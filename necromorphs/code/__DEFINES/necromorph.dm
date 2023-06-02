// Subsystems Fire
#define FIRE_PRIORITY_CORRUPTION	34

#define NECROMORPH_ACID_POWER	0.7	//Damage per unit of necromorph organic acid, used by many things
#define NECROMORPH_FRIENDLY_FIRE_FACTOR	0.5	//All damage dealt by necromorphs TO necromorphs, is multiplied by this
#define NECROMORPH_ACID_COLOR	"#946b36"

//Minimum power levels for bioblasts to trigger the appropriate ex_act tier
#define BIOBLAST_TIER_1	120
#define BIOBLAST_TIER_2	60
#define BIOBLAST_TIER_3	30

//Faction strings
#define FACTION_NECROMORPH	"necromorph"
#define ROLE_NECROMORPH "necromorph"

//Necromorph species
#define SPECIES_NECROMORPH "necromorph"
#define SPECIES_NECROMORPH_DIVIDER "divider"
#define SPECIES_NECROMORPH_DIVIDER_COMPONENT "divider_component"
#define SPECIES_NECROMORPH_SLASHER "slasher"

#define SPECIES_NECROMORPH_SLASHER_ENHANCED "enhanced_slasher"
#define SPECIES_NECROMORPH_SPITTER "spitter"
#define SPECIES_NECROMORPH_PUKER "puker"
#define SPECIES_NECROMORPH_BRUTE "brute"
#define SPECIES_NECROMORPH_EXPLODER "exploder"
#define SPECIES_NECROMORPH_EXPLODER_ENHANCED "enhanced_exploder"
#define SPECIES_NECROMORPH_TRIPOD "tripod"
#define SPECIES_NECROMORPH_HUNTER "hunter"
#define SPECIES_NECROMORPH_INFECTOR "infector"
#define SPECIES_NECROMORPH_INFECTOR_ENHANCED "enhanced_infector"
#define SPECIES_NECROMORPH_TWITCHER "twitcher"
#define SPECIES_NECROMORPH_TWITCHER_ORACLE "oracle_twitcher"
#define SPECIES_NECROMORPH_LEAPER "leaper"
#define SPECIES_NECROMORPH_LEAPER_ENHANCED "enhanced_leaper"
#define SPECIES_NECROMORPH_LEAPER_HOPPER "hopper"
#define	SPECIES_NECROMORPH_LURKER "lurker"
#define SPECIES_NECROMORPH_UBERMORPH "ubermorph"


//Graphical variants
#define SPECIES_NECROMORPH_BRUTE_FLESH "brutef"
#define SPECIES_NECROMORPH_SLASHER_DESICCATED "slasher_ancient"
#define SPECIES_NECROMORPH_SLASHER_CARRION "slasher_carrion"
#define	SPECIES_NECROMORPH_LURKER_MALO "lurker_malo"

#define SPECIES_NECROMORPH_PUKER_FLAYED "puker_flayed"
#define SPECIES_NECROMORPH_PUKER_CLASSIC "puker"

#define SPECIES_NECROMORPH_EXPLODER_ENHANCED_RIGHT "enhanced_right_exploder"
#define SPECIES_NECROMORPH_EXPLODER_ENHANCED_LEFT "enhanced_left_exploder"
#define SPECIES_NECROMORPH_EXPLODER_RIGHT "right_exploder"
#define SPECIES_NECROMORPH_EXPLODER_LEFT "left_exploder"

#define NECRO_DEFAULT_VENT_ENTER_TIME 4.5 SECONDS //Standard time for a necromorph to enter a vent.
#define NECRO_DEFAULT_VENT_EXIT_TIME 2 SECONDS //Standard time for a necromorph to exit a vent.

#define NECROMORPH_CAN_VENT_CRAWL (1<<0)
#define NECROMORPH_CAN_HAVE_ID (1<<1)


#define CHARGE_SPEED(charger) (min(charger.valid_steps_taken, charger.max_steps_buildup) * charger.speed_per_step)
#define CHARGE_MAX_SPEED (speed_per_step * max_steps_buildup)

#define CHARGE_BRUTE (1<<0)

#define STOP_CHARGE_ON_DEL (1<<0)

#define CHARGE_OFF 0
#define CHARGE_BUILDINGUP 1
#define CHARGE_ON 2
#define CHARGE_MAX 3
