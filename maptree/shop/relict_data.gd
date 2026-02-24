class_name RelicData
extends Resource

@export var id: String
@export var display_name: String
@export_multiline var description: String
@export var heals_full: bool = false
@export var icon: Texture2D
@export var cost_shells: int = 0
@export var show_in_topbar: bool = true

# Optional: was es bewirkt
enum Type {WEAPON, POTION, POISON, HEART}
@export var type: Type

enum Subtype {STRENGTH, HEALTH, PROTECTION, HEART, FROG}
@export var subtype: Subtype
@export var power: int
@export var duration_sec: int
