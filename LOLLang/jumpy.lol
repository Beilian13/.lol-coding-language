-- mode:window
-- ============================================================
--  JUMPY.LOL  -  platformer in LOLang
--  LEFT/RIGHT = move      SHIFT = run
--  SPACE / UP = jump      (coyote time + variable jump height)
--  ESC        = quit
--  Collect all coins to advance to the next level!
-- ============================================================

window("JUMPY.LOL", 640, 400)

-- Keys
let KEY_LEFT  = 37
let KEY_RIGHT = 39
let KEY_UP    = 38
let KEY_SPACE = 32
let KEY_SHIFT = 16
let KEY_ESC   = 27

-- Tile size and world dimensions
let TS    = 24    -- tile size in pixels
let COLS  = 26    -- map columns
let ROWS  = 16    -- map rows
let SW    = 640
let SH    = 400

-- ── Level maps (3 levels) ─────────────────────────────────
-- Each row is a bitmask: bit N = col N is solid
-- 26 columns so max value = 2^26-1 = 67108863

-- Level 1: gentle intro
let L1r0  = 67108863  -- full top border
let L1r1  = 33554433  -- sides only
let L1r2  = 33554433
let L1r3  = 33554433
let L1r4  = 33685569  -- platform mid-left  (bits 7,8,9,10,11)
let L1r5  = 33554433
let L1r6  = 33554433
let L1r7  = 50397249  -- platform right area
let L1r8  = 33554433
let L1r9  = 33554433
let L1r10 = 33587265  -- low platform
let L1r11 = 33554433
let L1r12 = 33554433
let L1r13 = 33554433
let L1r14 = 33554433
let L1r15 = 67108863  -- full floor

-- Level 2: trickier gaps
let L2r0  = 67108863
let L2r1  = 33554433
let L2r2  = 33554433
let L2r3  = 33685569
let L2r4  = 33554433
let L2r5  = 50430017
let L2r6  = 33554433
let L2r7  = 33554433
let L2r8  = 33685569
let L2r9  = 33554433
let L2r10 = 33554433
let L2r11 = 50397249
let L2r12 = 33554433
let L2r13 = 33685569
let L2r14 = 33554433
let L2r15 = 67108863

-- Level 3: tough!
let L3r0  = 67108863
let L3r1  = 33554433
let L3r2  = 50397249
let L3r3  = 33554433
let L3r4  = 33685569
let L3r5  = 33554433
let L3r6  = 33554433
let L3r7  = 50430017
let L3r8  = 33554433
let L3r9  = 33685569
let L3r10 = 33554433
let L3r11 = 33554433
let L3r12 = 50397249
let L3r13 = 33554433
let L3r14 = 33685569
let L3r15 = 67108863

-- Current level row cache (updated on level load)
let mr0=0 let mr1=0 let mr2=0 let mr3=0 let mr4=0 let mr5=0
let mr6=0 let mr7=0 let mr8=0 let mr9=0 let mr10=0 let mr11=0
let mr12=0 let mr13=0 let mr14=0 let mr15=0

func loadLevel(lv)
    if lv == 1 then
        mr0=L1r0 mr1=L1r1 mr2=L1r2 mr3=L1r3
        mr4=L1r4 mr5=L1r5 mr6=L1r6 mr7=L1r7
        mr8=L1r8 mr9=L1r9 mr10=L1r10 mr11=L1r11
        mr12=L1r12 mr13=L1r13 mr14=L1r14 mr15=L1r15
    end
    if lv == 2 then
        mr0=L2r0 mr1=L2r1 mr2=L2r2 mr3=L2r3
        mr4=L2r4 mr5=L2r5 mr6=L2r6 mr7=L2r7
        mr8=L2r8 mr9=L2r9 mr10=L2r10 mr11=L2r11
        mr12=L2r12 mr13=L2r13 mr14=L2r14 mr15=L2r15
    end
    if lv == 3 then
        mr0=L3r0 mr1=L3r1 mr2=L3r2 mr3=L3r3
        mr4=L3r4 mr5=L3r5 mr6=L3r6 mr7=L3r7
        mr8=L3r8 mr9=L3r9 mr10=L3r10 mr11=L3r11
        mr12=L3r12 mr13=L3r13 mr14=L3r14 mr15=L3r15
    end
end

