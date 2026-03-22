-- mode:window
-- ============================================================
--  STARLANCE: COOP SURVIVAL  (GitHub Gist edition)
--  No server needed. Uses GitHub Gist as shared state.
--
--  HOW TO START A MATCH:
--    First player runs this, presses ENTER to create a blob.
--    The blob ID is shown on screen — share it with friends.
--    Friends edit BLOB_ID at the top and launch the script.
--
--  The blob ID is also saved to starlance_blob.txt next to
--  this script so you don't have to re-enter it each time.
-- ============================================================

window("STARLANCE: COOP SURVIVAL", 480, 640)

-- ── Keys ─────────────────────────────────────────────────
let KEY_W=87     let KEY_S=83    let KEY_A=65    let KEY_D=68
let KEY_UP=38    let KEY_DN=40   let KEY_LEFT=37 let KEY_RIGHT=39
let KEY_Z=90     let KEY_SPC=32  let KEY_SHIFT=16 let KEY_ESC=27
let KEY_ENTER=13

-- ── Screen ───────────────────────────────────────────────
let SW=480 let SH=640

-- ── GitHub Gist API ──────────────────────────────────────
-- Free, no server needed. Needs a GitHub Personal Access Token.
-- Create one at: github.com -> Settings -> Developer Settings
--   -> Personal access tokens -> Tokens (classic) -> New
--   -> Scopes: tick "gist" only -> Generate
-- Paste it below. Share your GIST_ID with friends to join.
let GIST_TOKEN = "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"
let GIST_API   = "https://api.github.com/gists"
let GIST_FILE  = "starlance_state.json"

-- ── Slot layout in the blob ───────────────────────────────
-- We use 8 player slots. Each slot is a fixed set of keys:
--   p0x p0y p0hp p0sc p0on  (x, y, hp, score, active)
--   ...
--   p7x p7y p7hp p7sc p7on
-- Plus boss state: bx by bhp bmhp bph bon bframe
-- Plus meta: phase winner
--
-- The blob is one flat JSON object — all keys at top level.
-- We use jsonGet/jsonSet to read/write individual fields.

-- ── My player state ──────────────────────────────────────
let px=220.0  let py=540.0  let php=100  let pscore=0
let PW=14     let PH=14
let pinvince=0  let pdead=0  let shootcd=0

-- ── My slot (0-7) ────────────────────────────────────────
let mySlot   = -1     -- assigned on join
let blobId   = ""     -- the Gist ID
let blobData = "{}"   -- last fetched blob JSON
let netTimer = 0
let NET_RATE = 5      -- sync every 5 frames

-- ── Other players ────────────────────────────────────────
let op0x=0.0  let op0y=0.0  let op0hp=0  let op0on=0
let op1x=0.0  let op1y=0.0  let op1hp=0  let op1on=0
let op2x=0.0  let op2y=0.0  let op2hp=0  let op2on=0
let op3x=0.0  let op3y=0.0  let op3hp=0  let op3on=0
let op4x=0.0  let op4y=0.0  let op4hp=0  let op4on=0
let op5x=0.0  let op5y=0.0  let op5hp=0  let op5on=0
let op6x=0.0  let op6y=0.0  let op6hp=0  let op6on=0
let op7x=0.0  let op7y=0.0  let op7hp=0  let op7on=0

-- ── Boss ─────────────────────────────────────────────────
let bossOn=0   let bossHp=0  let bossMaxHp=500
let bossX=200.0 let bossY=60.0 let bossPhase=0
let bossFrame=0  -- server-authoritative frame counter

-- ── Player bullets (12) ───────────────────────────────────
let pb0x=0.0 let pb0y=0.0 let pb0on=0
let pb1x=0.0 let pb1y=0.0 let pb1on=0
let pb2x=0.0 let pb2y=0.0 let pb2on=0
let pb3x=0.0 let pb3y=0.0 let pb3on=0
let pb4x=0.0 let pb4y=0.0 let pb4on=0
let pb5x=0.0 let pb5y=0.0 let pb5on=0
let pb6x=0.0 let pb6y=0.0 let pb6on=0
let pb7x=0.0 let pb7y=0.0 let pb7on=0
let pb8x=0.0 let pb8y=0.0 let pb8on=0
let pb9x=0.0 let pb9y=0.0 let pb9on=0
let pb10x=0.0 let pb10y=0.0 let pb10on=0
let pb11x=0.0 let pb11y=0.0 let pb11on=0

-- ── Boss bullets (24) ────────────────────────────────────
let bb0x=0.0 let bb0y=0.0 let bb0vx=0.0 let bb0vy=0.0 let bb0on=0
let bb1x=0.0 let bb1y=0.0 let bb1vx=0.0 let bb1vy=0.0 let bb1on=0
let bb2x=0.0 let bb2y=0.0 let bb2vx=0.0 let bb2vy=0.0 let bb2on=0
let bb3x=0.0 let bb3y=0.0 let bb3vx=0.0 let bb3vy=0.0 let bb3on=0
let bb4x=0.0 let bb4y=0.0 let bb4vx=0.0 let bb4vy=0.0 let bb4on=0
let bb5x=0.0 let bb5y=0.0 let bb5vx=0.0 let bb5vy=0.0 let bb5on=0
let bb6x=0.0 let bb6y=0.0 let bb6vx=0.0 let bb6vy=0.0 let bb6on=0
let bb7x=0.0 let bb7y=0.0 let bb7vx=0.0 let bb7vy=0.0 let bb7on=0
let bb8x=0.0 let bb8y=0.0 let bb8vx=0.0 let bb8vy=0.0 let bb8on=0
let bb9x=0.0 let bb9y=0.0 let bb9vx=0.0 let bb9vy=0.0 let bb9on=0
let bb10x=0.0 let bb10y=0.0 let bb10vx=0.0 let bb10vy=0.0 let bb10on=0
let bb11x=0.0 let bb11y=0.0 let bb11vx=0.0 let bb11vy=0.0 let bb11on=0
let bb12x=0.0 let bb12y=0.0 let bb12vx=0.0 let bb12vy=0.0 let bb12on=0
let bb13x=0.0 let bb13y=0.0 let bb13vx=0.0 let bb13vy=0.0 let bb13on=0
let bb14x=0.0 let bb14y=0.0 let bb14vx=0.0 let bb14vy=0.0 let bb14on=0
let bb15x=0.0 let bb15y=0.0 let bb15vx=0.0 let bb15vy=0.0 let bb15on=0
let bb16x=0.0 let bb16y=0.0 let bb16vx=0.0 let bb16vy=0.0 let bb16on=0
let bb17x=0.0 let bb17y=0.0 let bb17vx=0.0 let bb17vy=0.0 let bb17on=0
let bb18x=0.0 let bb18y=0.0 let bb18vx=0.0 let bb18vy=0.0 let bb18on=0
let bb19x=0.0 let bb19y=0.0 let bb19vx=0.0 let bb19vy=0.0 let bb19on=0
let bb20x=0.0 let bb20y=0.0 let bb20vx=0.0 let bb20vy=0.0 let bb20on=0
let bb21x=0.0 let bb21y=0.0 let bb21vx=0.0 let bb21vy=0.0 let bb21on=0
let bb22x=0.0 let bb22y=0.0 let bb22vx=0.0 let bb22vy=0.0 let bb22on=0
let bb23x=0.0 let bb23y=0.0 let bb23vx=0.0 let bb23vy=0.0 let bb23on=0

-- ── Particles ────────────────────────────────────────────
let pt0x=0.0 let pt0y=0.0 let pt0vx=0.0 let pt0vy=0.0 let pt0l=0
let pt1x=0.0 let pt1y=0.0 let pt1vx=0.0 let pt1vy=0.0 let pt1l=0
let pt2x=0.0 let pt2y=0.0 let pt2vx=0.0 let pt2vy=0.0 let pt2l=0
let pt3x=0.0 let pt3y=0.0 let pt3vx=0.0 let pt3vy=0.0 let pt3l=0
let pt4x=0.0 let pt4y=0.0 let pt4vx=0.0 let pt4vy=0.0 let pt4l=0
let pt5x=0.0 let pt5y=0.0 let pt5vx=0.0 let pt5vy=0.0 let pt5l=0
let pt6x=0.0 let pt6y=0.0 let pt6vx=0.0 let pt6vy=0.0 let pt6l=0
let pt7x=0.0 let pt7y=0.0 let pt7vx=0.0 let pt7vy=0.0 let pt7l=0

-- Game state
let frame=0    -- local render/animation frame (per-client)
let gframe=0   -- shared game frame from blob (same on all clients = deterministic)
let running=1 let gamePhase=0
let aliveCount=0 let flashT=0
let bossDmg=0   -- accumulated boss damage this tick

-- Wave + coop state
let wave=0          -- current wave number (read from blob)
let teamScore=0     -- shared team score (read from blob)
let myKills=0       -- my kills this session
let waveClearing=0  -- flash timer for wave clear

-- Client-side enemy simulation (deterministic — same seed = same enemies on all clients)
-- Enemies are driven by wave + frame, not synced over network (saves bandwidth)
-- 8 enemy slots
let en0x=0.0 let en0y=0.0 let en0hp=0 let en0on=0 let en0t=0 let en0type=0
let en1x=0.0 let en1y=0.0 let en1hp=0 let en1on=0 let en1t=0 let en1type=0
let en2x=0.0 let en2y=0.0 let en2hp=0 let en2on=0 let en2t=0 let en2type=0
let en3x=0.0 let en3y=0.0 let en3hp=0 let en3on=0 let en3t=0 let en3type=0
let en4x=0.0 let en4y=0.0 let en4hp=0 let en4on=0 let en4t=0 let en4type=0
let en5x=0.0 let en5y=0.0 let en5hp=0 let en5on=0 let en5t=0 let en5type=0
let en6x=0.0 let en6y=0.0 let en6hp=0 let en6on=0 let en6t=0 let en6type=0
let en7x=0.0 let en7y=0.0 let en7hp=0 let en7on=0 let en7t=0 let en7type=0
let enSpawnCd=0    -- frames until next enemy spawn
let enTotal=0      -- enemies killed this wave
let enNeeded=0     -- kills needed to clear wave
-- Coop wave state (read from blob, slot 0 is authoritative)
let waveNum=1 let waveEnemies=0 let teamScore=0 let teamDead=0

-- ── Helpers ──────────────────────────────────────────────
func clamp(v,lo,hi)
    if v<lo then return lo end
    if v>hi then return hi end
    return v
