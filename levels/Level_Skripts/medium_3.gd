extends Node2D

@export var respawn_y: float = 680.0

@onready var player := get_node_or_null("Main/Entities/Player") as CharacterBody2D
var spawn_position: Vector2


func _ready():
	if player == null:
		push_error("Player NICHT gefunden! Pfad: Main/Entities/Player")
		return

	spawn_position = player.global_position


func _physics_process(delta):
	if player and player.global_position.y > respawn_y:
		respawn_player()


func respawn_player():
	player.global_position = spawn_position
	player.velocity = Vector2.ZERO

