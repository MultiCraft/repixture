
--
-- Locks mod
-- By Kaadmy, for Pixture
--

local S = minetest.get_translator("rp_locks")
local N = function(s) return s end

local INFOTEXT_PUBLIC = N("Locked Chest")
local INFOTEXT_OWNED = N("Locked Chest (Owned by @1)")
local INFOTEXT_CRACKED_PUBLIC = N("Locked Chest (cracked open)")
local INFOTEXT_CRACKED_OWNED = N("Locked Chest (cracked open) (Owned by @1)")
local INFOTEXT_NAMED_OWNED = N("@1 (Owned by @2)")

locks = {}

-- Settings

local picked_time = tonumber(minetest.settings:get("locks_picked_time")) or 15 -- unlocked for 15 seconds
local all_unlocked = minetest.settings:get_bool("locks_all_unlocked")

-- API functions

function locks.is_owner(meta, player)
   local name = player:get_player_name()
   local owner = meta:get_string("lock_owner")

   return name == owner
end

function locks.has_owner(meta)
   return meta:get_string("lock_owner") ~= ""
end

function locks.is_locked(meta, player)
   if all_unlocked then
      return false
   end

   if locks.is_owner(meta, player) then
      return false
   end

   local t = minetest.get_gametime()

   local cracked = meta:get_int("lock_cracked")

   if cracked == 1 then
      return false
   end

   return true
end

-- Items and nodes

minetest.register_tool(
   "rp_locks:pick",
   {
      description = S("Lock Pick"),
      _tt_help = S("Cracks locked chests"),

      inventory_image = "locks_pick.png",
      wield_image = "locks_pick.png",

      sound = { breaks = "default_tool_breaks" },
      stack_max = 1,

      on_use = function(itemstack, player, pointed_thing)
         if pointed_thing.type ~= "node" then
             return itemstack
         end
         local pos = pointed_thing.under
         if minetest.is_protected(pos, player:get_player_name()) and
                 not minetest.check_player_privs(player, "protection_bypass") then
             minetest.record_protection_violation(pos, player:get_player_name())
             return itemstack
         end

         local node = minetest.get_node(pos)
         if minetest.get_item_group(node.name, "locked") == 0 then
            return itemstack
         end
         local meta = minetest.get_meta(pos)
         local cracked = meta:get_int("lock_cracked") == 1
         if cracked then
            -- Is already open
            return itemstack
         end
         -- Attempt to pick lock
         if math.random(1, 5) <= 1 then
            -- Success!
            meta:set_int("lock_cracked", 1)
            local timer = minetest.get_node_timer(pos)
            -- Unlock node for a limited time
            timer:start(picked_time)

            local owner = meta:get_string("lock_owner")
            if owner == "" then
               meta:set_string("infotext", S(INFOTEXT_CRACKED_PUBLIC))
            else
               meta:set_string("infotext", S(INFOTEXT_CRACKED_OWNED, owner))
            end

            -- TODO: Add graphical effect to show success

            local burglar = player:get_player_name()
            if owner then
               if owner ~= burglar then
                   minetest.chat_send_player(
                      owner,
                      minetest.colorize("#f00",
                          S("@1 has broken into your locked chest!", burglar)))
                   minetest.chat_send_player(
                       burglar,
                       minetest.colorize("#0f0", S("You have broken the lock!")))
               else
                   minetest.chat_send_player(
                      burglar,
                      minetest.colorize("#0f0", S("You have broken into your own locked chest!")))
               end
            else
               minetest.chat_send_player(
                   burglar,
                   minetest.colorize("#0f0", S("You have broken the lock!")))
            end
            achievements.trigger_achievement(player, "burglar")
            minetest.sound_play({name="locks_unlock",gain=0.8},{pos=pos, max_hear_distance=16}, true)
         else
            -- Failure!
            minetest.sound_play({name="locks_pick",gain=0.5},{pos=pos, max_hear_distance=16}, true)
         end

         if not minetest.settings:get_bool("creative_mode") then
             itemstack:add_wear(8200) -- about 8 uses
         end
         return itemstack
      end,
})

