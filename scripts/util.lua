local constants = require("constants")

local M = {}

local SECTION_GROUP = constants.AUTOTRASH_SECTION_GROUP
local max_request = constants.max_request

local item_prototypes = {}

--- @param name string
--- @return LuaItemPrototype?
function M.item_prototype(name)
    if item_prototypes[name] then
        return item_prototypes[name]
    end
    item_prototypes[name] = prototypes.item[name]
    return item_prototypes[name]
end

--- Convert get_contents() result (2.0+ array or legacy map) to name → count.
--- @param contents table?
--- @return table<string, number>
function M.contents_to_name_map(contents)
    local map = {}
    if not contents then
        return map
    end
    for k, v in pairs(contents) do
        if type(v) == "table" and v.name then
            map[v.name] = (map[v.name] or 0) + (v.count or 0)
        elseif type(v) == "number" and type(k) == "string" then
            map[k] = v
        end
    end
    return map
end

--- Convert targeted_items_deliver / pickup arrays to name → count.
--- @param items table?
--- @return table<string, number>
function M.items_to_name_map(items)
    return M.contents_to_name_map(items)
end

function M.copy_preset(preset)
    local new_table = {config = {}, by_name = {}, c_requests = preset.c_requests, max_slot = preset.max_slot}
    local nt_config = new_table.config
    local nt_by_name = new_table.by_name
    for i, config in pairs(preset.config) do
        nt_config[i] = {name = config.name, min = config.min, max = config.max, slot = config.slot}
        nt_by_name[config.name] = nt_config[i]
    end
    return new_table
end

--- @param entity LuaEntity?
--- @return LuaLogisticPoint?
function M.get_requester_point(entity)
    if not (entity and entity.valid) then
        return
    end
    local index
    if entity.type == "character" then
        index = defines.logistic_member_index.character_requester
    elseif entity.type == "spider-vehicle" then
        index = defines.logistic_member_index.spidertron_requester
    else
        return
    end
    return entity.get_logistic_point(index)
end

--- @param entity LuaEntity?
--- @return LuaLogisticPoint?
function M.get_provider_point(entity)
    if not (entity and entity.valid) then
        return
    end
    local index
    if entity.type == "character" then
        index = defines.logistic_member_index.character_provider
    elseif entity.type == "spider-vehicle" then
        index = defines.logistic_member_index.spidertron_provider
    else
        return
    end
    return entity.get_logistic_point(index)
end

--- Find or create the dedicated AutoTrash manual section.
--- @param point LuaLogisticPoint
--- @param group_name string?
--- @return LuaLogisticSection?
function M.find_or_create_section(point, group_name)
    group_name = group_name or SECTION_GROUP
    for _, section in pairs(point.sections) do
        if section.valid and section.is_manual and section.group == group_name then
            return section
        end
    end
    return point.add_section(group_name)
end

--- @param section LuaLogisticSection
function M.clear_section(section)
    if not (section and section.valid and section.is_manual) then
        return
    end
    for i = section.filters_count, 1, -1 do
        section.clear_slot(i)
    end
end

--- Build a LogisticFilter for normal-quality items.
--- @param name string
--- @param min number
--- @param max number|nil
--- @return LogisticFilter
function M.make_filter(name, min, max)
    local filter = {
        value = {name = name, type = "item", quality = "normal", comparator = "="},
        min = min or 0,
    }
    if max ~= nil and max < max_request then
        filter.max = max
    end
    -- omit max → infinite trash limit
    return filter
end

--- Read one section into a sparse config table (does not clear existing).
--- @param section LuaLogisticSection
--- @param into table
local function merge_section_into(section, into)
    if not (section and section.valid) then
        return
    end
    local config = into.config
    local by_name = into.by_name
    for i = 1, section.filters_count do
        local filter = section.get_slot(i)
        local value = filter and filter.value
        local name = value and value.name
        if name and M.item_prototype(name) then
            local min = filter.min or 0
            local max = filter.max
            if max == nil then
                max = max_request
            end
            local existing = by_name[name]
            if existing then
                if min > existing.min then
                    if existing.min <= 0 and min > 0 then
                        into.c_requests = into.c_requests + 1
                    end
                    existing.min = min
                end
                if max < existing.max then
                    existing.max = max
                end
                if existing.max < existing.min then
                    existing.max = existing.min
                end
            else
                local slot = into.max_slot + 1
                local entry = {name = name, min = min, max = max, slot = slot}
                config[slot] = entry
                by_name[name] = entry
                into.max_slot = slot
                if min > 0 then
                    into.c_requests = into.c_requests + 1
                end
            end
        end
    end
