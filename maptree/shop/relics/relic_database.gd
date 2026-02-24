extends Node

const ALL_RELICS: Array[RelicData] = [
    preload("res://maptree/shop/relics/health_potion_big.tres") as RelicData,
    preload("res://maptree/shop/relics/health_potion_small.tres") as RelicData,
    preload("res://maptree/shop/relics/protection_potion_big.tres") as RelicData,
    preload("res://maptree/shop/relics/protection_potion_small.tres") as RelicData,
]

var by_id: Dictionary = {} # Dictionary[String, RelicData]

func _ready() -> void:
    for r in ALL_RELICS:
        if r == null:
            continue
        if by_id.has(r.id):
            push_error("Duplicate relic id: %s" % r.id)
        by_id[r.id] = r

func get_relic(id: String) -> RelicData:
    return by_id.get(id, null)

func get_all_relics() -> Array[RelicData]:
    return ALL_RELICS