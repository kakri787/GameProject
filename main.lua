_G.love = require("love")

local enemy = require "Enemy"
local button = require "Button"

math.randomseed(os.time())

local fonts = {
    medium = {
        font = love.graphics.newFont(16),
        size = 16
    },
    large = {
        font = love.graphics.newFont(24),
        size = 24
    },
    massive = {
        font = love.graphics.newFont(60),
        size = 60
    }
}

-- Creating MiloDino object
SPRITE_WIDTH, SPRITE_HEIGHT = 760, 94
QUAD_WIDTH = 76
QUAD_HEIGHT = SPRITE_HEIGHT

local dino = {
    x = love.graphics.getWidth()/2,
    y = love.graphics.getHeight()/2-QUAD_HEIGHT/2,
    sprite = love.graphics.newImage("png/spritesheet.png"),
    animation = {
        direction = "right",
        vertical = "none",
        idle = true,
        frame = 1,
        max_frames = 10,
        speed = 5,
        timer = 0.1
    }
}


local quads = {}
for i = 1, dino.animation.max_frames do
    quads[i] = love.graphics.newQuad (QUAD_WIDTH * (i-1), 0,  QUAD_WIDTH, QUAD_HEIGHT, SPRITE_WIDTH, SPRITE_HEIGHT)
end

-- Creating game states
local game = {
    state = {
        menu = true,
        pause = false,
        running = false,
        ended = false
    },
    difficulty = 1,
    points = 0,
    levels = {15, 30, 60, 120} -- table with points that correspond to levels
}

-- Init enemy and button tables
local enemies = {}

local buttons = {
    menu_state = {},
    ended_state = {}
}

local function changeGameState(state)
    game.state["menu"] = state == "menu"
    game.state["paused"] = state == "paused"
    game.state["running"] = state == "running"
    game.state["ended"] = state == "ended"
end

-- function to start game
local function startNewGame()
    love.mouse.setVisible(false)

    changeGameState("running")
    game.points = 0
    dino.x = love.graphics.getWidth()/2
    dino.y = love.graphics.getHeight()/2-QUAD_HEIGHT/2
    enemies = {
        enemy(1)
    }
end

-- function to check if button is pressed
function love.mousepressed(x, y, button, presses)
    if not game.state.running then
        if button == 1 then
            if game.state.menu then
                for index in pairs(buttons.menu_state) do
                    buttons.menu_state[index]:checkPressed(x, y)
                end
            elseif game.state.ended then
                for index in pairs(buttons.ended_state) do
                    buttons.ended_state[index]:checkPressed(x, y)
                end
            end
        end
    end
end

function love.load()
    local bgm = love.audio.newSource( 'audio/ballin.mp3', 'stream' )
    bgm:setVolume(0.2)
    bgm:setLooping( true )
    bgm:play()
    
    buttons.menu_state.play = button("Play", startNewGame, nil, 50, 50)
    buttons.menu_state.exit = button ("Exit", love.event.quit, nil, 50, 50)

    buttons.ended_state.replay = button("Replay", startNewGame, nil, 50, 50)
    buttons.ended_state.menu = button ("Menu", changeGameState, "menu", 50, 50)
    buttons.ended_state.exit = button ("Exit", love.event.quit, nil, 50, 50)
end


function love.update(dt)
    if game.state.running then
        -- allow player controls for movement
        if love.keyboard.isDown("d") then
            dino.animation.idle = false
            dino.animation.direction = "right"
            dino.x = dino.x + dino.animation.speed
        end
        if love.keyboard.isDown("a") then
            dino.animation.idle = false
            dino.animation.direction = "left"
            dino.x = dino.x - dino.animation.speed
        end
        if love.keyboard.isDown("w") then
            dino.animation.idle = false
            dino.y = dino.y - dino.animation.speed
        end
        if love.keyboard.isDown("s") then
            dino.animation.idle = false
            dino.y = dino.y + dino.animation.speed
        end
        -- if no keyboard input then reset sprite to idle state and idle frame
        if not love.keyboard.isDown('w', 'a', 's', 'd') then
            dino.animation.idle = true
            dino.animation.frame = 1
        end
        -- animating sprite if not idle
        if not dino.animation.idle then
            dino.animation.timer = dino.animation.timer + dt

            -- updating to next frame
            if dino.animation.timer > 0.1 + dt then -- default timer is 0.1, dt is time for every frame i.e 1/60 seconds, if timer exceeds time between frame then update to next frame
                dino.animation.timer = 0.1
                dino.animation.frame = dino.animation.frame + 1

                -- looping animation set once every frame in set has been exhausted
                if dino.animation.frame > dino.animation.max_frames then
                    dino.animation.frame = 1
                end
            end
        end

        -- spawning enemies
        for i = 1, #enemies do
            if not enemies[i]:checkTouched(dino.x, dino.y+QUAD_HEIGHT/2) then
                enemies[i]:move(dino.x, dino.y+QUAD_HEIGHT/2)

                for i = 1, #game.levels do
                    if math.floor(game.points) == game.levels[i] then
                        table.insert(enemies, 1, enemy(game.difficulty * (i+1)))

                        game.points = game.points + 1
                    end
                end
            else
                changeGameState("ended")
                love.mouse.setVisible(true)
            end
        end

        game.points = game.points + 3*dt
    end
end

function love.draw()
    if game.state.menu then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("MILODINO", fonts.massive.font, -20, 200, love.graphics.getWidth(), "center")
        buttons.menu_state.play:draw(love.graphics.getWidth()/2-buttons.menu_state.play.width, love.graphics.getHeight()/2-buttons.menu_state.play.height, 13, 19)
        buttons.menu_state.exit:draw(love.graphics.getWidth()/2-buttons.menu_state.exit.width, love.graphics.getHeight()/2 + 5, 13,19)
    elseif game.state.ended then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("GAME OVER", fonts.massive.font, -20, 200, love.graphics.getWidth(), "center")
        love.graphics.printf("Points: "..math.floor(game.points), fonts.large.font, -20, 300, love.graphics.getWidth(), "center")
        buttons.ended_state.replay:draw(love.graphics.getWidth()/2-buttons.ended_state.replay.width, love.graphics.getHeight()/2, 6.5, 19)
        buttons.ended_state.menu:draw(love.graphics.getWidth()/2-buttons.ended_state.replay.width, love.graphics.getHeight()/2+buttons.ended_state.replay.height+5, 9.5, 19)
        buttons.ended_state.exit:draw(love.graphics.getWidth()/2-buttons.ended_state.replay.width, love.graphics.getHeight()/2+2*(buttons.ended_state.replay.height+5), 13, 19)

    elseif game.state.running then -- if game is running draw dino to screen
        for i = 1, #enemies do
            enemies[i]:draw()
        end

        love.graphics.printf(math.floor(game.points), fonts.large.font, 0, 10, love.graphics.getWidth(), "center")
        if dino.animation.direction == "left" then -- draw sprite to face left, set x offset by quad_width/4 so sprite does not flip about y axis
            love.graphics.draw(dino.sprite, quads[dino.animation.frame], dino.x, dino.y, 0, -1, 1, QUAD_WIDTH/2)
        end
        if dino.animation.direction == "right" then -- draw sprite to face right
            love.graphics.draw(dino.sprite, quads[dino.animation.frame], dino.x, dino.y, 0, 1, 1, QUAD_WIDTH/2)
        end
    end
end
