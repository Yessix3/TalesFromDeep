extends CharacterBody2D

@export var friction := 800
@export var gravity := 400

###################################
@export var player_path: NodePath
@export var entities_path: NodePath

@onready var player: Node2D = get_node(player_path) as Node2D
@onready var entities: Node = get_node(entities_path)
#########################################
#@onready var player := get_tree().get_root().get_node("Level").get_node("Main").get_node("Entities").get_node("Player")
@onready var animated_sprite = $AnimatedSprite2D
@onready var spear = load("res://entities/ahab_spear.tscn")
@onready var arm = load("res://entities/ahab_arm.tscn")
#@onready var entities := get_tree().get_root().get_node("Level").get_node("Main").get_node("Entities")


signal enemy_hit(damage: int)
signal health_change(value: int)
#############################
signal enemy_died()

var boss_health_boost: int = 1
var boss_damage_boost: int = 1
var player_damage_boost: int = 1

func apply_battle_config(cfg: BattleConfig) -> void:

	boss_health_boost = cfg.enemy_health_boost
	print("[Boss] health boost:", boss_health_boost)
	boss_damage_boost = cfg.enemy_damage_boost
	print("[Boss] damage boost:", boss_health_boost)
	player_damage_boost = cfg.player_damage_boost
	print("[Boss] player damage boost:", boss_health_boost)


	max_health = int(max_health * ((100.0 + boss_health_boost)/100.0))


###########################################


@export var max_health = 50
@onready var current_health = max_health
@export var phase_change_health = 25

var face_right = false
var is_attacking = false
var terminal_velocity = 600
var current_decision := "idle"
var last_decision := "wait"
@export var phase := 1

func _ready():
	print(player)
	

func _process(delta):
	apply_gravity(delta)
	apply_friction(delta)
	if current_decision == "idle":
		face_player()
		if phase == 1:
			make_decisionP1()
		else:
			make_decisionP2()
		attack(current_decision)
	move_and_slide()
	
	

func apply_gravity(delta):
	velocity.y += gravity*delta
	velocity.y = min(velocity.y, terminal_velocity)

func apply_friction(delta):
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, friction * delta)

func face_player():
	if player.global_position.x > global_position.x:
		face_right = true
	else:
		face_right = false
	print(face_right)
	animated_sprite.flip_h = not face_right


func make_decisionP1():
	current_decision = "acting"
	var random = randf()
	if phase==1 and current_health <= phase_change_health:
		change_phase()
	else:
		if player.global_position.y < global_position.y-60:
			if last_decision == "roar":
				last_decision = "ground_poke"
				current_decision = "ground_poke"
			else: 
				if random < 0.2:
					last_decision = "ground_poke"
					current_decision = "ground_poke"
				else:
					if abs(player.global_position.x - global_position.x) < 120:
						last_decision = "roar"
						current_decision = "roar"
					else:
						last_decision = "dash"
						current_decision = "dash"
		else:
			if abs(player.global_position.x - global_position.x) < 130:
				if random < 0.3 or last_decision == "dash":
					last_decision = "melee"
					current_decision = "melee"
				else:
					last_decision = "dash"
					current_decision = "dash" 
			else:
				last_decision = "dash"
				current_decision = "dash" 


func make_decisionP2():
	current_decision = "acting"
	var random = randf()
	if player.global_position.y < global_position.y-60:
		last_decision = "dragoon"
		current_decision = "dragoon"
	else:
		if random < 0.5:
			last_decision = "leap"
			current_decision = "leap"
		else:
			last_decision = "throw"
			current_decision = "throw"



func change_phase():
	animated_sprite.play("Change_Phase")



func attack(move):
	print(move)
	if move == "dash":
		dashP1()
	if move == "melee":
		meleeP1()
	if move == "ground_poke":
		ground_pokeP1()
	if move == "roar":
		roarP1()
	if move == "dragoon":
		dragoonP2()
	if move == "leap":
		leapP2()
	if move == "throw":
		throwP2()







func dashP1():
	animated_sprite.play("Dash_Windup")

func meleeP1():
	animated_sprite.play("Melee_Windup")

func ground_pokeP1():
	animated_sprite.play("Ground_Poke_Windup")

func roarP1():
	animated_sprite.play("Roar_Windup")

func dragoonP2():
	animated_sprite.play("Dragoon_Windup")

func leapP2():
	animated_sprite.play("Leap_Windup")

func throwP2():
	animated_sprite.play("Throw_Windup")






