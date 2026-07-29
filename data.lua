local data_util = require("__flib__.data-util")
require("prototypes.styles")

local tint = {r = 255, g = 240, b = 0}

data:extend{
    data_util.build_sprite("autotrash_selection", nil, data_util.planner_base_image, 64, {tint = tint})
}

-- Copy flags from a vanilla selection tool when available (avoid 2.1-only flags).
local vanilla_tool = data.raw["selection-tool"]["selection-tool"]
local tool_flags = vanilla_tool and vanilla_tool.flags or {"not-stackable", "only-in-cursor", "spawnable"}

data:extend{
    {
        type = "selection-tool",
        name = "autotrash-network-selection",
        icons = {{icon = data_util.planner_base_image, icon_size = 64, tint = tint}},
        stack_size = 1,
        flags = tool_flags,
        hidden = true,
        draw_label_for_cursor_render = true,
        select = {
            border_color = {r = 0, g = 1, b = 0},
            cursor_box_type = "copy",
            -- any-tile kept for 2.0/2.1 dual-target (2.1 no longer implies it from blueprint)
            mode = {"blueprint", "any-entity", "any-tile"},
            entity_type_filters = {"roboport"},
        },
        alt_select = {
            border_color = {r = 0, g = 0, b = 1},
            cursor_box_type = "copy",
            mode = {"blueprint", "any-entity", "any-tile"},
            entity_type_filters = {"roboport"},
        },
    }
}

data:extend{
    {
        type = "custom-input",
        name = "autotrash-toggle-gui",
        key_sequence = "CONTROL + L",
        order = "a"
    },
    {
        type = "custom-input",
        name = "autotrash_trash_cursor",
        key_sequence = "SHIFT + T",
        order = "b"
    },
    {
        type = "custom-input",
        name = "autotrash_pause",
        key_sequence = "SHIFT + P",
        order = "c"
    },
    {
        type = "custom-input",
        name = "autotrash_pause_requests",
        key_sequence = "SHIFT + O",
        order = "d"
    },
    {
        type = "custom-input",
        name = "autotrash-toggle-unrequested",
        key_sequence = "",
        order = "e"
    },
}

data:extend{
    {
        type = "shortcut",
        name = "autotrash-toggle-gui",
        action = "lua",
        icon = "__AutoTrash__/graphics/shortcut.png",
        icon_size = 64,
        small_icon = "__AutoTrash__/graphics/shortcut.png",
        small_icon_size = 64,
        disabled_icon = "__AutoTrash__/graphics/shortcut-disabled.png",
        disabled_small_icon = "__AutoTrash__/graphics/shortcut-disabled.png",
        toggleable = true,
        associated_control_input = "autotrash-toggle-gui"
    }
}
