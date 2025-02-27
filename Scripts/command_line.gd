extends CanvasLayer


@onready var history_label = $Control/MarginContainer/VBoxContainer/RichTextLabel
@onready var input_field = $Control/MarginContainer/VBoxContainer/LineEdit
var command_history = []

func _ready():
	input_field.connect("text_submitted", Callable(self, "_on_command_entered"))
	visible = false  # Start hidden

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F1:  # Toggle console visibility
			visible = !visible
			GameMaster.can_move = !GameMaster.can_move
			if visible:
				input_field.grab_focus()

func _on_command_entered(command):
	command = command.strip_edges()
	var words = command.split(" ", false)
	if words.size() == 0 or words[0] == "":
		return
	
	if words.size() > 3:
		
		command_history.append("> " + command)
		command_history.append("Unknown command: Too many arguments")
	elif words.size() == 3 and not words[2].is_valid_int():
		command_history.append("> " + command)
		command_history.append("Unknown command: Third argument must be an integer")
	
	else:
		var cmd = words[0]
		var option = words[1] if words.size() >= 2 else ""
		var num = int(words[2]) if words.size() == 3 else -1
		command_history.append("> " + command)
		process_command(cmd, option, num)
	update_history()
	input_field.text = ""

func update_history():
	history_label.clear()
	for cmd in command_history:
		history_label.append_text(cmd + "\n")

func process_command(command, option = "", num = ""):
	match command:
		"help":
			command_history.append("Available commands: help, clear, kill, noclip, godmode, fog, position, spawn <entity> <num>")
		"clear":
			command_history.clear()
		"kill":
			visible = false
			$"../Player".end_game()
		"noclip":
			$"../Player".no_clip()
			command_history.append("No Clip set: " + str($"../Player".noclip_enabled))
		"godmode":
			$"../Player".god_mode()
			command_history.append("God mode set: " + str($"../Player".godmode_enabled))
		"spawn":
			if option != "":
				if num != -1:
					command_history.append("Attempting Spawn of " + option + " in room " + str($"../Player".global_position.floor()))
					$"../map_gen".force_spawn($"../Player".global_position, option, num)
		"fog":
			GameMaster.DISABLE_FOG = !GameMaster.DISABLE_FOG
			command_history.append("Dissable Fog " + str(GameMaster.DISABLE_FOG))
		"position":
			var cur_room = ($"../Player".global_position) / 272
			print(cur_room)
			print(cur_room.floor())
		"combatlogs":
			GameMaster.DEBUG_COMBATLOGS = !GameMaster.DEBUG_COMBATLOGS
			if GameMaster.DEBUG_COMBATLOGS == true:
				command_history.append("Verbose combat logs enabled.")
			else:
				command_history.append("Verbose combat logs disabled.")
		_:
			command_history.append("Unknown command: " + command)
