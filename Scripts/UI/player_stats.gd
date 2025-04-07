extends CanvasLayer

@onready var name_label = $PanelContainer/VBoxContainer/NameBox/Name
@onready var seed_label = $PanelContainer/VBoxContainer/SeedBox/Seed
@onready var base_str_label = $PanelContainer/VBoxContainer/StatsBox/GridContainer/BaseStrVal
@onready var base_def_label = $PanelContainer/VBoxContainer/StatsBox/GridContainer/BaseDefVal
@onready var attack_label = $PanelContainer/VBoxContainer/StatsBox/GridContainer/AtkVal
@onready var armor_label = $PanelContainer/VBoxContainer/StatsBox/GridContainer/ArmorVal
@onready var health_label = $PanelContainer/VBoxContainer/StatsBox/GridContainer/HealthVal
@onready var xp_label = $PanelContainer/VBoxContainer/StatsBox/GridContainer/XPval
@onready var xp_to_next_label = $PanelContainer/VBoxContainer/StatsBox/GridContainer/XPtoNextVal
@onready var lvl_label = $PanelContainer/VBoxContainer/StatsBox/GridContainer/LevelVal
@onready var inventory_list = $PanelContainer/VBoxContainer/Inventory/ItemList
@onready var use_button_list = $PanelContainer/VBoxContainer/Inventory/ItemList/UseButtons
@onready var identify_button_list = $PanelContainer/VBoxContainer/Inventory/ItemList/IdentifyButtons
@onready var resume_button = $PanelContainer/VBoxContainer/HBoxContainer/Resume
@onready var quit_button = $PanelContainer/VBoxContainer/HBoxContainer/Quit

@onready var player = $"../Player"

func _ready():
	update_stats()
	resume_button.connect("pressed", _on_close_pressed)
	visible = false # Start hidden
	identify_button_list.visible = false

func _process(delta):
	if visible:
		GameMaster.can_move = false

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode in [KEY_TAB, KEY_ESCAPE]:
		visible = !visible
		if visible:
			GameMaster.can_move = false
		else:
			GameMaster.can_move = true
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
	for column in inventory_list.get_children():
		for child in column.get_children():
			child.queue_free()
	
	for item in player.inventory_node.get_children():
		var use_button = Button.new()
		var identify_button = Button.new()
		var item_known_as = player.known(item.entity_name)
		if (item.stackable):
			use_button.text = "Use %s (Currently have x%d)" % [item_known_as, item.count]
		else:
			use_button.text = "Use %s" % item_known_as
		identify_button.text = "Identify %s" % item_known_as
		use_button.pressed.connect(_on_use_pressed.bind(use_button))
		use_button_list.add_child(use_button)
		identify_button.pressed.connect(_on_identify_pressed.bind(identify_button))
		identify_button_list.add_child(identify_button)

func _on_close_pressed():
	visible = false
	GameMaster.can_move = true

func enable_identify():
	identify_button_list.visible = true

func _on_use_pressed(use_button: BaseButton):
	var index = use_button.get_index()
	player.use(index)
	update_stats()

func _on_identify_pressed(identify_button: BaseButton):
	var index = identify_button.get_index()
	player.identify(index)
	identify_button_list.visible = false
	update_stats()

func _on_quit_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")