end

-- safe number read: returns 0 if key missing or blank
func safeNum(key)
    let v = jsonGet(blobData, key)
    if v == "" then return 0 end
    return tonum(v)
end

func pkey(slot, field)
    -- returns e.g. "p3hp" for slot=3, field="hp"
    return "p" + tostr(slot) + field
end

-- ── Blob I/O ─────────────────────────────────────────────
-- ch 0 = push (PUT), ch 1 = pull (GET)
func fireRead()
    if blobId == "" then return end
    if httpReady(1) == 1 then
        -- Use authenticated GET to avoid GitHub rate limits (60/hr unauth vs 5000/hr auth)
        httpGetAuthAsync(1, GIST_API + "/" + blobId, GIST_TOKEN)
    end
end

func collectRead()
    if httpReady(1) == 0 then return end
    let resp = httpResult(1)
    if resp ~= "" then
        let content = jsonGet(resp, "content")
        if content ~= "" then
            blobData = content
        end
    end
end

func fireWrite(data)
    if blobId == "" then return end
    if httpReady(0) == 1 then
        -- wrap data in Gist update format: {"files":{"filename":{"content":"..."}}}
        -- we escape the data minimally since it's already valid JSON
        -- Build Gist PATCH body safely without nested quote issues
        let p1 = "{\"files\":{\"" 
        let p2 = "\":{\"content\":" 
        let p3 = "}}}"
        let payload = p1 + GIST_FILE + p2 + jsonEscape(data) + p3
        httpPatchAsync(0, GIST_API + "/" + blobId, payload, GIST_TOKEN)
    end
end

-- ── Join: find empty slot in current blob ─────────────────
func joinGame()
    -- sync read once at join time
    let gResp = httpGet(GIST_API + "/" + blobId)
    if gResp ~= "" then
        let cnt = jsonGet(gResp, "content")
        if cnt ~= "" then blobData = cnt end
    end
    let slot = 0
    while slot < 8 do
        let onKey = "p" + tostr(slot) + "on"
        let val = jsonGet(blobData, onKey)
        if val == "0" or val == "" then
            mySlot = slot
            -- write ourselves in
            blobData = jsonSet(blobData, "p" + tostr(slot) + "x",  tostr(floor(px)))
            blobData = jsonSet(blobData, "p" + tostr(slot) + "y",  tostr(floor(py)))
            blobData = jsonSet(blobData, "p" + tostr(slot) + "hp", tostr(php))
            blobData = jsonSet(blobData, "p" + tostr(slot) + "sc", "0")
            blobData = jsonSet(blobData, "p" + tostr(slot) + "on", "1")
            fireWrite(blobData)
            return
        end
        slot = slot + 1
    end
    -- no slot — spectate slot 0
    mySlot = 0
end

-- ── Push my state into blob ───────────────────────────────
func pushMyState()
    if mySlot < 0 or blobId == "" then return end
    let s = tostr(mySlot)
    blobData = jsonSet(blobData, "p" + s + "x",  tostr(floor(px)))
    blobData = jsonSet(blobData, "p" + s + "y",  tostr(floor(py)))
    blobData = jsonSet(blobData, "p" + s + "hp", tostr(php))
    blobData = jsonSet(blobData, "p" + s + "sc", tostr(pscore))
    blobData = jsonSet(blobData, "p" + s + "on", "1")
    -- boss damage accumulated this tick
    if bossDmg > 0 then
        let curHp = tonum(jsonGet(blobData, "bhp"))
        let newHp = curHp - bossDmg
        if newHp < 0 then newHp = 0 end
        blobData = jsonSet(blobData, "bhp", tostr(newHp))
        pscore = pscore + bossDmg * 2
        bossDmg = 0
        if newHp <= 0 then
            blobData = jsonSet(blobData, "bon", "0")
            pscore = pscore + 2000
            -- Boss kill: add to team score, mark wave cleared, schedule next boss
            let ts2 = tonum(jsonGet(blobData, "tscore"))
            blobData = jsonSet(blobData, "tscore",   tostr(ts2 + 5000))
            blobData = jsonSet(blobData, "wcleared", "1")
            blobData = jsonSet(blobData, "bnext",    tostr(frame + 600))
            chord(523,659,784,400,0.5)
        end
    end
    -- update boss frame counter if we're slot 0 (slot 0 drives boss)
    if mySlot == 0 then
        blobData = jsonSet(blobData, "bframe", tostr(frame))
        -- spawn boss when timer hits
        let bnext = tonum(jsonGet(blobData, "bnext"))
        let bOn   = tonum(jsonGet(blobData, "bon"))
        if bOn == 0 and gframe >= bnext and bnext > 0 then
            blobData = jsonSet(blobData, "bon",   "1")
            blobData = jsonSet(blobData, "bhp",   tostr(bossMaxHp))
            blobData = jsonSet(blobData, "bmhp",  tostr(bossMaxHp))
            blobData = jsonSet(blobData, "bph",   "0")
        end
        -- Coop: count alive players + check if ALL dead
        let alive = 0
        let anyActive = 0
        let sl2 = 0
        while sl2 < 8 do
            let son = jsonGet(blobData, "p" + tostr(sl2) + "on")
            let shp = tonum(jsonGet(blobData, "p" + tostr(sl2) + "hp"))
            if son == "1" then
                anyActive = 1
                if shp > 0 then alive = alive + 1 end
            end
            sl2 = sl2 + 1
        end
        blobData = jsonSet(blobData, "alive", tostr(alive))
        -- Sync team score and wave
        let ts = tonum(jsonGet(blobData, "tscore"))
        blobData = jsonSet(blobData, "tscore", tostr(ts))
        -- All active players dead = game over
        if anyActive == 1 and alive == 0 and tonum(jsonGet(blobData, "phase")) == 1 then
            blobData = jsonSet(blobData, "phase", "2")
            blobData = jsonSet(blobData, "winner", "teamdead")
        end
        -- Wave clear: boss killed + no more wave enemies = advance wave
        let wcleared = tonum(jsonGet(blobData, "wcleared"))
        if wcleared == 1 then
            let wn = tonum(jsonGet(blobData, "wave"))
            blobData = jsonSet(blobData, "wave", tostr(wn + 1))
            blobData = jsonSet(blobData, "wcleared", "0")
            blobData = jsonSet(blobData, "bnext", tostr(frame + 300))
        end
    end
    fireWrite(blobData)
end

-- ── Pull everyone else from blob ──────────────────────────
func pullState()
    collectRead()
    fireRead()
    -- boss
    bossOn    = safeNum("bon")
    bossHp    = safeNum("bhp")
    bossMaxHp = safeNum("bmhp")
    if bossMaxHp == 0 then bossMaxHp = 500 end
    bossPhase = safeNum("bph")
    bossFrame = safeNum("bframe")
    let bx2   = jsonGet(blobData, "bx")
    let by2   = jsonGet(blobData, "by")
    if bx2 ~= "" then bossX = tonum(bx2) end
    if by2 ~= "" then bossY = tonum(by2) end
    -- active players + team score + wave
    aliveCount = safeNum("alive")
    teamScore  = safeNum("tscore")
    let bw = safeNum("wave")
    if bw > wave then wave = bw end
    -- sync shared frame counter (drives deterministic sim)
    let newgf = safeNum("bframe")
    if newgf > gframe then gframe = newgf end
    waveNum    = safeNum("wave")
    teamScore  = safeNum("tscore")
    if waveNum == 0 then waveNum = 1 end
    -- other players
    if mySlot ~= 0 then
        op0x=tonum(jsonGet(blobData,"p0x")) op0y=tonum(jsonGet(blobData,"p0y"))
        op0hp=tonum(jsonGet(blobData,"p0hp")) op0on=tonum(jsonGet(blobData,"p0on"))
    end
    if mySlot ~= 1 then
        op1x=tonum(jsonGet(blobData,"p1x")) op1y=tonum(jsonGet(blobData,"p1y"))
        op1hp=tonum(jsonGet(blobData,"p1hp")) op1on=tonum(jsonGet(blobData,"p1on"))
    end
    if mySlot ~= 2 then
        op2x=tonum(jsonGet(blobData,"p2x")) op2y=tonum(jsonGet(blobData,"p2y"))
        op2hp=tonum(jsonGet(blobData,"p2hp")) op2on=tonum(jsonGet(blobData,"p2on"))
    end
    if mySlot ~= 3 then
        op3x=tonum(jsonGet(blobData,"p3x")) op3y=tonum(jsonGet(blobData,"p3y"))
        op3hp=tonum(jsonGet(blobData,"p3hp")) op3on=tonum(jsonGet(blobData,"p3on"))
    end
    if mySlot ~= 4 then
        op4x=tonum(jsonGet(blobData,"p4x")) op4y=tonum(jsonGet(blobData,"p4y"))
        op4hp=tonum(jsonGet(blobData,"p4hp")) op4on=tonum(jsonGet(blobData,"p4on"))
    end
    if mySlot ~= 5 then
        op5x=tonum(jsonGet(blobData,"p5x")) op5y=tonum(jsonGet(blobData,"p5y"))
        op5hp=tonum(jsonGet(blobData,"p5hp")) op5on=tonum(jsonGet(blobData,"p5on"))
    end
    if mySlot ~= 6 then
        op6x=tonum(jsonGet(blobData,"p6x")) op6y=tonum(jsonGet(blobData,"p6y"))
        op6hp=tonum(jsonGet(blobData,"p6hp")) op6on=tonum(jsonGet(blobData,"p6on"))
    end
    if mySlot ~= 7 then
        op7x=tonum(jsonGet(blobData,"p7x")) op7y=tonum(jsonGet(blobData,"p7y"))
        op7hp=tonum(jsonGet(blobData,"p7hp")) op7on=tonum(jsonGet(blobData,"p7on"))
    end
end

