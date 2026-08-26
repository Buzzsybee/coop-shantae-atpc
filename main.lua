-- name: Shantae and Bowser's Curse
-- description: Shantae and the pirates curse moveset cuz why not :3

local TEXT_MOD_NAME = "Shantae"

if not _G.charSelectExists then
    djui_popup_create("\\#ffffdc\\\n"..TEXT_MOD_NAME.."\nRequires the Character Select Mod\nto use as a Library!\n\nPlease turn on the Character Select Mod\nand Restart the Room!", 6)
    return 0
end

local E_MODEL_CHAR = smlua_model_util_get_id("CHAR_geo")
local ICON_CHAR= get_texture_info("CHAR_icon")
local CHAR_GRAFFITI = get_texture_info("CHAR_graffiti")

local PALETTE_CHAR = {
    [PANTS]  = "FFFFFF",
    [SHIRT]  = "FFFFFF",
    [GLOVES] = "FFFFFF",
    [SHOES]  = "FFFFFF",
    [HAIR]   = "FFFFFF",
    [SKIN]   = "FFFFFF",
    [CAP]    = "FFFFFF",
	[EMBLEM] = "FFFFFF"
}

anims = {
    [charSelect.CS_ANIM_MENU] = 'CHAR_MENU_ANIM'
}

_G.charSelect.character_add_palette_preset(E_MODEL_CHAR, PALETTE_CHAR)


CHAR_CHAR = _G.charSelect.character_add(
    "Shantae", -- Character Name
    "Shantae and the pirates curse moveset cuz why not :3", -- Description
    "Honi", -- Credits
    "FFFFFF",           -- Menu Color
    E_MODEL_CHAR,       -- Character Model
    CT_MARIO,           -- Override Character
    ICON_CHAR, -- Life Icon
    1.0
)

if anims then charSelect.character_add_animations(E_MODEL_CHAR, anims) end
--charSelect.character_add_graffiti(CHAR_CHAR, CHAR_GRAFFITI)