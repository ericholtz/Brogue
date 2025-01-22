extends Node2D

var turnCounter = 0;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#function to take a turn, should basically wait for the player signal then handle all the enemies
#made it take any value in case we want faster enemies or slower player debuffs
func takeTurn(turnsTaken: int):
	turnCounter += turnsTaken
	print("Current turn: ",turnCounter);

func _on_player_input_event():
	takeTurn(1);
