/// @desc Wall 
wall_jump();
apply_wall_friction();

// Change to ground state
if place_meeting(x, y+1, collision_object_) { state = GROUND; } 
