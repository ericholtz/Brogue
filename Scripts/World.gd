extends Node2D

var turnCounter = 0;
#var player = $Player

# Called when the node enters the scene tree for the first time.
func _ready():
	var player_node = preload("res://Scenes/Player.tscn").instantiate()
	add_child(player_node)
	
	var name_box_node = preload("res://Scenes/TextBox.tscn").instantiate()
	add_child(name_box_node)
	
	var level_node = preload("res://Scenes/map_gen.tscn").instantiate()
	add_child(level_node)
	

#function to take a turn, should basically wait for the player signal then handle all the enemies
#made it take any value in case we want faster enemies or slower player debuffs
func takeTurn(turnsTaken: int):
	#if not GameMaster.can_move:
		#return
	print("Starting player turn")
	turnCounter += turnsTaken
	print("Current turn: ",turnCounter);
	#apply over-time effects, increment timers, whatever is appropriate here
	print("Ending player turn")
	enemyTurn()

#player and enemy turns are separated out so the player always gets priority over the enemies (unless debuffs change that)
func enemyTurn():
	print("Starting enemy turn")
	#handle enemy signals here
	print("Ending enemy turn")

func _on_player_input_event():
	takeTurn(1);
