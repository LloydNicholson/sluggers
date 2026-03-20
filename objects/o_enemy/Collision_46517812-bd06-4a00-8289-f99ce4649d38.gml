// Take damage from hitbox
if invincible_frames_ <= 0 {
	health_ -= 1;
	invincible_frames_ = 18;

	if health_ <= 0 {
		instance_destroy(self);
	}
}