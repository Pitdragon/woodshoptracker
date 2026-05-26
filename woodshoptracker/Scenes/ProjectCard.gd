extends PanelContainer

@onready var project_name:Label = $PanelVbox/NameLabel
@onready var customers_name:Label = $PanelVbox/ColumnsHbox/RightsideValues/CustomersName
@onready var costs:Label = $"PanelVbox/ColumnsHbox/RightsideValues/Materials Cost"
@onready var created:Label = $PanelVbox/ColumnsHbox/RightsideValues/DateCreated

var project_id: int

func card_setup(project:ProjectClass):
	project_id = project.id
	project_name.text = project.name
	customers_name.text = project.customers.name
	costs.text = str(project.material_costs())
	created.text = str(project.date_created)

# fix func to use database instead of class.
