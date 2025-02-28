extends CanvasLayer

@onready var name_label = $PanelContainer/VBoxContainer/Name
@onready var seed_label = $PanelContainer/VBoxContainer/Seed
@onready var base_str_label = $PanelContainer/VBoxContainer/GridContainer/BaseStrVal
@onready var base_def_label = $PanelContainer/VBoxContainer/GridContainer/BaseDefVal
@onready var attack_label = $PanelContainer/VBoxContainer/GridContainer/AtkVal
@onready var armor_label = $PanelContainer/VBoxContainer/GridContainer/ArmorVal
@onready var health_label = $PanelContainer/VBoxContainer/GridContainer/HealthVal
@onready var xp_label = $PanelContainer/VBoxContainer/GridContainer/XPval
@onready var xp_to_next_label = $PanelContainer/VBoxContainer/GridContainer/XPtoNextVal
@onready var lvl_label = $PanelContainer/VBoxContainer/GridContainer/LevelVal
@onready var inventory_list = $PanelContainer/VBoxContainer/Inventory/ItemList
@onready var close_button = $PanelContainer/VBoxContainer/Close

@onready var player = $"../Player"

func _ready():
	update_stats()
	close_button.connect("pressed", _on_close_pressed)
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
	lvl_label.text = str(player.level)
	xp_label.text = str(player.currentXP)
	var xpNeeded = player.XPtoNext - player.currentXP
	xp_to_next_label.text = str(xpNeeded)
	update_inventory()

func update_inventory():
	for child in inventory_list.get_children():
		child.queue_free()
	
	for item in player.inventoryNode.get_children():
		var use_button = Button.new()
		if (item.stackable):
			use_button.text = "Use %s (Currently have x%d)" % [item.entityName, item.count]
		else:
			use_button.text = "Use %s" % item.entityName
		use_button.pressed.connect(_on_use_pressed.bind(use_button))
		inventory_list.add_child(use_button)

func _on_close_pressed():
	visible = false
	GameMaster.can_move = true
	

func _on_use_pressed(useButton : BaseButton):
	var index = useButton.get_index()
	player.use(index)
	update_stats()
	
