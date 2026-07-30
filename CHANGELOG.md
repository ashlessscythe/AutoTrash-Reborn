# Changelog

All notable changes to Auto Trash are documented here.

## [6.0.1] — 2026-07-29

### Added

- Dock Auto Trash beside the character inventory (gui.relative), with collapse/expand.
- New setting "GUI location": attached right (default), attached left, or floating.
- Dock/undock title-bar controls; shortcut opens the character GUI when docked.

## [6.0.0] — 2026-07-29

### Added

- Factorio 2.0 and 2.1 compatibility (dual-target codebase).
- Companion to vanilla logistic sections: Apply writes only an "AutoTrash" section; other groups are preserved.
- Import from logistics merges all manual sections into the GUI.
- Trash unrequested uses the native logistic-point flag.

### Changed

- Requires Factorio 2.0+ and flib >= 0.15.0.
- MIT license added.

### Fixed

- Fixed controller-type check operator precedence.
- Fixed autotoggle-unrequested option writing the wrong GUI property.

## [5.3.16] — 2024-10-09

### Changed

- Internal fork bump; superseded by 6.0.0 for Factorio 2.x.

## [5.3.15] — 2024-10-09

### Fixed

- Fixed crash when ipmorting a preset

## [5.3.14] — 2024-10-05

### Fixed

- Fixed crash when saving a preset on a spidertron while in editor mode
- Possibly fixed crash when importing a preset via blueprint
- Possibly fixed crash when items stored in presets get removed from the game

### Changed

- "Set trash to requests" quick action now works when 0 items are requested

## [5.3.13] — 2021-02-03

### Fixed

- Fixed crash when mod settings are changed by script

## [5.3.12] — 2021-01-15

### Fixed

- Fixed crash when changing request/trash amounts with an empty slot selected

## [5.3.11] — 2021-01-08

### Changed

- Added a quick action to import the config from the logistics tab

## [5.3.10] — 2020-12-21

### Added

- Added a quick action to import the config from the inventory
- Shift + Ctrl clicking presets will append presets without filling gaps

## [5.3.9] — 2020-12-15

### Fixed

- Fixed crash when starting a game from custom scenario that used an older version of the mod

## [5.3.8] — 2020-12-09

### - Added two new commands

- Removed blue as a status indicator: Yellow button background means items are being delivered, red means no items are available/being delivered
- Minor changes to scrollbars to prevent the width of the gui changing

### Fixed

- Fixed crash when removing a preset via Spidertron and resaving it with the same name

## [5.3.7] — 2020-12-06

### Fixed

- Fixed crash with invalid status display

## [5.3.6] — 2020-12-02

### Fixed

- Fixed crash when importing presets via blueprint string

## [5.3.5] — 2020-11-30

### - Added a "Trash unrequested" button to the spidertron gui

- If requested amount and maximum amount are the same, only one number is shown in the gui
- Increased performance when dealing with a lot of configured items
- The gui for the spidertron is only shown for spidertrons with a logistics tab
- Added a delete button to the spidertron gui. Note that this will also delete the preset in the characters gui.

### Fixed

- Fixed crash when trying to save a preset via the spidertron and the character gui was invalid
- Fixed sprites for the pin and reset button

## [5.3.4] — 2020-11-29

### Changed

- Fixed error when trying to export a preset with no items set

## [5.3.3] — 2020-11-28

### Changed

- Changed the shortcut icon to red and yellow arrows
- Added a hotkey to toggle trashing unrequested items
- Added a checkbox to turn off trashing unrequested items once the inventory is cleaned up

### Fixed

- Fixed error when saving a preset via the spidertron gui

## [5.3.1] — 2020-11-24

### Changed

- Removed the (+/-) buttons, a new row will be added if something is put in the last row

### Fixed

- Fixed error when adding AutoTrash to an existing save

## [5.3.0] — 2020-11-23

### Changed

