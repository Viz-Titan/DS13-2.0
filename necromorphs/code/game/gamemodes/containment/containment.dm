//Still a lot of things to do
/datum/game_mode/containment
	var/obj/structure/marker/main_marker
	var/minimum_round_crew = 2
	var/minimum_alive_percentage = 0.1 //0.1 = 10%

///Attempts to select players for special roles the mode might have.
/datum/game_mode/containment/pre_setup()
	if(!length(GLOB.possible_marker_locations))
		log_mapping("No /obj/effect/marker_location was placed on the map!")
		return TRUE
	//Just it for now
	var/turf/location = pick(GLOB.possible_marker_locations)
	main_marker = new /obj/structure/marker(location)
	addtimer(CALLBACK(src, PROC_REF(activate_marker)), rand(45 MINUTES, 60 MINUTES))
	return TRUE

/datum/game_mode/containment/proc/activate_marker()
	main_marker?.activate()

/datum/game_mode/containment/post_setup(report)
	if(!CONFIG_GET(flag/no_intercept_report))
		addtimer(CALLBACK(src, PROC_REF(announce_marker)), rand(1 MINUTES, 3 MINUTES))
	return ..()

/datum/game_mode/containment/proc/announce_marker()
	. += "<center><b><h2>CEC Corporation Report</h2></b></center><hr><br />"
	. += "Your ship is currently in Cygnus System not far from Aegis VII planet. It is resricted area of space and you shold avoid outside contancts. Your task is to extract alien artifact on the planet surface and deliver it to the rendezvous point. Make sure Earth Government or crew without priority access will not find out about your location, task or cargo. "

	print_command_report(., "CEC Corporation Report", announce=FALSE)
	priority_announce("Thanks to the tireless efforts of our security and intelligence divisions, there are currently no credible threats to [station_name()]. All station construction projects have been authorized. Have a secure shift!", "Security Report", SSstation.announcer.get_rand_report_sound())

///Handles late-join antag assignments
/datum/game_mode/containment/make_antag_chance(mob/living/carbon/human/character)
	return

/datum/game_mode/containment/check_finished(force_ending)
	if(!SSticker.setup_done)
		return FALSE
	if(SSshuttle.emergency && (SSshuttle.emergency.mode == SHUTTLE_ENDGAME))
		return TRUE
	if(GLOB.station_was_nuked)
		return TRUE
	if(force_ending)
		return TRUE

	if(main_marker?.active)
		if(length(GLOB.joined_player_list) >= minimum_round_crew)
			var/minimum_living_crew = ROUND_UP(length(GLOB.joined_player_list) * minimum_alive_percentage)
			if (get_living_active_crew_on_station() < minimum_living_crew)
				return TRUE

/proc/get_living_active_crew_on_station()
	. = 0
	for(var/mob/living/alive as anything in GLOB.alive_player_list)
		if(!(alive.ckey in GLOB.joined_player_list))
			continue
		if(alive.client.is_afk())
			continue
		var/turf/location = get_turf(alive)
		if(!location || !SSmapping.level_trait(location.z, ZTRAIT_STATION))
			continue
		. += 1

/*
 * Generate a list of station goals available to purchase to report to the crew.
 *
 * Returns a formatted string all station goals that are available to the station.
 */
/datum/game_mode/containment/generate_station_goal_report()
	if(!GLOB.station_goals.len)
		return
	. = "<hr><b>Special Orders for [station_name()]:</b><BR>"
	for(var/datum/station_goal/station_goal as anything in GLOB.station_goals)
		station_goal.on_report()
		. += station_goal.get_report()
	return

/*
 * Generate a list of active station traits to report to the crew.
 *
 * Returns a formatted string of all station traits (that are shown) affecting the station.
 */
/datum/game_mode/containment/generate_station_trait_report()
	var/trait_list_string = ""
	for(var/datum/station_trait/station_trait as anything in SSstation.station_traits)
		if(!station_trait.show_in_report)
			continue
		trait_list_string += "[station_trait.get_report()]<BR>"
	if(trait_list_string != "")
		return "<hr><b>Identified shift divergencies:</b><BR>" + trait_list_string
	return

/datum/game_mode/containment/generate_station_goals(greenshift)
	var/goal_budget = greenshift ? INFINITY : CONFIG_GET(number/station_goal_budget)
	var/list/possible = subtypesof(/datum/station_goal)
	var/goal_weights = 0
	while(possible.len && goal_weights < goal_budget)
		var/datum/station_goal/picked = pick_n_take(possible)
		goal_weights += initial(picked.weight)
		GLOB.station_goals += new picked

//Set result and news report here
/datum/game_mode/containment/set_round_result()
	SSticker.mode_result = "undefined"
	if(GLOB.station_was_nuked)
		SSticker.news_report = STATION_DESTROYED_NUKE
	if(EMERGENCY_ESCAPED_OR_ENDGAMED)
		SSticker.news_report = STATION_EVACUATED
		if(SSshuttle.emergency.is_hijacked())
			SSticker.news_report = SHUTTLE_HIJACK

/// Mode specific admin panel.
/datum/game_mode/containment/admin_panel()
	return

GLOBAL_LIST_EMPTY(possible_marker_locations)

/obj/effect/marker_location
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = ""

/obj/effect/marker_location/Initialize()
	GLOB.possible_marker_locations += get_turf(src)
	return ..()
