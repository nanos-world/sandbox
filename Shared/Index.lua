-- Helper to load all files in a folder
function RequireAllLuaFilesInFolder(folder)
	local files = Package.GetFiles(folder, ".lua")
	for _, file in pairs(files) do
		Package.Require(file)
	end
end

-- Parts of an entity (like a Target's plate) keep their owner in the "OwnerEntity" value, so selecting, grabbing or targeting a part acts on the owner
function GetOwnerEntity(entity)
	if (not entity) then return nil end

	local owner = entity:GetValue("OwnerEntity")
	if (owner and owner:IsValid()) then return owner end

	return entity
end

-- Load all configs
RequireAllLuaFilesInFolder("Shared/Config")

Package.Require("Characters.lua")