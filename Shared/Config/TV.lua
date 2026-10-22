-- Models a TV and a CCTV's monitor can use, listed in their Context Menu: both show the picture on material index 1
-- A hanging one has no stand, so it floats where it is put (gravity off) to go on a wall
TV_MODELS = {
	{ id = "nanos-world::SM_TV",			name = "TV" },
	{ id = "nanos-world::SM_TV_Hanging",	name = "TV Hanging",	hanging = true },
}

-- Finds a model by its mesh, nil when unknown
function GetTVModel(mesh)
	for _, model in ipairs(TV_MODELS) do
		if (model.id == mesh) then return model end
	end
end
