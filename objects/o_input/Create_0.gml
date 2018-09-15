global.key_revert	= ord("X");

global.select_key	= vk_enter;
global.select_pad	= gp_face1;

global.down_key		= vk_down;
global.up_key		= vk_up;
global.up_pad		= gp_face1;
global.v_pad		= gp_axislv;

global.left_key		= vk_left;
global.right_key	= vk_right;
global.h_pad		= gp_axislh;

global.escape_key	= vk_escape;
global.escape_pad	= gp_start;

global.z_key		= ord("Z");
global.x_key		= ord("X");
global.c_key		= ord("C");
global.attack_key	= vk_space;

// Moving direction gamepad
#macro up_pad_released_ gamepad_button_check_released(0, gp_face1)
#macro sprint_pad_ gamepad_button_check(0, gp_shoulderrb)
#macro game_menu_pad_ gamepad_button_check_pressed(0, gp_select)
