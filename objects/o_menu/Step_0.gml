if !global.pause exit;

input_up = keyboard_check_pressed(global.up_key) || gamepad_button_check_pressed(0, gp_padu);
input_down = keyboard_check_pressed(global.down_key) || gamepad_button_check_pressed(0, gp_padd);
input_select = keyboard_check_pressed(global.select_key) || gamepad_button_check_pressed(0, global.select_pad);
input_right =  keyboard_check_pressed(global.right_key) || gamepad_button_check_pressed(0, gp_padr);
input_left = keyboard_check_pressed(global.left_key) || gamepad_button_check_pressed(0, gp_padl);

var ds_grid = menu_pages[page], ds_height = ds_grid_height(ds_grid);

if inputting {
	
		switch(ds_grid[# 1, menu_option[page]]) { 
			case menu_element_type.shift:
				var hinput = input_right - input_left;
				if hinput != 0 {
					// audio
					ds_grid[# 3, menu_option[page]] += hinput;
					ds_grid[# 3, menu_option[page]] = clamp(ds_grid[# 3, menu_option[page]], 0, array_length_1d(ds_grid[# 4, menu_option[page]])-1);
				}
				
			break;
			case menu_element_type.slider:
			switch (menu_option[page]) {
				case 0: if (!audio_is_playing(mas_test)) { audio_play_sound(mas_test, 1, false) }; break;
				case 1: if (!audio_is_playing(snd_test)) { audio_play_sound(snd_test, 1, false) }; break;
				case 2: if (!audio_is_playing(msc_test)) { audio_play_sound(msc_test, 1, false) }; break;
			}
			
			
			
			
				var hinput = (keyboard_check(global.right_key) || gamepad_button_check(0, gp_padr)) - (keyboard_check(global.left_key) || gamepad_button_check(0, gp_padl));
				if hinput != 0 {
					// intermittent audio 
					ds_grid[# 3, menu_option[page]] += hinput*0.01;
					ds_grid[# 3, menu_option[page]] = clamp(ds_grid[# 3, menu_option[page]], 0, 1);
					script_execute(ds_grid[# 2, menu_option[page]], ds_grid[# 3, menu_option[page]]);
				}
				
			break;
			case menu_element_type.toggle:  
				var hinput = input_right - input_left;
				if hinput != 0 {
					// audio
					ds_grid[# 3, menu_option[page]] += hinput;
					ds_grid[# 3, menu_option[page]] = clamp(ds_grid[# 3, menu_option[page]], 0, 1);
				}
				
			break;
			case menu_element_type.input: 
				var kk = keyboard_lastkey;
				if kk != vk_enter {
					if (kk != ds_grid[# 3, menu_option[page]]) // audio
					ds_grid[# 3, menu_option[page]] = kk;
					variable_global_set(ds_grid[# 2, menu_option[page]], kk);
				}
				
				break;
	}

} else {
	var o_change = input_down - input_up;
	if o_change != 0 {
		menu_option[page] += o_change;
		if menu_option[page] > (ds_height-1) { menu_option[page] = 0; }
		if menu_option[page] < 0 { menu_option[page] = ds_height - 1; }
		// audio
	}
}

if input_select {
	switch(ds_grid[# 1, menu_option[page]]) { 
		case menu_element_type.script_runner: script_execute(ds_grid[# 2, menu_option[page]]); break;
		case menu_element_type.page_transfer: page = ds_grid[# 2, menu_option[page]]; break;
		case menu_element_type.shift: 
		case menu_element_type.slider: 
		case menu_element_type.toggle: if inputting { script_execute(ds_grid[# 2, menu_option[page]], ds_grid[# 3, menu_option[page]]);}
		case menu_element_type.input: 
			inputting = !inputting;
			break;
		
	}
	audio_play_sound(snd_test, 1, false);
	
}


