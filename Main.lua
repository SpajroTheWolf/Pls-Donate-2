--Wait until game loads
repeat
    wait()
until game:IsLoaded()

--Stops script if on a different game
if game.PlaceId ~= 8737602449 and game.PlaceId ~= 8943844393 then
    return
end

if getgenv().loaded then
    return
else
    getgenv().loaded = true
end
--Anti-AFK
local Players = game:GetService("Players")
local connections = getconnections or get_signal_cons
if connections then
	for i,v in pairs(connections(Players.LocalPlayer.Idled)) do
		if v["Disable"] then
			v["Disable"](v)
		elseif v["Disconnect"] then
			v["Disconnect"](v)
		end
	end
else
    Players.LocalPlayer.Idled:Connect(function()
        local VirtualUser = game:GetService("VirtualUser")
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

--Variables
local unclaimed = {}
local counter = 0
local donation, boothText, spamming, hopTimer, vcEnabled, thanksDropdown, begDropdown, connectStat, hookName
local signPass = false 
local notUpdating = true
local exd = false
local errCount = 0
local queueonteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
local httprequest = (syn and syn.request) or http and http.request or http_request or (fluxus and fluxus.request) or request
local httpservice = game:GetService('HttpService')
local Flux = loadstring(game:HttpGet"https://raw.githubusercontent.com/SpajroTheWolf/Pls-Donate-2/main/ui.lua")()
local win = Flux:Window("PLS DONATE", "by Spajro", Color3.fromRGB(0, 128, 0), Enum.KeyCode.RightShift)
local function claimGifts()
    pcall(function()
        Players.LocalPlayer:WaitForChild("PlayerGui")
        local guipath = Players.LocalPlayer.PlayerGui:WaitForChild("ScreenGui")
        firesignal(guipath.GiftAlert.Buttons.Close["Activated"])
        local count = require(game.ReplicatedStorage.Remotes).Event("UnclaimedDonationCount"):InvokeServer()
        while count == nil do
            task.wait(5)
            count = require(game.ReplicatedStorage.Remotes).Event("UnclaimedDonationCount"):InvokeServer()
        end
        if count then
            local ud = {}
            for i = 1, count do
                table.insert(ud, i)
            end
            if #ud > 0 then
                firesignal(guipath.Gift.Buttons.Inbox["Activated"])
                Players.LocalPlayer.ClaimDonation:InvokeServer(ud)
                task.wait(.5)
                firesignal(guipath.GiftInbox.Buttons.Close["Activated"])
                task.wait(.5)
                firesignal(guipath.Gift.Buttons.Close["Activated"])
            end
        end
    end)
end
task.spawn(claimGifts)

local settingFile = "plsdonategui/settings.txt"
getgenv().settings = {}
--Load Settings

if not isfolder("plsdonategui") then
    makefolder("plsdonategui")
end
if not isfolder("plsdonategui/userProfiles") then
    makefolder("plsdonategui/userProfiles")
end

if isfile("plsdonategui/userProfiles/toggled.txt") then
    if readfile("plsdonategui/userProfiles/toggled.txt") == "true" then
        settingFile = tostring("plsdonategui/userProfiles/".. Players.LocalPlayer.UserId.. ".txt")
    end
else
    writefile("plsdonategui/userProfiles/toggled.txt", "false")
end

if isfile(settingFile) then
    local sl, er = pcall(function()
        getgenv().settings = httpservice:JSONDecode(readfile(settingFile))
    end)
    if er ~= nil then
        task.spawn(function()
            Flux:Notification("Settings reset due to error", er, "Okay")
        end)
        delfile(settingFile)
    end
end

local sNames = {"textUpdateToggle", "textUpdateDelay", "serverHopToggle", "serverHopDelay", "colorBox", "goalBox", "webhookToggle", "webhookBox", "danceChoice", "thanksMessage", "signToggle", "customBoothText", "signUpdateToggle", "signText", "signColorBox", "autoThanks", "autoBeg", "begMessage", "begDelay", "fpsLimit", "render", "thanksDelay", "vcServer", "randomToggle", "webhookshop", "anonymous", "fontFace", "fontSize", "staffHop", "censorHop", "reex", "boothPosition", "altServers"}
local sValues = {true, 30, true, 0, "0.196078, 0.803922, 0.196078", 5, false, "", "Disabled", {"Thank you", "Thanks!", "ty :)", "tysm!"}, false, "GOAL: $G", false, "your text here", "1, 1, 1", true, false, {"Please donate", "I'm so close to my goal!", "donate to me", "please"}, 300, 60, false, 3, false, true, false, false, "GothamBlack", 90, true, false, true, 3, false}
if #getgenv().settings ~= sNames then
    for i, v in ipairs(sNames) do
        if getgenv().settings[v] == nil then
            getgenv().settings[v] = sValues[i]
        end
    end
    writefile(settingFile, httpservice:JSONEncode(getgenv().settings))
end

--Save Settings
local settingsLock = true
local function saveSettings()
    if settingsLock == false then
        print('Settings saved.')
        writefile(settingFile, httpservice:JSONEncode(getgenv().settings))
    end
end

local function webhook(msg)
    httprequest({
        Url = getgenv().settings.webhookBox,
        Body = httpservice:JSONEncode({["content"] = msg}),
        Method = "POST",
        Headers = {["content-type"] = "application/json"}
    })
end

local function serverHop()
    if getgenv().settings.webhookshop then
        webhook(tostring("["..Players.LocalPlayer.DisplayName.."] Attempting to server hop"))
    end
    local gameId = "8737602449"
    if vcEnabled and getgenv().settings.altServers then
        if math.floor(math.random(0, 1)) == 1 then
            gameId = "8943844393"
        end
    end
    if vcEnabled and getgenv().settings.vcServer and not getgenv().settings.altServers then
        gameId = "8943844393"
    end
    local servers = {}
    local req = httprequest({Url = "https://games.roblox.com/v1/games/".. gameId.."/servers/Public?sortOrder=Desc&limit=100"})
   	local body = httpservice:JSONDecode(req.Body)
    if body and body.data then
        for i, v in next, body.data do
   	        if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.playing > 19 then
  		        table.insert(servers, 1, v.id)
 	        end 
        end
    end
    if #servers > 0 then
		game:GetService("TeleportService"):TeleportToPlaceInstance(gameId, servers[math.random(1, #servers)], Players.LocalPlayer)
    end
    game:GetService("TeleportService").TeleportInitFailed:Connect(function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(gameId, servers[math.random(1, #servers)], Players.LocalPlayer)
    end)
end

local function playerJoin(player)
    if not getgenv().settings.staffHop then return end
    if player:GetRankInGroup(12121240) >= 254 then
        serverHop()
    end
end

local function waitServerHop()
    task.wait(getgenv().settings.serverHopDelay * 60)
    serverHop()
end

local function hopSet()
    if hopTimer then
        task.cancel(hopTimer)
    end
    if getgenv().settings.serverHopDelay > 0 then
        hopTimer = task.spawn(waitServerHop)
    end
end

--Booth update function
local function update(ok, force)
    local text, colll
    local current = Players.LocalPlayer.leaderstats.Raised.Value
    local goal = current + tonumber(getgenv().settings.goalBox)

    --Roblox Censorship :)
    if goal == 420 or goal == 425 then
        goal += 10
    end
    if current == 420 or current == 425 then
        current -= 10  
    end
    
    if goal > 999 and goal < 10000 then
        if tonumber(getgenv().settings.goalBox) < 10 then
            goal = string.format("%.2fk", (current + 10) / 10 ^ 3)
        else
            goal = string.format("%.2fk", (goal) / 10 ^ 3)
        end
    elseif goal > 9999 then
        if tonumber(getgenv().settings.goalBox) < 10 then
            goal = string.format("%.1fk", (current + 10) / 10 ^ 3)
        else
            goal = string.format("%.1fk", (goal) / 10 ^ 3)
        end
    end
    if current > 999 and current < 10000 then
        current = string.format("%.2fk", current / 10 ^ 3)
    elseif current > 9999 then
        current = string.format("%.1fk", current / 10 ^ 3)
    end
    if getgenv().settings.textUpdateToggle and getgenv().settings.customBoothText and ok ~= "sign" then
        text = string.gsub(getgenv().settings.customBoothText, "$C", current)
        text = string.gsub (text, "$G", goal)
        if getgenv().settings.randomToggle then
            colll = Color3.fromRGB(math.random(1,255), math.random(1,255), math.random(1,255)):ToHex()
        else
            local boothSplitColor = string.split(getgenv().settings.colorBox, ', ')
            colll = Color3.new(tonumber(boothSplitColor[1]), tonumber(boothSplitColor[2]), tonumber(boothSplitColor[3])):ToHex()
        end
        if getgenv().settings.disableFont then
            boothText = text
        else
            boothText = tostring('<font face="'.. getgenv().settings.fontFace.. '" size="'.. getgenv().settings.fontSize ..'" color="#'.. colll ..'">'.. text.. '</font>')
        end
        --Updates the booth text
        local myBooth = Players.LocalPlayer.PlayerGui.MapUIContainer.MapUI.BoothUI:FindFirstChild(tostring("BoothUI".. unclaimed[1]))
        if myBooth.Sign.TextLabel.Text ~= boothText or force then
            if string.find(myBooth.Sign.TextLabel.Text, "###") then
                require(game.ReplicatedStorage.Remotes).Event("SetBoothText"):FireServer("your text here", "booth")
                task.wait(3)
            end
            require(game.ReplicatedStorage.Remotes).Event("SetBoothText"):FireServer(boothText, "booth")
            task.wait(3)
            if string.find(myBooth.Sign.TextLabel.Text, "###") and getgenv().settings.censorHop and not getgenv().censored then
                queueonteleport("getgenv().censored = true")
                serverHop()
            end
        end
    end
    if getgenv().settings.signToggle and getgenv().settings.signUpdateToggle and getgenv().settings.signText and signPass and ok ~= "booth" then
        local currentSign = game.Players.LocalPlayer.Character.DonateSign.TextSign.SurfaceGui.TextLabel.Text
        text = string.gsub(getgenv().settings.signText, "$C", current)
        text = string.gsub (text, "$G", goal)
        local signSplitColor = string.split(getgenv().settings.signColorBox, ', ')
        local signColorNew = Color3.new(tonumber(signSplitColor[1]), tonumber(signSplitColor[2]), tonumber(signSplitColor[3])):ToHex()
        signText = tostring('<font color="#'.. signColorNew.. '">'.. text.. '</font>')

        if currentSign ~= signText then
            if string.find(currentSign, "###") then
                require(game.ReplicatedStorage.Remotes).Event("SetBoothText"):FireServer("your text here", "sign")
                task.wait(3)
            end
            require(game.ReplicatedStorage.Remotes).Event("SetBoothText"):FireServer(signText, "sign")
            task.wait(3)
            if string.find(currentSign, "###") and getgenv().settings.censorHop and not getgenv().censored then
                queueonteleport("getgenv().censored = true")
                serverHop()
            end
        end
    end
    getgenv().censored = false
end

--Function to fix slider
local sliderInProgress = false;
local function slider(value, whichSlider)
    if sliderInProgress then
        return
    end
    sliderInProgress = true
    task.wait(1)
    if getgenv().settings[whichSlider] == value then
        saveSettings()
        sliderInProgress = false;
        if whichSlider == "serverHopDelay" then
            hopSet()
        elseif whichSlider == "colorBox" then
            update("booth")
        elseif whichSlider == "signColorBox" then
            update("sign")
        end
    else
        sliderInProgress = false;
        return slider(getgenv().settings[whichSlider], whichSlider)
    end
end

local function begging()
    while getgenv().settings.autoBeg do
        if #getgenv().settings.begMessage == 0 then return end
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(getgenv().settings.begMessage[math.random(#getgenv().settings.begMessage)],"All")
        task.wait(getgenv().settings.begDelay)
    end
end

local function webhookName()
    connectStat.Title.Text = "Disconnected"
    local yeppers = httprequest({
        Url = getgenv().settings.webhookBox,
        Method = "GET",
    })
    hookName = string.match(yeppers.Body, '"name": "(.*)", "avatar"')
    connectStat.Title.Text = "Connected to "..hookName
end

local boothTab = win:Tab("Booth", "http://www.roblox.com/asset/?id=10213989952")

local textUpdateToggle = boothTab:Toggle("Text Update", "Automatically updates text after donation", getgenv().settings.textUpdateToggle, function(t)
    if settingsLock then return end
    getgenv().settings.textUpdateToggle = t
    saveSettings()
    if t then
        update("booth")
    end
end)

local textUpdateDelay = boothTab:Slider("Update Delay (S)", "How long to wait after donation to update", 0, 120,getgenv().settings.textUpdateDelay, function(t)
    if settingsLock then return end
    getgenv().settings.textUpdateDelay = t
    slider(getgenv().settings.textUpdateDelay, "textUpdateDelay")
end)

boothTab:Dropdown("Standing Position", {"Front", "Left", "Right", "Behind"}, false, function(t)
    if settingsLock then return end
    if t == "Front" then
        getgenv().settings.boothPosition = 3
    elseif t == "Left" then
        getgenv().settings.boothPosition = -6
    elseif t == "Right" then
        getgenv().settings.boothPosition = 6
    else
        getgenv().settings.boothPosition = -5.5
    end
    saveSettings()
end)

boothTab:Button("Edit Text", "Customize what your booth says\n$C = Current, $G = Goal, 185 Character Limit", function()
    if not game:GetService("CoreGui").FluxLib:FindFirstChild("EditBooth") then
        local charLimit = 185
        if getgenv().settings.disableFont then
            charLimit = 300
        end
        local clonedGui = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.EditBooth:Clone()
        clonedGui.Parent = game:GetService("CoreGui").FluxLib
        clonedGui.Buttons.Settings:Destroy()
        clonedGui.Buttons.Refresh:Destroy()
        clonedGui.Buttons.Statistics:Destroy()
        clonedGui.TextBox.Text = getgenv().settings.customBoothText
        clonedGui.Visible = true
        clonedGui.Apply.Activated:Connect(function()
            if #clonedGui.TextBox.Text > charLimit then
                task.spawn(function()
                    game:GetService("SoundService").Fail:Play()
                    local failText = game:GetService("ReplicatedStorage").Templates.PopupTemplate:Clone();
                    failText.Text = "exceeded character limit ("..tostring(charLimit)..")";
                    failText.TextColor3 = Color3.fromRGB(255, 100, 100);
                    failText.Parent = clonedGui.Parent;
                    game:GetService("TweenService"):Create(failText, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {
                        Position = UDim2.new(0, 0, 0.8, 0)
                    }):Play();
                    wait(0.75);
                    game:GetService("TweenService"):Create(failText, TweenInfo.new(3, Enum.EasingStyle.Quint), {
                        TextTransparency = 1
                    }):Play();
                    wait(2);
                    failText:Destroy();
                end);
            else
                getgenv().settings.customBoothText = clonedGui.TextBox.Text
                clonedGui:Destroy()
                saveSettings()
                update("booth")
            end
        end)
        clonedGui.Buttons.Close.Activated:Connect(function()
            task.spawn(function()
                game:GetService("SoundService").Fail:Play()
                local failText = game:GetService("ReplicatedStorage").Templates.PopupTemplate:Clone();
                failText.Text = "canceled!";
                failText.TextColor3 = Color3.fromRGB(255, 100, 100);
                failText.Parent = clonedGui.Parent;
                game:GetService("TweenService"):Create(failText, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {
                    Position = UDim2.new(0, 0, 0.8, 0)
                }):Play();
                wait(0.75);
                game:GetService("TweenService"):Create(failText, TweenInfo.new(3, Enum.EasingStyle.Quint), {
                    TextTransparency = 1
                }):Play();
                wait(2);
                failText:Destroy();
            end);
            clonedGui:Destroy()
        end)
    end
end)

local colorsplit = string.split(getgenv().settings.colorBox, ', ')
local colorBox = boothTab:Colorpicker("Text Color", Color3.new(tonumber(colorsplit[1]), tonumber(colorsplit[2]), tonumber(colorsplit[3])), function(t)
    if settingsLock then return end
    t = tostring(t)
    getgenv().settings.colorBox = t
    slider(getgenv().settings.colorBox, "colorBox")
end)

local randomToggle = boothTab:Toggle("Random Color", "Uses a random color instead", getgenv().settings.randomToggle, function(t)
    if settingsLock then return end
    getgenv().settings.randomToggle = t
    saveSettings()
    update()
end)

local fonts = {
    "AmaticSC",
    "Antique",
    "Arcade",
    "Arial",
    "ArialBold",
    "Bangers",
    "Bodoni",
    "Cartoon",
    "Code",
    "Creepster",
    "DenkOne",
    "Fantasy",
    "Fondamento",
    "FredokaOne",
    "Garamond",
    "Gotham",
    "GothamBlack",
    "GothamBold",
    "GothamMedium",
    "GrenzeGotisch",
    "Highway",
    "IndieFlower",
    "JosefinSans",
    "Jura",
    "Kalam",
    "Legacy",
    "LuckiestGuy",
    "Merriweather",
    "Michroma",
    "Nunito",
    "Oswald",
    "PatrickHand",
    "PermanentMarker",
    "Roboto",
    "RobotoCondensed",
    "RobotoMono",
    "Sarpanch",
    "SciFi",
    "SourceSans",
    "SourceSansBold",
    "SourceSansItalic",
    "SourceSansLight",
    "SourceSansSemibold",
    "SpecialElite",
    "TitilliumWeb",
    "Ubuntu"
}

boothTab:Dropdown("Font Face", fonts, true, function(t)
    if settingsLock then return end
    getgenv().settings.fontFace = t
    saveSettings()
    update("booth")
end)

boothTab:Textbox("Font Size", "font size", false, getgenv().settings.fontSize, function(t)
    if settingsLock then return end
    if tonumber(t) then
        getgenv().settings.fontSize = tonumber(t)
        saveSettings()
        update("booth")
    end
end)

boothTab:Toggle("Disable Font", "Disables all font options (Color, Size, Face)\nBut grants you 115 extra characters", getgenv().settings.disableFont, function(t)
    if settingsLock then return end
    getgenv().settings.disableFont = t 
    saveSettings()
    update("booth", true)
end)

local goalBox = boothTab:Textbox("Goal Increase", "Amount to increase your goal by", false, getgenv().settings.goalBox, function(t)
    if settingsLock then return end
    if tonumber(t) then
        getgenv().settings.goalBox = tonumber(t)
        saveSettings()
        update("booth")
    end
end)




pcall(function()
    if game:GetService("MarketplaceService"):UserOwnsGamePassAsync(Players.LocalPlayer.UserId, 28460459) then
        signPass = true
    end
end)
if signPass then
    local signTab = win:Tab("Sign", "http://www.roblox.com/asset/?id=10213989952")

    local signToggle = signTab:Toggle("Equip Sign", "Equips your sign", getgenv().settings.signToggle, function(t)
        if settingsLock then return end
        getgenv().settings.signToggle = t
        saveSettings()
        if t then
            Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):EquipTool(Players.LocalPlayer.Backpack:FindFirstChild("DonateSign"))
        else
            Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):UnequipTools(Players.LocalPlayer.Backpack:FindFirstChild("DonateSign"))
        end
    end)

    local signUpdateToggle = signTab:Toggle("Text Update", "Automatically updates text after donation", getgenv().settings.signUpdateToggle, function(t)
        if settingsLock then return end
        getgenv().settings.signUpdateToggle = t
        saveSettings()
        if t then
            update("sign")
        end
    end)

    local colorsplitAgain = string.split(getgenv().settings.signColorBox, ', ')
    local signColorBox = signTab:Colorpicker("Text Color", Color3.new(tonumber(colorsplitAgain[1]), tonumber(colorsplitAgain[2]), tonumber(colorsplitAgain[3])), function(t)
        if settingsLock then return end
        t = tostring(t)
        getgenv().settings.signColorBox = t
        slider(getgenv().settings.signColorBox, "signColorBox")
    end)

    signTab:Button("Sign Text", "Customize what your sign says\n$C = Current, $G = Goal", function()
        if not game:GetService("CoreGui").FluxLib:FindFirstChild("EditBooth") then
            local clonedGui = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.EditBooth:Clone()
            clonedGui.Parent = game:GetService("CoreGui").FluxLib
            clonedGui.Buttons.Settings:Destroy()
            clonedGui.Buttons.Refresh:Destroy()
            clonedGui.Buttons.Statistics:Destroy()
            clonedGui.TextBox.Text = getgenv().settings.signText
            clonedGui.Visible = true
            clonedGui.Apply.Activated:Connect(function()
                if #clonedGui.TextBox.Text > 185 then
                    task.spawn(function()
                        game:GetService("SoundService").Fail:Play()
                        local failText = game:GetService("ReplicatedStorage").Templates.PopupTemplate:Clone();
                        failText.Text = "exceeded character limit (185)";
                        failText.TextColor3 = Color3.fromRGB(255, 100, 100);
                        failText.Parent = clonedGui.Parent;
                        game:GetService("TweenService"):Create(failText, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {
                            Position = UDim2.new(0, 0, 0.8, 0)
                        }):Play();
                        wait(0.75);
                        game:GetService("TweenService"):Create(failText, TweenInfo.new(3, Enum.EasingStyle.Quint), {
                            TextTransparency = 1
                        }):Play();
                        wait(2);
                        failText:Destroy();
                    end);
                else
                    getgenv().settings.signText = clonedGui.TextBox.Text
                    clonedGui:Destroy()
                    saveSettings()
                    update("sign")
                end
            end)
            clonedGui.Buttons.Close.Activated:Connect(function()
                task.spawn(function()
                    game:GetService("SoundService").Fail:Play()
                    local failText = game:GetService("ReplicatedStorage").Templates.PopupTemplate:Clone();
                    failText.Text = "canceled!";
                    failText.TextColor3 = Color3.fromRGB(255, 100, 100);
                    failText.Parent = clonedGui.Parent;
                    game:GetService("TweenService"):Create(failText, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {
                        Position = UDim2.new(0, 0, 0.8, 0)
                    }):Play();
                    wait(0.75);
                    game:GetService("TweenService"):Create(failText, TweenInfo.new(3, Enum.EasingStyle.Quint), {
                        TextTransparency = 1
                    }):Play();
                    wait(2);
                    failText:Destroy();
                end);
                clonedGui:Destroy()
            end)
        end
    end)
end

local chatTab = win:Tab("Chat", "http://www.roblox.com/asset/?id=10213989952")

local autoThanks = chatTab:Toggle("Auto Thanks", "Automatically sends a thank you message after donation", getgenv().settings.autoThanks, function(t)
    if settingsLock then return end
    getgenv().settings.autoThanks = t
    saveSettings()
end)

local thanksDelay = chatTab:Slider("Thanks Delay (S)", "How long to wait after donation to send message", 0, 120,getgenv().settings.thanksDelay,function(t)
    if settingsLock then return end
    getgenv().settings.thanksDelay = t
    slider(getgenv().settings.thanksDelay, "thanksDelay")
end)

chatTab:Button("Add thank you message", "Add thank you messages", function()
    if not game:GetService("CoreGui").FluxLib:FindFirstChild("ChangeMusic") then
        local clonedGui = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.ChangeMusic:Clone()
        clonedGui.Parent = game:GetService("CoreGui").FluxLib
        clonedGui.TextBox.Text = ""
        clonedGui.TextBox.PlaceholderText = "Message"
        clonedGui.Apply.Text = "ADD MESSAGE"
        clonedGui.Visible = true
        clonedGui.Apply.Activated:Connect(function()
            thanksDropdown:Add(clonedGui.TextBox.Text)
            table.insert(getgenv().settings.thanksMessage, clonedGui.TextBox.Text)
            clonedGui:Destroy()
            saveSettings()
        end)
        clonedGui.Buttons.Close.Activated:Connect(function()
            clonedGui:Destroy()
        end)
    end
end)

local tymsg = {"CLEAR ALL"}
for i, v in pairs(getgenv().settings.thanksMessage) do table.insert(tymsg, v) end
thanksDropdown = chatTab:Dropdown("Remove thank you message", tymsg, false, function(t)
    if t == "CLEAR ALL" then
        thanksDropdown:Clear()
        thanksDropdown:Add("CLEAR ALL")
        getgenv().settings.thanksMessage = {}
    else
        thanksDropdown:Clear(t)
        for i, v in pairs(getgenv().settings.thanksMessage) do 
            if v == t then
                table.remove(getgenv().settings.thanksMessage, i)
            end
        end
    end
    saveSettings()
end)

chatTab:Line()

local autoBeg = chatTab:Toggle("Auto Beg", "Automatically begs in chat", getgenv().settings.autoBeg, function(t)
    if settingsLock then return end
    getgenv().settings.autoBeg = t
    saveSettings()
    if t then
        spamming = task.spawn(begging)
    else
        task.cancel(spamming)
    end
end)

local begDelay = chatTab:Slider("Beg Delay (S)", "How long to wait in between begging messages", 0, 300,getgenv().settings.begDelay,function(t)
    if settingsLock then return end
    getgenv().settings.begDelay = t
    slider(getgenv().settings.begDelay, "begDelay")

end)

chatTab:Button("Add begging message", "Adds a begging message", function()
    if not game:GetService("CoreGui").FluxLib:FindFirstChild("ChangeMusic") then
        local clonedGui = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.ChangeMusic:Clone()
        clonedGui.Parent = game:GetService("CoreGui").FluxLib
        clonedGui.TextBox.Text = ""
        clonedGui.TextBox.PlaceholderText = "Message"
        clonedGui.Apply.Text = "ADD MESSAGE"
        clonedGui.Visible = true
        clonedGui.Apply.Activated:Connect(function()
            begDropdown:Add(clonedGui.TextBox.Text)
            table.insert(getgenv().settings.begMessage, clonedGui.TextBox.Text)
            clonedGui:Destroy()
            saveSettings()
        end)
        clonedGui.Buttons.Close.Activated:Connect(function()
            clonedGui:Destroy()
        end)
    end
end)




local bmsg = {"CLEAR ALL"}
for i, v in pairs(getgenv().settings.begMessage) do table.insert(bmsg, v) end
begDropdown = chatTab:Dropdown("Remove begging message", bmsg, false, function(t)
    if t == "CLEAR ALL" then
        begDropdown:Clear()
        begDropdown:Add("CLEAR ALL")
        getgenv().settings.begMessage = {}
    else
        begDropdown:Clear(t)
        for i, v in pairs(getgenv().settings.begMessage) do 
            if v == t then
                table.remove(getgenv().settings.begMessage, i)
            end
        end
    end
    saveSettings()
end)

chatTab:Line()




local webhookTab = win:Tab("Webhook", "http://www.roblox.com/asset/?id=10213989952")

local webhookBox = webhookTab:Textbox("Discord Webhook", 'Put your Discord Webhook URL here for notifications', true, "", function(t)
    if settingsLock then return end
    if string.find(t, "discord.com/api/webhooks/") then
        getgenv().settings.webhookBox = t;
        webhookName()
        saveSettings()
    end
end)

connectStat = webhookTab:Label("Disconnected", 15)

webhookTab:Line()

local webhookToggle = webhookTab:Toggle("Donation", "Donation Notifications", getgenv().settings.webhookToggle, function(t)
    if settingsLock then return end
    getgenv().settings.webhookToggle = t
    saveSettings()
end)

local webhookshop = webhookTab:Toggle("Server Hop", "Server Hop Notifications", getgenv().settings.webhookshop, function(t)
    if settingsLock then return end
    getgenv().settings.webhookshop = t
    saveSettings()
end)

webhookTab:Button("Test", "Sends a test message to your webhook to verify it is working", function()
    if getgenv().settings.webhookBox then
    webhook("**Spajro's Donation Bot v2.0.3**")
    webhook("``New Options:``")
    webhook("``- Better Look Of Weebhook :Robux:``")
    end
end)




pcall(function()
    if game:GetService("VoiceChatService"):IsVoiceEnabledForUserIdAsync(Players.LocalPlayer.UserId) or getgenv().vcbp then
        vcEnabled = true
    end
end)
local serverHopTab = win:Tab("Server", "http://www.roblox.com/asset/?id=10213989952")

local serverHopDelay = serverHopTab:Slider("Server Hop Delay (M)", "How long to wait for donations before server change\n0 = Disabled", 0, 120,getgenv().settings.serverHopDelay,function(t)
    if settingsLock then return end
    getgenv().settings.serverHopDelay = t
    slider(getgenv().settings.serverHopDelay, "serverHopDelay")
end)

if vcEnabled then
    serverHopTab:Toggle("VC Servers", "Toggles voice chat servers", getgenv().settings.vcServer, function(t)
        if settingsLock then return end
        getgenv().settings.vcServer = t
        saveSettings()
    end)
    serverHopTab:Toggle("Alternate", "Alternate between voice chat and normal servers", getgenv().settings.altServers, function(t)
        if settingsLock then return end
        getgenv().settings.altServers = t
        saveSettings()
    end)
end

serverHopTab:Toggle("Staff Join", "Server hops if a staff member joins the game", getgenv().settings.staffHop, function(t)
    if settingsLock then return end
    getgenv().settings.staffHop = t
    saveSettings()
end)

serverHopTab:Toggle("Booth Censor", "Server hops if your booth or sign gets censored", getgenv().settings.censorHop, function(t)
    if settingsLock then return end
    getgenv().settings.censorHop = t
    saveSettings()
end)

serverHopTab:Toggle("Re-Execute", "Executes the script after server hop\nTurn this off if you use autoexec", getgenv().settings.reex, function(t)
    if t and not exd then
        queueonteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/SpajroTheWolf/Pls-Donate-2/main/Main.lua'))()")
        exd = true
    end
    if settingsLock then return end
    getgenv().settings.reex = t
    saveSettings()
end)


serverHopTab:Button("Server Hop", "Changes servers", function()
    if settingsLock then return end
    Flux:closeUi()
    serverHop()
end)


serverHopTab:Line()
serverHopTab:Label("Server hopping has a chance to crash your game\nRecommended to use with Roblox Account Manager auto relaunch", 13)


local otherTab = win:Tab("Other", "http://www.roblox.com/asset/?id=10213989952")

otherTab:Button("Discord Server", "Copies Discord server link", function()
    local cboard = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)
    if cboard then
        cboard("https://discord.gg/tDNvX4JU6t")
    end
    Flux:Notification("Copied to clipboard", "https://discord.gg/tDNvX4JU6t", "Okay")
end)

otherTab:Line()

local danceDropdown = otherTab:Dropdown("Dance", {"Disabled","1","2", "3"}, false, function(t)
    if settingsLock then return end
    getgenv().settings.danceChoice = t
    saveSettings()
    if t == "Disabled" then
        Players:Chat("/e wave")
    elseif t == "1" then
        Players:Chat("/e dance")
    else
        Players:Chat("/e dance".. t)
    end
end)

local render = otherTab:Toggle("Disable Rendering", "Disables 3D rendering", getgenv().settings.render, function(t)
    getgenv().settings.render = t
    saveSettings()
    if t then
        local blackscreen = Instance.new("Frame")
        blackscreen.ZIndex = 0
        blackscreen.Parent = game:GetService("CoreGui").FluxLib
        blackscreen.BackgroundColor3 = Color3.fromRGB(0,0,0)
        blackscreen.Position = UDim2.new(-1, 0, -1, 0)
        blackscreen.Size = UDim2.new(2, 0, 2, 0)
        game:GetService("RunService"):Set3dRenderingEnabled(false)
        
    else
        if game:GetService("CoreGui").FluxLib:FindFirstChild("Frame") then
            game:GetService("CoreGui").FluxLib:FindFirstChild("Frame"):Destroy()
        end
        game:GetService("RunService"):Set3dRenderingEnabled(true)
    end
end)

if setfpscap and type(setfpscap) == "function" then
    local fpsLimit = otherTab:Slider("FPS Limit", "Limits FPS to decrease resource usage", 1, 60,getgenv().settings.fpsLimit,function(t)
    if settingsLock then return end
        getgenv().settings.fpsLimit = t
        setfpscap(t)
        slider(getgenv().settings.fpsLimit, "fpsLimit")
    end)
    setfpscap(getgenv().settings.fpsLimit)
end

otherTab:Toggle("Anonymous Mode", "Hides your donated amount on the leaderboard", getgenv().settings.anonymous, function(t)
    local anToggled = require(game.ReplicatedStorage.Settings):get().Anonymous
    if t and not anToggled then
        require(game.ReplicatedStorage.Remotes).Event("SetDonatedVisibility"):FireServer(false)
    end
    if settingsLock then return end
    getgenv().settings.anonymous = t
    saveSettings()
end)

otherTab:Line()

local userProfiles = otherTab:Toggle("Account Profiles", "Use different settings on every account", settingFile ~= "plsdonategui/settings.txt", function(t)
    if settingsLock then return end
    writefile("plsdonategui/userProfiles/toggled.txt", tostring(t))
    task.wait(1)
    Flux:closeUi()
    serverHop()
end)

otherTab:Button("Reset Settings", "Resets ALL settings to default", function()
    delfile(settingFile)
    Flux:closeUi()
    serverHop()
end)


settingsLock = false
if string.find(getgenv().settings.webhookBox, "discord.com/api/webhooks/") then
    webhookName()
end

Players.PlayerAdded:Connect(playerJoin)

task.spawn(function()
    for i,v in pairs(Players:GetPlayers()) do
        playerJoin(v)
    end
end)

local function findUnclaimed()
    for i, v in pairs(Players.LocalPlayer.PlayerGui.MapUIContainer.MapUI.BoothUI:GetChildren()) do
        if (v.Details.Owner.Text == "unclaimed") then
            table.insert(unclaimed, tonumber(string.match(tostring(v), "%d+")))
        end
    end
end
if not pcall(findUnclaimed) then
    serverHop()
end
local claimCount = #unclaimed
--Claim booth function
local function boothclaim()
    require(game.ReplicatedStorage.Remotes).Event("ClaimBooth"):InvokeServer(unclaimed[1])
    if not string.find(Players.LocalPlayer.PlayerGui.MapUIContainer.MapUI.BoothUI:FindFirstChild(tostring("BoothUI".. unclaimed[1])).Details.Owner.Text, Players.LocalPlayer.DisplayName) then
        task.wait(1)
        if not string.find(Players.LocalPlayer.PlayerGui.MapUIContainer.MapUI.BoothUI:FindFirstChild(tostring("BoothUI".. unclaimed[1])).Details.Owner.Text, Players.LocalPlayer.DisplayName) then
            error()
        end
    end
end
--Checks if booth claim fails
while not pcall(boothclaim) do
    if errCount >= claimCount then
        serverHop()
    end
    table.remove(unclaimed, 1)
    errCount += 1
end
hopSet()
--Walks to booth
local function noclip()
    for i,v in pairs(Players.LocalPlayer.Character:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
end
local noclipper = game:GetService("RunService").Stepped:Connect(noclip)
local function walkToBooth()
    local theCframe
    if string.find(tostring(getgenv().settings.boothPosition), "6") then
        theCframe = CFrame.new(getgenv().settings.boothPosition, 0, 0)
    else 
        theCframe = CFrame.new(0, 0, getgenv().settings.boothPosition)
    end
    local boothPos
    for i,v in ipairs(game:GetService("Workspace").BoothInteractions:GetChildren()) do
        if v:GetAttribute("BoothSlot") == unclaimed[1] then
            boothPos = v.CFrame * theCframe
            break
        end
    end
    game:GetService('VirtualInputManager'):SendKeyEvent(true, "LeftControl", false, game)
    local Controls = require(Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
    Controls:Disable()
    local atBooth = false
    game:GetService("Workspace").Map.Main.Bench:Destroy()
    Players.LocalPlayer.Character.Humanoid:MoveTo(boothPos.Position)
    Players.LocalPlayer.Character.Humanoid.MoveToFinished:Connect(function(reached)
        atBooth = true
    end)
    repeat task.wait() until atBooth
    Controls:Enable()
    game:GetService('VirtualInputManager'):SendKeyEvent(false, "LeftControl", false, game)
    Players.LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(Players.LocalPlayer.Character.HumanoidRootPart.Position, Vector3.new(40, 14, 101)))
end
walkToBooth()
-- noclipper:Disconnect()
require(game.ReplicatedStorage.Remotes).Event("RefreshItems"):InvokeServer()

if getgenv().settings.signToggle and signPass then
    Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):EquipTool(Players.LocalPlayer.Backpack:FindFirstChild("DonateSign"))
end
if getgenv().settings.danceChoice == "1" then
    task.wait(.25)
    Players:Chat("/e dance")
else
    task.wait(.25)
    Players:Chat("/e dance".. getgenv().settings.danceChoice)
end

if getgenv().settings.autoBeg then
    spamming = task.spawn(begging)
end
local RaisedC = Players.LocalPlayer.leaderstats.Raised.value
Players.LocalPlayer.leaderstats.Raised.Changed:Connect(function(newRaised)
    if getgenv().settings.webhookToggle and getgenv().settings.webhookBox then
        task.spawn(function()
            local sent = false
            task.wait(1)
            local logs = game:GetService("LogService"):GetLogHistory()
            for i = 0, 4 do
                if string.find(logs[#logs - i].message, game.Players.LocalPlayer.DisplayName) then
                    local message = logs[#logs - i].message
                    local amount = string.gsub(string.match(message, 'tipped (.*) Robux'), ",", "")
                    webhook(tostring(message.." *[After Tax: "..math.floor(tonumber(amount) * 0.6).."]* (Total: "..newRaised..")"))
                    sent = true
                    break
                end
            end
            if not sent then
                local amount = newRaised - RaisedC
                webhook(tostring("💰 Somebody tipped "..amount.." Robux to "..Players.LocalPlayer.DisplayName.." *[After Tax: "..math.floor(amount * 0.6).."]* (Total: " ..newRaised..")"))
            end
            RaisedC = newRaised
            
            -- To prevent duplicates just in case
            for i = 0, 4 do
                print("")
            end
        end)
    end
    hopSet()
    if getgenv().settings.autoThanks then
        task.spawn(function()
            task.wait(getgenv().settings.thanksDelay)
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(getgenv().settings.thanksMessage[math.random(#getgenv().settings.thanksMessage)],"All")
        end)
    end
    task.wait(getgenv().settings.textUpdateDelay)
    update()
end)
update()
while task.wait(getgenv().settings.serverHopDelay * 60) do
    if not hopTimer then
        hopSet()
    end
end
