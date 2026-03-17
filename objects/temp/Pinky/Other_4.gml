tilex = (16*(round(x/16)))
tiley = (16*(round(y/16)))
newtile = 0
if global.game < 2{
{sp = 1.875; spslow = 1; spfright = 1.25;}
if global.lvl > 1{sp = 2.125; spslow = 1.125; spfright = 1.375;}
if global.lvl > 4 or global.plus = true{sp = 2.375; spslow = 1.25; spfright = 1.5;}
}
else{
{sp = 2.125; spslow = 1.125; spfright = 1.375; spelroy = 2.25;}
if global.lvl > 2 or global.plus = true{sp = 2.375; spslow = 1.25; spfright = 1.5;}
}
speyes = 4;
if global.boost = 2{sp = 4};
dir = 3;
im = 0;
aboutface = 0
hspeed = 0; vspeed = spslow;
state = 0;
flash = 0;
house = 1;
housestate = 1;
resdir = -1;
chomped = 0;
up = 0;
cornerx = 32;
cornery = -16;
uppity = 1;

