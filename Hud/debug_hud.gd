extends CanvasLayer

@export var Debug_Hud: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

	$"../../PlayerControler".Current_Speed.connect(_get_speed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$Label.text = "Fps:" + str(Engine.get_frames_per_second())
	
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Hud Toggle"):
		Debug_Hud = not Debug_Hud
		if Debug_Hud == false:
			$".".hide()
		else:
			$".".show()


func _get_speed(Player_Speed: float) -> void:
	$Label2.text = "Speed:" + str(snapped(Player_Speed, 0.01))

func _on_player_controler_current_speed(_Speed: float) -> void:
	pass # Replace with function body.
