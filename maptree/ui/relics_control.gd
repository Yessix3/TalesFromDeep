class_name RelictsControl
extends Control

const RELICS_PER_PAGE := 5
const TWEEN_SCROLL_DURATION := 0.2

@export var left_button: TextureButton
@export var right_button: TextureButton

@onready var relics: HBoxContainer = %Relics
@onready var page_width = self.custom_minimum_size.x

var num_of_relics := 0
var current_page := 1
var max_page := 0
var relics_position: float

func _ready() -> void:
	left_button.pressed.connect(_on_left_button_pressed)
	right_button.pressed.connect(_on_right_button_pressed)
	relics.child_order_changed.connect(_on_relics_child_order_changed)
	call_deferred("update")


func update() -> void:
	num_of_relics = relics.get_child_count()
	max_page = ceili(num_of_relics/float(RELICS_PER_PAGE))
	left_button.disabled = current_page <= 1
	right_button.disabled = current_page >= max_page
	print(max_page)


func _on_left_button_pressed() -> void:
	if current_page > 1:
		current_page -= 1
		update()
		relics_position += page_width


func _on_right_button_pressed() -> void:
	if current_page < max_page:
		current_page += 1
		update()
		relics_position -= page_width


func _on_relics_child_order_changed() -> void:
	update()