- Updated for Factorio 1.1

## [5.2.17] — 2020-12-21

### Added

- Added a quick action to import the config from the inventory
- Shift + Ctrl clicking presets will append presets without filling gaps

## [5.2.16] — 2020-11-21

### Changed

- Added shortcut to toggle the AutoTrash gui
- Added mod setting to hide the button in the top left
- Removed commands /at_show and /at_hide

## [5.2.15] — 2020-11-20

### Fixed

- Fixed gui buttons becoming unresponsive.

## [5.2.14] — 2020-11-18

### Changed

- Sliders change the amount by one stack at a time.
- Added support for multiple main networks.

## [5.2.13] — 2020-11-08

### Fixed

- Fixed error when shift-clicking items to move them.

## [5.2.12] — 2020-11-07

### Changed

- Applying changes or pressing enter after changing the trash amount will display a message if the the amount got adjusted to the request amount.

### Fixed

- Fixed error when changing the trash amount via keyboard.

## [5.2.11] — 2020-11-06

### Fixed

- Fixed "Trash above requested" not working if no trash amount was set.
- Fixed temporary trash not working if the item was already set.
- Fixed errors when using the commands: /at_show and /at_hide.

## [5.2.10] — 2020-11-01

### Fixed

- Fixed requests not being set properly.
- Fixed button and textfields showing nothing if request is 0 and trash is unlimited.

## [5.2.9] — 2020-10-31

### Changed

- Added a pin button to the gui, to keep it open when pressing E/Escape. By default the gui will stay open.
- Added a tooltip to the top button, showing the control to toggle the status display.
- Researching the personal logistics opens the status display.

### Fixed

- Fixed UPS drop when deconstructing roboports with construction robots.

## [5.2.8] — 2020-10-30

### Fixed

- Fixed crash when requesting 0 of an item and infinite trash amount while "Trash above requested" is active.

## [5.2.7] — 2020-10-30

### Changed

- Made displayed columns and rows adjustable again. Columns are restricted from 5 to 40 in increments of 5.

## [5.2.6] — 2020-10-27

### Fixed

- Fixed error after players temporary trash slots have been emptied.

## [5.2.5] — 2020-10-27

### Fixed

- Fixed Unknown sprite error when ModuleInserter mod is missing.

## [5.2.4] — 2020-10-27

### Changed

- Updated the gui to look more like the vanilla gui.
- Removed mod settings to adjust the number of displayed rows/columns.
- Added flib as a dependency.

## [5.2.2] — 2020-09-20

### Changed

- Changed AutoTrash to be enabled as soon as the vanilla logistics tab is available.

## [5.2.1] — 2020-09-20

### Added

- Added buttons to export/import all presets at once.

### Fixed

- Fixed importing would mess up the item order in the gui.

## [5.2.0] — 2020-07-28

### Changed

- Changed the GUI to be draggable.
- Changed default number of columns to 10, to match the characters logistics GUI.
- Added setting to set the trash amount to the requested amount for new items.
- Removed the "Pause requests on death" setting, since that is now a vanilla feature.
- Reenable logistic requests after respawning when a death preset is selected.

### Fixed

- Fixed crash with the Rocket Rush scenario.
- Fixed error when exporting an empty configuration.

## [5.1.4] — 2020-05-26

### Fixed

- Fixed startup errors with Factorio 0.18.27.

## [5.1.3] — 2020-05-04

### Fixed

- Fixed blueprints, books and planners being autotrashed.

## [5.1.2] — 2020-04-15

### Fixed

- Maybe fixed a crash when updating from a save with now invalid items.

## [5.1.1] — 2020-03-20

### Fixed

- Fixed trashing unrequested items would set all requests to zero.

## [5.1.0] — 2020-03-19

### Changed

- Updated to work with the new character GUI added in 0.18.13.
- Removed obsolete setting to lock infinite slots behind a research.
- Updated gui to the dark logistic slots.

