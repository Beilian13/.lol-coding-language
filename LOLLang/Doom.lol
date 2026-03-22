-- mode:window
-- ============================================================
--  DOOM.LOL  v4  --  Complex Dungeon FPS
--
--  W/S=move  A/D=strafe  MOUSE=look  SHIFT=sprint
--  SPACE=shoot  R=reload  1/2/3=weapons  ESC=quit
-- ============================================================

window("DOOM.LOL  v4", 640, 400)

let SW=640  let SH=400  let HALF=200  let COLS=120
let KEY_W=87  let KEY_S=83  let KEY_A=65  let KEY_D=68
let KEY_LEFT=37  let KEY_RIGHT=39  let KEY_SPACE=32
let KEY_SHIFT=16  let KEY_R=82  let KEY_ESC=27
let KEY_1=49  let KEY_2=50  let KEY_3=51
let KEY_TAB=9
let MSENS=0.0018
let showMap=0  -- toggled by TAB

-- ── Player ───────────────────────────────────────────────
let px=1.5   let py=1.5
let pang=0.0  let pfov=0.66
let pspd=0.10  let tspd=0.028
let phealth=100  let parmor=50

-- ── Weapons ───────────────────────────────────────────────
let weapon=1
let ammo0=50  let ammo1=20  let ammo2=120
let guncd=0  let muzzle=0  let gunframe=0
let reloading=0  let reloadT=0  let bobT=0

-- ── Map 24×24 ────────────────────────────────────────────
let r0  = 16777215   -- 111111111111111111111111
let r1  = 8913409    -- 100000000100000000010001
let r2  = 11500509   -- 101110111101111011110101
let r3  = 8423441    -- 100010000001000100000001
let r4  = 12536309   -- 101011111001001011111101
let r5  = 8390657    -- 100000000001000000000001
let r6  = 16481247   -- 111110111101111011011111
let r7  = 8390657    -- 100000000001000000000001
let r8  = 10206137   -- 100111011101110111011001
let r9  = 8458273    -- 100001000000100010000001
let r10 = 16439215   -- 111101011110101101011111
let r11 = 8651265    -- 100000000100000000100001
let r12 = 12051197   -- 101111110100011111101101
let r13 = 9446017    -- 100000010100010000001001
let r14 = 10858165   -- 101011010111010110100101
let r15 = 8388609    -- 100000000000000000000001
let r16 = 15695095   -- 111011110011111011110111
let r17 = 8651777    -- 100000000010000000100001
let r18 = 12510653   -- 101111011010011101111101
let r19 = 8397857    -- 100001000010010000000001
let r20 = 11712421   -- 101001011110110101001101
let r21 = 8388609    -- 100000000000000000000001
let r22 = 11361749   -- 101010111011101010110101
let r23 = 16777215   -- 111111111111111111111111
let MSIZE=24

-- ── Z-buffer (20 samples) ────────────────────────────────
let zb0=0.0  let zb1=0.0  let zb2=0.0  let zb3=0.0  let zb4=0.0
let zb5=0.0  let zb6=0.0  let zb7=0.0  let zb8=0.0  let zb9=0.0
let zb10=0.0 let zb11=0.0 let zb12=0.0 let zb13=0.0 let zb14=0.0
let zb15=0.0 let zb16=0.0 let zb17=0.0 let zb18=0.0 let zb19=0.0

-- ── Particles (16 slots) ─────────────────────────────────
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
let pt12x=0.0 let pt12y=0.0 let pt12vx=0.0 let pt12vy=0.0 let pt12l=0
let pt13x=0.0 let pt13y=0.0 let pt13vx=0.0 let pt13vy=0.0 let pt13l=0
let pt14x=0.0 let pt14y=0.0 let pt14vx=0.0 let pt14vy=0.0 let pt14l=0
let pt15x=0.0 let pt15y=0.0 let pt15vx=0.0 let pt15vy=0.0 let pt15l=0

-- ── Enemies (16 slots) ────────────────────────────────────
-- type 1=imp  2=soldier  3=heavy  4=boss  5=sniper  6=ghost
-- state 0=idle  1=chase  2=atk  3=pain
let e0x=1.5  let e0y=2.5  let e0hp=0 let e0on=0 let e0t=0 let e0state=0 let e0type=1
let e1x=5.5  let e1y=3.5  let e1hp=0 let e1on=0 let e1t=0 let e1state=0 let e1type=5
let e2x=13.5 let e2y=3.5  let e2hp=0 let e2on=0 let e2t=0 let e2state=0 let e2type=2
let e3x=5.5  let e3y=5.5  let e3hp=0 let e3on=0 let e3t=0 let e3state=0 let e3type=2
let e4x=9.5  let e4y=3.5  let e4hp=0 let e4on=0 let e4t=0 let e4state=0 let e4type=3
let e5x=3.5  let e5y=7.5  let e5hp=0 let e5on=0 let e5t=0 let e5state=0 let e5type=1
let e6x=13.5 let e6y=7.5  let e6hp=0 let e6on=0 let e6t=0 let e6state=0 let e6type=5
let e7x=9.5  let e7y=9.5  let e7hp=0 let e7on=0 let e7t=0 let e7state=0 let e7type=2
let e8x=3.5  let e8y=11.5 let e8hp=0 let e8on=0 let e8t=0 let e8state=0 let e8type=6
let e9x=11.5 let e9y=13.5 let e9hp=0 let e9on=0 let e9t=0 let e9state=0 let e9type=3
let e10x=5.5 let e10y=15.5 let e10hp=0 let e10on=0 let e10t=0 let e10state=0 let e10type=1
let e11x=15.5 let e11y=15.5 let e11hp=0 let e11on=0 let e11t=0 let e11state=0 let e11type=2
let e12x=9.5 let e12y=17.5 let e12hp=0 let e12on=0 let e12t=0 let e12state=0 let e12type=6
let e13x=5.5 let e13y=19.5 let e13hp=0 let e13on=0 let e13t=0 let e13state=0 let e13type=3
let e14x=15.5 let e14y=21.5 let e14hp=0 let e14on=0 let e14t=0 let e14state=0 let e14type=2
let e15x=11.5 let e15y=21.5 let e15hp=0 let e15on=0 let e15t=0 let e15state=0 let e15type=4
let bossPhase=0  let bossHpMax=40
let totalEnemies=16

-- ── Projectiles (16 slots) ────────────────────────────────
-- type 1=normal  2=fast  3=spread  4=homing  5=bounce  6=explosive
let ep0x=0.0  let ep0y=0.0  let ep0vx=0.0 let ep0vy=0.0 let ep0on=0 let ep0type=1 let ep0age=0
let ep1x=0.0  let ep1y=0.0  let ep1vx=0.0 let ep1vy=0.0 let ep1on=0 let ep1type=1 let ep1age=0
let ep2x=0.0  let ep2y=0.0  let ep2vx=0.0 let ep2vy=0.0 let ep2on=0 let ep2type=1 let ep2age=0
let ep3x=0.0  let ep3y=0.0  let ep3vx=0.0 let ep3vy=0.0 let ep3on=0 let ep3type=1 let ep3age=0
let ep4x=0.0  let ep4y=0.0  let ep4vx=0.0 let ep4vy=0.0 let ep4on=0 let ep4type=1 let ep4age=0
let ep5x=0.0  let ep5y=0.0  let ep5vx=0.0 let ep5vy=0.0 let ep5on=0 let ep5type=1 let ep5age=0
let ep6x=0.0  let ep6y=0.0  let ep6vx=0.0 let ep6vy=0.0 let ep6on=0 let ep6type=1 let ep6age=0
let ep7x=0.0  let ep7y=0.0  let ep7vx=0.0 let ep7vy=0.0 let ep7on=0 let ep7type=1 let ep7age=0
let ep8x=0.0  let ep8y=0.0  let ep8vx=0.0 let ep8vy=0.0 let ep8on=0 let ep8type=1 let ep8age=0
let ep9x=0.0  let ep9y=0.0  let ep9vx=0.0 let ep9vy=0.0 let ep9on=0 let ep9type=1 let ep9age=0
let ep10x=0.0 let ep10y=0.0 let ep10vx=0.0 let ep10vy=0.0 let ep10on=0 let ep10type=1 let ep10age=0
let ep11x=0.0 let ep11y=0.0 let ep11vx=0.0 let ep11vy=0.0 let ep11on=0 let ep11type=1 let ep11age=0
let ep12x=0.0 let ep12y=0.0 let ep12vx=0.0 let ep12vy=0.0 let ep12on=0 let ep12type=1 let ep12age=0
let ep13x=0.0 let ep13y=0.0 let ep13vx=0.0 let ep13vy=0.0 let ep13on=0 let ep13type=1 let ep13age=0
let ep14x=0.0 let ep14y=0.0 let ep14vx=0.0 let ep14vy=0.0 let ep14on=0 let ep14type=1 let ep14age=0
let ep15x=0.0 let ep15y=0.0 let ep15vx=0.0 let ep15vy=0.0 let ep15on=0 let ep15type=1 let ep15age=0

-- ── Game state ────────────────────────────────────────────
let kills=0  let frame=0  let hitmsg=0  let damage=0
let lastWallX=0.0  -- set by castRay, read by drawCol

-- ── Pickups (8 slots): type 1=health  2=ammo  3=armor  4=shells ──────────
let pk0x=3.5  let pk0y=5.5  let pk0on=1  let pk0type=1   -- health - guard room
let pk1x=7.5  let pk1y=1.5  let pk1on=1  let pk1type=2   -- ammo - top corridor
let pk2x=13.5 let pk2y=5.5  let pk2on=1  let pk2type=4   -- shells - NE
let pk3x=1.5  let pk3y=9.5  let pk3on=1  let pk3type=3   -- armor - mid-west
let pk4x=7.5  let pk4y=11.5 let pk4on=1  let pk4type=1   -- health - keep
let pk5x=13.5 let pk5y=11.5 let pk5on=1  let pk5type=2   -- ammo - keep E
let pk6x=3.5  let pk6y=19.5 let pk6on=1  let pk6type=1   -- health - boss approach
let pk7x=7.5  let pk7y=21.5 let pk7on=1  let pk7type=3   -- armor - boss room

-- ── Head bob state ────────────────────────────────────────
let headBob=0.0  -- vertical offset applied to HALF
let footstepT=0  -- for footstep sound timing
let flashR=0  let flashG=0  let flashB=0  let flashT=0
let screenShake=0

-- ── Map helpers ──────────────────────────────────────────
func getRowVal(r)
    if r==0  then return r0  end  if r==1  then return r1  end
    if r==2  then return r2  end  if r==3  then return r3  end
    if r==4  then return r4  end  if r==5  then return r5  end
    if r==6  then return r6  end  if r==7  then return r7  end
    if r==8  then return r8  end  if r==9  then return r9  end
    if r==10 then return r10 end  if r==11 then return r11 end
    if r==12 then return r12 end  if r==13 then return r13 end
    if r==14 then return r14 end  if r==15 then return r15 end
    if r==16 then return r16 end  if r==17 then return r17 end
    if r==18 then return r18 end  if r==19 then return r19 end
    if r==20 then return r20 end  if r==21 then return r21 end
    if r==22 then return r22 end
    return r23
end

func pow2(col)
    if col==0  then return 1      end  if col==1  then return 2      end
    if col==2  then return 4      end  if col==3  then return 8      end
    if col==4  then return 16     end  if col==5  then return 32     end
    if col==6  then return 64     end  if col==7  then return 128    end
    if col==8  then return 256    end  if col==9  then return 512    end
    if col==10 then return 1024   end  if col==11 then return 2048   end
    if col==12 then return 4096   end  if col==13 then return 8192   end
    if col==14 then return 16384  end  if col==15 then return 32768  end
    if col==16 then return 65536  end  if col==17 then return 131072 end
    if col==18 then return 262144 end  if col==19 then return 524288 end
    if col==20 then return 1048576 end if col==21 then return 2097152 end
    if col==22 then return 4194304 end
    return 8388608
end

func isWall(row, col)
    if row<0 then return 1 end  if col<0 then return 1 end
    if row>=MSIZE then return 1 end  if col>=MSIZE then return 1 end
    let rv=getRowVal(floor(row))
    let pw=pow2(floor(col))
    let sh=floor(rv/pw)
    return sh - floor(sh/2)*2
end

