// Foreground
layer_x(fore_clouds_id, lerp(0, camera_get_view_x(view_camera[0]), 0.7));

// Midground
layer_x(mid_id, lerp(0, camera_get_view_x(view_camera[0]), 0.8));
layer_x(mid_silhoette, lerp(0, camera_get_view_x(view_camera[0]), 0.8));

// Background
layer_x(back_clouds_id, lerp(0, camera_get_view_x(view_camera[0]), 0.9));
layer_x(back_sky_id, lerp(0, camera_get_view_x(view_camera[0]), 1));