end

--- Merge filters from all manual sections on a logistic point.
--- @param point LuaLogisticPoint?
--- @return table
function M.get_requests_from_point(point)
    local result = {config = {}, by_name = {}, max_slot = 0, c_requests = 0}
    if not (point and point.valid) then
        return result
    end
    for _, section in pairs(point.sections) do
        if section.valid and section.is_manual then
            merge_section_into(section, result)
        end
    end
    return result
end

--- Merge filters from character or spidertron logistics (all manual sections).
--- @param entity LuaEntity?
--- @return table
function M.get_requests_from_entity(entity)
    return M.get_requests_from_point(M.get_requester_point(entity))
end

--- Write config into the AutoTrash section only; set trash_not_requested on the point.
--- @param entity LuaEntity
--- @param config_data table  -- {config=, by_name=, max_slot=, c_requests=}
--- @param flags table?       -- pause_trash, pause_requests, trash_above_requested, trash_unrequested, temporary_requests
--- @return boolean? true when trash_unrequested was auto-disabled
function M.set_requests_on_entity(entity, config_data, flags)
    local point = M.get_requester_point(entity)
    if not point then
        return
    end
    flags = flags or {}
    local section = M.find_or_create_section(point)
    if not section then
        return
    end

    M.clear_section(section)

    local storage_cfg = config_data.config
    local trash_paused = flags.pause_trash
    local trash_above_requested = flags.trash_above_requested
    local requests_paused = flags.pause_requests
    local temporary_requests = flags.temporary_requests or {}
    local handled_temporary = {}

    local slot = 0
    for c = 1, config_data.max_slot or 0 do
        local req = storage_cfg[c]
        if req then
            local name = req.name
            if temporary_requests[name] then
                req = temporary_requests[name].temporary
                handled_temporary[name] = true
            end
            local request = req.min or 0
            local min = requests_paused and 0 or request
            local max
            if trash_paused then
                max = nil -- infinite / no trash
            else
                max = (trash_above_requested and request > 0) and request or req.max
            end
            slot = slot + 1
            section.set_slot(slot, M.make_filter(name, min, max))
        end
    end

    for name, request_data in pairs(temporary_requests) do
        if not handled_temporary[name] then
            local temp = request_data.temporary
            slot = slot + 1
            section.set_slot(slot, M.make_filter(name, temp.min or 0, temp.max))
        end
    end

    -- Native trash-unrequested flag (replaces filler max=0 slots)
    local want_unrequested = flags.trash_unrequested and not trash_paused
    point.trash_not_requested = want_unrequested and true or false

    return false
end

--- Apply player's config_new to their character's AutoTrash section.
--- @param player LuaPlayer
--- @param pdata table
--- @return boolean?
function M.set_requests(player, pdata)
    local character = player.character
    if not character then
        return
    end
    local flags = {
        pause_trash = pdata.flags.pause_trash,
        pause_requests = pdata.flags.pause_requests,
        trash_above_requested = pdata.flags.trash_above_requested,
        trash_unrequested = pdata.flags.trash_unrequested,
        temporary_requests = pdata.temporary_requests,
    }
    M.set_requests_on_entity(character, pdata.config_new, flags)

    -- Auto-disable trash_unrequested when inventory has nothing left to trash
    if pdata.flags.trash_unrequested and not pdata.flags.pause_trash and pdata.flags.autotoggle_unrequested then
        local inv = player.get_main_inventory()
        if inv then
            local contents = M.contents_to_name_map(inv.get_contents())
            for name in pairs(pdata.config_new.by_name) do
                contents[name] = nil
            end
            for name in pairs(contents) do
                local proto = M.item_prototype(name)
                if proto and constants.trash_blacklist[proto.type] then
                    contents[name] = nil
                end
            end
            if not next(contents) then
                pdata.flags.trash_unrequested = false
                local point = M.get_requester_point(character)
                if point then
                    point.trash_not_requested = false
                end
                return true
            end
        end
    end
