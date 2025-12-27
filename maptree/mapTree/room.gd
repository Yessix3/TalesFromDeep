class_name Room
extends Resource

enum Type {NOT_ASSIGNED, START, FIGHT, EVENT, SHOP, BOSS}


@export var type: Type
@export var row: int
@export var column: int 
@export var position: Vector2        # combined row and column number (cordinate)
@export var next_rooms: Array[Room]
@export var selected := false

func _to_string() -> String:
    # for testing purpose
    return "%s (%s)" % [column, Type.keys()[type][0]]