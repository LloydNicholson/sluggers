var right_key = keyboard_check(global.right_key);
var left_key = keyboard_check(global.left_key);
var right_axis = gamepad_axis_value(0, gp_axislh) > 0;
var left_axis = gamepad_axis_value(0, gp_axislh) < 0;

var hinput = (right_key || right_axis) - (left_key || left_axis);

// Reduced acceleration in air for more deliberate platforming feel
var _accel = (state == GROUND) ? acceleration_ : acceleration_ * 0.55;

hspeed_ += hinput * _accel;
hspeed_ = clamp(hspeed_, -max_speed_, max_speed_);