func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "Change_Phase":
		phase = 2
		print("works")
		current_decision = "idle"
	
	if animated_sprite.animation == "Dash_Recovery":
		animated_sprite.play("Idle_P1")
		current_decision = "idle"
	if animated_sprite.animation == "Dash_Attack":
		animated_sprite.play("Dash_Recovery")
		$AttackP1Dash/AttackRight.disabled = true
		$AttackP1Dash/AttackLeft.disabled = true
	if animated_sprite.animation == "Dash_Windup":
		animated_sprite.play("Dash_Attack")
		dash_to_player(1)
		if face_right:
			$AttackP1Dash/AttackRight.disabled = false
		else:
			$AttackP1Dash/AttackLeft.disabled = false
	
	if animated_sprite.animation == "Melee_Recovery":
		animated_sprite.play("Idle_P1")
		current_decision = "idle"
	if animated_sprite.animation == "Melee_Attack":
		animated_sprite.play("Melee_Recovery")
		$AttackP1Melee/AttackRight.disabled = true
		$AttackP1Melee/AttackLeft.disabled = true
	if animated_sprite.animation == "Melee_Windup":
		animated_sprite.play("Melee_Attack")
		if face_right:
			$AttackP1Melee/AttackRight.disabled = false
		else:
			$AttackP1Melee/AttackLeft.disabled = false
	
	if animated_sprite.animation == "Roar_Recovery":
		animated_sprite.play("Idle_P1")
		current_decision = "idle"
	if animated_sprite.animation == "Roar_Attack":
		animated_sprite.play("Roar_Recovery")
		$AttackP1Roar/Attack.disabled = true
	if animated_sprite.animation == "Roar_Windup":
		animated_sprite.play("Roar_Attack")
		$AttackP1Roar/Attack.disabled = false
	
	if animated_sprite.animation == "Ground_Poke_Recovery":
		animated_sprite.play("Idle_P1")
		current_decision = "idle"
	if animated_sprite.animation == "Ground_Poke_Attack":
		animated_sprite.play("Ground_Poke_Recovery")
	if animated_sprite.animation == "Ground_Poke_Windup":
		animated_sprite.play("Ground_Poke_Attack")
		spawnArm()
	
	if animated_sprite.animation == "Dragoon_Recovery":
		animated_sprite.play("Idle_P2")
		current_decision = "idle"
	if animated_sprite.animation == "Dragoon_Attack2":
		animated_sprite.play("Dragoon_Recovery")
		$AttackP2Dragoon/Attack.disabled = true
	if animated_sprite.animation == "Dragoon_Attack1":
		animated_sprite.play("Dragoon_Attack2")
		$AttackP2Dragoon/Attack.disabled = false
	if animated_sprite.animation == "Dragoon_Windup":
		animated_sprite.play("Dragoon_Attack1")
		teleport_to_player_x()
		
	
	if animated_sprite.animation == "Leap_Recovery":
		animated_sprite.play("Idle_P2")
		current_decision = "idle"
	if animated_sprite.animation == "Leap_Attack2":
		animated_sprite.play("Leap_Recovery")
		$AttackP2Leap/AttackRight.disabled = true
		$AttackP2Leap/AttackLeft.disabled = true
	if animated_sprite.animation == "Leap_Attack1":
		animated_sprite.play("Leap_Attack2")
		if face_right:
			$AttackP2Leap/AttackRight.disabled = false
		else:
			$AttackP2Leap/AttackLeft.disabled = false
	if animated_sprite.animation == "Leap_Windup":
		animated_sprite.play("Leap_Attack1")
		leap_to_player()
		
		
	
	if animated_sprite.animation == "Throw_Recovery":
		animated_sprite.play("Idle_P2")
		current_decision = "idle"
	if animated_sprite.animation == "Throw_Attack":
		animated_sprite.play("Throw_Recovery")
	if animated_sprite.animation == "Throw_Windup":
		animated_sprite.play("Throw_Attack")
		throwSpear()





func teleport_to_player_x():
	global_position.x = player.global_position.x


func leap_to_player():
	velocity.y = -200
	$Timers/JumpTimer.start()


func dash_to_player(x):
	var distance = abs(player.global_position.x - global_position.x)
	if face_right:
		velocity.x = (400 + distance*1.1)*x
	else:
		velocity.x = -(400 + distance*1.1)*x
	



func _on_jump_timer_timeout():
	dash_to_player(0.5)



func spawnArm():
	var instance = arm.instantiate()
	var spawn_position = player.global_position
	instance.spawnPos = spawn_position
	instance.on_projectile_hit.connect(Callable(self, "on_arm_hit"))
	entities.add_child.call_deferred(instance)



func throwSpear():
	var instance = spear.instantiate()
	if face_right:
		instance.direction = -300
		instance.spawnRot = -300
	else:
		instance.direction = 300
		instance.spawnRot = 300
	var spawn_position = global_position
	spawn_position.y = spawn_position.y - 15
	instance.spawnPos = spawn_position
	instance.on_projectile_hit.connect(Callable(self, "on_throw_hit"))
	entities.add_child.call_deferred(instance)
	

func on_throw_hit():
	enemy_hit.emit(10)

func on_arm_hit():
	enemy_hit.emit(10)


func _on_attack_p_1_dash_body_entered(body: Node2D) -> void:
	enemy_hit.emit(10)


func _on_attack_p_1_melee_body_entered(body: Node2D) -> void:
	enemy_hit.emit(10)


func _on_attack_p_1_roar_body_entered(body: Node2D) -> void:
	enemy_hit.emit(10)


func _on_attack_p_2_dragoon_body_entered(body: Node2D) -> void:
	enemy_hit.emit(10)


func _on_attack_p_2_leap_body_entered(body: Node2D) -> void:
	enemy_hit.emit(10)

##################################################################################
func _on_player_hit(base_damage: int) -> void:
	var final_damage := int(base_damage * ((100.0 + float(player_damage_boost)) / 100.0))
	print("[Boss] hit base=", base_damage, " mult=", player_damage_boost, " final=", final_damage)

	var health_compare: int = current_health
	current_health -= final_damage
	health_change.emit(current_health - health_compare)
	print("[Boss] Health:", current_health)

	var _dead := false
	if current_health <= 0 and not _dead:
		_dead = true
		enemy_died.emit()
########################################################################################
