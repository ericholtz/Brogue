extends Node

func small_coin():
	var coins = [$coin1, $coin2, $coin3, $coin4, $coin5]
	var sound = coins.pick_random()
	sound.play()

func large_coin():
	var coins = [$manycoins1, $manycoins2]
	var sound = coins.pick_random()
	sound.play()

func attack():
	var whoosh = [$swing1, $swing2]
	var sound = whoosh.pick_random()
	sound.play()

func footstep():
	var steps = [$footstep1, $footstep2, $footstep3, $footstep4, $footstep5]
	var sound = steps.pick_random()
	sound.play()

func level_up():
	$levelup.play()

func heal():
	$heal.play()

func buff():
	$good.play()

func debuff():
	$bad.play()

func death():
	$death.play()

func stairs():
	$nextfloor.play()

func menu_yes():
	$click5.play()
	
func menu_no():
	$click3.play()

func inventory_click():
	$click1.play()

func play_menu_music():
	$MusicMainMenu.play()

func play_ambience():
	var ambience = [$MusicAmbience1, $MusicAmbience2, $MusicAmbience3, $MusicAmbience4, $MusicAmbience5, $MusicAmbience6]
	var music = ambience.pick_random()
	music.play()

func play_game_over_music():
	$MusicDeath.play()
