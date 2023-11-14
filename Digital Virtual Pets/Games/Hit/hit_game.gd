extends Control

var implements = [Interface.MiniGame]

@export_category("Stat Values")
@export var joyIncrement : int
@export var statIncrement : int
@export var statToIncrease : Enums.AbilityStat
@export_category("Game Values")
@export var gameDuration : float
@export var mashGoal : int
@export var mashMax : int
@export var decreaseFrequency : float
@export var decreaseAmount : int
@export var mashMeter : Node2D

var playMenu : Panel
var connectedPet : Node2D
var gameRunning : bool
var mashAmount : int = 0
var gameIteration : int = 3
var mashMode := false

func _process(delta):
	if gameRunning and mashMode and mashAmount > 0 and not $MashDecrease.is_stopped():
		pass

func startGame(pet : Node2D, playMenu : Panel):
	connectedPet = pet
	self.playMenu = playMenu
	$PseudoPet.sprite.set_sprite_frames(pet.sprite.sprite_frames)
	$PseudoPet.sprite.offset = pet.sprite.offset
	$PseudoPet.sprite.animation = "Idle"
	updateGameText("3")
	mashMeter.initializeMeter(mashMax, mashGoal)
	$Timer.start(1)
	gameRunning = true

func endGame():
	playMenu.closeMenu()
	queue_free()

func onWin():
	updateGameText("WIN!")
	gameRunning = false
	print("You Win!")
	connectedPet.receivePlay(joyIncrement, statToIncrease, statIncrement)
	await get_tree().create_timer(1).timeout
	endGame()

func onLose():
	updateGameText("LOSE!")
	gameRunning = false
	print("You Lose!")
	await get_tree().create_timer(1).timeout
	endGame()

func updateGameText(text : String):
	$Status.text = text

func updateMashBar(value : int, maxAmount : int):
	mashMeter.updateBar(mashAmount, mashMax)

func takeInput(input : Enums.InputType):
	if gameRunning and mashMode:
			match input:
				Enums.InputType.MIDDLEBUTTON:
					mashAmount += 1
					updateMashBar(mashAmount, mashMax)


func _on_timer_timeout():
	if gameIteration > 0:
		gameIteration -= 1
		updateGameText(str(gameIteration))
		$Timer.start(1)
	elif gameIteration == 0:
		updateGameText("START HITTING!!")
		$Timer.start(gameDuration)
		mashMode = true
	else:
		if mashAmount >= mashGoal:
			onWin()
		else:
			onLose()

func tickMashDecrease():
	if mashAmount > 0:
		mashAmount -= decreaseAmount
		
	if mashAmount < 0:
		mashAmount = 0
	updateMashBar(mashAmount, mashMax)
