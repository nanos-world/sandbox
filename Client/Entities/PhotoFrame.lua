PhotoFrame = Prop.Inherit("PhotoFrame")

PhotoFrame.name = "Photo Frame"
PhotoFrame.image = "package://sandbox/Client/Media/Entities/PhotoFrame.webp"
PhotoFrame.category = "display"


-- Context Menu Items when selecting this Entity
PhotoFrame.selected_context_menu_items = {
	{
		id = "photoframe_frame",
		type = "select",
		label = "frame",
		options = PHOTO_FRAME_STYLES,
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetFrame", Reliability.Reliable, value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetMesh()
		end,
	},
	{
		id = "photoframe_image",
		type = "text",
		multiline = true,
		label = "image",
		placeholder = "enter image url or base64...",
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetPhoto", Reliability.Reliable, value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetMaterialTextureParameter("Texture", 1) or ""
		end,
	},
}