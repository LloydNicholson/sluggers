/// @desc Ground
apply_friction_to_movement_entity();
player_jump();
sprite_index = stand_index_;
image_speed = 2;

// Change to air state
if !place_meeting(x, y+1, collision_object_) { state = AIR; }

