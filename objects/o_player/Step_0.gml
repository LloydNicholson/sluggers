// Death animation - overrides all other logic while dying
if dead_ {
	dead_timer_++;
	image_angle += 14;
	image_xscale = lerp(image_xscale, 0, 0.07);
	image_yscale = lerp(image_yscale, 0, 0.07);

	if dead_timer_ >= 80 {
		dead_ = false;
		dead_timer_ = 0;
		image_angle = 0;
		image_xscale = 1;
		image_yscale = 1;
		target_xscale_ = 1;
		target_yscale_ = 1;
		health_ = max_health_;
		vspeed_ = 0;
		hspeed_ = 0;
		state = AIR;
		invincible_ = invincible_frames_;

		if instance_exists(global.player_start_position) {
			x = global.player_start_position.x;
			y = global.player_start_position.y;
		} else {
			x = respawn_x_;
			y = respawn_y_;
		}
	}
	exit;
}

// Smooth squash and stretch toward targets
image_yscale += (target_yscale_ - image_yscale) * 0.25;
image_xscale += (target_xscale_ - image_xscale) * 0.25;
if abs(image_yscale - target_yscale_) < 0.01 { image_yscale = target_yscale_; }
if abs(abs(image_xscale) - abs(target_xscale_)) < 0.01 {
	image_xscale = target_xscale_ * sign(image_xscale != 0 ? image_xscale : 1);
}

// Run state machine (AIR=0, GROUND=1, WALL=2)
event_user(state);

vspeed_ += gravity_;
move_movement_entity(false);
player_move();

// Invincibility flash (alternate white/red)
if invincible_ > 0 {
	invincible_--;
	image_blend = (invincible_ mod 6 < 3) ? c_white : c_red;
} else {
	image_blend = c_white;
}

