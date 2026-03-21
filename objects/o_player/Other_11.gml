/// @desc Ground

// Reset coyote time while grounded
coyote_time_ = coyote_frames_;

// Restore scale to normal while on ground
target_yscale_ = 1;
target_xscale_ = sign(image_xscale != 0 ? image_xscale : 1) * 1;

apply_friction_to_movement_entity();
player_jump();
ground_player_move();

// Change to air state
if !place_meeting(x, y + 1, collision_object_) { state = AIR; }

