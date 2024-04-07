extends Node

#Returns a random member of the provided Array
func getRandomArrayMember(array: Array):
	if not array:
		return
	return array[randi_range(0,array.size()-1)]

func getLatestSave() -> Dictionary:
	var quickSaveTimeStamp = 0
	var quickSaveFile: FileAccess
	var quickSaveDict
	if FileAccess.file_exists("user://save.sav"):
		quickSaveFile = FileAccess.open("user://save.sav",FileAccess.READ)
		quickSaveDict = JSON.parse_string(quickSaveFile.get_line())
		quickSaveTimeStamp = quickSaveDict["unixTime"]
	var latestManualSaveFileName
	var dir = DirAccess.open("user://")
	if dir.dir_exists("Manual Saves"):
		dir.change_dir("Manual Saves")
		var files = dir.get_files()
		if files.size() > 0:
			latestManualSaveFileName = files[files.size()-1]
			if int(latestManualSaveFileName.right(-4)) > quickSaveTimeStamp:
				var manualSaveFile = FileAccess.open("user://Manual Saves/"+latestManualSaveFileName,FileAccess.READ)
				var manualSaveDict = JSON.parse_string(manualSaveFile.get_line())
				return manualSaveDict
	if quickSaveDict:
		return quickSaveDict
	else:
		return {}
