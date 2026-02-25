class_name RunStatus
extends Resource

signal shells_changed
signal relics_changed()

signal curr_health_changed(new_value: int)
signal max_health_changed(new_value: int)
signal died()

signal incoming_damage_mult_changed(new_value: int)
signal outgoing_damage_mult_changed(new_value: int)

signal enemy_health_boost_changed(v: int)
signal enemy_damage_boost_changed(v: int)

@export var incoming_damage_mult: int = 0 : set = set_incoming_damage_mult  # z.B. -15
@export var outgoing_damage_mult: int = 0 : set = set_outgoing_damage_mult  # z.B. +50

@export var enemy_health_boost: int = 0 : set = set_enemy_health_boost
@export var enemy_damage_boost: int = 0 : set = set_enemy_damage_boost

@export var next_enemy_health_boost: int = 0
@export var next_enemy_damage_boost: int = 0
@export var next_player_damage_boost: int = 0
@export var next_number_enemies_spawn_delta: int = 0

@export var next_enemy_variant_override: int = -1 


const STARTING_CURRENT_HEALTH := 100
const STARTING_MAX_HEALTH := 100
const STARTING_SHELLS := 0

@export var shells := STARTING_SHELLS: set = set_shells

@export var curr_health := STARTING_CURRENT_HEALTH: set = set_curr_health
@export var max_health := STARTING_MAX_HEALTH: set = set_max_health

@export var relic_counts: Dictionary = {}


func set_shells(new_amount: int) -> void:
    shells = new_amount
    shells_changed.emit()

func add_relic(relic: RelicData, amount: int = 1) -> void:
    if relic == null:
        return
    var key: String = relic.id
    var current: int = relic_counts.get(key, 0)
    relic_counts[key] = current + amount
    relics_changed.emit()

func get_relic_count(relic_id: String) -> int:
    return int(relic_counts.get(relic_id, 0))

func consume_relic(relic_id: String, amount: int = 1) -> bool:
    var current: int = get_relic_count(relic_id)
    if current < amount:
        return false
    relic_counts[relic_id] = current - amount
    if relic_counts[relic_id] <= 0:
        relic_counts.erase(relic_id)
    relics_changed.emit()
    return true

func set_curr_health(new_curr_health: int) -> void:
    curr_health = clamp(new_curr_health, 0, max_health)
    curr_health_changed.emit(curr_health)
    if curr_health <= 0:
        print("RunStatus died emitted")
        died.emit()

func set_max_health(new_max_health: int) -> void:
    max_health = max(1, new_max_health)
    max_health_changed.emit(max_health)
    # falls max sinkt:
    curr_health = clamp(curr_health, 0, max_health)
    curr_health_changed.emit(curr_health)

func apply_health_delta(delta: int) -> void:
    # delta kann negativ oder positiv sein
    set_curr_health(curr_health - delta)

func heal(amount: int) -> void:
    if amount <= 0:
        return
    set_curr_health(curr_health + amount)

func heal_to_full() -> void:
    set_curr_health(max_health)

func try_use_relic(relic: RelicData) -> bool:
    print("heal from", curr_health, "to", min(max_health, curr_health + int(relic.power)))
    if relic == null:
        return false
    if get_relic_count(relic.id) <= 0:
        return false

    # Nur Health-Potion hier behandeln (andere später)
    if relic.type == RelicData.Type.POTION and relic.subtype == RelicData.Subtype.HEALTH:
        # Wenn already full -> nicht verbrauchen
        if curr_health >= max_health:
            return false

        # erst verbrauchen, wenn Anwendung möglich
        if relic.heals_full:
            consume_relic(relic.id, 1)
            heal_to_full()
            return true
        else:
            consume_relic(relic.id, 1)
            heal(int(relic.power))
            return true

    return false


func set_incoming_damage_mult(v: int) -> void:
    incoming_damage_mult = v
    print("[RunStatus] incoming_damage_mult =", incoming_damage_mult)
    incoming_damage_mult_changed.emit(incoming_damage_mult)

func set_outgoing_damage_mult(v: int) -> void:
    outgoing_damage_mult = v
    outgoing_damage_mult_changed.emit(outgoing_damage_mult)

func calc_incoming_damage(base_damage: int) -> int:
    var final_damage := int(base_damage * ((100.0 + float(incoming_damage_mult)) / 100.0))
    print("[RunStatus] calc_incoming_damage base=", base_damage, " mult=", incoming_damage_mult, " final=", final_damage)
    return final_damage

func calc_outgoing_damage(base_damage: int) -> int:
    return int(base_damage * ((100.0 + float(outgoing_damage_mult)) / 100.0))

func add_extra_heart(amount: int = 1) -> void:
    if amount <= 0:
        return

    print("[RunStatus] add_extra_heart amount=", amount,
        " before: max=", max_health, " curr=", curr_health)

    # max erhöhen
    set_max_health(max_health + amount)

    # curr um gleichen Betrag erhöhen (nicht “to full”, sondern +amount)
    set_curr_health(curr_health + amount)

    print("[RunStatus] add_extra_heart done",
        " after: max=", max_health, " curr=", curr_health)

func try_buy_stronger_weapon(relic: RelicData) -> bool:
    # gibt true zurück, wenn gekauft+angewendet
    if relic == null:
        return false

    if get_relic_count(relic.id) > 0:
        print("[RunStatus] stronger weapon already owned:", relic.id)
        return false

    var bonus := int(relic.power) # erwartet 25
    if bonus == 0:
        bonus = 25
        print("[RunStatus] WARNING weapon power=0, fallback to 25")

    # dauerhaft setzen (nicht addieren, da einmalig)
    add_outgoing_damage_mult(bonus)

    # ins Inventar aufnehmen, damit es in TopBar angezeigt wird
    add_relic(relic, 1)

    print("[RunStatus] stronger weapon applied. outgoing_damage_mult=", outgoing_damage_mult)
    return true

func add_outgoing_damage_mult(delta: int) -> void:
    if delta == 0:
        return
    set_outgoing_damage_mult(outgoing_damage_mult + delta)
    print("[RunStatus] add_outgoing_damage_mult delta=", delta, " total=", outgoing_damage_mult)

func set_enemy_health_boost(v: int) -> void:
    enemy_health_boost = v
    enemy_health_boost_changed.emit(v)

func set_enemy_damage_boost(v: int) -> void:
    enemy_damage_boost = v
    enemy_damage_boost_changed.emit(v)

func add_enemy_health_boost(delta: int) -> void:
    set_enemy_health_boost(enemy_health_boost + delta)

func add_enemy_damage_boost(delta: int) -> void:
    set_enemy_damage_boost(enemy_damage_boost + delta)

func add_next_enemy_health_boost(delta: int) -> void:
    next_enemy_health_boost += delta

func add_next_enemy_damage_boost(delta: int) -> void:
    next_enemy_damage_boost += delta

func add_next_player_damage_boost(delta: int) -> void:
    next_player_damage_boost += delta

func add_next_number_enemies_spawn(delta: int) -> void:
    next_number_enemies_spawn_delta += delta

func set_next_enemy_variant(variant: int) -> void:
    next_enemy_variant_override = variant

func clear_next_battle_modifiers() -> void:
    next_enemy_health_boost = 0
    next_enemy_damage_boost = 0
    next_player_damage_boost = 0
    next_number_enemies_spawn_delta = 0
    next_enemy_variant_override = -1