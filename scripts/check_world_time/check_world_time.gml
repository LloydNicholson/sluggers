if global.count_up == true {
	global.secs	+= 1/room_speed;
}

if (global.secs < 60) && (global.secs > 59.9) {
	global.secs = 0;
	global.minutes += 1;
}
