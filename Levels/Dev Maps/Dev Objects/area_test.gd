extends StaticBody3D

@warning_ignore("unused_parameter")

func _on_area_3d_body_entered(body: Node3D) -> void:
	get_tree().change_scene_to_file.call_deferred("res://Levels/Dev Maps/Dev Playground/player_movement.tscn")
