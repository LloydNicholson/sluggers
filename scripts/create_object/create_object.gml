if (distance_to_object(o_solid) > sprite_height) {
	if (instance_number(o_solid_creation) + (instance_number(o_bouncy_creation))  < global.creations_allowed) {
		if keyboard_check_pressed(global.z_key) {
			instance_create_layer(x+hspeed_, y+1, "Instances", o_solid_creation);
		}
		
		if keyboard_check_pressed(global.x_key) {
			instance_create_layer(x+hspeed_, y+1, "Instances", o_bouncy_creation);	
		}
		
		if keyboard_check_pressed(global.c_key) {
			//instance_create_layer(x+hspeed_, y+1, "Instances", o_solid_creation);	
		}
	}	
}

