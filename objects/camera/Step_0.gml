if instance_exists(target) {
	// Smooth return to position
	x = lerp(x, target.x, follow_speed);
	y = lerp(y, target.y, follow_speed);
} 