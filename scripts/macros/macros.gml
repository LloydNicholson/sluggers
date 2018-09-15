// Macros

// Player index
#macro stand_index_ s_player;
#macro jump_index_ s_player_jump;
#macro walk_right_ s_player_right;
#macro left_slide_index_ s_player_slide;
#macro attack_index s_player_attack;

// Menu keyboard
#macro select_key_ keyboard_check_pressed(vk_enter) 
#macro down_key_ keyboard_check_pressed(vk_down) 


// Menu gamepad
#macro up_pad_alt gamepad_button_check_pressed(0, gp_padu)
#macro down_pad_alt gamepad_button_check_pressed(0, gp_padd)
#macro select_pad_ gamepad_button_check_pressed(0, gp_face1) 
