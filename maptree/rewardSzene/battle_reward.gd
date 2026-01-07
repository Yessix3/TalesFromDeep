class_name BattleReward
extends Control

const REWARD_BUTTON = preload("res://maptree/rewardSzene/reward_button.tscn")
const SHELLS_ICON := preload("res://maptree/TestButtons/GakiTestIconShell.png")
const SHELLS_TEXT := "%s Shells"

@export var run_status: RunStatus

@onready var rewards: VBoxContainer = %Rewards

func _ready() -> void:
	for node: Node in rewards.get_children():
		node.queue_free()

	#run_status = RunStatus.new()
	#run_status.shells_changed.connect(func(): print("shells: %s" % run_status.shells))

	#add_shells_reward(77)
#void add_shells_reward(amount: int)


func add_shells_reward(amount: int) -> void:
	var shells_reward := REWARD_BUTTON.instantiate() as RewardButton
	shells_reward.reward_icon = SHELLS_ICON
	shells_reward.reward_text = SHELLS_TEXT % amount
	shells_reward.pressed.connect(_on_shells_reward_taken.bind(amount))
	rewards.add_child.call_deferred(shells_reward)

func _on_shells_reward_taken(amount: int) -> void:
	if not run_status:
		return
	run_status.shells += amount


func _on_back_button_pressed() -> void:
	EventManager.battle_reward_exited.emit()

