-- mode:window
-- ============================================================
--  TURBODASH  -  endless momentum platformer
--  Pizza Tower inspired: build speed, wall jump, combo system
--
--  LEFT/RIGHT  = move          SHIFT = dash
--  SPACE/UP    = jump          DOWN  = dive / ground pound
--  Z           = attack        ESC   = pause
-- ============================================================

window("TURBODASH", 480, 320)

-- ── Keys ─────────────────────────────────────────────────
let KEY_LEFT=37  let KEY_RIGHT=39  let KEY_UP=38    let KEY_DN=40
let KEY_A=65     let KEY_D=68      let KEY_W=87     let KEY_S=83
let KEY_SPACE=32 let KEY_SHIFT=16  let KEY_Z=90     let KEY_ESC=27

-- ── Screen ───────────────────────────────────────────────
let SW=480 let SH=320

-- ── Physics constants ────────────────────────────────────
let GRAV       = 0.52
let MAXFALL    = 14.0
let WALKACC    = 0.9    -- ground acceleration
let RUNTACC    = 1.4    -- run acceleration (held dir)
let FRICTION   = 0.72   -- ground friction
let AIRFRIC    = 0.94   -- air friction
let JUMPFORCE  = 9.8
let WALLJUMP_X = 5.5
let WALLJUMP_Y = 8.5
let DASHSPD    = 11.0
let MAXSPD     = 9.0    -- walk cap
let MAXRUNSPD  = 16.0   -- run cap (momentum carries past walk)
let TSIZE      = 24     -- tile size px
let COLS       = 22     -- visible cols (480/24 = 20 + 2 offscreen)
let ROWS       = 13     -- visible rows (320/24 ~= 13)

-- ── World ────────────────────────────────────────────────
-- Map is 80 tiles wide, 13 rows, scrolls horizontally
-- Stored as 13 row-integers (bitmasks, 80 bits each)
-- We use pairs of 32-bit ints per row: rowL (cols 0-31) rowR (cols 32-79)
-- isSolid(col, row) checks the correct half

let MWIDTH = 80

-- Row data: 13 rows × 2 halves = 26 variables
-- Generated procedurally on start
let mr0L=0  let mr0R=0
let mr1L=0  let mr1R=0
let mr2L=0  let mr2R=0
let mr3L=0  let mr3R=0
let mr4L=0  let mr4R=0
let mr5L=0  let mr5R=0
let mr6L=0  let mr6R=0
let mr7L=0  let mr7R=0
let mr8L=0  let mr8R=0
let mr9L=0  let mr9R=0
let mr10L=0 let mr10R=0
let mr11L=0 let mr11R=0
let mr12L=0 let mr12R=0

-- ── Camera ───────────────────────────────────────────────
let camX=0.0    -- pixel offset, smoothed
let camTarget=0.0

-- ── Player ───────────────────────────────────────────────
let px=60.0  let py=200.0
let pvx=0.0  let pvy=0.0
let PW=14    let PH=22
let facing=1        -- 1=right -1=left
let onGround=0
let onWall=0        -- -1=left wall 1=right wall 0=none
let coyote=0
let jumpHeld=0
let runTime=0       -- frames held same direction (builds momentum)
let dashCd=0
let dashing=0
let dashTimer=0
let diveCd=0
let groundPounding=0
let wallSlide=0
let wallSlideTimer=0
let comboCount=0
let comboTimer=0
let attackCd=0
let attackTimer=0
let hitEnemy=0      -- flash timer

-- Speed tier (visual feedback)
-- 0=walk 1=jog 2=run 3=sprint 4=turbo
let speedTier=0
let tilesPassed=0   -- score
let distance=0.0    -- total px scrolled

-- ── Particles (24 slots) ─────────────────────────────────
let pt0x=0.0 let pt0y=0.0 let pt0vx=0.0 let pt0vy=0.0 let pt0l=0 let pt0r=0 let pt0g=0 let pt0b=0
let pt1x=0.0 let pt1y=0.0 let pt1vx=0.0 let pt1vy=0.0 let pt1l=0 let pt1r=0 let pt1g=0 let pt1b=0
let pt2x=0.0 let pt2y=0.0 let pt2vx=0.0 let pt2vy=0.0 let pt2l=0 let pt2r=0 let pt2g=0 let pt2b=0
let pt3x=0.0 let pt3y=0.0 let pt3vx=0.0 let pt3vy=0.0 let pt3l=0 let pt3r=0 let pt3g=0 let pt3b=0
let pt4x=0.0 let pt4y=0.0 let pt4vx=0.0 let pt4vy=0.0 let pt4l=0 let pt4r=0 let pt4g=0 let pt4b=0
let pt5x=0.0 let pt5y=0.0 let pt5vx=0.0 let pt5vy=0.0 let pt5l=0 let pt5r=0 let pt5g=0 let pt5b=0
let pt6x=0.0 let pt6y=0.0 let pt6vx=0.0 let pt6vy=0.0 let pt6l=0 let pt6r=0 let pt6g=0 let pt6b=0
let pt7x=0.0 let pt7y=0.0 let pt7vx=0.0 let pt7vy=0.0 let pt7l=0 let pt7r=0 let pt7g=0 let pt7b=0
let pt8x=0.0 let pt8y=0.0 let pt8vx=0.0 let pt8vy=0.0 let pt8l=0 let pt8r=0 let pt8g=0 let pt8b=0
let pt9x=0.0 let pt9y=0.0 let pt9vx=0.0 let pt9vy=0.0 let pt9l=0 let pt9r=0 let pt9g=0 let pt9b=0
let pt10x=0.0 let pt10y=0.0 let pt10vx=0.0 let pt10vy=0.0 let pt10l=0 let pt10r=0 let pt10g=0 let pt10b=0
let pt11x=0.0 let pt11y=0.0 let pt11vx=0.0 let pt11vy=0.0 let pt11l=0 let pt11r=0 let pt11g=0 let pt11b=0
let pt12x=0.0 let pt12y=0.0 let pt12vx=0.0 let pt12vy=0.0 let pt12l=0 let pt12r=0 let pt12g=0 let pt12b=0
let pt13x=0.0 let pt13y=0.0 let pt13vx=0.0 let pt13vy=0.0 let pt13l=0 let pt13r=0 let pt13g=0 let pt13b=0
let pt14x=0.0 let pt14y=0.0 let pt14vx=0.0 let pt14vy=0.0 let pt14l=0 let pt14r=0 let pt14g=0 let pt14b=0
let pt15x=0.0 let pt15y=0.0 let pt15vx=0.0 let pt15vy=0.0 let pt15l=0 let pt15r=0 let pt15g=0 let pt15b=0
let pt16x=0.0 let pt16y=0.0 let pt16vx=0.0 let pt16vy=0.0 let pt16l=0 let pt16r=0 let pt16g=0 let pt16b=0
let pt17x=0.0 let pt17y=0.0 let pt17vx=0.0 let pt17vy=0.0 let pt17l=0 let pt17r=0 let pt17g=0 let pt17b=0
let pt18x=0.0 let pt18y=0.0 let pt18vx=0.0 let pt18vy=0.0 let pt18l=0 let pt18r=0 let pt18g=0 let pt18b=0
let pt19x=0.0 let pt19y=0.0 let pt19vx=0.0 let pt19vy=0.0 let pt19l=0 let pt19r=0 let pt19g=0 let pt19b=0
let pt20x=0.0 let pt20y=0.0 let pt20vx=0.0 let pt20vy=0.0 let pt20l=0 let pt20r=0 let pt20g=0 let pt20b=0
let pt21x=0.0 let pt21y=0.0 let pt21vx=0.0 let pt21vy=0.0 let pt21l=0 let pt21r=0 let pt21g=0 let pt21b=0
let pt22x=0.0 let pt22y=0.0 let pt22vx=0.0 let pt22vy=0.0 let pt22l=0 let pt22r=0 let pt22g=0 let pt22b=0
let pt23x=0.0 let pt23y=0.0 let pt23vx=0.0 let pt23vy=0.0 let pt23l=0 let pt23r=0 let pt23g=0 let pt23b=0

