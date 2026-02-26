class_name RelicUI
extends Button

signal relic_clicked(relic: RelicData)

@export var relic: RelicData : set = set_relic

@onready var recicon: TextureRect = %RelicIcon
@onready var amount: Label = %RelicAmount

func _ready() -> void:
    if not pressed.is_connected(_on_pressed):
        pressed.connect(_on_pressed)
    print("RelicUI ready: disabled=", disabled, " relic=", relic.id)

func set_relic(new_relic: RelicData) -> void:
    relic = new_relic
    if not is_node_ready():
        await ready
    
    relic = new_relic
    recicon.texture = relic.icon

    if relic == null:
        recicon.texture = null
        amount.text = "0"
        disabled = true
        return

    disabled = false
    recicon.texture = relic.icon

func set_amount(value: int) -> void:
    if not is_node_ready():
        await ready
    amount.text = str(value)
    #visible = value > 0

func _on_pressed() -> void:
    print("pressed")
    if relic != null:
        relic_clicked.emit(relic)