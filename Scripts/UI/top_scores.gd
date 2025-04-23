extends Control

@onready var scores_label = $TextureRect/ScoresLabel
@onready var back_button = $BackButton

func _ready():
	load_top_scores()
	back_button.connect("pressed", Callable(self, "_on_back_pressed"))

func load_top_scores():
	var save_path = "user://top_scores.json"
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var raw_text = file.get_as_text()
		file.close()
		
		var scores = JSON.parse_string(raw_text)
		if scores:
			var display_text = ""
			for i in range(scores.size()):
				var entry = scores[i]
				display_text += str(i+1) + ". " + entry["name"] + ": " + str(entry["score"]) + "\n"
			scores_label.text = display_text
		else:
			scores_label.text = "No scores yet!"
	else:
		scores_label.text = "No scores file found."

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")
