extends Node3D
const F = preload("res://scripts/forms.gd")
func _ready() -> void:
	name="FirstCozyCornerKeepsake"
	F.finish(F.cylinder(self,Vector3(0,0.035,0),0.27,0.27,0.07,"d8bfa0"),"wood")
	F.box(self,Vector3(0,0.21,0),Vector3(0.29,0.28,0.24),"e6c3d3",0.025)
	var roof := PrismMesh.new()
	roof.size=Vector3(0.38,0.17,0.32)
	F.mesh(self,roof,Vector3(0,0.43,0),"b9a2d0")
	F.box(self,Vector3(0.09,0.47,-0.04),Vector3(0.045,0.12,0.05),"d5bccf",0.01)
	F.box(self,Vector3(0,0.16,0.127),Vector3(0.065,0.12,0.015),"fff0cf",0.008)
	for x in [-0.09,0.09]: F.box(self,Vector3(x,0.24,0.127),Vector3(0.045,0.055,0.012),"f9e3a8",0.005)
	F.box(self,Vector3(0,0.065,0.23),Vector3(0.43,0.085,0.028),"fff0db",0.014)
	var plaque := Label3D.new()
	plaque.text="First Cozy Corner"
	plaque.font_size=23
	plaque.pixel_size=0.0012
	plaque.modulate=Color("80697d")
	plaque.position=Vector3(0,0.065,0.249)
	add_child(plaque)
