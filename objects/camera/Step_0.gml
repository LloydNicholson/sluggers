if !instance_exists(o_player) exit;

camera_set_view_size(view_camera[0], view_w, view_h);
camera_set_view_pos(view_camera[0], x, y);

x = lerp(x, o_player.x-view_h/2, 0.1);
y = lerp(y, o_player.y, 0.1);