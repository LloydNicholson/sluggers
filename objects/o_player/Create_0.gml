// Player variables
depth = -100;
initialise_movement_entity(1, 0, o_solid, 1);

// Gamepad deadzone
gamepad_set_axis_deadzone(0, 0.5);

AIR = 0;
GROUND = 1;
WALL = 2;
state = AIR;

enum dir {
	right = 1,
	left = -1
}

// Coyote time (grace frames to jump after walking off a ledge)
coyote_time_ = 0;
coyote_frames_ = 7;

// Jump buffer (press jump slightly early and still jump on landing)
jump_buffer_ = 0;
jump_buffer_frames_ = 10;

// Health system
health_ = 3;
max_health_ = 3;
invincible_ = 0;
invincible_frames_ = 90;

// Death animation
dead_ = false;
dead_timer_ = 0;

// Squash and stretch targets
target_yscale_ = 1;
target_xscale_ = 1;

// Respawn position (set on room entry)
respawn_x_ = x;
respawn_y_ = y;
