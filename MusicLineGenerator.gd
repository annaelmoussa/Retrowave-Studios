extends Node

@export var json_data_path = "res://Ambient/Song/Level 1/Map/map.json"
var json_data = null

var line2d_scene = preload($".")

var target_UI = null
var target_viseur = null

func _ready():
	load_json_data()
	target_UI = get_node("UI")
	target_viseur = get_node("Viseur")
	generate_music_lines()
	

func load_json_data():
	var file = FileAccess.open(json_data_path, FileAccess.READ)
	if file == OK:
		var json_text = file.get_as_text()
		json_data = JSON.parse_string(json_text).result
		file.close()
	else:
		print("Error: Unable to open file: ", json_data_path)


func generate_music_lines():
	var tempo = json_data["tempo"]
	for track in json_data["tracks"]:
		var color_code = track["color"]
		var color = Color8(int(color_code.substr(1, 2)), int(color_code.substr(3, 2)), int(color_code.substr(5, 2)))
		for bar in track["bars"]:
			for note in bar["notes"]:
				var line = line2d_scene.instance()
				line.color = color
				line.points = [Vector2(), Vector2(0, -note["len"])]
				target_UI.add_child(line)

				var beat_duration = 60.0 / tempo
				var spawn_time = beat_duration * (note["pos"] / 100.0)
				var timer = Timer.new()
				timer.wait_time = spawn_time
				timer.connect("timeout", self._on_note_spawn_timeout.bind(line))
				add_child(timer)
				timer.start()

func _on_note_spawn_timeout(line):
	target_viseur.add_child(line)
	line.global_position = target_viseur.global_position
