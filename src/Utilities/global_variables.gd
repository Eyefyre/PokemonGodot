extends Node

var player_name: String = "AAAAAAA"
var player_money: int = 3000
var current_scene = "res://src/Locations/Overworld.tscn"
var player_position = {"x":0,"y":0}
var player_facing_direction = {"x":0,"y":0} #fix this
var rival_name: String = "BBBBBBB"
var has_pokedex: bool = false
var has_pikachu_from_oak: bool = false
var badges = [false,false,false,false,false,false,false,false]
var options = [0,0,0,0,0]
var pokedex = 1
var in_game_time = 0
#var current_items = null
#var pokedex_completion = null
var current_party = {
		"1": {
			"pokemon_id": 25,
			"global_id":37024,
			"pokemon_name":"Steve",
			"current_hp":19,
			"dvs": [15,15,15,15,15],
			"stats":[19,10,8,15,11],
			"level": 5,
			"experience": 180,
			"moves":{
				"1":{"move_id":1,"current_pp":40},
				"2":{"move_id":2,"current_pp":30},
				"3":null,
				"4":null
			},
			"original_trainer":"Adam",
			"is_fainted":false,
			"is_poisoned":false}
	}

var wild_encounter_data = null


var is_in_dialogue = false
var is_in_menu = false
var has_cut = false



# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func save_game():
	var player_dir = DataHelper.convert_int_to_vector2(Utils.get_player().facing_direction)
	var save_dict = {
		"player_name" : player_name,
		"player_money" : player_money,
		"current_scene": Utils.get_current_scene().filename,
		"player_position": {"x":Utils.get_player().position.x,"y":Utils.get_player().position.y},
		"player_facing_direction": {"x":player_dir.x,"y":player_dir.y},#Utils.get_player().input_direction,
		"rival_name": rival_name,
		"has_pokedex": has_pokedex,
		"has_pikachu_from_oak": has_pikachu_from_oak,
		"badges": badges,
		"options": options,
		"pokedex": pokedex,
		"in_game_time":in_game_time,
		"current_party":current_party
	}
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	save_game.store_line(to_json(save_dict))
	save_game.close()
	
func load_game():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return
	
	save_game.open("user://savegame.save", File.READ)
	var data
	while save_game.get_position() < save_game.get_len():
		data = parse_json(save_game.get_line())

	for x in data:
		self.set(str(x),data[x])
	save_game.close()
	
func does_save_exist():
	var save_game = File.new()
	return save_game.file_exists("user://savegame.save")

