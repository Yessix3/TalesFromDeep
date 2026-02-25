extends Node

enum Difficulty { EASY, MEDIUM, HARD }

# Pools
const EASY_POOL: Array[PackedScene] = [
	preload("res://levels/Easy2.tscn"),
	preload("res://levels/Easy3.tscn"),
	preload("res://levels/Easy4.tscn"),
	preload("res://levels/Easy5.tscn"),
]

const MEDIUM_POOL: Array[PackedScene] = [
	preload("res://levels/Medium1.tscn"),
	preload("res://levels/Medium2.tscn"),
	preload("res://levels/Medium3.tscn"),
	preload("res://levels/Medium4.tscn"),
	preload("res://levels/Medium5.tscn"),
]

const HARD_POOL: Array[PackedScene] = [
	preload("res://levels/Hard1.tscn"),
	preload("res://levels/Hard2.tscn"),
	preload("res://levels/Hard3.tscn"),
	preload("res://levels/Hard4.tscn"),
	preload("res://levels/Hard5.tscn"),
]

const BOSS_SCENE: PackedScene = preload("res://levels/BossLevel.tscn")

func _ready() -> void:
	randomize()

func difficulty_from_floor(floor_1_based: int) -> Difficulty:
	if floor_1_based >= 1 and floor_1_based <= 3:
		return Difficulty.EASY
	if floor_1_based >= 4 and floor_1_based <= 6:
		return Difficulty.MEDIUM
	return Difficulty.HARD  # 7-9 und alles darüber

func pick_battle_for_floor(floor_1_based: int) -> PackedScene:
	var diff := difficulty_from_floor(floor_1_based)
	match diff:
		Difficulty.EASY:
			return EASY_POOL.pick_random()
		Difficulty.MEDIUM:
			return MEDIUM_POOL.pick_random()
		Difficulty.HARD:
			return HARD_POOL.pick_random()
	return EASY_POOL[0]

func pick_boss() -> PackedScene:
	return BOSS_SCENE