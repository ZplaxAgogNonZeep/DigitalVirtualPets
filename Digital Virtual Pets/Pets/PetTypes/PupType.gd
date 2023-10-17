extends Node

var implements = [Interface.PetType]

var waitIntervalMax := 10.0
var waitIntervalMin := 3.0

var petName := "Pup"


func roamBehavior():
	if not get_parent().isRoaming and $MoveTimer.is_stopped():
		print("Roam behavior called")
		randomize()
		$MoveTimer.start(randf_range(waitIntervalMin, waitIntervalMax))

func onTickHunger():
	pass

func onTickJoy():
	pass

func _on_move_timer_timeout():
	print("move timeout")
	get_parent().goToPosition(get_parent().getNextPosition())
