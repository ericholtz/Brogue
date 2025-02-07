extends Button
func _ready():
	self.pressed.connect(_button_pressed)

func _button_pressed():
	GameMaster.damage_player(1)
