/// @desc Enemy draw with health bar and anger indicator

// Draw the enemy sprite
draw_self();

// Draw anger indicator (exclamation mark when chasing)
if angry_ && invincible_frames_ <= 0 {
	draw_set_font(-1);
	draw_set_color(c_red);
	draw_set_halign(fa_center);
	draw_set_valign(fa_bottom);
	var _indicator_y = y - sprite_height - 2;
	draw_text(x, _indicator_y, "!");
}

// Draw health bar (always visible)
var _bar_w = sprite_width * 0.85;
var _bar_h = 4;
var _bar_x = x - _bar_w * 0.5;
var _bar_y = y - sprite_height - (angry_ ? 16 : 10);

// Background outline
draw_set_color(c_black);
draw_rectangle(_bar_x - 1, _bar_y - 1, _bar_x + _bar_w + 1, _bar_y + _bar_h + 1, false);

// Empty health (dark red)
draw_set_color(make_color_rgb(80, 10, 10));
draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + _bar_h, false);

// Current health fill
var _fill = _bar_w * (health_ / max_health_);
draw_set_color(angry_ ? c_red : make_color_rgb(60, 210, 60));
draw_rectangle(_bar_x, _bar_y, _bar_x + _fill, _bar_y + _bar_h, false);

// Reset draw state
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
