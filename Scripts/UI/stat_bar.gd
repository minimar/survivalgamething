extends Control

var type: String:
	set(value):
		type = value
		if type == 'health':
			$AnimatedSprite2D.frame = 0
		else:
			$AnimatedSprite2D.frame = 1

var halved: bool:
	set(value):
		halved = value
		if halved:
			$AnimatedSprite2D.frame += 2
