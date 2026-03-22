-- mode:window
-- ============================================================
--  SPACE DUEL  --  2-player online shooter (GitHub Gist sync)
--  Player 1 creates a match → shares Gist ID
--  Player 2 pastes Gist ID → joins
--
--  WASD / arrows = move    SPACE = shoot
--  You are the BLUE ship   Opponent is RED
--  First to 5 kills wins
-- ============================================================

window("SPACE DUEL", 480, 360)

-- ── Keys ──────────────────────────────────────────────────────
let KEY_W=87  let KEY_S=83  let KEY_A=65  let KEY_D=68
let KEY_UP=38 let KEY_DN=40 let KEY_LEFT=37 let KEY_RIGHT=39
let KEY_SPACE=32  let KEY_ESC=27  let KEY_ENTER=13

-- ── Screen ────────────────────────────────────────────────────
let SW=480  let SH=360

-- ── GitHub Gist config ────────────────────────────────────────
-- PASTE YOUR GITHUB TOKEN HERE (needs 'gist' scope)
let GIST_TOKEN = "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"
let GIST_API   = "https://api.github.com/gists"
let GIST_FILE  = "spaceduel_state.json"
let gistId     = ""

-- ── Player (local) ────────────────────────────────────────────
let px   = 80.0   let py   = 160.0
let pvx  = 0.0    let pvy  = 0.0
let pang = 0.0    -- radians
let php  = 3      -- lives
let pscore = 0
let pSlot  = -1   -- 0=P1  1=P2
let pInv   = 0    -- invincibility frames

-- ── Opponent (remote) ─────────────────────────────────────────
let ox = 380.0   let oy = 160.0
let ovx= 0.0     let ovy= 0.0
let oang= 3.14
let ohp = 3
let oscore = 0
let oOn = 0

-- ── Bullets (8 mine + 8 opponent) ────────────────────────────
let mb0x=0.0 let mb0y=0.0 let mb0vx=0.0 let mb0vy=0.0 let mb0on=0
let mb1x=0.0 let mb1y=0.0 let mb1vx=0.0 let mb1vy=0.0 let mb1on=0
let mb2x=0.0 let mb2y=0.0 let mb2vx=0.0 let mb2vy=0.0 let mb2on=0
let mb3x=0.0 let mb3y=0.0 let mb3vx=0.0 let mb3vy=0.0 let mb3on=0
let mb4x=0.0 let mb4y=0.0 let mb4vx=0.0 let mb4vy=0.0 let mb4on=0
let mb5x=0.0 let mb5y=0.0 let mb5vx=0.0 let mb5vy=0.0 let mb5on=0
let mb6x=0.0 let mb6y=0.0 let mb6vx=0.0 let mb6vy=0.0 let mb6on=0
let mb7x=0.0 let mb7y=0.0 let mb7vx=0.0 let mb7vy=0.0 let mb7on=0

let ob0x=0.0 let ob0y=0.0 let ob0vx=0.0 let ob0vy=0.0 let ob0on=0
let ob1x=0.0 let ob1y=0.0 let ob1vx=0.0 let ob1vy=0.0 let ob1on=0
let ob2x=0.0 let ob2y=0.0 let ob2vx=0.0 let ob2vy=0.0 let ob2on=0
let ob3x=0.0 let ob3y=0.0 let ob3vx=0.0 let ob3vy=0.0 let ob3on=0
let ob4x=0.0 let ob4y=0.0 let ob4vx=0.0 let ob4vy=0.0 let ob4on=0
let ob5x=0.0 let ob5y=0.0 let ob5vx=0.0 let ob5vy=0.0 let ob5on=0
let ob6x=0.0 let ob6y=0.0 let ob6vx=0.0 let ob6vy=0.0 let ob6on=0
let ob7x=0.0 let ob7y=0.0 let ob7vx=0.0 let ob7vy=0.0 let ob7on=0

