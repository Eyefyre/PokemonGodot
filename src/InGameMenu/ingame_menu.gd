extends CanvasLayer

const pokemon_party_screen = preload("res://src/InGameMenu/PartyScreen.tscn")
const player_stat_screen = preload("res://src/InGameMenu/PlayerStatScreen.tscn")
const options_screen = preload("res://src/InGameMenu/OptionsScreen.tscn")
const save_screen = preload("res://src/InGameMenu/SaveScreen.tscn")
onready var select_arrow = $Control/NinePatchRect/SelectArrow
onready var menu = $Control

enum ScreenLoaded {NOTHING,JUST_MENU,PARTY_SCREEN,PLAYER_STAT_SCREEN,OPTIONS_SCREEN,SAVE_SCREEN}
var screen_loaded = ScreenLoaded.NOTHING


var menu_selection_positions = {0:Vector2(6,14),1:Vector2(6,30),2:Vector2(6,46),3:Vector2(6,62),4:Vector2(6,78),5:Vector2(6,94),6:Vector2(6,110)}
var save_selection_positions = {0:Vector2(8,8),1:Vector2(8,24)}
var options_selection_positions = {0:Vector2(7,18),1:Vector2(7,33),2:Vector2(7,48),3:Vector2(7,64),4:Vector2(7,79),5:Vector2(7,128)}
var selected_option: int = 0
var save_selected_option:int = 0
var option_selection:int = 0

var option_choices = {0:["SLOW","MID","FAST"],1:["ON","OFF"],2:["SHIFT","SET"],3:["MONO","EARPHONE1","EARPHONE2","EARPHONE3"],4:["LIGHTEST","LIGHT","NORMAL","DARK","DARKEST"]}
var text_speed_selection = GlobalVariables.options[0]
var animation_selection = GlobalVariables.options[1]
var battle_style_selection = GlobalVariables.options[2]
var sound_selection = GlobalVariables.options[3]
var print_selection = GlobalVariables.options[4]

func _ready():
	menu.visible = false
	select_arrow.rect_position = menu_selection_positions[selected_option]
	
func load_player_stat_screen():
	menu.visible = false
	screen_loaded = ScreenLoaded.PLAYER_STAT_SCREEN
	var stat_screen = player_stat_screen.instance()
	add_child(stat_screen)
	for x in range(8):
		if GlobalVariables.badges[x]:
			get_node("PlayerStatScreen/Badge" + str(x+1)).texture = load("res://assets/UI/Badge" + str((x+1))+ ".png")
		else:
			get_node("PlayerStatScreen/Badge" + str(x+1)).texture = load("res://assets/UI/GymLeader" + str((x+1))+ "Face.png")
func load_save_screen():
	screen_loaded = ScreenLoaded.SAVE_SCREEN
	var save__screen = save_screen.instance()
	add_child(save__screen)
	
func load_options_screen():
	option_selection = 0
	menu.visible = false
	screen_loaded = ScreenLoaded.OPTIONS_SCREEN
	var option_screen = options_screen.instance()
	add_child(option_screen)
	$OptionsScreen/NinePatchRect/TextSpeed.text = option_choices[0][text_speed_selection]
	$OptionsScreen/NinePatchRect/Animation.text = option_choices[1][animation_selection]
	$OptionsScreen/NinePatchRect/BattleStyle.text = option_choices[2][battle_style_selection]
	$OptionsScreen/NinePatchRect/Sound.text = option_choices[3][sound_selection]
	$OptionsScreen/NinePatchRect/Print.text = option_choices[4][print_selection]

func load_party_screen():
	menu.visible = false
	screen_loaded = ScreenLoaded.PARTY_SCREEN
	var party_screen = pokemon_party_screen.instance()
	add_child(party_screen)
	
func load_main_screen():
	menu.visible = true
	screen_loaded = ScreenLoaded.JUST_MENU
	if is_instance_valid($PlayerStatScreen):
		$PlayerStatScreen.queue_free()
	if is_instance_valid($OptionsScreen):
		$OptionsScreen.queue_free()
	if is_instance_valid($PartyScreen):
		$PartyScreen.queue_free()
	if is_instance_valid($SaveScreen):
		$SaveScreen.queue_free()
	
