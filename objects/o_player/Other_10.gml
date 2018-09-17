/// @desc Air
player_jump_height();
air_player_move();

// Change to ground state
if place_meeting(x, y+1, collision_object_) { state = GROUND; } 

// Change to wall state
if (place_meeting(x+1, y, collision_object_)) || (place_meeting(x-1, y, collision_object_)) { state = WALL; }