### Fixed

- Fixed out of range error when AutoTrash was added to an existing save.

## [5.0.2] — 2020-03-05

### Fixed

- Fixed unknown sprite error.

## [5.0.1] — 2020-01-31

### Fixed

- Fixed error when trying to import an invalid blueprint/string.

## [5.0.0] — 2020-01-26

### Changed

- Updated for Factorio 0.18.

## [4.2.0] — 2020-01-26

### Changed

- Added mod setting to lock unlimited request slots behind the final character logistic slots research.

## [4.1.11] — 2019-10-06

### Fixed

- Fixed setting a main network wouldn't work at all when the player had ropobort equipment in the armor.

## [4.1.10] — 2019-10-06

### Fixed

- Fixed auto pausing when the main network became invalid.

## [4.1.9] — 2019-09-20

### Changed

- Item status display now shows the number of missing items to fulfill the request.

### Fixed

- Fixed request slot count not resetting properly when clearing requests.

## [4.1.8] — 2019-07-18

### Fixed

- Fixed error when loading a save that requires a migration to be run.

## [4.1.7] — 2019-07-08

### Changed

- Requests with 0 amount are no longer set in the vanilla gui.

### Fixed

- Fixed crash when importing a blueprint with requests.

## [4.1.6] — 2019-07-03

### Changed

- Adding AutoTrash to an existing save only opens the gui when requests/trash is set.

### Fixed

- Fixed items in armor, gun and ammo inventory not being counted for the request status display.
- Fixed possible crash when loading a scenario in the map editor.

## [4.1.5] — 2019-06-23

### Changed

- Preset textfield only gets cleared when selecting multiple presets.
- Select all text when clicking the preset textfield.
- Adding AutoTrash to an existing save will import existing request/trash filters.

## [4.1.4] — 2019-06-18

### Fixed

- Fixed crash when entering a Factorissimo2 building.
- Fixed error when creating a new scenario via map editor.

## [4.1.3] — 2019-06-16

### Changed

- Added command: /at_import : Imports the vanilla request and trash settings into the mod gui.

### Fixed

- Fixed error when updating players without a character.

## [4.1.2] — 2019-06-16

### Added

- Combined logistic requests and trash configuration into one window.
- Click and drop: Hold shift when clicking a configured item, then shift click another button to swap the buttons.
- It is now possible to load multiple presets at once. If more than one preset contains an item, the maximum request/trash amount is chosen.
- Right click the main button to quickly load and apply a preset.
- Shift + Right click the main button to display the status of your requests.

### - Different colors for indicating the status of an order

- Added buttons to automatically load stored presets when respawning.
- Added buttons to import/export the configuration. Holding shift when clicking the export button creates a blueprint with constant combinators containing the configuration.

## [4.0.6] — 2019-05-23

### Fixed

- Fixed trashing not working at all.

## [4.0.5] — 2019-05-01

### Fixed

- updated for Factorio 0.17.35.

## [4.0.4] — 2019-03-31

### Fixed

- Fixed ruleset buttons not working in some circumstances.

## [4.0.3] — 2019-03-30

### Fixed

- Fixed items with equipment grid loosing all equipment when being trashed.

## [4.0.2] — 2019-03-29

### Fixed

- Fixed error when saving a logistic request with amount of 0.

## [4.0.1] — 2019-03-10

### Changed

- Updated for Factorio 0.17.
- Replaced buttons in the UI with filter-like buttons (like in the vanilla logistics and autotrash windows).
- To set a filter use left click, to reset use right click.

## [3.0.3] — 2018-04-21

### Fixed

- Fixed crash when mining a ropobort.

## [3.0.2] — 2018-03-26

### Fixed

- Fixed checkboxes not saving changes.

## [3.0.1] — 2018-01-06

### Fixed

- Fixed gui error.

## [3.0.0] — 2017-12-14

### Changed

- Updated for Factorio 0.16.
