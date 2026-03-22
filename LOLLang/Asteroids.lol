-- mode:window
-- ============================================================
--  ASTEROIDS v2  -  polished edition
--  WASD/arrows=thrust & rotate  SPACE=shoot  ESC=quit
-- ============================================================
window("ASTEROIDS v2", 600, 600)

let KEY_W=87 let KEY_A=65 let KEY_D=68 let KEY_S=83
let KEY_UP=38 let KEY_LEFT=37 let KEY_RIGHT=39
let KEY_SPACE=32 let KEY_ESC=27

-- Player
let px=300 let py=300 let pvx=0 let pvy=0
let pang=0 let salive=1 let respawnt=0 let iframes=0

-- Bullets (6)
let u0x=0 let u0y=0 let u0vx=0 let u0vy=0 let u0on=0 let u0l=0
let u1x=0 let u1y=0 let u1vx=0 let u1vy=0 let u1on=0 let u1l=0
let u2x=0 let u2y=0 let u2vx=0 let u2vy=0 let u2on=0 let u2l=0
let u3x=0 let u3y=0 let u3vx=0 let u3vy=0 let u3on=0 let u3l=0
let u4x=0 let u4y=0 let u4vx=0 let u4vy=0 let u4on=0 let u4l=0
let u5x=0 let u5y=0 let u5vx=0 let u5vy=0 let u5on=0 let u5l=0

-- Asteroids (10)
let a0x=0 let a0y=0 let a0vx=0 let a0vy=0 let a0r=0 let a0on=0 let a0ang=0 let a0sp=0
let a1x=0 let a1y=0 let a1vx=0 let a1vy=0 let a1r=0 let a1on=0 let a1ang=0 let a1sp=0
let a2x=0 let a2y=0 let a2vx=0 let a2vy=0 let a2r=0 let a2on=0 let a2ang=0 let a2sp=0
let a3x=0 let a3y=0 let a3vx=0 let a3vy=0 let a3r=0 let a3on=0 let a3ang=0 let a3sp=0
let a4x=0 let a4y=0 let a4vx=0 let a4vy=0 let a4r=0 let a4on=0 let a4ang=0 let a4sp=0
let a5x=0 let a5y=0 let a5vx=0 let a5vy=0 let a5r=0 let a5on=0 let a5ang=0 let a5sp=0
let a6x=0 let a6y=0 let a6vx=0 let a6vy=0 let a6r=0 let a6on=0 let a6ang=0 let a6sp=0
let a7x=0 let a7y=0 let a7vx=0 let a7vy=0 let a7r=0 let a7on=0 let a7ang=0 let a7sp=0
let a8x=0 let a8y=0 let a8vx=0 let a8vy=0 let a8r=0 let a8on=0 let a8ang=0 let a8sp=0
let a9x=0 let a9y=0 let a9vx=0 let a9vy=0 let a9r=0 let a9on=0 let a9ang=0 let a9sp=0

-- Particles (12 explosion dots)
let p0x=0 let p0y=0 let p0vx=0 let p0vy=0 let p0l=0
let p1x=0 let p1y=0 let p1vx=0 let p1vy=0 let p1l=0
let p2x=0 let p2y=0 let p2vx=0 let p2vy=0 let p2l=0
let p3x=0 let p3y=0 let p3vx=0 let p3vy=0 let p3l=0
let p4x=0 let p4y=0 let p4vx=0 let p4vy=0 let p4l=0
let p5x=0 let p5y=0 let p5vx=0 let p5vy=0 let p5l=0
let p6x=0 let p6y=0 let p6vx=0 let p6vy=0 let p6l=0
let p7x=0 let p7y=0 let p7vx=0 let p7vy=0 let p7l=0
let p8x=0 let p8y=0 let p8vx=0 let p8vy=0 let p8l=0
let p9x=0 let p9y=0 let p9vx=0 let p9vy=0 let p9l=0
let p10x=0 let p10y=0 let p10vx=0 let p10vy=0 let p10l=0
let p11x=0 let p11y=0 let p11vx=0 let p11vy=0 let p11l=0

-- Game state
let score=0 let lives=3 let frame=0 let shootcd=0 let dead=0
let wavepause=0 let wave=0 let MSIZE=16

func wrap(v,lo,hi)
    let r=hi-lo
    while v<lo do v=v+r end
    while v>=hi do v=v-r end
    return v
end
func dist(ax,ay,bx,by)
    let dx=ax-bx let dy=ay-by return sqrt(dx*dx+dy*dy)
