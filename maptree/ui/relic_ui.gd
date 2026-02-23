class_name RelicUI
extends Button

@export var relic: RelicData : set = set_relic

@onready var recicon: TextureRect = %RelicIcon
@onready var amount: Label = %RelicAmount

func set_relic(new_relic: RelicData) -> void:
    if not is_node_ready():
        await ready
    
    relic = new_relic
    recicon.texture = relic.icon