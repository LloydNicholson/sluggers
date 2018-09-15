/// @desc Air
// Collision with ground
vspeed_ += gravity_;
sprite_index = jump_index_;

player_jump_height();

hspeed_ += air_speed_/4;

// Change to ground state
if place_meeting(x, y+1, collision_object_) { state = GROUND; } 

// Change to wall state
if place_meeting(x+sign(hspeed_), y, collision_object_) { state = WALL; }
