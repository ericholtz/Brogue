extends GutTest

const MAP_GEN_PATH = "res://Scenes/map_gen.tscn"

var map_gen
var player
var mock_cmd_line

func before_each():
	# Load and initialize map_gen before each test
	map_gen = load(MAP_GEN_PATH).instantiate()
	add_child(map_gen)
	# Create and add mock CommandLine node to map_gen
	mock_cmd_line = load("res://Scenes/Menus/command_line.tscn").instantiate()
	add_child(mock_cmd_line)  # Add the mock as a child to map_gen


func after_each():
	# Cleanup after each test
	autofree(map_gen)
	autofree(mock_cmd_line)


# White Box Condition coverage 
# Test force_spawn() to ensure it correctly places an enemy
func test_force_spawn():
	# Create mock for CommandLine
	var room = load("res://Scenes/Rooms/room.tscn").instantiate()
	var bad_room = load("res://Scenes/Rooms/hallway.tscn").instantiate()
	var player_pos_good = Vector2(0,0)
	var player_pos_bad = Vector2(-1,-1)
	map_gen.vec_map[player_pos_good] = room
	map_gen.vec_map[player_pos_bad] = bad_room

	# check cmd history is nothing
	assert_false(mock_cmd_line.command_history.size() > 0, "Command history should have no entries")
	# entity good, option good, room good
	assert_true(map_gen.force_spawn(player_pos_good, "potion", 0) == true, "Valid room, valid entity, valid option")
	# entity good, option good, room bad
	assert_true(map_gen.force_spawn(player_pos_bad, "potion", 0) == false, "Bad room, valid entity, valid option")
	# entity good, option bad
	assert_true(map_gen.force_spawn(player_pos_good, "potion", 5) == false, "valid entity, bad option")
	# entity bad 
	assert_true(map_gen.force_spawn(player_pos_good, "null", 0) == false, "Bad entity")
	

# Black Box test
# Test the get_distance() function
func test_get_distance():
	# Test 1: Simple distance where x and y differ by 1
	var start_pos_1 = Vector2(0, 0)
	var target_pos_1 = Vector2(1, 1)
	var expected_result_1 = 2  # abs(0-1) + abs(0-1) = 2
	assert_true(map_gen.get_distance(start_pos_1, target_pos_1) == expected_result_1, "Expected distance between (0, 0) and (1, 1) is 2")

	# Test 2: Same positions (distance should be 0)
	var start_pos_2 = Vector2(3, 4)
	var target_pos_2 = Vector2(3, 4)
	var expected_result_2 = 0  # abs(3-3) + abs(4-4) = 0
	assert_true(map_gen.get_distance(start_pos_2, target_pos_2) == expected_result_2, "Expected distance between (3, 4) and (3, 4) is 0")

	# Test 3: Horizontal distance (y remains the same)
	var start_pos_3 = Vector2(5, 0)
	var target_pos_3 = Vector2(10, 0)
	var expected_result_3 = 5  # abs(5-10) + abs(0-0) = 5
	assert_true(map_gen.get_distance(start_pos_3, target_pos_3) == expected_result_3, "Expected distance between (5, 0) and (10, 0) is 5")

	# Test 4: Vertical distance (x remains the same)
	var start_pos_4 = Vector2(0, 2)
	var target_pos_4 = Vector2(0, 7)
	var expected_result_4 = 5  # abs(0-0) + abs(2-7) = 5
	assert_true(map_gen.get_distance(start_pos_4, target_pos_4) == expected_result_4, "Expected distance between (0, 2) and (0, 7) is 5")

	# Test 5: Large distance diagonally
	var start_pos_5 = Vector2(10, 10)
	var target_pos_5 = Vector2(20, 25)
	var expected_result_5 = 25  # abs(10-20) + abs(10-25) = 10 + 15 = 25
	assert_true(map_gen.get_distance(start_pos_5, target_pos_5) == expected_result_5, "Expected distance between (10, 10) and (20, 25) is 15")

# integration test of rooms and exit door
# test add_exit_to_last_room() function
func test_add_exit_to_last_room():
	var room = load("res://Scenes/Rooms/room.tscn").instantiate()
	var large_hor_room = load("res://Scenes/Rooms/largeroomHor.tscn").instantiate()
	var large_ver_room = load("res://Scenes/Rooms/largeroomVert.tscn").instantiate()
	
	# test room being last room
	map_gen.last_room = room
	assert_true(map_gen.add_exit_to_last_room() == true, "Valid room")
	# test large room being last room
	map_gen.last_room = large_hor_room
	assert_true(map_gen.add_exit_to_last_room() == true, "Valid large horizontal room")
	# test large room being last room
	map_gen.last_room = large_ver_room
	assert_true(map_gen.add_exit_to_last_room() == true, "Valid large vertical room")
	# test last room being null
	map_gen.last_room = null
	assert_true(map_gen.add_exit_to_last_room() == false, "no valid last room")
