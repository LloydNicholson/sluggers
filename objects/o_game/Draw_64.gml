/// @desc Draw UI
draw_set_font(f_game);
draw_set_halign(fa_left);
draw_set_valign(fa_bottom);

#region Draw fade
var g_width = camera.view_w, g_height = camera.view_h;
var c = c_black, black_alpha = 0;

draw_set_alpha(black_alpha);
draw_rectangle_color(0, 0, g_width, g_height, c,c,c,c, false); 
draw_set_alpha(1);

#endregion

#region Game Timer and Diamond collection
	if global.secs < 10 {
		draw_text(10, g_height, "Time: " + string(global.minutes) + ":0" + string(global.secs));	
	} else if global.secs >= 10 {
		draw_text(10, g_height, "Time: "+ string(global.minutes) + ":" + string(global.secs));	
	} else if global.secs < 10 && global.minutes >= 10 {
		draw_text(10, g_height, "Time: "+ "0"+ string(global.minutes) + ":0" + string(global.secs));	
	} else if global.secs >= 10 && global.minutes < 10 {
		draw_text(10, g_height, "Time: "+ "0" + string(global.minutes) + ":" + string(global.secs));	
	}

	var _diamond_string = string(global.diamonds);
	var _text_width = string_width(_diamond_string);
	var _x = g_width - _text_width+4;
	var _y = g_height - 16;
	draw_sprite(s_diamond, 0, _x-30, _y-15);
	draw_text(_x-15, _y, _diamond_string);

#endregion 

#region Creations remaining
	var _creations_string = "Creations remaining: " + string(global.creations_allowed);
	var _text_width = string_width(_creations_string);
	var _x = g_width - _text_width+4;
	var _y = 64;
	draw_text(_x-15, _y, _creations_string);

#endregion

//#region Game End Screen

//	if end_score_ >= 25 {
//		draw_text(100, 130, "Amazing! \nThat's a lot of diamonds!");	
//	} else {
//		draw_text(100, 130, "Not too bad! \nYou need more diamonds next time.");	
//	}
	
//	if end_min_ == 1 && end_secs_ <= 30 {
//		draw_text(100, 190, "That was fast. Well done!");	
//	} else if end_min_ >= 1 && end_secs_ > 30 {
//		draw_text(100, 190, "That's alright. \nYou need more speed!");	
//	}
	
//	draw_text(100, 250, "Total diamonds collected: " + string(end_score_));
//	draw_text(100,280, "Time taken: " + string(end_min_) + ":" + string(end_secs_));

//#endregion