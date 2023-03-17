extends Spatial

# Enumeration for drivetrain types
enum DrivetrainType {
	FWD,
	RWD,
	FOUR_WD
}

# Enumeration for transmission gears
enum Gear {
	NEUTRAL
	FIRST,
	SECOND,
	THIRD,
	FOURTH
	FIFTH,
	SIXTH,
	SEVENTH,
	EIGHT,
	NINTH,
	TENTH,
	ELEVENTH,
	REVERSE
}

export(DrivetrainType) var drivetrain_type: int = DrivetrainType.FWD

# Car properties
export var ENGINE_POWER = 60
export var AUTO_CLUTCH = false
export var STEER_DEADZONE = 0.1
export var STEER_FORCE = 100
export var WHEEL_FORCE_LIMIT = 10000
export var BRAKE_FORCE = 50


# Wheel and suspension node references
onready var front_left_wheel = $FrontLeftWheel
onready var front_right_wheel = $FrontRightWheel
onready var rear_left_wheel = $RearLeftWheel
onready var rear_right_wheel = $RearRightWheel

onready var front_left_suspension = $FrontLeftSuspension
onready var front_right_suspension = $FrontRightSuspension
onready var rear_left_suspension = $RearLeftSuspension
onready var rear_right_suspension = $RearRightSuspension

onready var front_axle = [front_left_suspension, front_right_suspension]
onready var rear_axle = [rear_left_suspension, rear_right_suspension]

onready var suspensions = front_axle + rear_axle

var gear = Gear.NEUTRAL


func _ready():
	enable_engine(true)
	
	# Set the wheel force limits for all wheels
	for suspension in suspensions:
		suspension.set_param_z(Generic6DOFJoint.PARAM_ANGULAR_MOTOR_FORCE_LIMIT, WHEEL_FORCE_LIMIT)

func enable_engine(value):
	for suspension in suspensions:
		suspension.set_flag_z(Generic6DOFJoint.FLAG_ENABLE_MOTOR, value)
	
func handbrake(amount):
	for suspension in suspensions:
		suspension.set_param_z(Generic6DOFJoint.PARAM_ANGULAR_MOTOR_TARGET_VELOCITY, amount)

func throttle(amount):
	if amount == 0:
		enable_engine(false)
	else:
		enable_engine(true)

		if drivetrain_type in [DrivetrainType.FWD, DrivetrainType.FOUR_WD]:
			for suspension in front_axle:
				suspension.set_param_z(Generic6DOFJoint.PARAM_ANGULAR_MOTOR_TARGET_VELOCITY, -amount * ENGINE_POWER)
			
		if drivetrain_type in [DrivetrainType.RWD, DrivetrainType.FOUR_WD]:
			for suspension in rear_axle:
				suspension.set_param_z(Generic6DOFJoint.PARAM_ANGULAR_MOTOR_TARGET_VELOCITY, -amount * ENGINE_POWER)
	
func steer(amount):
	var angle = 0.523599

	for suspension in front_axle:
		if amount < STEER_DEADZONE and amount > -STEER_DEADZONE:
			suspension.set_param_y(Generic6DOFJoint.PARAM_ANGULAR_LOWER_LIMIT, 0)
		else:
			if amount > 0:
				suspension.set_param_y(Generic6DOFJoint.PARAM_ANGULAR_UPPER_LIMIT, angle * amount)
			else:
				suspension.set_param_y(Generic6DOFJoint.PARAM_ANGULAR_LOWER_LIMIT, angle * amount)
				
		suspension.set_param_y(Generic6DOFJoint.PARAM_ANGULAR_MOTOR_TARGET_VELOCITY, amount * STEER_FORCE)
	
# Apply brake force
func brake(amount):
	for suspension in suspensions:
		suspension.set_param_z(Generic6DOFJoint.PARAM_ANGULAR_MOTOR_TARGET_VELOCITY, amount * BRAKE_FORCE)

	
func clutch(amount):
	pass # unfinished