-- ── DDA Raycaster ────────────────────────────────────────
func castRay(rdx, rdy)
    let mapX=floor(px)  let mapY=floor(py)
    let ddx=0.0  let ddy=0.0
    if abs(rdx)<0.00001 then ddx=99999 else ddx=abs(1.0/rdx) end
    if abs(rdy)<0.00001 then ddy=99999 else ddy=abs(1.0/rdy) end
    let stepX=0  let stepY=0  let sdx=0.0  let sdy=0.0
    if rdx<0 then stepX=-1  sdx=(px-mapX)*ddx else stepX=1 sdx=(mapX+1.0-px)*ddx end
    if rdy<0 then stepY=-1  sdy=(py-mapY)*ddy else stepY=1 sdy=(mapY+1.0-py)*ddy end
    let hit=0  let side=0  let steps=0
    while hit==0 do
        if sdx<sdy then sdx=sdx+ddx  mapX=mapX+stepX  side=0
        else            sdy=sdy+ddy  mapY=mapY+stepY  side=1 end
        if isWall(mapY,mapX)==1 then hit=1 end
        steps=steps+1
        if steps>32 then hit=1 end
    end
    let dist=0.0
    if side==0 then dist=sdx-ddx else dist=sdy-ddy end
    if dist<0.05 then dist=0.05 end
    -- compute wallX: fractional hit position on wall face (0..1)
    let wallX=0.0
    if side==0 then wallX=py+dist*(rdy/rdx) else wallX=px+dist*(rdx/rdy) end
    wallX=wallX-floor(wallX)
    -- pack: side*10000 + floor(wallX*1000)*1 + dist encoded separately
    -- but we only have one return value — encode as side*1000 + dist
    -- and pass wallX via a global
    lastWallX=wallX
    return side*1000+dist
end

func setZB(idx, val)
    if idx==0  then zb0=val  end  if idx==1  then zb1=val  end
    if idx==2  then zb2=val  end  if idx==3  then zb3=val  end
    if idx==4  then zb4=val  end  if idx==5  then zb5=val  end
    if idx==6  then zb6=val  end  if idx==7  then zb7=val  end
    if idx==8  then zb8=val  end  if idx==9  then zb9=val  end
    if idx==10 then zb10=val end  if idx==11 then zb11=val end
    if idx==12 then zb12=val end  if idx==13 then zb13=val end
    if idx==14 then zb14=val end  if idx==15 then zb15=val end
    if idx==16 then zb16=val end  if idx==17 then zb17=val end
    if idx==18 then zb18=val end  if idx==19 then zb19=val end
end

func getZB(idx)
    if idx<0  then return 99.0 end  if idx>19 then return 99.0 end
    if idx==0  then return zb0  end  if idx==1  then return zb1  end
    if idx==2  then return zb2  end  if idx==3  then return zb3  end
    if idx==4  then return zb4  end  if idx==5  then return zb5  end
    if idx==6  then return zb6  end  if idx==7  then return zb7  end
    if idx==8  then return zb8  end  if idx==9  then return zb9  end
    if idx==10 then return zb10 end  if idx==11 then return zb11 end
    if idx==12 then return zb12 end  if idx==13 then return zb13 end
    if idx==14 then return zb14 end  if idx==15 then return zb15 end
    if idx==16 then return zb16 end  if idx==17 then return zb17 end
    if idx==18 then return zb18 end
    return zb19
end

-- ── Wall column renderer ──────────────────────────────────
-- wallX is the fractional hit position (0..1) on the wall face
-- We pass it as an extra param from the main loop
func drawCol(x, dist, side, wallX)
    let lineH=floor(SH/dist)
    if lineH>SH then lineH=SH end
    let top=HALF-floor(lineH/2)  let bot=HALF+floor(lineH/2)
    if top<0 then top=0 end  if bot>SH then bot=SH end

    let bright=floor(230/dist)
    if bright>210 then bright=210 end
    if bright<16  then bright=16  end
    if side==1 then bright=floor(bright*0.50) end

    -- ceiling (2 bands only)
    color(8,10,22)  draw rect(x,0,5,floor(top*0.5))
    color(16,20,40) draw rect(x,floor(top*0.5),5,top-floor(top*0.5))

    -- wall base color
    let wr=bright  let wg=floor(bright*0.70)  let wb=floor(bright*0.38)
    if py>18 then wr=floor(wr*0.65) wg=floor(wg*0.55) wb=floor(wb*1.4) end
    color(wr,wg,wb) draw rect(x,top,5,bot-top)

    -- vertical mortar seam (1 per brick, at wallX multiples of 0.25)
    let bfrac=wallX-floor(wallX*4)*0.25
    if bfrac<0.035 then
        color(floor(wr*0.44),floor(wg*0.44),floor(wb*0.44))
        draw rect(x,top,2,bot-top)
    end

    -- horizontal mortar (just 2 lines per column)
    let bh=floor(lineH/3)
    if bh<2 then bh=2 end
    let hm1=top+bh  let hm2=top+bh*2
    if hm1>top and hm1<bot then
        color(floor(wr*0.44),floor(wg*0.44),floor(wb*0.44))
        draw rect(x,hm1,5,1)
    end
    if hm2>top and hm2<bot then
        color(floor(wr*0.44),floor(wg*0.44),floor(wb*0.44))
        draw rect(x,hm2,5,1)
    end

    -- floor (2 bands)
    let fh=SH-bot
    color(28,18,8)  draw rect(x,bot,5,floor(fh*0.45))
    color(14,8,3)   draw rect(x,bot+floor(fh*0.45),5,fh-floor(fh*0.45))
end


-- ── Sprite projection ─────────────────────────────────────
-- sprSz: world-space radius of sprite (e.g. 0.10 = small projectile)
-- sprites are square, size = floor(SH*sprSz/ty) pixels
func drawSprite(wx,wy,sprSz,unused,cr,cg,cb,zbSlot)
    let relx=wx-px  let rely=wy-py
    let cdx=sin(pang)  let cdy=0-cos(pang)
    let planx=0-cdy*pfov  let plany=cdx*pfov
    let invdet=1.0/(planx*cdy-cdx*plany)
    let tx=invdet*(cdy*relx-cdx*rely)
    let ty=invdet*(0-plany*relx+planx*rely)
    if ty<=0.12 then return end
    let wallZ=getZB(zbSlot)
    if ty>wallZ then return end
    let scx=floor((SW/2)*(1.0+tx/ty))
    -- pixel size based on world-space sprSz
    let pxH=floor(SH*sprSz/ty)
    if pxH<2 then return end
    if pxH>60 then pxH=60 end   -- hard cap: never bigger than 60px
    let half=floor(pxH/2)
    let dtop=HALF-half  let dbot=HALF+half
    let dlft=scx-half   let drgt=scx+half
    if dtop<0  then dtop=0  end  if dbot>SH then dbot=SH end
    if dlft<0  then dlft=0  end  if drgt>SW then drgt=SW end
    if dlft>=drgt then return end
    let shade=floor(200/ty)
    if shade>255 then shade=255 end  if shade<20 then shade=20 end
    color(floor(cr*shade/255),floor(cg*shade/255),floor(cb*shade/255))
    draw rect(dlft,dtop,drgt-dlft,dbot-dtop)
end

-- ── Enemy renderer ────────────────────────────────────────
func drawEnemy(ex,ey,ehp,eon,etype,estate)
    if eon==0 then return end
    let relx=ex-px  let rely=ey-py
    let cdx=sin(pang)  let cdy=0-cos(pang)
    let planx=0-cdy*pfov  let plany=cdx*pfov
    let invdet=1.0/(planx*cdy-cdx*plany)
    let tx=invdet*(cdy*relx-cdx*rely)
    let ty=invdet*(0-plany*relx+planx*rely)
    if ty<=0.12 then return end
    let scx=floor((SW/2)*(1.0+tx/ty))
    -- Enemy height = 0.85 of tile height (slightly shorter than ceiling)
    -- Enemy width  = 0.55 of height (narrower than tall)
    -- Vertically: feet at floor level (shift up by ~10% of drawH)
    let drawH=floor(SH*0.85/ty)
    if drawH<4 then return end
    if drawH>SH then drawH=SH end
    let halfH=floor(drawH/2)
    let halfW=floor(drawH*0.28)   -- width = ~0.55 of height, halved
    -- vertical offset: push sprite down so feet hit the floor line
    let voff=floor(SH*0.10/ty)
    let dtop=HALF-halfH+voff  let dbot=HALF+halfH+voff
    let dlft=scx-halfW        let drgt=scx+halfW
    if dtop<0  then dtop=0  end  if dbot>SH then dbot=SH end
    if dlft<0  then dlft=0  end  if drgt>SW then drgt=SW end
    if dlft>=drgt then return end
    let zbIdx=floor((scx/SW)*20)
    if zbIdx<0 then zbIdx=0 end  if zbIdx>19 then zbIdx=19 end
    if ty>getZB(zbIdx)+0.08 then return end

    let shade=floor(200/ty)
    if shade>255 then shade=255 end  if shade<15 then shade=15 end
    if estate==3 then shade=255 end  -- pain flash = full bright

    -- ghost flicker
    if etype==6 then
        if frame%10<3 then return end
        shade=floor(shade*0.55)
    end

    -- base palette per type
    let er=200 let eg=60  let eb=60    -- imp: red
    if etype==2 then er=50  eg=160 eb=60  end  -- soldier: olive green
    if etype==3 then er=130 eg=50  eb=190 end  -- heavy: purple
    if etype==4 then
        let pulse=floor(abs(sin(frame*0.08))*50)+150
        er=pulse eg=floor(pulse*0.35) eb=15
    end
    if etype==5 then er=15  eg=170 eb=210 end  -- sniper: teal
    if etype==6 then er=140 eg=210 eb=255 end  -- ghost: ice blue

    let br=floor(er*shade/255)  let bg=floor(eg*shade/255)  let bb=floor(eb*shade/255)
    let sw=drgt-dlft  let sh2=dbot-dtop

    -- ── Legs (bottom 30%) ─────────────────────────────────
    let legTop=dtop+floor(sh2*0.70)
    let legW=floor(sw*0.28)
    let legDark=floor(br*0.65)  let legDarkG=floor(bg*0.65)  let legDarkB=floor(bb*0.65)
    color(legDark,legDarkG,legDarkB)
    draw rect(dlft+2,      legTop, legW,  sh2-floor(sh2*0.70))
    draw rect(drgt-legW-2, legTop, legW,  sh2-floor(sh2*0.70))

    -- ── Torso (middle 45%) ────────────────────────────────
    let torsoTop=dtop+floor(sh2*0.25)
    let torsoBot=dtop+floor(sh2*0.70)
    let torsoH=torsoBot-torsoTop
    color(br,bg,bb) draw rect(dlft,torsoTop,sw,torsoH)
    -- chest highlight (lighter center stripe)
    color(floor(br*1.15+10),floor(bg*1.15+8),floor(bb*1.1+5))
    draw rect(scx-floor(sw*0.15),torsoTop,floor(sw*0.30),torsoH)

    -- ── Arms (thin side panels, torso height) ─────────────
    color(floor(br*0.80),floor(bg*0.80),floor(bb*0.80))
    draw rect(dlft,            torsoTop, floor(sw*0.18), torsoH)
    draw rect(drgt-floor(sw*0.18), torsoTop, floor(sw*0.18), torsoH)

    -- ── Head (top 25%) ────────────────────────────────────
    let headH=floor(sh2*0.25)
    let headW=floor(sw*0.60)
    let hx=scx-floor(headW/2)  let hy=dtop
    if hx<dlft then hx=dlft end
    -- skin / head color
    let skinR=floor(210*shade/255)  let skinG=floor(168*shade/255)  let skinB=floor(124*shade/255)
    if etype==4 then skinR=floor(br*1.1) skinG=floor(bg*0.8) skinB=bb end
    if etype==6 then skinR=br skinG=bg skinB=bb end
    color(skinR,skinG,skinB) draw rect(hx,hy,headW,headH)
    -- jaw shadow
    color(floor(skinR*0.72),floor(skinG*0.72),floor(skinB*0.72))
    draw rect(hx,hy+headH-2,headW,2)

    -- ── Eyes ──────────────────────────────────────────────
    if drawH>16 then
        let eyeY=hy+floor(headH*0.28)
        let eyeW=floor(headW*0.20)+1
        -- whites
        color(240,240,240)
        draw rect(hx+floor(headW*0.18),eyeY, eyeW,eyeW)
        draw rect(hx+floor(headW*0.62),eyeY, eyeW,eyeW)
        -- pupils (type-colored)
        let pupR=20 let pupG=20 let pupB=20
        if etype==1 then pupR=200 pupG=40  pupB=40  end
        if etype==4 then pupR=255 pupG=0   pupB=0   end
        if etype==5 then pupR=0   pupG=200 pupB=255 end
        if etype==6 then pupR=80  pupG=160 pupB=255 end
        color(pupR,pupG,pupB)
        draw rect(hx+floor(headW*0.20),eyeY+1,eyeW-1,eyeW-1)
        draw rect(hx+floor(headW*0.64),eyeY+1,eyeW-1,eyeW-1)
    end

    -- ── Type-specific extras ──────────────────────────────
    -- Heavy: shoulder armor plates
    if etype==3 and drawH>22 then
        color(floor(br*1.2+15),floor(bg*1.2+10),floor(bb*1.2+20))
        draw rect(dlft-2,       torsoTop, floor(sw*0.22)+2, floor(torsoH*0.40))
        draw rect(drgt-floor(sw*0.22), torsoTop, floor(sw*0.22)+2, floor(torsoH*0.40))
    end
    -- Sniper: rifle barrel (horizontal line across torso)
    if etype==5 and drawH>18 then
        color(60,70,80)
        draw rect(dlft-4,torsoTop+floor(torsoH*0.5),sw+8,2)
        color(180,200,220) draw rect(drgt,torsoTop+floor(torsoH*0.5)-1,4,1)
    end
    -- Boss: crown
    if etype==4 and drawH>28 then
        let spk=floor(headH*0.45)+1
        color(255,210,30)
        draw rect(hx,                    hy-spk, 3, spk)
        draw rect(hx+floor(headW/2)-1,   hy-spk-2, 4, spk+2)
        draw rect(hx+headW-3,            hy-spk, 3, spk)
        -- crown base
        color(200,160,20) draw rect(hx,hy-2,headW,2)
    end
    -- Ghost: glow outline on sides
    if etype==6 then
        color(floor(br*0.6),floor(bg*0.6)+40,floor(bb*0.6)+60)
        draw rect(dlft-1,dtop,2,sh2)
        draw rect(drgt-1,dtop,2,sh2)
    end

    -- ── HP bar (only when close enough) ───────────────────
    if ty<5 and drawH>14 then
        let maxHp=3
        if etype==2 then maxHp=5  end  if etype==3 then maxHp=10 end
        if etype==4 then maxHp=bossHpMax end
        if etype==5 then maxHp=3  end  if etype==6 then maxHp=4  end
        let barY=dtop-4
        color(40,8,8) draw rect(dlft,barY,sw,3)
        let hw=floor((ehp/maxHp)*sw)
        if hw>0 then
            if ehp>maxHp/2 then color(30,180,30) else color(200,60,20) end
            draw rect(dlft,barY,hw,3)
        end
    end