-- ── Spawn helpers ─────────────────────────────────────────
func spawnBB(x,y,vx,vy)
    if bb0on==0  then bb0x=x  bb0y=y  bb0vx=vx  bb0vy=vy  bb0on=1  return end
    if bb1on==0  then bb1x=x  bb1y=y  bb1vx=vx  bb1vy=vy  bb1on=1  return end
    if bb2on==0  then bb2x=x  bb2y=y  bb2vx=vx  bb2vy=vy  bb2on=1  return end
    if bb3on==0  then bb3x=x  bb3y=y  bb3vx=vx  bb3vy=vy  bb3on=1  return end
    if bb4on==0  then bb4x=x  bb4y=y  bb4vx=vx  bb4vy=vy  bb4on=1  return end
    if bb5on==0  then bb5x=x  bb5y=y  bb5vx=vx  bb5vy=vy  bb5on=1  return end
    if bb6on==0  then bb6x=x  bb6y=y  bb6vx=vx  bb6vy=vy  bb6on=1  return end
    if bb7on==0  then bb7x=x  bb7y=y  bb7vx=vx  bb7vy=vy  bb7on=1  return end
    if bb8on==0  then bb8x=x  bb8y=y  bb8vx=vx  bb8vy=vy  bb8on=1  return end
    if bb9on==0  then bb9x=x  bb9y=y  bb9vx=vx  bb9vy=vy  bb9on=1  return end
    if bb10on==0 then bb10x=x bb10y=y bb10vx=vx bb10vy=vy bb10on=1 return end
    if bb11on==0 then bb11x=x bb11y=y bb11vx=vx bb11vy=vy bb11on=1 return end
    if bb12on==0 then bb12x=x bb12y=y bb12vx=vx bb12vy=vy bb12on=1 return end
    if bb13on==0 then bb13x=x bb13y=y bb13vx=vx bb13vy=vy bb13on=1 return end
    if bb14on==0 then bb14x=x bb14y=y bb14vx=vx bb14vy=vy bb14on=1 return end
    if bb15on==0 then bb15x=x bb15y=y bb15vx=vx bb15vy=vy bb15on=1 return end
    if bb16on==0 then bb16x=x bb16y=y bb16vx=vx bb16vy=vy bb16on=1 return end
    if bb17on==0 then bb17x=x bb17y=y bb17vx=vx bb17vy=vy bb17on=1 return end
    if bb18on==0 then bb18x=x bb18y=y bb18vx=vx bb18vy=vy bb18on=1 return end
    if bb19on==0 then bb19x=x bb19y=y bb19vx=vx bb19vy=vy bb19on=1 return end
    if bb20on==0 then bb20x=x bb20y=y bb20vx=vx bb20vy=vy bb20on=1 return end
    if bb21on==0 then bb21x=x bb21y=y bb21vx=vx bb21vy=vy bb21on=1 return end
    if bb22on==0 then bb22x=x bb22y=y bb22vx=vx bb22vy=vy bb22on=1 return end
    if bb23on==0 then bb23x=x bb23y=y bb23vx=vx bb23vy=vy bb23on=1 return end
end

func spawnPB(x,y)
    if pb0on==0  then pb0x=x  pb0y=y  pb0on=1  return end
    if pb1on==0  then pb1x=x  pb1y=y  pb1on=1  return end
    if pb2on==0  then pb2x=x  pb2y=y  pb2on=1  return end
    if pb3on==0  then pb3x=x  pb3y=y  pb3on=1  return end
    if pb4on==0  then pb4x=x  pb4y=y  pb4on=1  return end
    if pb5on==0  then pb5x=x  pb5y=y  pb5on=1  return end
    if pb6on==0  then pb6x=x  pb6y=y  pb6on=1  return end
    if pb7on==0  then pb7x=x  pb7y=y  pb7on=1  return end
    if pb8on==0  then pb8x=x  pb8y=y  pb8on=1  return end
    if pb9on==0  then pb9x=x  pb9y=y  pb9on=1  return end
    if pb10on==0 then pb10x=x pb10y=y pb10on=1 return end
    if pb11on==0 then pb11x=x pb11y=y pb11on=1 return end
end

func spawnPart(x,y,vx,vy)
    if pt0l==0 then pt0x=x pt0y=y pt0vx=vx pt0vy=vy pt0l=20 return end
    if pt1l==0 then pt1x=x pt1y=y pt1vx=vx pt1vy=vy pt1l=18 return end
    if pt2l==0 then pt2x=x pt2y=y pt2vx=vx pt2vy=vy pt2l=22 return end
    if pt3l==0 then pt3x=x pt3y=y pt3vx=vx pt3vy=vy pt3l=16 return end
    if pt4l==0 then pt4x=x pt4y=y pt4vx=vx pt4vy=vy pt4l=20 return end
    if pt5l==0 then pt5x=x pt5y=y pt5vx=vx pt5vy=vy pt5l=18 return end
    if pt6l==0 then pt6x=x pt6y=y pt6vx=vx pt6vy=vy pt6l=22 return end
    if pt7l==0 then pt7x=x pt7y=y pt7vx=vx pt7vy=vy pt7l=15 return end
end

func burst(x,y)
    let i=0
    while i<8 do
        let a=i*0.785
        spawnPart(x,y,sin(a)*3,0-cos(a)*3)
        i=i+1
    end
end

-- ── Enemy wave system (client-side deterministic) ───────────
func rndEnemy(seed)
    -- uses gframe so all clients get identical sequence
    return abs(sin(seed * 137.5 + wave * 31.7 + gframe * 0.017))
end

func spawnEnemy(slot, ex, ey, ehp, etype)
    if slot==0 then en0x=ex en0y=ey en0hp=ehp en0on=1 en0t=0 en0type=etype end
    if slot==1 then en1x=ex en1y=ey en1hp=ehp en1on=1 en1t=0 en1type=etype end
    if slot==2 then en2x=ex en2y=ey en2hp=ehp en2on=1 en2t=0 en2type=etype end
    if slot==3 then en3x=ex en3y=ey en3hp=ehp en3on=1 en3t=0 en3type=etype end
    if slot==4 then en4x=ex en4y=ey en4hp=ehp en4on=1 en4t=0 en4type=etype end
    if slot==5 then en5x=ex en5y=ey en5hp=ehp en5on=1 en5t=0 en5type=etype end
    if slot==6 then en6x=ex en6y=ey en6hp=ehp en6on=1 en6t=0 en6type=etype end
    if slot==7 then en7x=ex en7y=ey en7hp=ehp en7on=1 en7t=0 en7type=etype end
end

func findFreeEnemy()
    if en0on==0 then return 0 end
    if en1on==0 then return 1 end
    if en2on==0 then return 2 end
    if en3on==0 then return 3 end
    if en4on==0 then return 4 end
    if en5on==0 then return 5 end
    if en6on==0 then return 6 end
    if en7on==0 then return 7 end
    return -1
end

func countEnemies()
    let n=0
    if en0on==1 then n=n+1 end if en1on==1 then n=n+1 end
    if en2on==1 then n=n+1 end if en3on==1 then n=n+1 end
    if en4on==1 then n=n+1 end if en5on==1 then n=n+1 end
    if en6on==1 then n=n+1 end if en7on==1 then n=n+1 end
    return n
end

func trySpawnWaveEnemy()
    enSpawnCd = enSpawnCd - 1
    if enSpawnCd > 0 then return end
    let slot = findFreeEnemy()
    if slot < 0 then return end
    -- seed from gframe so all clients spawn same enemy at same time
    let seed = gframe + slot * 17
    let edge = floor(rndEnemy(seed) * 4)
    let ex = 40.0 let ey = 0.0
    if edge == 0 then ex = 44 + floor(rndEnemy(seed+1)*392) ey = -30.0 end
    if edge == 1 then ex = 44 + floor(rndEnemy(seed+1)*392) ey = 670.0 end
    if edge == 2 then ex = 10.0  ey = 22 + floor(rndEnemy(seed+2)*596) end
    if edge == 3 then ex = 470.0 ey = 22 + floor(rndEnemy(seed+2)*596) end
    -- earlier waves: only basic types; later waves: harder types introduced
    let maxType = 2 + floor(wave / 2)
    if maxType > 6 then maxType = 6 end
    let etype = 1 + floor(rndEnemy(seed+3) * maxType)
    if etype > maxType then etype = maxType end
    if etype < 1 then etype = 1 end
    let ehp = 2 + wave + floor(wave/3)
    if ehp > 12 then ehp = 12 end
    spawnEnemy(slot, ex, ey, ehp, etype)
    -- spawn rate scales aggressively — wave 8+ is relentless
    let rate = 75 - wave * 7
    if rate < 12 then rate = 12 end
    enSpawnCd = rate
end

-- ── Bullet hell fire patterns ────────────────────────────────────────────

-- 1. Single aimed shot at player
func fireAimed(ex, ey, spd)
    let dx = px + PW/2 - ex
    let dy = py + PH/2 - ey
    let d = sqrt(dx*dx + dy*dy)
    if d < 1 then return end
    spawnBB(ex, ey, (dx/d)*spd, (dy/d)*spd)
end

-- 2. 3-way spread downward
func fireSpread3(ex, ey, spd)
    spawnBB(ex, ey, 0, spd)
    spawnBB(ex, ey,  sin(0.38)*spd, cos(0.38)*spd)
    spawnBB(ex, ey, 0-sin(0.38)*spd, cos(0.38)*spd)
end

-- 3. 5-way spread (wider)
func fireSpread5(ex, ey, spd)
    spawnBB(ex, ey, 0, spd)
    spawnBB(ex, ey,  sin(0.5)*spd,  cos(0.5)*spd)
    spawnBB(ex, ey, 0-sin(0.5)*spd, cos(0.5)*spd)
    spawnBB(ex, ey,  sin(1.0)*spd,  cos(1.0)*spd)
    spawnBB(ex, ey, 0-sin(1.0)*spd, cos(1.0)*spd)
end

-- 4. Full ring of N bullets
func fireRing(ex, ey, spd, n)
    let i = 0
    while i < n do
        let a = i * (6.2832 / n)
        spawnBB(ex, ey, sin(a)*spd, cos(a)*spd)
        i = i + 1
    end
end

-- 5. Double aimed: two bullets slightly offset
func fireDouble(ex, ey, spd)
    let dx = px + PW/2 - ex
    let dy = py + PH/2 - ey
    let d = sqrt(dx*dx + dy*dy)
    if d < 1 then return end
    let nx = dx/d let ny = dy/d
    -- perpendicular offset
    let ox = 0-ny*4 let oy = nx*4
    spawnBB(ex+ox, ey+oy, nx*spd, ny*spd)
    spawnBB(ex-ox, ey-oy, nx*spd, ny*spd)
end

-- 6. Spinning ring: ring offset by a rotating angle
func fireSpinRing(ex, ey, spd, n, angleOffset)
    let i = 0
    while i < n do
        let a = angleOffset + i * (6.2832 / n)
        spawnBB(ex, ey, sin(a)*spd, cos(a)*spd)
        i = i + 1
    end
