-- Songs a Jukebox can play, listed in its Context Menu
-- duration (seconds) is when shuffle moves to the next song, a song without it just loops
JUKEBOX_SONGS = {
	-- Playground
	{ id = "nanos-world::A_Playground_01",			name = "Playground 01",		duration = 177 },
	{ id = "nanos-world::A_Playground_02",			name = "Playground 02",		duration = 174 },
	{ id = "nanos-world::A_Playground_03",			name = "Playground 03",		duration = 177 },
	{ id = "nanos-world::A_Playground_04",			name = "Playground 04",		duration = 177 },

	-- Lounge (the main menu's)
	{ id = "nanos-world::A_AirportLounge",			name = "Airport Lounge",		duration = 308 },
	{ id = "nanos-world::A_Apero_Hour",				name = "Apero Hour",			duration = 283 },
	{ id = "nanos-world::A_BackbayLounge",			name = "Backbay Lounge",		duration = 267 },
	{ id = "nanos-world::A_BossaAntigua",			name = "Bossa Antigua",			duration = 284 },
	{ id = "nanos-world::A_CoolVibes",				name = "Cool Vibes",			duration = 219 },
	{ id = "nanos-world::A_CovertAffair",			name = "Covert Affair",			duration = 195 },
	{ id = "nanos-world::A_CrinolineDreams",		name = "Crinoline Dreams",		duration = 247 },
	{ id = "nanos-world::A_Deuces",					name = "Deuces",				duration = 191 },
	{ id = "nanos-world::A_GeorgeStreetShuffle",	name = "George Street Shuffle",	duration = 269 },
	{ id = "nanos-world::A_GymnopedieNo1",			name = "Gymnopedie No. 1",		duration = 188 },
	{ id = "nanos-world::A_InYourArms",				name = "In Your Arms",			duration = 169 },
	{ id = "nanos-world::A_Jazz_Brunch",			name = "Jazz Brunch",			duration = 324 },
	{ id = "nanos-world::A_LobbyTime",				name = "Lobby Time",			duration = 194 },
	{ id = "nanos-world::A_LocalForecast",			name = "Local Forecast",		duration = 200 },
	{ id = "nanos-world::A_LongStroll",				name = "Long Stroll",			duration = 255 },
	{ id = "nanos-world::A_MiningByMoonlight",		name = "Mining by Moonlight",	duration = 204 },
	{ id = "nanos-world::A_OpportunityWalks",		name = "Opportunity Walks",		duration = 162 },
	{ id = "nanos-world::A_PoppersAndProsecco",		name = "Poppers and Prosecco",	duration = 194 },
	{ id = "nanos-world::A_SmoothLovin",			name = "Smooth Lovin",			duration = 260 },

	-- Christmas
	{ id = "nanos-world::A_Deck_The_Halls",			name = "Deck the Halls",		duration = 266 },
	{ id = "nanos-world::A_Jingle_Bells",			name = "Jingle Bells",			duration = 143 },
	{ id = "nanos-world::A_NouvelleNoel",			name = "Nouvelle Noel",			duration = 192 },
	{ id = "nanos-world::A_We_Wish_You_A_Merry_Christmas",	name = "We Wish You a Merry Christmas",	duration = 138 },

	-- Halloween
	{ id = "nanos-world::A_Darkest_Child_Var",		name = "Darkest Child",			duration = 198 },
	{ id = "nanos-world::A_Evil_Plan",				name = "Evil Plan",				duration = 61 },
	{ id = "nanos-world::A_Industrial_Music_Box",	name = "Industrial Music Box",	duration = 103 },
	{ id = "nanos-world::A_Iron_Horse",				name = "Iron Horse",			duration = 100 },

	{ id = "nanos-world::A_BrandenburgNo4",			name = "Brandenburg No 4",		duration = 438 },
	{ id = "nanos-world::A_CanonInDMajor",			name = "Canon in D Major",		duration = 356 },
	{ id = "nanos-world::A_CelloSuite1InGPrelude",	name = "Cello Suite 1 in G",	duration = 129 },
	{ id = "nanos-world::A_PreludeInC",				name = "Prelude in C",			duration = 179 }
}

-- Playlists a Jukebox shuffles within, by song id; a song can be in more than one, the first playlist is the default
JUKEBOX_PLAYLISTS = {
	{ id = "playground", name = "playground", songs = {
		"nanos-world::A_Playground_01",
		"nanos-world::A_Playground_02",
		"nanos-world::A_Playground_03",
		"nanos-world::A_Playground_04"
	} },
	{ id = "lounge", name = "lounge", songs = {
		"nanos-world::A_AirportLounge",
		"nanos-world::A_Apero_Hour",
		"nanos-world::A_BackbayLounge",
		"nanos-world::A_BossaAntigua",
		"nanos-world::A_CoolVibes",
		"nanos-world::A_CovertAffair",
		"nanos-world::A_CrinolineDreams",
		"nanos-world::A_Deuces",
		"nanos-world::A_GeorgeStreetShuffle",
		"nanos-world::A_GymnopedieNo1",
		"nanos-world::A_InYourArms",
		"nanos-world::A_Jazz_Brunch",
		"nanos-world::A_LobbyTime",
		"nanos-world::A_LocalForecast",
		"nanos-world::A_LongStroll",
		"nanos-world::A_MiningByMoonlight",
		"nanos-world::A_OpportunityWalks",
		"nanos-world::A_PoppersAndProsecco",
		"nanos-world::A_SmoothLovin",
	} },
	{ id = "christmas", name = "christmas", songs = {
		"nanos-world::A_Jingle_Bells",
		"nanos-world::A_Deck_The_Halls",
		"nanos-world::A_NouvelleNoel",
		"nanos-world::A_We_Wish_You_A_Merry_Christmas"
	} },
	{ id = "halloween", name = "halloween", songs = {
		"nanos-world::A_Darkest_Child_Var",
		"nanos-world::A_Evil_Plan",
		"nanos-world::A_Industrial_Music_Box",
		"nanos-world::A_Iron_Horse"
	} },
	{ id = "classical", name = "classical", songs = {
		"nanos-world::A_GymnopedieNo1",
		"nanos-world::A_BrandenburgNo4",
		"nanos-world::A_CanonInDMajor",
		"nanos-world::A_CelloSuite1InGPrelude",
		"nanos-world::A_PreludeInC"
	} },
}

-- Default volume (0-1) and how far the song carries (cm), changeable per jukebox between the min and max distance
JUKEBOX_VOLUME = 1
JUKEBOX_INNER_RADIUS = 100
JUKEBOX_FALLOFF_DISTANCE = 5000
JUKEBOX_MIN_DISTANCE = 500
JUKEBOX_MAX_DISTANCE = 20000
