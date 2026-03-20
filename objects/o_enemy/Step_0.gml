/// @desc Enemy AI step

// Apply gravity
vspeed_ += gravity_;

// Vertical collision
if place_meeting(x, y + vspeed_, o_solid) {
	while !place_meeting(x, y + sign(vspeed_), o_solid) {
		y += sign(vspeed_);
	}
	vspeed_ = 0;
}
y += vspeed_;

// Detect player
if instance_exists(o_player) && !o_player.dead_ {
	var _dist = point_distance(x, y, o_player.x, o_player.y);
	angry_ = (_dist < detect_range_);

	if angry_ {
		// Chase player horizontally
		hspeed_ = sign(o_player.x - x) * chase_speed_;
	}
}

// Horizontal wall collision - bounce direction
if place_meeting(x + hspeed_, y, o_solid) {
	hspeed_ = -hspeed_;
}

// Edge detection - don't walk off platforms (only when patrolling, not chasing)
if !angry_ {
	var _look_x = x + sign(hspeed_) * 20;
	if !place_meeting(_look_x, y + 20, o_solid) && !place_meeting(x, y + 1, o_solid) == false {
		hspeed_ = -hspeed_;
	}
}

x += hspeed_;

// Clamp speed
hspeed_ = clamp(hspeed_, -chase_speed_ * 1.2, chase_speed_ * 1.2);
if hspeed_ == 0 { hspeed_ = move_speed_; }

// Face movement direction
if hspeed_ > 0 {
	image_xscale = 1;
} else {
	image_xscale = -1;
}

// Bob animation - subtle vertical bounce
bob_timer_ += 0.12;
image_yscale = 1 + sin(bob_timer_) * 0.07;

// Blink animation
blink_timer_--;
if blink_timer_ <= 0 {
	blink_ = 7;
	blink_timer_ = irandom_range(90, 360);
}
if blink_ > 0 { blink_--; }
eye_offset_y_ = (blink_ > 0) ? 2 : 0;

// Invincibility flash
if invincible_frames_ > 0 {
	invincible_frames_--;
	image_blend = (invincible_frames_ mod 4 < 2) ? c_white : c_yellow;
} else {
	// Color based on state
	if angry_ {
		image_blend = make_color_rgb(255, 150, 150);
	} else {
		image_blend = c_white;
	}
}