func getRow(r)
    if r == 0  then return mr0  end
    if r == 1  then return mr1  end
    if r == 2  then return mr2  end
    if r == 3  then return mr3  end
    if r == 4  then return mr4  end
    if r == 5  then return mr5  end
    if r == 6  then return mr6  end
    if r == 7  then return mr7  end
    if r == 8  then return mr8  end
    if r == 9  then return mr9  end
    if r == 10 then return mr10 end
    if r == 11 then return mr11 end
    if r == 12 then return mr12 end
    if r == 13 then return mr13 end
    if r == 14 then return mr14 end
    return mr15
end

func pow2(n)
    if n == 0  then return 1      end
    if n == 1  then return 2      end
    if n == 2  then return 4      end
    if n == 3  then return 8      end
    if n == 4  then return 16     end
    if n == 5  then return 32     end
    if n == 6  then return 64     end
    if n == 7  then return 128    end
    if n == 8  then return 256    end
    if n == 9  then return 512    end
    if n == 10 then return 1024   end
    if n == 11 then return 2048   end
    if n == 12 then return 4096   end
    if n == 13 then return 8192   end
    if n == 14 then return 16384  end
    if n == 15 then return 32768  end
    if n == 16 then return 65536  end
    if n == 17 then return 131072 end
    if n == 18 then return 262144 end
    if n == 19 then return 524288 end
    if n == 20 then return 1048576 end
    if n == 21 then return 2097152 end
    if n == 22 then return 4194304 end
    if n == 23 then return 8388608 end
    if n == 24 then return 16777216 end
    return 33554432
end

-- Returns 1 if tile (col, row) is solid
func isSolid(col, row)
    if row < 0    then return 0 end
    if row >= ROWS then return 1 end
    if col < 0    then return 1 end
    if col >= COLS then return 1 end
    let rv = getRow(floor(row))
    let pw = pow2(floor(col))
    let sh = floor(rv / pw)
    return sh - floor(sh / 2) * 2
end

-- Returns 1 if a pixel-space point (wx, wy) is inside a solid tile
func solidAt(wx, wy)
    return isSolid(floor(wx / TS), floor(wy / TS))
end

-- ── Coins (12 per level) ──────────────────────────────────
-- stored as tile coords, on=1 means not yet collected
let c0tx=0  let c0ty=0  let c0on=0
let c1tx=0  let c1ty=0  let c1on=0
let c2tx=0  let c2ty=0  let c2on=0
let c3tx=0  let c3ty=0  let c3on=0
let c4tx=0  let c4ty=0  let c4on=0
let c5tx=0  let c5ty=0  let c5on=0
let c6tx=0  let c6ty=0  let c6on=0
let c7tx=0  let c7ty=0  let c7on=0
let c8tx=0  let c8ty=0  let c8on=0
let c9tx=0  let c9ty=0  let c9on=0
let c10tx=0 let c10ty=0 let c10on=0
let c11tx=0 let c11ty=0 let c11on=0

func placeCoin(slot, tx, ty)
    if slot == 0  then c0tx=tx  c0ty=ty  c0on=1  end
    if slot == 1  then c1tx=tx  c1ty=ty  c1on=1  end
    if slot == 2  then c2tx=tx  c2ty=ty  c2on=1  end
    if slot == 3  then c3tx=tx  c3ty=ty  c3on=1  end
    if slot == 4  then c4tx=tx  c4ty=ty  c4on=1  end
    if slot == 5  then c5tx=tx  c5ty=ty  c5on=1  end
    if slot == 6  then c6tx=tx  c6ty=ty  c6on=1  end
    if slot == 7  then c7tx=tx  c7ty=ty  c7on=1  end
    if slot == 8  then c8tx=tx  c8ty=ty  c8on=1  end
    if slot == 9  then c9tx=tx  c9ty=ty  c9on=1  end
    if slot == 10 then c10tx=tx c10ty=ty c10on=1 end
    if slot == 11 then c11tx=tx c11ty=ty c11on=1 end
end

