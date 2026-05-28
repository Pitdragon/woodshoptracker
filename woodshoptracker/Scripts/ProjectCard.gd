extends Control

@onready var project_name:Label = $PanelContainer/PanelVbox/NameLabel
@onready var customers_name:Label = $PanelContainer/PanelVbox/ColumnsHbox/RightsideValues/CustomersName
@onready var costs:Label = $"PanelContainer/PanelVbox/ColumnsHbox/RightsideValues/MaterialsCost"
@onready var date_created:Label = $PanelContainer/PanelVbox/ColumnsHbox/RightsideValues/DateCreated
@onready var popup_menu: PopupMenu = $PanelContainer/PopupMenu

var project_id: int
signal CardClicked(project_id)
signal DeleteClicked(project_id)

func _ready() -> void:
	card_setup({"id": 101, "project_name": "Dining Room Table", "customers_name": "Andy Tark", "date_created": "05-25-26" })
	popup_menu.id_pressed.connect(_on_popup_menu_id_pressed)

func card_setup(project_row: Dictionary):
	project_id = project_row.get("id", "")
	project_name.text = project_row.get("project_name","")
	customers_name.text = project_row.get("customers_name","")
	costs.text = "No Material Assigned"
	date_created.text = str(project_row.get("date_created",""))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			CardClicked.emit(project_id)
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			popup_menu.popup()
			popup_menu.position = get_global_mouse_position()

func _on_popup_menu_id_pressed(menu_id: int):
	match menu_id:
		0:
			print("Deleted pressed id: " + str(project_id))
			DeleteClicked.emit(project_id)
