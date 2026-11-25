--!strict

------------------------------------------------------
---                    Configs
------------------------------------------------------

export type DashConfig = {
    SoundId: string,
    Delay: number,
    Bind: Enum.KeyCode,

    OnDash: (PlayerCharacter: Model) -> (), -- Model of Character, Called when dash is used
}

------------------------------------------------------
---                    Service
------------------------------------------------------

export type 

return {}