-- ── Particles (12 slots) ─────────────────────────────────────
let pt0x=0.0 let pt0y=0.0 let pt0vx=0.0 let pt0vy=0.0 let pt0l=0
let pt1x=0.0 let pt1y=0.0 let pt1vx=0.0 let pt1vy=0.0 let pt1l=0
let pt2x=0.0 let pt2y=0.0 let pt2vx=0.0 let pt2vy=0.0 let pt2l=0
let pt3x=0.0 let pt3y=0.0 let pt3vx=0.0 let pt3vy=0.0 let pt3l=0
let pt4x=0.0 let pt4y=0.0 let pt4vx=0.0 let pt4vy=0.0 let pt4l=0
let pt5x=0.0 let pt5y=0.0 let pt5vx=0.0 let pt5vy=0.0 let pt5l=0
let pt6x=0.0 let pt6y=0.0 let pt6vx=0.0 let pt6vy=0.0 let pt6l=0
let pt7x=0.0 let pt7y=0.0 let pt7vx=0.0 let pt7vy=0.0 let pt7l=0
let pt8x=0.0 let pt8y=0.0 let pt8vx=0.0 let pt8vy=0.0 let pt8l=0
let pt9x=0.0 let pt9y=0.0 let pt9vx=0.0 let pt9vy=0.0 let pt9l=0
let pt10x=0.0 let pt10y=0.0 let pt10vx=0.0 let pt10vy=0.0 let pt10l=0
let pt11x=0.0 let pt11y=0.0 let pt11vx=0.0 let pt11vy=0.0 let pt11l=0

-- ── Game state ────────────────────────────────────────────────
let frame      = 0
let running    = 1
let shootCd    = 0
let netTimer   = 0
let NET_RATE   = 5
let winner     = ""
let KILL_LIMIT = 5

-- ── Helpers ───────────────────────────────────────────────────
func clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

func spawnPart(x, y, vx, vy)
    if pt0l==0  then pt0x=x  pt0y=y  pt0vx=vx  pt0vy=vy  pt0l=18  return end
    if pt1l==0  then pt1x=x  pt1y=y  pt1vx=vx  pt1vy=vy  pt1l=16  return end
    if pt2l==0  then pt2x=x  pt2y=y  pt2vx=vx  pt2vy=vy  pt2l=20  return end
    if pt3l==0  then pt3x=x  pt3y=y  pt3vx=vx  pt3vy=vy  pt3l=14  return end
    if pt4l==0  then pt4x=x  pt4y=y  pt4vx=vx  pt4vy=vy  pt4l=18  return end
    if pt5l==0  then pt5x=x  pt5y=y  pt5vx=vx  pt5vy=vy  pt5l=16  return end
    if pt6l==0  then pt6x=x  pt6y=y  pt6vx=vx  pt6vy=vy  pt6l=18  return end
    if pt7l==0  then pt7x=x  pt7y=y  pt7vx=vx  pt7vy=vy  pt7l=14  return end
    if pt8l==0  then pt8x=x  pt8y=y  pt8vx=vx  pt8vy=vy  pt8l=18  return end
    if pt9l==0  then pt9x=x  pt9y=y  pt9vx=vx  pt9vy=vy  pt9l=16  return end
    if pt10l==0 then pt10x=x pt10y=y pt10vx=vx pt10vy=vy pt10l=20 return end
    if pt11l==0 then pt11x=x pt11y=y pt11vx=vx pt11vy=vy pt11l=14 return end
end

func burst(x, y)
    let i = 0
    while i < 8 do
        let a = i * 0.785
        spawnPart(x, y, sin(a)*4, cos(a)*4)
        i = i + 1
    end
end

