with Blinky{if house = 0 and state<2{
direction = resdir*90;
}resdir = -1}
with Pinky{if house = 0 and state<2{
direction = resdir*90;
}resdir = -1}
with Inky{if house = 0 and state<2{
direction = resdir*90;
}resdir = -1}
with Clyde{if house = 0 and state<2{
direction = resdir*90;
}resdir = -1}
with Fruit{if state>-1{
direction = resdir*90;
}resdir = -1}
Pac.chomp = 0; state = 2; chomped = 0;
with Pac{
if fright = true{
if pause = 0{
if eatdir = 0{hspeed = spfright; vspeed = 0; eatdir = -1}
if eatdir = 1{hspeed = spfright; vspeed = -spfright; eatdir = -1}
if eatdir = 2{hspeed = 0; vspeed = -spfright; eatdir = -1}
if eatdir = 3{hspeed = -spfright; vspeed = -spfright; eatdir = -1}
if eatdir = 4{hspeed = -spfright; vspeed = 0; eatdir = -1}
if eatdir = 5{hspeed = -spfright; vspeed = spfright; eatdir = -1}
if eatdir = 6{hspeed = 0; vspeed = spfright; eatdir = -1}
if eatdir = 7{hspeed = spfright; vspeed = spfright; eatdir = -1}
if bonked = 1{speed = speed*4};
}
else{pause = pause - 1}

}
else{
if pause = 0{
if eatdir = 0{hspeed = sp; vspeed = 0; eatdir = -1}
if eatdir = 1{hspeed = sp; vspeed = -sp; eatdir = -1}
if eatdir = 2{hspeed = 0; vspeed = -sp; eatdir = -1}
if eatdir = 3{hspeed = -sp; vspeed = -sp; eatdir = -1}
if eatdir = 4{hspeed = -sp; vspeed = 0; eatdir = -1}
if eatdir = 5{hspeed = -sp; vspeed = sp; eatdir = -1}
if eatdir = 6{hspeed = 0; vspeed = sp; eatdir = -1}
if eatdir = 7{hspeed = sp; vspeed = sp; eatdir = -1}
if bonked = 1{speed = speed*4};
}
else{pause = pause - 1}

}
}

