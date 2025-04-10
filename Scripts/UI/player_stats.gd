extends CanvasLayer

@onready var name_label = $MarginContainer/VBoxContainer/NameBox/Name
@onready var seed_label = $MarginContainer/VBoxContainer/SeedControls/SeedBox/Seed
@onready var seed_copy = $MarginContainer/VBoxContainer/SeedControls/SeedBox/CopyButton
@onready var base_str_label = $MarginContainer/VBoxContainer/StatsBox/GridContainer/BaseStrVal
@onready var base_def_label = $MarginContainer/VBoxContainer/StatsBox/GridContainer/BaseDefVal
@onready var attack_label = $MarginContainer/VBoxContainer/StatsBox/GridContainer/AtkVal
@onready var armor_label = $MarginContainer/VBoxContainer/StatsBox/GridContainer/ArmorVal
@onready var health_label = $MarginContainer/VBoxContainer/StatsBox/GridContainer/HealthVal
@onready var xp_label = $MarginContainer/VBoxContainer/StatsBox/GridContainer/XPval
@onready var xp_to_next_label = $MarginContainer/VBoxContainer/StatsBox/GridContainer/XPtoNextVal
@onready var lvl_label = $MarginContainer/VBoxContainer/StatsBox/GridContainer/LevelVal
@onready var inventory_list = $MarginContainer/VBoxContainer/Inventory/ItemList
@onready var resume_button = $MarginContainer/VBoxContainer/HBoxContainer/Resume
@onready var quit_button = $MarginContainer/VBoxContainer/HBoxContainer/Quit
@onready var cmdline = $"../CommandLine"

var identify_visible = false
var font = load("Textures/Tilemaps/UI/m5x7.ttf")
const INVENTORY_FONT_SIZE = 32

@onready var player = $"../Player"

func _ready():
	update_stats()
	resume_button.pressed.connect(_on_close_pressed)
	seed_copy.pressed.connect(_on_copy_pressed)
	visible = false # Start hidden

func _process(_delta):
	if visible:
		GameMaster.can_move = false

func _input(event):
	if cmdline.visible:
		return
	if event is InputEventKey and event.pressed and event.keycode in [KEY_TAB, KEY_ESCAPE, KEY_I]:
		visible = !visible
		if visible:
			SoundFx.menu_yes()
			GameMaster.can_move = false
		else:
			SoundFx.menu_no()
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
	for child in inventory_list.get_children():
		child.queue_free()
	
	for item in player.inventory_node.get_children():
		var sprite = AtlasTexture.new()
		var sprite_rect = TextureRect.new()
		var item_label = Label.new()
		var use_button = Button.new()
		var drop_button = Button.new()
		var identify_button = Button.new()
		
		sprite.atlas = item.get_child(0).get_texture()
		sprite.region = item.get_child(0).region_rect
		
		sprite_rect.texture = sprite
		sprite_rect.set_expand_mode(TextureRect.ExpandMode.EXPAND_FIT_WIDTH)
		inventory_list.add_child(sprite_rect)
		
		var item_known_as = player.known(item.entity_name)
		if (item.stackable):
			item_label.text = "%s (x%d)" % [item_known_as, item.count]
		else:
			item_label.text = "%s" % item_known_as
		item_label.add_theme_font_override("font", font)
		item_label.add_theme_font_size_override("font_size", INVENTORY_FONT_SIZE)
		inventory_list.add_child(item_label)
		
		use_button.text = " Use "
		use_button.name = "UseButton"
		use_button.pressed.connect(_on_use_pressed.bind(use_button))
		use_button.add_theme_font_override("font", font)
		use_button.add_theme_font_size_override("font_size", INVENTORY_FONT_SIZE)
		inventory_list.add_child(use_button)
		
		drop_button.text = " Drop "
		drop_button.name = "DropButton"
		drop_button.pressed.connect(_on_drop_pressed.bind(drop_button))
		drop_button.add_theme_font_override("font", font)
		drop_button.add_theme_font_size_override("font_size", INVENTORY_FONT_SIZE)
		inventory_list.add_child(drop_button)
		
		identify_button.visible = identify_visible
		identify_button.text = " Identify "
		identify_button.name = "IdentifyButton"
		identify_button.add_theme_font_override("font", font)
		identify_button.add_theme_font_size_override("font_size", INVENTORY_FONT_SIZE)
		identify_button.pressed.connect(_on_identify_pressed.bind(identify_button))
		inventory_list.add_child(identify_button)

func _on_close_pressed():
	visible = false
	SoundFx.menu_no()
	GameMaster.can_move = true

func _on_copy_pressed():
	SoundFx.menu_yes()
	DisplayServer.clipboard_set(str(GameMaster.current_seed))

func show_identify():
	inventory_list.columns = 5
	identify_visible = true

func hide_identify():
	inventory_list.columns = 4
	identify_visible = false

func _on_use_pressed(use_button: BaseButton):
	SoundFx.inventory_click()
	var index = use_button.get_index() / 5
	player.use(index)
	update_stats()

func _on_drop_pressed(drop_button: BaseButton):
	SoundFx.menu_no()
	var index = drop_button.get_index() / 5
	player.drop(index)
	update_stats()

func _on_identify_pressed(identify_button: BaseButton):
	SoundFx.inventory_click()
	var index = identify_button.get_index() / 5
	player.identify(index)
	hide_identify()
	update_stats()

func _on_quit_pressed():
	SoundFx.menu_no()
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")