end
func rnd(lo,hi)
    let r=abs(sin(frame*2.3+lo*7.1+score*0.9))
    return lo+floor(r*(hi-lo+1))
end

func spawnParticles(ex,ey,num)
    let i=0
    while i<num do
        let ang=rnd(0,360)*0.01745
        let spd=rnd(1,4)
        let vx2=sin(ang)*spd let vy2=0-cos(ang)*spd
        if p0l==0 then p0x=ex p0y=ey p0vx=vx2 p0vy=vy2 p0l=25 end
        if p1l==0 then p1x=ex p1y=ey p1vx=vx2 p1vy=vy2 p1l=25 end
        if p2l==0 then p2x=ex p2y=ey p2vx=vx2 p2vy=vy2 p2l=22 end
        if p3l==0 then p3x=ex p3y=ey p3vx=vx2 p3vy=vy2 p3l=20 end
        if p4l==0 then p4x=ex p4y=ey p4vx=vx2 p4vy=vy2 p4l=18 end
        if p5l==0 then p5x=ex p5y=ey p5vx=vx2 p5vy=vy2 p5l=16 end
        i=i+1
    end
end

func spawnAst(ax,ay,avx,avy,ar)
    let sp=rnd(1,3)
    if rnd(0,1)==0 then sp=0-sp end
    if a0on==0 then a0x=ax a0y=ay a0vx=avx a0vy=avy a0r=ar a0on=1 a0ang=0 a0sp=sp return end
    if a1on==0 then a1x=ax a1y=ay a1vx=avx a1vy=avy a1r=ar a1on=1 a1ang=0 a1sp=sp return end
    if a2on==0 then a2x=ax a2y=ay a2vx=avx a2vy=avy a2r=ar a2on=1 a2ang=0 a2sp=sp return end
    if a3on==0 then a3x=ax a3y=ay a3vx=avx a3vy=avy a3r=ar a3on=1 a3ang=0 a3sp=sp return end
    if a4on==0 then a4x=ax a4y=ay a4vx=avx a4vy=avy a4r=ar a4on=1 a4ang=0 a4sp=sp return end
    if a5on==0 then a5x=ax a5y=ay a5vx=avx a5vy=avy a5r=ar a5on=1 a5ang=0 a5sp=sp return end
    if a6on==0 then a6x=ax a6y=ay a6vx=avx a6vy=avy a6r=ar a6on=1 a6ang=0 a6sp=sp return end
    if a7on==0 then a7x=ax a7y=ay a7vx=avx a7vy=avy a7r=ar a7on=1 a7ang=0 a7sp=sp return end
    if a8on==0 then a8x=ax a8y=ay a8vx=avx a8vy=avy a8r=ar a8on=1 a8ang=0 a8sp=sp return end
    if a9on==0 then a9x=ax a9y=ay a9vx=avx a9vy=avy a9r=ar a9on=1 a9ang=0 a9sp=sp return end
end

func spawnWave()
    wave=wave+1
    let count=3+wave
    if count>8 then count=8 end
    let i=0
    while i<count do
        let edge=rnd(0,3)
        let ax=0 let ay=0
        if edge==0 then ax=rnd(0,600) ay=0 end
        if edge==1 then ax=rnd(0,600) ay=600 end
        if edge==2 then ax=0 ay=rnd(0,600) end
        if edge==3 then ax=600 ay=rnd(0,600) end
        let spd=rnd(1,2)
        let avx=rnd(0-spd,spd) let avy=rnd(0-spd,spd)
        if avx==0 then avx=1 end
        if avy==0 then avy=1 end
        spawnAst(ax,ay,avx,avy,38)
        i=i+1
    end
    -- wave start sound
    chord(220,277,330,300,0.3)
end

func shoot()
    let bvx=sin(pang*0.01745)*9
    let bvy=0-cos(pang*0.01745)*9
    if u0on==0 then u0x=px u0y=py u0vx=bvx u0vy=bvy u0on=1 u0l=50 return end
    if u1on==0 then u1x=px u1y=py u1vx=bvx u1vy=bvy u1on=1 u1l=50 return end
    if u2on==0 then u2x=px u2y=py u2vx=bvx u2vy=bvy u2on=1 u2l=50 return end
    if u3on==0 then u3x=px u3y=py u3vx=bvx u3vy=bvy u3on=1 u3l=50 return end
    if u4on==0 then u4x=px u4y=py u4vx=bvx u4vy=bvy u4on=1 u4l=50 return end
    if u5on==0 then u5x=px u5y=py u5vx=bvx u5vy=bvy u5on=1 u5l=50 return end
