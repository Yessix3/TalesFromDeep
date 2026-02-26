extends Control
class_name ResultScreen


@onready var text_label: RichTextLabel = %ResultText
@onready var continue_button: Button = %ContinueButton

@export var run_status: RunStatus
var result: EventResultData

func _ready() -> void:
	continue_button.pressed.connect(_on_continue)

func set_result(r: EventResultData, rs: RunStatus) -> void:
	result = r
	run_status = rs
	text_label.text = result.text

func _on_continue() -> void:
	if result == null or run_status == null:
		push_error("[EventResult] Missing result or run_status.")
		EventManager.exit_event_room()
		return

	_apply_result_effects(result, run_status)

	EventManager.event_room_exited.emit()

func _apply_result_effects(r: EventResultData, s: RunStatus) -> void:
	# sofortige Shells
	if r.gain_shells != 0:
		s.add_shells(r.gain_shells)

	# Max HP + Curr HP 
	if r.max_hp_delta != 0:
		s.add_max_health_with_current(r.max_hp_delta)

	# dauerhafte
	if r.player_damage_mult_delta != 0:
		s.add_outgoing_damage_mult(r.player_damage_mult_delta)

	if r.enemy_damage_boost_delta != 0:
		s.add_enemy_damage_boost(r.enemy_damage_boost_delta)

	if r.enemy_health_boost_delta != 0:
		s.add_enemy_health_boost(r.enemy_health_boost_delta)

	# “on hit lose shells”
	if r.shells_lost_on_hit_add != 0:
		s.add_shells_lost_on_hit(r.shells_lost_on_hit_add)
	
	if r.grant_relic != null and r.grant_relic_amount > 0:
		s.add_relic(r.grant_relic, r.grant_relic_amount)

	if r.heal_amount > 0 and s.curr_health < s.max_health:
		s.heal(r.heal_amount)
	
	if r.lose_all_items:
		s.clear_all_relics()

	if r.next_extra_enemies != 0:
		s.add_next_number_enemies_spawn(r.next_extra_enemies)
	
	if r.next_player_damage_boost_add != 0:
		s.add_next_player_damage_boost(r.next_player_damage_boost_add)

	if r.permanent_player_damage_boost_add != 0:
		s.add_outgoing_damage_mult(r.permanent_player_damage_boost_add)
	
	if r.immediate_damage > 0:
		s.apply_health_delta(r.immediate_damage)
