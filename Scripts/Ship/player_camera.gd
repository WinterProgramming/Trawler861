extends Camera2D

const ZOOM_SPEED = 2.5

var desired_zoom: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	desired_zoom = zoom.x


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if PlayerShip.instance.state != PlayerShip.State.IDLE:
		return

	if Input.is_action_pressed("camera_zoom_in") || Input.is_action_just_released("camera_zoom_in"):
		desired_zoom += 20.0 * delta
	elif Input.is_action_pressed("camera_zoom_out") || Input.is_action_just_released("camera_zoom_out"):
		desired_zoom -= 20.0 * delta
		
	desired_zoom = clampf(desired_zoom, 0.4, 1.0)
	zoom = zoom.move_toward(Vector2(desired_zoom, desired_zoom), ZOOM_SPEED * delta)
