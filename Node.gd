extends Node

@onready var crosshair = $"../UI/Crosshair"
@onready var UI = $"../UI"
@onready var right_ch = $"../UI/Crosshair/RightLine"
@onready var left_ch = $"../UI/Crosshair/LeftLine"

var json_data = {}
var melody_lines = []
var timer = null
var points = 0

func _ready():
	_load_json_data()
	_create_melody_lines()
	timer = Timer.new()
	timer.connect("timeout", self, "_on_timer_timeout")
	timer.set_wait_time(1.0 / json_data["tempo"] * 60)
	timer.set_one_shot(false)
	timer.start()
	add_child(timer)

func _load_json_data():
	var file = FileAccess.open("res://Ambient/Song/Level 1/Map/map.json", FileAccess.READ)  # Changed from FileAccess.READ to File.READ
	if file == OK:
		var content = file.get_as_text()
		json_data = JSON.parse_string(content)  # Changed from parse_json() to JSON.parse().result
	file.close()

func _create_melody_lines():
	for track in json_data["tracks"]:
		print_debug(track["color"])
		var color = Color.html(track["color"])  # Changed from Color.from_html() to Color.html()
		for bar in track["bars"]:
			for note in bar["notes"]:
				var line = Line2D.new()
				line.color = color
				line.width = note["len"]
				line.add_point(Vector2(note["pos"], 0))
				line.add_point(Vector2(note["pos"] + note["len"], 0))
				melody_lines.append(line)
				add_child(line)

func _on_timer_timeout():
	_move_melody_lines()
	_check_collision()

func _move_melody_lines():
	for line in melody_lines:
		var new_pos = line.position + Vector2(-1, 0)
		line.position = new_pos
		if new_pos.x < -line.width:
			line.queue_free()
			melody_lines.erase(line)

func _check_collision():
	if crosshair.can_fire and Input.is_action_pressed("fire"):
		var hit = false
		for line in melody_lines:
			if _is_line_colliding_with_crosshair(line, left_ch) or _is_line_colliding_with_crosshair(line, right_ch):
				hit = true
				points += 1
				break
		if not hit:
			points -= 1

func _is_line_colliding_with_crosshair(line, crosshair_line):
	return line.global_position.y >= crosshair_line.global_position.y - crosshair_line.width / 2 and line.global_position.y <= crosshair_line.global_position.y + crosshair_line.width / 2
