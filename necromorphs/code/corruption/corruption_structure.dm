#define GROWING 1
#define DECAYING 2

/obj/structure/necromorph
	name = "necromorph sturcture"
	desc = "There is something scary in it."
	icon = 'necromorphs/icons/effects/corruption.dmi'
	icon_state = "maw"
	anchored = TRUE
	max_integrity = 25
	resistance_flags = UNACIDABLE
	obj_flags = CAN_BE_HIT
	/// Weed below this structure, if it's dying then we are dying as well
	var/obj/structure/corruption/master
	/// If we are growing or decaying
	var/state = null

/obj/structure/necromorph/Initialize(mapload, obj/structure/corruption/new_master)
	..()
	if(!new_master)
		return INITIALIZE_HINT_QDEL
	RegisterSignal(src, COMSIG_ATOM_INTEGRITY_CHANGED, .proc/on_integrity_change)
	return INITIALIZE_HINT_LATELOAD

/obj/structure/necromorph/LateInitialize()
	..()
	update_signals(null, loc)

/obj/structure/necromorph/Destroy()
	master = null
	return ..()

/obj/structure/necromorph/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	..()
	update_signals(old_loc, loc)
	return TRUE

/obj/structure/necromorph/proc/update_signals(atom/old_loc, atom/new_loc)
	if(old_loc)
		UnregisterSignal(old_loc, list(COMSIG_TURF_NECRO_CORRUPTED, COMSIG_TURF_NECRO_UNCORRUPTED))
	if(new_loc)
		if(locate(/obj/structure/corruption) in loc)
			RegisterSignal(new_loc, COMSIG_TURF_NECRO_UNCORRUPTED, .proc/on_turf_uncorrupted)
			state = GROWING
			START_PROCESSING(SScorruption, src)
		else
			RegisterSignal(new_loc, COMSIG_TURF_NECRO_CORRUPTED, .proc/on_turf_corrupted)
			state = DECAYING
			START_PROCESSING(SScorruption, src)

/obj/structure/necromorph/proc/on_turf_uncorrupted(turf/source)
	SIGNAL_HANDLER
	state = DECAYING
	START_PROCESSING(SScorruption, src)

/obj/structure/necromorph/proc/on_turf_corrupted(turf/source)
	SIGNAL_HANDLER
	state = GROWING
	START_PROCESSING(SScorruption, src)

/obj/structure/necromorph/process(delta_time)
	if(state == GROWING)
		repair_damage(3*delta_time)
	else if(state == DECAYING)
		take_damage(3*delta_time)
	else
		. = PROCESS_KILL
		CRASH("Corruption was processing while state was [isnull(state) ? "NULL" : state]")

/obj/structure/necromorph/proc/on_integrity_change(atom/source, old_integrity, new_integrity)
	SIGNAL_HANDLER
	if(master)
		if((old_integrity >= new_integrity) && state != DECAYING)
			state = GROWING
			START_PROCESSING(SScorruption, src)
		else if(new_integrity >= max_integrity)
			state = null
			STOP_PROCESSING(SScorruption, src)

/obj/structure/necromorph/play_attack_sound(damage_amount, damage_type, damage_flag)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/effects/attackblob.ogg', 100, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			if(damage_amount)
				playsound(loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/necromorph/run_atom_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == MELEE)
		switch(damage_type)
			if(BRUTE)
				damage_amount *= 0.25
			if(BURN)
				damage_amount *= 2
	return ..()

/obj/structure/necromorph/CanCorrupt(corruption_dir)
	return TRUE

#undef GROWING
#undef DECAYING

/client/proc/spawn_corruption_structure()
	set category = "Debug"
	set desc = "Spawn corruption structure"
	set name = "Spawn Corruption Structure"

	if(!check_rights(R_SPAWN))
		return

	if(!length(GLOB.necromorph_markers))
		to_chat(mob, span_warning("There are no markers present!"))
		return

	var/list/list_to_pick = list()
	for(var/obj/structure/necromorph/struct as anything in subtypesof(/obj/structure/necromorph))
		list_to_pick[initial(struct.name)] = struct

	var/type_to_spawn = list_to_pick[tgui_input_list(usr, "Pick a structure to spawn", "Spawning", list_to_pick)]
	if(!type_to_spawn)
		return

	if(!length(GLOB.necromorph_markers))
		to_chat(mob, span_warning("There are no markers present!"))
		return

	var/obj/structure/marker/marker = tgui_input_list(usr, "Pick a marker", "Marker", GLOB.necromorph_markers)

	if(QDELETED(marker))
		return

	var/obj/structure/necromorph/necro = new type_to_spawn(get_turf(usr), marker)
	necro.flags_1 |= ADMIN_SPAWNED_1

	log_admin("[key_name(usr)] spawned [type_to_spawn] at [AREACOORD(usr)]")
	SSblackbox.record_feedback("tally", "corruption_spawn", 1, "Spawn Corruption Structure") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
