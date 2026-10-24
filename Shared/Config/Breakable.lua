-- Props that break apart when hit hard or damaged, by mesh: Sandbox breaks every Prop of these meshes, whoever spawned it (Server/Entities/Breakable.lua)
-- Other packages add theirs with Sandbox.SetBreakableProp, and a single prop is kept whole with prop:SetValue("Unbreakable", true)
--	["ASSET"] = {
--		weakness,                                               hit intensity (or damage x 50) it takes to break (500 when nil)
--		debris = { { mesh, rotation, offset, lifespan, randomness }, ... },   the pieces spawned in its place (on the clients)
--		explosive = {                                           blows up when it breaks
--			base_damage, minimum_damage, damage_inner_radius, damage_outer_radius, damage_falloff,
--			inflammable = { duration, force, relative_particle },   leaks and burns for duration (ms) when damaged, then blows up
--		},
--	}
BREAKABLE_PROPS = {
	-- SM_Fruit_Watermelon_01
	["nanos-world::SM_Fruit_Watermelon_01"] = {
		weakness = 700,
		debris = {
			{
				mesh = "nanos-world::SM_Fruit_Watermelon_01_Half_01",
				rotation = Rotator()
			},
			{
				mesh = "nanos-world::SM_Fruit_Watermelon_01_Half_01",
				rotation = Rotator(180, 0, 0)
			},
			{
				mesh = "nanos-world::SM_Fruit_Watermelon_01_Crust_01"
			},
			{
				mesh = "nanos-world::SM_Fruit_Watermelon_01_Slice_01"
			},
			{
				mesh = "nanos-world::SM_Fruit_Watermelon_01_Slice_01"
			},
		}
	},

	-- SM_Fruit_Cantaloupe_01
	["nanos-world::SM_Fruit_Cantaloupe_01"] = {
		weakness = 700,
		debris = {
			{
				mesh = "nanos-world::SM_Fruit_Cantaloupe_01_Half_01"
			},
			{
				mesh = "nanos-world::SM_Fruit_Cantaloupe_01_Slice_01"
			},
			{
				mesh = "nanos-world::SM_Fruit_Cantaloupe_01_Slice_01"
			},
			{
				mesh = "nanos-world::SM_Fruit_Cantaloupe_01_Slice_01"
			},
			{
				mesh = "nanos-world::SM_Fruit_Cantaloupe_01_Slice_01"
			},
			{
				mesh = "nanos-world::SM_Fruit_Cantaloupe_01_Slice_01"
			},
		}
	},

	-- SM_Fruit_Plum_01
	["nanos-world::SM_Fruit_Plum_01"] = {
		weakness = 700,
		debris = {
			{
				mesh = "nanos-world::SM_Fruit_Plum_01_Half_01",
				rotation = Rotator()
			},
			{
				mesh = "nanos-world::SM_Fruit_Plum_01_Half_02",
				rotation = Rotator()
			},
		}
	},

	-- SM_Fruit_Mango_01
	["nanos-world::SM_Fruit_Mango_01"] = {
		weakness = 700,
		debris = {
			{
				mesh = "nanos-world::SM_Fruit_Mango_01_Half_01",
				rotation = Rotator()
			},
			{
				mesh = "nanos-world::SM_Fruit_Mango_01_Half_01",
				rotation = Rotator(180, 0, 0)
			},
		}
	},

	-- SM_Fruit_Lemon_01
	["nanos-world::SM_Fruit_Lemon_01"] = {
		weakness = 700,
		debris = {
			{
				mesh = "nanos-world::SM_Fruit_Lemon_01_Half_01",
				rotation = Rotator()
			},
			{
				mesh = "nanos-world::SM_Fruit_Lemon_01_Half_01",
				rotation = Rotator(180, 0, 0)
			},
		}
	},

	-- SM_Fruit_Squash_01
	["nanos-world::SM_Fruit_Squash_01"] = {
		weakness = 700,
		debris = {
			{
				mesh = "nanos-world::SM_Fruit_Squash_01_Half_01",
				rotation = Rotator()
			},
			{
				mesh = "nanos-world::SM_Fruit_Squash_01_Half_01",
				rotation = Rotator(0, 180, 0)
			},
		}
	},

	-- SM_Veg_Onion_Red_01
	["nanos-world::SM_Veg_Onion_Red_01"] = {
		weakness = 700,
		debris = {
			{
				mesh = "nanos-world::SM_Veg_Onion_Red_01_Cut",
				rotation = Rotator()
			},
			{
				mesh = "nanos-world::SM_Veg_Onion_Red_01_Cut",
				rotation = Rotator(180, 0, 0)
			},
		}
	},

	-- SM_Veg_Artichoke_01
	["nanos-world::SM_Veg_Artichoke_01"] = {
		weakness = 700,
		debris = {
			{
				mesh = "nanos-world::SM_Veg_Artichoke_01_Half_01",
				rotation = Rotator()
			},
			{
				mesh = "nanos-world::SM_Veg_Artichoke_01_Half_01",
				rotation = Rotator(0, 180, 0)
			},
		}
	},

	-- SM_Fruit_Lime_01
	["nanos-world::SM_Fruit_Lime_01"] = {
		weakness = 700,
		debris = {
			{
				mesh = "nanos-world::SM_Fruit_Lime_01_Half_01",
				rotation = Rotator()
			},
			{
				mesh = "nanos-world::SM_Fruit_Lime_01_Half_01",
				rotation = Rotator(180, 0, 0)
			},
		}
	},

	-- SM_Fruit_Orange_01
	["nanos-world::SM_Fruit_Orange_01"] = {
		weakness = 700,
		debris = {
			{
				mesh = "nanos-world::SM_Fruit_Orange_01_Half_01",
				rotation = Rotator()
			},
			{
				mesh = "nanos-world::SM_Fruit_Orange_01_Wedge_01",
				rotation = Rotator()
			},
		}
	},

	-- SM_Fruit_Apple_01
	["nanos-world::SM_Fruit_Apple_01"] = {
		weakness = 700,
		debris = {
			{
				mesh = "nanos-world::SM_Fruit_Apple_01_Half_01",
				rotation = Rotator()
			},
			{
				mesh = "nanos-world::SM_Fruit_Apple_01_Quarter_01",
				rotation = Rotator()
			},
		}
	},

	-- SM_Fruit_Tomato_01
	["nanos-world::SM_Fruit_Tomato_01"] = {
		weakness = 700,
		debris = {
			{
				mesh = "nanos-world::SM_Fruit_Tomato_01_SliceBottom",
				rotation = Rotator()
			},
			{
				mesh = "nanos-world::SM_Fruit_Tomato_01_SliceTop",
				rotation = Rotator()
			},
		}
	},

	-- SM_Fruit_Mandarin_01
	["nanos-world::SM_Fruit_Mandarin_01"] = {
		weakness = 700,
		debris = {
			{
				mesh = "nanos-world::SM_Fruit_Mandarin_01_Half_01",
				rotation = Rotator()
			},
			{
				mesh = "nanos-world::SM_Fruit_Mandarin_01_Wedge_01",
				rotation = Rotator()
			},
		}
	},

	-- SM_Fruit_Apple_Red_01
	["nanos-world::SM_Fruit_Apple_Red_01"] = {
		weakness = 700,
		debris = {
			{
				mesh = "nanos-world::SM_Fruit_Apple_Red_01_Half_01",
				rotation = Rotator()
			},
			{
				mesh = "nanos-world::SM_Fruit_Apple_Red_01_Quarter_01",
				rotation = Rotator()
			},
		}
	},

	-- SM_Fruit_Apple_Green_01
	["nanos-world::SM_Fruit_Apple_Green_01"] = {
		weakness = 700,
		debris = {
			{
				mesh = "nanos-world::SM_Fruit_Apple_Green_01_Half_01",
				rotation = Rotator()
			},
			{
				mesh = "nanos-world::SM_Fruit_Apple_Green_01_Quarter_01",
				rotation = Rotator()
			},
		}
	},

	-- SM_Fruit_Avocado_01
	["nanos-world::SM_Fruit_Avocado_01"] = {
		weakness = 700,
		debris = {
			{
				mesh = "nanos-world::SM_Fruit_Avocado_01_Half_01",
				rotation = Rotator()
			},
			{
				mesh = "nanos-world::SM_Fruit_Avocado_01_Half_02",
				rotation = Rotator()
			},
		}
	},

	-- SM_Fruit_Peach_01
	["nanos-world::SM_Fruit_Peach_01"] = {
		weakness = 700,
		debris = {
			{
				mesh = "nanos-world::SM_Fruit_Peach_01_Half_01",
				rotation = Rotator()
			},
			{
				mesh = "nanos-world::SM_Fruit_Peach_01_Half_02",
				rotation = Rotator()
			},
		}
	},

	-- SM_Bread_Pizza_01
	["nanos-world::SM_Bread_Pizza_01"] = {
		weakness = 700,
		debris = {
			{
				mesh = "nanos-world::SM_Bread_Pizza_01_Slice_01",
				rotation = Rotator()
			},
			{
				mesh = "nanos-world::SM_Bread_Pizza_01_Slice_02",
				rotation = Rotator()
			},
			{
				mesh = "nanos-world::SM_Bread_Pizza_01_Slice_03",
				rotation = Rotator()
			},
			{
				mesh = "nanos-world::SM_Bread_Pizza_01_Slice_04",
				rotation = Rotator()
			},
			{
				mesh = "nanos-world::SM_Bread_Pizza_01_Slice_05",
				rotation = Rotator()
			},
			{
				mesh = "nanos-world::SM_Bread_Pizza_01_Slice_06",
				rotation = Rotator()
			},
		}
	},

	-- SM_Fruit_Pear_01
	["nanos-world::SM_Fruit_Pear_01"] = {
		weakness = 700,
		debris = {
			{
				mesh = "nanos-world::SM_Fruit_Pear_01_Half_01",
				rotation = Rotator()
			},
			{
				mesh = "nanos-world::SM_Fruit_Pear_01_Half_01",
				rotation = Rotator(180, 0, 0)
			},
		}
	},

	-- SM_Bread_Loaf_Multi_01
	["nanos-world::SM_Bread_Loaf_Multi_01"] = {
		weakness = 700,
		debris = {
			{
				mesh = "nanos-world::SM_Bread_Loaf_Multi_01_Slice_01",
				rotation = Rotator(),
				offset = Vector(9, 0, 0)
			},
			{
				mesh = "nanos-world::SM_Bread_Loaf_Multi_01_SliceEnd",
				rotation = Rotator(),
				offset = Vector(12, 0, 0)
			},
			{
				mesh = "nanos-world::SM_Bread_Loaf_Multi_01_SliceLoaf",
				rotation = Rotator(),
				offset = Vector(-3, 0, 0)
			},
		}
	},

	-- SM_Onion_Red_01
	["nanos-world::SM_Onion_Red_01"] = {
		weakness = 700,
		debris = {
			{
				mesh = "nanos-world::SM_Onion_Red_01_Cut",
				rotation = Rotator()
			},
			{
				mesh = "nanos-world::SM_Onion_Red_01_Cut",
				rotation = Rotator(180, 0, 0)
			},
		}
	},

	-- SM_ConcreteBag_Stack_01
	["nanos-world::SM_ConcreteBag_Stack_01"] = {
		weakness = 700,
		debris = {
			{
				mesh = "nanos-world::SM_ConcreteBag",
				rotation = Rotator()
			},
			{
				mesh = "nanos-world::SM_ConcreteBag",
				rotation = Rotator()
			},
			{
				mesh = "nanos-world::SM_ConcreteBag",
				rotation = Rotator()
			},
			{
				mesh = "nanos-world::SM_ConcreteBag",
				rotation = Rotator()
			},
		}
	},

	-- SM_Trash_01
	["nanos-world::SM_Trash_01"] = {
		weakness = 600,
		debris = {
			{
				mesh = "nanos-world::SM_Bread_Pizza_01_Crust_01"
			},
			{
				mesh = "nanos-world::SM_Bread_Pizza_01_Slice_01"
			},
			{
				mesh = "nanos-world::SM_Bread_Muffin_01"
			},
		}
	},

	-- Explosives (an explosive table makes it blow up when it breaks)
	["nanos-world::SM_PropaneTank_01"] = {
		weakness = 700,
		explosive = {
			inflammable = {
				duration = 5000,
				force = -15000,
				relative_particle = Vector(0, 0, 40)
			}
		}
	},

	["nanos-world::SM_PropaneTank_02"] = {
		weakness = 700,
		explosive = {
			inflammable = {
				duration = 5000,
				force = -15000,
				relative_particle = Vector(0, 0, 40)
			}
		}
	},

	["nanos-world::SM_TallGasCanister_01"] = {
		weakness = 700,
		explosive = {
			damage_outer_radius = 1250,
			inflammable = {
				duration = 5000,
				force = -115000,
				relative_particle = Vector(0, 0, 160)
			}
		}
	},

	["nanos-world::SM_Barrel_01"] = {
		weakness = 700,
		explosive = {}
	},
	["nanos-world::SM_Canister"] = {
		weakness = 700,
		explosive = {}
	},
}
