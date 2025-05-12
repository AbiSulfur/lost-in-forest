extends CharacterBody2D

const SPEED = 100

func _physics_process(delta):
	var direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * SPEED
	move_and_slide()

	# Membalik arah karakter saat ke kiri
	if direction != 0:
		$Sprite2D.flip_h = direction < 0