func _unhandled_input(event):
	if GlobalVariables.is_in_dialogue:
		return
	match screen_loaded:
		ScreenLoaded.NOTHING:
			if event.is_action_pressed("OpenMenu"):
				GlobalVariables.is_in_menu = true
				var player = Utils.get_player()
				if !player.is_moving:
					player.set_physics_process(false)
					menu.visible = true
					screen_loaded = ScreenLoaded.JUST_MENU
		ScreenLoaded.JUST_MENU:
			if event.is_action_pressed("Back") or event.is_action_pressed("OpenMenu"):
				var player = Utils.get_player()
				player.set_physics_process(true)
				menu.visible = false
				screen_loaded = ScreenLoaded.NOTHING
				GlobalVariables.is_in_menu = false
			elif event.is_action_pressed("ui_down"):
				selected_option += 1
				if selected_option > 6:
					selected_option = 0
				select_arrow.rect_position = menu_selection_positions[selected_option]
			elif event.is_action_pressed("ui_up"):
				if selected_option == 0:
					selected_option = 6
				else:
					selected_option -= 1
				select_arrow.rect_position = menu_selection_positions[selected_option]
			elif event.is_action_pressed("Accept"):
				match selected_option:
					1:
						load_party_screen()
					3:
						load_player_stat_screen()
					4:
						load_save_screen()
					5:
						load_options_screen()
					6:
						var player = Utils.get_player()
						player.set_physics_process(true)
						menu.visible = false
						screen_loaded = ScreenLoaded.NOTHING
						selected_option = 0
						select_arrow.rect_position = menu_selection_positions[selected_option]
				
		ScreenLoaded.PARTY_SCREEN:
			if event.is_action_pressed("Back"):
				load_main_screen()
		ScreenLoaded.OPTIONS_SCREEN:
			if event.is_action_pressed("Back"):
				GlobalVariables.options = [text_speed_selection,animation_selection,battle_style_selection,sound_selection,print_selection]
				load_main_screen()
			elif event.is_action_pressed("ui_down"):
				option_selection += 1
				if option_selection > 5:
					option_selection = 0
				$OptionsScreen/NinePatchRect/Selector.rect_position = options_selection_positions[option_selection]
			elif event.is_action_pressed("ui_up"):
				option_selection -= 1
				if option_selection < 0:
					option_selection = 5
				$OptionsScreen/NinePatchRect/Selector.rect_position = options_selection_positions[option_selection]
			elif event.is_action_pressed("ui_left"):
				match option_selection:
					0:
						text_speed_selection -= 1
						if text_speed_selection < 0:
							text_speed_selection = len(option_choices[0])-1
						$OptionsScreen/NinePatchRect/TextSpeed.text = option_choices[0][text_speed_selection]
					1:
						animation_selection -= 1
						if animation_selection < 0:
							animation_selection = len(option_choices[1])-1
						$OptionsScreen/NinePatchRect/Animation.text = option_choices[1][animation_selection]
					2:
						battle_style_selection -= 1
						if battle_style_selection < 0:
							battle_style_selection = len(option_choices[2])-1
						$OptionsScreen/NinePatchRect/BattleStyle.text = option_choices[2][battle_style_selection]
					3:
						sound_selection -= 1
						if sound_selection < 0:
							sound_selection = len(option_choices[3])-1
						$OptionsScreen/NinePatchRect/Sound.text = option_choices[3][sound_selection]
					4:
						print_selection -= 1
						if print_selection < 0:
							print_selection = len(option_choices[4])-1
						$OptionsScreen/NinePatchRect/Print.text = option_choices[4][print_selection]
			elif event.is_action_pressed("ui_right"):
				match option_selection:
					0:
						text_speed_selection += 1
						if text_speed_selection > len(option_choices[0])-1:
							text_speed_selection = 0
						$OptionsScreen/NinePatchRect/TextSpeed.text = option_choices[0][text_speed_selection]
					1:
						animation_selection += 1
						if animation_selection > len(option_choices[1])-1:
							animation_selection = 0
						$OptionsScreen/NinePatchRect/Animation.text = option_choices[1][animation_selection]
					2:
						battle_style_selection += 1
						if battle_style_selection > len(option_choices[2])-1:
							battle_style_selection = 0
						$OptionsScreen/NinePatchRect/BattleStyle.text = option_choices[2][battle_style_selection]
					3:
						sound_selection += 1
						if sound_selection > len(option_choices[3])-1:
							sound_selection = 0
						$OptionsScreen/NinePatchRect/Sound.text = option_choices[3][sound_selection]
					4:
						print_selection += 1
						if print_selection > len(option_choices[4])-1:
							print_selection = 0
						$OptionsScreen/NinePatchRect/Print.text = option_choices[4][print_selection]
			elif event.is_action_pressed("Accept"):
				match option_selection:
					5:
						GlobalVariables.options = [text_speed_selection,animation_selection,battle_style_selection,sound_selection,print_selection]
						load_main_screen()
		ScreenLoaded.PLAYER_STAT_SCREEN:
			if event.is_action_pressed("Back") or event.is_action_pressed("Accept"):
				load_main_screen()
		ScreenLoaded.SAVE_SCREEN:	
			if event.is_action_pressed("Back"):
				load_main_screen()
			elif event.is_action_pressed("ui_down"):
				save_selected_option += 1
				if save_selected_option > 1:
					save_selected_option = 1
				$SaveScreen/NinePatchRect3/TextureRect.rect_position = save_selection_positions[save_selected_option]
			elif event.is_action_pressed("ui_up"):
				save_selected_option -= 1
				if save_selected_option < 0:
					save_selected_option = 0
				$SaveScreen/NinePatchRect3/TextureRect.rect_position = save_selection_positions[save_selected_option]
			elif event.is_action_pressed("Accept"):
				match save_selected_option:
					0:
						GlobalVariables.save_game()
						load_main_screen()
					1:
						load_main_screen()
				
