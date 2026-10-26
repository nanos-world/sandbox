-- Ball styles, listed in its Context Menu: the material on SM_PG_Ball (a football sized sphere, BALL_RADIUS at scale 1), the scale it takes, its physical
-- material (how it bounces), its weight (kg) and how hard a run kicks it (multiplies the runner's speed)
BALL_STYLES = {
	{
		id = "Soccer",
		name = "Soccer",
		image = "package://sandbox/Client/Media/Entities/BallSoccer.webp",
		material = "nanos-world::MI_PG_Ball_Soccer",
		scale = 1,
		physical_material = "nanos-world::PM_Rubber",
		mass = 0.45,
		kick = 2.4
	},
	{
		id = "Basketball",
		name = "Basketball",
		image = "package://sandbox/Client/Media/Entities/BallBasketball.webp",
		material = "nanos-world::MI_PG_Ball_Basketball",
		scale = 1.1,
		physical_material = "nanos-world::PM_Rubber",
		mass = 0.6,
		kick = 1.3
	},
	{
		id = "Volleyball",
		name = "Volleyball",
		image = "package://sandbox/Client/Media/Entities/BallVolleyball.webp",
		material = "nanos-world::MI_PG_Ball_Volleyball",
		scale = 0.95,
		physical_material = "nanos-world::PM_Rubber",
		mass = 0.27,
		kick = 1.7
	},
	{
		id = "Beach",
		name = "Beach Ball",
		image = "package://sandbox/Client/Media/Entities/BallBeach.webp",
		material = "nanos-world::MI_PG_Ball_Beach",
		scale = 2.2,
		physical_material = "nanos-world::PM_RubberBouncy",
		mass = 0.1,
		kick = 1.2
	},
	{
		id = "Tennis",
		name = "Tennis Ball",
		image = "package://sandbox/Client/Media/Entities/BallTennis.webp",
		material = "nanos-world::MI_PG_Ball_Tennis",
		scale = 0.3,
		physical_material = "nanos-world::PM_RubberBouncy",
		mass = 0.06,
		kick = 1.8
	},
}

-- SM_PG_Ball's radius at scale 1 (cm)
BALL_RADIUS = 11

-- Radius (cm) of the sphere Trigger riding on the ball: a Trigger only tests the other actor's pivot, and a character's is its capsule middle ~90 up, so
-- this reaches it when the capsule is about 20 cm from the ball (sqrt(100^2 - 80^2) = 60 horizontally)
BALL_KICK_RADIUS = 100

-- Below this speed (cm/s) a character only nudges the ball away instead of kicking it, and how hard that nudge is (cm/s)
BALL_KICK_MIN_SPEED = 120
BALL_NUDGE = 150

-- Cooldowns (ms) between kicks: any kicker, and the same kicker again (with lag the ball can pass through someone and re-enter their reach)
BALL_KICK_COOLDOWN = 150
BALL_KICK_SAME_KICKER_COOLDOWN = 600

-- How high a kick lifts the ball, in parts of its forward speed: a sprint lobs it
BALL_KICK_LIFT = 0.2

-- The kick's thump (bounces use the physical material's own impact sound, like BouncyBall)
BALL_KICK_SOUND = "nanos-world::A_Ball_Impact"

-- Finds a style by id, nil when unknown
function GetBallStyle(id)
	for _, style in ipairs(BALL_STYLES) do
		if (style.id == id) then return style end
	end
end
