extends CharacterBody3D

@export var speed = 3.0
@export var health = 20
@export var damage = 10
@export var attack_delay = 1.0
@export var spawn_radius_min = 10.0
@export var spawn_radius_max = 15.0
@export var attack_range = 1.5
@onready var player = $"../player"
@onready var navigation_agent = $NavigationAgent3D
@onready var nav: NavigationRegion3D = $"../NavigationRegion3D"
@onready var animation_player = $scene/AnimationPlayer
var can_attack = true

func _ready():
	add_to_group("enemies")
	navigation_agent.target_reached.connect(_on_target_reached)
	animation_player.play("MoveDrone", -1, 1.0, true)
	global_transform.origin = random_spawn_position()
	
func random_spawn_position():
	var angle = randf_range(0, 2 * PI)
	var radius = randf_range(spawn_radius_min, spawn_radius_max)
	var offset = Vector3(cos(angle) * radius, 0, sin(angle) * radius)
	return player.global_transform.origin + offset
	
func update_target_position(target_position_player):
	navigation_agent.target_position = target_position_player

func _physics_process(delta):
	update_target_position(player.global_transform.origin)
	var next_location = navigation_agent.get_next_path_position()
	var direction = global_transform.origin.direction_to(next_location)
	var new_velocity = direction.normalized() * speed
	velocity = new_velocity
	move_and_slide()
	_face_player()

func _face_player():
	var player_position = player.global_transform.origin
	var look_at_position = Vector3(player_position.x, global_transform.origin.y, player_position.z)
	look_at(look_at_position, Vector3.UP)

func _on_target_reached():
	var distance_to_player = global_transform.origin.distance_to(player.global_transform.origin)
	if distance_to_player <= attack_range:
		_attack_player()
#
func _attack_player():
	if can_attack:
		player.take_damage(damage)
		can_attack = false
		await get_tree().create_timer(attack_delay).timeout
		can_attack = true
	
func take_damage(damage_player):
	health -= damage_player
	if health <= 0:
		_die()

func _die():
	queue_free()
