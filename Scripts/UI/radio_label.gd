extends Label
class_name RadioLabel

signal on_finished_reading

const WAIT_SECONDS = 8.0
const FADE_SECONDS = 2.0

var tween: Tween

func _ready():
	set_visible(false)

func set_data(t: String):
	set_visible(true)
	var col = modulate
	col.a = 1.0
	modulate = col
	text = ""
	
	if tween:
		tween.stop()
	tween = create_tween()
	tween.tween_property(self, "text", t, 0.05 * t.length())
	tween.tween_callback(read_finished)
	tween.tween_interval(WAIT_SECONDS)
	tween.tween_property(self, "modulate", Color(col, 0.0), FADE_SECONDS)
	tween.finished.connect(tween_finished)

func tween_finished():
	set_visible(false)
	tween = null

func read_finished():
	on_finished_reading.emit()

func can_use() -> bool:
	return tween == null
