extends KinematicBody2D

export var speed = 4.0
export var jump_speed = 4.0
const TILE_SIZE = 16

onready var anim_tree =$AnimationTree
onready var animation_player = $AnimationPlayer
onready var jump_shadow = $JumpShadow
onready var anim_state = anim_tree.get("parameters/playback")
onready var ray = $BlockingRaycast
onready var doorRay = $DoorRaycast
onready var ledgeRay = $LedgeRayCast
onready var interactRay = $InteractableRayCast
onready var cuttreeRay  = $CutTreeRayCast


var jumping_over_ledge: bool = false

var prevent_input: bool = false

signal player_clicked_interactable_signal(interactable_dialogue_id)
signal player_cut_tree_signal
signal player_entering_door_signal
signal player_moving_signal
signal player_stopped_signal

enum PlayerState {IDLE,TURNING,WALKING}
enum FacingDirection {LEFT,RIGHT,UP,DOWN}

var player_state = PlayerState.IDLE
var facing_direction = FacingDirection.DOWN

var initial_position = Vector2(0,0)
var input_direction = Vector2(0,1)
var is_moving = false
var percent_moved_to_next_tile = 0.0



# Called when the node enters the scene tree for the first time.
func _ready():
	anim_tree.active = true
#	position = position.snapped(Vector2.ONE * tile_size)
#	position += Vector2.ONE * tile_size/2
	jump_shadow.visible = false
	initial_position = position
	anim_tree.set("parameters/Idle/blend_position", input_direction)
	anim_tree.set("parameters/Walk/blend_position", input_direction)
	anim_tree.set("parameters/Turn/blend_position", input_direction)
	
func set_spawn(location:Vector2,direction:Vector2):
	anim_tree.set("parameters/Idle/blend_position", direction)
	anim_tree.set("parameters/Walk/blend_position", direction)
	anim_tree.set("parameters/Turn/blend_position", direction)
	position = location
	
func _physics_process(delta):
	if player_state == PlayerState.TURNING or prevent_input:
		return
	elif is_moving == false:
		process_player_input()
	elif input_direction != Vector2.ZERO:
		anim_state.travel(("Walk"))
		move(delta)
	else:
		anim_state.travel(("Idle"))
		is_moving = false
		
func _unhandled_input(event):
	if interactRay.is_colliding() and GlobalVariables.is_in_menu == false:
		if event.is_action_pressed("Accept"):
			anim_state.travel(("Idle"))
			is_moving = false
			set_physics_process(false)
			interactRay.enabled = false
			emit_signal("player_clicked_interactable_signal",interactRay.get_collider().dialogue_id)
	elif cuttreeRay.is_colliding() and GlobalVariables.is_in_menu == false:
		if event.is_action_pressed("Accept"):
			anim_state.travel(("Idle"))
			is_moving = false
			set_physics_process(false)
			cuttreeRay.enabled = false
			emit_signal("player_cut_tree_signal")
			
	
func process_player_input():
	if input_direction.y == 0:
		input_direction.x = int(Input.is_action_pressed("PlayerMoveRight")) - int(Input.is_action_pressed("PlayerMoveLeft"))
	if input_direction.x == 0:
		input_direction.y = int(Input.is_action_pressed("PlayerMoveDown")) - int(Input.is_action_pressed("PlayerMoveUp"))
		
	if input_direction != Vector2.ZERO:
		anim_tree.set("parameters/Idle/blend_position", input_direction)
		anim_tree.set("parameters/Walk/blend_position", input_direction)
		anim_tree.set("parameters/Turn/blend_position", input_direction)
		
		if need_to_turn():
			player_state = PlayerState.TURNING
			anim_state.travel("Turn")
		else:
			initial_position = position
			is_moving = true
	else:
		anim_state.travel("Idle")
		
func need_to_turn():		
	var new_facing_direction
	if input_direction.x < 0:
		new_facing_direction = FacingDirection.LEFT
	elif input_direction.x > 0:
		new_facing_direction = FacingDirection.RIGHT
	elif input_direction.y < 0:
		new_facing_direction = FacingDirection.UP
	elif input_direction.y > 0:
		new_facing_direction = FacingDirection.DOWN
	var desired_step: Vector2 = input_direction * TILE_SIZE / 2
	interactRay.cast_to = desired_step
	interactRay.force_raycast_update()
	cuttreeRay.cast_to = desired_step
	cuttreeRay.force_raycast_update()
	if facing_direction != new_facing_direction:
		facing_direction = new_facing_direction
		return true
	facing_direction = new_facing_direction
	return false

func finished_turning():
	player_state = PlayerState.IDLE

func move(delta):
	var desired_step: Vector2 = input_direction * TILE_SIZE / 2
	
	ray.cast_to = desired_step
	ray.force_raycast_update()
	
	ledgeRay.cast_to = desired_step
	ledgeRay.force_raycast_update()
	
	doorRay.cast_to = desired_step
	doorRay.force_raycast_update()
	
	cuttreeRay.cast_to = desired_step
	cuttreeRay.force_raycast_update()

	
	if doorRay.is_colliding():
		if percent_moved_to_next_tile == 0.0:
			emit_signal("player_entering_door_signal")
		percent_moved_to_next_tile += speed * delta
		if percent_moved_to_next_tile >= 1.0:
			position = initial_position + (input_direction * TILE_SIZE)
			percent_moved_to_next_tile = 0.0
			is_moving = false
			prevent_input = true
			anim_state.travel(("Idle"))
			$Camera2D.clear_current()
		else:
			position = initial_position + (input_direction * TILE_SIZE * percent_moved_to_next_tile)
			
	
	elif (ledgeRay.is_colliding() && input_direction == Vector2(0,1)) or jumping_over_ledge:
		percent_moved_to_next_tile += jump_speed * delta
		if percent_moved_to_next_tile >= 2.0:
			position = initial_position + (input_direction * TILE_SIZE * 2)
			percent_moved_to_next_tile = 0.0
			is_moving = false
			jump_shadow.visible = false
			jumping_over_ledge = false
		else:
			animation_player.play("jumping")
			jump_shadow.visible = true
			jumping_over_ledge = true
			position = initial_position + (input_direction * TILE_SIZE * percent_moved_to_next_tile)
#			var input = input_direction.y * TILE_SIZE * percent_moved_to_next_tile
#			position.y = initial_position.y + (-0.96 - 0.53 * input + 0.05 + pow(input,2))
		
	elif !ray.is_colliding() and !cuttreeRay.is_colliding():
		if percent_moved_to_next_tile == 0:
			emit_signal("player_moving_signal")
		percent_moved_to_next_tile += speed * delta
		if percent_moved_to_next_tile >= 1.0:
			position = initial_position + (TILE_SIZE * input_direction)
			percent_moved_to_next_tile = 0.0
			is_moving = false
			emit_signal("player_stopped_signal")
		else:
			position = initial_position + (input_direction * TILE_SIZE * percent_moved_to_next_tile)
	else:
		percent_moved_to_next_tile = 0.0
		is_moving = false
	interactRay.cast_to = desired_step
	interactRay.force_raycast_update()
	cuttreeRay.cast_to = desired_step
	cuttreeRay.force_raycast_update()
	#print(position)
	