end

func drawStars()
    let i=0
    while i<50 do
        let sx=floor(abs(sin(i*127.1+0.3))*598)+1
        let sy=floor(abs(cos(i*311.7+0.7))*598)+1
        if i<20 then color(255,255,255) draw rect(sx,sy,2,2)
        else color(90,90,130) draw rect(sx,sy,1,1) end
        i=i+1
    end
end

func drawAst(ax,ay,ar,aang,aon)
    if aon==0 then return end
    color(170,150,120)
    let i=0
    while i<10 do
        let a1=( aang+i*36)*0.01745
        let a2=(aang+(i+1)*36)*0.01745
        let r1=ar-floor(abs(sin(i*1.7+aang*0.1))*ar*0.25)
        let r2=ar-floor(abs(sin((i+1)*1.7+aang*0.1))*ar*0.25)
        let x1=floor(ax+sin(a1)*r1) let y1=floor(ay-cos(a1)*r1)
        let x2=floor(ax+sin(a2)*r2) let y2=floor(ay-cos(a2)*r2)
        draw line(x1,y1,x2,y2)
        i=i+1
    end
    -- crater detail
    color(100,85,65)
    draw rect(floor(ax-ar/3),floor(ay-ar/4),3,3)
    draw rect(floor(ax+ar/5),floor(ay+ar/5),2,2)
end

func drawShip()
    if salive==0 then return end
    if iframes>0 then
        if iframes%8<4 then return end
    end
    let rad=pang*0.01745
    let nx=floor(px+sin(rad)*14) let ny=floor(py-cos(rad)*14)
    let lx=floor(px+sin(rad-2.4)*12) let ly=floor(py-cos(rad-2.4)*12)
    let rx=floor(px+sin(rad+2.4)*12) let ry=floor(py-cos(rad+2.4)*12)
    let bkx=floor(px+sin(rad+3.14)*6) let bky=floor(py-cos(rad+3.14)*6)
    color(80,200,255)
    draw line(nx,ny,lx,ly)
    draw line(nx,ny,rx,ry)
    draw line(lx,ly,bkx,bky)
    draw line(rx,ry,bkx,bky)
    -- thrust flame
    if keydown(KEY_W)==1 or keydown(KEY_UP)==1 then
        let fx=floor(px+sin(rad+3.14)*(12+rnd(2,5)))
        let fy=floor(py-cos(rad+3.14)*(12+rnd(2,5)))
        color(255,floor(rnd(80,180)),20)
        draw line(bkx,bky,fx,fy)
    end
end

func drawParticles()
    if p0l>0 then color(255,200,60) draw rect(floor(p0x),floor(p0y),3,3) end
    if p1l>0 then color(255,160,40) draw rect(floor(p1x),floor(p1y),2,2) end
    if p2l>0 then color(255,220,80) draw rect(floor(p2x),floor(p2y),3,3) end
    if p3l>0 then color(200,120,30) draw rect(floor(p3x),floor(p3y),2,2) end
    if p4l>0 then color(255,180,50) draw rect(floor(p4x),floor(p4y),2,2) end
    if p5l>0 then color(255,100,20) draw rect(floor(p5x),floor(p5y),3,3) end
    if p6l>0 then color(220,200,60) draw rect(floor(p6x),floor(p6y),2,2) end
    if p7l>0 then color(255,140,40) draw rect(floor(p7x),floor(p7y),2,2) end
    if p8l>0 then color(200,160,50) draw rect(floor(p8x),floor(p8y),3,3) end
    if p9l>0 then color(255,200,80) draw rect(floor(p9x),floor(p9y),2,2) end
    if p10l>0 then color(240,120,30) draw rect(floor(p10x),floor(p10y),2,2) end
    if p11l>0 then color(255,240,100) draw rect(floor(p11x),floor(p11y),3,3) end
end

