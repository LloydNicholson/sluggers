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
