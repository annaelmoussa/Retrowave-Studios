extends CharacterBody3D

@export var speed = 3.0
@export var health = 20
@export var damage = 10
@export var attack_range = 1.5
@onready var player = $"../player"
@onready var navigation_agent = $NavigationAgent3D
@onready var nav: NavigationRegion3D = $"../NavigationRegion3D"

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
	player.take_damage(damage)
	
	
	# Ajoutez cette méthode pour infliger des dégâts à l'ennemi
func take_damage(damage):
	health -= damage
	
	# Vérifiez si l'ennemi est mort
	if health <= 0:
		_die()

# Ajoutez cette méthode pour gérer la mort de l'ennemi
func _die():
	# Faites ici ce que vous voulez lorsque l'ennemi meurt, par exemple :
	queue_free()