local S = minetest.get_translator("rp_supertools")

minetest.register_craftitem(
   "rp_supertools:growth_tool",
   {
      description = S("Growth Tool"),
      _tt_help = S("Make plants grow instantly"),
      inventory_image = "rp_supertools_growth_tool.png",
      wield_image = "rp_supertools_growth_tool.png",
      groups = { supertool = 1, tool = 1 },
      stack_max = 1,
      on_place = function(itemstack, placer, pointed_thing)
         -- Handle pointed node handlers and protection
         local handled, handled_itemstack = util.on_place_pointed_node_handler(itemstack, placer, pointed_thing)
         if handled then
            return handled_itemstack
         end
         if util.handle_node_protection(placer, pointed_thing) then
            return itemstack
         end

	 -- Handle growing things
	 local apos = pointed_thing.above
	 local upos = pointed_thing.under
         local unode = minetest.get_node(upos)
         local anode = minetest.get_node(apos)

         local diff = vector.subtract(apos, upos)
	 local used = false
         if minetest.get_item_group(unode.name, "sapling") ~= 0 then
            used = default.grow_sapling(upos)
         elseif diff.y > 0 and unode.name == "rp_default:dirt" and anode.name == "air" then
            local biomedata = minetest.get_biome_data(upos)
	    local biome = minetest.get_biome_name(biomedata.biome)
	    if default.is_dry_biome(biome) then
               minetest.set_node(upos, {name="rp_default:dirt_with_dry_grass"})
            else
               minetest.set_node(upos, {name="rp_default:dirt_with_grass"})
            end
	    used = true
         elseif diff.y > 0 and unode.name == "rp_default:swamp_dirt" and anode.name == "air" then
            minetest.set_node(upos, {name="rp_default:dirt_with_swamp_grass"})
	    used = true
         elseif diff.y > 0 and unode.name == "rp_default:dirt_with_grass" and anode.name == "air" then
            minetest.set_node(apos, {name="rp_default:grass"})
	    used = true
         elseif diff.y > 0 and unode.name == "rp_default:dirt_with_dry_grass" and anode.name == "air" then
            minetest.set_node(apos, {name="rp_default:dry_grass"})
	    used = true
         elseif diff.y > 0 and unode.name == "rp_default:dirt_with_swamp_grass" and anode.name == "air" then
            minetest.set_node(apos, {name="rp_default:swamp_grass"})
	    used = true
         elseif unode.name == "rp_default:grass" then
            minetest.set_node(upos, {name="rp_default:tall_grass"})
	    used = true
         elseif minetest.get_item_group(unode.name, "farming_plant") == 1 then
            local udef = minetest.registered_nodes[unode.name]
	    local plantname = udef._rp_farming_plant_name
            local has_grown = farming.next_stage(upos, plantname)
	    if has_grown then
               used = true
	    end
         elseif (unode.name == "rp_default:papyrus" or unode.name == "rp_default:cactus" or unode.name == "rp_default:thistle") then
            local top = vector.add(upos, vector.new(0,1,0))
	    if minetest.get_node(top).name == "air" then
               minetest.set_node(top, {name=unode.name})
	       used = true
            end
	 end

	 if used then
            minetest.sound_play({name="rp_default_fertilize", gain=1.0}, {pos=pointed_thing.under}, true)
            if not minetest.is_creative_enabled(placer:get_player_name()) then
               itemstack:add_wear(5400) -- 13 uses
            end

            minetest.log("action", "[rp_supertools] " .. placer:get_player_name() .. " used growth tool on "..unode.name.." at "..minetest.pos_to_string(upos))
         end

         return itemstack
      end,
})
