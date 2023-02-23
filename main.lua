function love.load()
    love.window.setMode(320, 240)

    engine = love.audio.newSource("carengine.mp3", "static")
    engine:setLooping(true)
    grasssfx = love.audio.newSource("grasssfx.mp3", "static")
    grasssfx:setLooping(true)
    startnoise = love.audio.newSource("startnoise1.mp3", "static")

    screenHeight = love.graphics.getHeight()
    screenWidth = love.graphics.getWidth()

    mountainx = -3000

    totalSectDist = 0

    distance = 0
    curvature = 0

    playerCurvature = 0

    elapsedTime = 0

    drBrownOne = {0.7, 0.7, 0.7}
    drBrownTwo = {0.3, 0.3, 0.3}

    crRed = {0.9, 0, 0}
    crWhite = {0.95, 0.95, 0.95}

    grass1 = {0.1, 0.2, 0.09}
    grass2 = {0.0, 0.1, 0.05}
    grass1 = grass2
    yello = {1, 1, 0}

    timerColor = {0.7,0.7,0.7}

    trackDist = {500, 100, 300, 100, 300, 300, 200, 170, 1500}
    trackCurve = {0, -1.4, 0, 0.6, -0.6, 0, 0, -1.4, 0}
    track = {}
    trackSections = {}

    timer = 0

    for i = 1, #trackDist, 1 do
        for k = 1, trackDist[i], 1 do
            table.insert(track, trackCurve[i])
            table.insert(trackSections, 0)
        end
    end

    po = 0

    for i=#track, 2, -1 do
        nextCurve = track[i - 1]
        curve = track[i]
            if (curve > nextCurve and curve == 0) then
                curve = curve - 0.0025
                while (curve > nextCurve) do
                    table.insert(track,i,curve)
                    table.insert(trackSections,i,1)
                    curve = curve - 0.0025
                end
            elseif (curve < nextCurve and curve == 0) then
                curve = curve + 0.0025
                while (curve < nextCurve) do
                    table.insert(track,i, curve)
                    table.insert(trackSections,i,1)
                    curve = curve + 0.0025
                end
            elseif (curve > nextCurve) then
                curve = curve - 0.0025
                while (curve > nextCurve) do
                    table.insert(track,i,curve)
                    table.insert(trackSections,i,0)
                    curve = curve - 0.0025
                end
            elseif (curve < nextCurve) then
                curve = curve + 0.0025
                while (curve < nextCurve) do
                    table.insert(track,i, curve)
                    table.insert(trackSections,i,0)
                    curve = curve + 0.0025
                end
            end
    end

    billboards = {}

    for i=1, #trackSections, 1 do
        if i % 500 == 0 then
            table.insert(billboards,i,1)
        else 
            table.insert(billboards,i,0)
        end
    end
    

    zmap = {}
    for i=1, 122 do 
        val = 1.2^(i - 89)
        table.insert(zmap, val)
    end
    

    totalDist = 0

    dx = 0

    counter = 0

    distanceToSegment = 0

    speed = 0

    trackSection = 0
    offset = 0
    
    car = "center"

    finishline = love.graphics.newImage("finishline.png")
    startline1 = love.graphics.newImage("startline1.png")
    startline2 = love.graphics.newImage("startline2.png")
    startlinego1 = love.graphics.newImage("startlinego1.png")
    startlinego2 = love.graphics.newImage("startlinego2.png")

    leftSign = love.graphics.newImage("signL.png")
    signR = love.graphics.newImage("signR.png")

    mountain = love.graphics.newImage("mountainscargame.png")

    start = false
    trackend = false

    distance = distance + 0.1

    doneOnce = false
end

function love.keypressed(key)
    if love.keyboard.isDown("s") then
        distance = distance - (10)
    end
end

