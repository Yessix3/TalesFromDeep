class_name EventData
extends Resource

@export var event_id: String           # z.B. "event_01"
@export var title: String
@export_multiline var message: String
@export var options: Array[OptionButtonData]