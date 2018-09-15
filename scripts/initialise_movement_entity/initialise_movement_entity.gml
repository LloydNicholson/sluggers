///@arg friction
///@arg bounce
///@arg collision_object
///@arg gravity

friction_ = argument0;
bounce_amount_ = argument1;
collision_object_ = argument2;
gravity_ = argument3;

vspeed_ = 0;
hspeed_ = 0;
jump_speed_ = 20;
acceleration_ = 0.5;
max_speed_ = 10;
speed_ = 0;
direction_ = 0;
air_speed_ = hspeed_/2;