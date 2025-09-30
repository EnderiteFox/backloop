class_name CameraTransition
extends Object
## An object only containing two signals
## Is used for camera transitions, to handle transition end and interruptions safely without having to disconnect signals
## The [code]CameraTransition[/code] is destroyed once the transition ends or is interrupted, so functions bound to
## signals don't risk being called multiple times

@warning_ignore("unused_signal")
signal transition_end
@warning_ignore("unused_signal")
signal transition_interrupted
