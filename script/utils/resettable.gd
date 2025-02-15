extends RefCounted
class_name Resettable
## A resettable object.
## Contains a single reset function that calls the reset function of all properties of the class.

## By default, reset the object when it is created.
## This ensures that the reset method has roughly the same behaviour than [method Object._init].
## To disable this, override the _init function to not call reset.
func _init() -> void:
	reset()

## Resets the object.
## Equivalent to calling [code]reset_object(self)[/code].
## Override to reset the properties of the object.
## Make sure to call [code]super.reset()[/code] to keep the recusive reset behaviour
func reset() -> void:
	reset_object(self)

## Resets all the [Resettable] properties of the given [Object].
## Allows using the same recursive behaviour of [Resettable] on objects that are not resettable.
static func reset_object(object: Object) -> void:
	for property_dict in object.get_property_list():
		var property: Variant = object.get(property_dict["name"])
		if !is_instance_valid(property):
			continue
		if property is Resettable:
			property.reset()