-- ── Enemies (12 slots) ───────────────────────────────────
let en0x=0.0 let en0y=0.0 let en0vx=0.0 let en0hp=0 let en0on=0 let en0type=0 let en0t=0
let en1x=0.0 let en1y=0.0 let en1vx=0.0 let en1hp=0 let en1on=0 let en1type=0 let en1t=0
let en2x=0.0 let en2y=0.0 let en2vx=0.0 let en2hp=0 let en2on=0 let en2type=0 let en2t=0
let en3x=0.0 let en3y=0.0 let en3vx=0.0 let en3hp=0 let en3on=0 let en3type=0 let en3t=0
let en4x=0.0 let en4y=0.0 let en4vx=0.0 let en4hp=0 let en4on=0 let en4type=0 let en4t=0
let en5x=0.0 let en5y=0.0 let en5vx=0.0 let en5hp=0 let en5on=0 let en5type=0 let en5t=0
let en6x=0.0 let en6y=0.0 let en6vx=0.0 let en6hp=0 let en6on=0 let en6type=0 let en6t=0
let en7x=0.0 let en7y=0.0 let en7vx=0.0 let en7hp=0 let en7on=0 let en7type=0 let en7t=0
let en8x=0.0 let en8y=0.0 let en8vx=0.0 let en8hp=0 let en8on=0 let en8type=0 let en8t=0
let en9x=0.0 let en9y=0.0 let en9vx=0.0 let en9hp=0 let en9on=0 let en9type=0 let en9t=0
let en10x=0.0 let en10y=0.0 let en10vx=0.0 let en10hp=0 let en10on=0 let en10type=0 let en10t=0
let en11x=0.0 let en11y=0.0 let en11vx=0.0 let en11hp=0 let en11on=0 let en11type=0 let en11t=0

-- ── Collectibles (8 slots) ───────────────────────────────
-- type 1=coin 2=gem 3=speed boost
let co0x=0.0 let co0y=0.0 let co0on=0 let co0type=0
let co1x=0.0 let co1y=0.0 let co1on=0 let co1type=0
let co2x=0.0 let co2y=0.0 let co2on=0 let co2type=0
let co3x=0.0 let co3y=0.0 let co3on=0 let co3type=0
let co4x=0.0 let co4y=0.0 let co4on=0 let co4type=0
let co5x=0.0 let co5y=0.0 let co5on=0 let co5type=0
let co6x=0.0 let co6y=0.0 let co6on=0 let co6type=0
let co7x=0.0 let co7y=0.0 let co7on=0 let co7type=0

-- ── Game state ───────────────────────────────────────────
let frame=0    let running=1
let gameState=0  -- 0=title 1=playing 2=dead 3=paused
let score=0    let hiScore=0
let lives=3    let hp=3   let maxHp=3
let speedBoost=0  -- frames of speed boost remaining
let screenShake=0

-- ── Procedural generation seed ────────────────────────────
let genSeed=0    -- dedicated world-gen seed (function of worldX only)
let effectSeed=0 -- separate seed for particles, enemies, collectibles
let worldX=0    -- how many tile columns have passed

-- ── Helpers ──────────────────────────────────────────────
func clamp(v,lo,hi)
    if v<lo then return lo end
    if v>hi then return hi end
    return v
end

-- rnd: for particles, enemies, collectibles — uses effectSeed
func rnd(lo,hi)
    let r=abs(sin(effectSeed*137.5+frame*0.07+lo*31.1))
    effectSeed=effectSeed+1
    return lo+floor(r*(hi-lo+1))
end

-- worldRnd: pure deterministic function of col+worldX only
-- same col always produces the same output regardless of frame or other rng calls
func worldRnd(col, slot)
    let seed = (col + worldX*0.001) * 7919.0 + slot * 1999.0
    return abs(sin(seed * 0.001 + cos(seed * 0.0007)))
end

-- worldRndInt(col, slot, lo, hi) — integer in [lo,hi]
func worldRndInt(col, slot, lo, hi)
    let r = worldRnd(col, slot)
    return lo + floor(r * (hi - lo + 1))
end

func pow2(n)
    if n==0  then return 1 end        if n==1  then return 2 end
    if n==2  then return 4 end        if n==3  then return 8 end
    if n==4  then return 16 end       if n==5  then return 32 end
    if n==6  then return 64 end       if n==7  then return 128 end
    if n==8  then return 256 end      if n==9  then return 512 end
    if n==10 then return 1024 end     if n==11 then return 2048 end
    if n==12 then return 4096 end     if n==13 then return 8192 end
    if n==14 then return 16384 end    if n==15 then return 32768 end
    if n==16 then return 65536 end    if n==17 then return 131072 end
    if n==18 then return 262144 end   if n==19 then return 524288 end
    if n==20 then return 1048576 end  if n==21 then return 2097152 end
    if n==22 then return 4194304 end  if n==23 then return 8388608 end
    if n==24 then return 16777216 end if n==25 then return 33554432 end
    if n==26 then return 67108864 end if n==27 then return 134217728 end
    if n==28 then return 268435456 end if n==29 then return 536870912 end
    return 1073741824
end

-- Get/set a bit in a row half
func getRowHalf(row, half)
    if half==0 then
        if row==0  then return mr0L  end if row==1  then return mr1L  end
        if row==2  then return mr2L  end if row==3  then return mr3L  end
        if row==4  then return mr4L  end if row==5  then return mr5L  end
        if row==6  then return mr6L  end if row==7  then return mr7L  end
        if row==8  then return mr8L  end if row==9  then return mr9L  end
        if row==10 then return mr10L end if row==11 then return mr11L end
        return mr12L
    end
    if row==0  then return mr0R  end if row==1  then return mr1R  end
    if row==2  then return mr2R  end if row==3  then return mr3R  end
    if row==4  then return mr4R  end if row==5  then return mr5R  end
    if row==6  then return mr6R  end if row==7  then return mr7R  end
    if row==8  then return mr8R  end if row==9  then return mr9R  end
    if row==10 then return mr10R end if row==11 then return mr11R end
    return mr12R
end

func setRowHalf(row, half, val)
    if half==0 then
        if row==0  then mr0L=val  return end if row==1  then mr1L=val  return end
        if row==2  then mr2L=val  return end if row==3  then mr3L=val  return end
        if row==4  then mr4L=val  return end if row==5  then mr5L=val  return end
        if row==6  then mr6L=val  return end if row==7  then mr7L=val  return end
        if row==8  then mr8L=val  return end if row==9  then mr9L=val  return end
        if row==10 then mr10L=val return end if row==11 then mr11L=val return end
        mr12L=val return
    end
    if row==0  then mr0R=val  return end if row==1  then mr1R=val  return end
    if row==2  then mr2R=val  return end if row==3  then mr3R=val  return end
    if row==4  then mr4R=val  return end if row==5  then mr5R=val  return end
    if row==6  then mr6R=val  return end if row==7  then mr7R=val  return end
    if row==8  then mr8R=val  return end if row==9  then mr9R=val  return end
    if row==10 then mr10R=val return end if row==11 then mr11R=val return end
    mr12R=val
end

func isSolid(col, row)
    if row<0 then return 0 end
    if row>=ROWS then return 1 end
    if col<0 then return 1 end
    if col>=MWIDTH then return 0 end
    let half=0 let c=col
    if col>=32 then half=1 c=col-32 end
    let rv=getRowHalf(floor(row), half)
    let pw=pow2(floor(c))
    let sh=floor(rv/pw)
    return sh - floor(sh/2)*2
end

func setBit(col, row, val)
    if row<0 or row>=ROWS then return end
    if col<0 or col>=MWIDTH then return end
    let half=0 let c=col
    if col>=32 then half=1 c=col-32 end
    let rv=getRowHalf(row, half)
    let pw=pow2(c)
    let cur=floor(rv/pw) - floor(floor(rv/pw)/2)*2
    if val==1 and cur==0 then rv=rv+pw end
    if val==0 and cur==1 then rv=rv-pw end
    setRowHalf(row, half, rv)
end

-- Solid at pixel coords (world space)
func solidAtW(wx, wy)
    return isSolid(floor(wx/TSIZE), floor(wy/TSIZE))
end

-- ── Procedural level generator ────────────────────────────
-- Generates in chunks of 8 columns at a time
-- Patterns: flat run, gap, pit, platform staircase, ceiling run, tunnel

let genCol=0     -- next column to generate
let floorY=11    -- current floor row (10-12)
let ceilY=0      -- ceiling row (-1=none, otherwise 0-3)
let runLen=0     -- current pattern run remaining
let patType=0    -- current pattern type
let lastPlatY=8  -- last floating platform row

func clearColumn(col)
    let r=0
    while r<ROWS do
        setBit(col, r, 0)
        r=r+1
    end
end

func solidColumn(col, fromRow, toRow)
    let r=fromRow
    while r<=toRow do
        setBit(col, r, 1)
        r=r+1
    end
end

