extends Control
class_name Shop

@export var stock: Array[RelicData] = [] : set = set_stock

@onready var list_parent: VBoxContainer = %RelictList
@onready var row1: HBoxContainer = %Row1
@onready var row2: HBoxContainer = %Row2

@onready var detail_icon: TextureRect = %DetailIcon
@onready var detail_name: Label = %DetailName
@onready var detail_desc: RichTextLabel = %DetailDesc
@onready var detail_cost: Label = %DetailCost
@onready var buy_button: Button = %BuyButton
@onready var detail_shell_icon: TextureRect = %DetailShellIcon

var selected_relic: RelicData = null
var run_status: RunStatus = null # vom GameManager setzen

const RELIC_BUTTON_SCENE: PackedScene = preload("res://maptree/shop/shop_relict_button.tscn")

func _ready() -> void:
	buy_button.pressed.connect(_on_buy_pressed)
	buy_button.disabled = true
	detail_shell_icon.visible = false

	_build_list()
	_show_details(null)

func set_stock(new_stock: Array[RelicData]) -> void:
	stock = new_stock
	if is_node_ready():
		_build_list()
		_show_details(null)

func _build_list() -> void:
	# alte Buttons entfernen
	for c in row1.get_children():
		c.queue_free()
	for c in row2.get_children():
		c.queue_free()
	
	var half: int = int(ceil(stock.size() / 2.0))

	# Buttons neu erstellen
	for i in range(stock.size()):
		var relic := stock[i]
		var b := RELIC_BUTTON_SCENE.instantiate() as ShopRelicButton
		b.relic = relic
		b.selected.connect(_on_relic_selected)

		if i < half:
			row1.add_child(b)
		else:
			row2.add_child(b)


func _on_relic_selected(relic: RelicData) -> void:
	selected_relic = relic
	detail_shell_icon.visible = true
	_show_details(relic)

func _show_details(relic: RelicData) -> void:
	if relic == null:
		detail_icon.texture = null
		detail_name.text = ""
		detail_desc.text = ""
		detail_cost.text = ""
		detail_shell_icon.visible = false
		buy_button.disabled = true
		return

	detail_icon.texture = relic.icon
	detail_name.text = relic.display_name
	detail_desc.text = relic.description
	detail_cost.text = str(relic.cost_shells)

	detail_shell_icon.visible = true
	buy_button.disabled = (run_status == null) or (run_status.shells < relic.cost_shells)

func _on_buy_pressed() -> void:
	if selected_relic == null or run_status == null:
		return

	if run_status.shells < selected_relic.cost_shells:
		return

	# kaufen: Währung abziehen
	run_status.shells -= selected_relic.cost_shells

	if selected_relic.type == RelicData.Type.WEAPON:
	# schon gekauft? -> nix tun
		if run_status.get_relic_count(selected_relic.id) > 0:
			print("[Shop] weapon already owned -> ignore:", selected_relic.id)
			return

		# ins Inventar, damit es in TopBar angezeigt wird
		run_status.add_relic(selected_relic, 1)

		# Effekt additiv anwenden (25%)
		var bonus := int(selected_relic.power)
		if bonus == 0:
			bonus = 25
			print("[Shop] WARNING weapon power=0, fallback 25")
		run_status.add_outgoing_damage_mult(bonus)

		# komplett aus dem Shop entfernen
		stock.erase(selected_relic)
		print("[Shop] removed weapon from shop:", selected_relic.id)

		# UI zurücksetzen
		selected_relic = null
		_build_list()
		_show_details(null)
		return

	var is_extra_heart := (selected_relic.type == RelicData.Type.HEART) \
		or (selected_relic.subtype == RelicData.Subtype.HEART)

	if is_extra_heart:
		var amount := 1
		if selected_relic.power > 0:
			amount = int(selected_relic.power)
		run_status.add_extra_heart(amount)
		print("[Shop] applied extra heart amount=", amount)
	else:
		# Standard: Item dem Inventar hinzufügen
		run_status.add_relic(selected_relic)
		print("[Shop] added to inventory id=", selected_relic.id)

	
	
	selected_relic = null
	detail_shell_icon.visible = true
	_build_list()
	_show_details(null)

func _on_button_pressed() -> void:
	EventManager.shop_exited.emit()
