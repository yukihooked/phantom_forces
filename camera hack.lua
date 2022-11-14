getgenv().camera = {
    no_sway = true,
    no_shake = true,
}

local game_client = {}
do
    for i,v in next, getgc(true) do
        if typeof(v) == "table" then
            if rawget(v, 'setSway') then
                game_client.camera = v
            end
        end
    end
end

local old_set_sway = game_client.camera.setSway
local old_shake = game_client.camera.shake
game_client.camera.setSway = function(self, amount)
    local sway = getgenv().camera.no_sway and 0 or amount

    return old_set_sway(self, sway)
end

game_client.camera.shake = function(self, amount)
    local shake = getgenv().camera.no_shake and Vector3.zero or amount

    return old_shake(self, shake)
end