end

-- ── Projectile renderer (type-aware color+size) ───────────
func drawEP(epx,epy,epon,eptype)
    if epon==0 then return end
    -- sprSz is the world-space radius → pxH = floor(SH*sprSz/ty)
    -- at distance 3: pxH = floor(400*sprSz/3). sprSz=0.06 → 8px. Good.
    if eptype==1 then drawSprite(epx,epy,0.055,0,255,140,20,10) end   -- normal: small orange ball
    if eptype==2 then drawSprite(epx,epy,0.040,0,255,240,80,10) end   -- fast: tiny yellow streak
    if eptype==3 then drawSprite(epx,epy,0.060,0,255,100,20,10) end   -- spread: small orange
    if eptype==4 then
        let pulse=floor(abs(sin(frame*0.15))*80)+140
        drawSprite(epx,epy,0.058,0,pulse,0,pulse,10)                  -- homing: small purple
    end
    if eptype==5 then drawSprite(epx,epy,0.048,0,80,200,255,10) end   -- bounce: small cyan
    if eptype==6 then drawSprite(epx,epy,0.075,0,255,60,20,10) end    -- explosive: slightly bigger
end

-- ── Particles ────────────────────────────────────────────
func spawnPart(x,y,vx,vy,life)
    if pt0l==0  then pt0x=x  pt0y=y  pt0vx=vx  pt0vy=vy  pt0l=life  return end
    if pt1l==0  then pt1x=x  pt1y=y  pt1vx=vx  pt1vy=vy  pt1l=life  return end
    if pt2l==0  then pt2x=x  pt2y=y  pt2vx=vx  pt2vy=vy  pt2l=life  return end
    if pt3l==0  then pt3x=x  pt3y=y  pt3vx=vx  pt3vy=vy  pt3l=life  return end
    if pt4l==0  then pt4x=x  pt4y=y  pt4vx=vx  pt4vy=vy  pt4l=life  return end
    if pt5l==0  then pt5x=x  pt5y=y  pt5vx=vx  pt5vy=vy  pt5l=life  return end
    if pt6l==0  then pt6x=x  pt6y=y  pt6vx=vx  pt6vy=vy  pt6l=life  return end
    if pt7l==0  then pt7x=x  pt7y=y  pt7vx=vx  pt7vy=vy  pt7l=life  return end
    if pt8l==0  then pt8x=x  pt8y=y  pt8vx=vx  pt8vy=vy  pt8l=life  return end
    if pt9l==0  then pt9x=x  pt9y=y  pt9vx=vx  pt9vy=vy  pt9l=life  return end
    if pt10l==0 then pt10x=x pt10y=y pt10vx=vx pt10vy=vy pt10l=life return end
    if pt11l==0 then pt11x=x pt11y=y pt11vx=vx pt11vy=vy pt11l=life return end
    if pt12l==0 then pt12x=x pt12y=y pt12vx=vx pt12vy=vy pt12l=life return end
    if pt13l==0 then pt13x=x pt13y=y pt13vx=vx pt13vy=vy pt13l=life return end
    if pt14l==0 then pt14x=x pt14y=y pt14vx=vx pt14vy=vy pt14l=life return end
    if pt15l==0 then pt15x=x pt15y=y pt15vx=vx pt15vy=vy pt15l=life return end
end

func burstAt(wx,wy)
    let i=0
    while i<8 do
        let a=i*0.785
        spawnPart(wx,wy,sin(a)*0.07,cos(a)*0.07,20)
        i=i+1
    end
end

func moveParticles()
    if pt0l>0  then pt0x=pt0x+pt0vx   pt0y=pt0y+pt0vy   pt0l=pt0l-1   end
    if pt1l>0  then pt1x=pt1x+pt1vx   pt1y=pt1y+pt1vy   pt1l=pt1l-1   end
    if pt2l>0  then pt2x=pt2x+pt2vx   pt2y=pt2y+pt2vy   pt2l=pt2l-1   end
    if pt3l>0  then pt3x=pt3x+pt3vx   pt3y=pt3y+pt3vy   pt3l=pt3l-1   end
    if pt4l>0  then pt4x=pt4x+pt4vx   pt4y=pt4y+pt4vy   pt4l=pt4l-1   end
    if pt5l>0  then pt5x=pt5x+pt5vx   pt5y=pt5y+pt5vy   pt5l=pt5l-1   end
    if pt6l>0  then pt6x=pt6x+pt6vx   pt6y=pt6y+pt6vy   pt6l=pt6l-1   end
    if pt7l>0  then pt7x=pt7x+pt7vx   pt7y=pt7y+pt7vy   pt7l=pt7l-1   end
    if pt8l>0  then pt8x=pt8x+pt8vx   pt8y=pt8y+pt8vy   pt8l=pt8l-1   end
    if pt9l>0  then pt9x=pt9x+pt9vx   pt9y=pt9y+pt9vy   pt9l=pt9l-1   end
    if pt10l>0 then pt10x=pt10x+pt10vx pt10y=pt10y+pt10vy pt10l=pt10l-1 end
    if pt11l>0 then pt11x=pt11x+pt11vx pt11y=pt11y+pt11vy pt11l=pt11l-1 end
    if pt12l>0 then pt12x=pt12x+pt12vx pt12y=pt12y+pt12vy pt12l=pt12l-1 end
    if pt13l>0 then pt13x=pt13x+pt13vx pt13y=pt13y+pt13vy pt13l=pt13l-1 end
    if pt14l>0 then pt14x=pt14x+pt14vx pt14y=pt14y+pt14vy pt14l=pt14l-1 end
    if pt15l>0 then pt15x=pt15x+pt15vx pt15y=pt15y+pt15vy pt15l=pt15l-1 end
end

func drawParticles()
    if pt0l>0  then drawSprite(pt0x,  pt0y,  0.040,0,255,180,40,10) end
    if pt1l>0  then drawSprite(pt1x,  pt1y,  0.035,0,255,120,20,10) end
    if pt2l>0  then drawSprite(pt2x,  pt2y,  0.045,0,255,220,60,10) end
    if pt3l>0  then drawSprite(pt3x,  pt3y,  0.032,0,200,60, 10,10) end
    if pt4l>0  then drawSprite(pt4x,  pt4y,  0.038,0,255,160,40,10) end
    if pt5l>0  then drawSprite(pt5x,  pt5y,  0.034,0,220,80, 20,10) end
    if pt6l>0  then drawSprite(pt6x,  pt6y,  0.042,0,255,200,80,10) end
    if pt7l>0  then drawSprite(pt7x,  pt7y,  0.030,0,180,100,20,10) end
    if pt8l>0  then drawSprite(pt8x,  pt8y,  0.038,0,255,180,40,10) end
    if pt9l>0  then drawSprite(pt9x,  pt9y,  0.035,0,255,120,20,10) end
    if pt10l>0 then drawSprite(pt10x, pt10y, 0.042,0,255,200,60,10) end
    if pt11l>0 then drawSprite(pt11x, pt11y, 0.030,0,200,60, 10,10) end
    if pt12l>0 then drawSprite(pt12x, pt12y, 0.038,0,255,160,40,10) end
    if pt13l>0 then drawSprite(pt13x, pt13y, 0.034,0,220,80, 20,10) end
    if pt14l>0 then drawSprite(pt14x, pt14y, 0.042,0,255,200,80,10) end
    if pt15l>0 then drawSprite(pt15x, pt15y, 0.030,0,180,100,20,10) end
end

-- ── Sound FX ─────────────────────────────────────────────
func sfxShoot()    tone(1100,35,0.4,1) end
func sfxShotgun()  beep(280,20) beep(180,25) end
func sfxChaingun() tone(1600,15,0.3,1) end
func sfxKill()     tone(330,60,0.4,2) beep(200,25) end
func sfxBossKill() chord(200,250,300,200,0.5) tone(440,300,0.4,2) end
func sfxPain()     tone(180,70,0.6,2) end
func sfxDeath()    beep(220,40) beep(160,40) beep(100,50) beep(60,80) end
func sfxBounce()   tone(600,20,0.2,1) end
func sfxExplode()  beep(120,60) tone(200,80,0.5,2) end
func sfxSnipe()    tone(1800,25,0.45,1) end
func sfxGhost()    tone(300,40,0.3,3) end

-- ── Collision ─────────────────────────────────────────────
func canMove(nx,ny)
    let r=0.28
    if isWall(floor(ny-r),floor(nx-r))==1 then return 0 end
    if isWall(floor(ny-r),floor(nx+r))==1 then return 0 end
    if isWall(floor(ny+r),floor(nx-r))==1 then return 0 end
    if isWall(floor(ny+r),floor(nx+r))==1 then return 0 end
    return 1
end

func canMoveE(nx,ny)
    if isWall(floor(ny),floor(nx))==1 then return 0 end
    return 1
end

-- ── Hitscan ───────────────────────────────────────────────
func edist(ex,ey)
    let dx=ex-px  let dy=ey-py
    return sqrt(dx*dx+dy*dy)
end

func killEnemy(slot)
    kills=kills+1
    flashR=200 flashG=60 flashB=20 flashT=3
    if slot==0  then burstAt(e0x,e0y)  end  if slot==1  then burstAt(e1x,e1y)  end
    if slot==2  then burstAt(e2x,e2y)  end  if slot==3  then burstAt(e3x,e3y)  end
    if slot==4  then burstAt(e4x,e4y)  end  if slot==5  then burstAt(e5x,e5y)  end
    if slot==6  then burstAt(e6x,e6y)  end  if slot==7  then burstAt(e7x,e7y)  end
    if slot==8  then burstAt(e8x,e8y)  end  if slot==9  then burstAt(e9x,e9y)  end
    if slot==10 then burstAt(e10x,e10y) end if slot==11 then burstAt(e11x,e11y) end
    if slot==12 then burstAt(e12x,e12y) end if slot==13 then burstAt(e13x,e13y) end
    if slot==14 then burstAt(e14x,e14y) end
    if slot==15 then burstAt(e15x,e15y) sfxBossKill() flashT=8 end
end

