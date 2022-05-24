tool
extends EditorPlugin


enum {
	MoveHere,
	MoveHereWithGridSnap,
	InvertScaleHorizontally,
	InvertScaleVertically,
	ResetScale,
}


var menu : PopupMenu
var target_pos : Vector2
var target_node : Node2D

var snap_offset_x = 0
var snap_offset_y = 0
var snap_step_x = 8
var snap_step_y = 8


func popup_menu(position):
	target_pos = position
	menu.popup(Rect2(get_editor_interface().get_editor_viewport().get_global_mouse_position(), Vector2(1, 1)))


func _enter_tree():
	watch_snap_step_settings(get_editor_interface().get_base_control())
	menu = PopupMenu.new()
	menu.add_item("Move here", MoveHere)
	menu.add_item("Move here with Grid Snap", MoveHereWithGridSnap)
	menu.add_item("Invert Scale Horizontally", InvertScaleHorizontally)
	menu.add_item("Invert Scale Vertically", InvertScaleVertically)
	menu.add_item("Reset Scale", ResetScale)
	menu.connect("id_pressed", self, "menu_id_pressed")
	
	get_editor_interface().get_editor_viewport().add_child(menu)


func forward_canvas_gui_input(event):
	if !is_instance_valid(target_node):
		return
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT && event.pressed:
			if get_editor_interface().get_edited_scene_root().has_method("get_global_mouse_position"):
				popup_menu(get_editor_interface().get_edited_scene_root().get_global_mouse_position())
				return true
			else:
				print("Error: Node2D Context Menu cannot function as the current scene's root node is not of the 'CanvasItem' base class.")
				return false


func _exit_tree():
	if is_instance_valid(menu):
		menu.queue_free()
	target_node = null


func check_node_type(var node_type):
	if node_type is Node2D:
		target_node = node_type
		return true


func menu_id_pressed(id):
	if !is_instance_valid(target_node):
		return
	match(id):
		MoveHere:
			move_here()
		MoveHereWithGridSnap:
			move_here_with_grid_snap()
		InvertScaleHorizontally:
			invert_scale_horizontally()
		InvertScaleVertically:
			invert_scale_vertically()
		ResetScale:
			reset_scale()


func move_here():
	var undo_redo = get_undo_redo()
	var _action_name = str("Move CanvasItem \"", target_node.name, "\" to ", target_pos)
	undo_redo.create_action(_action_name)
	undo_redo.add_undo_property(target_node, "global_position", target_node.global_position)
	undo_redo.add_do_property(target_node, "global_position", target_pos)
	target_node.global_position = target_pos
	undo_redo.commit_action()


func move_here_with_grid_snap():
	var undo_redo = get_undo_redo()
	target_pos = Vector2(round(target_pos.x / snap_step_x) * snap_step_y, round(target_pos.y / snap_step_y) * snap_step_y) + Vector2(snap_offset_x, snap_offset_y)
	var _action_name = str("Move CanvasItem \"", target_node.name, "\" to ", target_pos, " with Grid Snap")
	undo_redo.create_action(_action_name)
	undo_redo.add_undo_property(target_node, "global_position", target_node.global_position)
	undo_redo.add_do_property(target_node, "global_position", target_pos)
	target_node.global_position = target_pos
	undo_redo.commit_action()


func invert_scale_horizontally():
	var undo_redo = get_undo_redo()
	var new_scale = target_node.scale * Vector2(-1, 1)
	var _action_name = str("Invert CanvasItem \"", target_node.name, "\" scale horizontally")
	undo_redo.create_action(_action_name)
	undo_redo.add_undo_property(target_node, "scale", target_node.scale)
	undo_redo.add_do_property(target_node, "scale", new_scale)
	target_node.scale = new_scale
	undo_redo.commit_action()


func invert_scale_vertically():
	var undo_redo = get_undo_redo()
	var new_scale = target_node.scale * Vector2(1, -1)
	var _action_name = str("Invert CanvasItem \"", target_node.name, "\" scale vertically")
	undo_redo.create_action(_action_name)
	undo_redo.add_undo_property(target_node, "scale", target_node.scale)
	undo_redo.add_do_property(target_node, "scale", new_scale)
	target_node.scale = new_scale
	undo_redo.commit_action()


func reset_scale():
	var undo_redo = get_undo_redo()
	var new_scale = Vector2(1, 1)
	var _action_name = str("Reset CanvasItem \"", target_node.name, "\" scale to ", new_scale)
	undo_redo.create_action(_action_name)
	undo_redo.add_undo_property(target_node, "scale", target_node.scale)
	undo_redo.add_do_property(target_node, "scale", new_scale)
	target_node.scale = new_scale
	undo_redo.commit_action()


func watch_snap_step_settings(root:Node):
	for child in root.get_children():
		if child is Label:
			if child.text == tr("Grid Offset:"):
				var container : GridContainer = child.get_node("..")
				var offset_x : SpinBox = container.get_child(1)
				var offset_y : SpinBox = container.get_child(2)
				var step_x : SpinBox = container.get_child(4)
				var step_y : SpinBox = container.get_child(5)
				
				if !offset_x.is_connected("value_changed", self, "snap_offset_x_changed"):
					offset_x.connect("value_changed", self, "snap_offset_x_changed" )
				if !offset_y.is_connected("value_changed", self, "snap_offset_y_changed"):
					offset_y.connect("value_changed", self, "snap_offset_y_changed" )
				if !step_x.is_connected("value_changed", self, "snap_step_x_changed"):
					step_x.connect("value_changed", self, "snap_step_x_changed" )
				if !step_y.is_connected("value_changed", self, "snap_step_y_changed"):
					step_y.connect("value_changed", self, "snap_step_y_changed" )
				
				snap_offset_x = offset_x.value
				snap_offset_y = offset_y.value
				snap_step_x = step_x.value
				snap_step_y = step_y.value
				return
		watch_snap_step_settings(child)


func snap_offset_x_changed(value):
	snap_offset_x = value


func snap_offset_y_changed(value):
	snap_offset_y = value


func snap_step_x_changed(value):
	snap_step_x = value


func snap_step_y_changed(value):
	snap_step_y = value
