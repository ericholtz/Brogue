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
	if command.strip_edges() != "":
		command_history.append("> " + command)
		process_command(command)
		update_history()
	input_field.text = ""

func update_history():
	history_label.clear()
	for cmd in command_history:
		history_label.append_text(cmd + "\n")

func process_command(command):
	match command:
		"help":
			command_history.append("Available commands: help, clear")
		"clear":
			command_history.clear()
		"kill":
			$"../Player".end_game()
		"noclip":
			$"../Player".end_game()
		_:
			command_history.append("Unknown command: " + command)
