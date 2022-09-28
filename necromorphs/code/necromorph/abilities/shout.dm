/// We use 2 different tyoes for the similar ability to ensure locate() works properly
/*
	Shout
*/

/datum/action/cooldown/necro/shout
	name = "Shout"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	desc = "Shout to disorientate your enemies."
	cooldown_time = 8 SECONDS
	click_to_activate = FALSE

/datum/action/cooldown/necro/shout/Activate(atom/target)
	StartCooldown()
	var/mob/living/carbon/necromorph/holder = owner
	holder.play_necro_sound(SOUND_SHOUT, VOLUME_HIGH, TRUE, 2)
	var/matrix/new_matrix = matrix(holder.transform)
	var/shake_dir = pick(-1, 1)
	new_matrix.Turn(17*shake_dir)
	animate(holder, transform = new_matrix, pixel_x = holder.pixel_x + 6*shake_dir, time = 1)
	spawn(1)
		animate(holder, transform = matrix(), pixel_x = holder.pixel_x-6*shake_dir, time = 11, easing = ELASTIC_EASING)
	new /obj/effect/temp_visual/expanding_circle(holder.loc, 2, 3 SECONDS)	//Visual effect
	for(var/mob/M in range(8, src))
		var/distance = get_dist(src, M)
		var/intensity = 5 - (distance * 0.3)
		var/duration = (7 - (distance * 0.5)) SECONDS
		shake_camera(M, duration, intensity)

/*
	Scream
*/

/datum/action/cooldown/necro/scream
	name = "Scream"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	desc = "Scream to disorientate your enemies."
	cooldown_time = 8 SECONDS
	click_to_activate = FALSE

/datum/action/cooldown/necro/scream/Activate(atom/target)
	StartCooldown()
	var/mob/living/carbon/necromorph/holder = owner
	holder.play_necro_sound(SOUND_SHOUT_LONG, VOLUME_HIGH, TRUE, 2)
	RegisterSignal(holder, COMSIG_MOVABLE_PRE_MOVE, .proc/on_move)
	spawn(1)
		UnregisterSignal(holder, COMSIG_MOVABLE_PRE_MOVE)
	var/matrix/new_matrix = matrix(holder.transform)
	var/shake_dir = pick(-1, 1)
	new_matrix.Turn(17*shake_dir)
	animate(holder, transform = new_matrix, pixel_x = holder.pixel_x + 6*shake_dir, time = 1)
	spawn(1)
		animate(holder, transform = matrix(), pixel_x = holder.pixel_x-6*shake_dir, time = 11, easing = ELASTIC_EASING)
	new /obj/effect/temp_visual/expanding_circle(holder.loc, 2, 3 SECONDS)	//Visual effect
	for(var/mob/M in range(8, src))
		var/distance = get_dist(src, M)
		var/intensity = 5 - (distance * 0.3)
		var/duration = (7 - (distance * 0.5)) SECONDS
		shake_camera(M, duration, intensity)

/datum/action/cooldown/necro/scream/proc/on_move(mob/living/carbon/necromorph/holder)
	return COMPONENT_MOVABLE_BLOCK_PRE_MOVE
