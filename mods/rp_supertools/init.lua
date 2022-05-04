local S = minetest.get_translator("rp_supertools")

minetest.register_craftitem(
   "rp_supertools:growth_tool",
   {
      description = S("Growth Tool"),
      _tt_help = S("Make plants grow instantly"),
      inventory_image = "rp_supertools_growth_tool.png",
      wield_image = "rp_supertools_growth_tool.png",
      groups = { supertool = 1 },
      on_place = function(itemstack, user, pointed_thing)
	 if pointed_thing.type ~= "node" then
             return itemstack
	 end
         local pos_protected = minetest.get_pointed_thing_position(pointed_thing, true)
         if minetest.is_protected(pos_protected, user:get_player_name()) and
                 not minetest.check_player_privs(user, "protection_bypass") then
             minetest.record_protection_violation(pos_protected, user:get_player_name())
             return itemstack
         end

	 local apos = pointed_thing.above
	 local upos = pointed_thing.under
         local unode = minetest.get_node(upos)
         local anode = minetest.get_node(apos)

         local diff = vector.subtract(apos, upos)
	 local used = false
         if minetest.get_item_group(unode.name, "sapling") ~= 0 then
            minetest.get_node_timer(upos):start(0)
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
            if not minetest.is_creative_enabled(user:get_player_name()) then
               itemstack:add_wear(5400) -- 13 uses
            end
         end

         return itemstack
      end,
})
