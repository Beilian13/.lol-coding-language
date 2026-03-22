-- mode:window
-- ============================================================
--  DODGE v2  -  avoid the falling blocks
--  A/D or LEFT/RIGHT = move    SHIFT = sprint    ESC = quit
-- ============================================================
window("DODGE v2", 480, 600)

-- Keys
let KEY_A=65 let KEY_D=68 let KEY_LEFT=37 let KEY_RIGHT=39
let KEY_SHIFT=16 let KEY_ESC=27

-- Player
let px=220 let py=540 let pw=40 let ph=14 let pspeed=5

-- Blocks (8 slots)
let b0x=0 let b0y=-60 let b0w=0 let b0s=0 let b0on=0
let b1x=0 let b1y=-60 let b1w=0 let b1s=0 let b1on=0
let b2x=0 let b2y=-60 let b2w=0 let b2s=0 let b2on=0
let b3x=0 let b3y=-60 let b3w=0 let b3s=0 let b3on=0
let b4x=0 let b4y=-60 let b4w=0 let b4s=0 let b4on=0
let b5x=0 let b5y=-60 let b5w=0 let b5s=0 let b5on=0
let b6x=0 let b6y=-60 let b6w=0 let b6s=0 let b6on=0
let b7x=0 let b7y=-60 let b7w=0 let b7s=0 let b7on=0
let bh=16

-- State
let score=0 let dead=0 let frame=0 let spawncd=30
let hiScore=0 let combo=0 let lastScore=0
let shakeX=0 let shakeY=0  -- screen shake

func rnd(lo, hi)
    let r = abs(sin(frame*3.7 + score*13.1 + lo*0.3))
    return lo + floor(r*(hi-lo+1))
end
func clamp(v,lo,hi)
    if v<lo then return lo end
    if v>hi then return hi end
    return v
end

func spawnBlock()
    let bx=rnd(8,432) let bw2=rnd(30,85)
    let spd=rnd(2,4)+floor(score/8)
    if spd>12 then spd=12 end
    if b0on==0 then b0x=bx b0y=-20 b0w=bw2 b0s=spd b0on=1 return end
    if b1on==0 then b1x=bx b1y=-20 b1w=bw2 b1s=spd b1on=1 return end
    if b2on==0 then b2x=bx b2y=-20 b2w=bw2 b2s=spd b2on=1 return end
    if b3on==0 then b3x=bx b3y=-20 b3w=bw2 b3s=spd b3on=1 return end
    if b4on==0 then b4x=bx b4y=-20 b4w=bw2 b4s=spd b4on=1 return end
    if b5on==0 then b5x=bx b5y=-20 b5w=bw2 b5s=spd b5on=1 return end
    if b6on==0 then b6x=bx b6y=-20 b6w=bw2 b6s=spd b6on=1 return end
    if b7on==0 then b7x=bx b7y=-20 b7w=bw2 b7s=spd b7on=1 return end
end

func hits(bx,by,bw2)
    if bx+bw2<px then return 0 end
    if bx>px+pw  then return 0 end
    if by+bh<py  then return 0 end
    if by>py+ph  then return 0 end
    return 1
end

func drawStars()
    let i=0
    while i<50 do
        let sx=floor(abs(sin(i*137.5))*478)+1
        let sy=floor(abs(cos(i*251.3+frame*0.08))*598)+1
        if i<20 then color(255,255,255) draw rect(sx,sy,2,2)
        else color(100,100,150) draw rect(sx,sy,1,1) end
        i=i+1
    end
end

func drawPlayer(ox,oy)
    let g=floor(abs(sin(frame*0.5))*100)+100
    let gd=floor(g/3)
    -- thruster glow
    color(g,gd,255)
    draw rect(px+ox+5,     py+oy+ph,8,5)
    draw rect(px+ox+pw-13, py+oy+ph,8,5)
    -- body
    color(60,180,255)
    draw rect(px+ox, py+oy, pw, ph)
    -- cockpit
    color(200,240,255)
    draw rect(px+ox+pw/2-3, py+oy, 6, 5)
    -- wings
    color(40,130,200)
    draw rect(px+ox,        py+oy+4, 8, ph-4)
    draw rect(px+ox+pw-8,   py+oy+4, 8, ph-4)
end

func drawBlock(bx,by,bw2,bon,ox,oy)
    if bon==0 then return end
    -- glow behind block
    let spd2=b0s
    color(120,20,20)
    draw rect(bx+ox-2, by+oy-2, bw2+4, bh+4)
    -- main face
    color(210,50,50)
    draw rect(bx+ox, by+oy, bw2, bh)
    -- top highlight
    color(255,120,90)
    draw rect(bx+ox+2, by+oy+2, bw2-4, 4)
    -- bottom shadow
    color(110,15,15)
    draw rect(bx+ox, by+oy+bh-3, bw2, 3)
end

