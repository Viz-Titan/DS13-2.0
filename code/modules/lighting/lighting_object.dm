/datum/lighting_object
	///the underlay we are currently applying to our turf to apply light
	var/mutable_appearance/current_underlay
	var/mutable_appearance/additive_underlay

	///whether we are already in the SSlighting.objects_queue list
	var/needs_update = FALSE

	///the turf that our light is applied to
	var/turf/affected_turf

/datum/lighting_object/New(turf/source)
	if(!isturf(source))
		qdel(src, force=TRUE)
		stack_trace("a lighting object was assigned to [source], a non turf! ")
		return
	. = ..()

	current_underlay = mutable_appearance(LIGHTING_ICON, (source.lighting_uses_jen ? "wall-jen-[source.smoothing_junction]" : "light"), source.z, LIGHTING_PLANE, 255, RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM)
	additive_underlay = mutable_appearance(LIGHTING_ICON, (source.lighting_uses_jen ? "wall-jen-[source.smoothing_junction]" : "light"), source.z, LIGHTING_PLANE_ADDITIVE, 255, RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM)
	additive_underlay.blend_mode = BLEND_ADD

	affected_turf = source
	if (affected_turf.lighting_object)
		qdel(affected_turf.lighting_object, force = TRUE)
		stack_trace("a lighting object was assigned to a turf that already had a lighting object!")

	affected_turf.lighting_object = src
	affected_turf.luminosity = 0

	if(CONFIG_GET(flag/starlight))
		for(var/turf/open/space/space_tile in RANGE_TURFS(1, affected_turf))
			space_tile.update_starlight()

	needs_update = TRUE
	SSlighting.objects_queue += src

/datum/lighting_object/Destroy(force)
	if (!force)
		return QDEL_HINT_LETMELIVE
	SSlighting.objects_queue -= src
	if (isturf(affected_turf))
		affected_turf.lighting_object = null
		affected_turf.luminosity = 1
		affected_turf.underlays -= current_underlay
		affected_turf.underlays -= additive_underlay
	affected_turf = null
	return ..()

/datum/lighting_object/proc/update()

	// To the future coder who sees this and thinks
	// "Why didn't he just use a loop?"
	// Well my man, it's because the loop performed like shit.
	// And there's no way to improve it because
	// without a loop you can make the list all at once which is the fastest you're gonna get.
	// Oh it's also shorter line wise.
	// Including with these comments.

	var/static/datum/lighting_corner/dummy/dummy_lighting_corner = new

	var/datum/lighting_corner/red_corner = affected_turf.lighting_corner_SW || dummy_lighting_corner
	var/datum/lighting_corner/green_corner = affected_turf.lighting_corner_SE || dummy_lighting_corner
	var/datum/lighting_corner/blue_corner = affected_turf.lighting_corner_NW || dummy_lighting_corner
	var/datum/lighting_corner/alpha_corner = affected_turf.lighting_corner_NE || dummy_lighting_corner

	var/max = max(red_corner.largest_color_luminosity, green_corner.largest_color_luminosity, blue_corner.largest_color_luminosity, alpha_corner.largest_color_luminosity)

	var/rr = red_corner.cache_r
	var/rg = red_corner.cache_g
	var/rb = red_corner.cache_b

	var/gr = green_corner.cache_r
	var/gg = green_corner.cache_g
	var/gb = green_corner.cache_b

	var/br = blue_corner.cache_r
	var/bg = blue_corner.cache_g
	var/bb = blue_corner.cache_b

	var/ar = alpha_corner.cache_r
	var/ag = alpha_corner.cache_g
	var/ab = alpha_corner.cache_b

	#if LIGHTING_SOFT_THRESHOLD != 0
	var/set_luminosity = max > LIGHTING_SOFT_THRESHOLD
	#else
	// Because of floating points™?, it won't even be a flat 0.
	// This number is mostly arbitrary.
	var/set_luminosity = max > 1e-6
	#endif

	if((rr & gr & br & ar) && (rg + gg + bg + ag + rb + gb + bb + ab == 8))
		//anything that passes the first case is very likely to pass the second, and addition is a little faster in this case
		affected_turf.underlays -= current_underlay
		current_underlay.icon_state = "lighting_transparent"
		current_underlay.color = null
		affected_turf.underlays += current_underlay
	else if(!set_luminosity)
		affected_turf.underlays -= current_underlay
		current_underlay.icon_state = "lighting_dark"
		current_underlay.color = null
		affected_turf.underlays += current_underlay
	else
		affected_turf.underlays -= current_underlay
		current_underlay.icon_state = affected_turf.lighting_uses_jen ? "wall-jen-[affected_turf.smoothing_junction]" : "light"
		current_underlay.color = list(
			rr, rg, rb, 00,
			gr, gg, gb, 00,
			br, bg, bb, 00,
			ar, ag, ab, 00,
			00, 00, 00, 01
		)

		affected_turf.underlays += current_underlay

	if((red_corner.applying_additive || green_corner.applying_additive || blue_corner.applying_additive || alpha_corner.applying_additive) && !(affected_turf.z_flags & Z_MIMIC_OVERWRITE))
		//I'm not ENTIRELY sure why, but turfs of this nature will black out if they get bloom'd
		affected_turf.underlays -= additive_underlay
		additive_underlay.icon_state = affected_turf.lighting_uses_jen ? "wall-jen-[affected_turf.smoothing_junction]" : "light"
		var/arr = red_corner.add_r
		var/arb = red_corner.add_b
		var/arg = red_corner.add_g

		var/agr = green_corner.add_r
		var/agb = green_corner.add_b
		var/agg = green_corner.add_g

		var/abr = blue_corner.add_r
		var/abb = blue_corner.add_b
		var/abg = blue_corner.add_g

		var/aarr = alpha_corner.add_r
		var/aarb = alpha_corner.add_b
		var/aarg = alpha_corner.add_g

		additive_underlay.color = list(
			arr, arg, arb, 00,
			agr, agg, agb, 00,
			abr, abg, abb, 00,
			aarr, aarg, aarb, 00,
			00, 00, 00, 01
		)
		affected_turf.underlays += additive_underlay
	else
		affected_turf.underlays -= additive_underlay

	affected_turf.luminosity = set_luminosity

	if (affected_turf.above)
		if(affected_turf.above.shadower)
			affected_turf.above.shadower.copy_lighting(src)
		else
			affected_turf.above.update_mimic()
