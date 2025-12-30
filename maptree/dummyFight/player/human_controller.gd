class_name HumanController
extends Node

@export var action_left: String = "Left"
@export var action_right: String = "Right"

@onready var player: Player = get_parent()

func _physics_process(_delta):
    player.movement = Input.get_axis(action_left, action_right)