func moveParticles()
    if p0l>0 then p0x=p0x+p0vx p0y=p0y+p0vy p0l=p0l-1 end
    if p1l>0 then p1x=p1x+p1vx p1y=p1y+p1vy p1l=p1l-1 end
    if p2l>0 then p2x=p2x+p2vx p2y=p2y+p2vy p2l=p2l-1 end
    if p3l>0 then p3x=p3x+p3vx p3y=p3y+p3vy p3l=p3l-1 end
    if p4l>0 then p4x=p4x+p4vx p4y=p4y+p4vy p4l=p4l-1 end
    if p5l>0 then p5x=p5x+p5vx p5y=p5y+p5vy p5l=p5l-1 end
    if p6l>0 then p6x=p6x+p6vx p6y=p6y+p6vy p6l=p6l-1 end
    if p7l>0 then p7x=p7x+p7vx p7y=p7y+p7vy p7l=p7l-1 end
    if p8l>0 then p8x=p8x+p8vx p8y=p8y+p8vy p8l=p8l-1 end
    if p9l>0 then p9x=p9x+p9vx p9y=p9y+p9vy p9l=p9l-1 end
    if p10l>0 then p10x=p10x+p10vx p10y=p10y+p10vy p10l=p10l-1 end
    if p11l>0 then p11x=p11x+p11vx p11y=p11y+p11vy p11l=p11l-1 end
end

func splitAst(ax,ay,ar,avx,avy)
    spawnParticles(ax,ay,6)
    if ar>15 then
        let nr=floor(ar/2)
        spawnAst(ax,ay,0-avy,avx,nr)
        spawnAst(ax,ay,avy,0-avx,nr)
        score=score+10
        -- split sound: high ping
        tone(880,60,0.3,0)
    else
        score=score+25
        -- destroy sound: crunch
        tone(220,80,0.4,2)
    end
end

func checkBulletAst(ux,uy,uon)
    if uon==0 then return 0 end
    if a0on==1 then if dist(ux,uy,a0x,a0y)<a0r then splitAst(a0x,a0y,a0r,a0vx,a0vy) a0on=0 return 1 end end
    if a1on==1 then if dist(ux,uy,a1x,a1y)<a1r then splitAst(a1x,a1y,a1r,a1vx,a1vy) a1on=0 return 1 end end
    if a2on==1 then if dist(ux,uy,a2x,a2y)<a2r then splitAst(a2x,a2y,a2r,a2vx,a2vy) a2on=0 return 1 end end
    if a3on==1 then if dist(ux,uy,a3x,a3y)<a3r then splitAst(a3x,a3y,a3r,a3vx,a3vy) a3on=0 return 1 end end
    if a4on==1 then if dist(ux,uy,a4x,a4y)<a4r then splitAst(a4x,a4y,a4r,a4vx,a4vy) a4on=0 return 1 end end
    if a5on==1 then if dist(ux,uy,a5x,a5y)<a5r then splitAst(a5x,a5y,a5r,a5vx,a5vy) a5on=0 return 1 end end
    if a6on==1 then if dist(ux,uy,a6x,a6y)<a6r then splitAst(a6x,a6y,a6r,a6vx,a6vy) a6on=0 return 1 end end
    if a7on==1 then if dist(ux,uy,a7x,a7y)<a7r then splitAst(a7x,a7y,a7r,a7vx,a7vy) a7on=0 return 1 end end
    if a8on==1 then if dist(ux,uy,a8x,a8y)<a8r then splitAst(a8x,a8y,a8r,a8vx,a8vy) a8on=0 return 1 end end
    if a9on==1 then if dist(ux,uy,a9x,a9y)<a9r then splitAst(a9x,a9y,a9r,a9vx,a9vy) a9on=0 return 1 end end
    return 0
end

func checkShipHit()
    if salive==0 then return end
    if iframes>0 then return end
    if a0on==1 then if dist(px,py,a0x,a0y)<a0r-4 then salive=0 end end
    if a1on==1 then if dist(px,py,a1x,a1y)<a1r-4 then salive=0 end end
    if a2on==1 then if dist(px,py,a2x,a2y)<a2r-4 then salive=0 end end
    if a3on==1 then if dist(px,py,a3x,a3y)<a3r-4 then salive=0 end end
    if a4on==1 then if dist(px,py,a4x,a4y)<a4r-4 then salive=0 end end
    if a5on==1 then if dist(px,py,a5x,a5y)<a5r-4 then salive=0 end end
    if a6on==1 then if dist(px,py,a6x,a6y)<a6r-4 then salive=0 end end
    if a7on==1 then if dist(px,py,a7x,a7y)<a7r-4 then salive=0 end end
    if a8on==1 then if dist(px,py,a8x,a8y)<a8r-4 then salive=0 end end
    if a9on==1 then if dist(px,py,a9x,a9y)<a9r-4 then salive=0 end end
end

