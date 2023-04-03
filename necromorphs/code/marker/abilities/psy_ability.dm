/datum/action/cooldown/necro/psy
	name = "Generic psy ability"
	button_icon = 'necromorphs/icons/hud/signal_icons.dmi'
	cooldown_time = 0.1 SECONDS
	click_to_activate = TRUE
	var/cost = 0
	var/click_through_static = FALSE
	var/marker_flags = SIGNAL_ABILITY_PRE_ACTIVATION|SIGNAL_ABILITY_POST_ACTIVATION

/datum/action/cooldown/necro/psy/New(Target, original, cooldown)
	..()
	name += " | Cost: [cost] psy"

/// Intercepts client owner clicks to activate the ability
/datum/action/cooldown/necro/psy/InterceptClickOn(mob/camera/marker_signal/caller, params, atom/target)
	if(!IsAvailable())
		return FALSE
	if(!target)
		return FALSE
	if(caller.psy_energy < cost)
		to_chat(caller, span_notice("You don't have enough psy to use this ability"))
		return FALSE

	if(istype(target, /atom/movable/screen/cameranet_static))
		if(!click_through_static)
			return FALSE
		var/list/modifiers = params2list(params)
		var/new_target = parse_caught_click_modifiers(modifiers, get_turf(caller), caller.client)
		params = list2params(modifiers)
		if(!new_target)
			return FALSE
		target = new_target

	// The actual action begins here
	if(!PreActivate(target))
		return FALSE

	// And if we reach here, the action was complete successfully
	if(unset_after_click)
		unset_click_ability(caller, refund_cooldown = FALSE)
	caller.next_click = world.time + click_cd_override

	return TRUE

/datum/action/cooldown/necro/psy/Activate(atom/target)
	var/mob/camera/marker_signal/caller = owner
	caller.change_psy_energy(-cost)
	..()
