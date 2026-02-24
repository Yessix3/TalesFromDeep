extends Node


# Battle-related events
signal battle_over_closed(type: int)
signal fight_won
signal fight_lost

# Map-related events
signal map_exited(room: Room)

# Shop-related events
signal shop_exited

# Battle Reward-related events
signal battle_reward_exited

# Event room-related events
signal event_room_exited

signal result_requested(result: EventResultData)

func request_result(result: EventResultData) -> void:
    result_requested.emit(result)
