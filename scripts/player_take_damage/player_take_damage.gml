/// player_take_damage()
/// Call from player context when taking damage from an enemy or hazard.
/// @arg [knockback_source_x] Optional x position to knockback away from
/// @arg [knockback_source_y] Optional y position to knockback away from

if invincible_ > 0 || dead_ { exit; }

health_ -= 1;
invincible_ = invincible_frames_;

// Knockback away from damage source
var _src_x = (argument_count > 0) ? argument[0] : x;
hspeed_ = sign(x - _src_x) * 7;
if hspeed_ == 0 { hspeed_ = 7; }
vspeed_ = -9;

if health_ <= 0 {
	dead_ = true;
	dead_timer_ = 0;
	vspeed_ = 0;
	hspeed_ = 0;
}
