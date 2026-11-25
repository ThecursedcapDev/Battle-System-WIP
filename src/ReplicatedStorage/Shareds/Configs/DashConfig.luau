--!strict

const ReplicatedStorage = game:GetService("ReplicatedStorage")
const DashTypes = require(ReplicatedStorage.Shareds.Types.DashTypes)

local DashConfig: DashTypes.DashConfig = {
    SoundId = "rbxasset://sounds/dash.mp3",
    Delay = 0.5,
    Bind = Enum.KeyCode.Q,
    
    OnDash = function(PlayerCharacter)
        
    end
}

return DashConfig