func genNextColumn()
    if genCol >= MWIDTH then return end
    let col=genCol
    clearColumn(col)

    -- Always solid walls on left/right edge cols
    if col==0 or col==1 then
        solidColumn(col, 0, ROWS-1)
        genCol=genCol+1
        return
    end

    -- Start new pattern if run exhausted
    -- All decisions are pure functions of genCol so same column = same result
    if runLen<=0 then
        patType=worldRndInt(genCol, 0, 0, 5)
        runLen=worldRndInt(genCol, 1, 4, 10)
        let delta=worldRndInt(genCol, 2, 0, 2)-1
        floorY=clamp(floorY+delta, 9, 12)
        ceilY=-1
        if patType==4 then ceilY=worldRndInt(genCol, 3, 1, 3) end
    end
    runLen=runLen-1

    -- Floor
    solidColumn(col, floorY, ROWS-1)

    -- Ceiling if tunnel
    if ceilY>=0 then
        solidColumn(col, 0, ceilY)
    end

    -- Pattern: gap (no floor for 2-3 cols mid-run)
    if patType==1 and runLen>=2 and runLen<=4 then
        clearColumn(col)
        -- make sure sides are closed
        if floorY>10 then floorY=10 end
    end

    -- Pattern: floating platforms staircase
    if patType==2 then
        let platRow=worldRndInt(genCol, 4, 3, 9)
        lastPlatY=platRow
        setBit(col,   platRow, 1)
        setBit(col+1, platRow, 1)
        setBit(col+2, platRow, 1)
    end

    -- Pattern: tall wall to wall-jump over (2-col pillar)
    if patType==3 and (runLen==4 or runLen==5) then
        solidColumn(col, floorY-5, floorY)
    end

    -- Decor: raised floor bumps
    if patType==5 then
        if runLen%3==0 then setBit(col, floorY-1, 1) end
    end

    genCol=genCol+1
end

func generateWorld()
    -- Fill entire map
    -- world seed is purely positional — no frame/score dependency
    genSeed=0
    let c=0
    while c<MWIDTH do
        genNextColumn()
        c=c+1
    end
end

-- ── Scroll: regenerate right edge as camera moves ─────────
func scrollWorld(tilesMoved)
    -- shift all rows left by tilesMoved cols
    -- (we regenerate the rightmost tilesMoved columns fresh)
    -- For now: complete regen when we've passed enough tiles
    -- (full regen is cheap — 80 cols takes <1ms)
    if tilesMoved <= 0 then return end
    -- worldX advances first so worldRnd sees correct position during regen
    worldX=worldX+tilesMoved
    -- shift map data left
    let shamt=tilesMoved
    let r=0
    while r<ROWS do
        let newL=0 let newR=0
        -- extract bits shamt..31 from L into positions 0..31-shamt
        let rv=getRowHalf(r,0)
        -- shift right by shamt
        newL=floor(rv/pow2(shamt))
        -- bring in bits from R to fill high bits of L
        let rvR=getRowHalf(r,1)
        let bitsFromR=rvR - floor(rvR/pow2(32-shamt))*pow2(32-shamt)
        newL=newL + bitsFromR*pow2(32-shamt)
        -- shift R similarly (R only has 48 cols mapped: cols 32-79)
        newR=floor(rvR/pow2(shamt))
        setRowHalf(r, 0, newL)
        setRowHalf(r, 1, newR)
        r=r+1
    end
    -- regenerate rightmost shamt columns
    genCol=MWIDTH-shamt
    let c=0
    while c<shamt do
        genNextColumn()
        c=c+1
    end
end

-- ── Particles ────────────────────────────────────────────
func spawnPart(x,y,vx,vy,life,r,g,b)
    if pt0l==0  then pt0x=x  pt0y=y  pt0vx=vx  pt0vy=vy  pt0l=life pt0r=r pt0g=g pt0b=b return end
    if pt1l==0  then pt1x=x  pt1y=y  pt1vx=vx  pt1vy=vy  pt1l=life pt1r=r pt1g=g pt1b=b return end
    if pt2l==0  then pt2x=x  pt2y=y  pt2vx=vx  pt2vy=vy  pt2l=life pt2r=r pt2g=g pt2b=b return end
    if pt3l==0  then pt3x=x  pt3y=y  pt3vx=vx  pt3vy=vy  pt3l=life pt3r=r pt3g=g pt3b=b return end
    if pt4l==0  then pt4x=x  pt4y=y  pt4vx=vx  pt4vy=vy  pt4l=life pt4r=r pt4g=g pt4b=b return end
    if pt5l==0  then pt5x=x  pt5y=y  pt5vx=vx  pt5vy=vy  pt5l=life pt5r=r pt5g=g pt5b=b return end
    if pt6l==0  then pt6x=x  pt6y=y  pt6vx=vx  pt6vy=vy  pt6l=life pt6r=r pt6g=g pt6b=b return end
    if pt7l==0  then pt7x=x  pt7y=y  pt7vx=vx  pt7vy=vy  pt7l=life pt7r=r pt7g=g pt7b=b return end
    if pt8l==0  then pt8x=x  pt8y=y  pt8vx=vx  pt8vy=vy  pt8l=life pt8r=r pt8g=g pt8b=b return end
    if pt9l==0  then pt9x=x  pt9y=y  pt9vx=vx  pt9vy=vy  pt9l=life pt9r=r pt9g=g pt9b=b return end
    if pt10l==0 then pt10x=x pt10y=y pt10vx=vx pt10vy=vy pt10l=life pt10r=r pt10g=g pt10b=b return end
    if pt11l==0 then pt11x=x pt11y=y pt11vx=vx pt11vy=vy pt11l=life pt11r=r pt11g=g pt11b=b return end
    if pt12l==0 then pt12x=x pt12y=y pt12vx=vx pt12vy=vy pt12l=life pt12r=r pt12g=g pt12b=b return end
    if pt13l==0 then pt13x=x pt13y=y pt13vx=vx pt13vy=vy pt13l=life pt13r=r pt13g=g pt13b=b return end
    if pt14l==0 then pt14x=x pt14y=y pt14vx=vx pt14vy=vy pt14l=life pt14r=r pt14g=g pt14b=b return end
    if pt15l==0 then pt15x=x pt15y=y pt15vx=vx pt15vy=vy pt15l=life pt15r=r pt15g=g pt15b=b return end
    if pt16l==0 then pt16x=x pt16y=y pt16vx=vx pt16vy=vy pt16l=life pt16r=r pt16g=g pt16b=b return end
    if pt17l==0 then pt17x=x pt17y=y pt17vx=vx pt17vy=vy pt17l=life pt17r=r pt17g=g pt17b=b return end
    if pt18l==0 then pt18x=x pt18y=y pt18vx=vx pt18vy=vy pt18l=life pt18r=r pt18g=g pt18b=b return end
    if pt19l==0 then pt19x=x pt19y=y pt19vx=vx pt19vy=vy pt19l=life pt19r=r pt19g=g pt19b=b return end
    if pt20l==0 then pt20x=x pt20y=y pt20vx=vx pt20vy=vy pt20l=life pt20r=r pt20g=g pt20b=b return end
    if pt21l==0 then pt21x=x pt21y=y pt21vx=vx pt21vy=vy pt21l=life pt21r=r pt21g=g pt21b=b return end
    if pt22l==0 then pt22x=x pt22y=y pt22vx=vx pt22vy=vy pt22l=life pt22r=r pt22g=g pt22b=b return end
    if pt23l==0 then pt23x=x pt23y=y pt23vx=vx pt23vy=vy pt23l=life pt23r=r pt23g=g pt23b=b return end
end

func spawnDust(x,y)
    spawnPart(x,y, rnd(0,3)-1, 0-rnd(0,2), 10, 200,180,140)
    spawnPart(x,y, rnd(0,3)-1, 0-rnd(0,2), 8,  180,160,120)
end

func spawnSpeedTrail(x,y,spd)
    let r=80+floor(abs(spd)*8)
    if r>255 then r=255 end
    spawnPart(x,y, 0-spd*0.3, rnd(0,1)-0, 6, r, floor(r*0.4), 20)
end

