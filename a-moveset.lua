ACT_SHANTE_CANNONJUMP = allocate_mario_action(ACT_FLAG_AIR | ACT_FLAG_ATTACKING)

local function act_shante_cannonjump(m)
    local step = perform_air_step(m, 0)
    if step == AIR_STEP_LANDED then
        set_mario_action(m, ACT_JUMP_LAND, 0)
    end
end
hook_mario_action(ACT_SHANTE_CANNONJUMP, act_shante_cannonjump)