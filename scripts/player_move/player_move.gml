var right_key = keyboard_check(global.right_key);
var left_key = keyboard_check(global.left_key);
var right_axis = gamepad_axis_value(0, gp_axislh) > 0;
var left_axis = gamepad_axis_value(0, gp_axislh) < 0;


var hinput = (right_key || right_axis) - (left_key || left_axis);

hspeed_ += hinput*acceleration_;
hspeed_ = clamp(hspeed_+hinput, -max_speed_, max_speed_);


 