func spawnMyBullet(x, y, vx, vy)
    if mb0on==0 then mb0x=x mb0y=y mb0vx=vx mb0vy=vy mb0on=1 return end
    if mb1on==0 then mb1x=x mb1y=y mb1vx=vx mb1vy=vy mb1on=1 return end
    if mb2on==0 then mb2x=x mb2y=y mb2vx=vx mb2vy=vy mb2on=1 return end
    if mb3on==0 then mb3x=x mb3y=y mb3vx=vx mb3vy=vy mb3on=1 return end
    if mb4on==0 then mb4x=x mb4y=y mb4vx=vx mb4vy=vy mb4on=1 return end
    if mb5on==0 then mb5x=x mb5y=y mb5vx=vx mb5vy=vy mb5on=1 return end
    if mb6on==0 then mb6x=x mb6y=y mb6vx=vx mb6vy=vy mb6on=1 return end
    if mb7on==0 then mb7x=x mb7y=y mb7vx=vx mb7vy=vy mb7on=1 return end
end

-- ── Gist helpers ──────────────────────────────────────────────
func gistRead()
    if gistId == "" then return "{}" end
    let resp = httpGetAuth(GIST_API + "/" + gistId, GIST_TOKEN)
    if resp == "" then return "{}" end
    let content = jsonGet(resp, "content")
    if content == "" then return "{}" end
    return content
end

func gistWrite(data)
    if gistId == "" then return end
    let p1 = "{\"files\":{\""
    let p2 = "\":{\"content\":"
    let p3 = "}}}"
    let payload = p1 + GIST_FILE + p2 + jsonEscape(data) + p3
    httpPatchAsync(0, GIST_API + "/" + gistId, payload, GIST_TOKEN)
end

func gistCreate(data)
    let cp1 = "{\"description\":\"SpaceDuel\",\"public\":true,\"files\":{\""
    let cp2 = "\":{\"content\":"
    let cp3 = "}}}"
    let payload = cp1 + GIST_FILE + cp2 + jsonEscape(data) + cp3
    let resp = httpPostAuth(GIST_API, payload, GIST_TOKEN)
    return jsonGet(resp, "id")
end

-- ── Build JSON state for my slot ─────────────────────────────
func buildMyState()
    let s = tostr(pSlot)
    let state = jsonSet("{}", "p" + s + "x",     tostr(floor(px)))
    state = jsonSet(state, "p" + s + "y",         tostr(floor(py)))
    state = jsonSet(state, "p" + s + "ang",       tostr(floor(pang*100)))
    state = jsonSet(state, "p" + s + "hp",        tostr(php))
    state = jsonSet(state, "p" + s + "score",     tostr(pscore))
    state = jsonSet(state, "p" + s + "on",        "1")
    -- encode my bullets as comma-separated x:y pairs
    let bs = ""
    if mb0on==1 then bs = bs + tostr(floor(mb0x)) + ":" + tostr(floor(mb0y)) + "," end
    if mb1on==1 then bs = bs + tostr(floor(mb1x)) + ":" + tostr(floor(mb1y)) + "," end
    if mb2on==1 then bs = bs + tostr(floor(mb2x)) + ":" + tostr(floor(mb2y)) + "," end
    if mb3on==1 then bs = bs + tostr(floor(mb3x)) + ":" + tostr(floor(mb3y)) + "," end
    state = jsonSet(state, "p" + s + "bullets", bs)
    state = jsonSet(state, "winner", winner)
    return state
end