func hitEnemy(slot,dmg)
    if slot==0  then e0hp=e0hp-dmg   e0state=3  e0t=0  if e0hp<=0  then e0on=0  killEnemy(0)  sfxKill() end end
    if slot==1  then e1hp=e1hp-dmg   e1state=3  e1t=0  if e1hp<=0  then e1on=0  killEnemy(1)  sfxKill() end end
    if slot==2  then e2hp=e2hp-dmg   e2state=3  e2t=0  if e2hp<=0  then e2on=0  killEnemy(2)  sfxKill() end end
    if slot==3  then e3hp=e3hp-dmg   e3state=3  e3t=0  if e3hp<=0  then e3on=0  killEnemy(3)  sfxKill() end end
    if slot==4  then e4hp=e4hp-dmg   e4state=3  e4t=0  if e4hp<=0  then e4on=0  killEnemy(4)  sfxKill() end end
    if slot==5  then e5hp=e5hp-dmg   e5state=3  e5t=0  if e5hp<=0  then e5on=0  killEnemy(5)  sfxKill() end end
    if slot==6  then e6hp=e6hp-dmg   e6state=3  e6t=0  if e6hp<=0  then e6on=0  killEnemy(6)  sfxKill() end end
    if slot==7  then e7hp=e7hp-dmg   e7state=3  e7t=0  if e7hp<=0  then e7on=0  killEnemy(7)  sfxKill() end end
    if slot==8  then e8hp=e8hp-dmg   e8state=3  e8t=0  if e8hp<=0  then e8on=0  killEnemy(8)  sfxKill() end end
    if slot==9  then e9hp=e9hp-dmg   e9state=3  e9t=0  if e9hp<=0  then e9on=0  killEnemy(9)  sfxKill() end end
    if slot==10 then e10hp=e10hp-dmg e10state=3 e10t=0 if e10hp<=0 then e10on=0 killEnemy(10) sfxKill() end end
    if slot==11 then e11hp=e11hp-dmg e11state=3 e11t=0 if e11hp<=0 then e11on=0 killEnemy(11) sfxKill() end end
    if slot==12 then e12hp=e12hp-dmg e12state=3 e12t=0 if e12hp<=0 then e12on=0 killEnemy(12) sfxKill() end end
    if slot==13 then e13hp=e13hp-dmg e13state=3 e13t=0 if e13hp<=0 then e13on=0 killEnemy(13) sfxKill() end end
    if slot==14 then e14hp=e14hp-dmg e14state=3 e14t=0 if e14hp<=0 then e14on=0 killEnemy(14) sfxKill() end end
    if slot==15 then e15hp=e15hp-dmg e15state=3 e15t=0 if e15hp<=0 then e15on=0 killEnemy(15) sfxBossKill() end end
    hitmsg=12
end

func tryShootOnce(dmg)
    let fdx=sin(pang)  let fdy=0-cos(pang)
    let best=-1  let bestD=99.0
    let exs=0.0 let eys=0.0 let eons=0
    -- check each enemy
    if e0on==1  then let d=edist(e0x,e0y)   let rx=e0x-px  let ry=e0y-py  if rx*fdx+ry*fdy>0 and abs(rx*fdy-ry*fdx)<d*0.30 and d<bestD then best=0  bestD=d end end
    if e1on==1  then let d=edist(e1x,e1y)   let rx=e1x-px  let ry=e1y-py  if rx*fdx+ry*fdy>0 and abs(rx*fdy-ry*fdx)<d*0.30 and d<bestD then best=1  bestD=d end end
    if e2on==1  then let d=edist(e2x,e2y)   let rx=e2x-px  let ry=e2y-py  if rx*fdx+ry*fdy>0 and abs(rx*fdy-ry*fdx)<d*0.30 and d<bestD then best=2  bestD=d end end
    if e3on==1  then let d=edist(e3x,e3y)   let rx=e3x-px  let ry=e3y-py  if rx*fdx+ry*fdy>0 and abs(rx*fdy-ry*fdx)<d*0.30 and d<bestD then best=3  bestD=d end end
    if e4on==1  then let d=edist(e4x,e4y)   let rx=e4x-px  let ry=e4y-py  if rx*fdx+ry*fdy>0 and abs(rx*fdy-ry*fdx)<d*0.30 and d<bestD then best=4  bestD=d end end
    if e5on==1  then let d=edist(e5x,e5y)   let rx=e5x-px  let ry=e5y-py  if rx*fdx+ry*fdy>0 and abs(rx*fdy-ry*fdx)<d*0.30 and d<bestD then best=5  bestD=d end end
    if e6on==1  then let d=edist(e6x,e6y)   let rx=e6x-px  let ry=e6y-py  if rx*fdx+ry*fdy>0 and abs(rx*fdy-ry*fdx)<d*0.30 and d<bestD then best=6  bestD=d end end
    if e7on==1  then let d=edist(e7x,e7y)   let rx=e7x-px  let ry=e7y-py  if rx*fdx+ry*fdy>0 and abs(rx*fdy-ry*fdx)<d*0.30 and d<bestD then best=7  bestD=d end end
    if e8on==1  then let d=edist(e8x,e8y)   let rx=e8x-px  let ry=e8y-py  if rx*fdx+ry*fdy>0 and abs(rx*fdy-ry*fdx)<d*0.30 and d<bestD then best=8  bestD=d end end
    if e9on==1  then let d=edist(e9x,e9y)   let rx=e9x-px  let ry=e9y-py  if rx*fdx+ry*fdy>0 and abs(rx*fdy-ry*fdx)<d*0.30 and d<bestD then best=9  bestD=d end end
    if e10on==1 then let d=edist(e10x,e10y) let rx=e10x-px let ry=e10y-py if rx*fdx+ry*fdy>0 and abs(rx*fdy-ry*fdx)<d*0.30 and d<bestD then best=10 bestD=d end end
    if e11on==1 then let d=edist(e11x,e11y) let rx=e11x-px let ry=e11y-py if rx*fdx+ry*fdy>0 and abs(rx*fdy-ry*fdx)<d*0.30 and d<bestD then best=11 bestD=d end end
    if e12on==1 then let d=edist(e12x,e12y) let rx=e12x-px let ry=e12y-py if rx*fdx+ry*fdy>0 and abs(rx*fdy-ry*fdx)<d*0.30 and d<bestD then best=12 bestD=d end end
    if e13on==1 then let d=edist(e13x,e13y) let rx=e13x-px let ry=e13y-py if rx*fdx+ry*fdy>0 and abs(rx*fdy-ry*fdx)<d*0.30 and d<bestD then best=13 bestD=d end end
    if e14on==1 then let d=edist(e14x,e14y) let rx=e14x-px let ry=e14y-py if rx*fdx+ry*fdy>0 and abs(rx*fdy-ry*fdx)<d*0.30 and d<bestD then best=14 bestD=d end end
    if e15on==1 then let d=edist(e15x,e15y) let rx=e15x-px let ry=e15y-py if rx*fdx+ry*fdy>0 and abs(rx*fdy-ry*fdx)<d*0.30 and d<bestD then best=15 bestD=d end end
    if best<0 then return end
    hitEnemy(best, dmg)
end

func tryShoot()
    if weapon==1 then
        if ammo0<=0 then tone(220,40,0.3,2) return end
        ammo0=ammo0-1  tryShootOnce(1)  sfxShoot()
    end
    if weapon==2 then
        if ammo1<=0 then tone(220,40,0.3,2) return end
        ammo1=ammo1-1
        tryShootOnce(1) tryShootOnce(1) tryShootOnce(1)
        tryShootOnce(1) tryShootOnce(1)
        sfxShotgun()
    end
    if weapon==3 then
        if ammo2<=0 then tone(220,40,0.3,2) return end
        ammo2=ammo2-1  tryShootOnce(1)  sfxChaingun()
    end
end

-- ── Projectile system ────────────────────────────────────
func spawnEP(ex,ey,ptype)
    let fdx=px-ex  let fdy=py-ey
    let d=sqrt(fdx*fdx+fdy*fdy)
    if d<0.1 then return end
    let spd=0.055
    if ptype==2 then spd=0.095 end  -- fast: sniper shot
    if ptype==3 then spd=0.060 end  -- spread
    if ptype==4 then spd=0.040 end  -- homing: slow
    if ptype==5 then spd=0.070 end  -- bounce
    if ptype==6 then spd=0.048 end  -- explosive: medium
    let vx=(fdx/d)*spd  let vy=(fdy/d)*spd
    if ep0on==0  then ep0x=ex  ep0y=ey  ep0vx=vx  ep0vy=vy  ep0on=1  ep0type=ptype  ep0age=0  return end
    if ep1on==0  then ep1x=ex  ep1y=ey  ep1vx=vx  ep1vy=vy  ep1on=1  ep1type=ptype  ep1age=0  return end
    if ep2on==0  then ep2x=ex  ep2y=ey  ep2vx=vx  ep2vy=vy  ep2on=1  ep2type=ptype  ep2age=0  return end
    if ep3on==0  then ep3x=ex  ep3y=ey  ep3vx=vx  ep3vy=vy  ep3on=1  ep3type=ptype  ep3age=0  return end
    if ep4on==0  then ep4x=ex  ep4y=ey  ep4vx=vx  ep4vy=vy  ep4on=1  ep4type=ptype  ep4age=0  return end
    if ep5on==0  then ep5x=ex  ep5y=ey  ep5vx=vx  ep5vy=vy  ep5on=1  ep5type=ptype  ep5age=0  return end
    if ep6on==0  then ep6x=ex  ep6y=ey  ep6vx=vx  ep6vy=vy  ep6on=1  ep6type=ptype  ep6age=0  return end
    if ep7on==0  then ep7x=ex  ep7y=ey  ep7vx=vx  ep7vy=vy  ep7on=1  ep7type=ptype  ep7age=0  return end
    if ep8on==0  then ep8x=ex  ep8y=ey  ep8vx=vx  ep8vy=vy  ep8on=1  ep8type=ptype  ep8age=0  return end
    if ep9on==0  then ep9x=ex  ep9y=ey  ep9vx=vx  ep9vy=vy  ep9on=1  ep9type=ptype  ep9age=0  return end
    if ep10on==0 then ep10x=ex ep10y=ey ep10vx=vx ep10vy=vy ep10on=1 ep10type=ptype ep10age=0 return end
    if ep11on==0 then ep11x=ex ep11y=ey ep11vx=vx ep11vy=vy ep11on=1 ep11type=ptype ep11age=0 return end
    if ep12on==0 then ep12x=ex ep12y=ey ep12vx=vx ep12vy=vy ep12on=1 ep12type=ptype ep12age=0 return end
    if ep13on==0 then ep13x=ex ep13y=ey ep13vx=vx ep13vy=vy ep13on=1 ep13type=ptype ep13age=0 return end
    if ep14on==0 then ep14x=ex ep14y=ey ep14vx=vx ep14vy=vy ep14on=1 ep14type=ptype ep14age=0 return end
    if ep15on==0 then ep15x=ex ep15y=ey ep15vx=vx ep15vy=vy ep15on=1 ep15type=ptype ep15age=0 return end
end

-- Boss spread: fires 3-shot fan
func spawnSpread(ex,ey)
    let fdx=px-ex  let fdy=py-ey
    let d=sqrt(fdx*fdx+fdy*fdy)
    if d<0.1 then return end
    let nx=fdx/d  let ny=fdy/d
    spawnEP(ex,ey,3)
    let s=0.342  let c=0.940
    let spd=0.060
    let lx=nx*c-ny*s  let ly=nx*s+ny*c
    let rx=nx*c+ny*s  let ry=0-nx*s+ny*c
    if ep4on==0 then ep4x=ex ep4y=ey ep4vx=lx*spd ep4vy=ly*spd ep4on=1 ep4type=3 ep4age=0 end
    if ep5on==0 then ep5x=ex ep5y=ey ep5vx=rx*spd ep5vy=ry*spd ep5on=1 ep5type=3 ep5age=0 end
end

func hitPlayer(eptype)
    let dmg=8
    if eptype==2 then dmg=18 end  -- sniper: heavy
    if eptype==3 then dmg=9  end  -- spread
    if eptype==4 then dmg=14 end  -- homing
    if eptype==5 then dmg=7  end  -- bounce
    if eptype==6 then dmg=22 end  -- explosive: very heavy
    -- armor absorbs half
    if parmor>0 then
        let absorbed=floor(dmg/2)
        parmor=parmor-absorbed
        if parmor<0 then parmor=0 end
        dmg=dmg-absorbed
    end
    phealth=phealth-dmg  damage=12  sfxPain()
    flashR=150 flashG=0 flashB=0 flashT=6
    screenShake=8
    if phealth<0 then phealth=0 end
