extends Node3D

@export var Mouse_Sensitivity : float = 0.005
@export var Invert_Horizontal_Camera : bool = false
@export var Invert_Vertical_Camera : bool = false
@onready var SpringArm: SpringArm3D = $"."

var Mouse_Toggle: bool = true

const MIN_LENGTH: float = 3.0
const MAX_LENGTH: float = 7.0
const STEP_LENGTH: float = 2.0

var lerp_speed: float = 5.0
var target_length: float = 5.0   # stored between frames

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Exit"):
		get_tree().quit()
		
	if event is InputEventMouseMotion:
		rotate_from_vector(event.relative * Mouse_Sensitivity)

func _process(delta: float) -> void:
	if Input.is_action_pressed("Mouse Toggle"):
		Mouse_Toggle = not Mouse_Toggle
	if Mouse_Toggle == false:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	
	
	Camera_Range(delta)

func Camera_Range(delta: float) -> void:

	# Smoothly interpolate toward target
	SpringArm.spring_length = lerp(SpringArm.spring_length, target_length, delta * lerp_speed)

	# Handle zoom input
	if Input.is_action_just_pressed("Zoom In"):
		if target_length <= MIN_LENGTH:
			pass
			#print("Already at minimum zoom!")
		else:
			target_length = clamp(target_length - STEP_LENGTH, MIN_LENGTH, MAX_LENGTH)
			
	elif Input.is_action_just_pressed("Zoom Out"):
		if target_length >= MAX_LENGTH:
			pass
			#print("Already at maximum zoom!")
		else:
			target_length = clamp(target_length + STEP_LENGTH, MIN_LENGTH, MAX_LENGTH)

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