function love.update(dt)
    elapsedTime = elapsedTime + 1

    local togglepre = math.sin(elapsedTime / 5.5)
    local togglego = math.sin(elapsedTime * 1.5)

    if (togglepre > 0 and start == false) then
        startlinepre = startline1
        startnoise:play()
    elseif (togglepre > 0 and start == true) then
        startnoise:setPitch(1.5)
        startnoise:play()
    else
        startlinepre = startline2
        startnoise:stop()
    end

    if (elapsedTime > 115) then
        startnoise:stop()
    end

    if (togglepre > 0 and trackend == true) then
        timerColor = {1,1,1}
    else
        timerColor = {.7,.7,.7}
    end

    if (togglego > 0) then
        startlinego = startlinego1
    else
        startlinego = startlinego2
    end

    if (start and trackend == false) then
        startline = startlinego
        timer = timer + 1
    else
        startline = startlinepre
    end

    if (elapsedTime > 100) then
        start = true
    end

    image = "f1centered.png"
    pitch = ((speed + 1) / 27)

    if (love.keyboard.isDown("a")) and (speed > 0) then
        mountainx = mountainx + (dt * 200 * math.abs(curvature))

        image = "f1carLeft.png"
        playerCurvature = playerCurvature + 0.025
    end

    if love.keyboard.isDown("d") and (speed > 0) then
        mountainx = mountainx - (dt * 200 * math.abs(curvature))

        image = "f1carRight.png"
        playerCurvature = playerCurvature - 0.025
    end


    if love.keyboard.isDown("w") and trackend == false then
        engine:play()
        engine:setPitch(pitch)
        if (start == true) then
            if (speed < 4) then
                speed = speed + (dt * 10)
            elseif (speed >= 4 and speed < 9) then
                speed = speed + (dt * 11)
            elseif (speed >= 9 and speed < 19) then
                speed = speed + (dt * 13)
            elseif (speed >= 19 and speed < 29) then
                speed = speed + (dt * 8)
            elseif (speed >= 29 and speed < 34) then
                speed = speed + (dt * 5)
            elseif (speed >= 34 and speed < 37) then
                speed = speed + (dt * 1)
            end
        end

            distance = distance + (0.3 * speed)
    else 
        engine:setPitch(pitch)
        if (speed > 0) then
            speed = speed - (dt * 9)
        elseif (speed < 0) then
            engine:play()
            speed = 0
        end
        distance = distance + (0.2 * speed)
    end

    if (playerCurvature > 0.5 or playerCurvature < -0.5) then
        grasssfx:play()
        if (speed > 6) then
            speed = speed - (dt * 50)
        end
    else
        grasssfx:stop()
    end

    curvature = track[math.ceil(distance)]

    offset = 0
    playerCurvature = playerCurvature - (0.035 * curvature * 0.02 * speed)

    if (distance + 400 > #track) then
        distance = 1;
    end

    
end

function love.draw()
    local rowd
    local v
    local clip

    love.graphics.setColor(0.2,0.0,0.7)
    love.graphics.rectangle("fill", 0,0,320,111)
    love.graphics.setColor(0.5,0.0,0.7)
    love.graphics.rectangle("fill", 0,111,320,3)
    love.graphics.setColor(0.7,0.0,0.4)
    love.graphics.rectangle("fill", 0,114,320,3)
    love.graphics.setColor(0.7,0.2,0.2)
    love.graphics.rectangle("fill", 0,117,320,3)

    love.graphics.setColor(0.0, 0.4, 0.2)
    love.graphics.draw(mountain, mountainx, 0)


    for y=0,screenHeight / 2, 1 do
        local renderLine = math.ceil(distance + zmap[121 - y])
        local renderLine2 = math.ceil(distance + zmap[122 - y])
        local isInView = false
        if (zmap[122 - y] > 20) then
            for i=renderLine, renderLine2, 1 do
                if (billboards[i] == 1) then
                    isInView = true
                end
            end
        elseif (billboards[renderLine] == 1) then
            isInView = true
        end

        local perspective = y / (screenHeight / 2)
        for x=0, screenWidth, 1 do
            local row = screenHeight / 2 + y
            local perspective = y / (screenHeight / 2)
            rowd = row
            v = y
            

            dx = track[renderLine]

            if (dx == 0 or trackSections[renderLine] == 1) then
                dx = curvature
            end
            
            local middlePt = 0.5 - (dx) * math.pow((1 - perspective), 4) + (playerCurvature * perspective)
            local roadWidth = 0.05 + perspective
            local clipWidth = roadWidth * 0.1
            local stripeWidth = roadWidth * 0.007
            local bufferWidth = roadWidth * 0.03
            local dividerWidth = roadWidth * 0.01
            local jibbit = roadWidth * 0.01
            roadWidth = roadWidth * 0.5
            local leftGrass = (middlePt - jibbit - dividerWidth - roadWidth - stripeWidth - bufferWidth - clipWidth) * screenWidth
            local leftClip = (middlePt - jibbit - dividerWidth - roadWidth - stripeWidth - bufferWidth) * screenWidth
            local leftBuffer = (middlePt - jibbit - dividerWidth - roadWidth - stripeWidth) * screenWidth
            local leftstripe = (middlePt - jibbit - dividerWidth - roadWidth) * screenWidth
            local leftDivide = (middlePt - jibbit - dividerWidth) * screenWidth
            local leftJibbit = (middlePt - jibbit) * screenWidth
            local rightJibbit = (middlePt + jibbit ) * screenWidth
            local rightDivide = (middlePt + jibbit + dividerWidth) * screenWidth
            local rightstripe = (middlePt + jibbit + dividerWidth + roadWidth) * screenWidth
            local rightBuffer = (middlePt + jibbit + dividerWidth + roadWidth + stripeWidth) * screenWidth
            local rightClip = (middlePt + jibbit + dividerWidth + roadWidth + stripeWidth + bufferWidth) * screenWidth
            local rightGrass = (middlePt + jibbit + dividerWidth + roadWidth + stripeWidth + bufferWidth + clipWidth) * screenWidth

            clip = leftClip

            local roadColor = math.sin(35 * math.pow(1-perspective, 3) + distance * 0.2)
            local skirtColor = math.sin(80 * math.pow(1-perspective, 3) + distance * 0.3)
            local stripeColor = math.sin(35 * math.pow(1-perspective, 2) + distance * 0.1)

            
            if (roadColor > 0) then
                colorDirt = drBrownOne
                colorGrass = grass1
                drBrownTwo = {0.3, 0.3, 0.3}
                colorStripe = crWhite
            else
                colorDirt = drBrownTwo
                colorGrass = grass2
                drBrownTwo = {0.27, 0.27, 0.27}
                colorStripe = {0.27, 0.27, 0.27}
            end

            if (skirtColor > 0) then
                curbColor = crRed
            else
                curbColor = crWhite
            end
            
            if (stripeColor > 0) then
                stripeColor = crWhite
            else
                stripeColor = yello
            end

            if (x >= 0 and x < leftGrass) then --draw left grass area
                love.graphics.setColor(colorGrass)
                love.graphics.rectangle("fill",x, row, 1, 1)
            elseif (x >= leftGrass and x < leftClip) then --draw left clip
                love.graphics.setColor(curbColor)
                love.graphics.rectangle("fill",x, row, 1, 1)
            elseif (x >= leftClip and x < leftBuffer) then --draw buffer
                love.graphics.setColor(drBrownTwo)
                love.graphics.rectangle("fill",x, row, 1, 1)
            elseif (x >= leftBuffer and x < leftstripe) then --draw stripe1
                love.graphics.setColor(stripeColor)
                love.graphics.rectangle("fill",x, row, 1, 1)
            elseif (x >= leftstripe and x < leftDivide) then --draw road
                love.graphics.setColor(drBrownTwo)
                love.graphics.rectangle("fill",x, row, 1, 1)
            elseif (x >= leftDivide and x < leftJibbit) then --draw stripe
                love.graphics.setColor(drBrownTwo)
                love.graphics.rectangle("fill",x, row, 1, 1)
            elseif (x >= leftJibbit and x < rightJibbit) then --draw road
                love.graphics.setColor(colorStripe)
                love.graphics.rectangle("fill",x, row, 1, 1)
            elseif (x >= rightJibbit and x < rightDivide) then --draw stripe
                love.graphics.setColor(drBrownTwo)
                love.graphics.rectangle("fill",x, row, 1, 1)
            elseif (x >= rightDivide and x < rightstripe) then --draw road
                love.graphics.setColor(drBrownTwo)
                love.graphics.rectangle("fill",x, row, 1, 1)
            elseif (x >= rightstripe and x < rightBuffer) then --draw stripe1
                love.graphics.setColor(stripeColor)
                love.graphics.rectangle("fill",x, row, 1, 1)
            elseif (x >= rightBuffer and x < rightClip) then --draw road
                love.graphics.setColor(drBrownTwo)
                love.graphics.rectangle("fill",x, row, 1, 1)
            elseif (x >= rightClip and x < rightGrass) then --draw right clip
                love.graphics.setColor(curbColor)
                love.graphics.rectangle("fill",x, row, 1, 1)
            elseif (x >= rightGrass and x < screenWidth) then --draw right grass
                love.graphics.setColor(colorGrass)
                love.graphics.rectangle("fill",x, row, 1, 1)
            end
        end
        if (isInView) then
            love.graphics.setColor(1,1,1)
            love.graphics.draw(leftSign, clip, rowd - 10, 0, 10 / (121 - y), 10 / (121 - y))
        end
    end
    local nCarPos = screenWidth / 2

    love.graphics.setColor(1,1,1)
    carOnscreen = love.graphics.newImage(image)
    love.graphics.draw(carOnscreen, nCarPos - 30, (screenHeight / 2) + 70)

    love.graphics.setColor(timerColor)
    love.graphics.print(timer, 0, 0)
    love.graphics.print(speed, 0, 15)
    love.graphics.print(distance, 0, 30)
    love.graphics.print(dx, 0, 45)
    love.graphics.print(playerCurvature, 0, 60)
end
