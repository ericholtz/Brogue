extends CanvasLayer

@onready var name_label = $PanelContainer/VBoxContainer/Name
@onready var attack_label = $PanelContainer/VBoxContainer/GridContainer/AtkVal
@onready var defense_label = $PanelContainer/VBoxContainer/GridContainer/DefVal
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
	health_label.text = str(player.health)
	attack_label.text = str(player.strength)
	defense_label.text = str(player.defense)
	update_inventory()

func update_inventory():
	for child in inventory_list.get_children():
		child.queue_free()
	
	for item in player.inventory:
		var item_label = Label.new()
		item_label.text = "- %s x%d" % [item, player.inventory[item]]
		inventory_list.add_child(item_label)

func _on_close_pressed():
	visible = false
	GameMaster.can_move = true
	
