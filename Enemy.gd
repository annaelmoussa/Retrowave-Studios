extends CharacterBody3D

@export var speed = 3.0
@export var health = 20
@export var damage = 10
@export var attack_delay = 1.0
@export var attack_range = 1.5
@onready var player = $"../player"
@onready var navigation_agent = $NavigationAgent3D
@onready var nav: NavigationRegion3D = $"../NavigationRegion3D"

var can_attack = true

func _ready():
	add_to_group("enemies")
	navigation_agent.target_reached.connect(_on_target_reached)

func update_target_position(target_position_player):
	navigation_agent.target_position = target_position_player

func _physics_process(delta):
	update_target_position(player.global_transform.origin)
	var next_location = navigation_agent.get_next_path_position()
	var direction = global_transform.origin.direction_to(next_location)
	var new_velocity = direction.normalized() * speed
	velocity = new_velocity
	move_and_slide()

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
