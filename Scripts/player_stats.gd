extends CanvasLayer

@onready var name_label = $PanelContainer/VBoxContainer/Name
@onready var seed_label = $PanelContainer/VBoxContainer/Seed
@onready var base_str_label = $PanelContainer/VBoxContainer/GridContainer/BaseStrVal
@onready var base_def_label = $PanelContainer/VBoxContainer/GridContainer/BaseDefVal
@onready var attack_label = $PanelContainer/VBoxContainer/GridContainer/AtkVal
@onready var armor_label = $PanelContainer/VBoxContainer/GridContainer/ArmorVal
@onready var health_label = $PanelContainer/VBoxContainer/GridContainer/HealthVal
@onready var inventory_list = $PanelContainer/VBoxContainer/Inventory/ItemList
@onready var close_button = $PanelContainer/VBoxContainer/Close

@onready var player = $"../Player"

func _ready():
	update_stats()
	close_button.connect("pressed", Callable(self, "_on_close_pressed"))
	visible = false # Start hidden

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		visible = !visible
		GameMaster.can_move = !GameMaster.can_move
		update_stats()
		update_inventory()

func update_stats():
	name_label.text = "Name: " + player.player_name
	seed_label.text = "Seed: " + str(GameMaster.current_seed)
	health_label.text = str(player.health)
	base_str_label.text = str(player.strength)
	base_def_label.text = str(player.defense)
	attack_label.text = str(player.attack)
	armor_label.text = str(player.armor)
	update_inventory()

func update_inventory():
	for child in inventory_list.get_children():
		child.queue_free()
	
	for item in player.inventory:
		var item_label = Label.new()
		item_label.text = "- %s" % item
		inventory_list.add_child(item_label)

func _on_close_pressed():
	visible = false
	GameMaster.can_move = true
	
