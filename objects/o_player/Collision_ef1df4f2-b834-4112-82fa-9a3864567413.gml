/// @desc Player touches death area - instant kill
if !dead_ && invincible_ <= 0 {
	dead_ = true;
	dead_timer_ = 0;
	vspeed_ = 0;
	hspeed_ = 0;
}
