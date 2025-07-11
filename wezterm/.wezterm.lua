-- Pull in the wezterm API
local wezterm = require 'wezterm'
local act = wezterm.action

local merge = {}

function merge.all(base, overrides)
    local ret    = base or {}
    local second = overrides or {}
    for _, v in pairs(second) do table.insert(ret, v) end
    return ret
end

-- This will hold the configuration.
local config = wezterm.config_builder()
config.key_tables = {}

config.front_end = 'WebGpu'
config.webgpu_power_preference = 'HighPerformance'

config.window_decorations = 'TITLE | RESIZE | MACOS_USE_BACKGROUND_COLOR_AS_TITLEBAR_COLOR'
config.audible_bell = 'Disabled'

config.font = wezterm.font 'Monaco'
config.font_size = 16

config.color_scheme = 'Solarized (dark) (terminal.sexy)'
config.colors = {
  tab_bar = {
    active_tab = {
      -- I use a solarized dark theme; this gives a teal background to the
      -- active tab
      fg_color = '#073642',
      bg_color = '#2aa198',
    }
  }
}

config.scrollback_lines = 10000

-- config.enable_scroll_bar = true
-- config.colors = {
-- 		scrollbar_thumb = '#657B83',
-- }
-- config.window_padding = {
--   right = '5px',
-- }

config.inactive_pane_hsb = {
  saturation = 0.4,
  brightness = 0.5,
}

config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.tab_max_width = 32
config.switch_to_last_active_tab_when_closing_tab = true


-- Show which key table is active in the status area
-- wezterm.on('update-right-status', function(window, pane)
--   local status = ''

--   -- local key_table_name = window:active_key_table()
--   -- if key_table_name then
--   --   status = wezterm.format {
--   --     {Background = { Color = 'teal'}},
--   --     {Text = key_table_name},
--   --   }
--   -- end

--   local our_tab = pane:tab()
--   local is_zoomed = false
--   if our_tab ~= nil then
--     for _, pane_attributes in pairs(our_tab:panes_with_info()) do
--       is_zoomed = pane_attributes['is_zoomed'] or is_zoomed
--     end
--   end
--   if is_zoomed then
--     status = wezterm.format {
--       {Background = { Color = 'fuchsia'}},
--       {Text = ' 🔍 '},
--     }
--   end

--   window:set_right_status(status)
-- end)