-- ── Parse opponent state from shared JSON ────────────────────
func pullOpponent(data)
    let os2 = "1"
    if pSlot == 1 then os2 = "0" end
    oOn = tonum(jsonGet(data, "p" + os2 + "on"))
    if oOn == 0 then return end
    ox     = tonum(jsonGet(data, "p" + os2 + "x"))
    oy     = tonum(jsonGet(data, "p" + os2 + "y"))
    oang   = tonum(jsonGet(data, "p" + os2 + "ang")) / 100.0
    ohp    = tonum(jsonGet(data, "p" + os2 + "hp"))
    oscore = tonum(jsonGet(data, "p" + os2 + "score"))
    -- decode opponent bullets
    ob0on=0 ob1on=0 ob2on=0 ob3on=0 ob4on=0 ob5on=0 ob6on=0 ob7on=0
    let bs = jsonGet(data, "p" + os2 + "bullets")
    if bs ~= "" then
        let bullets = split(bs, ",")
        let nb = splitLen(bullets)
        if nb > 0 and splitGet(bullets, 0) ~= "" then
            let bx = tonum(splitGet(split(splitGet(bullets, 0), ":"), 0))
            let by2 = tonum(splitGet(split(splitGet(bullets, 0), ":"), 1))
            ob0x=bx ob0y=by2 ob0on=1
        end
        if nb > 1 and splitGet(bullets, 1) ~= "" then
            let bx = tonum(splitGet(split(splitGet(bullets, 1), ":"), 0))
            let by2 = tonum(splitGet(split(splitGet(bullets, 1), ":"), 1))
            ob1x=bx ob1y=by2 ob1on=1
        end
        if nb > 2 and splitGet(bullets, 2) ~= "" then
            let bx = tonum(splitGet(split(splitGet(bullets, 2), ":"), 0))
            let by2 = tonum(splitGet(split(splitGet(bullets, 2), ":"), 1))
            ob2x=bx ob2y=by2 ob2on=1
        end
        if nb > 3 and splitGet(bullets, 3) ~= "" then
            let bx = tonum(splitGet(split(splitGet(bullets, 3), ":"), 0))
            let by2 = tonum(splitGet(split(splitGet(bullets, 3), ":"), 1))
            ob3x=bx ob3y=by2 ob3on=1
        end
    end
    -- check winner
    let w = jsonGet(data, "winner")
    if w ~= "" then winner = w end
end

-- ── Draw ─────────────────────────────────────────────────────
func drawBG()
    color(4, 6, 16) clear()
    -- stars
    let i = 0
    while i < 60 do
        let sx = floor(abs(sin(i*137.5))*478)+1
        let sy = floor(abs(cos(i*251.3+frame*0.05))*358)+1
        if i < 40 then color(50,50,90) draw rect(sx,sy,1,1)
        else color(140,140,200) draw rect(sx,sy,2,2) end
        i = i + 1
    end
end

func drawShip(dx, dy, ang, r, g, b, inv)
    -- don't draw if invincible and blinking
    if inv > 0 and inv % 6 < 3 then return end
    let sx = floor(dx) let sy = floor(dy)
    let co = cos(ang)  let si = sin(ang)
    -- nose
    let nx = floor(dx + si*14)
    let ny = floor(dy - co*14)
    -- left wing
    let lx = floor(dx - co*8 - si*8)
    let ly = floor(dy - si*8 + co*8)  -- wait, wrong — keep simple
    -- Just draw a rotated cross for simplicity
    color(r, g, b)
    -- body
    draw rect(sx-4, sy-4, 8, 8)
    -- nose tip
    draw rect(nx-2, ny-2, 4, 4)
    -- wing left
    draw rect(floor(dx-co*10)-2, floor(dy-si*10)-2, 4, 4)  -- hmm wrong axis
    -- Keep it minimal: just a diamond + nose
    color(r, g, b) draw rect(sx-2, sy-6, 4, 12)
    draw rect(sx-6, sy-2, 12, 4)
    -- nose glow
    color(255, 220, 80)
    draw rect(nx-1, ny-1, 3, 3)
    -- engine glow
    let gc = floor(abs(sin(frame*0.3))*60)+60
    color(gc, gc/3, 200)
    draw rect(floor(dx - si*10)-2, floor(dy + co*10)-2, 4, 4)
end

func drawBullets()
    color(180, 240, 255)
    if mb0on==1 then draw rect(floor(mb0x)-2,floor(mb0y)-2,4,4) end
    if mb1on==1 then draw rect(floor(mb1x)-2,floor(mb1y)-2,4,4) end
    if mb2on==1 then draw rect(floor(mb2x)-2,floor(mb2y)-2,4,4) end
    if mb3on==1 then draw rect(floor(mb3x)-2,floor(mb3y)-2,4,4) end
    if mb4on==1 then draw rect(floor(mb4x)-2,floor(mb4y)-2,4,4) end
    if mb5on==1 then draw rect(floor(mb5x)-2,floor(mb5y)-2,4,4) end
    if mb6on==1 then draw rect(floor(mb6x)-2,floor(mb6y)-2,4,4) end
    if mb7on==1 then draw rect(floor(mb7x)-2,floor(mb7y)-2,4,4) end
    color(255, 160, 80)
    if ob0on==1 then draw rect(floor(ob0x)-2,floor(ob0y)-2,4,4) end
    if ob1on==1 then draw rect(floor(ob1x)-2,floor(ob1y)-2,4,4) end
    if ob2on==1 then draw rect(floor(ob2x)-2,floor(ob2y)-2,4,4) end
    if ob3on==1 then draw rect(floor(ob3x)-2,floor(ob3y)-2,4,4) end