func loadCoins(lv)
    if lv == 1 then
        placeCoin(0,  3, 13)  placeCoin(1,  5, 13)
        placeCoin(2,  7,  3)  placeCoin(3,  9,  3)
        placeCoin(4, 12, 13)  placeCoin(5, 14, 13)
        placeCoin(6, 16,  6)  placeCoin(7, 18,  6)
        placeCoin(8,  8,  9)  placeCoin(9, 10,  9)
        placeCoin(10,20, 13)  placeCoin(11,22, 13)
    end
    if lv == 2 then
        placeCoin(0,  3, 13)  placeCoin(1,  6,  2)
        placeCoin(2,  9, 13)  placeCoin(3, 12,  4)
        placeCoin(4, 15, 13)  placeCoin(5, 18,  4)
        placeCoin(6,  4,  4)  placeCoin(7,  7, 13)
        placeCoin(8, 11, 13)  placeCoin(9, 13,  7)
        placeCoin(10,17, 13)  placeCoin(11,21, 13)
    end
    if lv == 3 then
        placeCoin(0,  2, 13)  placeCoin(1,  5,  1)
        placeCoin(2,  8, 13)  placeCoin(3, 11,  3)
        placeCoin(4, 14, 13)  placeCoin(5, 17,  1)
        placeCoin(6,  3,  8)  placeCoin(7,  6, 13)
        placeCoin(8, 10, 13)  placeCoin(9, 13,  6)
        placeCoin(10,16, 13)  placeCoin(11,20, 13)
    end
end

func countCoins()
    let n=0
    if c0on==1 then n=n+1 end   if c1on==1 then n=n+1 end
    if c2on==1 then n=n+1 end   if c3on==1 then n=n+1 end
    if c4on==1 then n=n+1 end   if c5on==1 then n=n+1 end
    if c6on==1 then n=n+1 end   if c7on==1 then n=n+1 end
    if c8on==1 then n=n+1 end   if c9on==1 then n=n+1 end
    if c10on==1 then n=n+1 end  if c11on==1 then n=n+1 end
    return n
end

-- ── Enemies (6 slots per level) ───────────────────────────
-- patrol left-right between walls
let e0x=0 let e0y=0 let e0vx=0 let e0on=0
let e1x=0 let e1y=0 let e1vx=0 let e1on=0
let e2x=0 let e2y=0 let e2vx=0 let e2on=0
let e3x=0 let e3y=0 let e3vx=0 let e3on=0
let e4x=0 let e4y=0 let e4vx=0 let e4on=0
let e5x=0 let e5y=0 let e5vx=0 let e5on=0

func placeEnemy(slot, tx, ty)
    let wx = tx * TS + 4
    let wy = ty * TS - 16
    if slot == 0 then e0x=wx e0y=wy e0vx=1 e0on=1 end
    if slot == 1 then e1x=wx e1y=wy e1vx=1 e1on=1 end
    if slot == 2 then e2x=wx e2y=wy e2vx=1 e2on=1 end
    if slot == 3 then e3x=wx e3y=wy e3vx=-1 e3on=1 end
    if slot == 4 then e4x=wx e4y=wy e4vx=1 e4on=1 end
    if slot == 5 then e5x=wx e5y=wy e5vx=-1 e5on=1 end
end

func loadEnemies(lv)
    e0on=0 e1on=0 e2on=0 e3on=0 e4on=0 e5on=0
    if lv == 1 then
        placeEnemy(0,  6, 15)
        placeEnemy(1, 15, 15)
        placeEnemy(2, 20, 15)
    end
    if lv == 2 then
        placeEnemy(0,  4, 15)
        placeEnemy(1, 10, 15)
        placeEnemy(2, 17, 15)
        placeEnemy(3,  7,  4)
    end
    if lv == 3 then
        placeEnemy(0,  3, 15)
        placeEnemy(1,  9, 15)
        placeEnemy(2, 15, 15)
        placeEnemy(3, 21, 15)
        placeEnemy(4,  6,  1)
        placeEnemy(5, 18,  1)
    end
end

-- ── Player ────────────────────────────────────────────────
let PW = 14   -- player width
let PH = 20   -- player height

let px    = 48.0   -- pixel position
let py    = 312.0
let pvx   = 0.0
let pvy   = 0.0
let onGround  = 0
let coyote    = 0    -- coyote time frames
let jumpHeld  = 0    -- for variable jump height
let facing    = 1    -- 1=right -1=left
let pframe    = 0    -- animation frame
let pdead     = 0
let deadTimer = 0

-- ── Game state ────────────────────────────────────────────
let lives   = 3
let score   = 0
let hiScore = 0
let level   = 1
let frame   = 0
let running = 1

-- Physics constants
let GRAVITY   = 0.42
let JUMPFORCE = 8.2
let WALKSPD   = 2.4
let RUNSPD    = 4.0
let FRICTION  = 0.78
let MAXFALL   = 12.0

