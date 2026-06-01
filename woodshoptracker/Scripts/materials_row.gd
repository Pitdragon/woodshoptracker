extends HBoxContainer
@onready var number:LineEdit = $NumberOfMaterials
@onready var material_description: LineEdit = $ProjectsName
@onready var cost: LineEdit = $Cost
@onready var total: Label = $TotalCostLabel
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cost.text_submitted.connect(calculate_total)
	cost.focus_exited.connect(calculate_total)
	cost.focus_entered.connect(func(): cost.text = "")
	number.text_submitted.connect(calculate_total)
	number.focus_exited.connect(calculate_total)
	number.focus_entered.connect(func(): number.text = "")

func calculate_total(_text= ""):

	var totalcost: float
	var price := cost.text
	if price.strip_edges() == "":
		cost.text = "0.00"
		return
	if price.is_valid_float() == false:
		cost.text = "0.00"
		return
	totalcost = number.text.to_float() * price.to_float()
	total.text = "Total: $" + "%.2f" % totalcost

func get_material_data() -> Dictionary:
	if is_row_valid() == true:
		var data = {
			"number": number.text.to_int(),
			"Material_type": material_description.text,
			"price": cost.text.to_float()
		}
		return data
	else:
		return {}

func  has_valid_quantity() -> bool:
	return number.text.strip_edges() != "" and number.text.is_valid_int()

func has_valid_mareial_type() -> bool:
	return material_description.text.strip_edges() != ""

func has_valid_price() -> bool:
	return cost.text.strip_edges() != "" and cost.text.is_valid_float()

func is_row_valid() -> bool:
	return has_valid_quantity() and has_valid_mareial_type() and has_valid_price()
