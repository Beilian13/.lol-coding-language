-- mode:window
window("THE LURKER", 1280, 800)

-- ── Configuration ──────────────────────────────────────────
let SW=1280 let SH=800 let HALF_H=400
let COLS=180 -- Balanced for high-speed raycasting
let STRIP=7.11
let MSENS=0.0015

-- ── Player Stats ──────────────────────────────────────────
let phealth=100
let credits=0
let ammo=15
let base_speed=0.08
let stamina=100.0
let max_stamina=100.0
let light_range=16.0
let floor_id=1

-- ── Game State ─────────────────────────────────────────────
let px=2.5   let py=2.5   let pang=0.0
let frame=0
let game_mode=0 -- 0:Play, 1:Shop, 2:Paused
let curse_type=0 -- 0:None, 1:Flicker, 2:Void, 3:Glitch, 4:Panic
let shop_cards = "" -- Not used in this engine, we'll use 3 vars
let s1=0 let s2=0 let s3=0
let p1=0 let p2=0 let p3=0

-- ── Entities ──────────────────────────────────────────────
let mx=20.5 let my=20.5 let m_speed=0.022 -- The Lurker (Red)
let bx=15.5 let by=15.5 let b_active=0    -- The Blinker (Blue)
let sx=10.5 let sy=10.5 let s_active=0    -- The Static (Grey)

-- ── Procedural Generator ──────────────────────────────────
func getMapCell(x, y)
    let fx=floor(x) let fy=floor(y)
    if fx<0 or fx>=24 or fy<0 or fy>=24 then return 1 end
    if fx==2 and fy==2 then return 0 end
    if fx==21 and fy==21 then return 2 end 
    
    -- Seeded Connectivity
    let seed = floor_id * 19.1
    let path = sin(fx * 0.4 + seed) + cos(fy * 0.4 - seed)
    if path > 0.3 then return 0 end
    
    -- Scrap Metal (Credits)
    let scrap = sin(fx * 44 + fy * 12 + seed)
    if scrap > 0.98 then return 3 end
    
    return 1
end

-- ── Audio ─────────────────────────────────────────────────
let music_t=0 let note_p=0
func playMusic()
    music_t = music_t + 1
    if music_t > 30 then
        let n = note_p % 16
        let f = 0
        if n==0 then f=110 elseif n==4 then f=130 elseif n==8 then f=123 elseif n==12 then f=110 end
        if f > 0 then tone(f, 200, 0.1, 0) end
        note_p = note_p + 1 music_t = 0
    end
end

-- ── Start Game ────────────────────────────────────────────
lockMouse(1)