-- ── Resolve collision for one axis ────────────────────────
-- Move player by (dx,0) then push out of tiles
func moveX(dx)
    px = px + dx
    -- Test left and right edges at 3 heights
    let top    = py + 2
    let mid    = py + PH / 2
    let bot    = py + PH - 2
    if dx > 0 then
        -- moving right: test right edge
        let rx = px + PW
        if solidAt(rx, top) == 1 or solidAt(rx, mid) == 1 or solidAt(rx, bot) == 1 then
            px = floor(rx / TS) * TS - PW - 0.01
            pvx = 0
        end
    end
    if dx < 0 then
        -- moving left: test left edge
        if solidAt(px, top) == 1 or solidAt(px, mid) == 1 or solidAt(px, bot) == 1 then
            px = floor(px / TS + 1) * TS + 0.01
            pvx = 0
        end
    end
end

func moveY(dy)
    py = py + dy
    if dy > 0 then
        -- falling: test bottom edge
        let by = py + PH
        let lx = px + 2
        let rx = px + PW - 2
        if solidAt(lx, by) == 1 or solidAt(rx, by) == 1 then
            py = floor(by / TS) * TS - PH - 0.01
            pvy = 0
            onGround = 1
            coyote   = 6
        end
    end
    if dy < 0 then
        -- rising: test top edge
        let lx = px + 2
        let rx = px + PW - 2
        if solidAt(lx, py) == 1 or solidAt(rx, py) == 1 then
            py = floor(py / TS + 1) * TS + 0.01
            pvy = 0
            jumpHeld = 0
        end
    end
end

-- ── Draw one tile ─────────────────────────────────────────
func drawTile(tx, ty, camX)
    let sx = tx * TS - camX
    if sx < -TS then return end
    if sx > SW  then return end
    -- outer block
    color(80, 140, 80)
    draw rect(sx, ty * TS, TS, TS)
    -- top highlight
    color(110, 180, 100)
    draw rect(sx, ty * TS, TS, 3)
    -- left highlight
    draw rect(sx, ty * TS, 3, TS)
    -- inner shadow
    color(55, 100, 55)
    draw rect(sx + TS - 3, ty * TS + 3, 3, TS - 3)
    draw rect(sx + 3, ty * TS + TS - 3, TS - 3, 3)
    -- brick pattern
    color(65, 115, 65)
    if ty % 2 == 0 then
        draw rect(sx + TS/2, ty * TS + 4, 1, TS - 8)
    else
        draw rect(sx + 4, ty * TS + 4, 1, TS - 8)
        draw rect(sx + TS - 5, ty * TS + 4, 1, TS - 8)
    end
end

-- ── Draw the level ────────────────────────────────────────
func drawLevel(camX)
    let row = 0
    while row < ROWS do
        let col = 0
        while col < COLS do
            if isSolid(col, row) == 1 then
                drawTile(col, row, camX)
            end
            col = col + 1
        end
        row = row + 1
    end
end

-- ── Draw coins ────────────────────────────────────────────
func drawCoins(camX)
    let spin = frame % 20
    let cw = 8
    if spin > 10 then cw = floor(8 - (spin - 10)) end
    if spin <= 10 then cw = floor(spin - 2) end
    if cw < 1 then cw = 1 end
    if cw > 8 then cw = 8 end

    if c0on==1 then color(255,210,40) draw rect(c0tx*TS+camX*0+8-cw/2-camX, c0ty*TS+4, cw, 14) end
    if c1on==1 then color(255,210,40) draw rect(c1tx*TS+8-cw/2-camX, c1ty*TS+4, cw, 14) end
    if c2on==1 then color(255,210,40) draw rect(c2tx*TS+8-cw/2-camX, c2ty*TS+4, cw, 14) end
    if c3on==1 then color(255,210,40) draw rect(c3tx*TS+8-cw/2-camX, c3ty*TS+4, cw, 14) end
    if c4on==1 then color(255,210,40) draw rect(c4tx*TS+8-cw/2-camX, c4ty*TS+4, cw, 14) end
    if c5on==1 then color(255,210,40) draw rect(c5tx*TS+8-cw/2-camX, c5ty*TS+4, cw, 14) end
    if c6on==1 then color(255,210,40) draw rect(c6tx*TS+8-cw/2-camX, c6ty*TS+4, cw, 14) end
    if c7on==1 then color(255,210,40) draw rect(c7tx*TS+8-cw/2-camX, c7ty*TS+4, cw, 14) end
    if c8on==1 then color(255,210,40) draw rect(c8tx*TS+8-cw/2-camX, c8ty*TS+4, cw, 14) end
    if c9on==1 then color(255,210,40) draw rect(c9tx*TS+8-cw/2-camX, c9ty*TS+4, cw, 14) end
    if c10on==1 then color(255,210,40) draw rect(c10tx*TS+8-cw/2-camX, c10ty*TS+4, cw, 14) end
    if c11on==1 then color(255,210,40) draw rect(c11tx*TS+8-cw/2-camX, c11ty*TS+4, cw, 14) end
