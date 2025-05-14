extends CharacterBody2D

@export var walk_speed = 150.0
@export var run_speed = 250.0
@export_range(0, 1) var acceleration = 0.1
@export_range(0, 1) var deceleration = 0.1

@export var animated_sprite : AnimatedSprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Tambahkan gravitasi agar tetap jatuh saat di udara
	if not is_on_floor():
		velocity.y += gravity * delta

	# Tentukan kecepatan: jalan atau lari
	var speed = walk_speed
	if Input.is_action_pressed("run"):
		speed = run_speed

	# Arah gerak dari input kiri dan kanan
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * speed, speed * acceleration)
		animated_sprite.flip_h = direction == -1
		if is_on_floor():
			if Input.is_action_pressed("run"):
				animated_sprite.play("Run")
			else:
				animated_sprite.play("Walk")
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed * deceleration)
		if is_on_floor():
			animated_sprite.play("Idle")

	move_and_slide()