end

-- 7. Burst: rapid 3 aimed shots in sequence (called 3 frames apart)
func fireBurst3(ex, ey, spd, phase)
    if phase == 0 then fireAimed(ex-4, ey, spd) end
    if phase == 1 then fireAimed(ex,   ey, spd) end
    if phase == 2 then fireAimed(ex+4, ey, spd) end
end

-- 8. Spiral: one bullet at rotating angle per call
func fireSpiral(ex, ey, spd, angle)
    spawnBB(ex, ey, sin(angle)*spd, cos(angle)*spd)
end

-- 9. Cross: 4 bullets at 90 degrees
func fireCross(ex, ey, spd)
    spawnBB(ex, ey,  spd,    0)
    spawnBB(ex, ey, 0-spd,   0)
    spawnBB(ex, ey,  0,     spd)
    spawnBB(ex, ey,  0,  0-spd)
end

-- 10. X-cross: 4 bullets at 45 degrees
func fireXcross(ex, ey, spd)
    let d = spd * 0.707
    spawnBB(ex, ey,  d,  d)
    spawnBB(ex, ey, 0-d, d)
    spawnBB(ex, ey,  d, 0-d)
    spawnBB(ex, ey, 0-d,0-d)
end

func updateOneEnemy(slot)
    let ex=0.0 let ey=0.0 let ehp=0 let eon=0 let et=0 let etype=0
    if slot==0 then ex=en0x ey=en0y ehp=en0hp eon=en0on et=en0t etype=en0type end
    if slot==1 then ex=en1x ey=en1y ehp=en1hp eon=en1on et=en1t etype=en1type end
    if slot==2 then ex=en2x ey=en2y ehp=en2hp eon=en2on et=en2t etype=en2type end
    if slot==3 then ex=en3x ey=en3y ehp=en3hp eon=en3on et=en3t etype=en3type end
    if slot==4 then ex=en4x ey=en4y ehp=en4hp eon=en4on et=en4t etype=en4type end
    if slot==5 then ex=en5x ey=en5y ehp=en5hp eon=en5on et=en5t etype=en5type end
    if slot==6 then ex=en6x ey=en6y ehp=en6hp eon=en6on et=en6t etype=en6type end
    if slot==7 then ex=en7x ey=en7y ehp=en7hp eon=en7on et=en7t etype=en7type end
    if eon==0 then return end

    et = et + 1
    -- bullet speed scales with wave
    let fspd = 1.6 + wave * 0.12
    if fspd > 4.2 then fspd = 4.2 end
    -- spiral angle for spinning patterns
    let sangle = gframe * 0.06 + slot * 0.8

    -- ── TYPE 1: Sniper — slow mover, rapid aimed triples ────────────────
    if etype == 1 then
        ex = ex + sin(gframe * 0.03 + slot) * 1.0
        ey = ey + 0.6
        if gframe % 40 == slot * 5 then fireDouble(ex+12, ey+12, fspd) end
        if gframe % 40 == slot * 5 + 5 then fireAimed(ex+12, ey+12, fspd*1.1) end
    end

    -- ── TYPE 2: Spreader — medium mover, 5-way fans ─────────────────────
    if etype == 2 then
        ex = ex + sin(gframe * 0.05 + slot * 1.3) * 1.5
        ey = ey + 1.1
        if gframe % 35 == slot * 4 then fireSpread5(ex+12, ey+24, fspd*0.9) end
    end

    -- ── TYPE 3: Spinner — stationary-ish, spinning rings ────────────────
    if etype == 3 then
        ex = ex + sin(gframe * 0.06 + slot) * 2.0
        ey = ey + 0.4
        if gframe % 18 == slot * 2 then fireSpiral(ex+12, ey+12, fspd, sangle) end
        if gframe % 60 == slot * 7 then fireRing(ex+12, ey+12, fspd*0.7, 8) end
    end

    -- ── TYPE 4: Cross — fires cross+X pattern, drops fast ───────────────
    if etype == 4 then
        ex = ex + sin(gframe * 0.04 + slot * 0.9) * 1.8
        ey = ey + 1.4
        if gframe % 45 == slot * 5 then fireCross(ex+12, ey+12, fspd) end
        if gframe % 45 == slot * 5 + 8 then fireXcross(ex+12, ey+12, fspd) end
    end

    -- ── TYPE 5: Burst — fires rapid 3-shot bursts, zigzags ──────────────
    if etype == 5 then
        let zigzag = sin(gframe * 0.08 + slot * 2.1)
        ex = ex + zigzag * 2.5
        ey = ey + 1.0
        if gframe % 12 == slot * 3     then fireBurst3(ex+12, ey+12, fspd, 0) end
        if gframe % 12 == slot * 3 + 4 then fireBurst3(ex+12, ey+12, fspd, 1) end
        if gframe % 12 == slot * 3 + 8 then fireBurst3(ex+12, ey+12, fspd, 2) end
    end

    -- ── TYPE 6: Vortex — slow dense spiral, hard to dodge ───────────────
    if etype == 6 then
        ex = ex + sin(gframe * 0.025 + slot) * 1.2
        ey = ey + 0.5
        -- fires 2 spirals rotating opposite directions
        if gframe % 6 == slot then
            fireSpiral(ex+12, ey+12, fspd*0.8, sangle)
            fireSpiral(ex+12, ey+12, fspd*0.8, 0-sangle+3.14)
        end
        if gframe % 70 == slot * 9 then fireSpread3(ex+12, ey+12, fspd*1.2) end
    end

    -- off screen = gone
    if ey > SH + 60 or ey < -100 or ex < -100 or ex > SW + 100 then eon = 0 end

    if slot==0 then en0x=ex en0y=ey en0hp=ehp en0on=eon en0t=et end
    if slot==1 then en1x=ex en1y=ey en1hp=ehp en1on=eon en1t=et end
    if slot==2 then en2x=ex en2y=ey en2hp=ehp en2on=eon en2t=et end
    if slot==3 then en3x=ex en3y=ey en3hp=ehp en3on=eon en3t=et end
    if slot==4 then en4x=ex en4y=ey en4hp=ehp en4on=eon en4t=et end
    if slot==5 then en5x=ex en5y=ey en5hp=ehp en5on=eon en5t=et end
    if slot==6 then en6x=ex en6y=ey en6hp=ehp en6on=eon en6t=et end
    if slot==7 then en7x=ex en7y=ey en7hp=ehp en7on=eon en7t=et end
end

func updateAllEnemies()
    updateOneEnemy(0) updateOneEnemy(1) updateOneEnemy(2) updateOneEnemy(3)
    updateOneEnemy(4) updateOneEnemy(5) updateOneEnemy(6) updateOneEnemy(7)
end

-- Check player bullets vs enemies
func checkPBvsEnemies()
    let s = 0
    while s < 8 do
        let ex=0.0 let ey=0.0 let ehp=0 let eon=0
        if s==0 then ex=en0x ey=en0y ehp=en0hp eon=en0on end
        if s==1 then ex=en1x ey=en1y ehp=en1hp eon=en1on end
        if s==2 then ex=en2x ey=en2y ehp=en2hp eon=en2on end
        if s==3 then ex=en3x ey=en3y ehp=en3hp eon=en3on end
        if s==4 then ex=en4x ey=en4y ehp=en4hp eon=en4on end
        if s==5 then ex=en5x ey=en5y ehp=en5hp eon=en5on end
        if s==6 then ex=en6x ey=en6y ehp=en6hp eon=en6on end
        if s==7 then ex=en7x ey=en7y ehp=en7hp eon=en7on end
        if eon == 1 then
            if pb0on==1  and pb0x>ex  and pb0x<ex+24 and pb0y>ey  and pb0y<ey+24 then ehp=ehp-1 pb0on=0  end
            if pb1on==1  and pb1x>ex  and pb1x<ex+24 and pb1y>ey  and pb1y<ey+24 then ehp=ehp-1 pb1on=0  end
            if pb2on==1  and pb2x>ex  and pb2x<ex+24 and pb2y>ey  and pb2y<ey+24 then ehp=ehp-1 pb2on=0  end
            if pb3on==1  and pb3x>ex  and pb3x<ex+24 and pb3y>ey  and pb3y<ey+24 then ehp=ehp-1 pb3on=0  end
            if pb4on==1  and pb4x>ex  and pb4x<ex+24 and pb4y>ey  and pb4y<ey+24 then ehp=ehp-1 pb4on=0  end
            if pb5on==1  and pb5x>ex  and pb5x<ex+24 and pb5y>ey  and pb5y<ey+24 then ehp=ehp-1 pb5on=0  end
            if pb6on==1  and pb6x>ex  and pb6x<ex+24 and pb6y>ey  and pb6y<ey+24 then ehp=ehp-1 pb6on=0  end
            if pb7on==1  and pb7x>ex  and pb7x<ex+24 and pb7y>ey  and pb7y<ey+24 then ehp=ehp-1 pb7on=0  end
            if pb8on==1  and pb8x>ex  and pb8x<ex+24 and pb8y>ey  and pb8y<ey+24 then ehp=ehp-1 pb8on=0  end
            if pb9on==1  and pb9x>ex  and pb9x<ex+24 and pb9y>ey  and pb9y<ey+24 then ehp=ehp-1 pb9on=0  end
            if pb10on==1 and pb10x>ex and pb10x<ex+24 and pb10y>ey and pb10y<ey+24 then ehp=ehp-1 pb10on=0 end
            if pb11on==1 and pb11x>ex and pb11x<ex+24 and pb11y>ey and pb11y<ey+24 then ehp=ehp-1 pb11on=0 end
            if ehp <= 0 then
                eon = 0
                myKills = myKills + 1
                pscore = pscore + 50 + wave * 10
                tone(660, 40, 0.3, 1)
            end
            if s==0 then en0hp=ehp en0on=eon end
            if s==1 then en1hp=ehp en1on=eon end
            if s==2 then en2hp=ehp en2on=eon end
            if s==3 then en3hp=ehp en3on=eon end
            if s==4 then en4hp=ehp en4on=eon end
            if s==5 then en5hp=ehp en5on=eon end
            if s==6 then en6hp=ehp en6on=eon end
            if s==7 then en7hp=ehp en7on=eon end
        end
        s = s + 1
    end
end

