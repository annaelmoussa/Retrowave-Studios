extends Node3D

@onready var player = $player

func _physics_process(delta):
	get_tree().call_group("enemies", "update_target_position", player.global_transform.origin)

func spawn_enemy():
	var spawn_distance = 10.0
	var player_direction = player.global_transform.basis.z.normalized()  # Get the player's forward direction
	var spawn_position = player.global_transform.origin - player_direction * spawn_distance
	# Load the enemy scene
	var enemy_scene = load("res://Enemy.tscn")

	# Instantiate the enemy
	var enemy_instance = enemy_scene.instantiate()

	# Set the enemy's position (you can change this based on your needs)
	enemy_instance.global_transform.origin = spawn_position

	# Add the enemy to the scene
	add_child(enemy_instance)

	# Add the enemy to the "enemies" group
	enemy_instance.add_to_group("enemies")


func _ready():
	$EnemySpawnTimer.timeout.connect(spawn_enemy)