end

-- ── Draw enemies ──────────────────────────────────────────
func drawEnemy(ex, ey, eon, camX)
    if eon == 0 then return end
    let sx = floor(ex) - camX
    -- body
    color(220, 60, 60)
    draw rect(sx, floor(ey), 16, 16)
    -- eyes (direction-aware)
    color(255, 255, 255)
    draw rect(sx + 3, floor(ey) + 4, 4, 4)
    draw rect(sx + 9, floor(ey) + 4, 4, 4)
    color(0, 0, 0)
    draw rect(sx + 4, floor(ey) + 5, 2, 2)
    draw rect(sx + 10, floor(ey) + 5, 2, 2)
    -- feet animation
    let legOff = floor(abs(sin(frame * 0.2 + ex * 0.1)) * 3)
    color(180, 40, 40)
    draw rect(sx + 2, floor(ey) + 14, 4, 2 + legOff)
    draw rect(sx + 10, floor(ey) + 14, 4, 2 + floor(legOff * 0))
end

-- ── Draw player ───────────────────────────────────────────
func drawPlayer(camX)
    let sx = floor(px) - camX
    let sy = floor(py)

    if pdead == 1 then
        -- spinning death
        let spin2 = deadTimer % 8
        color(255, 100, 100)
        draw rect(sx + spin2, sy, PW - spin2*2, PH)
        return
    end

    -- shadow
    color(0, 80, 0)
    draw rect(sx + 2, sy + PH, PW - 4, 3)

    -- body
    color(60, 120, 220)
    draw rect(sx, sy + 6, PW, PH - 6)

    -- head
    color(240, 200, 160)
    draw rect(sx + 2, sy, PW - 4, 10)

    -- eyes
    color(40, 40, 40)
    if facing == 1 then
        draw rect(sx + 8, sy + 3, 3, 3)
    else
        draw rect(sx + 3, sy + 3, 3, 3)
    end

    -- hair
    color(80, 50, 20)
    draw rect(sx + 2, sy, PW - 4, 3)

    -- legs (walk animation)
    let legSwing = 0
    if onGround == 1 then
        legSwing = floor(sin(pframe * 0.3) * 4)
    end
    color(30, 80, 160)
    draw rect(sx + 2, sy + PH - 6, 4, 6 + legSwing)
    draw rect(sx + PW - 6, sy + PH - 6, 4, 6 - legSwing)

    -- shoes
    color(50, 35, 20)
    draw rect(sx,      sy + PH + legSwing,     6, 3)
    draw rect(sx + PW - 6, sy + PH - legSwing, 6, 3)

    -- arms
    color(60, 120, 220)
    if onGround == 0 then
        -- arms out when airborne
        draw rect(sx - 4, sy + 8, 5, 3)
        draw rect(sx + PW - 1, sy + 8, 5, 3)
    else
        draw rect(sx - 3, sy + 9 + legSwing/2, 4, 3)
        draw rect(sx + PW - 1, sy + 9 - legSwing/2, 4, 3)
    end
end

-- ── Draw HUD ──────────────────────────────────────────────
func drawHUD()
    -- top bar bg
    color(0, 0, 0)
    draw rect(0, 0, SW, 24)
    color(20, 20, 20)
    draw rect(0, 23, SW, 1)

    -- lives
    let i = 0
    while i < lives do
        color(60, 120, 220)
        draw rect(8 + i * 18, 4, 10, 14)
        color(240, 200, 160)
        draw rect(10 + i * 18, 2, 6, 8)
        i = i + 1
    end

    -- score
    color(255, 220, 50)
    draw text("SCORE " + tostr(score), 80, 6)

    -- hi score
    color(180, 180, 220)
    draw text("BEST " + tostr(hiScore), 220, 6)

    -- level
    color(100, 220, 100)
    draw text("LEVEL " + tostr(level) + "/3", 370, 6)

    -- coins remaining
    let coinsLeft = countCoins()
    color(255, 210, 40)
    draw text("COINS " + tostr(12 - coinsLeft) + "/12", 480, 6)