func drawEnemy(ex, ey, eon, etype)
    if eon==0 then return end
    let sx=floor(ex) let sy=floor(ey)
    -- TYPE 1: Sniper — narrow purple diamond
    if etype==1 then
        color(180,60,220)
        draw rect(sx+8,sy,8,8)
        draw rect(sx+4,sy+4,16,8)
        draw rect(sx+8,sy+12,8,8)
        color(230,130,255) draw rect(sx+10,sy+8,4,4)
    end
    -- TYPE 2: Spreader — wide teal wedge
    if etype==2 then
        color(40,180,160)
        draw rect(sx,sy+8,24,8)
        draw rect(sx+4,sy+4,16,12)
        draw rect(sx+8,sy,8,16)
        color(120,255,240) draw rect(sx+9,sy+6,6,6)
    end
    -- TYPE 3: Spinner — rotating ring shape (square approximation)
    if etype==3 then
        let pulse=floor(abs(sin(gframe*0.1+ex*0.1))*40)+120
        color(pulse,100,40)
        draw rect(sx,sy,24,4)
        draw rect(sx,sy+20,24,4)
        draw rect(sx,sy,4,24)
        draw rect(sx+20,sy,4,24)
        color(255,180,80) draw rect(sx+8,sy+8,8,8)
        draw rect(sx+10,sy+10,4,4)
    end
    -- TYPE 4: Cross — red X shape
    if etype==4 then
        color(220,40,40)
        draw rect(sx+8,sy,8,24)
        draw rect(sx,sy+8,24,8)
        color(255,120,100) draw rect(sx+10,sy+10,4,4)
        color(180,20,20) draw rect(sx+10,sy,4,24)
        draw rect(sx,sy+10,24,4)
    end
    -- TYPE 5: Burst — yellow zigzagger, looks frantic
    if etype==5 then
        let zz=floor(abs(sin(gframe*0.2+ex))*6)
        color(220,200,20)
        draw rect(sx+zz,sy,8,8)
        draw rect(sx+16-zz,sy+8,8,8)
        draw rect(sx+zz,sy+16,8,8)
        color(255,240,80) draw rect(sx+8,sy+8,8,8)
    end
    -- TYPE 6: Vortex — dark cyan spiral core
    if etype==6 then
        let vp=floor(abs(sin(gframe*0.15+ex*0.05))*30)+80
        color(20,vp,vp+40)
        draw rect(sx+4,sy,16,4)
        draw rect(sx,sy+4,4,16)
        draw rect(sx+4,sy+20,16,4)
        draw rect(sx+20,sy+4,4,16)
        draw rect(sx+8,sy+4,8,16)
        draw rect(sx+4,sy+8,16,8)
        color(80,255,240) draw rect(sx+10,sy+10,4,4)
    end
end

func drawAllEnemies()
    drawEnemy(en0x,en0y,en0on,en0type) drawEnemy(en1x,en1y,en1on,en1type)
    drawEnemy(en2x,en2y,en2on,en2type) drawEnemy(en3x,en3y,en3on,en3type)
    drawEnemy(en4x,en4y,en4on,en4type) drawEnemy(en5x,en5y,en5on,en5type)
    drawEnemy(en6x,en6y,en6on,en6type) drawEnemy(en7x,en7y,en7on,en7type)
end

-- ── Boss firing (deterministic by bossFrame) ──────────────
-- boss fire helpers removed — updateBoss now uses shared fire functions directly

func updateBoss()
    if bossOn==0 then
        bb0on=0 bb1on=0 bb2on=0 bb3on=0 bb4on=0 bb5on=0
        bb6on=0 bb7on=0 bb8on=0 bb9on=0 bb10on=0 bb11on=0
        return
    end
    -- boss position: sine wave (driven by bossFrame from server)
    let t=gframe*0.016
    bossX = 200 + sin(t*0.4)*150
    bossY = 60  + sin(t*0.8)*30

    -- phase
    if bossMaxHp > 0 then
        let pct = bossHp / bossMaxHp
        if pct < 0.25 then bossPhase=2
        elseif pct < 0.6 then bossPhase=1
        else bossPhase=0
        end
    end

    -- fire patterns keyed on gframe (shared = same bullets on all clients)
    let spd=2.2+bossPhase*0.6
    let sangle2 = gframe * 0.07
    if bossPhase==0 then
        -- phase 0: aimed doubles + slow rings
        if gframe%35==0  then fireDouble(bossX+40, bossY+40, spd) end
        if gframe%35==12 then fireDouble(bossX+40, bossY+40, spd) end
        if gframe%70==0  then fireRing(bossX+40, bossY+40, spd*0.8, 8) end
        if gframe%90==45 then fireSpread5(bossX+40, bossY+60, spd) end
    end
    if bossPhase==1 then
        -- phase 1: spinning rings + aimed bursts
        if gframe%8==0   then fireSpiral(bossX+40, bossY+40, spd, sangle2) end
        if gframe%8==0   then fireSpiral(bossX+40, bossY+40, spd, 0-sangle2+3.14) end
        if gframe%40==0  then fireCross(bossX+40, bossY+40, spd*1.2) end
        if gframe%40==10 then fireXcross(bossX+40, bossY+40, spd*1.2) end
        if gframe%55==28 then fireDouble(bossX+40, bossY+40, spd*1.3) end
    end
    if bossPhase==2 then
        -- phase 2: everything at once, very fast
        if gframe%5==0   then fireSpiral(bossX+40, bossY+40, spd*1.2, sangle2) end
        if gframe%5==0   then fireSpiral(bossX+40, bossY+40, spd*1.2, 0-sangle2+3.14) end
        if gframe%25==0  then fireCross(bossX+40, bossY+40, spd*1.4) end
        if gframe%25==6  then fireXcross(bossX+40, bossY+40, spd*1.4) end
        if gframe%20==10 then fireSpread5(bossX+40, bossY+60, spd*1.5) end
        if gframe%30==15 then fireRing(bossX+40, bossY+40, spd, 12) end
    end
end

-- ── Draw ─────────────────────────────────────────────────
func drawBG()
    color(4,6,20) clear()
    let i=0
    while i<50 do
        let sx=floor(abs(sin(i*137.5))*478)+1
        let sy=floor(abs(cos(i*251.3+frame*0.4))*638)%640
        if i<30 then color(60,60,100) draw rect(sx,sy,1,1)
        else color(160,160,210) draw rect(sx,sy,2,2) end
        i=i+1
    end
end

func drawMyShip()
    if pdead==1 then return end
    if pinvince>0 and pinvince%6<3 then return end
    let sx=floor(px) let sy=floor(py)
    let gc=floor(abs(sin(frame*0.3))*80)+80
    color(gc,gc/3,255) draw rect(sx+4,sy+PH,6,5)
    color(80,180,255)  draw rect(sx+2,sy+4,PW-4,PH-4)
    color(200,230,255) draw rect(sx+5,sy,4,6)
    color(40,120,200)  draw rect(sx,sy+8,5,PH-8)
    draw rect(sx+PW-5,sy+8,5,PH-8)
    if keydown(KEY_SHIFT)==1 then
        color(255,80,80) draw rect(sx+PW/2-1,sy+PH/2-1,3,3)
    end
end

func drawOther(ox,oy,ohp,oon)
    if oon==0 then return end
    let sx=floor(ox) let sy=floor(oy)
    if ohp<=0 then
        -- ghost of dead player: faint cross
        color(60,30,30)
        draw line(sx,sy,sx+PW,sy+PH)
        draw line(sx+PW,sy,sx,sy+PH)
        return
    end
    -- "transparent" ship: dim fill + bright outline only
    -- body fill (very dim — simulates transparency)
    color(50,36,10)
    draw rect(sx,sy+4,PW,PH-4)
    -- nose fill
    color(50,46,26)
    draw rect(sx+4,sy,6,6)
    -- bright outline edges (gives shape without opacity)
    color(220,160,50)
    draw rect(sx,    sy+4, PW, 1)        -- top edge
    draw rect(sx,    sy+PH-1, PW, 1)     -- bottom edge
    draw rect(sx,    sy+4, 1, PH-4)      -- left edge
    draw rect(sx+PW-1, sy+4, 1, PH-4)   -- right edge
    -- nose outline
    draw rect(sx+4, sy, 6, 1)
    draw rect(sx+4, sy, 1, 6)
    draw rect(sx+9, sy, 1, 6)
    -- engine glow (dim pulse)
    let gc2=floor(abs(sin(frame*0.3+ox*0.1))*40)+20
    color(gc2, gc2/3, 80)
    draw rect(sx+4, sy+PH, 6, 3)
    -- hp bar above
    color(20,8,8) draw rect(sx-2,sy-6,PW+4,3)
    let hw=floor((ohp/100.0)*(PW+4))
    if hw>0 then
        color(40,160,40) draw rect(sx-2,sy-6,hw,3)
    end
end

func drawAllOthers()
    drawOther(op0x,op0y,op0hp,op0on)
    drawOther(op1x,op1y,op1hp,op1on)
    drawOther(op2x,op2y,op2hp,op2on)
    drawOther(op3x,op3y,op3hp,op3on)
    drawOther(op4x,op4y,op4hp,op4on)
    drawOther(op5x,op5y,op5hp,op5on)
    drawOther(op6x,op6y,op6hp,op6on)
    drawOther(op7x,op7y,op7hp,op7on)
end

func drawBoss()
    if bossOn==0 then return end
    let sx=floor(bossX) let sy=floor(bossY)
    if bossPhase==0 then color(160,40,200) end
    if bossPhase==1 then color(200,40,120) end
    if bossPhase==2 then
        let fc=floor(abs(sin(frame*0.2))*80)+120
        color(fc,20,20)
    end
    draw rect(sx+10,sy,60,80) draw rect(sx,sy+10,80,60)
    color(80,20,100) draw rect(sx-20,sy+20,30,40)
    draw rect(sx+70,sy+20,30,40)
    color(255,255,255) draw rect(sx+30,sy+20,20,20)
    color(20,20,20) draw rect(sx+36,sy+24,8,12)
    color(255,60,60) draw rect(sx+38,sy+26,4,8)
    -- HP bar
    color(40,10,40) draw rect(80,8,320,12)
    let bpct=0
    if bossMaxHp>0 then bpct=floor(bossHp*320/bossMaxHp) end
    if bossPhase==0 then color(160,60,220) end
    if bossPhase==1 then color(220,60,120) end
    if bossPhase==2 then color(255,40,40) end
    if bpct>0 then draw rect(80,8,bpct,12) end
    color(255,255,255) draw text("BOSS",86,10)
