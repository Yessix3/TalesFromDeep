extends Node


# Battle-related events
enum BattleOverType { WIN, LOSE }
signal battle_over_screen_requested(text: String, type: BattleOverType)
signal fight_won(won: bool)

# Map-related events
signal map_exited(room: Room)

# Shop-related events
signal shop_exited

# Campfire-related events
signal campfire_exited

# Battle Reward-related events
signal battle_reward_exited

# Random Event room-related events
signal event_room_exited
