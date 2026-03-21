/// @desc Draw UI
draw_set_font(f_game);
draw_set_halign(fa_left);
draw_set_valign(fa_bottom);

var g_width = camera.view_w, g_height = camera.view_h;

#region Health display (top-left)
var _player = instance_find(o_player, 0);
if instance_exists(_player) {
	var _hp = _player.health_;
	var _max_hp = _player.max_health_;
	var _heart_w = 18;
	var _heart_h = 14;
	var _heart_gap = 4;
	var _hx = 12;
	var _hy = 12;

	for (var i = 0; i < _max_hp; i++) {
		var _cx = _hx + i * (_heart_w + _heart_gap);

		// Shadow
		draw_set_color(c_black);
		draw_rectangle(_cx + 1, _hy + 1, _cx + _heart_w + 1, _hy + _heart_h + 1, false);

		// Fill (red = full, dark = empty)
		if i < _hp {
			if _player.invincible_ > 0 && _player.invincible_ mod 6 < 3 {
				draw_set_color(c_red);
			} else {
				draw_set_color(make_color_rgb(220, 50, 50));
			}
		} else {
			draw_set_color(make_color_rgb(60, 20, 20));
		}
		draw_rectangle(_cx, _hy, _cx + _heart_w, _hy + _heart_h, false);

		// Highlight (top-left corner shine)
		draw_set_color(make_color_rgb(255, 120, 120));
		draw_rectangle(_cx + 2, _hy + 2, _cx + _heart_w - 4, _hy + 4, false);
	}
	draw_set_color(c_white);

	// "DEAD" overlay text
	if _player.dead_ {
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_color(c_red);
		draw_text(g_width * 0.5, g_height * 0.5, "RESPAWNING...");
		draw_set_color(c_white);
		draw_set_halign(fa_left);
		draw_set_valign(fa_bottom);
	}
}
#endregion

#region Game Timer (bottom-left)
var _mins = floor(global.secs / 60) + global.minutes;
var _secs = floor(global.secs) mod 60;
var _time_str = "Time: " + string(_mins) + ":" + (_secs < 10 ? "0" : "") + string(_secs);
draw_set_color(c_black);
draw_text(11, g_height + 1, _time_str);
draw_set_color(c_white);
draw_text(10, g_height, _time_str);
#endregion

#region Diamond count (bottom-right)
var _diamond_string = string(global.diamonds);
var _text_width = string_width(_diamond_string);
var _dx = g_width - _text_width - 36;
var _dy = g_height - 4;
draw_sprite(s_diamond, 0, _dx, _dy - 20);
draw_set_color(c_black);
draw_text(_dx + 22, _dy + 1, _diamond_string);
draw_set_color(c_white);
draw_text(_dx + 22, _dy, _diamond_string);

if global.diamond_combo > 1 && global.diamond_combo_timer > 0 {
	draw_set_halign(fa_right);
	draw_set_color(c_black);
	draw_text(g_width - 10, g_height - 26, "x" + string(global.diamond_combo) + " COMBO!");
	draw_set_color(make_color_rgb(255, 230, 90));
	draw_text(g_width - 11, g_height - 27, "x" + string(global.diamond_combo) + " COMBO!");
	draw_set_color(c_white);
	draw_set_halign(fa_left);
}
#endregion

#region Level name (top-right)
var _level_name = "";
switch (room) {
	case rm_0: _level_name = "Level 1"; break;
	case rm_1: _level_name = "Level 2"; break;
	case rm_2: _level_name = "Level 3"; break;
	case rm_3: _level_name = "Level 4"; break;
	case rm_4: _level_name = "Level 5"; break;
}
if _level_name != "" {
	draw_set_halign(fa_right);
	draw_set_color(c_black);
	draw_text(g_width - 9, 21, _level_name);
	draw_set_color(make_color_rgb(255, 220, 100));
	draw_text(g_width - 10, 20, _level_name);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
}
#endregion