end

func drawPB()
    color(180,240,255)
    if pb0on==1  then draw rect(floor(pb0x),  floor(pb0y),  4,10) end
    if pb1on==1  then draw rect(floor(pb1x),  floor(pb1y),  4,10) end
    if pb2on==1  then draw rect(floor(pb2x),  floor(pb2y),  4,10) end
    if pb3on==1  then draw rect(floor(pb3x),  floor(pb3y),  4,10) end
    if pb4on==1  then draw rect(floor(pb4x),  floor(pb4y),  4,10) end
    if pb5on==1  then draw rect(floor(pb5x),  floor(pb5y),  4,10) end
    if pb6on==1  then draw rect(floor(pb6x),  floor(pb6y),  4,10) end
    if pb7on==1  then draw rect(floor(pb7x),  floor(pb7y),  4,10) end
    if pb8on==1  then draw rect(floor(pb8x),  floor(pb8y),  4,10) end
    if pb9on==1  then draw rect(floor(pb9x),  floor(pb9y),  4,10) end
    if pb10on==1 then draw rect(floor(pb10x), floor(pb10y), 4,10) end
    if pb11on==1 then draw rect(floor(pb11x), floor(pb11y), 4,10) end
end

func drawBB()
    let i=0
    while i<24 do
        let bx=0.0 let by=0.0 let bon=0
        if i==0  then bx=bb0x  by=bb0y  bon=bb0on  end
        if i==1  then bx=bb1x  by=bb1y  bon=bb1on  end
        if i==2  then bx=bb2x  by=bb2y  bon=bb2on  end
        if i==3  then bx=bb3x  by=bb3y  bon=bb3on  end
        if i==4  then bx=bb4x  by=bb4y  bon=bb4on  end
        if i==5  then bx=bb5x  by=bb5y  bon=bb5on  end
        if i==6  then bx=bb6x  by=bb6y  bon=bb6on  end
        if i==7  then bx=bb7x  by=bb7y  bon=bb7on  end
        if i==8  then bx=bb8x  by=bb8y  bon=bb8on  end
        if i==9  then bx=bb9x  by=bb9y  bon=bb9on  end
        if i==10 then bx=bb10x by=bb10y bon=bb10on end
        if i==11 then bx=bb11x by=bb11y bon=bb11on end
        if i==12 then bx=bb12x by=bb12y bon=bb12on end
        if i==13 then bx=bb13x by=bb13y bon=bb13on end
        if i==14 then bx=bb14x by=bb14y bon=bb14on end
        if i==15 then bx=bb15x by=bb15y bon=bb15on end
        if i==16 then bx=bb16x by=bb16y bon=bb16on end
        if i==17 then bx=bb17x by=bb17y bon=bb17on end
        if i==18 then bx=bb18x by=bb18y bon=bb18on end
        if i==19 then bx=bb19x by=bb19y bon=bb19on end
        if i==20 then bx=bb20x by=bb20y bon=bb20on end
        if i==21 then bx=bb21x by=bb21y bon=bb21on end
        if i==22 then bx=bb22x by=bb22y bon=bb22on end
        if i==23 then bx=bb23x by=bb23y bon=bb23on end
        if bon==1 then
            color(255,80,80) draw rect(floor(bx)-1,floor(by)-1,6,6)
            color(255,200,200) draw rect(floor(bx)+1,floor(by)+1,2,2)
        end
        i=i+1
    end
end

func drawParticles()
    if pt0l>0 then color(255,200,60) draw rect(floor(pt0x),floor(pt0y),3,3) end
    if pt1l>0 then color(255,140,40) draw rect(floor(pt1x),floor(pt1y),3,3) end
    if pt2l>0 then color(255,220,80) draw rect(floor(pt2x),floor(pt2y),4,4) end
    if pt3l>0 then color(200,100,30) draw rect(floor(pt3x),floor(pt3y),3,3) end
    if pt4l>0 then color(255,180,50) draw rect(floor(pt4x),floor(pt4y),3,3) end
    if pt5l>0 then color(255,100,20) draw rect(floor(pt5x),floor(pt5y),4,4) end
    if pt6l>0 then color(220,200,60) draw rect(floor(pt6x),floor(pt6y),3,3) end
    if pt7l>0 then color(255,240,100) draw rect(floor(pt7x),floor(pt7y),3,3) end
end

func drawHUD()
    -- side bars
    color(0,0,0) draw rect(0,0,40,SH) draw rect(SW-40,0,40,SH)
    color(8,8,24) draw rect(40,0,SW-80,22) draw rect(40,SH-22,SW-80,22)

    -- HP bar (color shifts green->yellow->red)
    color(50,10,10) draw rect(44,SH-18,200,12)
    let hw=floor(php*2) if hw>200 then hw=200 end
    let hcr=40 let hcg=180
    if php <= 60 then hcr=200 hcg=140 end
    if php <= 30 then hcr=180 hcg=40 end
    color(hcr,hcg,40) draw rect(44,SH-18,hw,12)
    color(255,200,200) draw text("HP "+tostr(php),50,SH-17)

    -- score
    color(255,220,50) draw text("SCORE "+tostr(pscore),44,5)

    -- wave
    color(100,220,255) draw text("WAVE "+tostr(wave),210,5)

    -- players online
    color(100,220,100) draw text(tostr(aliveCount)+" ONLINE",320,5)

    -- team score
    color(180,255,180) draw text("TEAM "+tostr(teamScore),44,SH-36)

    -- slot indicator
    color(80,80,150) draw text("P"+tostr(mySlot),SW-34,SH-17)

    -- boss warning pulses on borders
    if bossOn==1 then
        if frame%20<10 then
            color(220,40,40)
            draw rect(40,22,SW-80,4)
            draw rect(40,SH-26,SW-80,4)
        end
        if frame%30<15 then
            color(200,40,40) draw text("!! BOSS FIGHT !!",144,SH-36)
        end
    end

    -- wave clear celebration
    if waveClearing > 0 then
        if waveClearing % 20 < 12 then
            color(60,200,100) draw text("WAVE CLEAR!",176,300)
            color(255,220,50) draw text("TEAM SCORE "+tostr(teamScore),150,326)
        end
        waveClearing = waveClearing - 1
    end

    -- damage flash
    if flashT>0 then
        color(180,40,40) draw rect(40,22,SW-80,SH-44)
        flashT=flashT-1
    end
end

-- ═══════════════════════════════
--  SETUP SCREEN
-- ═══════════════════════════════
let blobSavePath = path_join(scriptParent, "starlance_blob.txt")

func drawSetup()
    drawBG()
    color(0,0,0) draw rect(0,0,SW,SH)
    let si=0
    while si<40 do
        let ssx=floor(abs(sin(si*137.5))*478)+1
        let ssy=floor(abs(cos(si*251.3+frame*0.3))*638)%640
        color(80,80,140) draw rect(ssx,ssy,2,2)
        si=si+1
    end
    color(80,180,255)  draw text("STARLANCE: COOP SURVIVAL",76,80)
    color(180,180,255) draw text("Up to 8 players  |  coop vs waves + boss",64,108)

    if blobId == "" then
        color(255,220,50) draw text("ENTER = create new match",110,200)
        color(160,200,160) draw text("(first player only — share the ID)",94,224)
        color(160,160,200) draw text("or edit starlance_blob.txt with",96,260)
        color(160,160,200) draw text("your friend's blob ID to join theirs",88,280)
    else
        color(100,255,150) draw text("Blob ID found:",130,200)
        color(255,220,80)  draw text(blobId,80,224)
        color(160,200,160) draw text("ENTER = join this match",118,264)
        color(160,160,200) draw text("Share this ID for others to join",94,288)
    end

    color(80,80,120) draw text("WASD/arrows=move  Z/SPACE=shoot",72,380)
    color(80,80,120) draw text("SHIFT=focus  |  boss fights every 3 waves",60,400)
end

-- ── Try loading saved blob ID ─────────────────────────────
if path_exists(blobSavePath)==1 then
    let saved=readFile(blobSavePath)
    if len(saved) > 5 then
        blobId = saved
    end
end