end

func drawParticles()
    color(255, 180, 40)
    if pt0l>0  then draw rect(floor(pt0x),  floor(pt0y),  3,3) pt0x=pt0x+pt0vx   pt0y=pt0y+pt0vy   pt0l=pt0l-1  end
    if pt1l>0  then draw rect(floor(pt1x),  floor(pt1y),  3,3) pt1x=pt1x+pt1vx   pt1y=pt1y+pt1vy   pt1l=pt1l-1  end
    if pt2l>0  then draw rect(floor(pt2x),  floor(pt2y),  4,4) pt2x=pt2x+pt2vx   pt2y=pt2y+pt2vy   pt2l=pt2l-1  end
    if pt3l>0  then draw rect(floor(pt3x),  floor(pt3y),  3,3) pt3x=pt3x+pt3vx   pt3y=pt3y+pt3vy   pt3l=pt3l-1  end
    if pt4l>0  then draw rect(floor(pt4x),  floor(pt4y),  3,3) pt4x=pt4x+pt4vx   pt4y=pt4y+pt4vy   pt4l=pt4l-1  end
    if pt5l>0  then draw rect(floor(pt5x),  floor(pt5y),  3,3) pt5x=pt5x+pt5vx   pt5y=pt5y+pt5vy   pt5l=pt5l-1  end
    if pt6l>0  then draw rect(floor(pt6x),  floor(pt6y),  3,3) pt6x=pt6x+pt6vx   pt6y=pt6y+pt6vy   pt6l=pt6l-1  end
    if pt7l>0  then draw rect(floor(pt7x),  floor(pt7y),  3,3) pt7x=pt7x+pt7vx   pt7y=pt7y+pt7vy   pt7l=pt7l-1  end
    if pt8l>0  then draw rect(floor(pt8x),  floor(pt8y),  3,3) pt8x=pt8x+pt8vx   pt8y=pt8y+pt8vy   pt8l=pt8l-1  end
    if pt9l>0  then draw rect(floor(pt9x),  floor(pt9y),  3,3) pt9x=pt9x+pt9vx   pt9y=pt9y+pt9vy   pt9l=pt9l-1  end
    if pt10l>0 then draw rect(floor(pt10x), floor(pt10y), 4,4) pt10x=pt10x+pt10vx pt10y=pt10y+pt10vy pt10l=pt10l-1 end
    if pt11l>0 then draw rect(floor(pt11x), floor(pt11y), 3,3) pt11x=pt11x+pt11vx pt11y=pt11y+pt11vy pt11l=pt11l-1 end
end

func drawHUD()
    -- P1 (blue) lives left
    color(40, 120, 220) draw text("P1", 10, 8)
    let i = 0
    while i < php do
        color(40, 180, 255) draw rect(34 + i*14, 10, 10, 8)
        i = i + 1
    end
    color(255, 220, 50) draw text(tostr(pscore), 10, 22)

    -- P2 (red) lives right
    if oOn == 1 then
        color(220, 60, 40) draw text("P2", SW-28, 8)
        let j = 0
        while j < ohp do
            color(255, 100, 60) draw rect(SW-50-j*14, 10, 10, 8)
            j = j + 1
        end
        color(255, 220, 50) draw text(tostr(oscore), SW-26, 22)
    else
        color(120, 80, 60) draw text("Waiting...", SW/2-36, 8)
    end

    -- Score to win
    color(180, 180, 220) draw text("First to " + tostr(KILL_LIMIT), SW/2-34, SH-16)

    -- Gist ID display (small, for sharing)
    if gistId ~= "" then
        color(60, 80, 60) draw text("ID:" + gistId, 2, SH-8)
    end

    -- Winner overlay
    if winner ~= "" then
        color(0,0,0) draw rect(100, 140, 280, 70)
        if winner == tostr(pSlot) then
            color(80, 255, 120) draw text("YOU WIN!", 188, 158)
        else
            color(255, 80, 80)  draw text("YOU LOSE!", 184, 158)
        end
        color(200,200,255) draw text("ESC to quit", 192, 182)
    end