func moveParticles()
    if pt0l>0  then pt0x=pt0x+pt0vx  pt0y=pt0y+pt0vy  pt0vy=pt0vy+0.15 pt0l=pt0l-1 end
    if pt1l>0  then pt1x=pt1x+pt1vx  pt1y=pt1y+pt1vy  pt1vy=pt1vy+0.15 pt1l=pt1l-1 end
    if pt2l>0  then pt2x=pt2x+pt2vx  pt2y=pt2y+pt2vy  pt2vy=pt2vy+0.15 pt2l=pt2l-1 end
    if pt3l>0  then pt3x=pt3x+pt3vx  pt3y=pt3y+pt3vy  pt3vy=pt3vy+0.15 pt3l=pt3l-1 end
    if pt4l>0  then pt4x=pt4x+pt4vx  pt4y=pt4y+pt4vy  pt4vy=pt4vy+0.15 pt4l=pt4l-1 end
    if pt5l>0  then pt5x=pt5x+pt5vx  pt5y=pt5y+pt5vy  pt5vy=pt5vy+0.15 pt5l=pt5l-1 end
    if pt6l>0  then pt6x=pt6x+pt6vx  pt6y=pt6y+pt6vy  pt6vy=pt6vy+0.15 pt6l=pt6l-1 end
    if pt7l>0  then pt7x=pt7x+pt7vx  pt7y=pt7y+pt7vy  pt7vy=pt7vy+0.15 pt7l=pt7l-1 end
    if pt8l>0  then pt8x=pt8x+pt8vx  pt8y=pt8y+pt8vy  pt8vy=pt8vy+0.15 pt8l=pt8l-1 end
    if pt9l>0  then pt9x=pt9x+pt9vx  pt9y=pt9y+pt9vy  pt9vy=pt9vy+0.15 pt9l=pt9l-1 end
    if pt10l>0 then pt10x=pt10x+pt10vx pt10y=pt10y+pt10vy pt10vy=pt10vy+0.15 pt10l=pt10l-1 end
    if pt11l>0 then pt11x=pt11x+pt11vx pt11y=pt11y+pt11vy pt11vy=pt11vy+0.15 pt11l=pt11l-1 end
    if pt12l>0 then pt12x=pt12x+pt12vx pt12y=pt12y+pt12vy pt12vy=pt12vy+0.15 pt12l=pt12l-1 end
    if pt13l>0 then pt13x=pt13x+pt13vx pt13y=pt13y+pt13vy pt13vy=pt13vy+0.15 pt13l=pt13l-1 end
    if pt14l>0 then pt14x=pt14x+pt14vx pt14y=pt14y+pt14vy pt14vy=pt14vy+0.15 pt14l=pt14l-1 end
    if pt15l>0 then pt15x=pt15x+pt15vx pt15y=pt15y+pt15vy pt15vy=pt15vy+0.15 pt15l=pt15l-1 end
    if pt16l>0 then pt16x=pt16x+pt16vx pt16y=pt16y+pt16vy pt16vy=pt16vy+0.15 pt16l=pt16l-1 end
    if pt17l>0 then pt17x=pt17x+pt17vx pt17y=pt17y+pt17vy pt17vy=pt17vy+0.15 pt17l=pt17l-1 end
    if pt18l>0 then pt18x=pt18x+pt18vx pt18y=pt18y+pt18vy pt18vy=pt18vy+0.15 pt18l=pt18l-1 end
    if pt19l>0 then pt19x=pt19x+pt19vx pt19y=pt19y+pt19vy pt19vy=pt19vy+0.15 pt19l=pt19l-1 end
    if pt20l>0 then pt20x=pt20x+pt20vx pt20y=pt20y+pt20vy pt20vy=pt20vy+0.15 pt20l=pt20l-1 end
    if pt21l>0 then pt21x=pt21x+pt21vx pt21y=pt21y+pt21vy pt21vy=pt21vy+0.15 pt21l=pt21l-1 end
    if pt22l>0 then pt22x=pt22x+pt22vx pt22y=pt22y+pt22vy pt22vy=pt22vy+0.15 pt22l=pt22l-1 end
    if pt23l>0 then pt23x=pt23x+pt23vx pt23y=pt23y+pt23vy pt23vy=pt23vy+0.15 pt23l=pt23l-1 end
end

func drawParticles(cx)
    if pt0l>0  then color(pt0r,pt0g,pt0b)   draw rect(floor(pt0x-cx),  floor(pt0y),  3,3) end
    if pt1l>0  then color(pt1r,pt1g,pt1b)   draw rect(floor(pt1x-cx),  floor(pt1y),  3,3) end
    if pt2l>0  then color(pt2r,pt2g,pt2b)   draw rect(floor(pt2x-cx),  floor(pt2y),  3,3) end
    if pt3l>0  then color(pt3r,pt3g,pt3b)   draw rect(floor(pt3x-cx),  floor(pt3y),  3,3) end
    if pt4l>0  then color(pt4r,pt4g,pt4b)   draw rect(floor(pt4x-cx),  floor(pt4y),  4,4) end
    if pt5l>0  then color(pt5r,pt5g,pt5b)   draw rect(floor(pt5x-cx),  floor(pt5y),  3,3) end
    if pt6l>0  then color(pt6r,pt6g,pt6b)   draw rect(floor(pt6x-cx),  floor(pt6y),  3,3) end
    if pt7l>0  then color(pt7r,pt7g,pt7b)   draw rect(floor(pt7x-cx),  floor(pt7y),  3,3) end
    if pt8l>0  then color(pt8r,pt8g,pt8b)   draw rect(floor(pt8x-cx),  floor(pt8y),  4,4) end
    if pt9l>0  then color(pt9r,pt9g,pt9b)   draw rect(floor(pt9x-cx),  floor(pt9y),  3,3) end
    if pt10l>0 then color(pt10r,pt10g,pt10b) draw rect(floor(pt10x-cx), floor(pt10y), 3,3) end
    if pt11l>0 then color(pt11r,pt11g,pt11b) draw rect(floor(pt11x-cx), floor(pt11y), 3,3) end
    if pt12l>0 then color(pt12r,pt12g,pt12b) draw rect(floor(pt12x-cx), floor(pt12y), 4,4) end
    if pt13l>0 then color(pt13r,pt13g,pt13b) draw rect(floor(pt13x-cx), floor(pt13y), 3,3) end
    if pt14l>0 then color(pt14r,pt14g,pt14b) draw rect(floor(pt14x-cx), floor(pt14y), 3,3) end
    if pt15l>0 then color(pt15r,pt15g,pt15b) draw rect(floor(pt15x-cx), floor(pt15y), 3,3) end
    if pt16l>0 then color(pt16r,pt16g,pt16b) draw rect(floor(pt16x-cx), floor(pt16y), 4,4) end
    if pt17l>0 then color(pt17r,pt17g,pt17b) draw rect(floor(pt17x-cx), floor(pt17y), 3,3) end
    if pt18l>0 then color(pt18r,pt18g,pt18b) draw rect(floor(pt18x-cx), floor(pt18y), 3,3) end
    if pt19l>0 then color(pt19r,pt19g,pt19b) draw rect(floor(pt19x-cx), floor(pt19y), 3,3) end
    if pt20l>0 then color(pt20r,pt20g,pt20b) draw rect(floor(pt20x-cx), floor(pt20y), 4,4) end
    if pt21l>0 then color(pt21r,pt21g,pt21b) draw rect(floor(pt21x-cx), floor(pt21y), 3,3) end
    if pt22l>0 then color(pt22r,pt22g,pt22b) draw rect(floor(pt22x-cx), floor(pt22y), 3,3) end
    if pt23l>0 then color(pt23r,pt23g,pt23b) draw rect(floor(pt23x-cx), floor(pt23y), 3,3) end
end

-- ── Collision ─────────────────────────────────────────────
func moveX(dx)
    px=px+dx
    let top=py+2 let mid=py+PH/2 let bot=py+PH-2
    if dx>0 then
        let rx=px+PW
        if solidAtW(rx,top)==1 or solidAtW(rx,mid)==1 or solidAtW(rx,bot)==1 then
            px=floor((px+PW)/TSIZE)*TSIZE-PW-0.01
            pvx=0 onWall=1
        end
    end
    if dx<0 then
        if solidAtW(px,top)==1 or solidAtW(px,mid)==1 or solidAtW(px,bot)==1 then
            px=floor(px/TSIZE+1)*TSIZE+0.01
            pvx=0 onWall=-1
        end
    end
end

func moveY(dy)
    py=py+dy
    if dy>0 then
        let by=py+PH
        let lx=px+2 let rx=px+PW-2
        if solidAtW(lx,by)==1 or solidAtW(rx,by)==1 then
            py=floor(by/TSIZE)*TSIZE-PH-0.01
            pvy=0 onGround=1 coyote=8
            if abs(pvx)>4 then spawnDust(px+PW/2,py+PH) end
        end
    end
    if dy<0 then
        let lx=px+2 let rx=px+PW-2
        if solidAtW(lx,py)==1 or solidAtW(rx,py)==1 then
            py=floor(py/TSIZE+1)*TSIZE+0.01
            pvy=0 jumpHeld=0
        end
    end
end