-- Setup loop
let setup=1
while setup==1 do
    frame=frame+1
    if keydown(KEY_ESC)==1 then running=0 setup=0 end

    if keydown(KEY_ENTER)==1 then
        if blobId == "" then
            -- Create new blob
            color(4,6,20) clear()
            color(255,220,50) draw text("Creating match...",150,300)
            sleep(16)
            -- Initial blob state: 8 empty player slots + boss state
            let initData = "{\"phase\":0,\"alive\":0,\"winner\":\"\","
            initData = initData + "\"bon\":0,\"bhp\":500,\"bmhp\":500,\"bph\":0,"
            initData = initData + "\"bx\":200,\"by\":60,\"bframe\":0,\"bnext\":1800,"
            initData = initData + "\"p0on\":0,\"p0x\":220,\"p0y\":540,\"p0hp\":100,\"p0sc\":0,"
            initData = initData + "\"p1on\":0,\"p1x\":240,\"p1y\":540,\"p1hp\":100,\"p1sc\":0,"
            initData = initData + "\"p2on\":0,\"p2x\":200,\"p2y\":520,\"p2hp\":100,\"p2sc\":0,"
            initData = initData + "\"p3on\":0,\"p3x\":260,\"p3y\":520,\"p3hp\":100,\"p3sc\":0,"
            initData = initData + "\"p4on\":0,\"p4x\":180,\"p4y\":500,\"p4hp\":100,\"p4sc\":0,"
            initData = initData + "\"p5on\":0,\"p5x\":280,\"p5y\":500,\"p5hp\":100,\"p5sc\":0,"
            initData = initData + "\"p6on\":0,\"p6x\":160,\"p6y\":540,\"p6hp\":100,\"p6sc\":0,"
            initData = initData + "\"p7on\":0,\"p7x\":300,\"p7y\":540,\"p7hp\":100,\"p7sc\":0,\"wave\":1,\"tscore\":0,\"wcleared\":0}"
            if GIST_TOKEN == "YOUR_GITHUB_TOKEN_HERE" then
                color(255,80,80)  draw text("Edit GIST_TOKEN at the top of",76,320)
                color(255,80,80)  draw text("starlance_br.lol first!",140,340)
                color(180,180,180) draw text("github.com > Settings > Developer",68,368)
                color(180,180,180) draw text("Settings > Personal access tokens",64,386)
                color(180,180,180) draw text("Create token with 'gist' scope only",60,404)
                sleep(3000)
            else
                blobData = jsonSet(blobData, "phase", "1")
                blobData = jsonSet(blobData, "bnext", "1800")
                -- Build Gist creation body safely
                let cp1 = "{\"description\":\"STARLANCE BR\",\"public\":true,\"files\":{\"" 
                let cp2 = "\":{\"content\":" 
                let cp3 = "}}}"
                -- jsonEscape wraps blobData in quotes and escapes inner quotes
                -- so GitHub receives content as a string, not a raw object
                let payload = cp1 + GIST_FILE + cp2 + jsonEscape(blobData) + cp3
                print("=== SENDING TO GITHUB ===")
                print("URL: " + GIST_API)
                print("PAYLOAD: " + payload)
                print("TOKEN PREFIX: " + tostr(len(GIST_TOKEN)) + " chars")
                print("=========================")
                let createResp = httpPostAuth(GIST_API, payload, GIST_TOKEN)
                print("=== GITHUB RESPONSE ===")
                print(createResp)
                print("=======================")
                let bid = jsonGet(createResp, "id")
                if bid ~= "" then
                    blobId = bid
                    writeFile(blobSavePath, bid)
                    setup=0
                    tone(440,80,0.3,0) tone(554,80,0.3,0) tone(659,120,0.5,0)
                else
                    -- Print full response to CMD for easy debugging
                    print("=== GITHUB API RESPONSE ===")
                    print(createResp)
                    print("=== END RESPONSE ===")
                    let errMsg = jsonGet(createResp, "message")
                    color(255,80,80)   draw text("GitHub error (see CMD window):",50,290)
                    color(255,160,160) draw text(errMsg,60,312)
                    color(180,180,180) draw text("Full response printed to CMD",84,340)
                    color(180,180,180) draw text("Check token has gist scope",96,360)
                    sleep(6000)
                end
            end
        else
            -- Join existing match
            -- blobId is just the Gist ID (not a full URL)
            let gistResp = httpGetAuth(GIST_API + "/" + blobId, GIST_TOKEN)
            if gistResp ~= "" then
                -- extract content from {"files":{"starlance_state.json":{"content":"..."}}}
                let content = jsonGet(gistResp, "content")
                if content ~= "" then
                    blobData = content
                    setup=0
                else
                    color(255,80,80) draw text("Gist found but no game data in it",80,340)
                    sleep(2000)
                end
            else
                color(255,80,80) draw text("Could not find Gist: " + blobId,76,340)
                sleep(2000)
            end
        end
    end

    drawSetup()
    sleep(16)
end

if running==0 then
    -- exited from setup
    let dummy=0
else

-- ── Join a slot ───────────────────────────────────────────
joinGame()
px = 200.0 + mySlot * 10.0
py = 540.0
wave = safeNum("wave")
if wave < 1 then wave = 1 end
gframe = safeNum("bframe")   -- sync to server time immediately
enNeeded = 10 + wave * 5
enSpawnCd = 60
tone(440,80,0.3,0) tone(554,80,0.3,0) tone(659,120,0.4,0)