end

func updateOneEP(slot)
    let ex=0.0 let ey=0.0 let evx=0.0 let evy=0.0 let eon=0 let etype=1 let eage=0
    if slot==0  then ex=ep0x  ey=ep0y  evx=ep0vx  evy=ep0vy  eon=ep0on  etype=ep0type  eage=ep0age  end
    if slot==1  then ex=ep1x  ey=ep1y  evx=ep1vx  evy=ep1vy  eon=ep1on  etype=ep1type  eage=ep1age  end
    if slot==2  then ex=ep2x  ey=ep2y  evx=ep2vx  evy=ep2vy  eon=ep2on  etype=ep2type  eage=ep2age  end
    if slot==3  then ex=ep3x  ey=ep3y  evx=ep3vx  evy=ep3vy  eon=ep3on  etype=ep3type  eage=ep3age  end
    if slot==4  then ex=ep4x  ey=ep4y  evx=ep4vx  evy=ep4vy  eon=ep4on  etype=ep4type  eage=ep4age  end
    if slot==5  then ex=ep5x  ey=ep5y  evx=ep5vx  evy=ep5vy  eon=ep5on  etype=ep5type  eage=ep5age  end
    if slot==6  then ex=ep6x  ey=ep6y  evx=ep6vx  evy=ep6vy  eon=ep6on  etype=ep6type  eage=ep6age  end
    if slot==7  then ex=ep7x  ey=ep7y  evx=ep7vx  evy=ep7vy  eon=ep7on  etype=ep7type  eage=ep7age  end
    if slot==8  then ex=ep8x  ey=ep8y  evx=ep8vx  evy=ep8vy  eon=ep8on  etype=ep8type  eage=ep8age  end
    if slot==9  then ex=ep9x  ey=ep9y  evx=ep9vx  evy=ep9vy  eon=ep9on  etype=ep9type  eage=ep9age  end
    if slot==10 then ex=ep10x ey=ep10y evx=ep10vx evy=ep10vy eon=ep10on etype=ep10type eage=ep10age end
    if slot==11 then ex=ep11x ey=ep11y evx=ep11vx evy=ep11vy eon=ep11on etype=ep11type eage=ep11age end
    if slot==12 then ex=ep12x ey=ep12y evx=ep12vx evy=ep12vy eon=ep12on etype=ep12type eage=ep12age end
    if slot==13 then ex=ep13x ey=ep13y evx=ep13vx evy=ep13vy eon=ep13on etype=ep13type eage=ep13age end
    if slot==14 then ex=ep14x ey=ep14y evx=ep14vx evy=ep14vy eon=ep14on etype=ep14type eage=ep14age end
    if slot==15 then ex=ep15x ey=ep15y evx=ep15vx evy=ep15vy eon=ep15on etype=ep15type eage=ep15age end
    if eon==0 then return end

    eage=eage+1
    -- max age = 200 frames
    if eage>200 then eon=0 end

    -- TYPE 4: Homing — steers toward player
    if etype==4 then
        let tdx=px-ex  let tdy=py-ey
        let td=sqrt(tdx*tdx+tdy*tdy)
        if td>0.1 then
            evx=evx+(tdx/td)*0.005
            evy=evy+(tdy/td)*0.005
            let spd=sqrt(evx*evx+evy*evy)
            if spd>0.048 then evx=evx/spd*0.048  evy=evy/spd*0.048 end
        end
    end

    ex=ex+evx  ey=ey+evy

    -- Wall collision
    if isWall(floor(ey),floor(ex))==1 then
        -- TYPE 5: Bounce off wall (up to 3 bounces encoded in age<90)
        if etype==5 and eage<90 then
            -- reflect on whichever axis hit
            if isWall(floor(ey),floor(ex-evx))==0 then evx=0-evx
            elseif isWall(floor(ey-evy),floor(ex))==0 then evy=0-evy
            else evx=0-evx  evy=0-evy end
            ex=ex+evx  ey=ey+evy
            sfxBounce()
        else
            -- TYPE 6: Explosive — splash damage on wall hit
            if etype==6 then
                let dx=ex-px  let dy=ey-py
                if sqrt(dx*dx+dy*dy)<1.5 then hitPlayer(6) sfxExplode() end
                burstAt(ex,ey) burstAt(ex+0.1,ey+0.1)
            end
            eon=0
        end
    end

    if eon==1 then
        let dx=ex-px  let dy=ey-py
        let hitR=0.35
        if etype==6 then hitR=0.5 end
        if sqrt(dx*dx+dy*dy)<hitR then
            if etype==6 then sfxExplode() burstAt(ex,ey) end
            hitPlayer(etype)
            eon=0
        end
    end

    if slot==0  then ep0x=ex  ep0y=ey  ep0vx=evx  ep0vy=evy  ep0on=eon  ep0age=eage  end
    if slot==1  then ep1x=ex  ep1y=ey  ep1vx=evx  ep1vy=evy  ep1on=eon  ep1age=eage  end
    if slot==2  then ep2x=ex  ep2y=ey  ep2vx=evx  ep2vy=evy  ep2on=eon  ep2age=eage  end
    if slot==3  then ep3x=ex  ep3y=ey  ep3vx=evx  ep3vy=evy  ep3on=eon  ep3age=eage  end
    if slot==4  then ep4x=ex  ep4y=ey  ep4vx=evx  ep4vy=evy  ep4on=eon  ep4age=eage  end
    if slot==5  then ep5x=ex  ep5y=ey  ep5vx=evx  ep5vy=evy  ep5on=eon  ep5age=eage  end
    if slot==6  then ep6x=ex  ep6y=ey  ep6vx=evx  ep6vy=evy  ep6on=eon  ep6age=eage  end
    if slot==7  then ep7x=ex  ep7y=ey  ep7vx=evx  ep7vy=evy  ep7on=eon  ep7age=eage  end
    if slot==8  then ep8x=ex  ep8y=ey  ep8vx=evx  ep8vy=evy  ep8on=eon  ep8age=eage  end
    if slot==9  then ep9x=ex  ep9y=ey  ep9vx=evx  ep9vy=evy  ep9on=eon  ep9age=eage  end
    if slot==10 then ep10x=ex ep10y=ey ep10vx=evx ep10vy=evy ep10on=eon ep10age=eage end
    if slot==11 then ep11x=ex ep11y=ey ep11vx=evx ep11vy=evy ep11on=eon ep11age=eage end
    if slot==12 then ep12x=ex ep12y=ey ep12vx=evx ep12vy=evy ep12on=eon ep12age=eage end
    if slot==13 then ep13x=ex ep13y=ey ep13vx=evx ep13vy=evy ep13on=eon ep13age=eage end
    if slot==14 then ep14x=ex ep14y=ey ep14vx=evx ep14vy=evy ep14on=eon ep14age=eage end
    if slot==15 then ep15x=ex ep15y=ey ep15vx=evx ep15vy=evy ep15on=eon ep15age=eage end
end

func updateAllEP()
    updateOneEP(0)  updateOneEP(1)  updateOneEP(2)  updateOneEP(3)
    updateOneEP(4)  updateOneEP(5)  updateOneEP(6)  updateOneEP(7)
    updateOneEP(8)  updateOneEP(9)  updateOneEP(10) updateOneEP(11)
    updateOneEP(12) updateOneEP(13) updateOneEP(14) updateOneEP(15)
end