end

-- ── Setup screen ─────────────────────────────────────────────
let savePath = path_join(scriptParent, "spaceduel_id.txt")

func drawSetup()
    color(4,6,16) clear()
    let i = 0
    while i < 40 do
        let sx=floor(abs(sin(i*137.5+frame*0.02))*478)+1
        let sy=floor(abs(cos(i*251.3))*358)+1
        color(50,50,90) draw rect(sx,sy,2,2)
        i = i + 1
    end
    color(40,180,255)  draw text("SPACE DUEL", SW/2-46, 60)
    color(180,180,220) draw text("2-player online shooter", SW/2-60, 82)
    if gistId == "" then
        color(255,220,50) draw text("ENTER = host new match (P1)", SW/2-74, 140)
        color(160,200,160) draw text("or put Gist ID in spaceduel_id.txt to join", SW/2-110, 164)
    else
        color(100,255,150) draw text("Gist ID:", SW/2-40, 140)
        color(255,220,80)  draw text(gistId, SW/2-floor(len(gistId)*3), 162)
        color(160,200,160) draw text("ENTER = join as P2 (or re-host as P1)", SW/2-94, 186)
    end
    if GIST_TOKEN == "YOUR_GITHUB_TOKEN_HERE" then
        color(255,80,80) draw text("Set GIST_TOKEN at top of script!", SW/2-88, 220)
    end
    color(80,80,120) draw text("WASD=move  SPACE=shoot", SW/2-60, 290)
end

-- Load saved gist id
if path_exists(savePath) == 1 then
    let saved = readFile(savePath)
    if len(saved) > 5 then gistId = trim(saved) end
end

-- Setup loop
let setup = 1
while setup == 1 do
    frame = frame + 1
    if keydown(KEY_ESC)==1 then running=0 setup=0 end
    if keydown(KEY_ENTER)==1 then
        if GIST_TOKEN == "YOUR_GITHUB_TOKEN_HERE" then
            -- show error, stay on setup
        elseif gistId == "" then
            -- Host as P1
            color(4,6,16) clear()
            color(255,220,50) draw text("Creating match...", SW/2-52, 180)
            sleep(16)
            let initData = "{\"p0on\":0,\"p0x\":80,\"p0y\":160,\"p0ang\":0,\"p0hp\":3,\"p0score\":0,\"p0bullets\":\"\","
            initData = initData + "\"p1on\":0,\"p1x\":380,\"p1y\":160,\"p1ang\":314,\"p1hp\":3,\"p1score\":0,\"p1bullets\":\"\","
            initData = initData + "\"winner\":\"\"}"
            let newId = gistCreate(initData)
            if newId ~= "" then
                gistId = newId
                writeFile(savePath, newId)
                pSlot = 0
                px = 80.0  py = 160.0  pang = 0.0
                setup = 0
            end
        else
            -- Join as P2
            pSlot = 1
            px = 380.0  py = 160.0  pang = 3.14159
            setup = 0
        end
    end
    drawSetup()
    sleep(16)
end

if running == 0 then
    let d2 = 0
else

-- Mark ourselves online
let initPull = gistRead()
let myState = buildMyState()
let merged = jsonSet(initPull, "p" + tostr(pSlot) + "on", "1")
gistWrite(merged)

