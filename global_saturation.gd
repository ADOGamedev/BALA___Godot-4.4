extends Node

var canvas_layer: CanvasLayer
var shader_rect: ColorRect
   
func create_env():
    canvas_layer = CanvasLayer.new()
    add_child(canvas_layer)
    
    shader_rect = ColorRect.new()
    shader_rect.material = ShaderMaterial.new()
    shader_rect.material.shader = load("res://assets/shaders/saturation_shader.gdshader")
    shader_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    canvas_layer.add_child(shader_rect)

    shader_rect.anchor_top = 0
    shader_rect.anchor_bottom = 1
    shader_rect.anchor_left = 0
    shader_rect.anchor_right = 1

func set_saturation(value: float):
    shader_rect.material.set_shader_parameter("saturation", value / 100)
