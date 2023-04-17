extends Control
func _on_button_pressed():
	# Réinitialiser la vie du joueur
	var player = get_tree().current_scene.get_node("player")
	player.reset_health()
	get_tree().paused = false
	# Supprimer la scène actuelle et ajouter la scène principale à l'arborescence des nœuds
	get_tree().reload_current_scene()
	


func _on_quit_pressed():
	get_tree().quit()
