extends CharacterBody2D

# --- Variabel dan Konstanta ---
const SPEED = 100
const RUN_MULTIPLIER = 1.5
const JUMP_FORCE = -300
const GRAVITY = 800
const ATTACK_COOLDOWN = 0.4
const THROW_COOLDOWN = 1.0
const SWORD_DAMAGE = 5
const THROW_DAMAGE = 10

var is_attacking = false
var can_attack = true
var can_throw = true
var is_jumping = false
var is_dead = false

# --- Fungsi Utama ---
func _physics_process(delta):
	if is_dead:
		return

	handle_movement(delta)
	handle_jump()
	handle_attack()
	handle_animation()
	move_and_slide()

# --- Fungsi Gerak ---
func handle_movement(delta):
	var dir = 0
	if Input.is_action_pressed("move_left"):
		dir -= 1
	if Input.is_action_pressed("move_right"):
		dir += 1

	var speed = SPEED
	if Input.is_action_pressed("run"):
		speed *= RUN_MULTIPLIER

	velocity.x = dir * speed

	if dir != 0:
		$AnimatedSprite2D.flip_h = dir < 0

	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		is_jumping = false

# --- Fungsi Lompat ---
func handle_jump():
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_FORCE
		is_jumping = true
		$AnimatedSprite2D.play("jump")

# --- Fungsi Serangan ---
func handle_attack():
	if Input.is_action_just_pressed("attack_sword") and can_attack:
		sword_attack()
	elif Input.is_action_just_pressed("attack_throw") and can_throw:
		throw_object()

func sword_attack():
	is_attacking = true
	can_attack = false

	if not is_on_floor():
		$AnimatedSprite2D.play("air_attack")
	elif abs(velocity.x) > SPEED:
		$AnimatedSprite2D.play("run_attack")
	else:
		$AnimatedSprite2D.play("attack_sword")

	await get_tree().create_timer(ATTACK_COOLDOWN).timeout
	is_attacking = false
	can_attack = true


func throw_object():
	is_attacking = true
	can_throw = false

	if not is_on_floor():
		$AnimatedSprite2D.play("air_throw")
	elif abs(velocity.x) > SPEED:
		$AnimatedSprite2D.play("run_throw")
	else:
		$AnimatedSprite2D.play("throw")

	await get_tree().create_timer(THROW_COOLDOWN).timeout
	is_attacking = false
	can_throw = true


# --- Fungsi Animasi Otomatis ---
func handle_animation():
	if is_dead:
		$AnimatedSprite2D.play("death")
	elif is_attacking:
		pass
	elif not is_on_floor():
		if velocity.y < 0:
			$AnimatedSprite2D.play("jump")
		else:
			$AnimatedSprite2D.play("fall")
	elif velocity.x != 0:
		$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("idle")

# --- Fungsi Damage dan Mati ---
func take_damage(amount):
	if is_dead:
		return
	$AnimatedSprite2D.play("hit")
	# kurangi nyawa di sini

	is_dead = true
	velocity = Vector2.ZERO
	$AnimatedSprite2D.play("death")
