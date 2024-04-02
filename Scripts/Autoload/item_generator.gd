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
	},
	'test': {
		'itemID': 'test',
		'itemName': 'TESTING ITEM',
		'description': 'TEST',
		'sprite': 2,
		'stackable': true,
		'maxStack': 99
	},
	'gun': {
		'itemID': 'gun',
		'itemName': 'Handgun',
		'description': 'Your handgun.',
		'sprite': 3,
		'stackable': false
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
	},
	'testHead': {
		"itemID": "testHead",
		"itemName": "TEST Hat",
		"description": "TEST.",
		'sprite': 0,
		'usable': true,
		'stackable': false,
		'type': 'head',
		'armorRating': 0,
		'movementReduction': 0
	},
	'testTorso': {
		"itemID": "testTorso",
		"itemName": "TEST Shirt",
		"description": "TEST.",
		'sprite': 1,
		'usable': true,
		'stackable': false,
		'type': 'torso',
		'armorRating': 0,
		'movementReduction': 0
	},
	'testLegs': {
		"itemID": "testLegs",
		"itemName": "TEST Pants",
		"description": "TEST.",
		'sprite': 2,
		'usable': true,
		'stackable': false,
		'type': 'legs',
		'armorRating': 0,
		'movementReduction': 0
	}
}

var foodDict = {
	'steak': {
		'itemID': 'steak',
		'itemName': 'Cooked Steak',
		'description': 'A cooked steak.',
		'sprite': 0,
		'stackable': true,
		'maxStack': 5,
		'usable': true,
		'foodSaturation': 50,
		'type': 'cooked'
	},
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
	elif foodDict.has(itemName):
		newItem = Food.new()
		for key in foodDict[itemName]:
			match key:
				'itemID': newItem.itemID = foodDict[itemName][key]
				'itemName': newItem.itemName = foodDict[itemName][key]
				'description': newItem.description = foodDict[itemName][key]
				'sprite': newItem.sprite = foodDict[itemName][key]
				'stackable': newItem.stackable = foodDict[itemName][key]
				'maxStack': newItem.maxStack = foodDict[itemName][key]
				'usable': newItem.usable = foodDict[itemName][key]
				'foodSaturation': newItem.foodSaturation = foodDict[itemName][key]
				'type': newItem.type = foodDict[itemName][key]
	
	if not newItem:
		printerr("Failed to make item: "+str(itemName))
	newItem.quantity = 1
	return newItem
