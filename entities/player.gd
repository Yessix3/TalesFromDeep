extends CharacterBody2D

@export_group('move')
@export var speed: int = 200
@export var acceleration: int = 800
@export var friction: int = 900
var direction := Vector2.ZERO
var can_move := true



@export_group('jump')
@export var jump_height: int = 300
@export var gravity := 600
@export var terminal_velocity := 500
@export var wall_cling_velocity := 20
var jump := false
var short_jump := false

func _process(delta):
	apply_gravity(delta)
	if can_move:
		get_input()
		apply_movement(delta)
		

func get_input():
	#horizontal movement
	direction.x = Input.get_axis("left", "right")
	
	#jump input
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or $Timers/jump_delay.time_left:
			jump = true
		if velocity.y > 0 and not is_on_floor():
			$Timers/jump_buffer.start()
	if Input.is_action_just_released("jump") and not is_on_floor() and velocity.y < 0:
		short_jump = true
		

func apply_movement(delta):
	#left right with acceleration
	if direction.x:
		velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
	else: 
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	
	#jumping
	if jump or $Timers/jump_buffer.time_left and (is_on_floor() or is_on_wall()):
		velocity.y = -jump_height
		if is_on_wall():
			velocity.x = direction.x / -2 * jump_height
		jump = false
		short_jump = false
	
	
	
	#delayed jump check
	var on_floor = is_on_floor()
	move_and_slide()
	if on_floor and not is_on_floor() and velocity.y >= 0:
		$Timers/jump_delay.start()
	
func apply_gravity(delta):
	velocity.y += gravity*delta
	if short_jump and velocity.y < 0:
		velocity.y = velocity.y/2
		short_jump = false
	if is_on_wall_only():
		velocity.y = min(velocity.y, wall_cling_velocity)
	else:
		velocity.y = min(velocity.y, terminal_velocity)
	
	





#const SPEED = 300.0
#const JUMP_VELOCITY = -400.0
#
#
#func _physics_process(delta: float) -> void:
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
#
	#move_and_slide()