-- ── Enemy AI ─────────────────────────────────────────────
func updateEnemy(slot)
    let ex=0.0 let ey=0.0 let ehp=0 let eon=0 let et=0 let estate=0 let etype=0
    if slot==0  then ex=e0x  ey=e0y  ehp=e0hp  eon=e0on  et=e0t  estate=e0state  etype=e0type  end
    if slot==1  then ex=e1x  ey=e1y  ehp=e1hp  eon=e1on  et=e1t  estate=e1state  etype=e1type  end
    if slot==2  then ex=e2x  ey=e2y  ehp=e2hp  eon=e2on  et=e2t  estate=e2state  etype=e2type  end
    if slot==3  then ex=e3x  ey=e3y  ehp=e3hp  eon=e3on  et=e3t  estate=e3state  etype=e3type  end
    if slot==4  then ex=e4x  ey=e4y  ehp=e4hp  eon=e4on  et=e4t  estate=e4state  etype=e4type  end
    if slot==5  then ex=e5x  ey=e5y  ehp=e5hp  eon=e5on  et=e5t  estate=e5state  etype=e5type  end
    if slot==6  then ex=e6x  ey=e6y  ehp=e6hp  eon=e6on  et=e6t  estate=e6state  etype=e6type  end
    if slot==7  then ex=e7x  ey=e7y  ehp=e7hp  eon=e7on  et=e7t  estate=e7state  etype=e7type  end
    if slot==8  then ex=e8x  ey=e8y  ehp=e8hp  eon=e8on  et=e8t  estate=e8state  etype=e8type  end
    if slot==9  then ex=e9x  ey=e9y  ehp=e9hp  eon=e9on  et=e9t  estate=e9state  etype=e9type  end
    if slot==10 then ex=e10x ey=e10y ehp=e10hp eon=e10on et=e10t estate=e10state etype=e10type end
    if slot==11 then ex=e11x ey=e11y ehp=e11hp eon=e11on et=e11t estate=e11state etype=e11type end
    if slot==12 then ex=e12x ey=e12y ehp=e12hp eon=e12on et=e12t estate=e12state etype=e12type end
    if slot==13 then ex=e13x ey=e13y ehp=e13hp eon=e13on et=e13t estate=e13state etype=e13type end
    if slot==14 then ex=e14x ey=e14y ehp=e14hp eon=e14on et=e14t estate=e14state etype=e14type end
    if slot==15 then ex=e15x ey=e15y ehp=e15hp eon=e15on et=e15t estate=e15state etype=e15type end
    if eon==0 then return end

    et=et+1
    let d=edist(ex,ey)
    -- Skip full AI update for very distant idle enemies (perf)
    if d>14.0 and estate==0 then return end

    -- Alert radii
    let alertR=5.5
    if etype==2 then alertR=8.5 end   -- soldier: wide awareness
    if etype==3 then alertR=4.0 end   -- heavy: short but always angry
    if etype==4 then alertR=99.0 end  -- boss: always alert
    if etype==5 then alertR=12.0 end  -- sniper: very wide awareness
    if etype==6 then alertR=7.0 end   -- ghost: medium

    if estate==0 and d<alertR then estate=1 et=0 end
    if estate==3 and et>16     then estate=1 et=0 end

    -- Speeds
    let spd=0.022
    if etype==1 then spd=0.032 end  -- imp: fast rush
    if etype==2 then spd=0.018 end  -- soldier: careful
    if etype==3 then spd=0.011 end  -- heavy: slow
    if etype==4 then               -- boss
        spd=0.016
        if bossPhase==1 then spd=0.024 end
        if bossPhase==2 then spd=0.032 end
    end
    if etype==5 then spd=0.008 end  -- sniper: barely moves
    if etype==6 then spd=0.026 end  -- ghost: floats through space

    if estate==1 then
        let tdx=px-ex  let tdy=py-ey
        let dl=sqrt(tdx*tdx+tdy*tdy)
        if dl<0.01 then dl=0.01 end

        -- TYPE 1: Imp — straight charge, spit at mid range
        if etype==1 then
            if canMoveE(ex+(tdx/dl)*spd,ey)==1 then ex=ex+(tdx/dl)*spd end
            if canMoveE(ex,ey+(tdy/dl)*spd)==1 then ey=ey+(tdy/dl)*spd end
            if d>2.0 and d<8.0 and et%50==0 then spawnEP(ex,ey,1) tone(440,25,0.2,2) end
            if d<0.8 and frame%(55+slot*7)==0 then
                phealth=phealth-9 damage=10 sfxPain()
                flashR=130 flashG=0 flashB=0 flashT=5
                if phealth<0 then phealth=0 end
            end
        end

        -- TYPE 2: Soldier — strafe + shoot, retreats when wounded
        if etype==2 then
            let strafex=0-(tdy/dl)*spd  let strafey=(tdx/dl)*spd
            if ehp==1 then
                if canMoveE(ex-(tdx/dl)*spd,ey)==1 then ex=ex-(tdx/dl)*spd end
                if canMoveE(ex,ey-(tdy/dl)*spd)==1 then ey=ey-(tdy/dl)*spd end
            elseif d>3.5 then
                if canMoveE(ex+(tdx/dl)*spd,ey)==1 then ex=ex+(tdx/dl)*spd end
                if canMoveE(ex,ey+(tdy/dl)*spd)==1 then ey=ey+(tdy/dl)*spd end
            else
                if et%120<60 then
                    if canMoveE(ex+strafex,ey+strafey)==1 then ex=ex+strafex ey=ey+strafey end
                else
                    if canMoveE(ex-strafex,ey-strafey)==1 then ex=ex-strafex ey=ey-strafey end
                end
            end
            let fr=40  if ehp==1 then fr=22 end
            if et%fr==0 then
                if ehp>1 then spawnEP(ex,ey,1) else spawnEP(ex,ey,2) end
                tone(700,25,0.2,1)
            end
        end

        -- TYPE 3: Heavy — slow advance, massive melee, throws explosive
        if etype==3 then
            if canMoveE(ex+(tdx/dl)*spd,ey)==1 then ex=ex+(tdx/dl)*spd end
            if canMoveE(ex,ey+(tdy/dl)*spd)==1 then ey=ey+(tdy/dl)*spd end
            if d<0.9 and frame%(48+slot*11)==0 then
                phealth=phealth-22 damage=14 sfxPain()
                flashR=150 flashG=0 flashB=0 flashT=8
                screenShake=14
                if phealth<0 then phealth=0 end
            end
            -- throws explosive at medium range
            if d>2.5 and d<9.0 and et%80==0 then spawnEP(ex,ey,6) tone(300,30,0.3,2) end
        end

        -- TYPE 4: Boss — 3-phase AI
        if etype==4 then
            let bhp=ehp
            if bhp<=floor(bossHpMax*0.25) then bossPhase=2
            elseif bhp<=floor(bossHpMax*0.5) then bossPhase=1
            else bossPhase=0 end

            if bossPhase==0 then
                -- circle strafe + aimed shots
                let sx=0-(tdy/dl)*spd  let sy=(tdx/dl)*spd
                if et%160<80 then
                    if canMoveE(ex+sx,ey+sy)==1 then ex=ex+sx ey=ey+sy end
                else
                    if canMoveE(ex-sx,ey-sy)==1 then ex=ex-sx ey=ey-sy end
                end
                if et%30==0 then spawnEP(ex,ey,1) tone(440,28,0.3,1) end
                if et%60==30 then spawnEP(ex,ey,1) end
            end
            if bossPhase==1 then
                -- advance + spread
                if d>2.0 then
                    if canMoveE(ex+(tdx/dl)*spd,ey)==1 then ex=ex+(tdx/dl)*spd end
                    if canMoveE(ex,ey+(tdy/dl)*spd)==1 then ey=ey+(tdy/dl)*spd end
                end
                if et%25==0 then spawnSpread(ex,ey) tone(330,28,0.35,2) end
                if et%40==20 then spawnEP(ex,ey,6) end  -- explosive
                if d<1.0 and frame%40==0 then
                    phealth=phealth-16 damage=13 sfxPain()
                    flashR=160 flashG=0 flashB=0 flashT=8
                    if phealth<0 then phealth=0 end
                end
            end
            if bossPhase==2 then
                -- frenzy: rush + homing + spread + explosive
                if d>1.0 then
                    if canMoveE(ex+(tdx/dl)*spd,ey)==1 then ex=ex+(tdx/dl)*spd end
                    if canMoveE(ex,ey+(tdy/dl)*spd)==1 then ey=ey+(tdy/dl)*spd end
                end
                if et%18==0  then spawnEP(ex,ey,4) tone(220,22,0.4,2) end
                if et%28==10 then spawnSpread(ex,ey) end
                if et%45==22 then spawnEP(ex,ey,6) end
                if d<0.8 and frame%28==0 then
                    phealth=phealth-20 damage=16 sfxPain()
                    flashR=180 flashG=0 flashB=0 flashT=10
                    screenShake=12
                    if phealth<0 then phealth=0 end
                end
            end
        end

        -- TYPE 5: Sniper — stays far, fires fast precise shots, sidesteps
        if etype==5 then
            -- keep distance: retreat if close
            if d<5.0 then
                if canMoveE(ex-(tdx/dl)*spd,ey)==1 then ex=ex-(tdx/dl)*spd end
                if canMoveE(ex,ey-(tdy/dl)*spd)==1 then ey=ey-(tdy/dl)*spd end
            else
                -- small sidestep
                let sx=0-(tdy/dl)*spd  let sy=(tdx/dl)*spd
                if et%180<90 then
                    if canMoveE(ex+sx,ey+sy)==1 then ex=ex+sx ey=ey+sy end
                else
                    if canMoveE(ex-sx,ey-sy)==1 then ex=ex-sx ey=ey-sy end
                end
            end
            -- fires fast shot (type 2) every 55 frames — high damage
            if et%55==0 then spawnEP(ex,ey,2) sfxSnipe() end
        end

        -- TYPE 6: Ghost — passes through pillars (uses canMoveE like normal
        --         but teleports past walls occasionally), fires homing
        if etype==6 then
            -- can move through thin walls (no wall check on Y)
            ex=ex+(tdx/dl)*spd
            ey=ey+(tdy/dl)*spd
            -- snap back to open cell if deeply inside wall
            if isWall(floor(ey),floor(ex))==1 then
                ex=ex-(tdx/dl)*spd*2
                ey=ey-(tdy/dl)*spd*2
            end
            if et%40==0 then spawnEP(ex,ey,4) sfxGhost() end  -- homing
            if d<0.7 and frame%(45+slot*9)==0 then
                phealth=phealth-11 damage=11 sfxPain()
                flashR=80 flashG=0 flashB=120 flashT=6
                if phealth<0 then phealth=0 end
            end
        end
    end

    if slot==0  then e0x=ex  e0y=ey  e0hp=ehp  e0on=eon  e0t=et  e0state=estate  end
    if slot==1  then e1x=ex  e1y=ey  e1hp=ehp  e1on=eon  e1t=et  e1state=estate  end
    if slot==2  then e2x=ex  e2y=ey  e2hp=ehp  e2on=eon  e2t=et  e2state=estate  end
    if slot==3  then e3x=ex  e3y=ey  e3hp=ehp  e3on=eon  e3t=et  e3state=estate  end
    if slot==4  then e4x=ex  e4y=ey  e4hp=ehp  e4on=eon  e4t=et  e4state=estate  end
    if slot==5  then e5x=ex  e5y=ey  e5hp=ehp  e5on=eon  e5t=et  e5state=estate  end
    if slot==6  then e6x=ex  e6y=ey  e6hp=ehp  e6on=eon  e6t=et  e6state=estate  end
    if slot==7  then e7x=ex  e7y=ey  e7hp=ehp  e7on=eon  e7t=et  e7state=estate  end
    if slot==8  then e8x=ex  e8y=ey  e8hp=ehp  e8on=eon  e8t=et  e8state=estate  end
    if slot==9  then e9x=ex  e9y=ey  e9hp=ehp  e9on=eon  e9t=et  e9state=estate  end
    if slot==10 then e10x=ex e10y=ey e10hp=ehp e10on=eon e10t=et e10state=estate end
    if slot==11 then e11x=ex e11y=ey e11hp=ehp e11on=eon e11t=et e11state=estate end
    if slot==12 then e12x=ex e12y=ey e12hp=ehp e12on=eon e12t=et e12state=estate end
    if slot==13 then e13x=ex e13y=ey e13hp=ehp e13on=eon e13t=et e13state=estate end
    if slot==14 then e14x=ex e14y=ey e14hp=ehp e14on=eon e14t=et e14state=estate end
    if slot==15 then e15x=ex e15y=ey e15hp=ehp e15on=eon e15t=et e15state=estate end
end

-- ── Weapon draw ───────────────────────────────────────────
func drawGun()
    let moving=0
    if keydown(KEY_W)==1 or keydown(KEY_S)==1 or keydown(KEY_A)==1 or keydown(KEY_D)==1 then
        bobT=bobT+1  moving=1
    end
    let bob=0  if moving==1 then bob=floor(sin(bobT*0.18)*5) end
    let gx=255  let gy=288+bob

    if muzzle>0 then
        color(255,220,80) draw rect(gx+42,gy-34,24,20)
        color(255,160,20) draw rect(gx+46,gy-44,16,14)
        color(255,255,200) draw rect(gx+50,gy-50,8,10)
    end

    if weapon==1 then
        color(55,55,60)  draw rect(gx,    gy,    80,24)
        color(40,40,45)  draw rect(gx+54, gy-8,  30,10)
        color(65,45,30)  draw rect(gx+8,  gy+22, 22,36)
        color(75,75,80)  draw rect(gx+4,  gy+4,  44,8)
        if gunframe>0 then color(180,140,40) draw rect(gx+28,gy+2,14,6) end
    end
    if weapon==2 then
        color(55,40,30)  draw rect(gx-20,gy,    120,18)
        color(45,35,25)  draw rect(gx-10,gy-8,  100,10)
        color(70,55,40)  draw rect(gx+10,gy+16, 50, 30)
        color(60,60,65)  draw rect(gx+80,gy-2,  30, 8)
        if gunframe>0 then color(200,160,60) draw rect(gx+20,gy+2,20,6) end
    end
    if weapon==3 then
        color(50,50,55)  draw rect(gx,    gy,    90,26)
        color(40,40,45)  draw rect(gx+60, gy-10, 40,12)
        color(65,45,30)  draw rect(gx+10, gy+24, 26,32)
        let rot=frame%8
        color(70,70,75)  draw rect(gx+68,gy-14+rot,10,4)
        color(70,70,75)  draw rect(gx+68,gy+2-rot, 10,4)
        if gunframe>0 then color(220,160,30) draw rect(gx+32,gy+2,20,8) end
    end

    if reloading==1 then
        let rp=floor((1.0-reloadT/30.0)*80)
        color(20,20,20) draw rect(260,380,80,4)
        color(100,200,255) draw rect(260,380,rp,4)
    end
end

