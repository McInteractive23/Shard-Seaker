extends CharacterBody3D

@export var Dev_Print: bool = false

## This is a Description
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

var Movement_Input : Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	
	Movement_Logic(delta)
	Jump_Logic(delta)
	
	move_and_slide()

#	if is_on_wall():
#		for i in range(get_slide_collision_count()):
#			var collision = get_slide_collision(i)
#			var collider = collision.get_collider()
#			
#			if collider == null:
#				continue
#
#			# If the collider is the StaticBody3D inside the Purple Dev Box
#			if collider.get_parent() and collider.get_parent().name == "Purple Dev Box":
#				print("Touching the Purple Dev Box!")



#Fix Stopping In Mid Air add Glide movement with no movement deceleration in air

func Movement_Logic(delta: float) -> void:
	Movement_Input = Input.get_vector("Left","Right","Forward","Backward").rotated(-Player_Camera.global_rotation.y)
	var Horizontal_Movement : Vector2 = Vector2(velocity.x, velocity.z)
	var Is_Sprinting: bool = Input.is_action_pressed("Sprint")
	

	if Movement_Input != Vector2.ZERO:
		var Max_Speed : float = Sprint_Speed if Is_Sprinting else Base_Speed
		var Movement : Vector2 = Horizontal_Movement/Base_Speed
		var _Movement_x : float = Movement.x
		var _Movement_y : float = Movement.y



		const ROT_SPEED : float = 16.0  # tweak: higher = faster turn
		var move_dir : Vector2 = Movement
		if move_dir.length() > 0.001:
			var target: float = wrapf(-move_dir.angle() + deg_to_rad(-90.0), 0.0, TAU)
			$Mesh.rotation.y = lerp_angle($Mesh.rotation.y, target, clamp(ROT_SPEED * delta, 0.0, 1.0))
			#print("Y = ",floor(Movement.x * 100.0) / 100.0)
			#print("X = ",floor(Movement.y * 100.0) / 100.0)
			#lerp_angle uses the shortest direction and handles wrap-around



		Horizontal_Movement += Movement_Input * Max_Speed * Movement_Acceleration * delta
		Horizontal_Movement = Horizontal_Movement.limit_length(Max_Speed)
		velocity.x = Horizontal_Movement.x
		velocity.z = Horizontal_Movement.y
	else: if is_on_floor():
		Horizontal_Movement = Horizontal_Movement.move_toward(Vector2.ZERO, Base_Speed * Movement_Deceleration * delta)
		velocity.x = Horizontal_Movement.x
		velocity.z = Horizontal_Movement.y


	if is_on_wall() and Dev_Print == true:
		var tree_node: Node = get_node("../Mesh/ClimbeableTree")

		for i : int in range(get_slide_collision_count()):
			var collision: KinematicCollision3D = get_slide_collision(i)
			var collider: Object = collision.get_collider()
			if collider == null:
				continue

			var parent_node: Node = collider.get_parent()
			if parent_node == null:
				continue

			# Walk up the tree to see if we eventually reach ClimbeableTree
			var current: Node = parent_node
			while current:
				if current == tree_node:
					print("Touching ClimbeableTree child:", parent_node.name)
					break
				current = current.get_parent()


func Jump_Logic(delta: float) -> void:
	if is_on_floor():
		if Input.is_action_just_pressed("Jump"):
			velocity.y = -jump_velocity
	var Gravity : float = jump_gravity if velocity.y > 0.0 else fall_gravity
	velocity.y -= Gravity * delta
