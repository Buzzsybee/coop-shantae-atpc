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
charSelect.character_hook_moveset(CT_SHANTE, HOOK_ON_LEVEL_INIT, reset_shantae_states)

ACT_SHANTE_CANNONJUMP = allocate_mario_action(ACT_FLAG_AIR | ACT_FLAG_ATTACKING)
ACT_SHANTE_JUMP = allocate_mario_action(ACT_FLAG_AIR | ACT_FLAG_CONTROL_JUMP_HEIGHT)
ACT_SHANTE_HAT_GLIDE = allocate_mario_action(ACT_FLAG_AIR| ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
ACT_SHANTE_SCIMITAR_DOWN = allocate_mario_action(ACT_FLAG_AIR | ACT_FLAG_ATTACKING)

local function act_shante_cannonjump(m)
    local e = gShantaeStates[m.playerIndex]

    if m.actionTimer == 0 then
        m.faceAngle.y = m.intendedYaw
        set_mario_anim_with_accel(m, CHAR_ANIM_CRAWLING, 1.0)
        m.vel.y = 20 * e.cannonJumpNumber
        
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

    return false
end
hook_mario_action(ACT_SHANTE_CANNONJUMP, {every_frame = act_shante_cannonjump})

---comment
---@param m MarioState
---@return boolean
local function act_shante_jump(m)
    local e = gShantaeStates[m.playerIndex]

    if m.actionTimer == 0 then
        m.faceAngle.y = m.intendedYaw
        set_mario_anim_with_accel(m, CHAR_ANIM_SINGLE_JUMP, 0x10000)
        play_character_sound(m, CHAR_SOUND_YAH_WAH_HOO)
        m.vel.y = 50
    end

    local step = perform_air_step(m, 0)
    update_air_without_turn(m)

    if step == AIR_STEP_LANDED then
        set_mario_action(m, ACT_JUMP_LAND, 0)
    end

    
    m.actionTimer = m.actionTimer + 1

    return false
end
hook_mario_action(ACT_SHANTE_JUMP, {every_frame = act_shante_jump})

local function act_shante_hat_glide(m)
    local e = gShantaeStates[m.playerIndex]

    if m.actionTimer == 0 then
        set_mario_anim_with_accel(m, CHAR_ANIM_HANG_ON_OWL, 0x10000)
        play_character_sound(m, CHAR_SOUND_WHOA)
        m.vel.y = 20
    end

    local step = perform_air_step(m, 0)
    update_air_with_turn(m)

    if m.vel.y < 1 then
        m.vel.y = m.vel.y + 3.8
    end

    if step == AIR_STEP_LANDED then
        set_mario_action(m, ACT_JUMP_LAND, 0)
    end

    if (m.controller.buttonDown & X_BUTTON) == 0 then
        set_mario_action(m, ACT_FREEFALL, 0)
    end

    m.actionTimer = m.actionTimer + 1
    
    return false
end
hook_mario_action(ACT_SHANTE_HAT_GLIDE, {every_frame = act_shante_hat_glide})

local function  act_shante_scimitar_down(m)
    local e = gShantaeStates[m.playerIndex]

    if m.actionTimer == 0 then
        set_mario_anim_with_accel(m, CHAR_ANIM_TWIRL, 0x10000)
        play_character_sound(m, CHAR_SOUND_WHOA)
        m.vel.y = 50
    end

    local step = perform_air_step(m, 0)
    update_air_without_turn(m)

    if step == AIR_STEP_LANDED then
        m.actionState = 1
    end

    if m.actionState == 1 then
        set_camera_shake_from_point(SHAKE_POS_MEDIUM, m.pos.x, m.pos.y, m.pos.z)
        play_mario_landing_sound_once(m, SOUND_ACTION_METAL_HEAVY_LANDING)

        if m.actionTimer > 4 then
            set_mario_action(m, ACT_IDLE, 0)
        end
    end

    m.actionTimer = m.actionTimer + 1

    m.vel.y = m.vel.y - 1
    
    return false
end
hook_mario_action(ACT_SHANTE_SCIMITAR_DOWN, {every_frame = act_shante_scimitar_down}, INT_GROUND_POUND)

local function before_shante_action(m, a)
    if a == ACT_JUMP or a == ACT_DOUBLE_JUMP or a == ACT_TRIPLE_JUMP or a == ACT_LONG_JUMP or a == ACT_SIDE_FLIP or a == ACT_BACKFLIP then
        return ACT_SHANTE_JUMP
    end

    if a == ACT_DIVE then
        return ACT_JUMP_KICK
    end

    if a == ACT_GROUND_POUND then
        return ACT_SHANTE_SCIMITAR_DOWN
    end

end
charSelect.character_hook_moveset(CT_SHANTE, HOOK_BEFORE_SET_MARIO_ACTION, before_shante_action)

---comment
---@param m MarioState
local function shante_update(m)
    local e = gShantaeStates[m.playerIndex]

    m.peakHeight = m.pos.y

    if m.action & ACT_FLAG_AIR == 0 then e.cannonJumpNumber = 3 end

    if m.action == ACT_SHANTE_JUMP then m.actionTimer = m.actionTimer + 1 

        if m.actionTimer > 15 then
            if (m.controller.buttonPressed & X_BUTTON) ~= 0 and m.action ~= ACT_SHANTE_HAT_GLIDE then
                set_mario_action(m, ACT_SHANTE_HAT_GLIDE, 0)
            end
        end
    end

    if m.action == ACT_SHANTE_CANNONJUMP or m.action == ACT_SHANTE_JUMP or m.action == ACT_SHANTE_HAT_GLIDE then
        if m.actionTimer > 5 then 
            if (m.controller.buttonPressed & A_BUTTON) ~= 0 then
                if e.cannonJumpNumber > 0 then 
                    set_mario_action(m, ACT_SHANTE_CANNONJUMP, 0)
                end
            end

            if (m.controller.buttonPressed & X_BUTTON) ~= 0 and m.action ~= ACT_SHANTE_HAT_GLIDE then
                set_mario_action(m, ACT_SHANTE_HAT_GLIDE, 0)
            end

            if (m.controller.buttonPressed & Z_TRIG) ~= 0 and m.action ~= ACT_SHANTE_SCIMITAR_DOWN then
                set_mario_action(m, ACT_SHANTE_SCIMITAR_DOWN, 0)
            end
        end
    end
end
charSelect.character_hook_moveset(CT_SHANTE, HOOK_MARIO_UPDATE, shante_update)

---comment
---@param m MarioState
---@param o Object
---@param type InteractionType
local function shante_allow_interact(m, o, type)
    if get_id_from_behavior(o.behavior) == id_bhvPoleGrabbing or get_id_from_behavior(o.behavior) == id_bhvGiantPole or get_id_from_behavior(o.behavior) == id_bhvTree then
        return false
    end
end
charSelect.character_hook_moveset(CT_SHANTE, HOOK_ALLOW_INTERACT, shante_allow_interact)