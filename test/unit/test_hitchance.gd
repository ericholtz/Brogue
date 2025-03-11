extends GutTest

#This is a BLACK-BOX unit test of the calculate_hit_chance(attack, defense) function in GameMaster.

#load the relevant script and make a null object to hold it
var Obj = load('res://Core/GameMaster.gd')
var _obj = null

#before each test, refresh obj
func before_each():
	_obj = Obj.new()

#after each test, free obj
func after_each():
	autofree(_obj)

#tests begin here
func test_even():
	assert_eq(_obj.calculate_hit_chance(1,1), 0.9)

func test_more_atk():
	assert_eq(_obj.calculate_hit_chance(1,0), 0.9)

func test_more_def():
	assert_eq(_obj.calculate_hit_chance(0,1), 0.8)

func test_negative_attack():
	assert_eq(_obj.calculate_hit_chance(-1,1), 0.7)

func test_negative_defense():
	assert_eq(_obj.calculate_hit_chance(1,-1), 0.9)

func test_significant_attack():
	assert_eq(_obj.calculate_hit_chance(5,0), 0.9)

func test_significant_defense():
	assert_eq(_obj.calculate_hit_chance(0,5), 0.4)

func test_negative_significant_attack():
	assert_eq(_obj.calculate_hit_chance(-5,5), 0.4)

func test_negative_significant_defense():
	assert_eq(_obj.calculate_hit_chance(5,-5), 0.9)
