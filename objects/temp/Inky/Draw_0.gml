if Pac.alarm[9] = -1{
if chomped = 0{
if state = 0{
    if house = 0 and global.start = 0 and global.boost = 2 and !collision_point(tilex,tiley,Slow,false,true){
        if dir = 1{draw_sprite_ext(spr_boostlines,5,x,y,1,1,0,make_color_rgb(0,255,255),1)};
        else{if dir = 3{draw_sprite_ext(spr_boostlines,6,x,y+(global.plus*floor(global.game/2)*8),1,1,0,make_color_rgb(0,255,255),1)};
        else{draw_sprite_ext(spr_boostlines,dir,x,y+(global.plus*floor(global.game/2)*8),1,1,0,make_color_rgb(0,255,255),1)}
        }}
if global.otto = 0{
    if global.start = false{draw_sprite_ext(spr_Ghost,(floor(im/8))+(floor((global.plus+(global.game/2))/2))*6,x,y,1,1,0,make_color_rgb(0,255,255),1)}
    else{draw_sprite_ext(spr_Ghost,0+(floor((global.plus+(global.game/2))/2))*6,x,y,1,1,0,make_color_rgb(0,255,255),1);}
}
else{
    if global.start = false{draw_sprite_ext(spr_OttoMon,(floor(im/8))+(2*dir),x,y,1,1,0,make_color_rgb(0,255,255),1);
    draw_sprite(spr_OttoMon,(floor(im/8))+(2*dir)+8,x,y);}
    else{draw_sprite_ext(spr_OttoMon,4-2,x,y,1,1,0,make_color_rgb(0,255,255),1);
    draw_sprite(spr_OttoMon,4+8-2,x,y);}
}
}
if global.game = 2 and global.plus = true{
    if state = 1{}else{draw_sprite(spr_Eyes,dir,x,y+6)}
}
else{
    if state = 1 or (global.otto = 1 and state = 2){}else{draw_sprite(spr_Eyes,dir,x,y)}
}
if state = 1{
    if global.otto = 1{draw_sprite(spr_OttoMon,16+(floor(im/8))+(flash*2),x,y);}
    else{
    draw_sprite_ext(spr_Ghost,(floor(im/8))+(global.plus*2)+(floor((global.plus+(global.game/2))/2))*6,x,y,1,1,0,make_color_rgb(flash*255,flash*255,255),1)
    if global.plus = true{draw_sprite(spr_Ghost,(floor(im/8))+4,x,y)}
    draw_sprite(spr_Eyes,4+flash,x,y+(global.plus*3))
}}
if global.start = false{if global.game = 2 and global.plus = 1{
if state = 1{draw_sprite_ext(spr_Ghost,(floor(im/8))+10,x,y,1,1,0,make_color_rgb(255,255-(flash*255),255-(flash*255)),1)}
else{draw_sprite_ext(spr_Ghost,(floor(im/8))+10,x,y,1,1,0,c_white,1)}
}}
else{if global.game = 2 and global.plus = 1{draw_sprite(spr_Ghost,0+10,x,y)}}
}
}

