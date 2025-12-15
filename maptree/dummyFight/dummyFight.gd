class_name Fight
extends Node2D

@export var player: Player

@onready var win_area: Area2D = $Win
@onready var lose_area: Area2D = $Loose


signal fight_won(won: bool)

func _ready():
	win_area.body_entered.connect(_on_win_area_entered)
	lose_area.body_entered.connect(_on_lose_area_entered)



func _on_win_area_entered(body):
	if body.is_in_group("player"):
		fight_won.emit(true)


func _on_lose_area_entered(body):
	if body.is_in_group("player"):
		fight_won.emit(false)
