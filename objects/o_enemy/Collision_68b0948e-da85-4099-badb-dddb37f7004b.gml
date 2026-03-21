/// @desc Enemy touches player - deal damage
var _enemy_x = x;
var _enemy_y = y;
with (other) {
	player_take_damage(_enemy_x, _enemy_y);
}
