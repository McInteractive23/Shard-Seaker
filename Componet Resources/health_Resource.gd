class_name HealthComponet extends Node

## This is a Description

signal damaged
signal is_dead

@export_group("Health")
@export var health: int = 0
@export var max_health: int = 0

@export_group("Damage")
@export var area3d : Area3D

func _ready() -> void:
	area3d.area_entered.connect(collision)

func collision() -> void:
	damaged.emit(1)

func damage_taken(damage: int) -> void:
	health -= damage
	if health <= 0:
		is_dead.emit()
