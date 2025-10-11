class_name SettingRange
extends Range

@export var setting: Settings.Type


func _ready() -> void:
	self.value = Settings.get_setting(setting)
	self.value_changed.connect(Settings.set_setting.bind(setting))
	Settings.setting_changed.connect(_on_setting_changed)
	
	
func _on_setting_changed(type: Settings.Type, val: Variant) -> void:
	if type == setting:
		self.value = val
