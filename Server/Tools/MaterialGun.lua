MaterialGun = ToolGun.Inherit("MaterialGun")

function MaterialGun:Constructor(location, rotation)
	-- Calls parent ToolGun constructor
	ToolGun.Constructor(self, location, rotation, Color.GREEN)
end

-- Players' characters are left alone, like the Color Gun does
function MaterialGun.CanTarget(entity)
	if (not NanosUtils.IsEntityValid(entity)) then return false end

	return not (entity:IsA(Character) and entity:GetPlayer())
end

function MaterialGun:OnApplyMaterial(player, entity, hit_location, direction, preset_id, index)
	if (not MaterialGun.CanTarget(entity)) then return end

	local preset = GetMaterialGunPreset(preset_id)
	if (not preset) then return end

	entity:SetMaterial(preset.material, SanitizeMaterialIndex(index))
	Particle(hit_location, direction:ToOrientationRotator(), "nanos-world::P_DirectionalBurst")
end

function MaterialGun:OnResetMaterial(player, entity, hit_location, direction, index)
	if (not MaterialGun.CanTarget(entity)) then return end

	entity:ResetMaterial(SanitizeMaterialIndex(index))
	Particle(hit_location, direction:ToOrientationRotator(), "nanos-world::P_DirectionalBurst")
end

MaterialGun.SubscribeRemote("ApplyMaterial", MaterialGun.OnApplyMaterial)
MaterialGun.SubscribeRemote("ResetMaterial", MaterialGun.OnResetMaterial)