-- Use lock on chest to lock it
local put_lock = function(itemstack, putter, pointed_thing)
    if pointed_thing.type ~= "node" then
        return itemstack
    end
    local pos = pointed_thing.under
    local node = minetest.get_node(pos)
    if node.name == "rp_default:chest" then
        local name
        if putter and putter:is_player() then
           name = putter:get_player_name()
        end
        if minetest.is_protected(pos, name) and
                not minetest.check_player_privs(putter, "protection_bypass") then
            minetest.record_protection_violation(pos, name)
            return itemstack
        end
        node.name = "rp_locks:chest"
        minetest.swap_node(pos, node)
        local meta = minetest.get_meta(pos)
        if name ~= "" then
           meta:set_string("infotext", S(INFOTEXT_OWNED, name))
           meta:set_string("lock_owner", name)
        else
           meta:set_string("infotext", S(INFOTEXT_PUBLIC))
        end
        if not minetest.settings:get_bool("creative_mode") then
           itemstack:take_item()
        end
    end
    return itemstack
end

minetest.register_craftitem(
   "rp_locks:lock",
   {
      description = S("Lock"),
      _tt_help = S("Used to craft locked chests"),

      inventory_image = "locks_lock.png",
      wield_image = "locks_lock.png",

      -- Place or punch lock on chest to lock the chest
      on_use = put_lock,
      on_place = put_lock,
})

minetest.register_node(
   "rp_locks:chest",
   {
      description = S("Locked Chest"),
      _tt_help = S("Provides 32 inventory slots") .. "\n" .. S("Can only be opened by its owner and those who have a lockpick"),
      tiles ={
         "default_chest_top.png",
         "default_chest_top.png",
         "default_chest_sides.png",
         "default_chest_sides.png",
         "default_chest_sides.png",
         "locks_chest_front.png"
      },
      paramtype2 = "facedir",
      groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, locked = 1},
      is_ground_content = false,
      sounds = default.node_sound_wood_defaults(),
      on_construct = function(pos)
         local meta = minetest.get_meta(pos)
         meta:set_int("lock_cracked", 0)
         meta:set_string("infotext", S(INFOTEXT_PUBLIC))

         local inv = meta:get_inventory()
         inv:set_size("main", 8 * 4)
      end,
      after_place_node = function(pos, player)
         local name = player:get_player_name()

         local meta = minetest.get_meta(pos)
         meta:set_string("infotext", S(INFOTEXT_OWNED, name))
         meta:set_string("lock_owner", name)
      end,
      on_rightclick = function(pos, node, player)
         local meta = minetest.get_meta(pos)

         if not locks.is_locked(meta, player) then
            local np = pos.x .. "," .. pos.y .. "," .. pos.z
            local form = rp_formspec.get_page("rp_default:2part")
            form = form .. "list[nodemeta:" .. np .. ";main;0.25,0.25;8,4;]"
            form = form .. "listring[nodemeta:" .. np .. ";main]"
            form = form .. rp_formspec.get_itemslot_bg(0.25, 0.25, 8, 4)

            form = form .. "list[current_player;main;0.25,4.75;8,4;]"
            form = form .. "listring[current_player;main]"
            form = form .. rp_formspec.get_hotbar_itemslot_bg(0.25, 4.75, 8, 1)
            form = form .. rp_formspec.get_itemslot_bg(0.25, 5.75, 8, 3)

            minetest.show_formspec(
               player:get_player_name(),
               "default_chest",
               form
            )
         end
      end,
      on_timer = function(pos, elapsed)
         local meta = minetest.get_meta(pos)
         meta:set_int("lock_cracked", 0)
         local owner = meta:get_string("lock_owner")
         if owner == "" then
            meta:set_string("infotext", INFOTEXT_PUBLIC)
         else
            meta:set_string("infotext", S(INFOTEXT_OWNED, owner))
         end
      end,
      allow_metadata_inventory_move = function(pos, from_l, from_i, to_l, to_i, cnt, player)
         if minetest.is_protected(pos, player:get_player_name()) and
                 not minetest.check_player_privs(player, "protection_bypass") then
             minetest.record_protection_violation(pos, player:get_player_name())
             return 0
         end
         local meta = minetest.get_meta(pos)
         if locks.is_locked(meta, player) then
            return 0
         end
         return cnt
      end,
      allow_metadata_inventory_put = function(pos, listname, index, itemstack, player)
         if minetest.is_protected(pos, player:get_player_name()) and
                 not minetest.check_player_privs(player, "protection_bypass") then
             minetest.record_protection_violation(pos, player:get_player_name())
             return 0
         end
         local meta = minetest.get_meta(pos)
         if locks.is_locked(meta, player) then
            return 0
         end
         return itemstack:get_count()
      end,
      allow_metadata_inventory_take = function(pos, listname, index, itemstack, player)
         if minetest.is_protected(pos, player:get_player_name()) and
                 not minetest.check_player_privs(player, "protection_bypass") then
             minetest.record_protection_violation(pos, player:get_player_name())
             return 0
         end
         local meta = minetest.get_meta(pos)
         if locks.is_locked(meta, player) then
            return 0
         end
         return itemstack:get_count()
      end,
      can_dig = function(pos, player)
         local meta = minetest.get_meta(pos)
         local inv = meta:get_inventory()
         return inv:is_empty("main") and (locks.is_owner(meta, player) or (not locks.has_owner(meta)))
      end,
      write_name = function(pos, text)
         local meta = minetest.get_meta(pos)

         if text == "" then
            meta:set_string("infotext", S(INFOTEXT_OWNED,
                               meta:get_string("lock_owner")))
         else
            meta:set_string("infotext", S(INFOTEXT_NAMED_OWNED,
                               text, meta:get_string("lock_owner")))
         end
      end,
      on_blast = function() end,
})

