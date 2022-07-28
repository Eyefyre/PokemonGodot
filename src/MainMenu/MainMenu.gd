extends CanvasLayer


enum ScreenLoaded {TITLE,MAIN_NO_SAVE,MAIN_SAVE,OPTION,CONTINUE}
var screen_loaded = ScreenLoaded.TITLE

const options_screen = preload("res://src/InGameMenu/OptionsScreen.tscn")

var options_selection_positions = {0:Vector2(7,18),1:Vector2(7,33),2:Vector2(7,48),3:Vector2(7,64),4:Vector2(7,79),5:Vector2(7,128)}
var no_save_selection_positions = {0:Vector2(7,14),1:Vector2(7,30)}
var save_selection_positions = {0:Vector2(7,17),1:Vector2(6,33),2:Vector2(6,48)}
var no_save_selected_option: int = 0
var save_selected_option: int = 0
var option_selection:int = 0

var option_choices = {0:["SLOW","MID","FAST"],1:["ON","OFF"],2:["SHIFT","SET"],3:["MONO","EARPHONE1","EARPHONE2","EARPHONE3"],4:["LIGHTEST","LIGHT","NORMAL","DARK","DARKEST"]}
var text_speed_selection = 0
var animation_selection = 0
var battle_style_selection = 0
var sound_selection = 0
var print_selection = 0

func _ready():
	#GlobalVariables.load_game()
	text_speed_selection = GlobalVariables.options[0]
	animation_selection = GlobalVariables.options[1]
	battle_style_selection = GlobalVariables.options[2]
	sound_selection = GlobalVariables.options[3]
	print_selection = GlobalVariables.options[4]

func load_main_screen():
	if GlobalVariables.does_save_exist():
		screen_loaded = ScreenLoaded.MAIN_SAVE
		$Control/WithSaveFile.visible = true
		$Control/WithoutSaveFile.visible = false
	else:
		screen_loaded = ScreenLoaded.MAIN_NO_SAVE
		$Control/WithSaveFile.visible = false
		$Control/WithoutSaveFile.visible = true
	if is_instance_valid($Control/OptionsScreen):
		$Control/OptionsScreen.queue_free()
		
func load_options_screen():
	option_selection = 0
	screen_loaded = ScreenLoaded.OPTION
	var option_screen = options_screen.instance()
	$Control.add_child(option_screen)
	$Control/OptionsScreen/NinePatchRect/TextSpeed.text = option_choices[0][text_speed_selection]
	$Control/OptionsScreen/NinePatchRect/Animation.text = option_choices[1][animation_selection]
	$Control/OptionsScreen/NinePatchRect/BattleStyle.text = option_choices[2][battle_style_selection]
	$Control/OptionsScreen/NinePatchRect/Sound.text = option_choices[3][sound_selection]
	$Control/OptionsScreen/NinePatchRect/Print.text = option_choices[4][print_selection]		
		
func new_game():
	Utils.get_scene_manager().transition_from_main("res://src/Locations/PalletTown/PlayerHouse2F.tscn",Vector2(48,96),Vector2(0,-1))
	
func load_game():
	GlobalVariables.load_game()
	Utils.get_scene_manager().transition_from_main(GlobalVariables.current_scene,GlobalVariables.player_position,GlobalVariables.player_facing_direction)
		
