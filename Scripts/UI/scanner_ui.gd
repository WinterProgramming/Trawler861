class_name ScannerUI
extends Control

var widgets: Array[ScannerWidget]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for c in get_children():
		var widget = c as ScannerWidget
		if widget:
			widgets.append(widget)
	
	PlayerShip.instance.on_scan_enter.connect(on_scan_enter)
	PlayerShip.instance.on_scan_exit.connect(on_scan_exit)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_scan_enter(scannable: Scannable):
	var widget = get_widget()
	if !widget:
		return
	
	widget.set_data(scannable)
	
func on_scan_exit(scannable: Scannable):
	for w in widgets:
		if w.scannable == scannable:
			w.clear()


func get_widget() -> ScannerWidget:
	for w in widgets:
		if w.scannable == null:
			return w
	return null
