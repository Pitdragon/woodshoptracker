extends PanelContainer

@onready var project_name:Label = $PanelVbox/NameLabel
@onready var customers_name:Label = $PanelVbox/ColumnsHbox/RightsideValues/CustomersName
@onready var costs:Label = $"PanelVbox/ColumnsHbox/RightsideValues/Materials Cost"
@onready var date_created:Label = $PanelVbox/ColumnsHbox/RightsideValues/DateCreated

var project_id: int
signal CardClicked(project_id)

func _ready() -> void:
	card_setup({"id": 101, "project_name": "Dining Room Table", "customers_name": "Andy Tark", "date_created": "05-25-26" })

func card_setup(project_row: Dictionary):
	project_id = project_row.get("id", "")
	project_name.text = project_row.get("project_name","")
	customers_name.text = project_row.get("customers_name","")
	costs.text = "No Material Assigned"
	date_created.text = project_row.get("date_created","")

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			CardClicked.emit()
			print("card Clicked")
