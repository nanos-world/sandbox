LogicButton = Prop.Inherit("LogicButton")

ConfigureSpawnLimits("Button", "Buttons", LogicButton.GetCount, "max_buttons")

-- The Spawn Menu calls it with (location, rotation, tab, id, player), style is one of BUTTON_STYLES' ids (Classic when nil or unknown)
function LogicButton:Constructor(location, rotation, tab, id, player, switchable, style)
	style = GetButtonStyle(style) or BUTTON_STYLES[1]

	self.Super:Constructor(location, rotation, style.base, CollisionType.Auto, true, GrabMode.Enabled, CCDMode.Auto, SpawnMode.Manual)
	self.base_mesh = style.base

	self.cooldown_timeout = nil
	self.last_pressed_time = 0

	-- Makes it switchable by default
	self:SetSwitchable(player, switchable ~= false)

	-- Starts off by default
	self.is_active = false

	-- Linked entities (note that destroyed entities may still exist if they are not gced yet)
	self.linked_entities = setmetatable({}, { __mode = "k" })

	self:FinishSpawn()

	-- Spawns the moving part (it attaches to the spawned base) and sets the cooldown
	self:SetStyle(player, style.id)

	if (player) then
		Events.CallRemote("AddNotification", player, Reliability.Reliable, NotificationType.Info, "BUTTON_WIRE_TUTORIAL", "use a Wire Gun to link buttons to other entities", 10, 5)
	end
end

-- Colors the style's tint slot: on the moving part when there is one, else on the base
function LogicButton:SetTint(color)
	self.tint = color

	local target = (self.part and self.part:IsValid()) and self.part or self
	if (self.style.tint_slot) then
		target:SetMaterialColorParameter("Tint", color, self.style.tint_slot)
	else
		target:SetMaterialColorParameter("Tint", color)
	end
end

-- Interacting is disabled while cooling down; with a moving part only the part is interactable, never the base
function LogicButton:SetPressable(pressable)
	self.pressable = pressable

	local grab_mode = pressable and GrabMode.Enabled or GrabMode.Disabled
	local has_part = self.part and self.part:IsValid()

	self:SetGrabMode(has_part and GrabMode.Disabled or grab_mode)

	if (has_part) then
		self.part:SetGrabMode(grab_mode)
	end
end

-- Moves the part to its on or off placement (relative to the base it is attached to), instantly when time is 0
function LogicButton:Animate(is_on, time)
	local style = self.style
	if (not self.part or not self.part:IsValid()) then return end

	time = time or style.time

	if (style.push) then
		local location = style.offset - Vector(0, 0, is_on and style.push or 0)
		if (time > 0) then self.part:TranslateRelativeTo(location, time) else self.part:SetRelativeLocation(location) end
	else
		local rotation = Rotator(0, 0, is_on and style.on or style.off)
		if (time > 0) then self.part:RotateRelativeTo(rotation, time) else self.part:SetRelativeRotation(rotation) end
	end
end

function LogicButton:SetStyle(player, style_id)
	local style = GetButtonStyle(style_id)
	if (not style) then
		Console.Warn("LogicButton: unknown style '%s'", tostring(style_id))
		return
	end

	self.style = style
	self.cooldown = style.cooldown or 500
	self:SetValue("Style", style.id, true)

	if (self.base_mesh ~= style.base) then
		self.base_mesh = style.base
		self:SetMesh(style.base)
	end

	if (style.part) then
		if (self.part and self.part:IsValid()) then
			self.part:SetMesh(style.part)
		else
			-- Rides on the base out of the physics simulation (StaticOnly, so it never pushes the base around), only Animate moves it
			self.part = Prop(self:GetLocation(), self:GetRotation(), style.part, CollisionType.StaticOnly, false, GrabMode.Enabled)
			-- Selecting, grabbing or targeting the part with a tool acts on the button (see GetOwnerEntity)
			self.part:SetValue("OwnerEntity", self, true)
			self.part:SetMassOverride(1)
			self.part:Subscribe("Interact", function(_, character)
				self:Press(character:GetPlayer(), character)
				return false
			end)
			self.part:Subscribe("TakeDamage", function(_, damage, bone, type, from_direction, instigator, causer)
				return self:OnTakeDamage(damage, bone, type, from_direction, instigator, causer)
			end)
			self.part:AttachTo(self, AttachmentRule.SnapToTarget, "", 0)
		end

		self.part:SetRelativeLocation(style.offset)
		self.part:SetRelativeRotation(Rotator())
		self:Animate(self.switchable and self.is_active, 0)
	elseif (self.part) then
		if (self.part:IsValid()) then self.part:Destroy() end
		self.part = nil
	end

	self:SetValue("Part", self.part, true)

	-- The part may have just appeared or gone, so the base's interactability follows it
	self:SetPressable(self.pressable ~= false)

	if (self.tint) then
		self:SetTint(self.tint)
	end
