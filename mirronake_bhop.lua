CreateConVar("bhop", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Toggle bunnyhop functionality (0 = off, 1 = on)")

local b_and = bit.band
local b_or = bit.bor
local b_not = bit.bnot

local function getLocalizedMessage(key)
    local lang = GetConVar("gmod_language"):GetString()
    local messages = {
        en = {
            enabled = "Bunnyhop enabled.",
            disabled = "Bunnyhop disabled.",
            info = "You can use the command 'bhop 0/1' to toggle bunnyhop functionality.",
        },
        ru = {
            enabled = "Баннихоп включён.",
            disabled = "Баннихоп отключён.",
            info = "Вы можете использовать команду 'bhop 0/1', чтобы переключить баннихоп.",
 	},            
        tr = {
            enabled = "Bunnyhop etkinleştirildi.",
            disabled = "Bunnyhop devre dışı.",
            info = "'bhop 0/1' komutunu kullanarak bunnyhop'u açıp kapatabilirsiniz.",
        }
    }
    return messages[lang] and messages[lang][key] or messages["en"][key]
end

hook.Add("SetupMove", "CustomBhopHook", function(player, moveData)
    if GetConVar("bhop"):GetInt() == 0 then return end
    if player:Alive() and player:GetMoveType() == MOVETYPE_WALK and not player:InVehicle() and player:WaterLevel() <= 1 then
        if b_and(moveData:GetButtons(), IN_JUMP) == IN_JUMP then
            if player:IsOnGround() then
                moveData:SetButtons(b_or(moveData:GetButtons(), IN_JUMP))
            else
                moveData:SetButtons(b_and(moveData:GetButtons(), b_not(IN_JUMP)))
            end
        end
    end
end)

concommand.Add("bhop", function(player, cmd, args)
    local bhopState = GetConVar("bhop"):GetInt()
    if bhopState == 1 then
        RunConsoleCommand("bhop", "0")
        if IsValid(player) and player:IsPlayer() then
            player:ChatPrint(getLocalizedMessage("disabled"))
        else
            print(getLocalizedMessage("disabled"))
        end
    else
        RunConsoleCommand("bhop", "1")
        if IsValid(player) and player:IsPlayer() then
            player:ChatPrint(getLocalizedMessage("enabled"))
        else
            print(getLocalizedMessage("enabled"))
        end
    end
end)

hook.Add("PlayerInitialSpawn", "BhopInfoMessage", function(player)
    player:ChatPrint(getLocalizedMessage("info"))
end)