wezterm.on('update-right-status', function(window, pane)
  -- Each element holds the text for a cell in a "powerline" style << fade
  local cells = {}

  local aws_profile = pane:get_user_vars().aws_profile
  if aws_profile ~= '' then
    table.insert(cells, wezterm.nerdfonts.dev_aws .. ' ' .. aws_profile)
  end

  local kube_context = pane:get_user_vars().kube_context
  if kube_context ~= '' then
    table.insert(cells, wezterm.nerdfonts.dev_kubernetes .. ' ' .. kube_context)
  end

  -- Figure out the cwd and host of the current pane.
  -- This will pick up the hostname for the remote host if your
  -- shell is using OSC 7 on the remote host.
  local cwd_uri = pane:get_current_working_dir()
  if cwd_uri then
    local cwd = ''
    local hostname = ''

    -- Running on a newer version of wezterm and we have
    -- a URL object here, making this simple!

    cwd = cwd_uri.file_path
    hostname = cwd_uri.host or wezterm.hostname()

    -- Remove the domain name portion of the hostname
    local dot = hostname:find '[.]'
    if dot then
      hostname = hostname:sub(1, dot - 1)
    end
    if hostname == '' then
      hostname = wezterm.hostname()
    end

    -- table.insert(cells, cwd)
    table.insert(cells, hostname)
  end

  local our_tab = pane:tab()
  local is_zoomed = false
  if our_tab ~= nil then
    for _, pane_attributes in pairs(our_tab:panes_with_info()) do
      is_zoomed = pane_attributes['is_zoomed'] or is_zoomed
    end
  end
  if is_zoomed then
    table.insert(cells, wezterm.nerdfonts.cod_zoom_in .. ' ')
  end

  -- The powerline < symbol
  local LEFT_ARROW = utf8.char(0xe0b3)
  -- The filled in variant of the < symbol
  local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

  -- Color palette for the backgrounds of each cell
  local colors = {
    '#3c1361',
    '#52307c',
    '#663a82',
    '#7c5295',
    '#b491c8',
  }

  -- Foreground color for the text across the fade
  local text_fg = '#c0c0c0'

  -- The elements to be formatted
  local elements = {}
  -- How many cells have been formatted
  local num_cells = 0

  -- Translate a cell into elements
  function push(text, is_last)
    local cell_no = num_cells + 1
    table.insert(elements, { Foreground = { Color = text_fg } })
    table.insert(elements, { Background = { Color = colors[cell_no] } })
    table.insert(elements, { Text = ' ' .. text .. ' ' })
    if not is_last then
      table.insert(elements, { Foreground = { Color = colors[cell_no + 1] } })
      table.insert(elements, { Text = SOLID_LEFT_ARROW })
    end
    num_cells = num_cells + 1
  end

  while #cells > 0 do
    local cell = table.remove(cells, 1)
    push(cell, #cells == 0)
  end

  window:set_right_status(wezterm.format(elements))
end)

config.leader = {
  key = 'a',
  mods = 'CTRL',
  timeout_milliseconds = 2000,
}

-- config.key_tables = {
--   -- Defines the keys that are active in our resize-pane mode.
--   -- Since we're likely to want to make multiple adjustments,
--   -- we made the activation one_shot=false. We therefore need
--   -- to define a key assignment for getting out of this mode.
--   -- 'resize_pane' here corresponds to the name="resize_pane" in
--   -- the key assignments above.
  

--   select_tab = {
--   	{ key = 'h', action = act.ActivateTabRelative(-1)},
--     { key = 'l', action = act.ActivateTabRelative(1)},
--     { key = 'Escape', action = 'PopKeyTable' },
--   }
-- }


-- CTRL + (h,j,k,l) to move between panes
config.keys = merge.all(config.keys, {
  {
      key = 'h',
      mods = 'CTRL',
      action = act.ActivatePaneDirection 'Left',
  },
  {
      key = 'j',
      mods = 'CTRL',
      action = act.ActivatePaneDirection 'Down',
  },
  {
      key = 'k',
      mods = 'CTRL',
      action = act.ActivatePaneDirection 'Up',
  },
  {
      key = 'l',
      mods = 'CTRL',
      action = act.ActivatePaneDirection 'Right',
  },
})

function activate_modal_keypane(window, pane, name)
  window:perform_action(wezterm.action.ActivateKeyTable {
    name = name,
    one_shot = false,
    until_unknown = true,
    prevent_fallback = true,
    timeout_milliseconds = 800,
  }, pane)
end

-- Tab movement mode
config.key_tables.select_tab = {
  { key = 'h', action = act.ActivateTabRelative(-1)},
  { key = 'l', action = act.ActivateTabRelative(1)},
  { key = 'Escape', action = 'PopKeyTable' },
}

config.keys = merge.all(config.keys, {
  {
    key = 'h',
    mods = 'LEADER',
    action = wezterm.action_callback(function(window, pane)
      window:perform_action(wezterm.action.ActivateTabRelative(-1), pane)
      activate_modal_keypane(window, pane, 'select_tab')
    end),
  },
  {
    key = 'l',
    mods = 'LEADER',
    action = wezterm.action_callback(function(window, pane)
      window:perform_action(wezterm.action.ActivateTabRelative(1), pane)
      activate_modal_keypane(window, pane, 'select_tab')
    end),
  },
})

-- Pane resize mode
config.key_tables.resize_pane = {
  { key = 'h', mods = 'CTRL', action = act.AdjustPaneSize { 'Left', 5 } },
  { key = 'l', mods = 'CTRL', action = act.AdjustPaneSize { 'Right', 5 } },
  { key = 'k', mods = 'CTRL', action = act.AdjustPaneSize { 'Up', 5 } },
  { key = 'j', mods = 'CTRL', action = act.AdjustPaneSize { 'Down', 5 } },
  { key = 'Escape', action = 'PopKeyTable' },
}

config.keys = merge.all(config.keys, {
  {
    key = 'h',
    mods = 'LEADER|CTRL',
    action = wezterm.action_callback(function(window, pane)
      window:perform_action(act.AdjustPaneSize { 'Left', 5 }, pane)
      activate_modal_keypane(window, pane, 'resize_pane')
    end),
  },
  {
    key = 'j',
    mods = 'LEADER|CTRL',
    action = wezterm.action_callback(function(window, pane)
      window:perform_action(act.AdjustPaneSize { 'Down', 5 }, pane)
      activate_modal_keypane(window, pane, 'resize_pane')
    end),
  },
  {
    key = 'k',
    mods = 'LEADER|CTRL',
    action = wezterm.action_callback(function(window, pane)
      window:perform_action(act.AdjustPaneSize { 'Up', 5 }, pane)
      activate_modal_keypane(window, pane, 'resize_pane')
    end),
  },
  {
    key = 'l',
    mods = 'LEADER|CTRL',
    action = wezterm.action_callback(function(window, pane)
      window:perform_action(act.AdjustPaneSize { 'Right', 5 }, pane)
      activate_modal_keypane(window, pane, 'resize_pane')
    end),
  },
})


-- Window renaming
config.keys = merge.all(config.keys, {
  {
    key = ',',
    mods = 'LEADER',
    action = wezterm.action.PromptInputLine {
      description = 'Enter new name for tab',
      action = wezterm.action_callback(
        function(window, pane, line)
          if line then
            window:active_tab():set_title(line)
          end
        end
      ),
    },
  },
})

config.keys = merge.all(config.keys, {
  -- Rebind OPT-Left, OPT-Right as ALT-b, ALT-f respectively to match Terminal.app behavior
  {
    key = 'LeftArrow',
    mods = 'OPT',
    action = act.SendKey {
      key = 'b',
      mods = 'ALT',
    },
  },
  {
    key = 'RightArrow',
    mods = 'OPT',
    action = act.SendKey { key = 'f', mods = 'ALT' },
  },
  -- Rebind OPT-Left, OPT-Right as ALT-b, ALT-f respectively to match Terminal.app behavior
  {
    key = 'LeftArrow',
    mods = 'CMD',
    action = act.SendKey {
      key = 'a',
      mods = 'CTRL',
    },
  },
  {
    key = 'RightArrow',
    mods = 'CMD',
    action = act.SendKey { key = 'e', mods = 'CTRL' },
  },
})

config.keys = merge.all(config.keys, {
  {
    key = 'u',
    mods = 'LEADER|CTRL',
    action = wezterm.action.ActivateCopyMode,
  },
  {
    key = 'z',
    mods = 'LEADER',
    action = wezterm.action.TogglePaneZoomState,
  },
  {
    key = 'c',
    mods = 'LEADER',
    action = wezterm.action.SpawnTab 'CurrentPaneDomain',
  },
  
  
  -- Close tab
  {
    key = 'x',
    mods = 'LEADER',
    action = wezterm.action.CloseCurrentTab{ confirm = true },
  },
  
  -- Vertical split
  {
    key = 'v',
    mods = 'LEADER',
    action = act.SplitPane {
      direction = 'Right',
      size = { Percent = 50 },
    },
  },
  
  -- Horizontal split
  {
    key = 's',
    mods = 'LEADER',
    action = act.SplitPane {
      direction = 'Down',
      size = { Percent = 50 },
    },
  },
})


-- and finally, return the configuration to wezterm
return config
