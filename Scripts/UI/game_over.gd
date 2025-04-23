extends CanvasLayer

@onready var play_again_btn = $VBoxContainer/PlayAgain
@onready var main_menu_btn = $VBoxContainer/MainMenu
@onready var quit_btn = $VBoxContainer/Quit
@onready var player = $"../Player"
@onready var map = $"../map_gen"
@onready var gold = int(player.gold)
@onready var dungeonfloor = int(map.level)
@onready var distance_traveled = int(GameMaster.turnCounter)
@onready var player_level = int(player.level)
@onready var score = int((gold * dungeonfloor * pow(1.2, player_level)) / log(distance_traveled + 10))

func _ready():
	SoundFx.game_over()
	SoundFx.play_game_over_music()
	$VBoxContainer/Label2.visible = true
	$VBoxContainer/Label2.text = "You hoarded " + str(gold) + " gold by floor " + str(dungeonfloor) + ".\n"
	$VBoxContainer/Label2.text += "SCORE: " + str(score)
	if map.bad_death == true:
		$VBoxContainer/Label2.visible = true
		$VBoxContainer/Label2.text = "You tripped down the stairs and died.\n"
		$VBoxContainer/Label2.text += "SCORE: " + str(score)
		$VBoxContainer.rotation_degrees = 2
		$VBoxContainer.set_position(Vector2(515,90))
	if player.player_name.to_lower() == "eric":
		$VBoxContainer/Label2.visible = true
		$VBoxContainer/Label2.text = "You hoarded " + str(gold) + " gold by floor " + str(dungeonfloor) + ", LOSER.\n"
		$VBoxContainer/Label2.text += "SCORE: " + str(0)
	if player.player_name.to_lower() == "alex":
		$VBoxContainer/Label2.visible = true
		$VBoxContainer/Label2.text = "You hoarded " + str(gold) + " gold by floor " + str(dungeonfloor) + ", LOSER.\n"
		$VBoxContainer/Label2.text += "SCORE: " + char(0x1FAF5) + char(0x1F921)#char(0x1F595)
	if player.player_name.to_lower() == "silas":
		$VBoxContainer/Label2.visible = true
		$VBoxContainer/Label2.text = "You hoarded " + str(gold) + " gold by floor " + str(dungeonfloor) + ", LOSRE.\n"
		$VBoxContainer/Label2.text += "SCORE: " + "MabyE -0"
	if player.player_name.to_lower() == "gabe":
		$VBoxContainer/Label2.visible = true
		$VBoxContainer/Label2.text = "You hoarded " + str(gold) + " gold by floor " + str(dungeonfloor) + "\n"
		$VBoxContainer/Label2.text += "SCORE: " + "\u221e"
	play_again_btn.connect("pressed", Callable(self, "_on_play_again"))
	main_menu_btn.connect("pressed", Callable(self, "_on_main_menu"))
	quit_btn.connect("pressed", Callable(self, "_on_quit"))
	save_high_score()

func _on_play_again():
	GameMaster.turnCounter = 0
	SoundFx.menu_yes()
	SoundFx.play_ambience()
	GameMaster._ready()
	get_tree().reload_current_scene()  # Restart the level

func _on_main_menu():
	SoundFx.menu_yes()
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")  # Load main menu

func _on_quit():
	SoundFx.menu_no()
	get_tree().quit()  # Exit the game

func save_high_score():
	var score_entry = {
		"name": player.player_name,
		"score": score,
		"gold": gold,
		"floor": dungeonfloor,
		"distance": distance_traveled,
		"level": player_level
	}

	var save_path = "user://top_scores.json"
	var scores = []

	if FileAccess.file_exists(save_path):
		var file_data = FileAccess.open(save_path, FileAccess.READ)
		var raw_text = file_data.get_as_text()
		file_data.close()
		if raw_text != "":
			scores = JSON.parse_string(raw_text)
			if scores == null:
				scores = []

	scores.append(score_entry)
	scores.sort_custom(func(a, b): return a["score"] > b["score"])
	if scores.size() > 10:
		scores = scores.slice(0, 10)

	var file_out = FileAccess.open(save_path, FileAccess.WRITE)
	file_out.store_string(JSON.stringify(scores, "\t"))
	file_out.close()

func _on_top_scores_pressed() -> void:
	SoundFx.menu_yes()
	get_tree().change_scene_to_file("res://Scenes/Menus/Top_scores.tscn")
