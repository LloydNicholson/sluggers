/// @desc Ground
apply_friction_to_movement_entity();
player_jump();
ground_player_move();

// Change to air state
if !place_meeting(x, y+1, collision_object_) { state = AIR; }

