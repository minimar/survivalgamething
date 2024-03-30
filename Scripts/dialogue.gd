extends Node
@onready var dialogueBox = $"Dialogue Box"
var dialogueText:String
var dialoguePos:int
# Called when the node enters the scene tree for the first time.
func _ready(): # Replace with function body.
	dialogueText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean ultricies sed nunc non aliquam. Curabitur tincidunt consectetur nulla, a ultricies lectus pulvinar nec. Nulla sit amet aliquet magna. Phasellus in dapibus ligula, eget cursus est. Morbi cursus ac metus eu sollicitudin. Nam placerat risus id lobortis gravida. Praesent vel malesuada dolor. Mauris eget nisi facilisis, tempus tellus quis, egestas lacus. Mauris in varius diam. Nullam ullamcorper elit quis urna consequat placerat. Ut nisi quam, posuere eu auctor at, hendrerit fermentum mi. Aenean fringilla, nunc vel suscipit porta, nunc velit interdum dolor, nec finibus est tellus non lacus."
	dialoguePos = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	dialogueBox.text = writeText(dialogueText, dialoguePos)
	dialoguePos += 1
func dialogBox(ID):
	pass

func writeText(text,value):
	text = text.left(value)
	return text
	
