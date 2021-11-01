ShinyTile = Class{__includes = Tile}



function ShinyTile:render(x,y)

    -- draw shadow
    love.graphics.setColor(34/255, 32/255, 52/255, 255/255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

    -- draw tile itself
    love.graphics.setColor(255/255, 255/255, 255/255, 255/255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)

    --Transparent little highlight thing.
    love.graphics.setColor(1,1,0.88, 0.35)

    local highlight_vertices = {self.x + x, self.y + y + 5,
                                self.x + x + 5, self.y + y + 1, 
                                self.x + x + 10, self.y + y + 1, 
                                self.x + x + 32, self.y + y + 32 - 5,
                                self.x + x + 32 - 2, self.y + y + 32, 
                                self.x + x + 32 - 10, self.y + y + 32}
    love.graphics.polygon('fill', highlight_vertices)

end