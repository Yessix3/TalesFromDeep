extends Node


# Battle-related events
signal battle_over_screen_requested(text: String, type: BattleOverPanel.Type)
signal fight_won
signal fight_lost

# Map-related events
signal map_exited(room: Room)

# Shop-related events
signal shop_exited

# Battle Reward-related events
signal battle_reward_exited

# Random Event room-related events
signal event_room_exited
