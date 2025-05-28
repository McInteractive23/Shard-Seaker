extends Node3D

@export var Mouse_Sensitivity : float = 0.005
@export var Invert_Horizontal_Camera : bool = false
@export var Invert_Vertical_Camera : bool = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_from_vector(event.relative * Mouse_Sensitivity)

func rotate_from_vector(v: Vector2) -> void:
	if v.length() == 0: 
		return
	
	if Invert_Horizontal_Camera == false: 
		rotation.y -= v.x
	else: 
		rotation.y -= -v.x
	
	if Invert_Vertical_Camera == false: 
		rotation.x -= v.y
		rotation.x = clamp(rotation.x, deg_to_rad(-90), deg_to_rad(15))
	else: 
		rotation.x -= -v.y
		rotation.x = clamp(rotation.x, deg_to_rad(-90), deg_to_rad(15))
