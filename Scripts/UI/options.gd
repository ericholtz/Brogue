extends Control


func _on_back_pressed():
	SoundFx.menu_no()
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")
