extends Node

var rng = RandomNumberGenerator.new()   
var area_data
var pokemon_data
var type_data 
var dialogue_data
var move_data


# Called when the node enters the scene tree for the first time.
func _ready():
	var file = File.new()
	file.open("res://assets/data/area_data.json", File.READ)
	var data = file.get_as_text()
	var d = JSON.parse(data).result
	area_data = d
	file.open("res://assets/data/pokemon_data.json", File.READ)
	data = file.get_as_text()
	d = JSON.parse(data).result
	pokemon_data = d
	file.open("res://assets/data/pokemon_type_data.json", File.READ)
	data = file.get_as_text()
	d = JSON.parse(data).result
	type_data = d
	file.open("res://assets/data/dialogue_data.json", File.READ)
	data = file.get_as_text()
	d = JSON.parse(data).result
	dialogue_data = d
	file.open("res://assets/data/move_data.json", File.READ)
	data = file.get_as_text()
	d = JSON.parse(data).result
	move_data = d



func generate_encounter(area_id):
	var encounter_number = generate_random_number(1,256)
	for pokes in area_data[String(area_id)]["pokemon_found"]:
		var value_range = pokes["encounter_chance"].split("-")
		if encounter_number >= int(value_range[0]) and encounter_number <= int(value_range[1]):
			return generate_wild_pokemon_data(pokes)
			
func generate_wild_pokemon_data(pokes):
	var full_data = pokemon_data[str(pokes["id"])]
	full_data["level"] = pokes["level"]
	var attack_dv = generate_random_number(0,15)
	var defense_dv = generate_random_number(0,15)
	var speed_dv = generate_random_number(0,15)
	var special_dv = generate_random_number(0,15)
	var hp_dv = 0
	if attack_dv %2 != 0:
		hp_dv += 8
	if defense_dv %2 != 0:
		hp_dv += 8
	if speed_dv %2 != 0:
		hp_dv += 8
	if special_dv %2 != 0:
		hp_dv += 8
	full_data["dvs"] = [hp_dv,attack_dv,defense_dv,speed_dv,special_dv]
	var stat_hp = generate_stat(full_data["base_stats"]["hp"],hp_dv,full_data["level"],full_data["level"]+10)
	return full_data

func generate_stat(baseStat,dv,level,e):
	return int(((baseStat + dv)*2+1) * level/100) + e
	
func generate_random_number(from,to):
	rng.randomize()
	return rng.randi_range(from,to)
			
func convert_int_to_vector2(num):
	match num:
		0:
			return Vector2(-1,0)
		1:
			return Vector2(1,0)
		2:
			return Vector2(0,-1)
		3:
			return Vector2(0,1)
			
func check_pokemon_has_cut():
	pass