var __b__;
__b__ = action_if_variable(room_height, 576, 0);
if __b__
{
{
if Pac.alarm[9] = -1{
if chomped = 0{
if state = 0{
if global.otto = 0{
    if global.start = false{draw_sprite_ext(spr_Ghost,(floor(im/8))+(floor((global.plus+(global.game/2))/2))*6,x,y-512,1,1,0,make_color_rgb(0,255,255),1)}
    else{draw_sprite_ext(spr_Ghost,0+(floor((global.plus+(global.game/2))/2))*6,x,y-512,1,1,0,make_color_rgb(0,255,255),1);}
}
else{
    if global.start = false{draw_sprite_ext(spr_OttoMon,(floor(im/8))+(2*dir),x,y-512,1,1,0,make_color_rgb(0,255,255),1);
    draw_sprite(spr_OttoMon,(floor(im/8))+(2*dir)+8,x,y-512);}
    else{draw_sprite_ext(spr_OttoMon,4-2,x,y-512,1,1,0,make_color_rgb(0,255,255),1);
    draw_sprite(spr_OttoMon,4+8-2,x,y-512);}
}
}
if global.game = 2 and global.plus = true{
    if state = 1{}else{draw_sprite(spr_Eyes,dir,x,y-512+6)}
}
else{
    if state = 1 or (global.otto = 1 and state = 2){}else{draw_sprite(spr_Eyes,dir,x,y-512)}
}
if state = 1{
    if global.otto = 1{draw_sprite(spr_OttoMon,16+(floor(im/8))+(flash*2),x,y-512);}
    else{
    draw_sprite_ext(spr_Ghost,(floor(im/8))+(global.plus*2)+(floor((global.plus+(global.game/2))/2))*6,x,y-512,1,1,0,make_color_rgb(flash*255,flash*255,255),1)
    if global.plus = true{draw_sprite(spr_Ghost,(floor(im/8))+4,x,y-512)}
    draw_sprite(spr_Eyes,4+flash,x,y-512+(global.plus*3))
}}
if global.start = false{if global.game = 2 and global.plus = 1{
if state = 1{draw_sprite_ext(spr_Ghost,(floor(im/8))+10,x,y-512,1,1,0,make_color_rgb(255,255-(flash*255),255-(flash*255)),1)}
else{draw_sprite_ext(spr_Ghost,(floor(im/8))+10,x,y-512,1,1,0,c_white,1)}
}}
else{if global.game = 2 and global.plus = 1{draw_sprite(spr_Ghost,0+10,x,y-512)}}
}
}

if Pac.alarm[9] = -1{
if chomped = 0{
if state = 0{
if global.otto = 0{
    if global.start = false{draw_sprite_ext(spr_Ghost,(floor(im/8))+(floor((global.plus+(global.game/2))/2))*6,x,y+512,1,1,0,make_color_rgb(0,255,255),1)}
    else{draw_sprite_ext(spr_Ghost,0+(floor((global.plus+(global.game/2))/2))*6,x,y+512,1,1,0,make_color_rgb(0,255,255),1);}
}
else{
    if global.start = false{draw_sprite_ext(spr_OttoMon,(floor(im/8))+(2*dir),x,y+512,1,1,0,make_color_rgb(0,255,255),1);
    draw_sprite(spr_OttoMon,(floor(im/8))+(2*dir)+8,x,y+512);}
    else{draw_sprite_ext(spr_OttoMon,4-2,x,y+512,1,1,0,make_color_rgb(0,255,255),1);
    draw_sprite(spr_OttoMon,4+8-2,x,y+512);}
}
}
if global.game = 2 and global.plus = true{
    if state = 1{}else{draw_sprite(spr_Eyes,dir,x,y+512+6)}
}
else{
    if state = 1 or (global.otto = 1 and state = 2){}else{draw_sprite(spr_Eyes,dir,x,y+512)}
}
if state = 1{
    if global.otto = 1{draw_sprite(spr_OttoMon,16+(floor(im/8))+(flash*2),x,y+512);}
    else{
    draw_sprite_ext(spr_Ghost,(floor(im/8))+(global.plus*2)+(floor((global.plus+(global.game/2))/2))*6,x,y+512,1,1,0,make_color_rgb(flash*255,flash*255,255),1)
    if global.plus = true{draw_sprite(spr_Ghost,(floor(im/8))+4,x,y+512)}
    draw_sprite(spr_Eyes,4+flash,x,y+512+(global.plus*3))
}}
if global.start = false{if global.game = 2 and global.plus = 1{
if state = 1{draw_sprite_ext(spr_Ghost,(floor(im/8))+10,x,y+512,1,1,0,make_color_rgb(255,255-(flash*255),255-(flash*255)),1)}
else{draw_sprite_ext(spr_Ghost,(floor(im/8))+10,x,y+512,1,1,0,c_white,1)}
}}
else{if global.game = 2 and global.plus = 1{draw_sprite(spr_Ghost,0+10,x,y+512)}}
}
}

}
}
