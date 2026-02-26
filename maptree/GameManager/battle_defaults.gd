extends Node

enum Difficulty { EASY, MEDIUM, HARD }

const MAX_ENEMIES_EASY := 4
const MAX_ENEMIES_MEDIUM := 5
const MAX_ENEMIES_HARD := 6

const BASE_ENEMIES_EASY := 1
const BASE_ENEMIES_MEDIUM := 2
const BASE_ENEMIES_HARD := 3

func difficulty_from_floor(floor_1_based: int) -> Difficulty:
	if floor_1_based >= 1 and floor_1_based <= 3:
		return Difficulty.EASY
	if floor_1_based >= 4 and floor_1_based <= 6:
		return Difficulty.MEDIUM
	return Difficulty.HARD


func max_enemies_for_diff(diff: Difficulty) -> int:
	match diff:
		Difficulty.EASY: return MAX_ENEMIES_EASY
		Difficulty.MEDIUM: return MAX_ENEMIES_MEDIUM
		_: return MAX_ENEMIES_HARD

func base_enemies_for_diff(diff: Difficulty) -> int:
	match diff:
		Difficulty.EASY: return BASE_ENEMIES_EASY
		Difficulty.MEDIUM: return BASE_ENEMIES_MEDIUM
		_: return BASE_ENEMIES_HARD

func make_default_config(diff: Difficulty) -> BattleConfig:
	var cfg := BattleConfig.new()

	match diff:
		Difficulty.EASY:
			cfg.enemy_health_boost = 0
			cfg.enemy_damage_boost = -20
			cfg.player_damage_boost = 10
			cfg.enemy_variant = 1
			cfg.number_enemies_spawn = BASE_ENEMIES_EASY
			cfg.shells_reward = 100

		Difficulty.MEDIUM:
			cfg.enemy_health_boost = 10
			cfg.enemy_damage_boost = 0
			cfg.player_damage_boost = 0
			cfg.enemy_variant = 1
			cfg.number_enemies_spawn =  BASE_ENEMIES_MEDIUM
			cfg.shells_reward = 150

		Difficulty.HARD:
			cfg.enemy_health_boost = 25
			cfg.enemy_damage_boost = 10
			cfg.player_damage_boost = -5
			cfg.enemy_variant = 2
			cfg.number_enemies_spawn = BASE_ENEMIES_HARD
			cfg.shells_reward = 200

	return cfg