func countAsts()
    let n=0
    if a0on==1 then n=n+1 end if a1on==1 then n=n+1 end
    if a2on==1 then n=n+1 end if a3on==1 then n=n+1 end
    if a4on==1 then n=n+1 end if a5on==1 then n=n+1 end
    if a6on==1 then n=n+1 end if a7on==1 then n=n+1 end
    if a8on==1 then n=n+1 end if a9on==1 then n=n+1 end
    return n
end

func drawHUD()
    color(255,215,50)  draw text("SCORE "+tostr(score), 8, 8)
    color(100,180,255) draw text("WAVE  "+tostr(wave),  8, 26)
    let i=0
    while i<lives do
        color(80,200,255)
        let lx2=530+i*22
        draw line(lx2+5,10,lx2,18)
        draw line(lx2+5,10,lx2+10,18)
        draw line(lx2,18,lx2+2,16)
        draw line(lx2+10,18,lx2+8,16)
        i=i+1
    end
end

-- ═══════════
--  MAIN LOOP
-- ═══════════
spawnWave()

while dead==0 do
    frame=frame+1
    iframes=iframes-1 if iframes<0 then iframes=0 end

    if keydown(KEY_ESC)==1 then dead=1 end

    if salive==1 then
        if keydown(KEY_LEFT)==1 or keydown(KEY_A)==1 then pang=pang-4 end
        if keydown(KEY_RIGHT)==1 or keydown(KEY_D)==1 then pang=pang+4 end
        pang=wrap(pang,0,360)

        if keydown(KEY_UP)==1 or keydown(KEY_W)==1 then
            pvx=pvx+sin(pang*0.01745)*0.25
            pvy=pvy-cos(pang*0.01745)*0.25
            let spd2=sqrt(pvx*pvx+pvy*pvy)
            if spd2>7 then pvx=pvx/spd2*7 pvy=pvy/spd2*7 end
        end

        shootcd=shootcd-1
        if keydown(KEY_SPACE)==1 then
            if shootcd<=0 then
                shoot()
                shootcd=12
                tone(880,40,0.25,1)
            end
        end
    end

    -- Physics
    if salive==1 then
        px=px+pvx py=py+pvy
        pvx=pvx*0.99 pvy=pvy*0.99
        px=wrap(px,0,600) py=wrap(py,0,600)
    end

    -- Respawn
    if salive==0 then
        if respawnt==0 then
            lives=lives-1
            spawnParticles(px,py,12)
            -- death sound
            beep(200,30) beep(150,30) beep(100,40) beep(60,60)
            if lives<=0 then dead=1
            else respawnt=120 end
        end
    end
    if respawnt>0 then
        respawnt=respawnt-1
        if respawnt==90 then
            px=300 py=300 pvx=0 pvy=0 pang=0 salive=1 iframes=90
        end
    end

    -- Bullets
    if u0on==1 then u0x=wrap(u0x+u0vx,0,600) u0y=wrap(u0y+u0vy,0,600) u0l=u0l-1 if u0l<=0 then u0on=0 end end
    if u1on==1 then u1x=wrap(u1x+u1vx,0,600) u1y=wrap(u1y+u1vy,0,600) u1l=u1l-1 if u1l<=0 then u1on=0 end end
    if u2on==1 then u2x=wrap(u2x+u2vx,0,600) u2y=wrap(u2y+u2vy,0,600) u2l=u2l-1 if u2l<=0 then u2on=0 end end
    if u3on==1 then u3x=wrap(u3x+u3vx,0,600) u3y=wrap(u3y+u3vy,0,600) u3l=u3l-1 if u3l<=0 then u3on=0 end end
    if u4on==1 then u4x=wrap(u4x+u4vx,0,600) u4y=wrap(u4y+u4vy,0,600) u4l=u4l-1 if u4l<=0 then u4on=0 end end
    if u5on==1 then u5x=wrap(u5x+u5vx,0,600) u5y=wrap(u5y+u5vy,0,600) u5l=u5l-1 if u5l<=0 then u5on=0 end end

    -- Asteroids
    if a0on==1 then a0x=wrap(a0x+a0vx,0,600) a0y=wrap(a0y+a0vy,0,600) a0ang=wrap(a0ang+a0sp,0,360) end
    if a1on==1 then a1x=wrap(a1x+a1vx,0,600) a1y=wrap(a1y+a1vy,0,600) a1ang=wrap(a1ang+a1sp,0,360) end
    if a2on==1 then a2x=wrap(a2x+a2vx,0,600) a2y=wrap(a2y+a2vy,0,600) a2ang=wrap(a2ang+a2sp,0,360) end
    if a3on==1 then a3x=wrap(a3x+a3vx,0,600) a3y=wrap(a3y+a3vy,0,600) a3ang=wrap(a3ang+a3sp,0,360) end
    if a4on==1 then a4x=wrap(a4x+a4vx,0,600) a4y=wrap(a4y+a4vy,0,600) a4ang=wrap(a4ang+a4sp,0,360) end
    if a5on==1 then a5x=wrap(a5x+a5vx,0,600) a5y=wrap(a5y+a5vy,0,600) a5ang=wrap(a5ang+a5sp,0,360) end
    if a6on==1 then a6x=wrap(a6x+a6vx,0,600) a6y=wrap(a6y+a6vy,0,600) a6ang=wrap(a6ang+a6sp,0,360) end
    if a7on==1 then a7x=wrap(a7x+a7vx,0,600) a7y=wrap(a7y+a7vy,0,600) a7ang=wrap(a7ang+a7sp,0,360) end
    if a8on==1 then a8x=wrap(a8x+a8vx,0,600) a8y=wrap(a8y+a8vy,0,600) a8ang=wrap(a8ang+a8sp,0,360) end
    if a9on==1 then a9x=wrap(a9x+a9vx,0,600) a9y=wrap(a9y+a9vy,0,600) a9ang=wrap(a9ang+a9sp,0,360) end

    if checkBulletAst(u0x,u0y,u0on)==1 then u0on=0 end
    if checkBulletAst(u1x,u1y,u1on)==1 then u1on=0 end
    if checkBulletAst(u2x,u2y,u2on)==1 then u2on=0 end
    if checkBulletAst(u3x,u3y,u3on)==1 then u3on=0 end
    if checkBulletAst(u4x,u4y,u4on)==1 then u4on=0 end
    if checkBulletAst(u5x,u5y,u5on)==1 then u5on=0 end
    checkShipHit()
    moveParticles()

    if wavepause>0 then
        wavepause=wavepause-1
        if wavepause==0 then spawnWave() end
    else
        if countAsts()==0 then wavepause=90 end
    end

    -- Render
    color(4,4,14) clear()
    drawStars()
    drawAst(a0x,a0y,a0r,a0ang,a0on) drawAst(a1x,a1y,a1r,a1ang,a1on)
    drawAst(a2x,a2y,a2r,a2ang,a2on) drawAst(a3x,a3y,a3r,a3ang,a3on)
    drawAst(a4x,a4y,a4r,a4ang,a4on) drawAst(a5x,a5y,a5r,a5ang,a5on)
    drawAst(a6x,a6y,a6r,a6ang,a6on) drawAst(a7x,a7y,a7r,a7ang,a7on)
    drawAst(a8x,a8y,a8r,a8ang,a8on) drawAst(a9x,a9y,a9r,a9ang,a9on)
    -- bullets
    color(255,255,100)
    if u0on==1 then draw rect(floor(u0x)-1,floor(u0y)-1,3,3) end
    if u1on==1 then draw rect(floor(u1x)-1,floor(u1y)-1,3,3) end
    if u2on==1 then draw rect(floor(u2x)-1,floor(u2y)-1,3,3) end
    if u3on==1 then draw rect(floor(u3x)-1,floor(u3y)-1,3,3) end
    if u4on==1 then draw rect(floor(u4x)-1,floor(u4y)-1,3,3) end
    if u5on==1 then draw rect(floor(u5x)-1,floor(u5y)-1,3,3) end
    drawParticles()
    drawShip()
    drawHUD()

    if wavepause>0 then
        if wavepause%20<12 then
            color(100,255,180) draw text("WAVE CLEAR!", 210, 280)
            color(255,220,80)  draw text("SCORE "+tostr(score), 240, 305)
        end
    end
    sleep(16)
end

-- Game over screen
let t=0
while t<220 do
    color(4,4,14) clear()
    drawStars()
    drawAst(a0x,a0y,a0r,a0ang,a0on)
    drawAst(a1x,a1y,a1r,a1ang,a1on)
    if t<12 then color(255,80,40) draw rect(0,0,600,600) end
    if t%28<18 then
        color(255,70,70)   draw text("GAME  OVER",  208, 260)
        color(255,220,50)  draw text("FINAL SCORE  "+tostr(score), 188, 292)
        color(160,160,210) draw text("close window to exit", 188, 322)
    end
    t=t+1
    sleep(16)
end
