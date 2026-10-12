# Sandbox

The official nanos world Sandbox game-mode. Spawn props, weapons, vehicles and NPCs, build contraptions with physics tools and play freely with your friends.

![Sandbox](https://github.com/user-attachments/assets/6904cda3-3027-4777-b0ad-268ad8e82d6f)


## Features

- **Spawn Menu** (`Q`): every Prop, Weapon, Vehicle and Character from every loaded package, searchable and split by tabs and categories
- **Context Menu** (`C`): select any entity in the world and tweak it (tint, gravity, custom per-entity options)
- **Tool Guns**: Physics Gun, Weld, Rope, Elastic, Spring, Slider, Ball Socket, Thruster, Wheel, Balloon, Light, Lamp, Trail, Button, Wire, Color, Resizer, Remover and more
- **Entities**: TVs, CCTVs, Retro Cameras, Photo Frames, Signs, Floating Texts, Rope Lights, Flashlights, Bouncy Balls, Balloons...
- **Dynamic sky and weather** powered by Ultra Dynamic Sky
- **Undo** (`X`) and a spawn history
- **Noclip** (`B`), **Ragdoll** (`J`) and a **Scoreboard** (`Tab`)
- Per-server spawn limits for every entity type
- Extensible: other packages can add items, context menu options and notifications


## Requirements

This game-mode automatically loads:

- [Default Weapons](https://github.com/nanos-world/nanos-world-weapons)
- [Default Vehicles](https://github.com/nanos-world/nanos-world-vehicles)
- [Default Characters](https://github.com/nanos-world/default-characters)

Recommended map: `default-testing-map`.


## Installation

Add it as your game-mode in the server `Config.toml`:

```toml
[game]
    map =       "default-testing-map"
    game_mode = "sandbox"
```

Or start the server from the command line:

```bash
./NanosWorldServer.exe --game_mode sandbox --map default-testing-map
```


## Settings

All settings can be changed in the New Game menu, in `Config.toml` or through the command line with `--custom_settings`.

| Setting | Default | Description |
|---|---|---|
| `enable_auto_weather` | `true` | Weather changes automatically |
| `enable_default_sky` | `true` | Overrides the map lights with Ultra Dynamic Sky |
| `enable_noclip` | `true` | Players can noclip |
| `enable_pvp` | `true` | Players can damage each other |
| `max_props` | `1000` | Max props per player |
| `max_weapons` | `100` | Max weapons per player |
| `max_vehicles` | `50` | Max vehicles per player |
| `max_npcs` | `50` | Max NPCs per player |
| `max_tools` | `50` | Max tool guns per player |
| `max_*` | | There is a limit for every entity (balloons, cables, thrusters, tvs, etc.), see `Package.toml` |

Example:

```toml
[custom_settings]
    enable_pvp = false
    max_props =  200
```

```bash
./NanosWorldServer.exe --game_mode sandbox --custom_settings "enable_pvp=false, max_props=200"
```


## Adding your own items to the Spawn Menu

Any class inheriting from `Prop`, `Weapon`, `Melee`, `Grenade`, `Character`, `CharacterSimple`, `VehicleWheeled` or `VehicleWater` shows up automatically in the Spawn Menu, as long as it defines a `name`. You don't need to depend on Sandbox at all.

```lua
-- Shared/Index.lua of your package
MyRifle = Weapon.Inherit("MyRifle", {
	name = "My Rifle",                                     -- label in the Spawn Menu (required)
	image = "assets://nanos-world/Thumbnails/SK_AK47.jpg", -- thumbnail
	category = "rifles",                                   -- category inside the tab
	tab = "tools",                                         -- optional: override the tab it goes to
})

function MyRifle:Constructor(location, rotation)
	self.Super:Constructor(location or Vector(), rotation or Rotator(), "nanos-world::SK_AK47")
	self:SetDamage(50)
end
```

Load your package together with Sandbox and it will be there.


## Adding Context Menu options to your entities

Define `selected_context_menu_items` in your class and they will appear when a player selects the entity with the Context Menu (`C`):

```lua
MyLamp = Prop.Inherit("MyLamp", {
	name = "My Lamp",
	category = "furniture",
})

if (Client) then
	MyLamp.selected_context_menu_items = {
		{
			id = "lamp_on",
			type = "checkbox",
			label = "turned on",
			value = function()
				return Sandbox.ContextMenu.selected_entity:GetValue("TurnedOn")
			end,
			callback = function(value)
				Sandbox.ContextMenu.selected_entity:CallRemoteEvent("SetTurnedOn", Reliability.Reliable, value)
			end,
		},
	}
end
```

Supported item types: `button`, `checkbox`, `color`, `number`, `range`, `select`, `select_image` and `text`.


## Using Sandbox from other packages

Sandbox exports the `Sandbox` table with its subsystems:

```lua
-- Client side: shows a notification only once per player (stored in their persistent data)
Sandbox.Notifications.Add(NotificationType.Info, "my_package_welcome", "Welcome! Press F to use my thing", 10, 2)

-- Client side: the entity currently selected in the Context Menu
local entity = Sandbox.ContextMenu.selected_entity
```

```lua
-- Server side: shows a notification to a player
Events.CallRemote("AddNotification", player, Reliability.Reliable, NotificationType.Info, "my_id", "Hello there!", 5, 0, true)
```


## Example packages that work with Sandbox

- [TS Fireworks](https://github.com/gtnardy/nanos-world-ts-fireworks): adds a Firework Gun to the Tools tab


## Documentation

See the [Official Sandbox Documentation](https://docs.nanos-world.com/docs/next/explore/sandbox-game-mode) for more details.