end

function LogicButton:SetActivatedColor(player, color)
	self.activated_color = color
	self:SetValue("ActivatedColor", color, true)

	if (self.is_active) then
		self:SetTint(color)
	end
end

function LogicButton:SetDeactivatedColor(player, color)
	self.deactivated_color = color
	self:SetValue("DeactivatedColor", color, true)

	if (not self.is_active) then
		self:SetTint(color)
	end
end

function LogicButton:SetSwitchable(player, switchable)
	self.switchable = switchable
	self:SetValue("Switchable", switchable, true)
end

function LogicButton:Press(player_instigator, causer)
	-- Test cooldown
	if (self.cooldown > 0) then
		local now = Server.GetTime()
		if (now - self.last_pressed_time < self.cooldown) then
			return false
		end

		self.last_pressed_time = now
	end

	-- If switchable and is active, then deactivate, else always activate
	if (self.switchable and self.is_active) then
		self:Deactivate(player_instigator, causer)
	else
		self:Activate(player_instigator, causer)
	end

	return false
end

function LogicButton:OnInteract(character)
	self:Press(character:GetPlayer(), character)
	return false
end

-- Shooting it presses it too (only shots: an explosion or a punch nearby does not)
function LogicButton:OnTakeDamage(damage, bone, type, from_direction, instigator, causer)
	if (type == DamageType.Shot) then
		self:Press(instigator, causer)
	end
	return false
end

function LogicButton:LinkEntity(entity, show_wire, wire_color)
	-- Already linked
	if (self.linked_entities[entity]) then
		return false
	end

	local link_data = {}

	if (show_wire) then
		local cable = Cable(self:GetLocation(), true)
		cable:SetMaterial("nanos-world::M_Default_Masked_Lit")
		cable:SetMaterialColorParameter("Tint", wire_color or Color.BLACK)
		cable:SetCableSettings(1, 1)
		cable:SetRenderingSettings(2, 4, 1)
		cable:AttachStartTo(self)
		cable:AttachEndTo(entity)

		link_data = {
			cable = cable
		}
	end

	self.linked_entities[entity] = link_data

	return true
end

function LogicButton:UnlinkAllEntities()
	for entity, linked_entity_data in pairs(self.linked_entities) do
		if (linked_entity_data.cable and linked_entity_data.cable:IsValid()) then
			linked_entity_data.cable:Destroy()
		end
	end

	self.linked_entities = setmetatable({}, { __mode = "k" })
end

function LogicButton:UnlinkEntity(entity)
	local linked_entity = self.linked_entities[entity]
	if (not linked_entity) then
		return false
	end

	if (linked_entity.cable and linked_entity.cable:IsValid()) then
		linked_entity.cable:Destroy()
	end

	self.linked_entities[entity] = nil

	return true
end

