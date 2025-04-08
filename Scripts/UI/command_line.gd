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
	
	if words.size() > 4:
		command_history.append("> " + command)
		command_history.append("Unknown command: Too many arguments")

	elif words.size() == 4 and (not words[2].is_valid_int() or not words[3].is_valid_int()):
		command_history.append("> " + command)
		command_history.append("Unknown command: Third and fourth argument must be integers")
	
	else:
		var cmd = words[0]
		var option = words[1] if words.size() >= 2 else ""
		var num = int(words[2]) if words.size() >= 3 else -1
		var count = int(words[3]) if words.size() == 4 else 1
		command_history.append("> " + command)
		process_command(cmd, option, num, count)
	update_history()
	input_field.text = ""

func update_history():
	history_label.clear()
	for cmd in command_history:
		history_label.append_text(cmd + "\n")

func process_command(command, option = "", num = "", count = ""):
	match command:
		"help":
			command_history.append("======================== AVAILABLE COMMANDS ========================")
			command_history.append("  help - show available commands")
			command_history.append("  clear - clear console scrollback")
			command_history.append("  kill - kill player")
			command_history.append("  noclip - toggle player collision")
			command_history.append("  godmode - toggle player damage")
			command_history.append("  fog - toggle fog")
			command_history.append("  postion - print player position")
			command_history.append("  logs - show logs")
			command_history.append("  spawn <entity group> <index> [count] - spawn a number of entities")
			command_history.append("    entity groups:")
			command_history.append("      melee_weapon    0-3")
			command_history.append("      armor           0-1")
			command_history.append("      potion          0-4")
			command_history.append("      scroll          0")
			command_history.append("      misc            0")
			command_history.append("      key             0-1")
			command_history.append("      cave_enemy      0-2")
			command_history.append("      ice_enemy       0-1")
			command_history.append("      big_ice_enemy   0-1")
			command_history.append("      rare_ice_enemy  0")
			command_history.append("      boss_enemy      0")
			command_history.append("      gold            0-2")
			command_history.append("      exit            0")
			command_history.append("  nextlevel <count> - immediately descend <count> levels forward")
			command_history.append("  zoom <level> - change the camera zoom level to <level> (1-5)")
			command_history.append("  zoom_raw <value> - set the zoom level to the exact raw <value>")
			command_history.append("  identify - identify the stats of all items currently in inventory")
			command_history.append("====================================================================")
			command_history.append("")
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
		"fog":
			GameMaster.DISABLE_FOG = !GameMaster.DISABLE_FOG
			command_history.append("Disable Fog " + str(GameMaster.DISABLE_FOG))
		"position":
			var cur_room = ($"../Player".global_position) / 272
			print(cur_room)
			print(cur_room.floor())
		"logs":
			GameMaster.DEBUG_COMBATLOGS = !GameMaster.DEBUG_COMBATLOGS
			if GameMaster.DEBUG_COMBATLOGS == true:
				command_history.append("Verbose combat logs enabled.")
			else:
				command_history.append("Verbose combat logs disabled.")
		"spawn":
			if option == "": return
			if num == -1: return
			for i in range(0, count):
				command_history.append("Attempting Spawn of " + option + " in room " + str($"../Player".global_position.floor()))
				$"../map_gen".force_spawn($"../Player".global_position, option, num)
		"nextlevel":
			option = int(option) if option != "" else 1
			for i in range(0, option):
				$"../map_gen".regenerate_map()
			command_history.append("Moved forward " + str(option) + " levels")
		"zoom":
			if option == "": return
			option = float(option)
			$"../Player".zoom(option)
			command_history.append("Set zoom level to " + str(option))
		"zoom_raw":
			if option == "": return
			option = float(option)
			$"../Player".zoom(option)
			command_history.append("Set zoom value to " + str(option))
		"identify":
			$"../Player".identify_all()
			command_history.append("Identified all items in inventory")
		_:
			command_history.append("Unknown command: " + command)
