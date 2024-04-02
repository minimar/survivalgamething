extends TextureButton
var item:
	set(value):
		item = value
		if item:
			$Sprite.visible = true
			$Sprite.frame = item.sprite
			if item.stackable:
				$Quantity.text = str(item.quantity)
		else:
			$Sprite.visible = false
			$Quantity.text = ""

var selected:
	set(value):
		selected = value
		$SelectedSprite.visible = selected
