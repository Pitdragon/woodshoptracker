extends Resource

class_name DatabaseManager

var db: SQLite
var path: String = "user://projects"

func _init() -> void:
	db = SQLite.new()
	db.path = path
	db.open_db()
	db.query("""CREATE TABLE if NOT EXISTS projects
			(id INTEGER PRIMARY KEY,
			project_name TEXT NOT NULL,
			customers_name text,
			date_created INTEGER,
			date_completed INTEGER,
			is_complete INTEGER DEFAULT 0);"""
			)
	db.query("""CREATE TABLE if NOT EXISTS materials
			(id INTEGER PRIMARY KEY,
			project_id INTEGER NOT NULL,
			material_name TEXT NOT NULL,
			cost REAL DEFAULT 0,
			FOREIGN KEY (project_id) REFERENCES projects(id));"""
			)
	db.close_db()

func add_new_project(projectname:String, customername:String):
	var created:int = Time.get_unix_time_from_system()
	db.open_db()
	db.query_with_bindings("""INSERT INTO projects
						(project_name, customers_name, date_created) VALUES (?,?,?);""",
						[projectname, customername, created])
	db.close_db()
