extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	GameMaster.gained_gold.connect(update_gold_display)
	GameMaster.damage_player_signal.connect(update_health_display)
	GameMaster.heal_player_signal.connect(update_health_display)
	GameMaster.took_turns.connect(update_turn_counter)

#public function that can connect to a signal
func update_gold_display(_gained_gold):
	# Defer the update so it runs after the player data actually updates
	call_deferred("_update_gold_text")

#private function called solely to update the ui text
func _update_gold_text():
	$GoldDisplay.text = str($"../Player".gold)

#ditto the above for health
func update_health_display(_adjust_health):
	call_deferred("_update_health_text")

func _update_health_text():
	$HealthDisplay.text = str($"../Player".health)

func update_turn_counter(_turns):
	call_deferred("_update_turns_text")

func _update_turns_text():
	$TurnCounter.text = "Turn <" + str(GameMaster.turnCounter) + ">"
