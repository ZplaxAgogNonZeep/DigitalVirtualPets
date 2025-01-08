extends Node2D

const TIMER_TIME := 5

@export_category("Object References")
@export var device : Node2D
#@export var activePet : Node2D
@export var objectContainer : Node2D
@export var petManager : Node2D
@export var menuManager : Node2D
@export var boundries : Array[Marker2D] # 0 = Left | 1 = Right
@export var ObjectSpawnLocations : Array[Marker2D]
@export_category("Spawnable Objects")
@export var foodInstance : PackedScene

var evolveInterval = 15

var _spawnpointStatus = [true, true, true, true]

func _ready():
	GameEvents.NewPetSpawned.connect(petSpawned)
	GameEvents.FeedPet.connect(feed)
	GameEvents.ClearObjects.connect(clearAllObjects)
	GameEvents.StartNeedsTimers.connect(_startNeedsTimers)
	
	GameEvents.SpawnPetOnStart.emit()


func _process(delta: float) -> void:
	#_proactivityBehavior()
	pass


func _unhandled_input(event):
	if Input.is_action_just_pressed("Debug"):
		_evolveCheck()
		Engine.time_scale = .5

#region Proactivity Events

func _proactivityBehavior():
	if (!Settings.isUsingProactivity):
		return
	
	Settings.windowFocused = DisplayServer.window_is_focused()
	
	
	
	if (Settings.windowFocused and Engine.time_scale == 1):
		pass
	else:
		pass

func test():
	#void window_move_to_foreground(window_id: int = 0)
	#void window_request_attention(window_id: int = 0)
	pass

#endregion

#region Events 

func feed():
	var food = foodInstance.instantiate()
	food.stopFallingAt = boundries[0].position.y
	if (not _spawnpointStatus.has(true)):
		food.queue_free()
		return
	while true:
		randomize()
		var spawnNumber = randi_range(0, 3)
		if (_spawnpointStatus[spawnNumber]):
			food.position = ObjectSpawnLocations[spawnNumber].position
			break
	objectContainer.add_child(food)

func petSpawned(isEgg := false):
	if (!isEgg):
		_startNeedsTimers()
	$GameTimers/EvolveTimer.start(Pet.EVOLVE_INTERVALS[petManager.stage])


func _startNeedsTimers():
	randomize()
	$GameTimers/HungerTimer.start((randf_range(3, 15)) * device.chatSpeed)
	randomize()
	$GameTimers/JoyTimer.start((randf_range(3, 15)) * device.chatSpeed)


func clearAllObjects():
	for x in range(objectContainer.get_child_count()):
		objectContainer.get_child(x).queue_free()

#endregion

#region Timer Controls 

func tickHunger():
	GameEvents.TickHunger.emit()
	randomize()
	$GameTimers/HungerTimer.start((randf_range(3, 15)) * device.chatSpeed)


func tickJoy():
	GameEvents.TickJoy.emit()
	randomize()
	$GameTimers/JoyTimer.start((randf_range(3, 15)) * device.chatSpeed)


func _evolveCheck():
	print("Check for Evolve!")
	GameEvents.EvolveCheck.emit()
	$GameTimers/EvolveTimer.start(evolveInterval)

#endregion

#region Signals

func _foodColliderEntered(body, number = 0):
	if (Interface.hasInterface(body, Interface.Food)):
		_spawnpointStatus[number] = false

func _foodColliderExited(body, number = 0):
	if (Interface.hasInterface(body, Interface.Food)):
		_spawnpointStatus[number] = true

#endregion

