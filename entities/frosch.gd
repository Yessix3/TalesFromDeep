extends CharacterBody2D

@onready var anim = $AnimationPlayer
@onready var detection_area: Area2D = $Detection_Area

var is_jumping = false
var player_in_range := false

func _ready():
	anim.animation_started.connect(_on_animation_player_animation_started)
	anim.animation_finished.connect(_on_animation_player_animation_finished)
	detection_area.body_entered.connect(_on_detection_entered)
	detection_area.body_exited.connect(_on_detection_exited)
	
	
func _process(delta:):
	if player_in_range == false:
		anim.play("jump")
	else:
		anim.stop()

	
func _on_detection_entered(body: Node):
	if body.is_in_group("player"):
		player_in_range = true


func _on_detection_exited(body: Node):
	if body.is_in_group("player"):
		player_in_range = false

func _on_animation_player_animation_started(anim_name):
	pass
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "jump":
		var offset = $Sprite2D.position.x
		global_position.x += offset/5
		$Sprite2D.position.x = 0
		is_jumping = false

func try_jump():
	if is_jumping:
		return
		
	is_jumping = true
	$AnimationPlayer.play("jump")