end

-- ── Draw background sky ───────────────────────────────────
func drawBG()
    -- sky gradient (top darker, horizon lighter)
    color(20, 80, 160)
    draw rect(0, 24, SW, 100)
    color(40, 110, 200)
    draw rect(0, 124, SW, 100)
    color(80, 150, 220)
    draw rect(0, 224, SW, 176)

    -- clouds
    let cx = frame % 700
    color(220, 230, 255)
    draw rect(SW - cx + 10, 40, 60, 18)
    draw rect(SW - cx + 20, 32, 40, 14)
    draw rect(SW - cx + 0,  46, 30, 10)
    draw rect(SW - cx + 300, 60, 80, 20)
    draw rect(SW - cx + 310, 50, 50, 16)
end

-- ── Coin collection check ─────────────────────────────────
func checkCoins()
    let pcx = px + PW / 2
    let pcy = py + PH / 2
    let R = TS * 0.8
    if c0on==1  and abs(pcx - (c0tx*TS+12))  < R and abs(pcy - (c0ty*TS+12))  < R then c0on=0  score=score+100 tone(880,60,0.4,0) end
    if c1on==1  and abs(pcx - (c1tx*TS+12))  < R and abs(pcy - (c1ty*TS+12))  < R then c1on=0  score=score+100 tone(988,60,0.4,0) end
    if c2on==1  and abs(pcx - (c2tx*TS+12))  < R and abs(pcy - (c2ty*TS+12))  < R then c2on=0  score=score+100 tone(880,60,0.4,0) end
    if c3on==1  and abs(pcx - (c3tx*TS+12))  < R and abs(pcy - (c3ty*TS+12))  < R then c3on=0  score=score+100 tone(988,60,0.4,0) end
    if c4on==1  and abs(pcx - (c4tx*TS+12))  < R and abs(pcy - (c4ty*TS+12))  < R then c4on=0  score=score+100 tone(880,60,0.4,0) end
    if c5on==1  and abs(pcx - (c5tx*TS+12))  < R and abs(pcy - (c5ty*TS+12))  < R then c5on=0  score=score+100 tone(988,60,0.4,0) end
    if c6on==1  and abs(pcx - (c6tx*TS+12))  < R and abs(pcy - (c6ty*TS+12))  < R then c6on=0  score=score+100 tone(880,60,0.4,0) end
    if c7on==1  and abs(pcx - (c7tx*TS+12))  < R and abs(pcy - (c7ty*TS+12))  < R then c7on=0  score=score+100 tone(988,60,0.4,0) end
    if c8on==1  and abs(pcx - (c8tx*TS+12))  < R and abs(pcy - (c8ty*TS+12))  < R then c8on=0  score=score+100 tone(880,60,0.4,0) end
    if c9on==1  and abs(pcx - (c9tx*TS+12))  < R and abs(pcy - (c9ty*TS+12))  < R then c9on=0  score=score+100 tone(988,60,0.4,0) end
    if c10on==1 and abs(pcx - (c10tx*TS+12)) < R and abs(pcy - (c10ty*TS+12)) < R then c10on=0 score=score+100 tone(880,60,0.4,0) end
    if c11on==1 and abs(pcx - (c11tx*TS+12)) < R and abs(pcy - (c11ty*TS+12)) < R then c11on=0 score=score+100 tone(1100,80,0.5,0) end
end

