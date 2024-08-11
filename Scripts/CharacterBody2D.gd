extends CharacterBody2D


@export var SPEED := 350.0
@export var sprint_mult := 1.5

@export var jump_height : int = 230
@export var jump_time_to_peak : float = 0.6
@export var jump_time_to_descent : float = 0.43

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak ** 2)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent ** 2)) * -1.0
var jump_available : bool = true
var jump_queued : bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	#velocity.y += get_gravity() * delta
	var newVelocity = velocity.y + (get_gravity_speed() * delta)
	velocity.y = lerp(velocity.y, newVelocity, 0.8)
	
	handle_movement()
	handle_jumping()
		
	move_and_slide()

func handle_movement():
	var direction = Input.get_axis("Left", "Right")
	if direction:
		velocity.x = direction * SPEED
		if Input.is_action_pressed("Sprint"):
			velocity.x *= sprint_mult
	# Slows down when not pushing button. Including while jumping, so be careful
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0, SPEED / 5)
	else: #FIXME: maybe?
		velocity.x = move_toward(velocity.x, 0, SPEED / 30)



func handle_jumping():
	# Coyote time and jump buffer
	if not is_on_floor():
		if jump_available:										   # Coyote time check
			get_tree().create_timer(0.1).timeout.connect(coyote_timeout)
	else:
		jump_available = true
		if jump_queued:											   # Jump if one in queue
			jump()

	if Input.is_action_just_pressed("Jump"):
		if jump_available:										   # Regular jump
			jump()
		else:													   # Queue a jump into buffer
			jump_queued = true
			get_tree().create_timer(0.1).timeout.connect(jump_buffer)
	elif Input.is_action_just_released("Jump") and velocity.y < 0: # Variable height on button release
		velocity.y *= 0.4

func jump():
	#velocity.y = jump_velocity
	velocity.y = lerp(velocity.y, jump_velocity, 0.8)
	jump_available = false

func get_gravity_speed():
	return jump_gravity if velocity.y < 0.0 else fall_gravity

func coyote_timeout():
	# This needs it's own function because they removed the fucking yeild method
	jump_available = false

func jump_buffer():
	jump_queued = false
