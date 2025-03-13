extends GutTest

#This is a BLACK-BOX unit test of the calculate_hit_chance(attack, defense) function in GameMaster.

#load the relevant script and make a null object to hold it
var GM = load('res://Core/GameMaster.gd')
var gm = null

#before each test, refresh obj
func before_each():
	gm = GM.new()

#after each test, free obj
func after_each():
	autofree(gm)

#tests begin here
func test_even():
	var hc = gm.calculate_hit_chance(1,1)
	assert_eq(hc, 0.9, "Expected 0.9, got <"+str(hc)+">")

func test_more_atk():
	var hc = gm.calculate_hit_chance(1,0)
	assert_eq(hc, 0.9, "Expected 0.9, got <"+str(hc)+">")

func test_more_def():
	var hc = gm.calculate_hit_chance(0,1)
	assert_eq(hc, 0.8, "Expected 0.8, got <"+str(hc)+">")

func test_negative_attack():
	var hc = gm.calculate_hit_chance(-1,1)
	assert_eq(hc, 0.7, "Expected 0.7, got <"+str(hc)+">")

func test_negative_defense():
	var hc = gm.calculate_hit_chance(1,-1)
	assert_eq(hc, 0.9, "Expected 0.9, got <"+str(hc)+">")

func test_significant_attack():
	var hc = gm.calculate_hit_chance(5,0)
	assert_eq(hc, 0.9, "Expected 0.9, got <"+str(hc)+">")

func test_significant_defense():
	var hc = gm.calculate_hit_chance(0,5)
	assert_eq(hc, 0.4, "Expected 0.4, got <"+str(hc)+">")

func test_negative_significant_attack():
	var hc = gm.calculate_hit_chance(-5,5)
	assert_eq(hc, 0.4, "Expected 0.4, got <"+str(hc)+">")

func test_negative_significant_defense():
	var hc = gm.calculate_hit_chance(5,-5)
	assert_eq(hc, 0.9, "Expected 0.9, got <"+str(hc)+">")