func drawHUD()
    -- health/score bar bg
    color(20,20,35)
    draw rect(0,560,480,40)
    -- score
    color(255,215,50)
    draw text("SCORE "+tostr(score), 10, 570)
    -- hi score
    color(160,200,255)
    draw text("BEST "+tostr(hiScore), 180, 570)
    -- combo
    if combo>1 then
        color(255,140,40)
        draw text("x"+tostr(combo)+" COMBO!", 340, 570)
    end
    -- speed indicator
    let bars=floor(score/10)
    if bars>8 then bars=8 end
    let i=0
    while i<bars do
        let bc=floor(i*30)
        color(50+bc, 200-bc, 60)
        draw rect(440+i*4, 568, 3, 20)
        i=i+1
    end
end

-- ════════════
--  GAME LOOP
-- ════════════
-- Intro sound
tone(440,80,0.3,0)
tone(554,80,0.3,0)
tone(659,120,0.4,0)

while dead==0 do
    frame=frame+1
    shakeX=floor(shakeX*0.7)
    shakeY=floor(shakeY*0.7)

    if keydown(KEY_ESC)==1 then dead=1 end

    let spd=pspeed
    if keydown(KEY_SHIFT)==1 then spd=floor(pspeed*1.8) end
    if keydown(KEY_A)==1 or keydown(KEY_LEFT)==1 then px=px-spd end
    if keydown(KEY_D)==1 or keydown(KEY_RIGHT)==1 then px=px+spd end
    px=clamp(px,0,480-pw)

    spawncd=spawncd-1
    if spawncd<=0 then
        spawnBlock()
        spawncd=30-floor(score/4)
        if spawncd<7 then spawncd=7 end
    end

    -- Move blocks
    if b0on==1 then b0y=b0y+b0s if b0y>620 then b0on=0 score=score+1 combo=combo+1 if combo>1 then tone(660+combo*40,60,0.2,1) end end end
    if b1on==1 then b1y=b1y+b1s if b1y>620 then b1on=0 score=score+1 combo=combo+1 end end
    if b2on==1 then b2y=b2y+b2s if b2y>620 then b2on=0 score=score+1 end end
    if b3on==1 then b3y=b3y+b3s if b3y>620 then b3on=0 score=score+1 end end
    if b4on==1 then b4y=b4y+b4s if b4y>620 then b4on=0 score=score+1 end end
    if b5on==1 then b5y=b5y+b5s if b5y>620 then b5on=0 score=score+1 end end
    if b6on==1 then b6y=b6y+b6s if b6y>620 then b6on=0 score=score+1 end end
    if b7on==1 then b7y=b7y+b7s if b7y>620 then b7on=0 score=score+1 end end

    -- Collisions
    if b0on==1 then if hits(b0x,b0y,b0w)==1 then dead=1 end end
    if b1on==1 then if hits(b1x,b1y,b1w)==1 then dead=1 end end
    if b2on==1 then if hits(b2x,b2y,b2w)==1 then dead=1 end end
    if b3on==1 then if hits(b3x,b3y,b3w)==1 then dead=1 end end
    if b4on==1 then if hits(b4x,b4y,b4w)==1 then dead=1 end end
    if b5on==1 then if hits(b5x,b5y,b5w)==1 then dead=1 end end
    if b6on==1 then if hits(b6x,b6y,b6w)==1 then dead=1 end end
    if b7on==1 then if hits(b7x,b7y,b7w)==1 then dead=1 end end

    if score>hiScore then hiScore=score end
    if score>lastScore then lastScore=score end

    -- Render
    let ox=shakeX let oy=shakeY
    color(6,6,18) clear()
    drawStars()
    color(30,30,55) draw line(0,558,480,558)
    drawBlock(b0x,b0y,b0w,b0on,ox,oy)
    drawBlock(b1x,b1y,b1w,b1on,ox,oy)
    drawBlock(b2x,b2y,b2w,b2on,ox,oy)
    drawBlock(b3x,b3y,b3w,b3on,ox,oy)
    drawBlock(b4x,b4y,b4w,b4on,ox,oy)
    drawBlock(b5x,b5y,b5w,b5on,ox,oy)
    drawBlock(b6x,b6y,b6w,b6on,ox,oy)
    drawBlock(b7x,b7y,b7w,b7on,ox,oy)
    drawPlayer(ox,oy)
    drawHUD()
    sleep(16)
end

-- Death sound + screen shake
beep(180,40) beep(120,40) beep(80,60) beep(50,80)

-- Game over
let t=0
while t<200 do
    color(6,6,18) clear()
    drawStars()
    if t<14 then color(200,40,40) draw rect(0,0,480,600) end
    if t%24<15 then
        color(255,70,70)   draw text("GAME  OVER",  152, 230)
        color(255,220,50)  draw text("SCORE  "+tostr(score), 178, 265)
        if score==hiScore then
            color(100,255,180) draw text("NEW BEST!", 183, 295)
        end
        color(160,160,200) draw text("close window to exit", 138, 335)
    end
    t=t+1
    sleep(16)
end
