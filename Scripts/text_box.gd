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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_text_submit"):
		if p_name.text:
			text_box_container.hide()
			#load("res://Scenes/world.tscn")
			Engine.time_scale = 1
			$"../UIManager".visible=true
			
			GameMaster.setname(p_name.text)
			#print(p_name.text)
			#get_tree().change_scene_to_file("res://Scenes/world.tscn")
		else:
			print("NO TEXT")
	pass
