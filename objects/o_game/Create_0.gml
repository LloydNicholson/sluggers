/// @description Setup global variables
// World globals
global.one_second = game_get_speed(gamespeed_fps);
global.minutes = 0;
global.secs = 0;
global.destroyed = [];
global.created = [];
global.pause = false;
global.count_up = true;

// View variables
global.view_width = camera_get_view_width(view_camera[0]);
global.view_height = camera_get_view_height(view_camera[0]);

// Player globals
global.player_stamina = 1;
global.max_player_stamina = 4;
global.diamonds = 0;
global.player_start_position = i_game_start;
global.player_score = 0;
global.creations_allowed = 0;

instance_create_layer(x, y, "Instances", o_input);
instance_create_layer(x, y, "Instances", o_menu);
instance_create_layer(x, y, "Instances", camera);
instance_create_layer(x, y, "Instances", o_bg_parallax);

end_min_ = 0;
end_secs_ = 0;
end_score_ = 0;

