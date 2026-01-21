extends CharacterBody2D

# === Einstellungen ===
@export var attack_cooldown: float = 2.0   # Sekunden zwischen Angriffen
@export var attack_range: float = 120.0   # Reichweite für Angriff (optional)

# === interne Variablen ===
var can_attack: bool = true

func _ready():
	$AnimatedSprite2D.play("idle")

func _process(delta):
	# Optional: einfache Angriffslogik
	# Wenn der Spieler in Reichweite ist, angreifen
	var player = get_node_or_null("../Player")  # Beispiel: Player ist im gleichen Parent
	if player and can_attack:
		var dist = global_position.distance_to(player.global_position)
		if dist <= attack_range:
			attack()

func attack():
	if not can_attack:
		return

	can_attack = false
	$AnimatedSprite2D.play("attack")

func _on_AnimatedSprite2D_animation_finished():
	if $AnimatedSprite2D.animation == "attack":
		$AnimatedSprite2D.play("idle")
		start_cooldown()

func start_cooldown():
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
