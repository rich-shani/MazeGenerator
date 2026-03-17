if Pac.dead = 0 and Pac.finish = 0{
if house = 1{newtile = 0; tilex = (xstart - 216) +  224; tiley = (ystart - 272) +  224}
if house = 0 and state = 2 and x > (xstart - 216) + 212 and x < (xstart - 216) +  220 and y = (ystart - 272) +  224{housestate=0;
    x = (xstart - 216) +  216; y = (ystart - 272) +  224; hspeed = 0; vspeed = speyes; house = 1; dir = 3;}
if house = 1 and state = 2 and x = (xstart - 216) +  216 and y > (ystart - 272) +  272 + 8{housestate=1;
    x = (xstart - 216) +  216; y = (ystart - 272) +  272 + 8; hspeed = 0; vspeed = -spslow; state = 0; dir = 1;}
if housestate = 1{  ///bouncing state
    if Pac.psig > Pac.dotcount{
        if y < (ystart - 272) +  264{y = (ystart - 272) +  264; hspeed = 0; vspeed = spslow; up = 0; dir = 3}
        if y > (ystart - 272) +  280{y = (ystart - 272) +  280; hspeed = 0; vspeed = -spslow; up = 1; dir = 1}
        if up = 0{hspeed = 0; vspeed = spslow;}else{hspeed = 0; vspeed = -spslow;}
    }
    else{
        if global.start = 0 and Pac.finish = 0{housestate = 2}
    }
}
if housestate = 2{hspeed = 0; vspeed = -spslow; dir = 1}
if house = 1 and state < 2 and x = (xstart - 216) +  216 and y < (ystart - 272) +  224{housestate=0;
    x = (xstart - 216) +  216; y = (ystart - 272) +  224; hspeed = -sp; vspeed = 0; house = 0; newtile = 0; dir = 2;}
}

if Pac.dead = 0 and Pac.finish = 0{
//speed
if house = 0{
if state = 0{
    if collision_point(tilex,tiley,Slow,false,true){speed = spslow}
    else{speed = sp}
}    
if state = 1{
    if collision_point(tilex,tiley,Slow,false,true){speed = spslow}else{speed = spfright}
}
if state = 2{
    speed = speyes
}
//turning
if Pac.chomp = 0 or state = 2{
if newtile = 1{
if dir = 0{
    if direction = 0 and x > tilex{direction = 0; newtile = 0; exit}
    if direction = 90 and y < tiley{direction = 0; x=tilex+(tiley-y); y=tiley; newtile = 0; exit}
    if direction = 180 and x < tilex{x = tilex; direction = 0; newtile = 0; exit}
    if direction = 270 and y > tiley{direction = 0; x=tilex+(y-tiley); y=tiley; newtile = 0; exit}
}
if dir = 1{
    if direction = 0 and x > tilex{direction = 90; y=tiley-(x-tilex); x=tilex; newtile = 0; exit}
    if direction = 90 and y < tiley{direction = 90; newtile = 0; exit}
    if direction = 180 and x < tilex{direction = 90; y=tiley-(tilex-x); x=tilex; newtile = 0; exit}
    if direction = 270 and y > tiley{y = tiley; direction = 90; newtile = 0; exit}
}
if dir = 2{
    if direction = 0 and x > tilex{x = tilex; direction = 180; newtile = 0; exit}
    if direction = 90 and y < tiley{direction = 180; x=tilex-(tiley-y); y=tiley; newtile = 0; exit}
    if direction = 180 and x < tilex{direction = 180; newtile = 0; exit}
    if direction = 270 and y > tiley{direction = 180; x=tilex-(y-tiley); y=tiley; newtile = 0; exit}
}
if dir = 3{
    if direction = 0 and x > tilex{direction = 270; y=tiley+(x-tilex); x=tilex; newtile = 0; exit}
    if direction = 90 and y < tiley{y = tiley; direction = 270; newtile = 0; exit}
    if direction = 180 and x < tilex{direction = 270; y=tiley+(tilex-x); x=tilex; newtile = 0; exit}
    if direction = 270 and y > tiley{direction = 270; newtile = 0; exit}
}
}
}
}
}

if room_width > 448{
if house = 0{
if x<__view_get( e__VW.XView, 0 )-32 and x>__view_get( e__VW.XView, 0 )-40 and dir = 2{aboutface = 1};
if x>__view_get( e__VW.XView, 0 )+480 and x<__view_get( e__VW.XView, 0 )+488 and dir = 0{aboutface = 1};
}}
if room_height = 960{
if house = 0{
if y<__view_get( e__VW.YView, 0 )+16 and y>__view_get( e__VW.YView, 0 )+8 and dir = 1{aboutface = 1};
if y>__view_get( e__VW.YView, 0 )+560-32 and y<__view_get( e__VW.YView, 0 )+568-32 and dir = 3{aboutface = 1};
}}

if state = 1{
    if Pac.alarm[0] < 121{visible = true}
}
else{visible = true}


if direction = 90 and y < 32
{y = 544; tiley = 16*(round(y/16));}
if direction = 270 and y > room_height - 32
{y = 32; tiley = 16*(round(y/16));}


