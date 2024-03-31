extends Node


var basicDict = {
	'rock': {
		'itemName': "Rock",
		'description': "A piece of rock.",
		'sprite': 0,
		'stackable': true,
		'maxStack': 99
	},
	'wood': {
		'itemName': "Wood",
		'description': "A piece of lumber.",
		'sprite': 1,
		'stackable': true,
		'maxStack': 15
	}
}
var foodDict = {
	
}

func makeItem(itemName):
	var newItem
	if basicDict.has(itemName):
		newItem = Item.new()
		for key in basicDict[itemName]:
			#print(key)
			match key:
				'itemName': newItem.itemName = basicDict[itemName][key]
				'description': newItem.description = basicDict[itemName][key]
				'sprite': newItem.sprite = basicDict[itemName][key]
				'stackable': newItem.stackable = basicDict[itemName][key]
				'maxStack': newItem.maxStack = basicDict[itemName][key]
	
	if not newItem:
		printerr("Failed to make item: "+str(itemName))
	return newItem
