extends CharacterBody3D

@export var Dev_Print: bool = false



signal Player_Speed(Speed : float)
var Speed: float = 0

## This is a Description
@export var Current_Speed : float = 0.0
var Transition_Speed : float = 16.0
@export var Base_Speed : float = 3.0
@export var Sprint_Speed : float = 5.0
@export var Movement_Acceleration : float = 4.0
@export var Movement_Deceleration : float = 8.0

@export var jump_height : float = 1.25
@export var jump_time_to_peak : float = 0.4
@export var jump_time_to_descent : float = 0.4

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

@onready var Player_Camera : Camera3D = $"Camera Controler/Camera3D"

const CLIMBABLE_LAYER_INDEX: int = 3
const CLIMBABLE_LAYER_MASK: int = 1 << (CLIMBABLE_LAYER_INDEX - 1)

@onready var tree_node: Node = get_node_or_null("../Mesh/ClimbeableTree")
@onready var ray: RayCast3D = get_node("Mesh/DetectClimbable") as RayCast3D

func _ready() -> void:
	if tree_node == null:
		push_warning("ClimbeableTree not found at ../Mesh/ClimbeableTree — adjust path if needed.")
	if ray == null:
		push_error("RayCast3D not found at Mesh/RayCast3D — fix path in script.")
		return

	ray.enabled = true
	ray.collision_mask = CLIMBABLE_LAYER_MASK
	ray.force_raycast_update()

func _physics_process(delta: float) -> void:
	
	Movement_Logic(delta)
	Jump_Logic(delta)
	
	move_and_slide()

func Movement_Logic(delta: float) -> void:
	# read input and rotate by camera yaw (assumes camera.global_rotation.y is in radians)
	var Movement_Input : Vector2 = Input.get_vector("Left", "Right", "Forward", "Backward").rotated(-Player_Camera.global_rotation.y)

	# --- DEADZONE + NORMALIZE ---
	const INPUT_DEADZONE : float = 0.15
	var Input_Length : float = Movement_Input.length()
	if Input_Length < INPUT_DEADZONE:
		Movement_Input = Vector2.ZERO
	elif Input_Length > 1.0:
		# clamp diagonal vectors so magnitude never exceeds 1
		Movement_Input = Movement_Input.normalized()
	# ---------------------------

	var Horizontal_Movement : Vector2 = Vector2(velocity.x, velocity.z)
	var Is_Sprinting: bool = Input.is_action_pressed("Sprint")
	
	var Target_Speed : float = Sprint_Speed if Is_Sprinting else Base_Speed
	var t : float = clamp(Transition_Speed * delta, 0.0, 1.0)
	Current_Speed = lerp(Current_Speed , Target_Speed, t)
	
	
	

	# use length() for a physically-meaningful speed value
	Speed = Horizontal_Movement.length()
	emit_signal("Player_Speed", Speed)

	if Movement_Input != Vector2.ZERO:
		var Max_Speed : float = Current_Speed
		# Movement is your current velocity scaled to base speed (used for rotation)
		var Movement : Vector2 = Horizontal_Movement / Base_Speed
		const ROT_SPEED : float = 16.0  # tweak: higher = faster turn
		var move_dir : Vector2 = Movement

		if ray.is_colliding():
			var normal: Vector3 = ray.get_collision_normal()
			var surf_basis: Basis = Basis.looking_at(normal, Vector3.UP)
			var euler: Vector3 = surf_basis.get_euler() * 180.0 / PI
			
			$Mesh.rotation.y = lerp_angle($Mesh.rotation.y, deg_to_rad(euler.y + 180), clamp(ROT_SPEED * delta, 0.0, 1.0))
			
		elif move_dir.length() > 0.001:
			var target: float = wrapf(-move_dir.angle() + deg_to_rad(-90.0), 0.0, TAU)
			$Mesh.rotation.y = lerp_angle($Mesh.rotation.y, target, clamp(ROT_SPEED * delta, 0.0, 1.0))

		# apply acceleration using normalized/clamped Movement_Input
		Horizontal_Movement += Movement_Input * Max_Speed * Movement_Acceleration * delta
		Horizontal_Movement = Horizontal_Movement.limit_length(Max_Speed)

		velocity.x = Horizontal_Movement.x
		velocity.z = Horizontal_Movement.y

	else:
		if is_on_floor():
			Horizontal_Movement = Horizontal_Movement.move_toward(Vector2.ZERO, Base_Speed * Movement_Deceleration * delta)
			velocity.x = Horizontal_Movement.x
			velocity.z = Horizontal_Movement.y


func Jump_Logic(delta: float) -> void:
	if is_on_floor():
		if Input.is_action_just_pressed("Jump"):
			velocity.y = -jump_velocity
	var Gravity : float = jump_gravity if velocity.y > 0.0 else fall_gravity
	velocity.y -= Gravity * delta