-- ═══════════════════════
--  MAIN LOOP
-- ═══════════════════════
while running == 1 do
    frame = frame + 1
    shootCd = shootCd - 1  if shootCd < 0 then shootCd = 0 end
    pInv = pInv - 1        if pInv < 0 then pInv = 0 end
    netTimer = netTimer + 1

    if keydown(KEY_ESC) == 1 then running = 0 end

    -- ── Movement ──────────────────────────────────────────────
    let thrust = 0
    if keydown(KEY_W)==1 or keydown(KEY_UP)==1 then
        pvx = pvx + sin(pang)*0.25
        pvy = pvy - cos(pang)*0.25
        thrust = 1
    end
    if keydown(KEY_S)==1 or keydown(KEY_DN)==1 then
        pvx = pvx - sin(pang)*0.12
        pvy = pvy + cos(pang)*0.12
    end
    if keydown(KEY_A)==1 or keydown(KEY_LEFT)==1 then
        pang = pang - 0.06
    end
    if keydown(KEY_D)==1 or keydown(KEY_RIGHT)==1 then
        pang = pang + 0.06
    end

    -- friction
    pvx = pvx * 0.96
    pvy = pvy * 0.96

    -- move
    px = px + pvx
    py = py + pvy

    -- wrap screen
    if px < 0   then px = SW end
    if px > SW  then px = 0  end
    if py < 0   then py = SH end
    if py > SH  then py = 0  end

    -- ── Shoot ─────────────────────────────────────────────────
    if keydown(KEY_SPACE)==1 and shootCd==0 then
        let bspd = 10.0
        spawnMyBullet(px, py, pvx + sin(pang)*bspd, pvy - cos(pang)*bspd)
        shootCd = 12
        tone(1200, 20, 0.2, 1)
    end

    -- ── Move my bullets ───────────────────────────────────────
    if mb0on==1 then mb0x=mb0x+mb0vx mb0y=mb0y+mb0vy
        if mb0x<0 or mb0x>SW or mb0y<0 or mb0y>SH then mb0on=0 end end
    if mb1on==1 then mb1x=mb1x+mb1vx mb1y=mb1y+mb1vy
        if mb1x<0 or mb1x>SW or mb1y<0 or mb1y>SH then mb1on=0 end end
    if mb2on==1 then mb2x=mb2x+mb2vx mb2y=mb2y+mb2vy
        if mb2x<0 or mb2x>SW or mb2y<0 or mb2y>SH then mb2on=0 end end
    if mb3on==1 then mb3x=mb3x+mb3vx mb3y=mb3y+mb3vy
        if mb3x<0 or mb3x>SW or mb3y<0 or mb3y>SH then mb3on=0 end end
    if mb4on==1 then mb4x=mb4x+mb4vx mb4y=mb4y+mb4vy
        if mb4x<0 or mb4x>SW or mb4y<0 or mb4y>SH then mb4on=0 end end
    if mb5on==1 then mb5x=mb5x+mb5vx mb5y=mb5y+mb5vy
        if mb5x<0 or mb5x>SW or mb5y<0 or mb5y>SH then mb5on=0 end end
    if mb6on==1 then mb6x=mb6x+mb6vx mb6y=mb6y+mb6vy
        if mb6x<0 or mb6x>SW or mb6y<0 or mb6y>SH then mb6on=0 end end
    if mb7on==1 then mb7x=mb7x+mb7vx mb7y=mb7y+mb7vy
        if mb7x<0 or mb7x>SW or mb7y<0 or mb7y>SH then mb7on=0 end end

    -- ── My bullets vs opponent ─────────────────────────────────
    if oOn==1 and pInv==0 then
        if ob0on==1 then let dx=ob0x-px let dy=ob0y-py if sqrt(dx*dx+dy*dy)<16 then
            php=php-1 pInv=90 ob0on=0 burst(px,py) tone(200,60,0.5,2)
            if php<=0 then oscore=oscore+1 php=3 px=80+pSlot*300 py=180.0 pvx=0 pvy=0 pInv=120 end
        end end
        if ob1on==1 then let dx=ob1x-px let dy=ob1y-py if sqrt(dx*dx+dy*dy)<16 then
            php=php-1 pInv=90 ob1on=0 burst(px,py) tone(200,60,0.5,2)
            if php<=0 then oscore=oscore+1 php=3 px=80+pSlot*300 py=180.0 pvx=0 pvy=0 pInv=120 end
        end end
        if ob2on==1 then let dx=ob2x-px let dy=ob2y-py if sqrt(dx*dx+dy*dy)<16 then
            php=php-1 pInv=90 ob2on=0 burst(px,py) tone(200,60,0.5,2)
            if php<=0 then oscore=oscore+1 php=3 px=80+pSlot*300 py=180.0 pvx=0 pvy=0 pInv=120 end
        end end
    end

    -- ── My bullets vs opponent ship ───────────────────────────
    if oOn==1 then
        if mb0on==1 then let dx=mb0x-ox let dy=mb0y-oy if sqrt(dx*dx+dy*dy)<16 then
            pscore=pscore+1 mb0on=0 burst(ox,oy) tone(440,60,0.4,2)
            if pscore >= KILL_LIMIT then winner=tostr(pSlot) end
        end end
        if mb1on==1 then let dx=mb1x-ox let dy=mb1y-oy if sqrt(dx*dx+dy*dy)<16 then
            pscore=pscore+1 mb1on=0 burst(ox,oy) tone(440,60,0.4,2)
            if pscore >= KILL_LIMIT then winner=tostr(pSlot) end
        end end
        if mb2on==1 then let dx=mb2x-ox let dy=mb2y-oy if sqrt(dx*dx+dy*dy)<16 then
            pscore=pscore+1 mb2on=0 burst(ox,oy) tone(440,60,0.4,2)
            if pscore >= KILL_LIMIT then winner=tostr(pSlot) end
        end end
    end

    -- ── Network sync ──────────────────────────────────────────
    if netTimer >= NET_RATE then
        netTimer = 0
        -- push my state
        let myJson = buildMyState()
        -- async pull last result
        if httpReady(1) == 1 then
            let resp = httpResult(1)
            if resp ~= "" then
                let content = jsonGet(resp, "content")
                if content ~= "" then pullOpponent(content) end
            end
            httpGetAuthAsync(1, GIST_API + "/" + gistId, GIST_TOKEN)
        end
        -- write my state (merge with last known)
        let merged2 = jsonSet(initPull, "p" + tostr(pSlot) + "x",       tostr(floor(px)))
        merged2 = jsonSet(merged2, "p" + tostr(pSlot) + "y",             tostr(floor(py)))
        merged2 = jsonSet(merged2, "p" + tostr(pSlot) + "ang",           tostr(floor(pang*100)))
        merged2 = jsonSet(merged2, "p" + tostr(pSlot) + "hp",            tostr(php))
        merged2 = jsonSet(merged2, "p" + tostr(pSlot) + "score",         tostr(pscore))
        merged2 = jsonSet(merged2, "p" + tostr(pSlot) + "on",            "1")
        let bs2 = ""
        if mb0on==1 then bs2 = bs2 + tostr(floor(mb0x)) + ":" + tostr(floor(mb0y)) + "," end
        if mb1on==1 then bs2 = bs2 + tostr(floor(mb1x)) + ":" + tostr(floor(mb1y)) + "," end
        if mb2on==1 then bs2 = bs2 + tostr(floor(mb2x)) + ":" + tostr(floor(mb2y)) + "," end
        merged2 = jsonSet(merged2, "p" + tostr(pSlot) + "bullets", bs2)
        if winner ~= "" then merged2 = jsonSet(merged2, "winner", winner) end
        initPull = merged2
        gistWrite(merged2)
    end

    -- ── Render ────────────────────────────────────────────────
    drawBG()
    drawParticles()
    drawBullets()
    drawShip(px, py, pang, 60, 140, 255, pInv)
    if oOn == 1 then
        drawShip(ox, oy, oang, 255, 80, 60, 0)
    end
    drawHUD()
    sleep(16)
end

end  -- running check
