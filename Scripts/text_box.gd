extends CanvasLayer

@onready var text_box_container = $TextBoxContainer

@onready var p_name = $TextBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/LineEdit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.time_scale = 0
	$"../UIManager".visible=false
	pass


func _hide_text_box(_unused_arg = null):
	hide()


func _on_line_edit_text_submitted(_new_text: String) -> void:
	if Input.is_action_just_pressed("ui_text_submit"):
		if p_name.text:
			text_box_container.hide()
			#load("res://Scenes/world.tscn")
			Engine.time_scale = 1
			$"../UIManager".visible=true
			
			GameMaster.setname(p_name.text)
		else:
			print("NO TEXT")
	pass
