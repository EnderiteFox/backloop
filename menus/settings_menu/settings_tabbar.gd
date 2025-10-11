extends TabBar

@export var tabs: Array[Control]


func _ready() -> void:
	if tabs.size() == 0:
		Game.print_error("No tabs configured")
		return
		
	if tabs.size() != self.tab_count:
		Game.print_error("The number of tabs specified is different from the number of tabs in the TabBar")
		return
		
	for tab in tabs:
		tab.visible = false
	tabs[0].visible = true

	self.tab_changed.connect(_on_tab_changed)
	
	
func _on_tab_changed(tab: int) -> void:
	for t in tabs:
		t.visible = false
	tabs[tab].visible = true
