/// @desc Wall
wall_jump();
apply_wall_friction();

// Wall slide squash
target_xscale_ = sign(image_xscale != 0 ? image_xscale : 1) * 0.8;
target_yscale_ = 1.2;

// Change to ground state
if place_meeting(x, y + 1, collision_object_) {
	state = GROUND;
	target_yscale_ = 0.7;
	target_xscale_ = sign(image_xscale != 0 ? image_xscale : 1) * 1.3;
}

// Leave wall state if no longer touching wall
if !place_meeting(x + 1, y, collision_object_) && !place_meeting(x - 1, y, collision_object_) {
	state = AIR;
}