-- ── Enemy update + collision ──────────────────────────────
func updateEnemy(slot)
    let ex=0 let ey=0 let evx=0 let eon=0
    if slot==0 then ex=e0x ey=e0y evx=e0vx eon=e0on end
    if slot==1 then ex=e1x ey=e1y evx=e1vx eon=e1on end
    if slot==2 then ex=e2x ey=e2y evx=e2vx eon=e2on end
    if slot==3 then ex=e3x ey=e3y evx=e3vx eon=e3on end
    if slot==4 then ex=e4x ey=e4y evx=e4vx eon=e4on end
    if slot==5 then ex=e5x ey=e5y evx=e5vx eon=e5on end
    if eon == 0 then return end

    -- move
    ex = ex + evx

    -- turn around at walls
    if solidAt(ex, ey + 8) == 1 or solidAt(ex + 16, ey + 8) == 1 then
        evx = 0 - evx
        ex = ex + evx * 2
    end

    -- also turn at ledge edges
    if solidAt(ex + 8, ey + 17) == 0 then
        evx = 0 - evx
    end

    -- store back
    if slot==0 then e0x=ex e0y=ey e0vx=evx end
    if slot==1 then e1x=ex e1y=ey e1vx=evx end
    if slot==2 then e2x=ex e2y=ey e2vx=evx end
    if slot==3 then e3x=ex e3y=ey e3vx=evx end
    if slot==4 then e4x=ex e4y=ey e4vx=evx end
    if slot==5 then e5x=ex e5y=ey e5vx=evx end

    -- hit player?
    if pdead == 1 then return end
    let dx = abs(px + PW/2 - (ex + 8))
    let dy = abs(py + PH/2 - (ey + 8))
    if dx < 14 and dy < 14 then
        -- stomp from above?
        if pvy > 0 and py + PH < ey + 8 then
            -- stomp kill
            if slot==0 then e0on=0 end
            if slot==1 then e1on=0 end
            if slot==2 then e2on=0 end
            if slot==3 then e3on=0 end
            if slot==4 then e4on=0 end
            if slot==5 then e5on=0 end
            pvy = -6.0
            score = score + 200
            tone(660, 80, 0.4, 1)
        else
            pdead    = 1
            deadTimer = 50
            lives = lives - 1
            tone(200, 60, 0.6, 2)
            beep(150, 40)
        end
    end
end

-- ── Save hi-score ─────────────────────────────────────────
func saveScore()
    let path = path_join(scriptParent, "jumpy_save.txt")
    if score > hiScore then
        hiScore = score
        writeFile(path, tostr(hiScore))
    end
end

func loadScore()
    let path = path_join(scriptParent, "jumpy_save.txt")
    if path_exists(path) == 1 then
        let s = readFile(path)
        hiScore = tonum(s)
    end
end

-- ── Level transition ──────────────────────────────────────
func nextLevel()
    level = level + 1
    if level > 3 then
        -- win!
        running = 0
        return
    end
    loadLevel(level)
    loadCoins(level)
    loadEnemies(level)
    px = 48.0
    py = 312.0
    pvx = 0.0
    pvy = 0.0
    onGround = 0
    -- fanfare
    chord(523, 659, 784, 400, 0.4)
end

-- ═══════════════════════════
--  INIT
-- ═══════════════════════════
loadScore()
loadLevel(1)
loadCoins(1)
loadEnemies(1)

-- intro jingle
tone(261, 100, 0.3, 0)
tone(329, 100, 0.3, 0)
tone(392, 100, 0.3, 0)
tone(523, 200, 0.5, 0)

