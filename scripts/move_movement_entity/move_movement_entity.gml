/// @arg bounce
var _bounce = argument0;

// Horizontal collision - step pixel-by-pixel to wall edge
if place_meeting(x + hspeed_, y, collision_object_) {
	while !place_meeting(x + sign(hspeed_), y, collision_object_) {
		x += sign(hspeed_);
	}
	if _bounce {
		hspeed_ = -(hspeed_) * bounce_amount_;
	} else {
		hspeed_ = 0;
	}
}

x += hspeed_;

// Vertical collision - step pixel-by-pixel to surface
if place_meeting(x, y + vspeed_, collision_object_) {
	while !place_meeting(x, y + sign(vspeed_), collision_object_) {
		y += sign(vspeed_);
	}
	if _bounce {
		vspeed_ = -(vspeed_) * bounce_amount_;
	} else {
		vspeed_ = 0;
	}
}

y += vspeed_;