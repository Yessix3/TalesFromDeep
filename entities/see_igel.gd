extends CharacterBody2D

# Nodes
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $Detection_Area
@onready var spike_area: Area2D = $SpikeHitbox
@onready var collision_shape: CollisionShape2D = $SpikeHitbox/CollisionShape2D

var hitbox_shape: CapsuleShape2D = null
var player_in_range := false

# Spike Tips
var spike_tips := []

const SPIKE_FRAME := 10  # Frame, in dem der Spike Schaden verursacht

func _ready():
	# SpikeTips Kinder holen
	var tips_node = $SpikeTips
	if tips_node:
		spike_tips = tips_node.get_children()
		if spike_tips.size() == 0:
			push_warning("SpikeTips hat keine Kinder!")
	else:
		push_error("SpikeTips Node existiert nicht!")

	# Signale für DetectionArea verbinden
	detection_area.body_entered.connect(_on_detection_entered)
	detection_area.body_exited.connect(_on_detection_exited)

	# Sprite initial
	sprite.play("idle")

	# CapsuleShape prüfen
	if collision_shape.shape is CapsuleShape2D:
		hitbox_shape = collision_shape.shape as CapsuleShape2D
	else:
		push_error("SpikeHitbox CollisionShape2D muss ein CapsuleShape2D enthalten!")

	# Verbinde alle TipAreas mit _on_tip_hit, aber deaktiviere Monitoring zunächst
	for tip in spike_tips:
		var tip_area = tip.get_node("TipArea") if tip.has_node("TipArea") else null
		if tip_area:
			tip_area.monitoring = false
			tip_area.body_entered.connect(_on_tip_hit)

func _process(delta):
	if player_in_range:
		attack()
	else:
		idle()
	
	if sprite.animation == "attack":
		update_hitbox()

		# TipAreas nur im Stichframe aktivieren
		for tip in spike_tips:
			var tip_area = tip.get_node("TipArea") if tip.has_node("TipArea") else null
			if tip_area:
				tip_area.monitoring = (sprite.frame == SPIKE_FRAME)

func attack():
	if sprite.animation != "attack":
		sprite.play("attack")

func idle():
	if sprite.animation != "idle":
		sprite.play("idle")

func _on_detection_entered(body: Node):
	if body.is_in_group("player"):
		player_in_range = true

func _on_detection_exited(body: Node):
	if body.is_in_group("player"):
		player_in_range = false

# --- Schaden, wenn Spieler SpikeTip berührt ---
func _on_tip_hit(body: Node):
	if body.is_in_group("player"):
		print("TOOK DAMAGE")
		#body.take_damage(1)  # <-- deine eigene Damage-Funktion

func update_hitbox():
	if spike_tips.size() == 0 or hitbox_shape == null:
		return

	# Mittelpunkt der Stachelspitzen berechnen
	var center := Vector2.ZERO
	for tip in spike_tips:
		center += tip.global_position
	center /= spike_tips.size()

	# Maximalen Abstand berechnen
	var max_dist := 0.0
	var tip_dirs := []
	for tip in spike_tips:
		var dir = tip.global_position - center
		tip_dirs.append(dir)
		max_dist = max(max_dist, dir.length())

	# Hitbox verschieben
	spike_area.global_position = center

	# CapsuleShape2D anpassen
	hitbox_shape.radius = max_dist / 2
	hitbox_shape.height = max_dist * 2

	# Rotation entlang weitester Spitze
	var longest_dir = tip_dirs[0]
	for dir in tip_dirs:
		if dir.length() > longest_dir.length():
			longest_dir = dir
	if longest_dir.length() > 0:
		spike_area.global_rotation = longest_dir.angle()
