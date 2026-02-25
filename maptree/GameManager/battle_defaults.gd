extends Node

enum Difficulty { EASY, MEDIUM, HARD }

const MAX_ENEMIES_EASY := 4
const MAX_ENEMIES_MEDIUM := 5
const MAX_ENEMIES_HARD := 6

func difficulty_from_floor(floor_1_based: int) -> Difficulty:
	if floor_1_based >= 1 and floor_1_based <= 3:
		return Difficulty.EASY
	if floor_1_based >= 4 and floor_1_based <= 6:
		return Difficulty.MEDIUM
	return Difficulty.HARD

func make_default_config(diff: Difficulty) -> BattleConfig:
	var cfg := BattleConfig.new()

	match diff:
		Difficulty.EASY:
			cfg.enemy_health_boost = 0
			cfg.enemy_damage_boost = -10
			cfg.player_damage_boost = 10
			cfg.enemy_variant = 1
			cfg.number_enemies_spawn = clamp(cfg.number_enemies_spawn, 0, MAX_ENEMIES_EASY)
			cfg.shells_reward = 1000

		Difficulty.MEDIUM:
			cfg.enemy_health_boost = 10
			cfg.enemy_damage_boost = 0
			cfg.player_damage_boost = 0
			cfg.enemy_variant = 1
			cfg.number_enemies_spawn = clamp(cfg.number_enemies_spawn, 0, MAX_ENEMIES_MEDIUM)
			cfg.shells_reward = 50

		Difficulty.HARD:
			cfg.enemy_health_boost = 25
			cfg.enemy_damage_boost = 10
			cfg.player_damage_boost = -5
			cfg.enemy_variant = 2
			cfg.number_enemies_spawn = clamp(cfg.number_enemies_spawn, 0, MAX_ENEMIES_HARD)
			cfg.shells_reward = 100

	return cfg
