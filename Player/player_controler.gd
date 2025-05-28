extends CharacterBody3D

@export var Base_Speed : float = 4.0

@onready var Player_Camera : Camera3D = $"Camera Controler/Camera3D"

var Movement_Input : Vector2 = Vector2.ZERO

func _physics_process(_delta: float) -> void:
	Movement_Input = Input.get_vector("Left","Right","Forward","Backward").rotated(-Player_Camera.global_rotation.y)
	velocity = Vector3(Movement_Input.x,0,Movement_Input.y) * Base_Speed
	move_and_slide()
