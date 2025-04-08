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
	var clang = [$sword1, $sword2, $sword3, $sword4, $sword5]
	var sound = clang.pick_random()
	sound.play()
	
func miss():
	var whoosh = [$swing1, $swing2]
	var sound = whoosh.pick_random()
	sound.play()

func footstep():
	var steps = [$footstep1, $footstep2, $footstep3, $footstep4, $footstep5]
	var sound = steps.pick_random()
	sound.play()

func item_pickup():
	$pickup.play()

func level_up():
	$levelup.play()

func game_over():
	$gameoversfx.play()

func heal():
	$heal.play()

func buff():
	$good.play()

func debuff():
	$bad.play()

func drop_item():
	$dropitem.play()

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
	if not $MusicMainMenu.playing:
		_stop_all_music()
		$MusicMainMenu.play()

func play_game_over_music():
	_stop_all_music()
	$MusicDeath.play()

func play_ambience():
	_stop_all_music()
	var ambience = [$MusicAmbience1, $MusicAmbience2, $MusicAmbience3, $MusicAmbience4, $MusicAmbience5, $MusicAmbience6]
	var music = ambience.pick_random()
	music.play()
	await music.finished
	play_ambience()

func _stop_all_music():
	$MusicMainMenu.stop()
	$MusicDeath.stop()
	for ambience in [$MusicAmbience1, $MusicAmbience2, $MusicAmbience3, $MusicAmbience4, $MusicAmbience5, $MusicAmbience6]:
		ambience.stop()
