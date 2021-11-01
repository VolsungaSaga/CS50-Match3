--[[
    GD50
    Match-3 Remake

    -- Board Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Board is our arrangement of Tiles with which we must try to find matching
    sets of three horizontally or vertically.
]]

Board = Class{}

function Board:init(x, y, level)
    self.x = x
    self.y = y
    self.matches = {}
    self.level = level --Cache the level we receive for when we generate new tiles to replace matched ones.

    print("Board Level:"..self.level)
    self:initializeTiles(level)
end

function Board:initializeTiles(level)
    self.tiles = {}

    for tileY = 1, 8 do
        
        -- empty table that will serve as a new row
        table.insert(self.tiles, {})

        for tileX = 1, 8 do
            
            -- create a new tile at X,Y with a random color and variety
            table.insert(self.tiles[tileY], GenerateTile(tileX, tileY, level))
        end
    end

    while self:calculateMatches() do
        
        -- recursively initialize if matches were returned so we always have
        -- a matchless board on start
        self:initializeTiles(level)
    end
end



--[[
    Goes left to right, top to bottom in the board, calculating matches by counting consecutive
    tiles of the same color. Doesn't need to check the last tile in every row or column if the 
    last two haven't been a match.
]]
function Board:calculateMatches()
    --DEBUG
    --END DEBUG
    local matches = {}

    -- how many of the same color blocks in a row we've found
    local matchNum = 1

    -- horizontal matches first
    for y = 1, 8 do
        local colorToMatch = self.tiles[y][1].color
        local isShinyRow = false
        matchNum = 1
        
        -- every horizontal tile
        for x = 2, 8 do
            
            -- if this is the same color as the one we're trying to match...
            if self.tiles[y][x].color == colorToMatch then

                --If the current tile is shiny, then we mark this row as a 'shiny row'.
                if is_a(self.tiles[y][x], ShinyTile) then
                    --print("Shiny Row Found at: ".. y .."," ..x)
                    isShinyRow = true
                end

                matchNum = matchNum + 1
            else
                
                -- set this as the new color we want to watch for
                colorToMatch = self.tiles[y][x].color
                -- Gotta check the very first tile we see in a potential match, too!
                if is_a(self.tiles[y][x], ShinyTile) then
                    isShinyRow = true
                end

                -- if we have a match of 3 or more up to now, add it to our matches table
                if matchNum >= 3 then
                    local match = {}

                    --If this was a shiny row, we need to add the entire row to our match table.
                    if isShinyRow then
                        for x2 = 1, 8, 1 do
                            table.insert(match, self.tiles[y][x2])
                        end
                        --break --We don't need to check for other matches in this row, because the whole row is now in match.
                   
                     --If it was not a shiny row, then continue as normal.
                    else
                        -- go backwards from here by matchNum
                        for x2 = x - 1, x - matchNum, -1 do
                            
                            -- add each tile to the match that's in that match
                            table.insert(match, self.tiles[y][x2])
                        end

                    end

                    -- add this match to our total matches table
                    table.insert(matches, match)
                end

                matchNum = 1
                isShinyRow = false

                -- don't need to check last two if they won't be in a match
                if x >= 7 then
                    break
                end
            end
        end

        -- account for the last row ending with a match
        if matchNum >= 3 then
            local match = {}
            --Account for the last few columns with the shiny row stuff.
            if isShinyRow then
                for x = 1, 8, 1 do
                    table.insert(match, self.tiles[y][x])
                end
            else
                -- go backwards from end of last row by matchNum
                for x = 8, 8 - matchNum + 1, -1 do
                    table.insert(match, self.tiles[y][x])
                end
            end


            table.insert(matches, match)
        end
    end

    -- vertical matches
    for x = 1, 8 do
        local colorToMatch = self.tiles[1][x].color
        local isShinyColumn = false

        matchNum = 1

        -- every vertical tile
        for y = 2, 8 do


            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1

                --If the current tile is shiny, then we mark this column as a 'shiny column'.
                if is_a(self.tiles[y][x], ShinyTile) then
                    --print("Shiny Row Found at: ".. y .."," ..x)
                    isShinyColumn = true
                end
            else
                colorToMatch = self.tiles[y][x].color

                -- Gotta check the very first tile we see in a potential match, too!
                if is_a(self.tiles[y][x], ShinyTile) then
                    isShinyColumn = true
                end

                if matchNum >= 3 then
                    local match = {}

                    --If this was a shiny row, we need to add the entire row to our match table.
                    if isShinyColumn then
                        for y2 = 1, 8, 1 do
                            table.insert(match, self.tiles[y2][x])
                        end
                        --break --We don't need to check for other matches in this row, because the whole row is now in match.
                    else

                        for y2 = y - 1, y - matchNum, -1 do
                            table.insert(match, self.tiles[y2][x])
                        end

                    end
                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if y >= 7 then
                    break
                end
            end
        end

        -- account for the last column ending with a match
        if matchNum >= 3 then
            local match = {}

            --Account for the last few columns with the shiny row stuff.
            if isShinyColumn then
                for y = 1, 8, 1 do
                    table.insert(match, self.tiles[y][x])
                end
            else
                -- go backwards from end of last row by matchNum
                for y = 8, 8 - matchNum + 1, -1 do
                    table.insert(match, self.tiles[y][x])
                end
            end

            table.insert(matches, match)
        end
    end

    -- store matches for later reference
    self.matches = matches

    -- return matches table if > 0, else just return false
    return #self.matches > 0 and self.matches or false
