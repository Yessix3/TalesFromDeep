class_name MapRoom
extends Area2D

signal selected(room: Room)

const ICONS := {
	Room.Type.NOT_ASSIGNED: [null, Vector2.ONE],
	Room.Type.FIGHT: [preload("res://maptree/MapIcons/Fight.png"), Vector2(0.13,0.13)],
	Room.Type.EVENT: [preload("res://maptree/MapIcons/Event.png"), Vector2(0.13, 0.13)],
	Room.Type.SHOP: [preload("res://maptree/MapIcons/Shop2.png"), Vector2(0.13,0.13)],
	Room.Type.BOSS: [preload("res://maptree/MapIcons/Boss.png"), Vector2(0.3,0.3)]
}

@onready var sprite_2d: Sprite2D = $Visuals/Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var available := false : set = set_available
var room: Room : set = set_room


var current_floor: int = 0

func set_room(new_data: Room) -> void:
	room = new_data
	position = room.position
	sprite_2d.texture = ICONS[room.type][0]
	sprite_2d.scale = ICONS[room.type][1]

func set_available(new_value: bool) -> void:
	available = new_value

	if available:
		sprite_2d.modulate = Color.WHITE
		animation_player.play("highlight")
		return

	# nicht verfügbar:
	animation_player.play("RESET")

	# besucht bleibt farbig
	if room != null and room.selected:
		sprite_2d.modulate = Color.WHITE
		return
	if room != null and room.row < current_floor:
		sprite_2d.modulate = Color(0.35, 0.35, 0.35)
	else:
		sprite_2d.modulate = Color.WHITE


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if not available or not event.is_action_pressed("left_mouse"):
		return
	room.selected = true
	selected.emit(room) ###########
	animation_player.play("RESET") 

func _on_map_room_selected() -> void:
	selected.emit(room)

func show_selected() -> void:
	available = false
	animation_player.play("RESET")

