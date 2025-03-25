extends CanvasLayer

@onready var play_again_btn = $VBoxContainer/PlayAgain
@onready var main_menu_btn = $VBoxContainer/MainMenu
@onready var quit_btn = $VBoxContainer/Quit
@onready var player = $"../Player"

func _ready():
	if player.player_name.to_lower() == "eric":
		$VBoxContainer/Label2.visible = true
		$VBoxContainer/Label2.text = "LOSER"
	if player.player_name.to_lower() == "silas":
		$VBoxContainer/Label2.visible = true
		$VBoxContainer/Label2.text = "LOSRE"
	play_again_btn.connect("pressed", Callable(self, "_on_play_again"))
	main_menu_btn.connect("pressed", Callable(self, "_on_main_menu"))
	quit_btn.connect("pressed", Callable(self, "_on_quit"))

func _on_play_again():
	get_tree().reload_current_scene()  # Restart the level

func _on_main_menu():
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")  # Load main menu

func _on_quit():
	get_tree().quit()  # Exit the game
