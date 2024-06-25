local love = require "love"

function Enemy(level)
    local dice = math.random(1, 4) -- randomize direction that enemy spawns from
    local _x, _y
    local _radius = 20

    if dice == 1 then
        _x = math.random(_radius, love.graphics.getWidth())
        _y = -_radius * 4
    elseif dice == 2 then
        _x = -_radius * 4
        _y = math.random(_radius, love.graphics.getHeight())
    elseif dice == 3 then
        _x = math.random(_radius, love.graphics.getWidth())
        _y = love.graphics.getHeight()+ _radius * 4
    else 
        _x = love.graphics.getWidth() + _radius * 4
        _y = math.random(_radius, love.graphics.getHeight())
    end

    return {
        level = level or 1,
        radius = _radius,
        x = _x,
        y = _y,

        checkTouched = function (self, player_x, player_y)
            return math.sqrt((self.x - player_x)^2) <= QUAD_WIDTH/2 and math.sqrt((self.y - player_y) ^2) <= QUAD_HEIGHT/2
        end,

        -- arithmetic for enemy to chase after player
        move = function (self, player_x, player_y)
            if player_x - self.x > 0 then
                self.x = self.x + self.level
            elseif player_x - self.x < 0 then
                self.x = self.x - self.level
            end

            if player_y - self.y > 0 then
                self.y = self.y + self.level
            elseif player_y - self.y < 0 then
                self.y = self.y - self.level
            end
        end,

        -- basic white circle as enemy
        draw = function (self)
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle("fill", self.x, self.y, self.radius)
        end
    }
end

return Enemy