while phealth > 0 do
    -- 1. PAUSE TOGGLE
    if keydown(27) == 1 then
        if game_mode == 0 then game_mode = 2 lockMouse(0)
        elseif game_mode == 2 then game_mode = 0 lockMouse(1) end
        sleep(250)
    end

    if game_mode == 0 then
        frame = frame + 1
        playMusic()
        
        -- Earn Passive Credits for Survival
        if frame % 100 == 0 then credits = credits + 5 end

        -- Activate Entities by Floor
        if floor_id > 2 then b_active = 1 end
        if floor_id > 4 then s_active = 1 end

        -- 2. MOVEMENT
        pang = pang + mouseDX() * MSENS
        let fdx = sin(pang) let fdy = 0 - cos(pang)
        let sdx = 0 - fdy    let sdy = fdx
        let wx=0 let wy=0
        if keydown(87)==1 then wy=wy+1 end if keydown(83)==1 then wy=wy-1 end
        if keydown(65)==1 then wx=wx-1 end if keydown(68)==1 then wx=wx+1 end
        
        let mag = sqrt(wx*wx + wy*wy + 0.0001)
        let isRunning = 0
        let cur_spd = base_speed
        if keydown(16)==1 and stamina > 5 and mag > 0.5 then 
            cur_spd = base_speed * 1.9 
            stamina = stamina - 0.8
            isRunning = 1
        else 
            stamina = stamina + 0.45 if stamina > max_stamina then stamina = max_stamina end
        end

        let vx = (wx/mag * sdx + wy/mag * fdx) * cur_spd
        let vy = (wx/mag * sdy + wy/mag * fdy) * cur_spd
        
        let nc = getMapCell(px+vx, py+vy)
        if nc != 1 then 
            px=px+vx py=py+vy 
            if nc == 3 then credits = credits + 50 tone(800, 50, 0.5, 1) end -- Pickup Scrap
        end

        -- 3. ENTITY AI
        -- Lurker (Chaser)
        let cur_m_spd = m_speed * (1.0001 ^ frame)
        let mdist = sqrt((mx-px)^2 + (my-py)^2)
        mx = mx + (px-mx)/mdist * cur_m_spd
        my = my + (py-my)/mdist * cur_m_spd
        if mdist < 0.4 then phealth = 0 end

        -- Blinker (Blue - Only moves when you look away)
        if b_active == 1 then
            let bdist = sqrt((bx-px)^2 + (by-py)^2)
            let diff = abs(pang - atan2(by-py, bx-px))
            if diff > 1.2 then 
                bx = bx + (px-bx)/bdist * 0.05
                by = by + (py-by)/bdist * 0.05
            end
            if bdist < 0.5 then phealth = 0 end
        end

        -- The Static (Grey - Attracted to sprinting)
        if s_active == 1 then
            let sdist = sqrt((sx-px)^2 + (sy-py)^2)
            let s_spd = 0.01
            if isRunning == 1 then s_spd = 0.06 end
            sx = sx + (px-sx)/sdist * s_spd
            sy = sy + (py-sy)/sdist * s_spd
            if sdist < 0.5 then phealth = 0 end
        end

        -- 4. RENDERING
        color(0, 0, 0) clear()
        let vd = light_range / (1.0 + floor_id * 0.12)
        if curse_type == 2 then vd = vd * 0.4 end -- Void Curse
        
        let pfov=0.8
        let planeX = 0-fdy*pfov let planeY = fdx*pfov
        let col = 0
        while col < COLS do
            let camX = 2.0 * col / COLS - 1.0
            let rdx = fdx + planeX*camX let rdy = fdy + planeY*camX
            let mapX=floor(px) let mapY=floor(py)
            let dX=abs(1/(rdx+0.0001)) let dY=abs(1/(rdy+0.0001))
            let stX=0 let stY=0 let sdX=0.0 let sdY=0.0
            if rdx<0 then stX=-1 sdX=(px-mapX)*dX else stX=1 sdX=(mapX+1-px)*dX end
            if rdy<0 then stY=-1 sdY=(py-mapY)*dY else stY=1 sdY=(mapY+1-py)*dY end
            
            let hit=0 let side=0 let wallT=0
            while hit == 0 and sdX < vd and sdY < vd do
                if sdX < sdY then sdX=sdX+dX mapX=mapX+stX side=0
                else sdY=sdY+dY mapY=mapY+stY side=1 end
                wallT = getMapCell(mapX, mapY)
                if wallT != 0 and wallT != 3 then hit = 1 end
            end
            
            if hit != 0 then
                let dist = 0.0
                if side == 0 then dist = sdX - dX else dist = sdY - dY end
                let br = 240 / (dist*dist + 0.1) * (1.0 - dist/vd)
                if curse_type == 1 and (frame % 80) < 5 then br = br * 0.2 end
                if side == 1 then br = br * 0.5 end
                if wallT == 2 then color(0, br, 0) else color(br, br*0.8, br*0.7) end
                let h = SH / (dist + 0.01)
                
                -- Glitch Curse Rendering
                let glitchX = 0
                if curse_type == 3 then glitchX = sin(col + frame)*10 end
                draw rect(col*STRIP + glitchX, HALF_H - h/2, STRIP+1, h)
            end
            col = col + 1
        end

        -- 5. SPRITE ENGINES (Eyes)
        let invDet = 1.0 / (planeX * fdy - fdx * planeY + 0.0001)
        func drawEnt(ex, ey, r, g, b)
            let tx = invDet * (fdy*(ex-px) - fdx*(ey-py))
            let ty = invDet * (0 - planeY*(ex-px) + planeX*(ey-py))
            if ty > 0.4 then
                let ssx = (SW/2) * (1 + tx/ty) let ssz = abs(SH/ty)
                color(r, g, b) draw circle(ssx - ssz/8, HALF_H, ssz/15 + 1)
                draw circle(ssx + ssz/8, HALF_H, ssz/15 + 1)
            end
        end
        drawEnt(mx, my, 255, 0, 0)
        if b_active==1 then drawEnt(bx, by, 0, 100, 255) end
        if s_active==1 then drawEnt(sx, sy, 150, 150, 150) end

        -- 6. HUD
        let d_exit = sqrt((21-px)^2 + (21-py)^2)
        color(150, 0, 0) draw text("DEPTH: " + tostr(floor_id * 100) + "m", 50, 50)
        color(255, 255, 0) draw text("CREDITS: " + tostr(credits), 50, 80)
        color(200, 0, 0) draw rect(50, 110, stamina * 3, 10)
        if d_exit < 1.3 then
            game_mode = 1 lockMouse(0)
            s1 = floor(sin(frame)*5) s2 = floor(cos(frame)*5) s3 = floor(sin(frame+5)*5)
            p1 = 100 p2 = 150 p3 = 200
            sleep(300)
        end
        if mdist < 6 or (s_active==1 and sqrt((sx-px)^2+(sy-py)^2)<6) then
            tone(40, 20, 0.3, 3) -- Danger Drone
        end

    elseif game_mode == 1 then
        -- ── SHOP SCREEN ───────────────────────────────
        color(5, 5, 15) clear()
        color(255, 255, 0) draw text("CURRENCY: " + tostr(credits) + "cr", 580, 100)
        func drawS(num, id, x, pr)
            color(20, 20, 40) draw rect(x, 200, 300, 400)
            color(255, 255, 255) draw text("ITEM 0" + tostr(num), x + 20, 230)
            let d = ""
            if id < 0 then id = abs(id) end
            if id == 0 then d = "BATTERY PACK (+12)\nPrice: " + tostr(pr) end
            if id == 1 then d = "LUNG GRAFT (+60)\nPrice: " + tostr(pr) end
            if id == 2 then d = "NEURO-STIM (++SPD)\nPrice: " + tostr(pr) end
            if id == 3 then d = "OPTIC CORE (Light+)\nPrice: " + tostr(pr) end
            if id == 4 then d = "EMP (Slower Lurker)\nPrice: " + tostr(pr) end
            draw text(d, x + 20, 350)
            draw text("PRESS ["+tostr(num)+"] TO BUY", x+20, 550)
        end
        drawS(1, s1, 150, p1) drawS(2, s2, 490, p2) drawS(3, s3, 830, p3)
        draw text("PRESS [0] TO ASCEND (FREE)", 540, 700)
        
        let buy = -1
        if keydown(49)==1 and credits >= p1 then buy=s1 credits=credits-p1 end
        if keydown(50)==1 and credits >= p2 then buy=s2 credits=credits-p2 end
        if keydown(51)==1 and credits >= p3 then buy=s3 credits=credits-p3 end
        if keydown(48)==1 then buy=99 end
        
        if buy != -1 then
            if buy == 0 then ammo = ammo + 12 end
            if buy == 1 then max_stamina = max_stamina + 60 stamina = max_stamina end
            if buy == 2 then base_speed = base_speed + 0.012 end
            if buy == 3 then light_range = light_range + 5 end
            if buy == 4 then m_speed = m_speed * 0.8 end
            
            floor_id = floor_id + 1
            curse_type = floor(sin(floor_id)*5) -- New Random Curse
            px=2.5 py=2.5 mx=20.5 my=20.5 bx=18.5 by=18.5 sx=12.5 sy=12.5
            game_mode=0 lockMouse(1) sleep(300)
        end
    elseif game_mode == 2 then
        color(0, 0, 0) clear()
        draw text("PAUSED", 620, 400)
    end
    sleep(16)
end

color(0,0,0) clear()
color(255, 0, 0) draw text("VITAL SIGNS LOST", 580, 400)
sleep(5000)
exit(0)