-- ═══════════════════════════
--  MAIN LOOP
-- ═══════════════════════════
while running == 1 do
    frame = frame + 1

    if keydown(KEY_ESC) == 1 then
        saveScore()
        running = 0
    end

    -- ── Camera ──────────────────────────────────────────
    -- smooth follow, clamped to world bounds
    let worldW  = COLS * TS
    let targetX = floor(px) - SW / 2 + PW / 2
    if targetX < 0 then targetX = 0 end
    if targetX > worldW - SW then targetX = worldW - SW end
    -- use targetX directly (no smoothing variable to avoid float drift)
    let camX = targetX

    -- ── Dead player handling ─────────────────────────────
    if pdead == 1 then
        deadTimer = deadTimer - 1
        if deadTimer <= 0 then
            if lives <= 0 then
                saveScore()
                running = 0
            else
                -- respawn
                pdead = 0
                px = 48.0
                py = 312.0
                pvx = 0.0
                pvy = 0.0
                onGround = 0
            end
        end

        -- still render while dying
        drawBG()
        drawLevel(camX)
        drawCoins(camX)
        drawEnemy(e0x,e0y,e0on,camX) drawEnemy(e1x,e1y,e1on,camX)
        drawEnemy(e2x,e2y,e2on,camX) drawEnemy(e3x,e3y,e3on,camX)
        drawEnemy(e4x,e4y,e4on,camX) drawEnemy(e5x,e5y,e5on,camX)
        drawPlayer(camX)
        drawHUD()
        sleep(16)
        -- skip rest of loop
        frame = frame + 0
    else

    -- ── Input ────────────────────────────────────────────
    let moving = 0
    let spd = WALKSPD
    if keydown(KEY_SHIFT) == 1 then spd = RUNSPD end

    if keydown(KEY_LEFT) == 1 then
        pvx = pvx - spd * 0.4
        if pvx < 0 - spd then pvx = 0 - spd end
        facing = -1
        moving = 1
    end
    if keydown(KEY_RIGHT) == 1 then
        pvx = pvx + spd * 0.4
        if pvx > spd then pvx = spd end
        facing = 1
        moving = 1
    end

    -- Jump (coyote time + variable height)
    if keydown(KEY_SPACE) == 1 or keydown(KEY_UP) == 1 then
        if coyote > 0 and jumpHeld == 0 then
            pvy       = 0 - JUMPFORCE
            onGround  = 0
            coyote    = 0
            jumpHeld  = 1
            tone(523, 60, 0.3, 0)
        end
        -- hold jump for extra height
        if jumpHeld == 1 and pvy < -2 then
            pvy = pvy - 0.3
        end
    else
        jumpHeld = 0
    end

    -- ── Physics ──────────────────────────────────────────
    -- gravity
    pvy = pvy + GRAVITY
    if pvy > MAXFALL then pvy = MAXFALL end

    -- friction when on ground
    if onGround == 1 then
        pvx = pvx * FRICTION
        if moving == 1 then pframe = pframe + 1 end
    else
        pvx = pvx * 0.92
    end

    -- reset ground flag (will be re-set by moveY if needed)
    onGround = 0
    coyote   = coyote - 1
    if coyote < 0 then coyote = 0 end

    -- move X then Y separately
    moveX(pvx)
    moveY(pvy)

    -- fell out of world = die
    if py > ROWS * TS + 40 then
        pdead     = 1
        deadTimer = 50
        lives     = lives - 1
        beep(200, 30) beep(140, 40) beep(90, 60)
    end

    -- ── Enemy update ─────────────────────────────────────
    updateEnemy(0) updateEnemy(1) updateEnemy(2)
    updateEnemy(3) updateEnemy(4) updateEnemy(5)

    -- ── Coin pickup ──────────────────────────────────────
    checkCoins()

    -- ── Level complete? ───────────────────────────────────
    if countCoins() == 0 then
        score = score + 500
        nextLevel()
    end

    -- ── Render ───────────────────────────────────────────
    drawBG()
    drawLevel(camX)
    drawCoins(camX)
    drawEnemy(e0x,e0y,e0on,camX) drawEnemy(e1x,e1y,e1on,camX)
    drawEnemy(e2x,e2y,e2on,camX) drawEnemy(e3x,e3y,e3on,camX)
    drawEnemy(e4x,e4y,e4on,camX) drawEnemy(e5x,e5y,e5on,camX)
    drawPlayer(camX)
    drawHUD()

    end  -- end pdead else branch
    sleep(16)
end

-- ═══════════════════════════
--  END SCREEN
-- ═══════════════════════════
saveScore()
let won = 0
if level > 3 then won = 1 end

let t = 0
while t < 300 do
    color(10, 20, 40)
    clear()

    -- stars
    let si = 0
    while si < 40 do
        let ssx = floor(abs(sin(si*137.5))*638)+1
        let ssy = floor(abs(cos(si*251.3+t*0.05))*398)+1
        color(150,150,200) draw rect(ssx,ssy,2,2)
        si = si + 1
    end

    if t % 26 < 16 then
        if won == 1 then
            color(100, 255, 150)
            draw text("YOU  WIN!", 230, 140)
            if t == 1 then
                chord(523, 659, 784, 300, 0.4)
                chord(659, 784, 988, 300, 0.4)
                chord(784, 988, 1047, 500, 0.5)
            end
        else
            color(255, 80, 80)
            draw text("GAME  OVER", 210, 140)
        end
        color(255, 220, 50)
        draw text("SCORE  " + tostr(score), 244, 178)
        color(180, 180, 255)
        draw text("BEST   " + tostr(hiScore), 244, 200)
        color(120, 120, 160)
        draw text("close window to exit", 196, 236)
    end

    t = t + 1
    sleep(16)
end