-- ═══════════════════════════════
--  MAIN LOOP
-- ═══════════════════════════════
while running==1 do
    frame=frame+1
    pinvince=pinvince-1 if pinvince<0 then pinvince=0 end
    shootcd=shootcd-1   if shootcd<0  then shootcd=0  end
    netTimer=netTimer+1

    if keydown(KEY_ESC)==1 then
        -- Mark slot as inactive
        if mySlot>=0 then
            blobData = jsonSet(blobData, "p"+tostr(mySlot)+"on", "0")
            fireWrite(blobData)
        end
        running=0
    end

    -- ── Movement ────────────────────────────────────────
    let spd=3.8
    if keydown(KEY_SHIFT)==1 then spd=1.6 end
    if keydown(KEY_LEFT)==1  or keydown(KEY_A)==1 then px=px-spd end
    if keydown(KEY_RIGHT)==1 or keydown(KEY_D)==1 then px=px+spd end
    if keydown(KEY_UP)==1    or keydown(KEY_W)==1 then py=py-spd end
    if keydown(KEY_DN)==1    or keydown(KEY_S)==1 then py=py+spd end
    px=clamp(px,40,SW-40-PW)
    py=clamp(py,22,SH-22-PH)

    -- ── Shoot ───────────────────────────────────────────
    if keydown(KEY_Z)==1 or keydown(KEY_SPC)==1 then
        if shootcd==0 then
            spawnPB(px+PW/2-2,py)
            shootcd=5
            tone(1400,20,0.15,1)
        end
    end

    -- ── Move player bullets ─────────────────────────────
    if pb0on==1  then pb0y=pb0y-12  if pb0y<-10  then pb0on=0  end end
    if pb1on==1  then pb1y=pb1y-12  if pb1y<-10  then pb1on=0  end end
    if pb2on==1  then pb2y=pb2y-12  if pb2y<-10  then pb2on=0  end end
    if pb3on==1  then pb3y=pb3y-12  if pb3y<-10  then pb3on=0  end end
    if pb4on==1  then pb4y=pb4y-12  if pb4y<-10  then pb4on=0  end end
    if pb5on==1  then pb5y=pb5y-12  if pb5y<-10  then pb5on=0  end end
    if pb6on==1  then pb6y=pb6y-12  if pb6y<-10  then pb6on=0  end end
    if pb7on==1  then pb7y=pb7y-12  if pb7y<-10  then pb7on=0  end end
    if pb8on==1  then pb8y=pb8y-12  if pb8y<-10  then pb8on=0  end end
    if pb9on==1  then pb9y=pb9y-12  if pb9y<-10  then pb9on=0  end end
    if pb10on==1 then pb10y=pb10y-12 if pb10y<-10 then pb10on=0 end end
    if pb11on==1 then pb11y=pb11y-12 if pb11y<-10 then pb11on=0 end end

    -- ── Player bullets vs boss ──────────────────────────
    if bossOn==1 then
        if pb0on==1  and pb0x>bossX  and pb0x<bossX+80 and pb0y>bossY  and pb0y<bossY+80 then bossDmg=bossDmg+1 pb0on=0  end
        if pb1on==1  and pb1x>bossX  and pb1x<bossX+80 and pb1y>bossY  and pb1y<bossY+80 then bossDmg=bossDmg+1 pb1on=0  end
        if pb2on==1  and pb2x>bossX  and pb2x<bossX+80 and pb2y>bossY  and pb2y<bossY+80 then bossDmg=bossDmg+1 pb2on=0  end
        if pb3on==1  and pb3x>bossX  and pb3x<bossX+80 and pb3y>bossY  and pb3y<bossY+80 then bossDmg=bossDmg+1 pb3on=0  end
        if pb4on==1  and pb4x>bossX  and pb4x<bossX+80 and pb4y>bossY  and pb4y<bossY+80 then bossDmg=bossDmg+1 pb4on=0  end
        if pb5on==1  and pb5x>bossX  and pb5x<bossX+80 and pb5y>bossY  and pb5y<bossY+80 then bossDmg=bossDmg+1 pb5on=0  end
        if pb6on==1  and pb6x>bossX  and pb6x<bossX+80 and pb6y>bossY  and pb6y<bossY+80 then bossDmg=bossDmg+1 pb6on=0  end
        if pb7on==1  and pb7x>bossX  and pb7x<bossX+80 and pb7y>bossY  and pb7y<bossY+80 then bossDmg=bossDmg+1 pb7on=0  end
        if pb8on==1  and pb8x>bossX  and pb8x<bossX+80 and pb8y>bossY  and pb8y<bossY+80 then bossDmg=bossDmg+1 pb8on=0  end
        if pb9on==1  and pb9x>bossX  and pb9x<bossX+80 and pb9y>bossY  and pb9y<bossY+80 then bossDmg=bossDmg+1 pb9on=0  end
        if pb10on==1 and pb10x>bossX and pb10x<bossX+80 and pb10y>bossY and pb10y<bossY+80 then bossDmg=bossDmg+1 pb10on=0 end
        if pb11on==1 and pb11x>bossX and pb11x<bossX+80 and pb11y>bossY and pb11y<bossY+80 then bossDmg=bossDmg+1 pb11on=0 end
    end

    -- ── Boss update + boss bullets vs player ─────────────
    updateBoss()
    if bb0on==1  then bb0x=bb0x+bb0vx   bb0y=bb0y+bb0vy   if bb0x<-8  or bb0x>SW+8  or bb0y<-8  or bb0y>SH+8  then bb0on=0  end end
    if bb1on==1  then bb1x=bb1x+bb1vx   bb1y=bb1y+bb1vy   if bb1x<-8  or bb1x>SW+8  or bb1y<-8  or bb1y>SH+8  then bb1on=0  end end
    if bb2on==1  then bb2x=bb2x+bb2vx   bb2y=bb2y+bb2vy   if bb2x<-8  or bb2x>SW+8  or bb2y<-8  or bb2y>SH+8  then bb2on=0  end end
    if bb3on==1  then bb3x=bb3x+bb3vx   bb3y=bb3y+bb3vy   if bb3x<-8  or bb3x>SW+8  or bb3y<-8  or bb3y>SH+8  then bb3on=0  end end
    if bb4on==1  then bb4x=bb4x+bb4vx   bb4y=bb4y+bb4vy   if bb4x<-8  or bb4x>SW+8  or bb4y<-8  or bb4y>SH+8  then bb4on=0  end end
    if bb5on==1  then bb5x=bb5x+bb5vx   bb5y=bb5y+bb5vy   if bb5x<-8  or bb5x>SW+8  or bb5y<-8  or bb5y>SH+8  then bb5on=0  end end
    if bb6on==1  then bb6x=bb6x+bb6vx   bb6y=bb6y+bb6vy   if bb6x<-8  or bb6x>SW+8  or bb6y<-8  or bb6y>SH+8  then bb6on=0  end end
    if bb7on==1  then bb7x=bb7x+bb7vx   bb7y=bb7y+bb7vy   if bb7x<-8  or bb7x>SW+8  or bb7y<-8  or bb7y>SH+8  then bb7on=0  end end
    if bb8on==1  then bb8x=bb8x+bb8vx   bb8y=bb8y+bb8vy   if bb8x<-8  or bb8x>SW+8  or bb8y<-8  or bb8y>SH+8  then bb8on=0  end end
    if bb9on==1  then bb9x=bb9x+bb9vx   bb9y=bb9y+bb9vy   if bb9x<-8  or bb9x>SW+8  or bb9y<-8  or bb9y>SH+8  then bb9on=0  end end
    if bb10on==1 then bb10x=bb10x+bb10vx bb10y=bb10y+bb10vy if bb10x<-8 or bb10x>SW+8 or bb10y<-8 or bb10y>SH+8 then bb10on=0 end end
    if bb11on==1 then bb11x=bb11x+bb11vx bb11y=bb11y+bb11vy if bb11x<-8 or bb11x>SW+8 or bb11y<-8 or bb11y>SH+8 then bb11on=0 end end
    if bb12on==1 then bb12x=bb12x+bb12vx bb12y=bb12y+bb12vy if bb12x<-8 or bb12x>SW+8 or bb12y<-8 or bb12y>SH+8 then bb12on=0 end end
    if bb13on==1 then bb13x=bb13x+bb13vx bb13y=bb13y+bb13vy if bb13x<-8 or bb13x>SW+8 or bb13y<-8 or bb13y>SH+8 then bb13on=0 end end
    if bb14on==1 then bb14x=bb14x+bb14vx bb14y=bb14y+bb14vy if bb14x<-8 or bb14x>SW+8 or bb14y<-8 or bb14y>SH+8 then bb14on=0 end end
    if bb15on==1 then bb15x=bb15x+bb15vx bb15y=bb15y+bb15vy if bb15x<-8 or bb15x>SW+8 or bb15y<-8 or bb15y>SH+8 then bb15on=0 end end
    if bb16on==1 then bb16x=bb16x+bb16vx bb16y=bb16y+bb16vy if bb16x<-8 or bb16x>SW+8 or bb16y<-8 or bb16y>SH+8 then bb16on=0 end end
    if bb17on==1 then bb17x=bb17x+bb17vx bb17y=bb17y+bb17vy if bb17x<-8 or bb17x>SW+8 or bb17y<-8 or bb17y>SH+8 then bb17on=0 end end
    if bb18on==1 then bb18x=bb18x+bb18vx bb18y=bb18y+bb18vy if bb18x<-8 or bb18x>SW+8 or bb18y<-8 or bb18y>SH+8 then bb18on=0 end end
    if bb19on==1 then bb19x=bb19x+bb19vx bb19y=bb19y+bb19vy if bb19x<-8 or bb19x>SW+8 or bb19y<-8 or bb19y>SH+8 then bb19on=0 end end
    if bb20on==1 then bb20x=bb20x+bb20vx bb20y=bb20y+bb20vy if bb20x<-8 or bb20x>SW+8 or bb20y<-8 or bb20y>SH+8 then bb20on=0 end end
    if bb21on==1 then bb21x=bb21x+bb21vx bb21y=bb21y+bb21vy if bb21x<-8 or bb21x>SW+8 or bb21y<-8 or bb21y>SH+8 then bb21on=0 end end
    if bb22on==1 then bb22x=bb22x+bb22vx bb22y=bb22y+bb22vy if bb22x<-8 or bb22x>SW+8 or bb22y<-8 or bb22y>SH+8 then bb22on=0 end end
    if bb23on==1 then bb23x=bb23x+bb23vx bb23y=bb23y+bb23vy if bb23x<-8 or bb23x>SW+8 or bb23y<-8 or bb23y>SH+8 then bb23on=0 end end

    -- Boss bullets hit player (tight 6x6 hitbox)
    if pinvince==0 then
        let hx=px+PW/2-3 let hy=py+PH/2-3
        if bb0on==1  and bb0x>hx  and bb0x<hx+6  and bb0y>hy  and bb0y<hy+6  then php=php-10 pinvince=60 flashT=3 bb0on=0  tone(200,60,0.5,2) end
        if bb1on==1  and bb1x>hx  and bb1x<hx+6  and bb1y>hy  and bb1y<hy+6  then php=php-10 pinvince=60 flashT=3 bb1on=0  tone(200,60,0.5,2) end
        if bb2on==1  and bb2x>hx  and bb2x<hx+6  and bb2y>hy  and bb2y<hy+6  then php=php-10 pinvince=60 flashT=3 bb2on=0  tone(200,60,0.5,2) end
        if bb3on==1  and bb3x>hx  and bb3x<hx+6  and bb3y>hy  and bb3y<hy+6  then php=php-10 pinvince=60 flashT=3 bb3on=0  tone(200,60,0.5,2) end
        if bb4on==1  and bb4x>hx  and bb4x<hx+6  and bb4y>hy  and bb4y<hy+6  then php=php-10 pinvince=60 flashT=3 bb4on=0  tone(200,60,0.5,2) end
        if bb5on==1  and bb5x>hx  and bb5x<hx+6  and bb5y>hy  and bb5y<hy+6  then php=php-10 pinvince=60 flashT=3 bb5on=0  tone(200,60,0.5,2) end
        if bb6on==1  and bb6x>hx  and bb6x<hx+6  and bb6y>hy  and bb6y<hy+6  then php=php-10 pinvince=60 flashT=3 bb6on=0  tone(200,60,0.5,2) end
        if bb7on==1  and bb7x>hx  and bb7x<hx+6  and bb7y>hy  and bb7y<hy+6  then php=php-10 pinvince=60 flashT=3 bb7on=0  tone(200,60,0.5,2) end
        if bb8on==1  and bb8x>hx  and bb8x<hx+6  and bb8y>hy  and bb8y<hy+6  then php=php-10 pinvince=60 flashT=3 bb8on=0  tone(200,60,0.5,2) end
        if bb9on==1  and bb9x>hx  and bb9x<hx+6  and bb9y>hy  and bb9y<hy+6  then php=php-10 pinvince=60 flashT=3 bb9on=0  tone(200,60,0.5,2) end
        if bb10on==1 and bb10x>hx and bb10x<hx+6 and bb10y>hy and bb10y<hy+6 then php=php-10 pinvince=60 flashT=3 bb10on=0 tone(200,60,0.5,2) end
        if bb11on==1 and bb11x>hx and bb11x<hx+6 and bb11y>hy and bb11y<hy+6 then php=php-10 pinvince=60 flashT=3 bb11on=0 tone(200,60,0.5,2) end
        if bb12on==1 and bb12x>hx and bb12x<hx+6 and bb12y>hy and bb12y<hy+6 then php=php-10 pinvince=60 flashT=3 bb12on=0 tone(200,60,0.5,2) end
        if bb13on==1 and bb13x>hx and bb13x<hx+6 and bb13y>hy and bb13y<hy+6 then php=php-10 pinvince=60 flashT=3 bb13on=0 tone(200,60,0.5,2) end
        if bb14on==1 and bb14x>hx and bb14x<hx+6 and bb14y>hy and bb14y<hy+6 then php=php-10 pinvince=60 flashT=3 bb14on=0 tone(200,60,0.5,2) end
        if bb15on==1 and bb15x>hx and bb15x<hx+6 and bb15y>hy and bb15y<hy+6 then php=php-10 pinvince=60 flashT=3 bb15on=0 tone(200,60,0.5,2) end
    end
    if php < 0 then php = 0 end
    -- Coop respawn: when you die, wait 5 seconds then respawn with 50hp
    if php == 0 and pdead == 0 then
        pdead = 1
        pinvince = 300   -- 5 seconds of death/respawn time
        burst(px+PW/2, py+PH/2)
        beep(200,30) beep(140,40) beep(90,50)
        tone(180,120,0.5,2)
    end
    if pdead == 1 and pinvince == 1 then
        -- Respawn
        pdead = 0
        php   = 50
        px    = 200.0 + mySlot * 10.0
        py    = 540.0
        tone(523,80,0.4,0) tone(659,120,0.5,0)
    end

    -- Particles
    if pt0l>0 then pt0x=pt0x+pt0vx pt0y=pt0y+pt0vy pt0vy=pt0vy+0.1 pt0l=pt0l-1 end
    if pt1l>0 then pt1x=pt1x+pt1vx pt1y=pt1y+pt1vy pt1vy=pt1vy+0.1 pt1l=pt1l-1 end
    if pt2l>0 then pt2x=pt2x+pt2vx pt2y=pt2y+pt2vy pt2vy=pt2vy+0.1 pt2l=pt2l-1 end
    if pt3l>0 then pt3x=pt3x+pt3vx pt3y=pt3y+pt3vy pt3vy=pt3vy+0.1 pt3l=pt3l-1 end
    if pt4l>0 then pt4x=pt4x+pt4vx pt4y=pt4y+pt4vy pt4vy=pt4vy+0.1 pt4l=pt4l-1 end
    if pt5l>0 then pt5x=pt5x+pt5vx pt5y=pt5y+pt5vy pt5vy=pt5vy+0.1 pt5l=pt5l-1 end
    if pt6l>0 then pt6x=pt6x+pt6vx pt6y=pt6y+pt6vy pt6vy=pt6vy+0.1 pt6l=pt6l-1 end
    if pt7l>0 then pt7x=pt7x+pt7vx pt7y=pt7y+pt7vy pt7vy=pt7vy+0.1 pt7l=pt7l-1 end

    -- ── Enemies (client-side, deterministic) ───────────────
    trySpawnWaveEnemy()
    updateAllEnemies()
    checkPBvsEnemies()

    -- ── Wave advance (slot 0 writes, everyone reads) ─────
    if mySlot == 0 then
        let killsNeeded = 10 + wave * 5
        let waveKills = tonum(jsonGet(blobData, "wkills"))
        if myKills > 0 then
            blobData = jsonSet(blobData, "wkills", tostr(waveKills + myKills))
            waveKills = waveKills + myKills
        end
        if waveKills >= killsNeeded and bossOn == 0 then
            wave = wave + 1
            blobData = jsonSet(blobData, "wave",   tostr(wave))
            blobData = jsonSet(blobData, "wkills", "0")
            -- boss every 3 waves
            if wave % 3 == 0 then
                blobData = jsonSet(blobData, "bnext", tostr(gframe + 120))
            end
            waveClearing = 80
            chord(523, 659, 784, 400, 0.4)
        end
    end

    -- ── Network sync ─────────────────────────────────────
    if netTimer >= NET_RATE then
        netTimer=0
        pushMyState()
    end
    pullState()

    -- ── Render ──────────────────────────────────────────
    drawBG()
    drawAllOthers()
    drawAllEnemies()
    drawBoss()
    drawBB()
    drawParticles()
    drawPB()
    drawMyShip()
    drawHUD()
    sleep(16)
end

end  -- end running check
