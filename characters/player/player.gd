class_name Player
extends CharacterBody2D


const ACCEL = 0.15
const JUMP_ACCEL = 0.1
const FRICTION = 0.25

@export var speed: float = 200.0

@export_group("Jump", "jump")
@export var jump_height: float = 36.0
@export var jump_time_to_peak: float = 0.25
@export var jump_time_to_descent: float = 0.2

@export_group("Glide", "glide")
@export var glide_time_to_descent: float = 0.5
@export var glide_terminal_velocity: float = 128.0

@export_group("Fall", "fall")
@export var fall_terminal_velocity: float = 256.0

var dir: int = 0
var on_ground: bool = false
var gravity_scale: float = 1.0
var state_machine: StateMachine = StateMachine.new()
var has_flower: bool = false
var can_move: bool = true

@onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0
@onready var glide_gravity: float = ((-2.0 * jump_height) / (glide_time_to_descent * glide_time_to_descent)) * -1.0

@onready var coyote_time: Timer = $CoyoteTime
@onready var jump_buffer: Timer = $JumpBuffer
@onready var sprite: Sprite2D = $Sprite
@onready var flower: Sprite2D = $Sprite/Flower
@onready var animator: AnimationPlayer = $Animator
@onready var wind_detector: Area2D = $WindDetector
@onready var glide_sfx: AudioStreamPlayer = $GlideSFX


func _ready() -> void:
	state_machine.add_state(_idle_state)
	state_machine.add_state(_run_state)
	state_machine.add_state(_jump_state)
	state_machine.add_state(_fall_state)
	state_machine.add_state(_glide_state)
	state_machine.set_initial_state(_idle_state)


func _physics_process(delta: float) -> void:
	flower.visible = has_flower
	gravity_scale = 1.0
	state_machine.update(delta)

	if wind_detector.has_overlapping_areas():
		var wind = wind_detector.get_overlapping_areas().front()
		if is_instance_valid(wind) and not wind.only_gliding:
			gravity_scale = wind.gravity_scale
			if wind.direction != Vector2i.UP:
				velocity += wind.direction * wind.push

	glide_sfx.volume_db = lerp(glide_sfx.volume_db, -10.0 if state_machine.current_state == _glide_state else -50.0, 8.0 * delta)

	dir = _get_dir()
	if is_on_floor():
		coyote_time.start()

	if dir != 0:
		sprite.scale.x = -1 if dir < 0 else 1
	on_ground = !coyote_time.is_stopped()

	if not is_on_floor():
		velocity.y += _get_gravity() * delta
		velocity.y = minf(velocity.y, _get_terminal_velocity())

	if Input.is_action_just_pressed("jump") and velocity.y >= 0:
		jump_buffer.start()
	elif Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5

	if !jump_buffer.is_stopped() and on_ground:
		_jump()

	_move()
	move_and_slide()


func _idle_state(delta: float) -> void:
	animator.play("idle")
	if is_on_floor():
		if dir != 0:
			state_machine.set_state(_run_state)
	else:
		if velocity.y < 0.0:
			state_machine.set_state(_jump_state)
		else:
			state_machine.set_state(_fall_state)


func _run_state(delta: float) -> void:
	animator.play("run")
	if is_on_floor():
		if dir == 0:
			state_machine.set_state(_idle_state)
	else:
		if velocity.y < 0.0:
			state_machine.set_state(_jump_state)
		else:
			state_machine.set_state(_fall_state)


func _jump_state(delta: float) -> void:
	animator.play("jump")
	if is_on_floor():
		state_machine.set_state(_idle_state)
	else:
		if velocity.y > 0.0:
			state_machine.set_state(_fall_state)


func _fall_state(delta: float) -> void:
	animator.play("fall")
	if is_on_floor():
		state_machine.set_state(_idle_state)
	else:
		if Input.is_action_pressed("glide"):
			state_machine.set_state(_glide_state)
		if velocity.y < 0.0:
			state_machine.set_state(_jump_state)


func _glide_state(delta: float) -> void:
	animator.play("glide")
	if wind_detector.has_overlapping_areas():
		var wind = wind_detector.get_overlapping_areas().front()
		if is_instance_valid(wind) and wind.only_gliding:
			gravity_scale = wind.gravity_scale
			if wind.direction != Vector2i.UP:
				velocity += wind.direction * wind.push

	print(velocity.y)
	if is_on_floor():
		state_machine.set_state(_idle_state)
	else:
		if not Input.is_action_pressed("glide"):
			state_machine.set_state(_fall_state)


func _get_terminal_velocity() -> float:
	if is_gliding():
		return glide_terminal_velocity
	else:
		return fall_terminal_velocity


func _get_gravity() -> float:
	if wind_detector.has_overlapping_areas() and is_gliding():
		return fall_gravity * randf_range(0.9, 1.05) * gravity_scale
	return (jump_gravity if velocity.y < 0.0 else (fall_gravity if not Input.is_action_pressed("glide") else glide_gravity)) * gravity_scale


func _get_dir() -> float:
	if not can_move:
		return 0
	return Input.get_axis("move_left", "move_right")


func _move(accel: float = ACCEL, friction: float = FRICTION) -> void:
	velocity.x = lerp(velocity.x, dir * speed, accel if dir != 0 else friction)


func _jump() -> void:
	jump_buffer.stop()
	coyote_time.stop()
	velocity.y = jump_velocity
	$JumpSFX.play()


func is_gliding() -> bool:
	return animator.current_animation == "glide"