-- ── Player physics update ────────────────────────────────
func updatePlayer()
    onGround=0 onWall=0
    coyote=coyote-1 if coyote<0 then coyote=0 end
    dashCd=dashCd-1 if dashCd<0 then dashCd=0 end
    attackCd=attackCd-1 if attackCd<0 then attackCd=0 end
    attackTimer=attackTimer-1 if attackTimer<0 then attackTimer=0 end
    speedBoost=speedBoost-1 if speedBoost<0 then speedBoost=0 end
    comboTimer=comboTimer-1
    if comboTimer<=0 then comboTimer=0 comboCount=0 end
    screenShake=screenShake-1 if screenShake<0 then screenShake=0 end
    wallSlideTimer=wallSlideTimer-1 if wallSlideTimer<0 then wallSlideTimer=0 end

    let maxV=MAXSPD
    if speedBoost>0 then maxV=MAXRUNSPD end

    -- Dash
    if dashing==1 then
        dashTimer=dashTimer-1
        pvx=DASHSPD*facing
        pvy=0
        if dashTimer<=0 then dashing=0 end
        spawnSpeedTrail(px+PW/2, py+PH/2, pvx)
    else
        -- Horizontal input
        let moving=0
        if keydown(KEY_LEFT)==1 or keydown(KEY_A)==1 then
            facing=-1 moving=1
            runTime=runTime+1
            let acc=WALKACC if runTime>20 then acc=RUNTACC end
            pvx=pvx-acc
            let cap=0-maxV if runTime>30 then cap=0-MAXRUNSPD end
            if pvx<cap then pvx=cap end
        elseif keydown(KEY_RIGHT)==1 or keydown(KEY_D)==1 then
            facing=1 moving=1
            runTime=runTime+1
            let acc=WALKACC if runTime>20 then acc=RUNTACC end
            pvx=pvx+acc
            let cap=maxV if runTime>30 then cap=MAXRUNSPD end
            if pvx>cap then pvx=cap end
        else
            runTime=0
            if onGround==1 then pvx=pvx*FRICTION
            else pvx=pvx*AIRFRIC end
        end

        -- Dash trigger
        if keydown(KEY_SHIFT)==1 and dashCd==0 and dashing==0 then
            dashing=1 dashTimer=8 dashCd=45
            pvy=0
            spawnPart(px+PW/2,py+PH/2, 0,0, 12, 255,220,80)
            tone(880,40,0.3,1)
        end
    end

    -- Jump
    if keydown(KEY_SPACE)==1 or keydown(KEY_W)==1 or keydown(KEY_UP)==1 then
        -- normal jump
        if coyote>0 and jumpHeld==0 then
            pvy=0-JUMPFORCE
            coyote=0 jumpHeld=1 onGround=0
            spawnDust(px+PW/2, py+PH)
            tone(440,50,0.25,0)
        end
        -- wall jump
        if onWall~=0 and coyote==0 and jumpHeld==0 then
            pvy=0-WALLJUMP_Y
            pvx=0-onWall*WALLJUMP_X
            jumpHeld=1
            spawnDust(px, py+PH/2)
            tone(523,50,0.25,0)
        end
        -- variable height
        if jumpHeld==1 and pvy<-2 then
            pvy=pvy-0.4
        end
    else
        jumpHeld=0
    end

    -- Ground pound / dive
    if keydown(KEY_DN)==1 or keydown(KEY_S)==1 then
        if onGround==0 and groundPounding==0 then
            groundPounding=1
            pvy=MAXFALL
            pvx=pvx*0.5
            tone(220,60,0.4,2)
        end
    else
        groundPounding=0
    end

    -- Gravity
    if dashing==0 then
        pvy=pvy+GRAV
        -- wall slide: slow fall while pressing into wall
        if onWall~=0 and pvy>0 then
            pvy=pvy*0.6
            wallSlide=1
            wallSlideTimer=5
        end
        if pvy>MAXFALL then pvy=MAXFALL end
    end

    -- Move
    moveX(pvx)
    moveY(pvy)

    -- Speed trail when fast
    let spd=abs(pvx)
    if spd>8 then
        speedTier=4
        spawnSpeedTrail(px+PW/2,py+PH/2,pvx)
    elseif spd>5 then speedTier=3
    elseif spd>3 then speedTier=2
    elseif spd>1 then speedTier=1
    else speedTier=0 end

    -- Fell off world
    if py>SH+40 then
        lives=lives-1
        hp=0
        gameState=2
    end
end

-- ── Enemies ──────────────────────────────────────────────
func spawnEnemy(slot, ex, ey, etype)
    if slot==0  then en0x=ex  en0y=ey  en0vx=0 en0hp=2 en0on=1 en0type=etype en0t=0  end
    if slot==1  then en1x=ex  en1y=ey  en1vx=0 en1hp=2 en1on=1 en1type=etype en1t=0  end
    if slot==2  then en2x=ex  en2y=ey  en2vx=0 en2hp=2 en2on=1 en2type=etype en2t=0  end
    if slot==3  then en3x=ex  en3y=ey  en3vx=0 en3hp=2 en3on=1 en3type=etype en3t=0  end
    if slot==4  then en4x=ex  en4y=ey  en4vx=0 en4hp=2 en4on=1 en4type=etype en4t=0  end
    if slot==5  then en5x=ex  en5y=ey  en5vx=0 en5hp=2 en5on=1 en5type=etype en5t=0  end
    if slot==6  then en6x=ex  en6y=ey  en6vx=0 en6hp=2 en6on=1 en6type=etype en6t=0  end
    if slot==7  then en7x=ex  en7y=ey  en7vx=0 en7hp=2 en7on=1 en7type=etype en7t=0  end
    if slot==8  then en8x=ex  en8y=ey  en8vx=0 en8hp=2 en8on=1 en8type=etype en8t=0  end
    if slot==9  then en9x=ex  en9y=ey  en9vx=0 en9hp=2 en9on=1 en9type=etype en9t=0  end
    if slot==10 then en10x=ex en10y=ey en10vx=0 en10hp=2 en10on=1 en10type=etype en10t=0 end
    if slot==11 then en11x=ex en11y=ey en11vx=0 en11hp=2 en11on=1 en11type=etype en11t=0 end
end

func findFreeEnemy()
    if en0on==0  then return 0  end if en1on==0  then return 1  end
    if en2on==0  then return 2  end if en3on==0  then return 3  end
    if en4on==0  then return 4  end if en5on==0  then return 5  end
    if en6on==0  then return 6  end if en7on==0  then return 7  end
    if en8on==0  then return 8  end if en9on==0  then return 9  end
    if en10on==0 then return 10 end if en11on==0 then return 11 end
    return -1
end

let enSpawnCd=80

func trySpawnEnemy()
    enSpawnCd=enSpawnCd-1
    if enSpawnCd>0 then return end
    let slot=findFreeEnemy()
    if slot<0 then enSpawnCd=20 return end
    -- spawn off right edge in world space
    let ex=camX+SW+48
    let floorPx=(ROWS-2)*TSIZE
    let ey=floorPx-16.0
    let etype=rnd(1,3)
    spawnEnemy(slot, ex, ey, etype)
    enSpawnCd=rnd(60,120)
end

