/mob/living/carbon/human/necromorph/hunter
	class = /datum/necro_class/hunter
	necro_species = /datum/species/necromorph/hunter

/mob/living/carbon/human/necromorph/hunter/play_necro_sound(audio_type, volume, vary, extra_range)
	playsound(src, pick(GLOB.hunter_sounds[audio_type]), volume, vary, extra_range)

/datum/necro_class/hunter
	display_name = "hunter"
	desc = "A rapidly regenerating vanguard, designed to lead the charge, suffer a glorious death, then get back up and do it again.\
	Avoid fire though."
	necromorph_type_path = /mob/living/carbon/human/necromorph/hunter
	melee_damage_lower = 10
	melee_damage_upper = 16
	max_health = 100
	actions = list(
	)
	minimap_icon = "hunter"

/datum/species/necromorph/hunter
	name = "Hunter"
	id = SPECIES_NECROMORPH_HUNTER
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/l_arm/necromorph/hunter,
		BODY_ZONE_R_ARM = /obj/item/bodypart/r_arm/necromorph/hunter,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/necromorph/hunter,
		BODY_ZONE_L_LEG = /obj/item/bodypart/l_leg/necromorph/hunter,
		BODY_ZONE_R_LEG = /obj/item/bodypart/r_leg/necromorph/hunter,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/necromorph/hunter,
	)
