extends Control
class_name ReportUI

@export var month_label: Label
@export var stability_label: Label
@export var quota_label: Label
@export var delta_label: Label
@export var button: Button

static var instance: ReportUI

func _init():
	instance = self

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.pressed.connect(on_button_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func display():
	set_visible(true)
	month_label.text = GameManager.instance.month_names[GameManager.instance.month]
	stability_label.text = "Station stability: %s" % GameManager.instance.stability_namers[GameManager.instance.station_stability]
	quota_label.text = "Material Quota: %s/%s" % [PlayerShip.instance.scrap, GameManager.instance.scrap_quota]
	delta_label.text = "Stability change: %s" % get_change_text()

func on_button_pressed():
	set_visible(false)
	GameManager.instance.next_month()

func get_change_text() -> String:
	var change = GameManager.instance.station_stability_change
	if change > 0:
		return "Good"
	else:
		return "Bad"