-- ── HUD ───────────────────────────────────────────────────
func drawHUD()
    -- HP bar
    color(50,18,18) draw rect(10,366,200,24)
    let hw=floor(phealth*2)  if hw>200 then hw=200 end
    let hcr=40  let hcg=180
    if phealth<=60 then hcr=200 hcg=140 end
    if phealth<=30 then hcr=200 hcg=40  end
    color(hcr,hcg,40) draw rect(10,366,hw,24)
    color(255,200,200) draw text("HP "+tostr(phealth),16,372)

    -- Armor bar
    if parmor>0 then
        color(20,20,60) draw rect(10,392,floor(parmor*2),6)
        color(80,140,255) draw rect(10,392,floor(parmor*2),6)
        color(180,180,255) draw text("AR",16,394)
    end

    -- Ammo
    let curAmmo=ammo0
    if weapon==2 then curAmmo=ammo1 end
    if weapon==3 then curAmmo=ammo2 end
    color(255,220,50) draw text("AMMO "+tostr(curAmmo),440,372)
    color(180,180,220)
    if weapon==1 then draw text("PISTOL",  440,358) end
    if weapon==2 then draw text("SHOTGUN", 440,358) end
    if weapon==3 then draw text("CHAINGUN",440,358) end

    -- Kills
    color(255,220,50) draw text("KILLS "+tostr(kills)+"/"+tostr(totalEnemies),10,354)

    -- Zone indicator
    color(120,120,160)
    if py<6 then draw text("ENTRY HALL",10,340) end
    if py>=6 and py<10 then draw text("PILLAR HALL",10,340) end
    if py>=10 and py<16 then draw text("FORTRESS KEEP",10,340) end
    if py>=16 and py<20 then draw text("ANTECHAMBER",10,340) end
    if py>=20 then
        if frame%20<12 then color(255,80,80) end
        draw text("BOSS CHAMBER",10,340)
    end

    -- Boss phase warning
    if e15on==1 then
        let bw=e15hp
        if bossPhase==0 then color(200,140,40) end
        if bossPhase==1 then color(220,60,40)  end
        if bossPhase==2 then
            if frame%12<6 then color(255,40,40) else color(255,180,40) end
        end
        color(40,10,40) draw rect(160,8,320,10)
        let bpct=0
        if bossHpMax>0 then bpct=floor(bw*320/bossHpMax) end
        if bossPhase==0 then color(160,80,220) end
        if bossPhase==1 then color(220,60,100) end
        if bossPhase==2 then color(255,40,40)  end
        if bpct>0 then draw rect(160,8,bpct,10) end
        color(255,255,255) draw text("BOSS",168,9)
        if bossPhase==2 then
            if frame%20<12 then color(255,60,60) draw text("!! FRENZY !!",232,9) end
        end
    end

    -- Crosshair
    color(255,255,255) draw rect(318,198,4,4)
    color(0,0,0)       draw rect(320,200,2,2)
    -- hit marker
    if hitmsg>0 then
        color(255,60,60)
        draw rect(310,196,16,2)  draw rect(310,204,16,2)
        draw rect(310,196,2,10)  draw rect(326,196,2,10)
    end

    -- Damage vignette
    if damage>0 then
        let dv=floor(damage*14)  if dv>160 then dv=160 end
        color(dv,0,0)
        draw rect(0,0,SW,8)    draw rect(0,SH-8,SW,8)
        draw rect(0,0,8,SH)    draw rect(SW-8,0,8,SH)
    end

    -- Flash
    if flashT>0 then
        color(flashR,flashG,flashB)
        draw rect(0,0,SW,SH)
        flashT=flashT-1
    end

    -- Minimap (top-right corner, 24×24 map at 3px/tile = 72×72)
    let ms=3  let mox=562  let moy=6
    -- pickups (small colored dots)
    color(40,200,40)
    if pk0on==1 then draw rect(floor(mox+pk0x*ms),floor(moy+pk0y*ms),2,2) end
    if pk1on==1 then draw rect(floor(mox+pk1x*ms),floor(moy+pk1y*ms),2,2) end
    if pk2on==1 then draw rect(floor(mox+pk2x*ms),floor(moy+pk2y*ms),2,2) end
    if pk3on==1 then draw rect(floor(mox+pk3x*ms),floor(moy+pk3y*ms),2,2) end
    if pk4on==1 then draw rect(floor(mox+pk4x*ms),floor(moy+pk4y*ms),2,2) end
    if pk5on==1 then draw rect(floor(mox+pk5x*ms),floor(moy+pk5y*ms),2,2) end
    if pk6on==1 then draw rect(floor(mox+pk6x*ms),floor(moy+pk6y*ms),2,2) end
    if pk7on==1 then draw rect(floor(mox+pk7x*ms),floor(moy+pk7y*ms),2,2) end
    -- player
    color(255,220,50)
    draw rect(floor(mox+px*ms)-1,floor(moy+py*ms)-1,3,3)
    let mfdx=sin(pang)  let mfdy=0-cos(pang)
    draw rect(floor(mox+px*ms+mfdx*3),floor(moy+py*ms+mfdy*3),2,2)
    -- enemies
    if e0on==1  then color(220,60,60)  draw rect(floor(mox+e0x*ms), floor(moy+e0y*ms), 2,2) end
    if e1on==1  then color(20,200,220) draw rect(floor(mox+e1x*ms), floor(moy+e1y*ms), 2,2) end
    if e2on==1  then color(60,180,60)  draw rect(floor(mox+e2x*ms), floor(moy+e2y*ms), 2,2) end
    if e3on==1  then color(60,180,60)  draw rect(floor(mox+e3x*ms), floor(moy+e3y*ms), 2,2) end
    if e4on==1  then color(140,60,220) draw rect(floor(mox+e4x*ms), floor(moy+e4y*ms), 2,2) end
    if e5on==1  then color(220,60,60)  draw rect(floor(mox+e5x*ms), floor(moy+e5y*ms), 2,2) end
    if e6on==1  then color(20,200,220) draw rect(floor(mox+e6x*ms), floor(moy+e6y*ms), 2,2) end
    if e7on==1  then color(60,180,60)  draw rect(floor(mox+e7x*ms), floor(moy+e7y*ms), 2,2) end
    if e8on==1  then color(160,220,255) draw rect(floor(mox+e8x*ms),floor(moy+e8y*ms), 2,2) end
    if e9on==1  then color(140,60,220) draw rect(floor(mox+e9x*ms), floor(moy+e9y*ms), 2,2) end
    if e10on==1 then color(220,60,60)  draw rect(floor(mox+e10x*ms),floor(moy+e10y*ms),2,2) end
    if e11on==1 then color(60,180,60)  draw rect(floor(mox+e11x*ms),floor(moy+e11y*ms),2,2) end
    if e12on==1 then color(160,220,255) draw rect(floor(mox+e12x*ms),floor(moy+e12y*ms),2,2) end
    if e13on==1 then color(140,60,220) draw rect(floor(mox+e13x*ms),floor(moy+e13y*ms),2,2) end
    if e14on==1 then color(60,180,60)  draw rect(floor(mox+e14x*ms),floor(moy+e14y*ms),2,2) end
    if e15on==1 then
        if frame%16<8 then color(255,200,30) else color(255,80,20) end
        draw rect(floor(mox+e15x*ms)-1,floor(moy+e15y*ms)-1,4,4)
    end
end

func drawMinimap()
    let ms=3  let mox=562  let moy=6
    let row=0
    while row<MSIZE do
        let col=0
        while col<MSIZE do
            if isWall(row,col)==1 then color(50,80,50)
            else color(12,18,12) end
            draw rect(mox+col*ms,moy+row*ms,ms-1,ms-1)
            col=col+1
        end
        row=row+1
    end
end

-- ── Pickup update ────────────────────────────────────────
func updatePickups()
    let pickup=0
    if pk0on==1 then let dx=pk0x-px let dy=pk0y-py if sqrt(dx*dx+dy*dy)<0.6 then pk0on=0 pickup=pk0type end end
    if pk1on==1 then let dx=pk1x-px let dy=pk1y-py if sqrt(dx*dx+dy*dy)<0.6 then pk1on=0 pickup=pk1type end end
    if pk2on==1 then let dx=pk2x-px let dy=pk2y-py if sqrt(dx*dx+dy*dy)<0.6 then pk2on=0 pickup=pk2type end end
    if pk3on==1 then let dx=pk3x-px let dy=pk3y-py if sqrt(dx*dx+dy*dy)<0.6 then pk3on=0 pickup=pk3type end end
    if pk4on==1 then let dx=pk4x-px let dy=pk4y-py if sqrt(dx*dx+dy*dy)<0.6 then pk4on=0 pickup=pk4type end end
    if pk5on==1 then let dx=pk5x-px let dy=pk5y-py if sqrt(dx*dx+dy*dy)<0.6 then pk5on=0 pickup=pk5type end end
    if pk6on==1 then let dx=pk6x-px let dy=pk6y-py if sqrt(dx*dx+dy*dy)<0.6 then pk6on=0 pickup=pk6type end end
    if pk7on==1 then let dx=pk7x-px let dy=pk7y-py if sqrt(dx*dx+dy*dy)<0.6 then pk7on=0 pickup=pk7type end end
    if pickup==1 then
        phealth=phealth+25 if phealth>100 then phealth=100 end
        flashR=20 flashG=140 flashB=20 flashT=3
        tone(660,40,0.3,0) tone(880,50,0.35,0)
    end
    if pickup==2 then
        ammo0=ammo0+15 ammo2=ammo2+30
        flashR=200 flashG=180 flashB=20 flashT=2
        tone(550,40,0.3,1)
    end
    if pickup==3 then
        parmor=parmor+30 if parmor>100 then parmor=100 end
        flashR=20 flashG=60 flashB=200 flashT=3
        tone(440,40,0.3,0) tone(660,50,0.35,0)
    end
    if pickup==4 then
        ammo1=ammo1+6
        flashR=200 flashG=120 flashB=20 flashT=2
        tone(480,40,0.3,1)
    end
end

func drawPickup(pkx,pky,pkon,pktype)
    if pkon==0 then return end
    let relx=pkx-px  let rely=pky-py
    let cdx=sin(pang)  let cdy=0-cos(pang)
    let planx=0-cdy*pfov  let plany=cdx*pfov
    let invdet=1.0/(planx*cdy-cdx*plany)
    let tx=invdet*(cdy*relx-cdx*rely)
    let ty=invdet*(0-plany*relx+planx*rely)
    if ty<=0.15 then return end
    let zbIdx=floor(((SW/2)*(1.0+tx/ty)/SW)*20)
    if zbIdx<0 then zbIdx=0 end if zbIdx>19 then zbIdx=19 end
    if ty>getZB(zbIdx) then return end
    -- bob animation
    let pxSize=floor(SH*0.12/ty)
    if pxSize<3 then return end if pxSize>40 then pxSize=40 end
    let scx=floor((SW/2)*(1.0+tx/ty))
    let bob2=floor(sin(frame*0.08+pkx)*3)
    let py2=HALF+floor(SH*0.30/ty)+bob2
    let half=floor(pxSize/2)
    let dlft=scx-half  let drgt=scx+half
    let dtop=py2-half  let dbot=py2+half
    if dlft<0 then dlft=0 end if drgt>SW then drgt=SW end
    if dtop<0 then dtop=0 end if dbot>SH then dbot=SH end
    let shade=floor(220/ty) if shade>255 then shade=255 end if shade<40 then shade=40 end
    -- cross shape pickup icon
    if pktype==1 then  -- health: red cross
        color(floor(180*shade/255),floor(30*shade/255),floor(30*shade/255))
        draw rect(dlft,dtop,pxSize,pxSize)
        color(floor(240*shade/255),floor(60*shade/255),floor(60*shade/255))
        draw rect(scx-1,dtop,3,pxSize)
        draw rect(dlft,py2-1,pxSize,3)
    end
    if pktype==2 then  -- ammo: yellow box
        color(floor(160*shade/255),floor(140*shade/255),floor(20*shade/255))
        draw rect(dlft,dtop,pxSize,pxSize)
        color(floor(220*shade/255),floor(200*shade/255),floor(40*shade/255))
        draw rect(dlft+1,dtop+1,pxSize-2,floor(pxSize*0.4))
    end
    if pktype==3 then  -- armor: blue diamond
        color(floor(20*shade/255),floor(60*shade/255),floor(180*shade/255))
        draw rect(dlft,dtop,pxSize,pxSize)
        color(floor(60*shade/255),floor(120*shade/255),floor(240*shade/255))
        draw rect(scx-1,dtop,3,pxSize)
        draw rect(dlft,py2-1,pxSize,3)
    end
    if pktype==4 then  -- shells: orange
        color(floor(180*shade/255),floor(80*shade/255),floor(10*shade/255))
        draw rect(dlft,dtop,pxSize,pxSize)
        color(floor(240*shade/255),floor(130*shade/255),floor(30*shade/255))
        draw rect(dlft+1,dtop+1,floor(pxSize*0.35),pxSize-2)
        draw rect(dlft+floor(pxSize*0.65),dtop+1,floor(pxSize*0.35),pxSize-2)
    end
end

func drawAllPickups()
    drawPickup(pk0x,pk0y,pk0on,pk0type) drawPickup(pk1x,pk1y,pk1on,pk1type)
    drawPickup(pk2x,pk2y,pk2on,pk2type) drawPickup(pk3x,pk3y,pk3on,pk3type)
    drawPickup(pk4x,pk4y,pk4on,pk4type) drawPickup(pk5x,pk5y,pk5on,pk5type)
    drawPickup(pk6x,pk6y,pk6on,pk6type) drawPickup(pk7x,pk7y,pk7on,pk7type)
    -- TAB: full-screen automap overlay
    if showMap==1 then
        color(0,0,0) draw rect(0,0,SW,SH)
        let ms2=8  let mox2=floor(SW/2-MSIZE*ms2/2)  let moy2=floor(SH/2-MSIZE*ms2/2)
        let row2=0
        while row2<MSIZE do
            let col2=0
            while col2<MSIZE do
                if isWall(row2,col2)==1 then color(60,90,60)
                else color(10,16,10) end
                draw rect(mox2+col2*ms2,moy2+row2*ms2,ms2-1,ms2-1)
                col2=col2+1
            end
            row2=row2+1
        end
        -- player on automap
        color(255,220,50)
        draw rect(floor(mox2+px*ms2)-2,floor(moy2+py*ms2)-2,5,5)
        let mfdx=sin(pang)  let mfdy=0-cos(pang)
        draw rect(floor(mox2+px*ms2+mfdx*5),floor(moy2+py*ms2+mfdy*5),3,3)
        -- enemies
        if e0on==1  then color(220,60,60)   draw rect(floor(mox2+e0x*ms2), floor(moy2+e0y*ms2), 4,4) end
        if e1on==1  then color(20,200,220)  draw rect(floor(mox2+e1x*ms2), floor(moy2+e1y*ms2), 4,4) end
        if e2on==1  then color(60,180,60)   draw rect(floor(mox2+e2x*ms2), floor(moy2+e2y*ms2), 4,4) end
        if e3on==1  then color(60,180,60)   draw rect(floor(mox2+e3x*ms2), floor(moy2+e3y*ms2), 4,4) end
        if e4on==1  then color(140,60,220)  draw rect(floor(mox2+e4x*ms2), floor(moy2+e4y*ms2), 4,4) end
        if e5on==1  then color(220,60,60)   draw rect(floor(mox2+e5x*ms2), floor(moy2+e5y*ms2), 4,4) end
        if e6on==1  then color(20,200,220)  draw rect(floor(mox2+e6x*ms2), floor(moy2+e6y*ms2), 4,4) end
        if e7on==1  then color(60,180,60)   draw rect(floor(mox2+e7x*ms2), floor(moy2+e7y*ms2), 4,4) end
        if e8on==1  then color(160,220,255) draw rect(floor(mox2+e8x*ms2), floor(moy2+e8y*ms2), 4,4) end
        if e9on==1  then color(140,60,220)  draw rect(floor(mox2+e9x*ms2), floor(moy2+e9y*ms2), 4,4) end
        if e15on==1 then
            if frame%12<6 then color(255,200,30) else color(255,80,20) end
            draw rect(floor(mox2+e15x*ms2)-1,floor(moy2+e15y*ms2)-1,6,6)
        end
        -- pickups
        color(40,220,80)
        if pk0on==1 then draw rect(floor(mox2+pk0x*ms2),floor(moy2+pk0y*ms2),3,3) end
        if pk1on==1 then draw rect(floor(mox2+pk1x*ms2),floor(moy2+pk1y*ms2),3,3) end
        if pk2on==1 then draw rect(floor(mox2+pk2x*ms2),floor(moy2+pk2y*ms2),3,3) end
        if pk3on==1 then draw rect(floor(mox2+pk3x*ms2),floor(moy2+pk3y*ms2),3,3) end
        if pk4on==1 then draw rect(floor(mox2+pk4x*ms2),floor(moy2+pk4y*ms2),3,3) end
        if pk5on==1 then draw rect(floor(mox2+pk5x*ms2),floor(moy2+pk5y*ms2),3,3) end
        if pk6on==1 then draw rect(floor(mox2+pk6x*ms2),floor(moy2+pk6y*ms2),3,3) end
        if pk7on==1 then draw rect(floor(mox2+pk7x*ms2),floor(moy2+pk7y*ms2),3,3) end
        color(180,180,220) draw text("TAB - close map",SW/2-40,SH-20)
    end
