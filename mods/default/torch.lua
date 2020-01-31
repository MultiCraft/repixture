local S = minetest.get_translator("default")

-- Torches



local function register_torch(subname, description, tt_help, tiles, overlay_tiles, overlay_side_R90, inv_image, light)
   minetest.register_node(
      "default:"..subname,
      {
         description = description,
         _tt_help = tt_help,
         drawtype = "nodebox",
         tiles = tiles,
         overlay_tiles = overlay_tiles,
         inventory_image = inv_image,
         wield_image = inv_image,
         paramtype = "light",
         paramtype2 = "wallmounted",
         light_source = light,
         sunlight_propagates = true,
         walkable = false,
         floodable = true,
         on_flood = function(pos, oldnode, newnode)
            minetest.add_item(pos, "default:torch_dead")
         end,
         node_placement_prediction = "",
         node_box = {
	    type = "wallmounted",
	    wall_top = {-2/16, 0, -2/16, 2/16, 0.5, 2/16},
	    wall_bottom = {-2/16, -0.5, -2/16, 2/16, 0, 2/16},
	    wall_side = {-0.5, -8/16, -2/16, -0.5+4/16, 0, 2/16},
         },
         groups = {choppy = 2, dig_immediate = 3, attached_node = 1, torch = 1},
         is_ground_content = false,
         sounds = default.node_sound_defaults(),
         on_construct = function(pos)
             local node = minetest.get_node(pos)
             local dir = minetest.wallmounted_to_dir(node.param2)
             if dir.x ~= 0 or dir.z ~= 0 then
                 minetest.set_node(pos, {name="default:"..subname.."_wall", param2 = node.param2})
             end
         end,
   })
   local copy, copy_o
   for i=1,6 do
      if tiles[i] ~= nil then
          copy = tiles[i]
      else
          tiles[i] = copy
      end
      if overlay_tiles then
          if overlay_tiles[i] ~= nil then
              copy_o = overlay_tiles[i]
          else
              overlay_tiles[i] = copy_o
          end
      end
   end
   local copy_tile = function(tile)
      if type(tile) == "table" then
         return table.copy(tile)
      else
         return tile
      end
   end
   local overlay_tiles2
   if overlay_tiles then
      overlay_tiles2 = {
          copy_tile(overlay_tiles[3]),
          copy_tile(overlay_tiles[4]),
          copy_tile(overlay_side_R90),
          copy_tile(overlay_side_R90),
          copy_tile(overlay_tiles[1]),
          copy_tile(overlay_tiles[2]),
      }
   end
   local tiles2
   if tiles then
      tiles2 = {
          tiles[3],
          tiles[4],
          tiles[5].."^[transformR90",
          tiles[6].."^[transformR90",
          tiles[1],
          tiles[2],
      }
   end
   minetest.register_node(
      "default:"..subname.."_wall",
      {
         drawtype = "nodebox",
         tiles = tiles2,
         overlay_tiles = overlay_tiles2,
         paramtype = "light",
         paramtype2 = "wallmounted",
         light_source = light,
         sunlight_propagates = true,
         walkable = false,
         floodable = true,
         on_flood = function(pos, oldnode, newnode)
            minetest.add_item(pos, "default:torch_dead")
         end,
         node_box = {
	    type = "wallmounted",
	    wall_top = {-2/16, 0, -2/16, 2/16, 0.5, 2/16},
	    wall_bottom = {-2/16, -0.5, -2/16, 2/16, 0, 2/16},
	    wall_side = {-0.5, -8/16, -2/16, -0.5+4/16, 0, 2/16},
         },
         drop = "default:"..subname,
         groups = {choppy = 2, dig_immediate = 3, attached_node = 1, not_in_creative_inventory = 1, torch = 2},
         is_ground_content = false,
         sounds = default.node_sound_defaults(),
   })




end

local tiles_base = {"default_torch_ends.png","default_torch_bottom.png","default_torch_base.png"}
local overlay_tiles_weak = {
    {
        name = "default_torch_weak_ends_overlay.png",
        animation = {
            type = "vertical_frames",
            aspect_w = 16,
            aspect_h = 16,
            length = 1.0,
        },
    },
    {
        name = "blank.png"
    },
    {
        name = "default_torch_weak_overlay.png",
        animation = {
            type = "vertical_frames",
            aspect_w = 16,
            aspect_h = 16,
            length = 1.0,
        },
    },
}
local overlay_tiles_normal = {
    {
        name = "default_torch_ends_overlay.png",
        animation = {
            type = "vertical_frames",
            aspect_w = 16,
            aspect_h = 16,
            length = 1.0,
        },
    },
    {
        name = "blank.png",
    },
    {
        name = "default_torch_overlay.png",
        animation = {
            type = "vertical_frames",
            aspect_w = 16,
            aspect_h = 16,
            length = 1.0,
        },
    },
}

local overlayR90_weak = {
    name = "default_torch_weak_overlayR90.png",
    animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1.0,
    },
}
local overlayR90_normal = {
    name = "default_torch_overlayR90.png",
    animation = {
        type = "vertical_frames",
        aspect_w = 16,
        aspect_h = 16,
        length = 1.0,
    },
}

register_torch("torch_dead", S("Dead Torch"), S("Doesn't provide any light"), {"default_torch_ends.png","default_torch_bottom.png","default_torch_base.png"}, nil, nil, "default_torch_dead_inventory.png")
register_torch("torch_weak", S("Weak Torch"), S("Provides a bit of light but it will eventually burn out"), {"default_torch_ends.png","default_torch_bottom.png","default_torch_base.png"}, overlay_tiles_weak, overlayR90_weak, "default_torch_weak_inventory.png", default.LIGHT_MAX-4)
register_torch("torch", S("Torch"), S("It's bright and burns forever"), {"default_torch_ends.png","default_torch_bottom.png","default_torch_base.png"}, overlay_tiles_normal, overlayR90_normal, "default_torch_inventory.png", default.LIGHT_MAX-1)

minetest.register_lbm({
	label = "Upgrade wall torches",
	name = "default:replace_legacy_wall_torches",
	nodenames = { "default:torch", "default:torch_weak", "default:torch_dead" },
	action = function(pos, node)
		local dir = minetest.wallmounted_to_dir(node.param2)
		if dir and (dir.x ~= 0 or dir.z ~= 0) then
			node.name = node.name .. "_wall"
			minetest.set_node(pos, node)
		end
	end,
})

default.log("torch", "loaded")
