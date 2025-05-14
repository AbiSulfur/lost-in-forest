extends CharacterBody2D
 
@export var walk_speed = 150.0
@export var run_speed = 250.0
@export_range(0, 1) var acceleration = 0.1
@export_range(0, 1) var deceleration = 0.1
 
@export var dash_speed = 1000.0
@export var dash_max_distance = 300.0
@export var dash_curve : Curve
@export var dash_cooldown = 1.0
 
@export var animated_sprite : AnimatedSprite2D
 
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
 
var is_dashing = false
var dash_start_position = 0
var dash_direction = 0
var dash_timer = 0

var is_attacking = false

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
 
	var speed
	if Input.is_action_pressed("run"):
		speed = run_speed
	else:
		speed = walk_speed

	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, speed * acceleration)
		animated_sprite.flip_h = direction == -1
		if is_on_floor() and not is_attacking:
			if Input.is_action_pressed("run"):
				animated_sprite.play("RunSword")
			else:
				animated_sprite.play("WalkSword")
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed * deceleration)
		if is_on_floor() and not is_attacking:
			animated_sprite.play("IdleSword")

	# ⛔ Lompat telah dihapus ⛔

	# Dash
	if Input.is_action_just_pressed("dash") and direction and not is_dashing and dash_timer <= 0:
		is_dashing = true
		dash_start_position = position.x
		dash_direction = direction
		dash_timer = dash_cooldown

	if is_dashing:
		var current_distance = abs(position.x - dash_start_position)
		if current_distance >= dash_max_distance or is_on_wall():
			is_dashing = false
		else:
			velocity.x = dash_direction * dash_speed * dash_curve.sample(current_distance / dash_max_distance)
			velocity.y = 0

	if dash_timer > 0:
		dash_timer -= delta

	# ✅ Serangan
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()

	move_and_slide()

func attack():
	is_attacking = true
	animated_sprite.play("AttackSword")

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "AttackSword":
		is_attacking = false
