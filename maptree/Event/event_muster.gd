extends Control
class_name EventScreen

@export var event_data: EventData

@onready var title_lable: Label = %EventTitle
@onready var message_label: RichTextLabel = %Situation
@onready var option_buttons: Array[EventOptionButton] = [
	%OptionButton1,
	%OptionButton2,
	%OptionButton3
]

func _ready() -> void:
	_bind_buttons()
	if event_data:
		show_event(event_data)

func _bind_buttons() -> void:
	for b in option_buttons:
		if not b.option_chosen.is_connected(_on_option_chosen):
			b.option_chosen.connect(_on_option_chosen)

func show_event(data: EventData) -> void:
	event_data = data
	message_label.text = data.message
	title_lable.text = data.title

	# sicherstellen, dass es genau 3 Optionen gibt
	if data.options.size() != 3:
		push_error("Event %s has %d options, expected 3." % [data.event_id, data.options.size()])

	for i in range(option_buttons.size()):
		option_buttons[i].option = data.options[i] if i < data.options.size() else null
		option_buttons[i].disabled = option_buttons[i].option == null

func _on_option_chosen(option: OptionButtonData) -> void:
	if option.result == null:
		push_error("Option %s has no result assigned." % option.id)
		return
	EventManager.request_result(option.result)
