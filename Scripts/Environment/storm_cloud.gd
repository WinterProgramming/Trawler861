extends Node2D


var movement_dir: Vector2
var player: PlayerShip
var damage_timer: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rand_movement()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation_degrees += 2.0 * delta
	position += movement_dir * 20.0 * delta
	
	if player:
		damage_timer -= delta
		if damage_timer <= 0.0:
			damage_player()
	
func rand_movement():
	var v = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
	movement_dir = v.normalized()

func _on_area_2d_body_entered(body: Node2D) -> void:
	player = body as PlayerShip
	if player:
		damage_player()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		player = null

func damage_player():
	player.apply_damage(global_position, 10.0)
	damage_timer = 2.0
