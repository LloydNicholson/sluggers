/// @desc Enemy setup
depth = -50;

// Movement
move_speed_ = 2;
hspeed_ = move_speed_;
vspeed_ = 0;
gravity_ = 0.6;

// Health
health_ = 2;
max_health_ = 2;
invincible_frames_ = 0;

// AI - player detection
angry_ = false;
detect_range_ = 220;
chase_speed_ = 3.5;

// Animation
bob_timer_ = random(100);
blink_timer_ = irandom_range(60, 300);
blink_ = 0;

// Eye animation offset (for drawing)
eye_offset_y_ = 0;
