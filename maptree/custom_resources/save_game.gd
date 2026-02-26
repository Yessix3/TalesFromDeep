class_name SaveGame
extends Resource

const SAVE_PATH := "user://savegame.tres"


@export var run_status: RunStatus

# MapTree-Daten (müssen rein datenbasiert sein!)
@export var map_data: Array[Array] = []
@export var last_room: Room
@export var floors_climbed: int = 0
@export var was_on_map: bool = true

@export var event_pool_state: Array[String] = []
@export var relic_counts: Array[String] = [] 

func save_data() -> void:
	var err := ResourceSaver.save(self, SAVE_PATH)
	assert(err == OK, "Couldn't save the game!")

static func load_data() -> SaveGame:
	if FileAccess.file_exists(SAVE_PATH):
		return ResourceLoader.load(SAVE_PATH) as SaveGame
	return null

static func delete_data() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
