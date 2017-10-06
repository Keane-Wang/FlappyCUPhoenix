-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

display.setStatusBar( display.HiddenStatusBar )

local physics = require( "physics" )
physics.start()
physics.pause()

_W = display.contentWidth
_H = display.contentHeight

scroll = 2

local bg1 = display.newImageRect("bg.png", 480, 320)
	bg1.anchorX = 0
	bg1.anchorY = 0
	bg1.x = 0
	bg1.y = 0
 
local bg2 = display.newImageRect("bg.png", 480, 320)
	bg2.anchorX = 0
	bg2.anchorY = 0
	bg2.x = bg1.x + 480
	bg2.y = 0
 
local Phoenix = display.newImageRect("CU-phoenix.png", 100, 60)
	Phoenix.x = 100
	Phoenix.y = 80
	Phoenix.name = "phoenix" -- for future use
	PhoenixDied = false -- the status of the phoenix
	physics.addBody(Phoenix, "dynamic", {friction = 0, bounce = 0.1})

local ground = display.newRect(240, 320, _W, 10)
	physics.addBody(ground, "static")

local scoreCircle = display.newCircle( 26, 26, 20 )
	scoreCircle:setFillColor( 0.5 )

score = 0
scoreDisplay = display.newText(score, 27, 26, native.systemFont, 20)


traps = {}  --initialize a traps table first

for i=1,2 do
	local watertower = display.newImageRect("watertower_na.png", 70, 150)
	watertower.x = 200 + 480 * (i - 1)
	watertower.y = 240 
	watertower.name = "obstacle"
	physics.addBody(watertower, "static")
	--display the watertower
	--set the global coordinates of the center of watertower
	--set a “name” property for watertower as “obstacle” 
	--turn the watertower into physical object (“static”)
	traps[i] = watertower  --add to traps table
end

--create the highrise by the same way
for i=3,4 do
	local highrise = display.newImageRect("highrise.png", 50, 230)
	highrise.x = 400 + 480 * (i - 3)
	highrise.y = 200
	highrise.name = "obstacle"
	physics.addBody(highrise, "static")
	--display the watertower
	--set the global coordinates of the center of watertower
	--set a “name” property for watertower as “obstacle” 
	--turn the watertower into physical object (“static”)
	traps[i] = highrise  --add to traps table
	--print("traps" ,i ,"=" ,traps[i].x)
end

winningText = display.newText("You Win!", 240, 25, native.systemFont, 30 )
winningText:setFillColor( 0, 0, 1 )
winningText.isVisible = false
gameoverText = display.newText("Game Over", 240, 25, native.systemFont, 30 )
gameoverText:setFillColor( 1, 0, 0 )
gameoverText.isVisible = false
swipeText = display.newText("Swipe to restart", 240, 160, native.systemFont, 30)
swipeText.isVisible = false

-- screen update to put traps over background
local drawTraps= function( event )
   for i,obj in ipairs( traps ) do
        if obj.x ~= nil then
			-- 5 is from calculation by dividing the width of whole background image over prescribed frame rate
            obj.x = obj.x - 2
        end
	end 
end



--register a globle “enterFrame” event involve drawTraps listerner

local function bgScroll (event)
    bg1.x = bg1.x - scroll
    bg2.x = bg2.x - scroll
    for i=1,4 do
    	traps[i].x = traps[i].x - scroll
	end	
 
    if bg1.x == -_W then
        bg1.x = bg2.x + 480
    end
 
    if bg2.x == -_W then
        bg2.x = bg1.x + 480
    end
end


local function scoring ()
	for i=1,4 do
		if (traps[i].x == 100) then
			score = score + 1
			scoreDisplay.text = score
		end
	end
end

local function jump(obj)
   obj:applyForce(0, -10, obj.x, obj.y)
end



local function handleJump(event)
    --call the jump function (obj is event.target)
    jump(Phoenix)
end
--add a listener to the phoenix object yourself

-- show end of game, winning here
local function endgame ()
   --if the phoenix is not died
        --show the winning text by yourself
    if ( PhoenixDied == false) then
    	winningText.isVisible = true
    end
end



 -- show Game Over
local function GameOver()
   --if the phoenix is died
        --show the “Game Over” text at the top-most center location of the screen by yourself end function
		--add a "swipe" listener to restart the game yourself
	if ( PhoenixDied == true) then
		gameoverText.isVisible = true
    end

end

local function gameStart (event)
	physics.start()
	Runtime:removeEventListener("tap", gameStart)
	Runtime:addEventListener("enterFrame", bgScroll)
	Runtime:addEventListener("enterFrame", drawTraps)
	Runtime:addEventListener("enterFrame",scoring)
	Runtime:addEventListener("touch", handleJump)
end

local function cleanup (event)
	winningText.isVisible = false
	gameoverText.isVisible = false
	swipeText.isVisible = false

	score = 0
	scoreDisplay.text = score

	bg1.x = 0
	bg1.y = 0
	bg2.x = bg1.x + 480
	bg2.y = 0

	for i=1,2 do
		traps[i].x = 200 + 480 * (i - 1)
		traps[i].y = 240 
	end

	for i=3,4 do
		traps[i].x = 400 + 480 * (i - 3)
		traps[i].y = 200
	end

	Phoenix.isVisible = true
	Phoenix.x = 100
	Phoenix.y = 80
	Phoenix.rotation = 0
	PhoenixDied = false


end

local function restart (event)
	cleanup()
	physics.pause()
	Runtime:addEventListener("tap", gameStart)
end

local function handleSwipe(event)
	if event.phase == "ended" then
		if event.xStart < event.x and (event.x - event.xStart) >= 100 then
			--audio.play( pageturnSound )
			--storyboard.gotoScene( "page06", "slideRight", 1000 )
			Runtime:removeEventListener("touch",handleSwipe)
			print("swipe right")
			restart()
			return true
		end
	
	elseif event.xStart > event.x and (event.xStart - event.x) >= 100 then
		--audio.play( pageturnSound )
		--storyboard.gotoScene( "page08", "slideLeft", 1000 )
		Runtime:removeEventListener("touch",handleSwipe)
		print("swipe left")
		restart()
		return true
	end
end

-- when collision
local function onGlobalCollision( event )
	if ( event.phase == "began" ) then
		if (traps[4].x > 50) then
			PhoenixDied = true
		end
        physics.pause()
        Runtime:removeEventListener("enterFrame", bgScroll)
        Runtime:removeEventListener("enterFrame", drawTraps)
        Runtime:removeEventListener("enterFrame", scoring)
        Runtime:removeEventListener("touch", handleJump)
        Phoenix.isVisible = false
		endgame()
		GameOver()
		swipeText.isVisible = true
		Runtime:addEventListener("touch",handleSwipe)

    elseif ( event.phase == "ended" ) then

        -- remove the phoenix
        -- Think??
    end
end

Runtime:addEventListener( "collision", onGlobalCollision )
Runtime:addEventListener("tap", gameStart)



