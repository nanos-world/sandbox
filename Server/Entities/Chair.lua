-- A chair characters sit on with interact, taking the free seat nearest to them, and leave with the StandUp key (Client/Entities/Chair.lua),
-- by dying, by ragdolling or when the chair goes away. Its style (CHAIR_STYLES) changes the mesh and its seats, a bench seats several
-- A seated character is attached to its seat, flying (no gravity) and without collision, or its movement would push it off the seat on its own client;
-- its camera is locked to third person meanwhile, as in first person the body turns to follow the camera
--
-- The seated character carries the synced value "SittingAnimation", every client plays it from there (so late joiners see it too)
Chair = Prop.Inherit("Chair")

ConfigureSpawnLimits("Chair", "Chairs", Chair.GetCount, "max_chairs")

-- The Spawn Menu calls it with (location, rotation, tab, id, player), style is one of CHAIR_STYLES' ids (Wooden when nil or unknown)
-- It is turned so its front faces whoever spawned it
function Chair:Constructor(location, rotation, tab, id, player, style)
	style = GetChairStyle(style) or CHAIR_STYLES[1]

	-- Grab stays enabled so interact reaches it, OnInteract returns false so it sits instead of picking up
	self.Super:Constructor(location or Vector(), (rotation or Rotator()) + Rotator(0, 180 - style.front, 0), style.mesh, CollisionType.Auto, true, GrabMode.Enabled, CCDMode.Auto, SpawnMode.Manual)
	self:FinishSpawn()

	-- Seat index -> the character on it
	self.seated = {}

	self:SetStyle(player, style.id)
end

function Chair:SetStyle(player, style_id)
	local style = GetChairStyle(style_id)
	if (not style) then
		Console.Warn("Chair: unknown style '%s'", tostring(style_id))
		return
	end

	-- The seats change with it
	self:StandUpAll()

	self.style = style
	self:SetValue("Style", style.id, true)
	if (self:GetMesh() ~= style.mesh) then self:SetMesh(style.mesh) end
end

-- Index of the free seat nearest to location, nil when every seat is taken
function Chair:GetFreeSeat(location)
	local nearest, nearest_distance = nil, math.huge

	for index, seat in ipairs(self.style.seats) do
		if (not self.seated[index]) then
			local distance = self:GetSeatLocation(seat):Distance(location)
			if (distance < nearest_distance) then
				nearest, nearest_distance = index, distance
			end
		end
	end

	return nearest
end

function Chair:GetSeatLocation(seat)
	return self:GetLocation() + self:GetRotation():RotateVector(seat.offset)
end

-- What a seated character carries is kept in entity values, not Lua fields: a field set on a Character is only seen by the package that set it,
-- and other packages (the Playground map) seat characters too. "Chair" and "ChairSeat" (not synced) say where it sits
function Chair:Sit(character)
	if (character:GetValue("Chair") or character:IsDead() or character:IsInRagdollMode()) then return end

	local seat_index = self:GetFreeSeat(character:GetLocation())
	if (not seat_index) then return end

	local seat = self.style.seats[seat_index]
	local view_mode = character:GetViewMode()
	self.seated[seat_index] = character
	character:SetValue("Chair", self)
	character:SetValue("ChairSeat", seat_index)
	character:SetValue("ChairCameraMode", character:GetCameraMode())
	character:SetValue("ChairViewMode", view_mode)

	character:SetInputEnabled(false)
	character:SetFlyingMode(true)
	character:SetCollision(CollisionType.NoCollision)
	character:SetCameraMode(CameraMode.TPSOnly)
	if (view_mode == ViewMode.FPS) then character:SetViewMode(ViewMode.TPS1) end
	if (character.SetWeaponAimMode) then character:SetWeaponAimMode(AimMode.None) end

	character:AttachTo(self, AttachmentRule.SnapToTarget, "", 0)
	character:SetRelativeLocation(seat.offset)
	character:SetRelativeRotation(Rotator(0, seat.yaw, 0))

	character:SetValue("SittingAnimation", CHAIR_ANIMATION, true)
end

function Chair:StandUp(character)
	if (not character:IsValid() or character:GetValue("Chair") ~= self) then return end

	local seat_index = character:GetValue("ChairSeat")
	local seat = self.style.seats[seat_index]
	self.seated[seat_index] = nil

	character:SetValue("Chair", nil)
	character:SetValue("ChairSeat", nil)
	character:SetValue("SittingAnimation", nil, true)
	character:Detach()
	character:SetCollision(CollisionType.Auto)
	character:SetFlyingMode(false)
	character:SetCameraMode(character:GetValue("ChairCameraMode") or CameraMode.FPSTPS)
	character:SetViewMode(character:GetValue("ChairViewMode") or ViewMode.TPS1)

	-- A dead character keeps its input off, the respawn takes care of it
	if (not character:IsDead()) then character:SetInputEnabled(true) end

	-- Steps off in front of its seat
	if (seat) then
		local facing = Rotator(0, self:GetRotation().Yaw + seat.yaw, 0):GetForwardVector()
		local location = self:GetSeatLocation(seat) + facing * CHAIR_EXIT_DISTANCE
		location.Z = self:GetLocation().Z + CHAIR_EXIT_HEIGHT
		character:SetLocation(location)
	end
end

function Chair:StandUpAll()
	if (not self.seated) then return end

	-- StandUp empties the seats as it goes
	local seated = {}
	for _, character in pairs(self.seated) do seated[#seated + 1] = character end

	for _, character in ipairs(seated) do
		self:StandUp(character)
	end
	self.seated = {}
end

-- Interacting sits instead of picking it up
function Chair:OnInteract(character)
	self:Sit(character)
	return false
end

function Chair:OnStandUpRequest(player)
	local character = player:GetControlledCharacter()
	if (character) then self:StandUp(character) end
end

Chair.Subscribe("Interact", Chair.OnInteract)
Chair.Subscribe("Destroy", Chair.StandUpAll)
Chair.SubscribeRemote("SetStyle", Chair.SetStyle)
Chair.SubscribeRemote("StandUp", Chair.OnStandUpRequest)

-- A seated character leaves its chair when it dies, ragdolls or goes away
local function StandUpFromChair(character)
	local chair = character:GetValue("Chair")
	if (chair and chair:IsValid()) then chair:StandUp(character) end
end

Character.Subscribe("Death", StandUpFromChair)
Character.Subscribe("Destroy", StandUpFromChair)
Character.Subscribe("RagdollModeChange", function(character, old_state, new_state)
	if (new_state) then StandUpFromChair(character) end
end)
