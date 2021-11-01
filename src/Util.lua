--[[
    GD50
    Match-3 Remake

    -- StartState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Helper functions for writing Match-3.
]]
--[[
    Gamble
    This function returns true with a certain probability (1-100), false otherwise.
    Assumes that math.random has been seeded already, doesn't seed it itself.
]]
function Gamble(probability)
    local rand = math.random(1,100)
    if(rand <= probability) then
        return true
    
    else
        return false
    end

end
--[[
    Given an "atlas" (a texture with multiple sprites), generate all of the
    quads for the different tiles therein, divided into tables for each set
    of tiles, since each color has 6 varieties.
]]
function GenerateTileQuads(atlas)
    local tiles = {}

    local x = 0
    local y = 0

    local counter = 1

    -- 9 rows of tiles
    for row = 1, 9 do
        
        -- two sets of 6 cols, different tile varietes
        for i = 1, 2 do
            tiles[counter] = {}
            
            for col = 1, 6 do
                table.insert(tiles[counter], love.graphics.newQuad(
                    x, y, 32, 32, atlas:getDimensions()
                ))
                x = x + 32
            end

            counter = counter + 1
        end
        y = y + 32
        x = 0
    end

    return tiles
end



--[[
    Generate a random tile appropriate for the current level. There's a certain chance that it'll be shiny!
]]
function GenerateTile(tileX, tileY, level)
    --Grab an index from our generated subset.
    local gFramesIndex = gTileSubset[math.random(#gTileSubset)]



    --Roll a dice!
    local shiny = Gamble(10)
    if(shiny) then
        return ShinyTile(tileX, tileY,gFramesIndex, 
        (function ()
            if level > 1 then return math.random(6) else return 1 end
        end)() )
    
    else
        return Tile(tileX, tileY, gFramesIndex, 
        (function ()
            if level > 1 then return math.random(6) else return 1 end
        end)())
    end
end

--[[
    Generates a random subset of a table. Returns a table of indices to the target table.
]]
function GenerateTableSubset(target_table, subset_size)
    local table_subset = {}

    if subset_size > #target_table then
        return
    end

    for i = 1, subset_size do
        local index = math.random(#target_table)
        while In(table_subset, index) do
            --Reroll the index
            index = math.random(#target_table)
        end

        table.insert(table_subset, index)

    end

    return table_subset

end

function In(table, value)
    for k, v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

--[[
    Recursive table printing function.
    https://coronalabs.com/blog/2014/09/02/tutorial-printing-table-contents/
]]
function print_r ( t )
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end