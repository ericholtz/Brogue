extends GutTest

#This is a WHITE-BOX test of GameMaster's signal functions. This covers every function that sends a signal to another script
#and ensures that the signal is actually sent by our game logic with the correct value.

#load the relevant script and make a holder for it
var GameMaster = load("res://Core/GameMaster.gd")
var gm = null

#stub entity to project a gold value on so we can call collect_item
class DummyEntity:
	extends Area2D
	var entityType: int = 0
	var gold_worth: int = 0
var entity = null

#before each test, make new gm, set debug logs to false, and watch signals
func before_each():
	gm = GameMaster.new()
	entity = DummyEntity.new()
	add_child(gm)
	watch_signals(gm)
	gm.DEBUG_COMBATLOGS = false

#free after each test
func after_each():
	autofree(gm)
	autofree(entity)

#tests begin here
#test that gold signal works by setting entity to a value and running collect on it
func test_gained_gold_signal():
	entity.entityType = gm.EntityType.GOLD
	entity.gold_worth = 1
	gm.collect_entity(entity)
	#this method autogenerates a failure message, so the third argument is an array of expected params to go with the signal
	assert_signal_emitted_with_parameters(gm, "gained_gold", [1])

#test that item signal works by setting entity to an ITEM type and running collect on it
func test_gained_item_signal():
	entity.entityType = gm.EntityType.ITEM
	gm.collect_entity(entity)
	assert_signal_emitted_with_parameters(gm, "gained_item", [entity])

#test that calling setname emits a signal
func test_set_name_signal():
	gm.setname("testname")
	assert_signal_emitted_with_parameters(gm, "set_name", ["testname"])

#test that taking a turn emits a signal
func test_took_turns_signal():
	gm.can_move = true
	gm.takeTurn(1)
	assert_signal_emitted_with_parameters(gm, "took_turns", [1])

#test that damage_player emits a signal with the correct value
func test_damage_player_signal():
	gm.damage_player(1)
	assert_signal_emitted_with_parameters(gm, "damage_player_signal", [1])

#test that healing the player emits a signal with the correct value
func test_heal_player_signal():
	gm.heal_player(1)
	assert_signal_emitted_with_parameters(gm, "heal_player_signal", [1])

#test that moving when the flag is set to false does NOT emit a signal
func test_take_turn_when_cannot_move():
	gm.can_move = false
	gm.takeTurn(1)
	assert_signal_not_emitted(gm, "took_turns", "Signal took_turns fired on an invalid move")

#test collecting an invalid item
func test_collect_invalid_entity():
	entity = null
	gm.collect_entity(entity)
	assert_signal_not_emitted(gm, "gained_gold", "Signal gained_gold fired on an invalid or null entity")
	assert_signal_not_emitted(gm, "gained_item", "Signal gained_item fired on an invalid or null entity")

#test submitting an empty name
func test_empty_name():
	gm.setname("")
	assert_signal_not_emitted(gm, "set_name", "Signal set_name fired on an invalid name")