function LogicButton:Activate(player_instigator, causer, activated_entities)
	-- Prevents recursion
	if (activated_entities) then
		if (activated_entities[self]) then return end
	else
		activated_entities = {}
	end

	activated_entities[self] = true

	self.is_active = true
	-- Synced, so every client (late joiners too) shows the label of what the next press does
	if (self.switchable) then self:SetValue("Active", true, true) end

	self:Animate(true)

	-- Not switchable, a push part springs back right away and a tilting one once the cooldown is over (or right away, without cooldown)
	if (not self.switchable and self.part) then
		local release = self.style.push and BUTTON_PUSH_RELEASE or self.cooldown
		Timer.Bind(Timer.SetTimeout(function()
			if (not self.switchable) then self:Animate(false) end
		end, math.max(release, 1)), self)
	end

	-- Disables pressing and changes color if have cooldown
	if (self.cooldown > 0) then
		self:SetPressable(false)
		self:SetTint(self.activated_color or Color.GREEN)

		self.cooldown_timeout = Timer.SetTimeout(function()
			self.cooldown_timeout = nil
			self:ResetCooldown()

			-- Resets active as well if not switchable, so we always come back to is_active = false
			if (not self.switchable) then
				self.is_active = false
			end
		end, self.cooldown)

		Timer.Bind(self.cooldown_timeout, self)
	end

	-- Calls self
	if (self.OnActivated) then
		self:OnActivated(player_instigator, causer)
	end

	-- Calls the remote event on clients
	self:BroadcastRemoteEvent("OnActivated")

	-- Activates all linked entities
	for entity, _ in pairs(self.linked_entities) do
		if (entity and entity:IsValid()) then
			if (entity.Activate) then
				entity:Activate(player_instigator, self, activated_entities)
			end
		else
			self.linked_entities[entity] = nil
		end
	end
end

function LogicButton:Deactivate(player_instigator, causer, deactivated_entities)
	-- Prevents recursion
	if (deactivated_entities) then
		if (deactivated_entities[self]) then return end
	else
		deactivated_entities = {}
	end

	deactivated_entities[self] = true

	self.is_active = false
	self:SetValue("Active", false, true)

	self:Animate(false)

	-- Disables pressing and changes color if have cooldown
	if (self.cooldown > 0) then
		self:SetPressable(false)
		self:SetTint(self.deactivated_color or Color.RED)

		-- Resets cooldown after the time
		self.cooldown_timeout = Timer.SetTimeout(function()
			self.cooldown_timeout = nil
			self:ResetCooldown()
		end, self.cooldown)

		Timer.Bind(self.cooldown_timeout, self)
	end

	-- Calls the remote event on clients
	self:BroadcastRemoteEvent("OnDeactivated")

	-- Deactivates all linked entities
	for entity, _ in pairs(self.linked_entities) do
		if (entity and entity:IsValid()) then
			if (entity.Deactivate) then
				entity:Deactivate(player_instigator, self, deactivated_entities)
			end
		else
			self.linked_entities[entity] = nil
		end
	end
end

function LogicButton:ResetCooldown()
	if (self.cooldown_timeout) then
		Timer.ClearTimeout(self.cooldown_timeout)
		self.cooldown_timeout = nil
	end

	-- Re-enables interacting
	self:SetPressable(true)

	-- If not switchable, then we turn the color back, otherwise don't do nothing and keep the existing color
	if (not self.switchable) then
		local color = self.is_active and (self.deactivated_color or Color.RED) or (self.activated_color or Color.GREEN)
		self:SetTint(color)
	end
end

function LogicButton:SetActivateLabel(player, label)
	self:SetValue("ActivateLabel", label, true)
	self:BroadcastRemoteEvent("UpdateLabel")
end

function LogicButton:SetDeactivateLabel(player, label)
	self:SetValue("DeactivateLabel", label, true)
	self:BroadcastRemoteEvent("UpdateLabel")
end

function LogicButton:OnDestroy()
	if (self.part and self.part:IsValid()) then self.part:Destroy() end
end

LogicButton.Subscribe("Interact", LogicButton.OnInteract)
LogicButton.Subscribe("TakeDamage", LogicButton.OnTakeDamage)
LogicButton.Subscribe("Destroy", LogicButton.OnDestroy)
LogicButton.SubscribeRemote("Press", LogicButton.Press)
LogicButton.SubscribeRemote("SetStyle", LogicButton.SetStyle)
LogicButton.SubscribeRemote("SetSwitchable", LogicButton.SetSwitchable)
LogicButton.SubscribeRemote("SetActivatedColor", LogicButton.SetActivatedColor)
LogicButton.SubscribeRemote("SetDeactivatedColor", LogicButton.SetDeactivatedColor)
LogicButton.SubscribeRemote("SetActivateLabel", LogicButton.SetActivateLabel)
LogicButton.SubscribeRemote("SetDeactivateLabel", LogicButton.SetDeactivateLabel)
