extends Control

@onready var UI = $"."
@onready var right_ch = $RightLine
@onready var left_ch = $LeftLine
@onready var up_ch = $TopLine
@onready var down_ch = $BottomLine
@onready var static_arrow_right = $"../StaticArrowRight"
@onready var static_arrow_left = $"../StaticArrowLeft"
@onready var dynamic_arrow_right = $"../DynamicArrowRight"
@onready var dynamic_arrow_left = $"../DynamicArrowLeft"
@onready var perfect_counter = $"../HitStreak"

var can_fire = true
var CH_recoil_pos = 50
var score = 0
var arrow_speed = 100
var perfect_bonus = 10
var hit_streak = 0

func _ready():
	reset_dynamic_arrows()

func reset_dynamic_arrows():
	dynamic_arrow_right.position = static_arrow_right.position + Vector2(100, 0)
	dynamic_arrow_left.position = static_arrow_left.position + Vector2(-100, 0)

func move_dynamic_arrows(delta):
	dynamic_arrow_right.position.x -= arrow_speed * delta
	dynamic_arrow_left.position.x += arrow_speed * delta

	if dynamic_arrow_right.position.x <= static_arrow_right.position.x - 20 or dynamic_arrow_left.position.x >= static_arrow_left.position.x + 20:
		reset_dynamic_arrows()
		update_score()

func update_score():
	var distance_right = abs(dynamic_arrow_right.position.x - static_arrow_right.position.x)
	var distance_left = abs(dynamic_arrow_left.position.x - static_arrow_left.position.x)

	if distance_right < 5 and distance_left < 5:
		score += perfect_bonus
		show_perfect_effect()
		update_perfect_counter(1)
	elif distance_right < 50 and distance_left < 50:
		score += 1
	else:
		score -= 1

	print("Score:", score)

func _physics_process(delta):
	fire(delta)
	move_dynamic_arrows(delta)
	update_dynamic_arrow_opacity()

func update_dynamic_arrow_opacity():
	var distance_right = abs(dynamic_arrow_right.position.x - static_arrow_right.position.x)
	var distance_left = abs(dynamic_arrow_left.position.x - static_arrow_left.position.x)

	var opacity_right = 1.0 - clamp(distance_right / 100.0, 0.0, 1.0)
	var opacity_left = 1.0 - clamp(distance_left / 100.0, 0.0, 1.0)

	dynamic_arrow_right.modulate.a = opacity_right
	dynamic_arrow_left.modulate.a = opacity_left
	
	
	
func show_perfect_effect():
	static_arrow_left.texture = load("res://Crosshair/Left-Arrow-perfect.png")
	static_arrow_right.texture = load("res://Crosshair/Left-Right-perfect.png")
	await get_tree().create_timer(0.5).timeout
	static_arrow_left.texture = load("res://Crosshair/Left-Arrow.png")
	static_arrow_right.texture = load("res://Crosshair/Left-Right.png")

func update_perfect_counter(point):
	hit_streak += point
	perfect_counter.text = "%d Hit Streak " % hit_streak

func fire(delta):
	if Input.is_action_pressed("fire") and can_fire:
		up_ch.position = lerp( up_ch.position , Vector2(0 ,-CH_recoil_pos) , 3*delta)
		down_ch.position = lerp( down_ch.position , Vector2(0 , CH_recoil_pos) , 3 *delta)
		left_ch.position = lerp( left_ch.position , Vector2( -CH_recoil_pos , 0) ,3 *delta)
		right_ch.position = lerp( right_ch.position , Vector2( CH_recoil_pos , 0) ,3 *delta)
		
		can_fire = false
		
		if down_ch.position > Vector2(0,60):
			CH_recoil_pos = 60
		
		CH_recoil_pos += 4
		update_score()
		reset_dynamic_arrows()
		await get_tree().create_timer(.25).timeout
		can_fire = true
		
	if !Input.is_action_pressed("fire")  or not can_fire:
		for ch in UI.get_children():
			ch.position = lerp( ch.position , Vector2(0,0) , 3 * delta )
			CH_recoil_pos -= ch.position.x
