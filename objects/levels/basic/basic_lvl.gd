extends Node2D

@onready var city = $City

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasModulate/Panel.city = city


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func show_info_pan(text_):
	$CanvasModulate/info_panel/RichTextLabel.text = text_
	$CanvasModulate/info_panel.visible = true

func _on_undo_btn_pressed() -> void:
	city.undo_move()

func fill_console(text_):
	$CanvasModulate/console_pnl/consol.append_text(str(text_) + "\n")
