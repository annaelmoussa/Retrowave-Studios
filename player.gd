extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var mouse_sense = 0.1

# Variables pour gérer la vie du joueur
var max_health = 100
var health = max_health
var health_regeneration_rate = 1.0
var time_since_last_attack = 0.0
var health_regeneration_delay = 3.0

@onready var head = $head
@onready var camera = $head/Camera3D
@onready var damage_texture = $head/Camera3D/TextureRect
@onready var anim_player = $head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/AnimationPlayer
@onready var shot_sound = $head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/ShootSound

func _ready():
	#hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$head/Camera3D/SubViewportContainer/SubViewport.size = DisplayServer.window_get_size()
func _input(event):
	#get mouse input for camera rotation
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta):
	$head/Camera3D/SubViewportContainer/SubViewport/view_model_camera.global_transform = camera.global_transform
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if anim_player.current_animation == "shoot":
		pass
	elif input_dir != Vector2.ZERO and is_on_floor():
		anim_player.play("move")
	else:
		anim_player.play("idle")

	move_and_slide()


	# Gestion de la récupération de vie
	if health < max_health:
		time_since_last_attack += delta
		if time_since_last_attack >= health_regeneration_delay:
			health += health_regeneration_rate * delta
			health = min(health, max_health)
			damage_texture.modulate = Color(1, 1, 1, (float) (max_health - health) / max_health)
	# Gestion de l'attaque du joueur
	if Input.is_action_just_pressed("fire"):
		_shoot()

func take_damage(damage):
	print_debug(health)
	health -= damage
	damage_texture.modulate = Color(1, 1, 1, (float) (max_health - health) / max_health)
	time_since_last_attack = 0.0
	if health <= 0:
		_on_player_death()

func _on_player_death():
	var crosshair = camera.get_node("UI")
	crosshair.visible = false
	# Charger la scène "Game Over"
	var game_over_scene = load("res://GameOver.tscn")
	# Instancier la scène "Game Over"
	var game_over_instance = game_over_scene.instantiate()
	# Ajouter l'écran "Game Over" à l'arborescence des nœuds
	get_tree().current_scene.add_child(game_over_instance)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Stopper le jeu (optionnel)
	get_tree().paused = true

func _shoot():
	# Obtenez le nœud RayCast3D (remplacez "RayCast3D" par le nom de votre nœud)
	var raycast = $head/Camera3D/SubViewportContainer/SubViewport/view_model_camera/RayCast3D
	
	# Activez le raycast
	raycast.enabled = true
	
	# Lancer l'animation du tir
	anim_player.stop()
	anim_player.play("shoot")
	# var rng = RandomNumberGenerator.new().randf_range(.7, .9)
	shot_sound.set_pitch_scale(RandomNumberGenerator.new().randf_range(.7, .9))

	# Lancez le raycast
	raycast.force_raycast_update()

	# Vérifiez si un ennemi a été touché
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider.is_in_group("enemies"):
			# Infligez des dégâts à l'ennemi ou appelez une fonction pour le gérer, par exemple:
			collider.take_damage(10)
		
	# Désactivez le raycast après utilisation pour éviter de continuer à détecter des collisions
	raycast.enabled = false

func reset_health():
	health = max_health
	damage_texture.modulate = Color(1, 1, 1, (float) (max_health - health) / max_health)
