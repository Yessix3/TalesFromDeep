class_name RelicData
extends Resource

@export var id: String
@export var display_name: String
@export_multiline var description: String
@export var icon: Texture2D
@export var cost_shells: int = 0

# Optional: was es bewirkt
enum Type {WEAPON, POTION, HEART}
@export var type: Type

enum Subtype {STRENGTH, HEALTH, PROTECTION, HEART}
@export var subtype: Subtype
@export var power: float = 0.0
