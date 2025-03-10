extends GutTest

#This is a BLACK-BOX unit test of the calculate_hit_chance(attack, defense) function in GameMaster.

var Obj = load('res://Core/GameMaster.gd')
var _obj = null

func before_each():
	_obj = Obj.new()

func after_each():
	autofree(_obj)

func test_more_atk():
	assert_eq(_obj.calculate_hit_chance(1,0), 0.9)

func test_more_def():
	assert_eq(_obj.calculate_hit_chance(0,1), 0.8)

func test_even():
	assert_eq(_obj.calculate_hit_chance(1,1), 0.9)

func test_negative_attack():
	assert_eq(_obj.calculate_hit_chance(-1,1), 0.7)

func test_negative_defense():
	assert_eq(_obj.calculate_hit_chance(1,-1), 0.9)

func test_negative_significant_attack():
	assert_eq(_obj.calculate_hit_chance(-5,5), 0.5)