func updateOneEnemy(slot)
    let ex=0.0 let ey=0.0 let evx=0.0 let ehp=0 let eon=0 let etype=0 let et=0
    if slot==0  then ex=en0x  ey=en0y  evx=en0vx  ehp=en0hp  eon=en0on  etype=en0type  et=en0t  end
    if slot==1  then ex=en1x  ey=en1y  evx=en1vx  ehp=en1hp  eon=en1on  etype=en1type  et=en1t  end
    if slot==2  then ex=en2x  ey=en2y  evx=en2vx  ehp=en2hp  eon=en2on  etype=en2type  et=en2t  end
    if slot==3  then ex=en3x  ey=en3y  evx=en3vx  ehp=en3hp  eon=en3on  etype=en3type  et=en3t  end
    if slot==4  then ex=en4x  ey=en4y  evx=en4vx  ehp=en4hp  eon=en4on  etype=en4type  et=en4t  end
    if slot==5  then ex=en5x  ey=en5y  evx=en5vx  ehp=en5hp  eon=en5on  etype=en5type  et=en5t  end
    if slot==6  then ex=en6x  ey=en6y  evx=en6vx  ehp=en6hp  eon=en6on  etype=en6type  et=en6t  end
    if slot==7  then ex=en7x  ey=en7y  evx=en7vx  ehp=en7hp  eon=en7on  etype=en7type  et=en7t  end
    if slot==8  then ex=en8x  ey=en8y  evx=en8vx  ehp=en8hp  eon=en8on  etype=en8type  et=en8t  end
    if slot==9  then ex=en9x  ey=en9y  evx=en9vx  ehp=en9hp  eon=en9on  etype=en9type  et=en9t  end
    if slot==10 then ex=en10x ey=en10y evx=en10vx ehp=en10hp eon=en10on etype=en10type et=en10t end
    if slot==11 then ex=en11x ey=en11y evx=en11vx ehp=en11hp eon=en11on etype=en11type et=en11t end
    if eon==0 then return end

    et=et+1

    -- TYPE 1: Walker — patrols back and forth on platform
    if etype==1 then
        if evx==0 then evx=-1.5 end
        ex=ex+evx
        -- turn at edges or walls
        if solidAtW(ex-2,ey+8)==1 or solidAtW(ex+16,ey+8)==1 then evx=0-evx end
        if solidAtW(ex+8,ey+16)==0 then evx=0-evx end
    end

    -- TYPE 2: Jumper — bounces vertically
    if etype==2 then
        evx=-2.0
        ex=ex+evx
        let evy=sin(et*0.18)*5
        ey=ey+evy
    end

    -- TYPE 3: Charger — rushes at player when close
    if etype==3 then
        let dx=px-ex
        if abs(dx)<120 then
            if dx>0 then evx=3.5 else evx=-3.5 end
        else
            evx=-1.2
        end
        ex=ex+evx
    end

    -- Despawn if too far left
    if ex < camX-80 then eon=0 end

    -- Collision with player
    let sx=ex-camX let sy=ey
    let plx=px-camX let ply=py
    if eon==1 then
        if abs((plx+PW/2)-(sx+8))<16 and abs((ply+PH/2)-(sy+8))<16 then
            -- player stomps from above
            if pvy>0 and ply+PH < sy+6 then
                ehp=ehp-1
                pvy=-6.0
                comboCount=comboCount+1 comboTimer=90
                score=score+100*comboCount
                spawnPart(ex-camX,ey, 0,-3, 15, 255,200,60)
                tone(660,60,0.4,1)
                if ehp<=0 then eon=0 end
            elseif attackTimer>0 then
                -- attack hit
                ehp=ehp-1
                comboCount=comboCount+1 comboTimer=90
                score=score+100*comboCount
                spawnPart(ex-camX,ey, facing*3,-2, 15, 255,160,40)
                tone(550,60,0.3,2)
                if ehp<=0 then eon=0 end
            else
                -- player takes damage
                if hitEnemy==0 then
                    hp=hp-1
                    hitEnemy=60
                    screenShake=10
                    pvy=-5.0
                    pvx=0-(facing)*4
                    tone(200,80,0.5,2)
                    comboCount=0 comboTimer=0
                    if hp<=0 then
                        lives=lives-1
                        if lives<=0 then gameState=2
                        else hp=maxHp hitEnemy=120 end
                    end
                end
            end
        end
    end

    hitEnemy=hitEnemy-1 if hitEnemy<0 then hitEnemy=0 end

    if slot==0  then en0x=ex  en0y=ey  en0vx=evx  en0hp=ehp  en0on=eon  en0t=et  end
    if slot==1  then en1x=ex  en1y=ey  en1vx=evx  en1hp=ehp  en1on=eon  en1t=et  end
    if slot==2  then en2x=ex  en2y=ey  en2vx=evx  en2hp=ehp  en2on=eon  en2t=et  end
    if slot==3  then en3x=ex  en3y=ey  en3vx=evx  en3hp=ehp  en3on=eon  en3t=et  end
    if slot==4  then en4x=ex  en4y=ey  en4vx=evx  en4hp=ehp  en4on=eon  en4t=et  end
    if slot==5  then en5x=ex  en5y=ey  en5vx=evx  en5hp=ehp  en5on=eon  en5t=et  end
    if slot==6  then en6x=ex  en6y=ey  en6vx=evx  en6hp=ehp  en6on=eon  en6t=et  end
    if slot==7  then en7x=ex  en7y=ey  en7vx=evx  en7hp=ehp  en7on=eon  en7t=et  end
    if slot==8  then en8x=ex  en8y=ey  en8vx=evx  en8hp=ehp  en8on=eon  en8t=et  end
    if slot==9  then en9x=ex  en9y=ey  en9vx=evx  en9hp=ehp  en9on=eon  en9t=et  end
    if slot==10 then en10x=ex en10y=ey en10vx=evx en10hp=ehp en10on=eon en10t=et end
    if slot==11 then en11x=ex en11y=ey en11vx=evx en11hp=ehp en11on=eon en11t=et end
end

-- ── Collectibles ─────────────────────────────────────────
let coSpawnCd=50

func trySpawnCollectible()
    coSpawnCd=coSpawnCd-1
    if coSpawnCd>0 then return end
    -- find free slot
    let slot=-1
    if co0on==0 then slot=0 end
    if co1on==0 and slot<0 then slot=1 end
    if co2on==0 and slot<0 then slot=2 end
    if co3on==0 and slot<0 then slot=3 end
    if co4on==0 and slot<0 then slot=4 end
    if co5on==0 and slot<0 then slot=5 end
    if co6on==0 and slot<0 then slot=6 end
    if co7on==0 and slot<0 then slot=7 end
    if slot<0 then return end
    let cx=camX+SW+rnd(20,60)
    let cy=rnd(4,9)*TSIZE
    let ctype=rnd(1,3)
    if co0on==0 and slot==0 then co0x=cx co0y=cy co0on=1 co0type=ctype end
    if co1on==0 and slot==1 then co1x=cx co1y=cy co1on=1 co1type=ctype end
    if co2on==0 and slot==2 then co2x=cx co2y=cy co2on=1 co2type=ctype end
    if co3on==0 and slot==3 then co3x=cx co3y=cy co3on=1 co3type=ctype end
    if co4on==0 and slot==4 then co4x=cx co4y=cy co4on=1 co4type=ctype end
    if co5on==0 and slot==5 then co5x=cx co5y=cy co5on=1 co5type=ctype end
    if co6on==0 and slot==6 then co6x=cx co6y=cy co6on=1 co6type=ctype end
    if co7on==0 and slot==7 then co7x=cx co7y=cy co7on=1 co7type=ctype end
    coSpawnCd=rnd(30,60)
end

func checkCollectible(cox,coy,coon,ctype)
    if coon==0 then return 0 end
    let dx=abs(px+PW/2-(cox+8)) let dy=abs(py+PH/2-(coy+8))
    if dx<18 and dy<18 then
        if ctype==1 then score=score+50 tone(880,40,0.3,0) end
        if ctype==2 then score=score+200 tone(1047,60,0.4,0) comboCount=comboCount+2 comboTimer=90 end
        if ctype==3 then speedBoost=180 tone(659,80,0.4,0) end
        spawnPart(cox-camX,coy, 0,-2, 12, 255,220,80)
        return 1
    end
    return 0
end

func updateCollectibles()
    if checkCollectible(co0x,co0y,co0on,co0type)==1 then co0on=0 end
    if checkCollectible(co1x,co1y,co1on,co1type)==1 then co1on=0 end
    if checkCollectible(co2x,co2y,co2on,co2type)==1 then co2on=0 end
    if checkCollectible(co3x,co3y,co3on,co3type)==1 then co3on=0 end
    if checkCollectible(co4x,co4y,co4on,co4type)==1 then co4on=0 end
    if checkCollectible(co5x,co5y,co5on,co5type)==1 then co5on=0 end
    if checkCollectible(co6x,co6y,co6on,co6type)==1 then co6on=0 end
    if checkCollectible(co7x,co7y,co7on,co7type)==1 then co7on=0 end
    -- despawn if too far left
    if co0on==1 and co0x<camX-40 then co0on=0 end
    if co1on==1 and co1x<camX-40 then co1on=0 end
    if co2on==1 and co2x<camX-40 then co2on=0 end
    if co3on==1 and co3x<camX-40 then co3on=0 end
    if co4on==1 and co4x<camX-40 then co4on=0 end
    if co5on==1 and co5x<camX-40 then co5on=0 end
    if co6on==1 and co6x<camX-40 then co6on=0 end
    if co7on==1 and co7x<camX-40 then co7on=0 end
end

-- ── Draw level ────────────────────────────────────────────
func getTileColor(col, row)
    -- depth-based shading + decoration
    let depth = row
    let base  = 80 + floor((ROWS-row)*8)
    return base
end

func drawLevel(cx)
    -- background parallax layers
    -- far sky
    color(20,28,50) draw rect(0,0,SW,SH)
    -- mid clouds (parallax 0.2)
    let cloudX = floor(cx*0.2) % SW
    color(30,38,66)
    draw rect(0-cloudX+10, 30, 80, 20)
    draw rect(0-cloudX+160, 50, 60, 14)
    draw rect(0-cloudX+300, 35, 90, 18)
    draw rect(SW-cloudX+10, 30, 80, 20)
    draw rect(SW-cloudX+160, 50, 60, 14)

    -- tiles
    let startCol = floor(cx/TSIZE)
    let col=startCol
    while col < startCol+COLS+1 do
        let row=0
        while row<ROWS do
            if isSolid(col,row)==1 then
                let sx=(col*TSIZE)-floor(cx)
                let sy=row*TSIZE
                -- base tile
                let bright=100+floor((ROWS-row)*10)
                let g=floor(bright*0.9) let b=floor(bright*0.6)
                color(bright,g,b) draw rect(sx,sy,TSIZE,TSIZE)
                -- top edge highlight
                if isSolid(col,row-1)==0 then
                    color(bright+40,g+30,b+20)
                    draw rect(sx,sy,TSIZE,3)
                end
                -- left edge
                color(bright-20,g-15,b-10)
                draw rect(sx+TSIZE-3,sy,3,TSIZE)
            end
            row=row+1
        end
        col=col+1
    end
end

