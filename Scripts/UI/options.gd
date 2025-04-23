extends Control


func _on_back_pressed():
	SoundFx.menu_no()
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")

func _on_window_size_item_selected(index):
	if index == 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	elif index == 1:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	elif index == 2:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
