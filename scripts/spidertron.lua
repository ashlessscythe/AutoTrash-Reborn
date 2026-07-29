local gui = require("scripts.flib-gui")
local presets = require("scripts.presets")
local at_util = require("scripts.util")
local gui_util = require("scripts.gui-util")
local player_data = require("scripts.player-data")
local constants = require("constants")
local spider_gui = {}

local function set_requests(spider, requests, keep_presets)
    local flags = {}
    if keep_presets then
        local result = at_util.get_requests_from_entity(spider)
        local tmp = presets.merge(result, requests)
        at_util.set_requests_on_entity(spider, tmp, flags)
    else
        at_util.set_requests_on_entity(spider, requests, flags)
    end
end

local collapse_sprites = {
    [true] = {
        sprite = "utility/collapse",
        hovered_sprite = "utility/collapse_dark",
        clicked_sprite = "utility/collapse_dark"
    },
    [false] = {
        sprite = "utility/expand",
        hovered_sprite = "utility/expand",
        clicked_sprite = "utility/expand"
    }
}

spider_gui.handlers = {
    load = function(e, msg)
        set_requests(e.entity, e.pdata.presets[msg.name], e.shift)
    end,
    collapse = function(e)
        local frame = e.pdata.gui.spider.preset_frame
        local visible = not frame.visible
        frame.visible = visible
        for k, v in pairs(collapse_sprites[visible]) do
            e.element[k] = v
        end
        frame.parent.style.bottom_padding = visible and 8 or 0
    end,
    save = function(e)
        local textfield = e.pdata.gui.spider.preset_textfield
        local config = at_util.get_requests_from_entity(e.entity)
        if player_data.add_preset(e.player, e.pdata, textfield.text, config) then
            spider_gui.update(e.player, e.pdata)
            textfield.text = ""
        end
    end,
    textfield = function(e)
        e.element.select_all()
    end,
    trash_all = function(e)
        set_requests(e.entity, storage.trash_all_items, true)
        local point = at_util.get_requester_point(e.entity)
        if point then
            point.trash_not_requested = true
        end
    end,
}

function spider_gui.presets(pdata)
    local ret = {}
    local i = 1
    for name in pairs(pdata.presets) do
        ret[i] = {type = "flow", direction = "horizontal", name = name, children = {
            {
                type = "button", style = "at_preset_button", caption = name,
                actions = {on_click = {gui = "spider", action = "load", name = name}}
            },
            {type = "sprite-button", style = "at_delete_preset", sprite = "utility/trash",
                actions = {on_click = {gui = "presets", action = "delete", spider = true}},
            }
        }}
        i = i + 1
    end
    ret[#ret + 1] = {
        type = "button", style = "red_button", style_mods = {width = 182},
        caption = {"at-gui.spider-trash-all"},
        tooltip = {"at-gui.spider-trash-all-tt"},
        actions = {on_click = {gui = "spider", action = "trash_all"}}
    }
    return ret
end

function spider_gui.init(player, pdata)
    spider_gui.destroy(pdata)
    local refs = gui.build(player.gui.relative, {
        {type = "frame", direction = "vertical",
            style_mods = {maximal_height = constants.gui_dimensions.spidertron},
            ref = {"main"},
            anchor = {gui = defines.relative_gui_type.spider_vehicle_gui, position = defines.relative_gui_position.right},
            children = {
                {type = "flow", children = {
                    {type = "label", style = "frame_title", caption = "Logistics", elem_mods = {ignored_by_interaction = true}},
                    {type = "empty-widget", style = "flib_titlebar_drag_handle", elem_mods = {ignored_by_interaction = true}},
                    gui_util.frame_action_button("utility/collapse", "utility/collapse_dark",
                        {gui = "spider", action = "collapse"}
                    ),
                }},
                {type = "frame", style = "inside_shallow_frame", direction = "vertical", ref = {"preset_frame"}, children = {
                    {type = "frame", style = "subheader_frame", style_mods = {left_padding = 8}, children = {
                        {type = "textfield", style = "long_number_textfield", ref = {"preset_textfield"},
                            actions = {on_click = {gui = "spider", action = "textfield"}},
                        },
                        gui_util.pushers.horizontal,
                        {type = "sprite-button", sprite = "utility/check_mark", style = "item_and_count_select_confirm",
                            tooltip = {"at-gui.spider-save"},
                            actions = {on_click = {gui = "spider", action = "save"}}
                        }
                    }},
                    {type = "flow", direction = "vertical",
                        style_mods = {padding = 12, top_padding = 8, vertical_spacing = 12},
                        children = {
                        {type = "frame", style = "deep_frame_in_shallow_frame", children = {
                            {type = "scroll-pane", style = "at_right_scroll_pane", ref = {"presets"},
                                style_mods = {vertically_stretchable = false},
                                children = spider_gui.presets(pdata)
                            }
                        }},
                    }}
                }},
            }
        }
    })
    pdata.gui.spider = refs
end

function spider_gui.update(player, pdata, hide)
    if not (player.opened_gui_type == defines.gui_type.entity and player.opened and player.opened.type == "spider-vehicle") then
        return
    end
    local gui_spider = pdata.gui.spider and pdata.gui.spider.presets
    if not (gui_spider and gui_spider.valid) then
        spider_gui.init(player, pdata)
    end
    pdata.gui.spider.presets.clear()
    gui.build(pdata.gui.spider.presets, spider_gui.presets(pdata))
    pdata.gui.spider.main.visible = not hide
end

function spider_gui.destroy(pdata)
    if not (pdata.gui.spider and pdata.gui.spider.main and pdata.gui.spider.main.valid) then
        return
    end
    pdata.gui.spider.main.destroy()
    pdata.gui.spider = nil
end

return spider_gui