end

-- ── Init ──────────────────────────────────────────────────
func initEnemies()
    e0hp=3   e0on=1  e0state=0   -- imp
    e1hp=3   e1on=1  e1state=0   -- sniper
    e2hp=5   e2on=1  e2state=0   -- soldier
    e3hp=5   e3on=1  e3state=0   -- soldier
    e4hp=10  e4on=1  e4state=0   -- heavy
    e5hp=3   e5on=1  e5state=0   -- imp
    e6hp=3   e6on=1  e6state=0   -- sniper
    e7hp=5   e7on=1  e7state=0   -- soldier
    e8hp=4   e8on=1  e8state=0   -- ghost
    e9hp=10  e9on=1  e9state=0   -- heavy
    e10hp=3  e10on=1 e10state=0  -- imp
    e11hp=5  e11on=1 e11state=0  -- soldier
    e12hp=4  e12on=1 e12state=0  -- ghost
    e13hp=10 e13on=1 e13state=0  -- heavy
    e14hp=5  e14on=1 e14state=0  -- soldier
    e15hp=bossHpMax e15on=1 e15state=0 bossPhase=0  -- BOSS
end

-- ═══════════════════════
--  INIT
-- ═══════════════════════
initEnemies()
drawMinimap()
lockMouse(1)
playMusic("music.wav","bgm")
setMusicVolume("bgm",50)
let running=1

-- ═══════════════════════
--  MAIN LOOP
-- ═══════════════════════
while running==1 do
    frame=frame+1
    guncd=guncd-1         if guncd<0   then guncd=0   end
    muzzle=muzzle-1       if muzzle<0  then muzzle=0  end
    hitmsg=hitmsg-1       if hitmsg<0  then hitmsg=0  end
    damage=damage-1       if damage<0  then damage=0  end
    screenShake=screenShake-1 if screenShake<0 then screenShake=0 end

    if keydown(KEY_ESC)==1 then lockMouse(0) stopMusic("bgm") running=0 end
    if keydown(KEY_TAB)==1 and frame%10==0 then
        if showMap==0 then showMap=1 else showMap=0 end
    end
    if phealth<=0 then lockMouse(0) stopMusic("bgm") sfxDeath() running=0 end
    if kills>=totalEnemies then lockMouse(0) stopMusic("bgm") chord(523,659,784,500,0.5) running=0 end

    -- Weapon switch
    if keydown(KEY_1)==1 then weapon=1 end
    if keydown(KEY_2)==1 then weapon=2 end
    if keydown(KEY_3)==1 then weapon=3 end

    -- Reload
    if reloading==1 then
        reloadT=reloadT-1
        if reloadT<=0 then
            reloading=0
            if weapon==1 then ammo0=ammo0+12 end
            if weapon==2 then ammo1=ammo1+4  end
            if weapon==3 then ammo2=ammo2+25 end
            tone(440,60,0.3,0)
        end
    else
        if keydown(KEY_R)==1 then reloading=1 reloadT=30 tone(280,40,0.2,2) end
    end

    -- Turn
    pang=pang+mouseDX()*MSENS
    if keydown(KEY_LEFT)==1  then pang=pang-tspd end
    if keydown(KEY_RIGHT)==1 then pang=pang+tspd end

    -- Move
    let spd=pspd  if keydown(KEY_SHIFT)==1 then spd=pspd*2.0 end
    let fdx=sin(pang)  let fdy=0-cos(pang)
    let sdx=0-fdy      let sdy=fdx
    let moving=0
    if keydown(KEY_W)==1 then
        let nx=px+fdx*spd  let ny=py+fdy*spd
        if canMove(nx,py)==1 then px=nx end
        if canMove(px,ny)==1 then py=ny end
        moving=1
    end
    if keydown(KEY_S)==1 then
        let nx=px-fdx*spd  let ny=py-fdy*spd
        if canMove(nx,py)==1 then px=nx end
        if canMove(px,ny)==1 then py=ny end
        moving=1
    end
    if keydown(KEY_A)==1 then
        let nx=px-sdx*spd  let ny=py-sdy*spd
        if canMove(nx,py)==1 then px=nx end
        if canMove(px,ny)==1 then py=ny end
        moving=1
    end
    if keydown(KEY_D)==1 then
        let nx=px+sdx*spd  let ny=py+sdy*spd
        if canMove(nx,py)==1 then px=nx end
        if canMove(px,ny)==1 then py=ny end
        moving=1
    end
    -- Head bob
    if moving==1 then
        footstepT=footstepT+1
        let bobSpd=0.10  if keydown(KEY_SHIFT)==1 then bobSpd=0.16 end
        headBob=sin(footstepT*bobSpd)*3.5
        -- footstep sound at peak/trough of bob cycle
        if footstepT%32==0 then tone(80,25,0.12,2) end
    else
        headBob=headBob*0.85  -- settle back to zero
        footstepT=0
    end

    -- Shoot
    let fr=14  if weapon==3 then fr=5 end  if weapon==2 then fr=22 end
    if keydown(KEY_SPACE)==1 then
        if guncd==0 and reloading==0 then
            tryShoot()
            guncd=fr  muzzle=5  gunframe=4
        end
    end
    if gunframe>0 then gunframe=gunframe-1 end

    -- AI + pickups
    updateEnemy(0)  updateEnemy(1)  updateEnemy(2)  updateEnemy(3)
    updateEnemy(4)  updateEnemy(5)  updateEnemy(6)  updateEnemy(7)
    updateEnemy(8)  updateEnemy(9)  updateEnemy(10) updateEnemy(11)
    updateEnemy(12) updateEnemy(13) updateEnemy(14) updateEnemy(15)
    updateAllEP()
    moveParticles()
    updatePickups()

    -- Minimap refresh
    if frame%60==1 then drawMinimap() end

    -- Render
    let cx=0-fdy*pfov  let cy=fdx*pfov
    -- Apply head bob: temporarily shift horizon
    let vertShake=0
    if screenShake>0 then vertShake=floor(sin(frame*3.1)*screenShake*0.4) end
    HALF=floor(200+headBob+vertShake)
    let col=0
    while col<COLS do
        let camX2=2.0*col/COLS-1.0
        let rdx=fdx+cx*camX2  let rdy=fdy+cy*camX2
        let res=castRay(rdx,rdy)
        let side=floor(res/1000)
        let dist=res-side*1000
        drawCol(floor(col*640/COLS),dist,side,lastWallX)
        if col%6==0 then setZB(floor(col/6),dist) end
        col=col+1
    end
    HALF=200  -- restore after render

    -- Sprites
    drawParticles()
    drawAllPickups()
    drawEP(ep0x,ep0y,ep0on,ep0type)   drawEP(ep1x,ep1y,ep1on,ep1type)
    drawEP(ep2x,ep2y,ep2on,ep2type)   drawEP(ep3x,ep3y,ep3on,ep3type)
    drawEP(ep4x,ep4y,ep4on,ep4type)   drawEP(ep5x,ep5y,ep5on,ep5type)
    drawEP(ep6x,ep6y,ep6on,ep6type)   drawEP(ep7x,ep7y,ep7on,ep7type)
    drawEP(ep8x,ep8y,ep8on,ep8type)   drawEP(ep9x,ep9y,ep9on,ep9type)
    drawEP(ep10x,ep10y,ep10on,ep10type) drawEP(ep11x,ep11y,ep11on,ep11type)
    drawEP(ep12x,ep12y,ep12on,ep12type) drawEP(ep13x,ep13y,ep13on,ep13type)
    drawEP(ep14x,ep14y,ep14on,ep14type) drawEP(ep15x,ep15y,ep15on,ep15type)
    drawEnemy(e0x,e0y,e0hp,e0on,e0type,e0state)
    drawEnemy(e1x,e1y,e1hp,e1on,e1type,e1state)
    drawEnemy(e2x,e2y,e2hp,e2on,e2type,e2state)
    drawEnemy(e3x,e3y,e3hp,e3on,e3type,e3state)
    drawEnemy(e4x,e4y,e4hp,e4on,e4type,e4state)
    drawEnemy(e5x,e5y,e5hp,e5on,e5type,e5state)
    drawEnemy(e6x,e6y,e6hp,e6on,e6type,e6state)
    drawEnemy(e7x,e7y,e7hp,e7on,e7type,e7state)
    drawEnemy(e8x,e8y,e8hp,e8on,e8type,e8state)
    drawEnemy(e9x,e9y,e9hp,e9on,e9type,e9state)
    drawEnemy(e10x,e10y,e10hp,e10on,e10type,e10state)
    drawEnemy(e11x,e11y,e11hp,e11on,e11type,e11state)
    drawEnemy(e12x,e12y,e12hp,e12on,e12type,e12state)
    drawEnemy(e13x,e13y,e13hp,e13on,e13type,e13state)
    drawEnemy(e14x,e14y,e14hp,e14on,e14type,e14state)
    drawEnemy(e15x,e15y,e15hp,e15on,e15type,e15state)

    drawGun()
    drawHUD()
    sleep(7)
end

-- ═══════════════════════
--  END SCREEN
-- ═══════════════════════
let t=0
while t<300 do
    color(8,4,4) clear()
    let si=0
    while si<30 do
        let ssx=floor(abs(sin(si*137.5+t*0.02))*638)+1
        let ssy=floor(abs(cos(si*251.3))*398)+1
        color(60,60,100) draw rect(ssx,ssy,2,2)
        si=si+1
    end
    if t<12 and phealth<=0 then color(140,10,10) draw rect(0,0,SW,SH) end
    if t%28<18 then
        if phealth<=0 then
            color(220,40,40)  draw text("YOU  DIED",    220,150)
            color(255,100,100) draw text("YOU  DIED",   218,148)
        else
            color(80,220,80)  draw text("YOU  WIN!",    224,150)
            if t==2 then
                chord(523,659,784,300,0.4)
                chord(659,784,988,300,0.5)
                chord(784,988,1047,600,0.6)
            end
        end
        color(255,220,50)  draw text("KILLS  "+tostr(kills)+" / "+tostr(totalEnemies),220,186)
        -- star rating out of 5
        let stars=floor(kills*5/totalEnemies)
        if phealth<=0 then stars=0 end
        let si2=0
        while si2<5 do
            if si2<stars then color(255,200,40) else color(35,35,55) end
            draw rect(218+si2*24,216,16,16)
            draw rect(222+si2*24,212,8,8)
            si2=si2+1
        end
        color(130,130,180) draw text("close window to exit",194,252)
    end
    t=t+1
    sleep(16)
end