end

function M.pause_requests(player, pdata)
    pdata.flags.pause_requests = true
    M.set_requests(player, pdata)
end

function M.unpause_requests(player, pdata)
    pdata.flags.pause_requests = false
    M.set_requests(player, pdata)
end

function M.pause_trash(player, pdata)
    pdata.flags.pause_trash = true
    M.set_requests(player, pdata)
end

function M.unpause_trash(player, pdata)
    pdata.flags.pause_trash = false
    M.set_requests(player, pdata)
end

function M.get_non_equipment_network(character)
    if not character then
        return
    end
    local logi_point = character.get_logistic_point(defines.logistic_member_index.character_provider)
    if not logi_point then
        logi_point = character.get_logistic_point(defines.logistic_member_index.character_requester)
    end
    return logi_point and logi_point.logistic_network
end

function M.get_network_entity(player)
    local network = M.get_non_equipment_network(player.character)
    if network and network.valid then
        local cell = network.find_cell_closest_to(player.position)
        return cell and cell.owner
    end
    return false
end

function M.in_network(player, pdata)
    if not pdata.flags.trash_network then
        return true
    end
    local currentNetwork = M.get_non_equipment_network(player.character)
    if not (currentNetwork and currentNetwork.valid) then
        return false
    end
    for id, network in pairs(pdata.networks) do
        if network and network.valid then
            if currentNetwork == network.logistic_network then
                return true
            end
        elseif network and not network.valid then
            player.print({"at-message.network-lost", id})
            pdata.networks[id] = nil
        end
    end
    return false
end

function M.format_number(n, append_suffix)
    local amount = tonumber(n)
    if not amount then
        return n
    end
    local suffix = ""
    if append_suffix then
        local suffix_list = {
            ["T"] = 1000000000000,
            ["B"] = 1000000000,
            ["M"] = 1000000,
            ["k"] = 1000
        }
        local floor = math.floor
        local abs = math.abs
        for letter, limit in pairs(suffix_list) do
            if abs(amount) >= limit then
                amount = floor(amount / (limit / 10)) / 10
                suffix = letter
                break
            end
        end
    end
    local formatted = amount
    local k
    local gsub = string.gsub
    while true do
        formatted, k = gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then
            break
        end
    end
    return formatted .. suffix
end

function M.remove_invalid_items()
    local function _remove(tbl)
        local max_slot = #tbl.config
        if type(tbl.max_slot) ~= "number" then
            for j = 1, #tbl.config do
                if tbl.config[j] and tbl.config[j].slot > max_slot then
                    max_slot = tbl.config[j].slot
                end
            end
        else
            max_slot = tbl.max_slot
        end
        tbl.max_slot = max_slot
        for i = tbl.max_slot, 1, -1 do
            local item_config = tbl.config[i]
            if item_config then
                if not M.item_prototype(item_config.name) then
                    if tbl.config[i].min > 0 then
                        tbl.c_requests = tbl.c_requests - 1
                    end
                    tbl.by_name[item_config.name] = nil
                    tbl.config[i] = nil
                    if tbl.max_slot == i then
                        tbl.max_slot = false
                    end
                else
                    tbl.max_slot = tbl.max_slot or i
                end
            end
        end
    end
    for _, pdata in pairs(storage._pdata or {}) do
        if pdata.config_new and pdata.config_tmp then
            _remove(pdata.config_new)
            _remove(pdata.config_tmp)
        end
        if pdata.presets then
            for _, stored in pairs(pdata.presets) do
                _remove(stored)
            end
        end
    end
end

--- Default request amount when adding a slot (stack size, or 1).
--- @param name string
--- @return number
function M.default_request_amount(name)
    local proto = M.item_prototype(name)
    if proto and proto.stack_size then
        return proto.stack_size
    end
    return 1
end

--- Enable personal logistic requests on character if researched.
--- @param character LuaEntity
function M.enable_personal_logistics(character)
    local point = M.get_requester_point(character)
    if point then
        point.enabled = true
    end
end

return M