func _unhandled_input(event):
	match screen_loaded:
		ScreenLoaded.TITLE:
			if event.is_action_pressed("Accept") or event.is_action_pressed("OpenMenu"):
				$Control/TitleScreen.visible = false
				load_main_screen()
		ScreenLoaded.MAIN_SAVE:
			if event.is_action_pressed("Back"):
				$Control/TitleScreen.visible = true
				screen_loaded = ScreenLoaded.TITLE
			elif event.is_action_pressed("ui_down"):
				save_selected_option += 1
				if save_selected_option > 2:
					save_selected_option = 2
				$Control/WithSaveFile/Selector.rect_position = save_selection_positions[save_selected_option]
			elif event.is_action_pressed("ui_up"):
				save_selected_option -= 1
				if save_selected_option < 0:
					save_selected_option = 0
				$Control/WithSaveFile/Selector.rect_position = save_selection_positions[save_selected_option]
			elif event.is_action_pressed("Accept"):
				match save_selected_option:
					0:
						$Control/WithSaveFile/SaveFileInfo/Player.bbcode_text = "[right]"+GlobalVariables.player_name+"[/right]"
						$Control/WithSaveFile/SaveFileInfo/Badges.bbcode_text = "[right]"+str(GlobalVariables.badges.count(true))+"[/right]"
						$Control/WithSaveFile/SaveFileInfo/Pokedex.bbcode_text = "[right]"+str(GlobalVariables.pokedex)+"[/right]"
						$Control/WithSaveFile/SaveFileInfo/Time.bbcode_text = "[right]"+str(GlobalVariables.in_game_time)+"[/right]"
						$Control/WithSaveFile/SaveFileInfo.visible = true
						screen_loaded = ScreenLoaded.CONTINUE
					1:
						new_game()
					2:
						pass
						#load_options_screen()
		
		ScreenLoaded.MAIN_NO_SAVE:
			if event.is_action_pressed("Back"):
				$Control/TitleScreen.visible = true
				screen_loaded = ScreenLoaded.TITLE
			elif event.is_action_pressed("ui_down"):
				no_save_selected_option += 1
				if no_save_selected_option > 1:
					no_save_selected_option = 1
				$Control/WithoutSaveFile/Selector.rect_position = no_save_selection_positions[no_save_selected_option]
			elif event.is_action_pressed("ui_up"):
				no_save_selected_option -= 1
				if no_save_selected_option < 0:
					no_save_selected_option = 0
				$Control/WithoutSaveFile/Selector.rect_position = no_save_selection_positions[no_save_selected_option]
			elif event.is_action_pressed("Accept"):
				match no_save_selected_option:
					0:
						new_game()
					1:
						load_options_screen()
		ScreenLoaded.OPTION:
			if event.is_action_pressed("Back"):
				GlobalVariables.options = [text_speed_selection,animation_selection,battle_style_selection,sound_selection,print_selection]
				load_main_screen()
			elif event.is_action_pressed("ui_down"):
				option_selection += 1
				if option_selection > 5:
					option_selection = 0
				$Control/OptionsScreen/NinePatchRect/Selector.rect_position = options_selection_positions[option_selection]
			elif event.is_action_pressed("ui_up"):
				option_selection -= 1
				if option_selection < 0:
					option_selection = 5
				$Control/OptionsScreen/NinePatchRect/Selector.rect_position = options_selection_positions[option_selection]
			elif event.is_action_pressed("ui_left"):
				match option_selection:
					0:
						text_speed_selection -= 1
						if text_speed_selection < 0:
							text_speed_selection = len(option_choices[0])-1
						$Control/OptionsScreen/NinePatchRect/TextSpeed.text = option_choices[0][text_speed_selection]
					1:
						animation_selection -= 1
						if animation_selection < 0:
							animation_selection = len(option_choices[1])-1
						$Control/OptionsScreen/NinePatchRect/Animation.text = option_choices[1][animation_selection]
					2:
						battle_style_selection -= 1
						if battle_style_selection < 0:
							battle_style_selection = len(option_choices[2])-1
						$Control/OptionsScreen/NinePatchRect/BattleStyle.text = option_choices[2][battle_style_selection]
					3:
						sound_selection -= 1
						if sound_selection < 0:
							sound_selection = len(option_choices[3])-1
						$Control/OptionsScreen/NinePatchRect/Sound.text = option_choices[3][sound_selection]
					4:
						print_selection -= 1
						if print_selection < 0:
							print_selection = len(option_choices[4])-1
						$Control/OptionsScreen/NinePatchRect/Print.text = option_choices[4][print_selection]
			elif event.is_action_pressed("ui_right"):
				match option_selection:
					0:
						text_speed_selection += 1
						if text_speed_selection > len(option_choices[0])-1:
							text_speed_selection = 0
						$Control/OptionsScreen/NinePatchRect/TextSpeed.text = option_choices[0][text_speed_selection]
					1:
						animation_selection += 1
						if animation_selection > len(option_choices[1])-1:
							animation_selection = 0
						$Control/OptionsScreen/NinePatchRect/Animation.text = option_choices[1][animation_selection]
					2:
						battle_style_selection += 1
						if battle_style_selection > len(option_choices[2])-1:
							battle_style_selection = 0
						$Control/OptionsScreen/NinePatchRect/BattleStyle.text = option_choices[2][battle_style_selection]
					3:
						sound_selection += 1
						if sound_selection > len(option_choices[3])-1:
							sound_selection = 0
						$Control/OptionsScreen/NinePatchRect/Sound.text = option_choices[3][sound_selection]
					4:
						print_selection += 1
						if print_selection > len(option_choices[4])-1:
							print_selection = 0
						$Control/OptionsScreen/NinePatchRect/Print.text = option_choices[4][print_selection]
			elif event.is_action_pressed("Accept"):
				match option_selection:
					5:
						GlobalVariables.options = [text_speed_selection,animation_selection,battle_style_selection,sound_selection,print_selection]
						load_main_screen()
		ScreenLoaded.CONTINUE:
			if event.is_action_pressed("Back"):
				$Control/WithSaveFile/SaveFileInfo.visible = false
				screen_loaded = ScreenLoaded.MAIN_SAVE
			elif event.is_action_pressed("Accept"):
					load_game()
