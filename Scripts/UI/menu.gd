extends Control

@onready var seed_text = $CenterContainer/VBoxContainer/StartButton/TextureRect/CustomSeed

func _ready():
	SoundFx.play_menu_music()

func _on_start_button_pressed() -> void:
	SoundFx.menu_yes()
	var input_seed = int(seed_text.text)
	if input_seed != 0 and 1 <= input_seed and input_seed <= 1000000000:
		GameMaster.user_seed = input_seed
	get_tree().change_scene_to_file("res://Scenes/world.tscn")

func _on_quit_button_pressed() -> void:
	SoundFx.menu_no()
	get_tree().quit()

func _on_option_button_pressed():
	SoundFx.menu_yes()
	get_tree().change_scene_to_file("res://Scenes/Menus/options.tscn")