-- ── Draw enemies ─────────────────────────────────────────
func drawOneEnemy(ex,ey,eon,etype,et)
    if eon==0 then return end
    let sx=floor(ex-camX) let sy=floor(ey)
    if sx < -30 or sx > SW+30 then return end
    -- TYPE 1: Walker — squat red dude
    if etype==1 then
        color(200,50,50) draw rect(sx,sy+4,16,12)
        color(220,80,60) draw rect(sx+2,sy,12,8)
        color(255,255,255) draw rect(sx+4,sy+2,3,3) draw rect(sx+9,sy+2,3,3)
        color(0,0,0) draw rect(sx+5,sy+3,2,2) draw rect(sx+10,sy+3,2,2)
        -- legs
        let leg=floor(abs(sin(et*0.3))*3)
        color(160,30,30) draw rect(sx+2,sy+14,4,4+leg) draw rect(sx+10,sy+14,4,4-leg)
    end
    -- TYPE 2: Jumper — bouncy blue blob
    if etype==2 then
        let squish=floor(abs(sin(et*0.18))*3)
        color(50,100,220) draw rect(sx+2,sy+squish,12,12-squish)
        color(100,160,255) draw rect(sx+4,sy+squish,4,4)
        color(255,255,255) draw rect(sx+3,sy+2+squish,3,3) draw rect(sx+8,sy+2+squish,3,3)
    end
    -- TYPE 3: Charger — sharp orange triangle shape
    if etype==3 then
        color(240,120,20) draw rect(sx,sy+6,16,8)
        draw rect(sx+4,sy+2,8,12)
        draw rect(sx+6,sy,4,16)
        color(255,200,80) draw rect(sx+6,sy+6,4,4)
        color(255,255,255) draw rect(sx+5,sy+4,2,2) draw rect(sx+9,sy+4,2,2)
    end
end

func drawEnemies()
    drawOneEnemy(en0x,en0y,en0on,en0type,en0t)
    drawOneEnemy(en1x,en1y,en1on,en1type,en1t)
    drawOneEnemy(en2x,en2y,en2on,en2type,en2t)
    drawOneEnemy(en3x,en3y,en3on,en3type,en3t)
    drawOneEnemy(en4x,en4y,en4on,en4type,en4t)
    drawOneEnemy(en5x,en5y,en5on,en5type,en5t)
    drawOneEnemy(en6x,en6y,en6on,en6type,en6t)
    drawOneEnemy(en7x,en7y,en7on,en7type,en7t)
    drawOneEnemy(en8x,en8y,en8on,en8type,en8t)
    drawOneEnemy(en9x,en9y,en9on,en9type,en9t)
    drawOneEnemy(en10x,en10y,en10on,en10type,en10t)
    drawOneEnemy(en11x,en11y,en11on,en11type,en11t)
end

-- ── Draw collectibles ────────────────────────────────────
func drawCollectibles()
    let bob = floor(sin(frame*0.12)*3)
    if co0on==1 then
        let sx=floor(co0x-camX) let sy=floor(co0y)+bob
        if co0type==1 then color(255,210,40) draw rect(sx+2,sy+2,12,12) color(255,240,120) draw rect(sx+5,sy+5,6,6) end
        if co0type==2 then color(80,200,255) draw rect(sx,sy+4,8,8) draw rect(sx+4,sy,8,8) color(160,230,255) draw rect(sx+4,sy+4,6,6) end
        if co0type==3 then color(100,255,100) draw rect(sx+3,sy,10,16) draw rect(sx,sy+5,16,6) color(180,255,180) draw rect(sx+6,sy+3,4,10) end
    end
    if co1on==1 then
        let sx=floor(co1x-camX) let sy=floor(co1y)+bob
        if co1type==1 then color(255,210,40) draw rect(sx+2,sy+2,12,12) color(255,240,120) draw rect(sx+5,sy+5,6,6) end
        if co1type==2 then color(80,200,255) draw rect(sx,sy+4,8,8) draw rect(sx+4,sy,8,8) color(160,230,255) draw rect(sx+4,sy+4,6,6) end
        if co1type==3 then color(100,255,100) draw rect(sx+3,sy,10,16) draw rect(sx,sy+5,16,6) color(180,255,180) draw rect(sx+6,sy+3,4,10) end
    end
    if co2on==1 then
        let sx=floor(co2x-camX) let sy=floor(co2y)+bob
        if co2type==1 then color(255,210,40) draw rect(sx+2,sy+2,12,12) end
        if co2type==2 then color(80,200,255) draw rect(sx,sy+4,8,8) draw rect(sx+4,sy,8,8) end
        if co2type==3 then color(100,255,100) draw rect(sx+3,sy,10,16) draw rect(sx,sy+5,16,6) end
    end
    if co3on==1 then
        let sx=floor(co3x-camX) let sy=floor(co3y)+bob
        if co3type==1 then color(255,210,40) draw rect(sx+2,sy+2,12,12) end
        if co3type==2 then color(80,200,255) draw rect(sx,sy+4,8,8) draw rect(sx+4,sy,8,8) end
        if co3type==3 then color(100,255,100) draw rect(sx+3,sy,10,16) draw rect(sx,sy+5,16,6) end
    end
    if co4on==1 then let sx=floor(co4x-camX) let sy=floor(co4y)+bob color(255,210,40) draw rect(sx+2,sy+2,12,12) end
    if co5on==1 then let sx=floor(co5x-camX) let sy=floor(co5y)+bob color(255,210,40) draw rect(sx+2,sy+2,12,12) end
    if co6on==1 then let sx=floor(co6x-camX) let sy=floor(co6y)+bob color(255,210,40) draw rect(sx+2,sy+2,12,12) end
    if co7on==1 then let sx=floor(co7x-camX) let sy=floor(co7y)+bob color(255,210,40) draw rect(sx+2,sy+2,12,12) end
end

-- ── Draw player ───────────────────────────────────────────
func drawPlayer(cx)
    let sx=floor(px-cx) let sy=floor(py)
    if hitEnemy>0 and hitEnemy%6<3 then return end

    -- speed-based color tinting
    let tint=0
    if speedTier>=3 then tint=40 end
    if speedTier>=4 then tint=80 end
    if speedBoost>0 then tint=120 end

    -- shadow
    color(0,30,0) draw rect(sx+2, sy+PH, PW-4, 3)

    -- body
    let br=60+tint let bg=120 let bb=220
    if dashing==1 then br=255 bg=220 bb=40 end
    color(br,bg,bb)
    draw rect(sx+2,sy+6,PW-4,PH-6)

    -- head
    color(240,200,160) draw rect(sx+3,sy,PW-6,8)

    -- hair
    color(60,40,140+tint) draw rect(sx+3,sy,PW-6,3)

    -- eyes (direction-aware)
    color(20,20,20)
    if facing==1 then draw rect(sx+8,sy+3,3,3)
    else draw rect(sx+3,sy+3,3,3) end

    -- scarf (flies back when running)
    let scarfX = 0-facing*floor(abs(pvx)*0.5)
    color(220,60,60)
    draw rect(sx+4+scarfX,sy+5,6,3)

    -- legs
    let legSwing=0
    if onGround==1 and abs(pvx)>0.5 then
        legSwing=floor(sin(frame*0.4)*4)
    end
    color(40,80,160+tint)
    draw rect(sx+2,  sy+PH-8, 5, 8+legSwing)
    draw rect(sx+PW-7, sy+PH-8, 5, 8-legSwing)

    -- shoes
    color(40,30,20)
    draw rect(sx, sy+PH+legSwing, 7, 3)
    draw rect(sx+PW-7, sy+PH-legSwing, 7, 3)

    -- arms
    if attackTimer>0 then
        -- punch arm extended
        color(br,bg,bb)
        if facing==1 then draw rect(sx+PW, sy+8, 8, 4)
        else draw rect(sx-8, sy+8, 8, 4) end
        color(240,200,160)
        if facing==1 then draw rect(sx+PW+6, sy+7, 5, 5)
        else draw rect(sx-11, sy+7, 5, 5) end
    else
        color(br,bg,bb)
        if onGround==0 then
            draw rect(sx-4, sy+8, 5, 3)
            draw rect(sx+PW-1, sy+8, 5, 3)
        else
            draw rect(sx-3, sy+9+legSwing/2, 4, 3)
            draw rect(sx+PW-1, sy+9-legSwing/2, 4, 3)
        end
    end

    -- wall slide indicator
    if wallSlideTimer>0 then
        color(180,240,255)
        if onWall==1 then draw rect(sx+PW, sy+4, 3, PH-4)
        else draw rect(sx-3, sy+4, 3, PH-4) end
    end

    -- ground pound indicator
    if groundPounding==1 then
        color(255,160,20)
        draw rect(sx+PW/2-2, sy+PH, 4, 6)
    end
end