-- Crafting

crafting.register_craft(
   {
      output = "rp_locks:pick",
      items = {
         "rp_default:ingot_steel 2",
         "rp_default:stick 3",
      },
})

crafting.register_craft(
   {
      output = "rp_locks:lock",
      items = {
         "rp_default:ingot_steel 3",
         "group:planks 2",
      },
})

crafting.register_craft(
   {
      output = "rp_locks:chest",
      items = {
         "rp_default:chest",
         "rp_locks:lock",
      },
})

-- Achievements

achievements.register_achievement(
   "locksmith",
   {
      title = S("Locksmith"),
      description = S("Craft a lock."),
      times = 1,
      craftitem = "rp_locks:lock",
})

achievements.register_achievement(
   "burglar",
   {
      title = S("Burglar"),
      description = S("Break into a locked chest."),
      times = 1,
})

-- Update node after the rename orgy after 1.5.3
minetest.register_lbm(
   {
      label = "Update locked chests",
      name = "rp_locks:update_locked_chests",
      nodenames = {"rp_locks:chest"},
      action = function(pos, node)
         local meta = minetest.get_meta(pos)
         local owner = meta:get_string("lock_owner")
         local cracked = meta:get_int("lock_cracked") == 1
         if cracked then
           if owner ~= "" then
              meta:set_string("infotext", S(INFOTEXT_CRACKED_OWNED, owner))
           else
              meta:set_string("infotext", S(INFOTEXT_CRACKED_PUBLIC))
           end
         else
           if owner ~= "" then
              meta:set_string("infotext", S(INFOTEXT_OWNED, owner))
           else
              meta:set_string("infotext", S(INFOTEXT_PUBLIC))
           end
         end
      end,
   }
)

minetest.register_alias("locks:chest", "rp_locks:chest")
minetest.register_alias("locks:lock", "rp_locks:lock")
minetest.register_alias("locks:pick", "rp_locks:pick")

default.log("mod:rp_locks", "loaded")
