class_name BattleStatus
extends Resource

 # bestimmt schwierigkeit des Levels, kommt bei uns darauf an welche Lösung wir 
 # nehmen die Levels zu zu weisen: A) in jedem Layer wird random von Level-Pool
 # gewählt (hier wird battle_tier nicht benötigt), B) Level wird in Kategorien 
 # leicht-schwer eingeteilt (hier ist battle_tier die Kategorie)
 # C) für jeden Layer eine Levelkategorie
@export_range(0,2) var battle_tier: int  
@export_range(0.0, 10.0) var weight: float
@export var gold_reward_min: int
@export var gold_reward_max: int
@export var enemies: PackedScene

var accumulated_weight: float = 0.0

func roll_gold_reward() -> int:
    return randi_range(gold_reward_min, gold_reward_max)