-- ── Speed meter ──────────────────────────────────────────
func drawSpeedMeter()
    let spd=abs(pvx)
    -- background
    color(10,10,20) draw rect(4,4,60,8)
    -- fill
    let fill=floor(spd*4) if fill>60 then fill=60 end
    if speedTier==0 then color(60,100,60) end
    if speedTier==1 then color(100,180,60) end
    if speedTier==2 then color(200,220,40) end
    if speedTier==3 then color(255,160,20) end
    if speedTier==4 then color(255,60,20) end
    if speedBoost>0 then
        let fc=floor(abs(sin(frame*0.3))*80)+160
        color(fc,255,fc)
    end
    if fill>0 then draw rect(4,4,fill,8) end
    -- speed tier labels
    color(200,200,200) draw text("SPD",66,4)
end

-- ── HUD ──────────────────────────────────────────────────
func drawHUD()
    -- score
    color(255,220,50) draw text("SCORE "+tostr(score),4,SH-20)
    -- hi score
    if score>hiScore then hiScore=score end
    color(180,180,220) draw text("BEST "+tostr(hiScore),SW-80,SH-20)
    -- distance
    color(100,220,180) draw text("x"+tostr(worldX),SW/2-20,SH-20)
    -- HP hearts
    let i=0
    while i<maxHp do
        if i<hp then color(220,60,60)
        else color(60,30,30) end
        draw rect(4+i*16,16,12,10)
        draw rect(4+i*16+2,14,8,4)
        draw rect(4+i*16,14,4,4)
        draw rect(4+i*16+8,14,4,4)
        i=i+1
    end
    -- lives
    color(180,180,220) draw text("x"+tostr(lives),4+maxHp*16+4,16)
    -- combo
    if comboCount>1 then
        let cf=floor(abs(sin(frame*0.2))*60)+180
        color(cf, floor(cf*0.8), 40)
        draw text(tostr(comboCount)+"x COMBO!",SW/2-30,30)
    end
    -- speed meter
    drawSpeedMeter()
    -- speed boost indicator
    if speedBoost>0 then
        if frame%10<5 then
            color(100,255,100) draw text("TURBO!",SW/2-20,14)
        end
    end
end

-- ── Screen shake ─────────────────────────────────────────
func getShake()
    if screenShake<=0 then return 0 end
    return floor(sin(frame*1.3)*screenShake*0.4)
end

-- ── Game states ───────────────────────────────────────────

-- Title screen
func drawTitle()
    color(10,14,30) clear()
    -- stars
    let i=0
    while i<40 do
        let sx=floor(abs(sin(i*137.5+frame*0.02))*478)+1
        let sy=floor(abs(cos(i*251.3))*318)+1
        color(140,140,200) draw rect(sx,sy,2,2)
        i=i+1
    end
    -- title
    let tc=floor(abs(sin(frame*0.04))*60)+180
    color(tc,floor(tc*0.4),255)
    draw text("TURBODASH",SW/2-42,80)
    color(220,220,255)
    draw text("endless momentum platformer",SW/2-66,104)
    -- controls
    color(160,160,200) draw text("LEFT/RIGHT - run",SW/2-40,148)
    draw text("SPACE - jump",SW/2-30,164)
    draw text("SHIFT - dash",SW/2-30,180)
    draw text("Z - attack",SW/2-24,196)
    draw text("DOWN - ground pound",SW/2-48,212)
    -- start prompt
    if frame%40<24 then
        color(255,220,50) draw text("PRESS SPACE TO START",SW/2-50,250)
    end
    -- hi score
    if hiScore>0 then
        color(180,220,255) draw text("BEST: "+tostr(hiScore),SW/2-30,274)
    end
end

-- Death screen
func drawDead()
    color(10,5,5) clear()
    let i=0
    while i<20 do
        let sx=floor(abs(sin(i*137.5))*478)+1
        let sy=floor(abs(cos(i*251.3+frame*0.1))*318)+1
        color(80,30,30) draw rect(sx,sy,2,2)
        i=i+1
    end
    if frame%30<18 then
        color(255,60,60)  draw text("GAME OVER",SW/2-40,100)
    end
    color(255,220,50)  draw text("SCORE  "+tostr(score),SW/2-36,130)
    color(180,220,255) draw text("BEST   "+tostr(hiScore),SW/2-36,150)
    -- distance
    color(100,220,180) draw text("REACHED  x"+tostr(worldX),SW/2-44,170)
    if frame%40<24 then
        color(200,200,255) draw text("SPACE to play again",SW/2-46,210)
    end
end

-- Pause screen
func drawPause()
    -- darken
    color(0,0,20)
    draw rect(0,0,SW,SH)
    color(100,180,255) draw text("PAUSED",SW/2-24,120)
    color(180,180,220) draw text("ESC to resume",SW/2-34,148)
end

-- ── Reset game ────────────────────────────────────────────
func resetGame()
    px=60.0 py=200.0 pvx=0.0 pvy=0.0
    facing=1 onGround=0 onWall=0 coyote=0
    jumpHeld=0 runTime=0 dashCd=0 dashing=0
    dashTimer=0 groundPounding=0 wallSlide=0
    comboCount=0 comboTimer=0 attackCd=0
    attackTimer=0 hitEnemy=0 speedBoost=0
    speedTier=0 screenShake=0
    camX=0.0 camTarget=0.0
    worldX=0 genSeed=0 effectSeed=0
    score=0 hp=maxHp lives=3
    floorY=11 ceilY=-1 runLen=0 patType=0
    genCol=0
    -- clear enemies and collectibles
    en0on=0 en1on=0 en2on=0 en3on=0 en4on=0 en5on=0
    en6on=0 en7on=0 en8on=0 en9on=0 en10on=0 en11on=0
    co0on=0 co1on=0 co2on=0 co3on=0
    co4on=0 co5on=0 co6on=0 co7on=0
    generateWorld()
    gameState=1
end

-- ═══════════════════════════════
--  INIT
-- ═══════════════════════════════

-- Load hi score
let savePath=path_join(scriptParent,"turbodash_hi.txt")
if path_exists(savePath)==1 then
    hiScore=tonum(readFile(savePath))
end

generateWorld()

-- ═══════════════════════════════
--  MAIN LOOP
-- ═══════════════════════════════
while running==1 do
    frame=frame+1

    if keydown(KEY_ESC)==1 then
        if gameState==1 then gameState=3
        elseif gameState==3 then gameState=1
        else running=0 end
    end

    -- ── TITLE ────────────────────────────────────────────
    if gameState==0 then
        drawTitle()
        if keydown(KEY_SPACE)==1 then
            resetGame()
        end
        sleep(16)

    -- ── PLAYING ──────────────────────────────────────────
    elseif gameState==1 then

        -- Attack input
        if keydown(KEY_Z)==1 and attackCd==0 then
            attackTimer=12 attackCd=20
            tone(660,30,0.2,1)
        end

        -- Physics
        updatePlayer()

        -- Camera: smooth follow with lookahead
        camTarget = px - SW/3 + pvx*4
        if camTarget < 0 then camTarget=0 end
        camX = camX + (camTarget - camX) * 0.12

        -- Scroll world when camera moves far enough
        let newTile=floor(camX/TSIZE)
        let oldTile=floor((camX-pvx)/TSIZE)
        let moved=newTile-oldTile
        if moved>0 then
            scrollWorld(moved)
            -- worldX already incremented inside scrollWorld
            score=score+moved*2
        end

        -- Enemies + collectibles
        trySpawnEnemy()
        updateOneEnemy(0)  updateOneEnemy(1)  updateOneEnemy(2)
        updateOneEnemy(3)  updateOneEnemy(4)  updateOneEnemy(5)
        updateOneEnemy(6)  updateOneEnemy(7)  updateOneEnemy(8)
        updateOneEnemy(9)  updateOneEnemy(10) updateOneEnemy(11)
        trySpawnCollectible()
        updateCollectibles()

        -- Particles
        moveParticles()

        -- Save hi score
        if score>hiScore then
            hiScore=score
            writeFile(savePath,tostr(hiScore))
        end

        -- Render
        let shake=getShake()
        let cx=floor(camX)+shake

        drawLevel(cx)
        drawParticles(cx)
        drawCollectibles()
        drawEnemies()
        drawPlayer(cx)
        drawHUD()

        -- damage flash
        if hitEnemy>50 then
            color(180,20,20) draw rect(0,0,SW,SH)
        end

        sleep(16)

    -- ── DEAD ─────────────────────────────────────────────
    elseif gameState==2 then
        drawDead()
        if keydown(KEY_SPACE)==1 then
            resetGame()
        end
        sleep(16)

    -- ── PAUSED ───────────────────────────────────────────
    elseif gameState==3 then
        -- still render the world behind pause
        let cx=floor(camX)
        drawLevel(cx)
        drawEnemies()
        drawPlayer(cx)
        drawHUD()
        drawPause()
        sleep(16)
    end
end
