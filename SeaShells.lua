-- Project #1 - Here's an empty project for you to work with.
-------------------------------------------------------------
-- You can freely change between projects. All of your changes
-- are automatically saved until you close the browser window.
-- This is a seashell matching, sorting, collecting game

-- Hide phone status bar so the game is full screen
display.setStatusBar(display.HiddenStatusBar)

math.randomseed(os.time())

-------------------------------------------------
-- SETTINGS
-------------------------------------------------
- responsive design
local screenW = display.contentWidth
local screenH = display.contentHeight

- size, column, row
local cardSize = 60
local columns = 4
local rows = 2

-position
local topOffset = 160
local spacing = 20

- tracking in-game
local flippedCards = {}
local matchedPairs = 0
local totalPairs = 4
local busy = false
local level = 1

-------------------------------------------------
-- BACKGROUND
-------------------------------------------------

local sky = display.newRect(
    screenW * 0.5,
    screenH * 0.5,
    screenW,
    screenH
)
sky:setFillColor(0.6, 0.85, 1)

local sand = display.newRect(
    screenW * 0.5,
    screenH * 0.82,
    screenW,
    140
)
sand:setFillColor(0.9, 0.8, 0.55)

-------------------------------------------------
-- UI TEXT
-------------------------------------------------

local title = display.newText({
    text = "Seashell Match Game",
    x = screenW * 0.5,
    y = 40,
    font = native.systemFontBold,
    fontSize = 28
})

title:setFillColor(0.1, 0.2, 0.4)

local levelText = display.newText({
    text = "Level: 1",
    x = screenW * 0.5,
    y = 75,
    font = native.systemFont,
    fontSize = 22
})

levelText:setFillColor(0.1, 0.2, 0.4)

local rewardText = display.newText({
    text = "",
    x = screenW * 0.5,
    y = screenH * 0.68,
    font = native.systemFontBold,
    fontSize = 20
})

rewardText:setFillColor(0.3, 0.2, 0.1)

-------------------------------------------------
-- SHELL REWARDS
-------------------------------------------------

local shellRewards = {
    { name = "White Shell", color = {1,1,1} },
    { name = "Pink Shell", color = {1,0.7,0.8} },
    { name = "Blue Shell", color = {0.5,0.7,1} },
    { name = "Golden Shell", color = {1,0.85,0.2} },
    { name = "Lavender Shell", color = {0.8,0.6,1} }
}

-------------------------------------------------
-- CARD SYMBOLS
-------------------------------------------------

local symbols = {
    { name = "A", color = {1,0.5,0.5} },
    { name = "B", color = {0.5,1,0.5} },
    { name = "C", color = {0.5,0.7,1} },
    { name = "D", color = {1,1,0.5} }
}

-------------------------------------------------
-- CARD TABLE
-------------------------------------------------

local cards = {}

-------------------------------------------------
-- CREATE SHELL IN SAND
-------------------------------------------------

local function createCollectedShell(shellData)

    local shell = display.newCircle(
        math.random(30, screenW - 30),
        math.random(screenH - 110, screenH - 30),
        math.random(12, 18)
    )

    shell:setFillColor(
        shellData.color[1],
        shellData.color[2],
        shellData.color[3]
    )

    shell.rotation = math.random(-40, 40)
end

-------------------------------------------------
-- LEVEL COMPLETE
-------------------------------------------------

local function levelComplete()

    local reward = shellRewards[math.random(#shellRewards)]

    rewardText.text = "You found: " .. reward.name .. "!"

    createCollectedShell(reward)

    timer.performWithDelay(1500, function()

        rewardText.text = ""

        level = level + 1
        levelText.text = "Level: " .. level

        matchedPairs = 0

        for i = 1, #cards do
            cards[i].matched = false
            cards[i].isFlipped = false
            cards[i].label.alpha = 0
            cards[i]:setFillColor(0.2, 0.5, 0.9)
        end

        -- Shuffle cards again
        local shuffled = {}

        for i = 1, #symbols do
            shuffled[#shuffled + 1] = symbols[i]
            shuffled[#shuffled + 1] = symbols[i]
        end

        for i = #shuffled, 2, -1 do
            local j = math.random(i)
            shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
        end

        for i = 1, #cards do
            cards[i].symbolData = shuffled[i]
            cards[i].label.text = shuffled[i].name
        end

    end)
end

-------------------------------------------------
-- CARD TAP
-------------------------------------------------

local function onCardTap(event)

    local card = event.target

    if busy then
        return
    end

    if card.matched then
        return
    end

    if card.isFlipped then
        return
    end

    card.isFlipped = true

    card:setFillColor(
        card.symbolData.color[1],
        card.symbolData.color[2],
        card.symbolData.color[3]
    )

    card.label.alpha = 1

    flippedCards[#flippedCards + 1] = card

    if #flippedCards == 2 then

        busy = true

        local card1 = flippedCards[1]
        local card2 = flippedCards[2]

        if card1.symbolData.name == card2.symbolData.name then

            card1.matched = true
            card2.matched = true

            matchedPairs = matchedPairs + 1

            flippedCards = {}
            busy = false

            if matchedPairs == totalPairs then
                levelComplete()
            end

        else

            timer.performWithDelay(800, function()

                for i = 1, 2 do

                    local c = flippedCards[i]

                    c.isFlipped = false

                    c:setFillColor(0.2, 0.5, 0.9)

                    c.label.alpha = 0
                end

                flippedCards = {}
                busy = false

            end)
        end
    end

    return true
end

-------------------------------------------------
-- CREATE SHUFFLED SYMBOL LIST
-------------------------------------------------

local shuffledSymbols = {}

for i = 1, #symbols do
    shuffledSymbols[#shuffledSymbols + 1] = symbols[i]
    shuffledSymbols[#shuffledSymbols + 1] = symbols[i]
end

for i = #shuffledSymbols, 2, -1 do
    local j = math.random(i)
    shuffledSymbols[i], shuffledSymbols[j] =
        shuffledSymbols[j], shuffledSymbols[i]
end

-------------------------------------------------
-- CREATE CARDS
-------------------------------------------------

local startX =
    (screenW - ((columns * cardSize) + ((columns - 1) * spacing))) * 0.5
    + cardSize * 0.5

local startY = topOffset

local index = 1

for row = 1, rows do

    for col = 1, columns do

        local x =
            startX + (col - 1) * (cardSize + spacing)

        local y =
            startY + (row - 1) * (cardSize + spacing)

        local card = display.newRoundedRect(
            x,
            y,
            cardSize,
            cardSize,
            12
        )

        card:setFillColor(0.2, 0.5, 0.9)

        card.strokeWidth = 3
        card:setStrokeColor(1,1,1)

        card.symbolData = shuffledSymbols[index]
        card.isFlipped = false
        card.matched = false

        local label = display.newText({
            text = card.symbolData.name,
            x = x,
            y = y,
            font = native.systemFontBold,
            fontSize = 28
        })

        label.alpha = 0

        card.label = label

        card:addEventListener("tap", onCardTap)

        cards[#cards + 1] = card

        index = index + 1
    end
end
