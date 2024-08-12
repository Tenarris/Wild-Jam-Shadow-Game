extends Camera2D

@export var player : CharacterBody2D
var player_velocity : Vector2 = Vector2.ZERO

# Glance mechanic
var held_button : bool = false
@export var glance_dist : float = 300.0

# Camera movement speed and default screen boundries in pixels
const camera_upper_limit : int = -96
const camera_bottom_limit : int = 1920
const camera_left_limit : int = 0
const camera_right_limit: int = 10000000



func _process(delta):
	player_velocity = player.velocity
	camera_movement(delta)
	glance(delta)



func camera_movement(delta):
	var char_screen_region = get_viewport().size * 0.1
	var target_offset = player_velocity.normalized() * char_screen_region
	
	if player_velocity.length() > 0:
		offset = lerp(offset, target_offset, 0.8 * delta)
	elif not held_button:
		offset = lerp(offset, Vector2.ZERO, 0.3 * delta)

func glance(delta):
	var look_up = Input.is_action_pressed("Up")
	var look_down = Input.is_action_pressed("Down")
	
	if player.is_on_floor() and player_velocity.length() == 0:
		if (look_up or look_down) and held_button:
			if look_up:
				offset.y = lerp(offset.y, -glance_dist, 5.0 * delta)
			elif look_down:
				offset.y = lerp(offset.y, glance_dist, 5.0 * delta)
		elif look_up or look_down:
			get_tree().create_timer(0.5).timeout.connect(glance_trigger)
		else:
			held_button = false
			offset.y = lerp(offset.y, 0.0, 5.0 * delta)
	else:
		held_button = false
		offset.y = lerp(offset.y, 0.0, 5.0 * delta)

func glance_trigger():
	held_button = true

func update_screen_borders(left_limit: int = camera_upper_limit,
							top_limit: int = camera_upper_limit,
							right_limit: int = camera_right_limit,
							bottom_limit: int = camera_bottom_limit):
	limit_left = left_limit
	limit_top = top_limit
	limit_right = right_limit
	limit_bottom = bottom_limit
