extends TextureButton
var item:
	set(value):
		item = value
		if item:
			$Sprite.visible = true
			$Sprite.frame = item.sprite
			$Quantity.text = str(item.quantity)
		else:
			$Sprite.visible = false
			$Quantity.text = ""



