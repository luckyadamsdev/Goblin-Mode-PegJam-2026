extends Label
class_name TimerLabel

## countdown value to control time of one second
var countdown:float = 100.0

## whether this should be currentl counting
var counting:bool = false

var seconds:int = 0:
	set(p):
		seconds = p
		text = "%d" % seconds

func start() -> void:
	seconds = 0
	visible = true
	countdown = 1.0
	counting = true
	
func _process(delta: float) -> void:
	if !counting:
		return
	countdown -= delta
	if countdown < 0.0:
		countdown += 1
		seconds = seconds + 1
