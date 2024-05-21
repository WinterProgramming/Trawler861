extends Control
class_name ProgressUI

@export var date_label: Label
@export var trip_rects: Array[ColorRect]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.instance.month_updated.connect(on_month_updated)
	GameManager.instance.void_trips_updated.connect(on_void_trips_updated)
	on_void_trips_updated(0)


func on_month_updated(month: GameManager.Month):
	date_label.text = "%s 2348" % GameManager.instance.month_names[month]

func on_void_trips_updated(trips: int):
	for i in trip_rects.size():
		if i <= (trips - 1):
			trip_rects[i].color = Color.GREEN
		else:
			trip_rects[i].color = Color.GRAY