end

--[[
    Remove the matches from the Board by just setting the Tile slots within
    them to nil, then setting self.matches to nil.
]]
function Board:removeMatches()
    for k, match in pairs(self.matches) do
        for k, tile in pairs(match) do
            self.tiles[tile.gridY][tile.gridX] = nil
        end
    end

    self.matches = nil
end

--[[
    Shifts down all of the tiles that now have spaces below them, then returns a table that
    contains tweening information for these new tiles.
]]
function Board:getFallingTiles()
    -- tween table, with tiles as keys and their x and y as the to values
    local tweens = {}

    -- for each column, go up tile by tile till we hit a space
    for x = 1, 8 do
        local space = false
        local spaceY = 0

        local y = 8
        while y >= 1 do
            
            -- if our last tile was a space...
            local tile = self.tiles[y][x]
            
            if space then
                
                -- if the current tile is *not* a space, bring this down to the lowest space
                if tile then
                    
                    -- put the tile in the correct spot in the board and fix its grid positions
                    self.tiles[spaceY][x] = tile
                    tile.gridY = spaceY

                    -- set its prior position to nil
                    self.tiles[y][x] = nil

                    -- tween the Y position to 32 x its grid position
                    tweens[tile] = {
                        y = (tile.gridY - 1) * 32
                    }

                    -- set Y to spaceY so we start back from here again
                    space = false
                    y = spaceY

                    -- set this back to 0 so we know we don't have an active space
                    spaceY = 0
                end
            elseif tile == nil then
                space = true
                
                -- if we haven't assigned a space yet, set this to it
                if spaceY == 0 then
                    spaceY = y
                end
            end

            y = y - 1
        end
    end

    -- create replacement tiles at the top of the screen
    for x = 1, 8 do
        for y = 8, 1, -1 do
            local tile = self.tiles[y][x]

            -- if the tile is nil, we need to add a new one
            if not tile then

                -- new tile with random color and variety
                local tile = GenerateTile(x,y, self.level)
                tile.y = -32
                self.tiles[y][x] = tile

                -- create a new tween to return for this tile to fall down
                tweens[tile] = {
                    y = (tile.gridY - 1) * 32
                }
            end
        end
    end

    return tweens
end

--[[
    Get the neighbors of a given tile. Returns a table of Tiles
]]
function Board:getNeighbors(tile)
    local tileX = tile.gridX
    local tileY = tile.gridY

    --Left Edge
    if tileX == 1 then
        --Upper Left Corner
        if tileY == 1 then
            return {
                self.tiles[tileY][tileX + 1],
                self.tiles[tileY + 1][tileX]
            }
            
        --Lower Left Corner
        elseif tileY == 8 then
            return {
                self.tiles[tileY - 1][tileX],
                self.tiles[tileY][tileX + 1]
            }
        --Edge
        else
            return {
                self.tiles[tileY - 1][tileX],
                self.tiles[tileY][tileX + 1],
                self.tiles[tileY + 1][tileX]
            }
        end

    --Right Edge
    elseif tileX == 8 then
        --Upper Right Corner
        if tileY == 1 then
            return {
                self.tiles[tileY][tileX - 1],
                self.tiles[tileY + 1][tileX]
            }
        --Lower Right Corner
        elseif tileY == 8 then
            return {
                self.tiles[tileY - 1][tileX],
                self.tiles[tileY][tileX - 1]
            }
        --Edge
        else
            return {
                self.tiles[tileY - 1][tileX],
                self.tiles[tileY][tileX - 1],
                self.tiles[tileY + 1][tileX]
            }
        end


    elseif tileY == 1 then
        --Already got the corners in the previous cases, so upper edge!
        return {
            self.tiles[tileY][tileX - 1],
            self.tiles[tileY + 1][tileX],
            self.tiles[tileY][tileX + 1]
        }

    elseif tileY == 8 then
        --Lower Edge
        return {
            self.tiles[tileY][tileX - 1],
            self.tiles[tileY - 1][tileX],
            self.tiles[tileY][tileX + 1]
        }


    else
        --Not an edge!
        return{
            self.tiles[tileY][tileX + 1],
            self.tiles[tileY + 1][tileX],
            self.tiles[tileY][tileX - 1],
            self.tiles[tileY - 1][tileX]
        }

    end
end

function Board:render()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:render(self.x, self.y)
        end
    end
end