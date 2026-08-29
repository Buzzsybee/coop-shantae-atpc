if not charSelectExists then return end

gShantaeStates = {}
function reset_shantae_states(index)
    if index == nil then index = 0 end
    gShantaeStates[index] = {
        index = network_global_index_from_local(0),

        cannonJumpNumber = 3,

        gfxAngleX = 0,
        gfxAngleY = 0,
        gfxAngleZ = 0,
    }
end

for i = 0, (MAX_PLAYERS - 1) do
    reset_shantae_states(i)
end
--charSelect.character_hook_moveset(CT_SHANTE, HOOK_ON_LEVEL_INIT, reset_shantae_states)

ACT_SHANTE_CANNONJUMP = allocate_mario_action(ACT_FLAG_AIR | ACT_FLAG_ATTACKING)
ACT_SHANTE_JUMP = allocate_mario_action(ACT_FLAG_AIR | ACT_FLAG_CONTROL_JUMP_HEIGHT)
ACT_SHANTE_HAT_GLIDE = allocate_mario_action(ACT_FLAG_AIR| ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)

local function act_shante_cannonjump(m)
    local e = gShantaeStates[m.playerIndex]

    if m.actionTimer == 0 then
        m.faceAngle.y = m.intendedYaw
        set_mario_anim_with_accel(m, CHAR_ANIM_CRAWLING, 1.0)
        m.vel.y = 50
        
        m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE
        play_sound(SOUND_GENERAL2_BOBOMB_EXPLOSION, m.marioObj.header.gfx.cameraToObject)

        e.cannonJumpNumber = e.cannonJumpNumber - 1
    end

    local step = perform_air_step(m, 0)
    update_air_without_turn(m)

    if step == AIR_STEP_LANDED then
        set_mario_action(m, ACT_JUMP_LAND, 0)
    end

    m.actionTimer = m.actionTimer + 1
end
hook_mario_action(ACT_SHANTE_CANNONJUMP, {every_frame = act_shante_cannonjump})

local function act_shante_jump(m)
    local e = gShantaeStates[m.playerIndex]

    if m.actionTimer == 0 then
        set_mario_anim_with_accel(m, CHAR_ANIM_SINGLE_JUMP, 0x10000)
        play_character_sound(m, CHAR_SOUND_YAH_WAH_HOO)
        m.vel.y = 50
    end

    local step = perform_air_step(m, 0)
    update_air_without_turn(m)

    if step == AIR_STEP_LANDED then
        set_mario_action(m, ACT_JUMP_LAND, 0)
    end

    if m.actionTimer > 0 and (m.controller.buttonPressed & X_BUTTON) ~= 0 then
        if e.cannonJumpNumber > 0 then 
            set_mario_action(m, ACT_SHANTE_CANNONJUMP, 0)
        end
    end
    
    m.actionTimer = m.actionTimer + 1
end
hook_mario_action(ACT_SHANTE_JUMP, {every_frame = act_shante_jump})

local function act_shante_hat_glide(m)
    local e = gShantaeStates[m.playerIndex]

    if m.actionTimer == 0 then
        set_mario_anim_with_accel(m, CHAR_ANIM_HANG_ON_OWL, 0x1000)
        m.vel.y = 10
    end

    local step = perform_air_step(m, 0)
    update_air_with_turn(m)

    if step == AIR_STEP_LANDED then
        set_mario_action(m, ACT_JUMP_LAND, 0)
    end

    m.actionTimer = m.actionTimer + 1
end
hook_mario_action(ACT_SHANTE_HAT_GLIDE, {every_frame = act_shante_hat_glide})

local function before_shante_action(m, a)
    if a == ACT_JUMP or a == ACT_DOUBLE_JUMP or a == ACT_TRIPLE_JUMP or a == ACT_LONG_JUMP then
        return ACT_SHANTE_JUMP
    end

    if a == ACT_DIVE then
        return ACT_JUMP_KICK
    end

end
charSelect.character_hook_moveset(CT_SHANTE, HOOK_BEFORE_SET_MARIO_ACTION, before_shante_action)

---comment
---@param m MarioState
local function shante_update(m)
    local e = gShantaeStates[m.playerIndex]

    m.peakHeight = m.pos.y

    if m.action & ACT_FLAG_AIR == 0 then e.cannonJumpNumber = 3 end

    djui_chat_message_create(tostring(e.cannonJumpNumber))
    djui_chat_message_create(tostring(m.actionTimer))
end
charSelect.character_hook_moveset(CT_SHANTE, HOOK_MARIO_UPDATE, shante_update)
