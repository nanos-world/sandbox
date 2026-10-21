Ball = Prop.Inherit("Ball")

Ball.name = "Ball"
Ball.image = "package://sandbox/Client/Media/Entities/BallSoccer.webp"
Ball.category = "objects"

-- Context Menu Items when selecting this Entity
Ball.selected_context_menu_items = {
	{
		id = "ball_style",
		type = "select_image",
		label = "style",
		options = BALL_STYLES,
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetStyle", Reliability.Reliable, value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("Style") or BALL_STYLES[1].id
		end,
	},
}
