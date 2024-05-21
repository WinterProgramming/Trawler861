extends Control
class_name RadioUI

signal on_label_read_finished

@export var line_container: Control
@export var chat_start_audio: AudioStreamPlayer

static var instance: RadioUI
var labels: Array[RadioLabel]
var queue: Array[String]
var active_label: RadioLabel

func _init():
	instance = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_text(text: String):
	queue.append(text)
	if active_label == null:
		dequeue()

func dequeue():
	if queue.size() == 0:
		return
	
	var text = queue.pop_front()
	active_label = get_label()
	line_container.move_child(active_label, labels.size() - 1)
	active_label.set_data(text)
	active_label.on_finished_reading.connect(on_active_label_read_finished)
	chat_start_audio.play()

func get_label() -> RadioLabel:
	if labels.size() == 0:
		for c in line_container.get_children():
			var l = c as RadioLabel
			if l:
				labels.append(l)
	
	for l in labels:
		if l.can_use():
			return l
	return null

func on_active_label_read_finished():
	on_label_read_finished.emit()
	active_label.on_finished_reading.connect(on_active_label_read_finished)
	active_label = null
	dequeue()
