ResetBoardState = Class{__includes = BaseState}


function ResetBoardState:init()

    self.resetLabelY = -64

    
end

function ResetBoardState:enter(params)
    self.score = params.score
    self.timer = params.timer
    self.board = params.board
    --Tween the presentation text.
    Timer.tween(0.5, {[self] = {resetLabelY = VIRTUAL_HEIGHT / 2 - 8}
    })

    :finish(function ()
        Timer.after(1, function ()
            Timer.tween(0.5, {[self] = {resetLabelY = VIRTUAL_HEIGHT + 30}})
            :finish(function ()
                    --Reinitialize the board
                    self.board:initializeTiles(self.board.level)

                    --Go back to PlayState!
                    local playParams = {["level"] = self.board.level, ["score"] = self.score, ["timer"] = self.timer, ["board"] = self.board}

                    gStateMachine:change("play", playParams)
            end)
            
        end)
        
    end)




end

function ResetBoardState:update(dt)
    Timer.update(dt)
    
end

function ResetBoardState:render()
    -- render board of tiles
    self.board:render()

    -- render Level # label and background rect
    love.graphics.setColor(95/255, 205/255, 228/255, 200/255)
    love.graphics.rectangle('fill', 0, self.resetLabelY - 8, VIRTUAL_WIDTH, 48)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf("No matches! Board resetting!",
        0, self.resetLabelY, VIRTUAL_WIDTH, 'center')

    
end
