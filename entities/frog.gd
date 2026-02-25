extends CharacterBody2D

const SPEED = 45
const GRAVITY = 900
const KNOCKBACK_FORCE = -30
const ATTACK_RANGE = 35
const ATTACK_DURATION = 0.6
const ATTACK_COOLDOWN = 1.0

var health = 60
var health_min = 0

var dead = false
var taking_damage = false
var is_dealing_damage = false
var player_in_area = false
var can_attack = true

var dir: Vector2 = Vector2.LEFT

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player") as CharacterBody2D
@onready var player_hitbox: Area2D = player.get_node("AttackHitbox")


# =============================
# PHYSICS
# =============================
func _physics_process(delta):

	if !is_on_floor():
		velocity.y += GRAVITY * delta

	move()
	move_and_slide()
	handle_animation()

	check_attack()


# =============================
# MOVEMENT
# =============================
func move():

	if dead:
		velocity.x = 0
		return

	if taking_damage:
		var knockback_dir = position.direction_to(player.position)
		velocity.x = knockback_dir.x * KNOCKBACK_FORCE
		return

	if is_dealing_damage:
		velocity.x = 0
		return

	if player:
		var dir_to_player = position.direction_to(player.position)
		velocity.x = dir_to_player.x * SPEED

		if velocity.x != 0:
			dir.x = sign(velocity.x)


# =============================
# ATTACK CHECK
# =============================
func check_attack():

	if !player:
		return

	if dead or taking_damage:
		return

	if player_in_area and can_attack:
		if position.distance_to(player.position) <= ATTACK_RANGE:
			start_attack()


func start_attack():
	if is_dealing_damage or dead or taking_damage:
		return

	is_dealing_damage = true
	can_attack = false

	# Animation starten
	anim_sprite.play("attack")

	# Warten bis Animation fertig ist
	while anim_sprite.is_playing():
		await get_tree().process_frame

	is_dealing_damage = false

	# Cooldown
	await get_tree().create_timer(ATTACK_COOLDOWN).timeout
	can_attack = true


# =============================
# ANIMATION
# =============================
func handle_animation():

	if dead:
		if anim_sprite.animation != "death":
			anim_sprite.play("death")
			print("Frog died.")
		return

	if taking_damage:
		if anim_sprite.animation != "hurt":
			anim_sprite.play("hurt")
			print("Frog HP: ", health)
		return

	if is_dealing_damage:
		if anim_sprite.animation != "attack":
			anim_sprite.play("attack")
		return

	if anim_sprite.animation != "jump":
		anim_sprite.play("jump")

	anim_sprite.flip_h = velocity.x < 0


# =============================
# DAMAGE
# =============================
func take_damage(damage):

	if dead:
		return

	health -= damage
	taking_damage = true

	if health <= health_min:
		health = health_min
		die()
	else:
		await get_tree().create_timer(0.4).timeout
		taking_damage = false


func die():
	dead = true
	await get_tree().create_timer(1.0).timeout
	queue_free()


# =============================
# SIGNALS
# =============================
func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player_in_area = true


func _on_detection_area_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = false


func _on_frog_hitbox_area_entered(area):
	var damage = 10
	if area == player_hitbox:
		take_damage(damage)
