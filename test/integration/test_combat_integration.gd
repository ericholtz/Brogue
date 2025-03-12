extends GutTest

#This is an INTEGRATION test of GameMaster's combat function, using the actual scripts for player and enemy instead of dummy values

#load the relevant scripts and make holders
var GameMaster = load("res://Core/GameMaster.gd")
var gm = null
var Player = load("res://Scripts/Player.gd")
var player = null
var Enemy = load("res://Scripts/Monster_Scripts/Skeleton_Warrior.gd")
var enemy = null

#before each test, instantiate new gm/player/enemy and add to scene tree
func before_each():
	gm = GameMaster.new()
	player = Player.new()
	enemy = Enemy.new()
	
	add_child(gm)
	add_child(player)
	add_child(enemy)

func after_each():
	autofree(gm)
	autofree(player)
	autofree(enemy)
