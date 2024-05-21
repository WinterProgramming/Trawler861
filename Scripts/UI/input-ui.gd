extends Control

@export var panel: Panel
@export var show_label: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("input_help"):
		if panel.is_visible():
			panel.set_visible(false)
			show_label.modulate = Color(Color.WHITE, 0.25)
		else:
			panel.set_visible(true)
			show_label.modulate = Color(Color.WHITE, 1.0)
