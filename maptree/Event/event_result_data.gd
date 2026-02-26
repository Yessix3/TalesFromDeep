class_name EventResultData
extends Resource

@export var result_id: String
@export var text: String

@export var gain_shells: int = 0              # sofortige Shells
@export var max_hp_delta: int = 0             # z.B. +10 max HP (und curr HP mitziehen)
@export var player_damage_mult_delta: int = 0 # dauerhaft outgoing_damage_mult += delta
@export var enemy_damage_boost_delta: int = 0 # dauerhaft enemy_damage_boost += delta
@export var enemy_health_boost_delta: int = 0 # dauerhaft enemy_health_boost += delta


@export var shells_lost_on_hit_add: int = 0 # “Whenever hit, lose X shells”

@export var grant_relic: RelicData = null # z.B. Protection Potion
@export var grant_relic_amount: int = 1

@export var heal_amount: int = 0   

@export var lose_all_items: bool = false
@export var next_extra_enemies: int = 0 

@export var next_player_damage_boost_add: int = 0

@export var permanent_player_damage_boost_add: int = 0

@export var immediate_damage: int = 0
