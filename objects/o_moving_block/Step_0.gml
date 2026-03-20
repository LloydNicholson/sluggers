if x >= x_max - block_width {
	hspeed_ = -hspeed_;
} else if x <= x_min {
	hspeed_ = -hspeed_;
}

x += hspeed_;

// Push player if standing on top
if instance_exists(o_player) {
	var inst = instance_place(x, y - 1, o_player);
	if inst != noone {
		inst.hspeed_ = hspeed_;
	}
}

