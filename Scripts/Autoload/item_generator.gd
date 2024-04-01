extends Node


var basicDict = {
	'rock': {
		'itemID':'rock',
		'itemName': "Rock",
		'description': "A piece of rock.",
		'sprite': 0,
		'stackable': true,
		'maxStack': 99
	},
	'wood': {
		'itemID':'wood',
		'itemName': "Wood",
		'description': "A piece of lumber.",
		'sprite': 1,
		'stackable': true,
		'maxStack': 15
	},
	'bullet': {
		'itemID': 'bullet',
		'itemName': "Bullets",
		'description': '9mm handgun rounds.',
		'sprite': 2,
		'stackable': true,
		'maxStack': 99
	}
}

var clothingDict = {
	'basicHead': {
		"itemID": "basicHead",
		"itemName": "Basic Hat",
		"description": "Your basic hat.",
		'sprite': 0,
		'usable': true,
		'stackable': false,
		'type': 'head',
		'armorRating': 0,
		'movementReduction': 0
	},
	'basicTorso': {
		"itemID": "basicTorso",
		"itemName": "Basic Shirt",
		"description": "Your basic shirt.",
		'sprite': 1,
		'usable': true,
		'stackable': false,
		'type': 'torso',
		'armorRating': 0,
		'movementReduction': 0
	},
	'basicLegs': {
		"itemID": "basicLegs",
		"itemName": "Basic Pants",
		"description": "Your basic pants.",
		'sprite': 2,
		'usable': true,
		'stackable': false,
		'type': 'legs',
		'armorRating': 0,
		'movementReduction': 0
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
				'itemID': newItem.itemID = basicDict[itemName][key]
				'itemName': newItem.itemName = basicDict[itemName][key]
				'description': newItem.description = basicDict[itemName][key]
				'sprite': newItem.sprite = basicDict[itemName][key]
				'stackable': newItem.stackable = basicDict[itemName][key]
				'maxStack': newItem.maxStack = basicDict[itemName][key]
	elif clothingDict.has(itemName):
		newItem = Clothing.new()
		for key in clothingDict[itemName]:
			match key:
				'itemID': newItem.itemID = clothingDict[itemName][key]
				'itemName': newItem.itemName = clothingDict[itemName][key]
				'description': newItem.description = clothingDict[itemName][key]
				'sprite': newItem.sprite = clothingDict[itemName][key]
				'stackable': newItem.stackable = clothingDict[itemName][key]
				'type': newItem.type = clothingDict[itemName][key]
				'armorRating': newItem.armorRating = clothingDict[itemName][key]
				'movementReduction': newItem.movementReduction = clothingDict[itemName][key]
				'usable': newItem.usable = clothingDict[itemName][key]
	
	
	if not newItem:
		printerr("Failed to make item: "+str(itemName))
	return newItem
