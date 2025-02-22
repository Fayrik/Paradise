/mob/living/carbon/human
	name = "unknown"
	real_name = "unknown"
	voice_name = "unknown"
	icon = 'icons/mob/human.dmi'
	icon_state = "body_m_s"

	//why are these here and not in human_defines.dm
	var/list/hud_list[10]
	var/datum/species/species //Contains icon generation and language information, set during New().
	var/embedded_flag	  //To check if we've need to roll for damage on movement while an item is imbedded in us.
	var/obj/item/weapon/rig/wearing_rig // This is very not good, but it's much much better than calling get_rig() every update_canmove() call.

/mob/living/carbon/human/New(var/new_loc, var/new_species = null, var/delay_ready_dna = 0)
	if(!dna)
		dna = new /datum/dna(null)
		// Species name is handled by set_species()

	if(!species)
		if(new_species)
			set_species(new_species, 1)
		else
			set_species()

	if(species)
		name = species.get_random_name(gender)

	var/datum/reagents/R = new/datum/reagents(330)
	reagents = R
	R.my_atom = src

	hud_list[HEALTH_HUD]      = image('icons/mob/hud.dmi', src, "hudhealth100")
	hud_list[STATUS_HUD]      = image('icons/mob/hud.dmi', src, "hudhealthy")
	hud_list[ID_HUD]          = image('icons/mob/hud.dmi', src, "hudunknown")
	hud_list[WANTED_HUD]      = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPLOYAL_HUD]    = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPCHEM_HUD]     = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPTRACK_HUD]    = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[SPECIALROLE_HUD] = image('icons/mob/hud.dmi', src, "hudblank")
	hud_list[STATUS_HUD_OOC]  = image('icons/mob/hud.dmi', src, "hudhealthy")
	hud_list[NATIONS_HUD]     = image('icons/mob/hud.dmi', src, "hudblank")

	..()

	prev_gender = gender // Debug for plural genders
	make_blood()

	var/mob/M = src
	faction |= "\ref[M]" //what

	// Set up DNA.
	if(!delay_ready_dna && dna)
		dna.ready_dna(src)
		dna.real_name = real_name
		sync_organ_dna() //this shouldn't be necessaaaarrrryyyyyyyy
	UpdateAppearance()

/mob/living/carbon/human/Destroy()
	for(var/atom/movable/organelle in organs)
		qdel(organelle)
	organs = list()
	return ..()

/mob/living/carbon/human/dummy
	real_name = "Test Dummy"
	status_flags = GODMODE|CANPUSH

/mob/living/carbon/human/skrell/New(var/new_loc)
	h_style = "Skrell Male Tentacles"
	..(new_loc, "Skrell")

/mob/living/carbon/human/tajaran/New(var/new_loc)
	h_style = "Tajaran Ears"
	..(new_loc, "Tajaran")

/mob/living/carbon/human/vulpkanin/New(var/new_loc)
	h_style = "Bald"
	..(new_loc, "Vulpkanin")

/mob/living/carbon/human/unathi/New(var/new_loc)
	h_style = "Unathi Horns"
	..(new_loc, "Unathi")

/mob/living/carbon/human/vox/New(var/new_loc)
	h_style = "Short Vox Quills"
	..(new_loc, "Vox")

/mob/living/carbon/human/voxarmalis/New(var/new_loc)
	h_style = "Bald"
	..(new_loc, "Vox Armalis")

/mob/living/carbon/human/skellington/New(var/new_loc)
	h_style = "Bald"
	..(new_loc, "Skellington")

/mob/living/carbon/human/kidan/New(var/new_loc)
	..(new_loc, "Kidan")

/mob/living/carbon/human/plasma/New(var/new_loc)
	h_style = "Bald"
	..(new_loc, "Plasmaman")

/mob/living/carbon/human/slime/New(var/new_loc)
	..(new_loc, "Slime People")

/mob/living/carbon/human/grey/New(var/new_loc)
	..(new_loc, "Grey")

/mob/living/carbon/human/human/New(var/new_loc)
	..(new_loc, "Human")

/mob/living/carbon/human/diona/New(var/new_loc)
	h_style = "Bald"
	..(new_loc, "Diona")

/mob/living/carbon/human/machine/New(var/new_loc)
	h_style = "blue IPC screen"
	..(new_loc, "Machine")

/mob/living/carbon/human/shadow/New(var/new_loc)
	h_style = "Bald"
	..(new_loc, "Shadow")

/mob/living/carbon/human/golem/New(var/new_loc)
	h_style = "Bald"
	..(new_loc, "Golem")

/mob/living/carbon/human/wryn/New(var/new_loc)
	h_style = "Antennae"
	..(new_loc, "Wryn")

/mob/living/carbon/human/nucleation/New(var/new_loc)
	h_style = "Nucleation Crystals"
	..(new_loc, "Nucleation")

/mob/living/carbon/human/monkey/New(var/new_loc)
	..(new_loc, "Monkey")

/mob/living/carbon/human/farwa/New(var/new_loc)
	..(new_loc, "Farwa")

/mob/living/carbon/human/wolpin/New(var/new_loc)
	..(new_loc, "Wolpin")

/mob/living/carbon/human/neara/New(var/new_loc)
	..(new_loc, "Neara")

/mob/living/carbon/human/stok/New(var/new_loc)
	..(new_loc, "Stok")

/mob/living/carbon/human/Bump(atom/movable/AM, yes)
	if(!(yes) || now_pushing || buckled)
		return 0
	now_pushing = 1
	if(ismob(AM))
		var/mob/tmob = AM

		if(iscarbon(tmob) && prob(10))
			spread_disease_to(tmob, "Contact")

		//BubbleWrap - Should stop you pushing a restrained person out of the way
		//i still don't get it, is this supposed to be 'bubblewrapping' or was it made by a guy named 'BubbleWrap'
		if(ishuman(tmob))
			for(var/mob/M in range(tmob, 1))

				if(tmob.pinned.len || (M.pulling == tmob && (tmob.restrained() && !M.restrained()) && M.stat == CONSCIOUS))
					if(!(world.time % 5)) //tmob is pinned to wall, or is restrained and pulled by a concious unrestrained human
						src << "<span class='danger'>[tmob] is restrained, you cannot push past.</span>"
					now_pushing = 0
					return 0

				//I have to fucking document this somewhere- the above if(tmob.pinned.len || etc) check above had
				//locate(/obj/item/weapon/grab, tmob.grabbed_by.len)) at the end of it
				//FIRST OF ALL, THAT IS NOT HOW YOU FUCKING USE LOCATE()
				//SECOND OF ALL, OH GOD, WHY WOULD YOU EVER WANT GRABBED MOBS TO BE UNABLE TO BE PUSHED PAST GOD

				if(tmob.pulling == M && (M.restrained() && !tmob.restrained()) && tmob.stat == CONSCIOUS)
					if(!(world.time % 5))
						src << "<span class='danger'>[tmob] is restraining [M], you cannot push past.</span>"
					now_pushing = 0
					return 0

		//Leaping mobs just land on the tile, no pushing, no anything.
		if(status_flags & LEAPING)
			loc = tmob.loc
			status_flags &= ~LEAPING
			now_pushing = 0
			return

		//BubbleWrap: people in handcuffs are always switched around as if they were on 'help' intent to prevent a person being pulled from being seperated from their puller
		//it might be 'bubblewrapping' given that this rhymes with 'hugboxing'
		if((tmob.a_intent == I_HELP || tmob.restrained()) && (a_intent == I_HELP || restrained()))
			if((canmove && tmob.canmove) && (!tmob.buckled && !tmob.buckled_mob))
				var/turf/oldloc = loc
				loc = tmob.loc
				tmob.loc = oldloc
				now_pushing = 0
				for(var/mob/living/carbon/slime/slime in view(1,tmob))
					if(slime.Victim == tmob)
						slime.UpdateFeed()
				return

		if(ishuman(tmob) && (FAT in tmob.mutations))
			if(prob(40) && !(FAT in src.mutations))
				src << "<span class='danger'>You fail to push [tmob]'s fat ass out of the way.</span>"
				now_pushing = 0
				return

		if(tmob.r_hand && istype(tmob.r_hand, /obj/item/weapon/shield/riot))
			if(prob(99))
				now_pushing = 0
				return

		if(tmob.l_hand && istype(tmob.l_hand, /obj/item/weapon/shield/riot))
			if(prob(99))
				now_pushing = 0
				return

		if(!(tmob.status_flags & CANPUSH))
			now_pushing = 0
			return

		tmob.LAssailant = src

	now_pushing = 0
	spawn(0)
		..()
		if(!istype(AM, /atom/movable))
			return
		if(!now_pushing)
			now_pushing = 1

			if(!AM.anchored)
				var/t = get_dir(src, AM)
				if(istype(AM, /obj/structure/window/full))
					for(var/obj/structure/window/win in get_step(AM, t))
						now_pushing = 0
						return
				step(AM, t)
			now_pushing = 0

/mob/living/carbon/human/Stat()
	..()
	statpanel("Status")

	stat(null, "Intent: [a_intent]")
	stat(null, "Move Mode: [m_intent]")
	if(ticker && ticker.mode && ticker.mode.name == "AI malfunction")
		if(ticker.mode:malf_mode_declared)
			stat(null, "Time left: [max(ticker.mode:AI_win_timeleft/(ticker.mode:apcs/3), 0)]")
	if(emergency_shuttle)
		var/eta_status = emergency_shuttle.get_status_panel_eta()
		if(eta_status)
			stat(null, eta_status)

	if(client.statpanel == "Status")
		if(locate(/obj/item/device/assembly/health) in src)
			stat(null, "Health: [health]")
		if(internal)
			if(!internal.air_contents)
				qdel(internal)
			else
				stat("Internal Atmosphere Info", internal.name)
				stat("Tank Pressure", internal.air_contents.return_pressure())
				stat("Distribution Pressure", internal.distribute_pressure)

		if(istype(back, /obj/item/weapon/rig))
			var/obj/item/weapon/rig/suit = back
			var/cell_status = "ERROR"
			if(suit.cell)
				cell_status = "[suit.cell.charge]/[suit.cell.maxcharge]"
			stat(null, "Suit charge: [cell_status]")

		if(mind)
			if(mind.changeling)
				stat("Chemical Storage", "[mind.changeling.chem_charges]/[mind.changeling.chem_storage]")
				stat("Absorbed DNA", mind.changeling.absorbedcount)
		stat(null, "Station Time: [worldtime2text()]")

	if(istype(loc, /obj/spacepod)) // Spacdpods!
		var/obj/spacepod/S = loc
		stat("Spacepod Charge", "[istype(S.battery) ? "[(S.battery.charge / S.battery.maxcharge) * 100]" : "No cell detected"]")
		stat("Spacepod Integrity", "[!S.health ? "0" : "[(S.health / initial(S.health)) * 100]"]%")

/mob/living/carbon/human/ex_act(severity)
	var/shielded = 0
	var/b_loss = null
	var/f_loss = null

	switch(severity)
		if(1)
			b_loss += 500
			if(!prob(getarmor(null, "bomb")))
				gib()
				return 0
			else
				var/atom/target = get_edge_target_turf(src, get_dir(src, get_step_away(src, src)))
				throw_at(target, 200, 4)

				var/limbs_affected = pick(2,3,4)
				var/obj/item/organ/external/processing_dismember
				var/list/valid_limbs = organs.Copy()

				while(limbs_affected != 0 && valid_limbs.len > 0)
					processing_dismember = pick(valid_limbs)
					if(processing_dismember.limb_name != "chest" && processing_dismember.limb_name != "head" && processing_dismember.limb_name != "groin")
						processing_dismember.droplimb(1,DROPLIMB_EDGE,0,1)
						valid_limbs -= processing_dismember
						limbs_affected -= 1
					else valid_limbs -= processing_dismember

		if(2)
			if(!shielded) //literally nothing could change shielded before this so wth
				b_loss += 60

			f_loss += 60

			var/limbs_affected = 0
			var/obj/item/organ/external/processing_dismember
			var/list/valid_limbs = organs.Copy()

			if(prob(getarmor(null, "bomb")))
				b_loss = b_loss/1.5
				f_loss = f_loss/1.5

				limbs_affected = pick(1, 1, 2)
			else
				limbs_affected = pick(1, 2, 3)

			while(limbs_affected != 0 && valid_limbs.len > 0)
				processing_dismember = pick(valid_limbs)
				if(processing_dismember.limb_name != "chest" && processing_dismember.limb_name != "head" && processing_dismember.limb_name != "groin")
					processing_dismember.droplimb(1,DROPLIMB_EDGE,0,1)
					valid_limbs -= processing_dismember
					limbs_affected -= 1
				else valid_limbs -= processing_dismember

			if(!istype(l_ear, /obj/item/clothing/ears/earmuffs) && !istype(r_ear, /obj/item/clothing/ears/earmuffs))
				ear_damage += 30
				ear_deaf += 120
			if(prob(70) && !shielded)
				Paralyse(10)

		if(3)
			b_loss += 30
			if(prob(getarmor(null, "bomb")))
				b_loss = b_loss/2

			else

				var/limbs_affected = pick(0, 1)
				var/obj/item/organ/external/processing_dismember
				var/list/valid_limbs = organs.Copy()

				while(limbs_affected != 0 && valid_limbs.len > 0)
					processing_dismember = pick(valid_limbs)
					if(processing_dismember.limb_name != "chest" && processing_dismember.limb_name != "head" && processing_dismember.limb_name != "groin")
						processing_dismember.droplimb(1,DROPLIMB_EDGE,0,1)
						valid_limbs -= processing_dismember
						limbs_affected -= 1
					else valid_limbs -= processing_dismember

			if(!istype(l_ear, /obj/item/clothing/ears/earmuffs) && !istype(r_ear, /obj/item/clothing/ears/earmuffs))
				ear_damage += 15
				ear_deaf += 60
			if(prob(50) && !shielded)
				Paralyse(10)

	var/update = 0
	var/weapon_message = "Explosive Blast"
	for(var/obj/item/organ/external/temp in organs)
		switch(temp.limb_name)
			if("head")
				update |= temp.take_damage(b_loss * 0.2,   f_loss * 0.2,   used_weapon = weapon_message)
			if("chest")
				update |= temp.take_damage(b_loss * 0.4,   f_loss * 0.4,   used_weapon = weapon_message)
			if("groin")
				update |= temp.take_damage(b_loss * 0.1,   f_loss * 0.1,   used_weapon = weapon_message)
			if("l_arm")
				update |= temp.take_damage(b_loss * 0.05,  f_loss * 0.05,  used_weapon = weapon_message)
			if("r_arm")
				update |= temp.take_damage(b_loss * 0.05,  f_loss * 0.05,  used_weapon = weapon_message)
			if("l_leg")
				update |= temp.take_damage(b_loss * 0.05,  f_loss * 0.05,  used_weapon = weapon_message)
			if("r_leg")
				update |= temp.take_damage(b_loss * 0.05,  f_loss * 0.05,  used_weapon = weapon_message)
			if("r_foot")
				update |= temp.take_damage(b_loss * 0.025, f_loss * 0.025, used_weapon = weapon_message)
			if("l_foot")
				update |= temp.take_damage(b_loss * 0.025, f_loss * 0.025, used_weapon = weapon_message)
			if("r_hand")
				update |= temp.take_damage(b_loss * 0.025, f_loss * 0.025, used_weapon = weapon_message)
			if("l_hand")
				update |= temp.take_damage(b_loss * 0.025, f_loss * 0.025, used_weapon = weapon_message)
	if(update)	UpdateDamageIcon()

	..()

/mob/living/carbon/human/blob_act()
	if(stat == DEAD)
		return
	show_message("<span class='userdanger'>The blob attacks you!</span>")
	var/dam_zone = pick("head", "chest", "groin", "l_arm", "l_hand", "r_arm", "r_hand", "l_leg", "l_foot", "r_leg", "r_foot")
	var/obj/item/organ/external/affecting = get_organ(ran_zone(dam_zone))
	apply_damage(5, BRUTE, affecting, run_armor_check(affecting, "melee"))

/mob/living/carbon/human/attack_animal(mob/living/simple_animal/M as mob)
	if(M.melee_damage_upper == 0)
		M.custom_emote(1, "[M.friendly] [src]")
	else
		M.do_attack_animation(src)
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		for(var/mob/O in viewers(src, null))
			O.show_message("\red <B>[M]</B> [M.attacktext] [src]!", 1)
		M.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name] ([src.ckey])</font>")
		src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was attacked by [M.name] ([M.ckey])</font>")
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		if(check_shields(damage, "the [M.name]"))
			return 0
		var/dam_zone = pick("head", "chest", "groin", "l_arm", "l_hand", "r_arm", "r_hand", "l_leg", "l_foot", "r_leg", "r_foot")
		var/obj/item/organ/external/affecting = get_organ(ran_zone(dam_zone))
		var/armor = run_armor_check(affecting, "melee")

		var/obj/item/organ/external/affected = src.get_organ(dam_zone)
		if(affected)
			affected.add_autopsy_data(M.name, damage) // Add the mob's name to the autopsy data
		apply_damage(damage,M.melee_damage_type, affecting, armor, M.name)
		updatehealth()

/mob/living/carbon/human/attack_larva(mob/living/carbon/alien/larva/L as mob)

	switch(L.a_intent)
		if(I_HELP)
			visible_message("<span class='notice'>[L] rubs its head against [src].</span>")


		else
			L.do_attack_animation(src)
			var/damage = rand(1, 3)
			visible_message("<span class='danger'>[L] bites [src]!</span>", \
					"<span class='userdanger'>[L] bites [src]!</span>")
			playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)

			if(stat != DEAD)
				L.amount_grown = min(L.amount_grown + damage, L.max_grown)
			var/obj/item/organ/external/affecting = get_organ(ran_zone(L.zone_sel.selecting))
			var/armor_block = run_armor_check(affecting, "melee")
			apply_damage(damage, BRUTE, affecting, armor_block)

/mob/living/carbon/human/proc/is_loyalty_implanted()
	for(var/L in contents)
		if(istype(L, /obj/item/weapon/implant/loyalty))
			for(var/obj/item/organ/external/O in organs)
				if(L in O.implants)
					return 1
	return 0

/mob/living/carbon/human/attack_slime(mob/living/carbon/slime/M as mob)
	if(M.Victim) return // can't attack while eating!

	if (health > -100)

		M.do_attack_animation(src)
		visible_message("<span class='danger'>The [M.name] glomps [src]!</span>", \
				"<span class='userdanger'>The [M.name] glomps [src]!</span>")

		var/damage = rand(1, 3)

		if(M.is_adult)
			damage = rand(10, 35)
		else
			damage = rand(5, 25)

		if(check_shields(damage, "the [M.name]"))
			return 0

		var/dam_zone = pick("head", "chest", "groin", "l_arm", "l_hand", "r_arm", "r_hand", "l_leg", "l_foot", "r_leg", "r_foot")

		var/obj/item/organ/external/affecting = get_organ(ran_zone(dam_zone))
		var/armor_block = run_armor_check(affecting, "melee")
		apply_damage(damage, BRUTE, affecting, armor_block)


		if(M.powerlevel > 0)
			var/stunprob = 10
			var/power = M.powerlevel + rand(0,3)

			switch(M.powerlevel)
				if(1 to 2) stunprob = 20
				if(3 to 4) stunprob = 30
				if(5 to 6) stunprob = 40
				if(7 to 8) stunprob = 60
				if(9) 	   stunprob = 70
				if(10) 	   stunprob = 95

			if(prob(stunprob))
				M.powerlevel -= 3
				if(M.powerlevel < 0)
					M.powerlevel = 0

				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>The [M.name] has shocked []!</B>", src), 1)

				Weaken(power)
				if (stuttering < power)
					stuttering = power
				Stun(power)

				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(5, 1, src)
				s.start()

				if (prob(stunprob) && M.powerlevel >= 8)
					adjustFireLoss(M.powerlevel * rand(6,10))


		updatehealth()

	return


/mob/living/carbon/human/restrained()
	if (handcuffed)
		return 1
	if (istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
		return 1
	return 0


/mob/living/carbon/human/var/temperature_resistance = T0C+75


/mob/living/carbon/human/show_inv(mob/user)
	user.set_machine(src)
	var/has_breathable_mask = istype(wear_mask, /obj/item/clothing/mask)
	var/list/obscured = check_obscured_slots()

	var/dat = {"<table>
	<tr><td><B>Left Hand:</B></td><td><A href='?src=\ref[src];item=[slot_l_hand]'>[(l_hand && !(l_hand.flags&ABSTRACT)) ? l_hand : "<font color=grey>Empty</font>"]</A></td></tr>
	<tr><td><B>Right Hand:</B></td><td><A href='?src=\ref[src];item=[slot_r_hand]'>[(r_hand && !(r_hand.flags&ABSTRACT)) ? r_hand : "<font color=grey>Empty</font>"]</A></td></tr>
	<tr><td>&nbsp;</td></tr>"}

	dat += "<tr><td><B>Back:</B></td><td><A href='?src=\ref[src];item=[slot_back]'>[(back && !(back.flags&ABSTRACT)) ? back : "<font color=grey>Empty</font>"]</A>"
	if(has_breathable_mask && istype(back, /obj/item/weapon/tank))
		dat += "&nbsp;<A href='?src=\ref[src];internal=[slot_back]'>[internal ? "Disable Internals" : "Set Internals"]</A>"

	dat += "</td></tr><tr><td>&nbsp;</td></tr>"

	dat += "<tr><td><B>Head:</B></td><td><A href='?src=\ref[src];item=[slot_head]'>[(head && !(head.flags&ABSTRACT)) ? head : "<font color=grey>Empty</font>"]</A></td></tr>"

	if(slot_wear_mask in obscured)
		dat += "<tr><td><font color=grey><B>Mask:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Mask:</B></td><td><A href='?src=\ref[src];item=[slot_wear_mask]'>[(wear_mask && !(wear_mask.flags&ABSTRACT)) ? wear_mask : "<font color=grey>Empty</font>"]</A></td></tr>"

	if(!issmall(src))
		if(slot_glasses in obscured)
			dat += "<tr><td><font color=grey><B>Eyes:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
		else
			dat += "<tr><td><B>Eyes:</B></td><td><A href='?src=\ref[src];item=[slot_glasses]'>[(glasses && !(glasses.flags&ABSTRACT))	? glasses : "<font color=grey>Empty</font>"]</A></td></tr>"

		if(slot_l_ear in obscured)
			dat += "<tr><td><font color=grey><B>Left Ear:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
		else
			dat += "<tr><td><B>Left Ear:</B></td><td><A href='?src=\ref[src];item=[slot_l_ear]'>[(l_ear && !(l_ear.flags&ABSTRACT))		? l_ear		: "<font color=grey>Empty</font>"]</A></td></tr>"

		if(slot_r_ear in obscured)
			dat += "<tr><td><font color=grey><B>Right Ear:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
		else
			dat += "<tr><td><B>Right Ear:</B></td><td><A href='?src=\ref[src];item=[slot_r_ear]'>[(r_ear && !(r_ear.flags&ABSTRACT))		? r_ear		: "<font color=grey>Empty</font>"]</A></td></tr>"

		dat += "<tr><td>&nbsp;</td></tr>"

		dat += "<tr><td><B>Exosuit:</B></td><td><A href='?src=\ref[src];item=[slot_wear_suit]'>[(wear_suit && !(wear_suit.flags&ABSTRACT)) ? wear_suit : "<font color=grey>Empty</font>"]</A></td></tr>"
		if(wear_suit)
			dat += "<tr><td>&nbsp;&#8627;<B>Suit Storage:</B></td><td><A href='?src=\ref[src];item=[slot_s_store]'>[(s_store && !(s_store.flags&ABSTRACT)) ? s_store : "<font color=grey>Empty</font>"]</A>"
			if(has_breathable_mask && istype(s_store, /obj/item/weapon/tank))
				dat += "&nbsp;<A href='?src=\ref[src];internal=[slot_s_store]'>[internal ? "Disable Internals" : "Set Internals"]</A>"
			dat += "</td></tr>"
		else
			dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>Suit Storage:</B></font></td></tr>"

		if(slot_shoes in obscured)
			dat += "<tr><td><font color=grey><B>Shoes:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
		else
			dat += "<tr><td><B>Shoes:</B></td><td><A href='?src=\ref[src];item=[slot_shoes]'>[(shoes && !(shoes.flags&ABSTRACT))		? shoes		: "<font color=grey>Empty</font>"]</A></td></tr>"

		if(slot_gloves in obscured)
			dat += "<tr><td><font color=grey><B>Gloves:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
		else
			dat += "<tr><td><B>Gloves:</B></td><td><A href='?src=\ref[src];item=[slot_gloves]'>[(gloves && !(gloves.flags&ABSTRACT))		? gloves	: "<font color=grey>Empty</font>"]</A></td></tr>"

		if(slot_w_uniform in obscured)
			dat += "<tr><td><font color=grey><B>Uniform:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
		else
			dat += "<tr><td><B>Uniform:</B></td><td><A href='?src=\ref[src];item=[slot_w_uniform]'>[(w_uniform && !(w_uniform.flags&ABSTRACT)) ? w_uniform : "<font color=grey>Empty</font>"]</A></td></tr>"

		if(w_uniform == null || (slot_w_uniform in obscured))
			dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>Pockets:</B></font></td></tr>"
			dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>ID:</B></font></td></tr>"
			dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>Belt:</B></font></td></tr>"
			dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>Suit Sensors:</B></font></td></tr>"
			dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>PDA:</B></font></td></tr>"
		else
			dat += "<tr><td>&nbsp;&#8627;<B>Belt:</B></td><td><A href='?src=\ref[src];item=[slot_belt]'>[(belt && !(belt.flags&ABSTRACT)) ? belt : "<font color=grey>Empty</font>"]</A>"
			if(has_breathable_mask && istype(belt, /obj/item/weapon/tank))
				dat += "&nbsp;<A href='?src=\ref[src];internal=[slot_belt]'>[internal ? "Disable Internals" : "Set Internals"]</A>"
			dat += "</td></tr>"
			dat += "<tr><td>&nbsp;&#8627;<B>Pockets:</B></td><td><A href='?src=\ref[src];pockets=left'>[(l_store && !(l_store.flags&ABSTRACT)) ? "Left (Full)" : "<font color=grey>Left (Empty)</font>"]</A>"
			dat += "&nbsp;<A href='?src=\ref[src];pockets=right'>[(r_store && !(r_store.flags&ABSTRACT)) ? "Right (Full)" : "<font color=grey>Right (Empty)</font>"]</A></td></tr>"
			dat += "<tr><td>&nbsp;&#8627;<B>ID:</B></td><td><A href='?src=\ref[src];item=[slot_wear_id]'>[(wear_id && !(wear_id.flags&ABSTRACT)) ? wear_id : "<font color=grey>Empty</font>"]</A></td></tr>"
			dat += "<tr><td>&nbsp;&#8627;<B>PDA:</B></td><td><A href='?src=\ref[src];item=[slot_wear_pda]'>[(wear_pda && !(wear_pda.flags&ABSTRACT)) ? wear_pda : "<font color=grey>Empty</font>"]</A></td></tr>"

			if(istype(w_uniform, /obj/item/clothing/under))
				var/obj/item/clothing/under/U = w_uniform
				dat += "<tr><td>&nbsp;&#8627;<B>Suit Sensors:</b></td><td><A href='?src=\ref[src];set_sensor=1'>[U.has_sensor >= 2 ? "</a><font color=grey>--SENSORS LOCKED--</font>" : "Set Sensors</a>"]</td></tr>"

				if(U.accessories.len)
					dat += "<tr><td>&nbsp;&#8627;<A href='?src=\ref[src];strip_accessory=1'>Remove Accessory</a></td></tr>"


	if(handcuffed)
		dat += "<tr><td><B>Handcuffed:</B> <A href='?src=\ref[src];item=[slot_handcuffed]'>Remove</A></td></tr>"
	if(legcuffed)
		dat += "<tr><td><A href='?src=\ref[src];item=[slot_legcuffed]'>Legcuffed</A></td></tr>"

	dat += {"</table>
	<A href='?src=\ref[user];mach_close=mob\ref[src]'>Close</A>
	"}

	var/datum/browser/popup = new(user, "mob\ref[src]", "[src]", 440, 540)
	popup.set_content(dat)
	popup.open()


// called when something steps onto a human
// this handles mulebots and vehicles
/mob/living/carbon/human/Crossed(var/atom/movable/AM)
	if(istype(AM, /obj/machinery/bot/mulebot))
		var/obj/machinery/bot/mulebot/MB = AM
		MB.RunOver(src)

	if(istype(AM, /obj/vehicle))
		var/obj/vehicle/V = AM
		V.RunOver(src)

// Get rank from ID, ID inside PDA, PDA, ID in wallet, etc.
/mob/living/carbon/human/proc/get_authentification_rank(var/if_no_id = "No id", var/if_no_job = "No job")
	var/obj/item/device/pda/pda = wear_id
	if (istype(pda))
		if (pda.id)
			return pda.id.rank
		else
			return pda.ownrank
	else
		var/obj/item/weapon/card/id/id = get_idcard()
		if(id)
			return id.rank ? id.rank : if_no_job
		else
			return if_no_id

//gets assignment from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_assignment(var/if_no_id = "No id", var/if_no_job = "No job")
	var/obj/item/device/pda/pda = wear_id
	var/obj/item/weapon/card/id/id = wear_id
	if (istype(pda))
		if (pda.id && istype(pda.id, /obj/item/weapon/card/id))
			. = pda.id.assignment
		else
			. = pda.ownjob
	else if (istype(id))
		. = id.assignment
	else
		return if_no_id
	if (!.)
		. = if_no_job
	return

//gets name from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_authentification_name(var/if_no_id = "Unknown")
	var/obj/item/device/pda/pda = wear_id
	var/obj/item/weapon/card/id/id = wear_id
	if (istype(pda))
		if (pda.id)
			. = pda.id.registered_name
		else
			. = pda.owner
	else if (istype(id))
		. = id.registered_name
	else
		return if_no_id
	return

//repurposed proc. Now it combines get_id_name() and get_face_name() to determine a mob's name variable. Made into a seperate proc as it'll be useful elsewhere
/mob/living/carbon/human/proc/get_visible_name()
	if( wear_mask && (wear_mask.flags_inv&HIDEFACE) )	//Wearing a mask which hides our face, use id-name if possible
		return get_id_name("Unknown")
	if( head && (head.flags_inv&HIDEFACE) )
		return get_id_name("Unknown")		//Likewise for hats
	var/face_name = get_face_name()
	var/id_name = get_id_name("")
	if(id_name && (id_name != face_name))
		return "[face_name] (as [id_name])"
	return face_name

//Returns "Unknown" if facially disfigured and real_name if not. Useful for setting name when polyacided or when updating a human's name variable
/mob/living/carbon/human/proc/get_face_name()
	var/obj/item/organ/external/head = get_organ("head")
	if( !head || head.disfigured || (head.status & ORGAN_DESTROYED) || !real_name || (HUSK in mutations) )	//disfigured. use id-name if possible
		return "Unknown"
	return real_name

//gets name from ID or PDA itself, ID inside PDA doesn't matter
//Useful when player is being seen by other mobs
/mob/living/carbon/human/proc/get_id_name(var/if_no_id = "Unknown")
	var/obj/item/device/pda/pda = wear_id
	var/obj/item/weapon/card/id/id = wear_id
	if(istype(pda))		. = pda.owner
	else if(istype(id))	. = id.registered_name
	if(!.) 				. = if_no_id	//to prevent null-names making the mob unclickable
	return

//gets ID card object from special clothes slot or null.
/mob/living/carbon/human/proc/get_idcard()
	var/obj/item/weapon/card/id/id = wear_id
	var/obj/item/device/pda/pda = wear_id
	if (istype(pda) && pda.id)
		id = pda.id
	if (istype(id))
		return id

//Removed the horrible safety parameter. It was only being used by ninja code anyways.
//Now checks siemens_coefficient of the affected area by default
/mob/living/carbon/human/electrocute_act(var/shock_damage, var/obj/source, var/base_siemens_coeff = 1.0, var/def_zone = null,var/override = 0)

	if(status_flags & GODMODE)	//godmode
		return 0
	if(NO_SHOCK in mutations) //shockproof
		return 0

	if (!def_zone)
		def_zone = pick("l_hand", "r_hand")

	var/obj/item/organ/external/affected_organ = get_organ(check_zone(def_zone))
	var/siemens_coeff = base_siemens_coeff * get_siemens_coefficient_organ(affected_organ)

	return ..(shock_damage, source, siemens_coeff, def_zone,override)


/mob/living/carbon/human/Topic(href, href_list)
	if(!usr.stat && usr.canmove && !usr.restrained() && in_range(src, usr))

		if(href_list["item"])
			var/slot = text2num(href_list["item"])
			if(slot in check_obscured_slots())
				usr << "<span class='warning'>You can't reach that! Something is covering it.</span>"
				return

		if(href_list["pockets"])
			var/pocket_side = href_list["pockets"]
			var/pocket_id = (pocket_side == "right" ? slot_r_store : slot_l_store)
			var/obj/item/pocket_item = (pocket_id == slot_r_store ? r_store : l_store)
			var/obj/item/place_item = usr.get_active_hand() // Item to place in the pocket, if it's empty

			var/delay_denominator = 1
			if(pocket_item && !(pocket_item.flags&ABSTRACT))
				if(pocket_item.flags & NODROP)
					usr << "<span class='warning'>You try to empty [src]'s [pocket_side] pocket, it seems to be stuck!</span>"
				usr << "<span class='notice'>You try to empty [src]'s [pocket_side] pocket.</span>"
			else if(place_item && place_item.mob_can_equip(src, pocket_id, 1) && !(place_item.flags&ABSTRACT))
				usr << "<span class='notice'>You try to place [place_item] into [src]'s [pocket_side] pocket.</span>"
				delay_denominator = 4
			else
				return

			if(do_mob(usr, src, POCKET_STRIP_DELAY/delay_denominator)) //placing an item into the pocket is 4 times faster
				if(pocket_item)
					if(pocket_item == (pocket_id == slot_r_store ? r_store : l_store)) //item still in the pocket we search
						unEquip(pocket_item)
				else
					if(place_item)
						usr.unEquip(place_item)
						equip_to_slot_if_possible(place_item, pocket_id, 0, 1)

				// Update strip window
				if(usr.machine == src && in_range(src, usr))
					show_inv(usr)
			else
				// Display a warning if the user mocks up
				src << "<span class='warning'>You feel your [pocket_side] pocket being fumbled with!</span>"

		if(href_list["set_sensor"])
			if(istype(w_uniform, /obj/item/clothing/under))
				var/obj/item/clothing/under/U = w_uniform
				U.set_sensors(usr)

		if(href_list["strip_accessory"])
			if(istype(w_uniform, /obj/item/clothing/under))
				var/obj/item/clothing/under/U = w_uniform
				if(U.accessories.len)
					var/obj/item/clothing/accessory/A = U.accessories[1]
					usr.visible_message("<span class='danger'>\The [usr] starts to take off \the [A] from \the [src]'s [U]!</span>", \
										"<span class='danger'>You start to take off \the [A] from \the [src]'s [U]!</span>")

					if(do_mob(usr, src, 40) && A && U.accessories.len)
						usr.visible_message("<span class='danger'>\The [usr] takes \the [A] off of \the [src]'s [U]!</span>", \
											"<span class='danger'>You take \the [A] off of \the [src]'s [U]!</span>")
						A.on_removed(usr)
						U.accessories -= A
						update_inv_w_uniform()

	if (href_list["refresh"])
		if((machine)&&(in_range(src, usr)))
			show_inv(machine)

	if (href_list["mach_close"])
		var/t1 = text("window=[]", href_list["mach_close"])
		unset_machine()
		src << browse(null, t1)

	if (href_list["criminal"])
		if(hasHUD(usr,"security"))

			var/modified = 0
			var/perpname = "wot"
			if(wear_id)
				var/obj/item/weapon/card/id/I = wear_id.GetID()
				if(I)
					perpname = I.registered_name
				else
					perpname = name
			else
				perpname = name

			if(perpname)
				for (var/datum/data/record/E in data_core.general)
					if (E.fields["name"] == perpname)
						for (var/datum/data/record/R in data_core.security)
							if (R.fields["id"] == E.fields["id"])

								var/setcriminal = input(usr, "Specify a new criminal status for this person.", "Security HUD", R.fields["criminal"]) in list("None", "*Arrest*", "Incarcerated", "Parolled", "Released", "Cancel")

								if(hasHUD(usr, "security"))
									if(setcriminal != "Cancel")
										R.fields["criminal"] = setcriminal
										modified = 1

										spawn()
											hud_updateflag |= 1 << WANTED_HUD
											if(istype(usr,/mob/living/carbon/human))
												var/mob/living/carbon/human/U = usr
												U.handle_regular_hud_updates()
											if(istype(usr,/mob/living/silicon/robot))
												var/mob/living/silicon/robot/U = usr
												U.handle_regular_hud_updates()

			if(!modified)
				usr << "\red Unable to locate a data core entry for this person."

	if (href_list["secrecord"])
		if(hasHUD(usr,"security"))
			var/perpname = "wot"
			var/read = 0

			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.security)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"security"))
								usr << "<b>Name:</b> [R.fields["name"]]	<b>Criminal Status:</b> [R.fields["criminal"]]"
								usr << "<b>Minor Crimes:</b> [R.fields["mi_crim"]]"
								usr << "<b>Details:</b> [R.fields["mi_crim_d"]]"
								usr << "<b>Major Crimes:</b> [R.fields["ma_crim"]]"
								usr << "<b>Details:</b> [R.fields["ma_crim_d"]]"
								usr << "<b>Notes:</b> [R.fields["notes"]]"
								usr << "<a href='?src=\ref[src];secrecordComment=`'>\[View Comment Log\]</a>"
								read = 1

			if(!read)
				usr << "\red Unable to locate a data core entry for this person."

	if (href_list["secrecordComment"])
		if(hasHUD(usr,"security"))
			var/perpname = "wot"
			var/read = 0

			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.security)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"security"))
								read = 1
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									usr << text("[]", R.fields[text("com_[]", counter)])
									counter++
								if (counter == 1)
									usr << "No comment found"
								usr << "<a href='?src=\ref[src];secrecordadd=`'>\[Add comment\]</a>"

			if(!read)
				usr << "\red Unable to locate a data core entry for this person."

	if (href_list["secrecordadd"])
		if(hasHUD(usr,"security"))
			var/perpname = "wot"
			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.security)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"security"))
								var/t1 = sanitize(copytext(input("Add Comment:", "Sec. records", null, null)  as message,1,MAX_MESSAGE_LEN))
								if ( !(t1) || usr.stat || usr.restrained() || !(hasHUD(usr,"security")) )
									return
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									counter++
								if(istype(usr,/mob/living/carbon/human))
									var/mob/living/carbon/human/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.get_authentification_name()] ([U.get_assignment()]) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [game_year]<BR>[t1]")
								if(istype(usr,/mob/living/silicon/robot))
									var/mob/living/silicon/robot/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.name] ([U.modtype] [U.braintype]) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [game_year]<BR>[t1]")
								if(istype(usr,/mob/living/silicon/ai))
									var/mob/living/silicon/ai/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.name] (artificial intelligence) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [game_year]<BR>[t1]")

	if (href_list["medical"])
		if(hasHUD(usr,"medical"))
			var/perpname = "wot"
			var/modified = 0

			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name

			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.general)
						if (R.fields["id"] == E.fields["id"])
							var/setmedical = input(usr, "Specify a new medical status for this person.", "Medical HUD", R.fields["p_stat"]) in list("*SSD*", "*Deceased*", "Physically Unfit", "Active", "Disabled", "Cancel")

							if(hasHUD(usr,"medical"))
								if(setmedical != "Cancel")
									R.fields["p_stat"] = setmedical
									modified = 1
									if(PDA_Manifest.len)
										PDA_Manifest.Cut()

									spawn()
										if(istype(usr,/mob/living/carbon/human))
											var/mob/living/carbon/human/U = usr
											U.handle_regular_hud_updates()
										if(istype(usr,/mob/living/silicon/robot))
											var/mob/living/silicon/robot/U = usr
											U.handle_regular_hud_updates()

			if(!modified)
				usr << "\red Unable to locate a data core entry for this person."

	if (href_list["medrecord"])
		if(hasHUD(usr,"medical"))
			var/perpname = "wot"
			var/read = 0

			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.medical)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"medical"))
								usr << "<b>Name:</b> [R.fields["name"]]	<b>Blood Type:</b> [R.fields["b_type"]]"
								usr << "<b>DNA:</b> [R.fields["b_dna"]]"
								usr << "<b>Minor Disabilities:</b> [R.fields["mi_dis"]]"
								usr << "<b>Details:</b> [R.fields["mi_dis_d"]]"
								usr << "<b>Major Disabilities:</b> [R.fields["ma_dis"]]"
								usr << "<b>Details:</b> [R.fields["ma_dis_d"]]"
								usr << "<b>Notes:</b> [R.fields["notes"]]"
								usr << "<a href='?src=\ref[src];medrecordComment=`'>\[View Comment Log\]</a>"
								read = 1

			if(!read)
				usr << "\red Unable to locate a data core entry for this person."

	if (href_list["medrecordComment"])
		if(hasHUD(usr,"medical"))
			var/perpname = "wot"
			var/read = 0

			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.medical)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"medical"))
								read = 1
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									usr << text("[]", R.fields[text("com_[]", counter)])
									counter++
								if (counter == 1)
									usr << "No comment found"
								usr << "<a href='?src=\ref[src];medrecordadd=`'>\[Add comment\]</a>"

			if(!read)
				usr << "\red Unable to locate a data core entry for this person."

	if (href_list["medrecordadd"])
		if(hasHUD(usr,"medical"))
			var/perpname = "wot"
			if(wear_id)
				if(istype(wear_id,/obj/item/weapon/card/id))
					perpname = wear_id:registered_name
				else if(istype(wear_id,/obj/item/device/pda))
					var/obj/item/device/pda/tempPda = wear_id
					perpname = tempPda.owner
			else
				perpname = src.name
			for (var/datum/data/record/E in data_core.general)
				if (E.fields["name"] == perpname)
					for (var/datum/data/record/R in data_core.medical)
						if (R.fields["id"] == E.fields["id"])
							if(hasHUD(usr,"medical"))
								var/t1 = sanitize(copytext(input("Add Comment:", "Med. records", null, null)  as message,1,MAX_MESSAGE_LEN))
								if ( !(t1) || usr.stat || usr.restrained() || !(hasHUD(usr,"medical")) )
									return
								var/counter = 1
								while(R.fields[text("com_[]", counter)])
									counter++
								if(istype(usr,/mob/living/carbon/human))
									var/mob/living/carbon/human/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.get_authentification_name()] ([U.get_assignment()]) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [game_year]<BR>[t1]")
								if(istype(usr,/mob/living/silicon/robot))
									var/mob/living/silicon/robot/U = usr
									R.fields[text("com_[counter]")] = text("Made by [U.name] ([U.modtype] [U.braintype]) on [time2text(world.realtime, "DDD MMM DD hh:mm:ss")], [game_year]<BR>[t1]")

	if (href_list["lookitem"])
		var/obj/item/I = locate(href_list["lookitem"])
		src.examinate(I)

	if (href_list["lookmob"])
		var/mob/M = locate(href_list["lookmob"])
		src.examinate(M)
	. = ..()


///eyecheck()
///Returns a number between -1 to 2
/mob/living/carbon/human/eyecheck()
	var/number = 0
	if(istype(src.head, /obj/item/clothing/head))			//are they wearing something on their head
		var/obj/item/clothing/head/HFP = src.head			//if yes gets the flash protection value from that item
		number += HFP.flash_protect
	if(istype(src.glasses, /obj/item/clothing/glasses))		//glasses
		var/obj/item/clothing/glasses/GFP = src.glasses
		number += GFP.flash_protect
	if(istype(src.wear_mask, /obj/item/clothing/mask))		//mask
		var/obj/item/clothing/mask/MFP = src.wear_mask
		number += MFP.flash_protect
	return number

///tintcheck()
///Checks eye covering items for visually impairing tinting, such as welding masks
///Checked in life.dm. 0 & 1 = no impairment, 2 = welding mask overlay, 3 = You can see jack, but you can't see shit.
/mob/living/carbon/human/tintcheck()
	var/tinted = 0
	if(istype(src.head, /obj/item/clothing/head))
		var/obj/item/clothing/head/HT = src.head
		tinted += HT.tint
	if(istype(src.glasses, /obj/item/clothing/glasses))
		var/obj/item/clothing/glasses/GT = src.glasses
		tinted += GT.tint
	if(istype(src.wear_mask, /obj/item/clothing/mask))
		var/obj/item/clothing/mask/MT = src.wear_mask
		tinted += MT.tint

	//god help me
	if(istype(back, /obj/item/weapon/rig))
		var/obj/item/weapon/rig/O = back
		if(O.helmet && O.helmet == head && (O.helmet.body_parts_covered & HEAD))
			if((O.offline && O.offline_vision_restriction == 1) || (!O.offline && O.vision_restriction == 1))
				tinted = 2
			if((O.offline && O.offline_vision_restriction == 2) || (!O.offline && O.vision_restriction == 2))
				tinted = 3
	//im so sorry

	return tinted


/mob/living/carbon/human/abiotic(var/full_body = 0)
	if(full_body && ((src.l_hand && !(src.l_hand.flags & ABSTRACT)) || (src.r_hand && !(src.r_hand.flags & ABSTRACT)) || (src.back || src.wear_mask || src.head || src.shoes || src.w_uniform || src.wear_suit || src.glasses || src.l_ear || src.r_ear || src.gloves)))
		return 1

	if((src.l_hand && !(src.l_hand.flags & ABSTRACT)) || (src.r_hand && !(src.r_hand.flags & ABSTRACT)))
		return 1

	return 0


/mob/living/carbon/human/proc/check_dna()
	dna.check_integrity(src)
	return

/mob/living/carbon/human/get_species()

	if(!species)
		set_species()

	return species.name

/mob/living/carbon/human/proc/play_xylophone()
	if(!src.xylophone)
		visible_message("\red [src] begins playing his ribcage like a xylophone. It's quite spooky.","\blue You begin to play a spooky refrain on your ribcage.","\red You hear a spooky xylophone melody.")
		var/song = pick('sound/effects/xylophone1.ogg','sound/effects/xylophone2.ogg','sound/effects/xylophone3.ogg')
		playsound(loc, song, 50, 1, -1)
		xylophone = 1
		spawn(1200)
			xylophone=0
	return

/mob/living/carbon/human/can_inject(var/mob/user, var/error_msg, var/target_zone, var/penetrate_thick = 0)
	. = 1

	if(!target_zone)
		if(!user)
			target_zone = pick("chest","chest","chest","left leg","right leg","left arm", "right arm", "head")
		else
			target_zone = user.zone_sel.selecting

	var/obj/item/organ/external/affecting = get_organ(target_zone)
	var/fail_msg
	if(!affecting)
		. = 0
		fail_msg = "They are missing that limb."
	else if (affecting.status & ORGAN_ROBOT)
		. = 0
		fail_msg = "That limb is robotic."
	else
		switch(target_zone)
			if("head")
				if(head && head.flags & THICKMATERIAL && !penetrate_thick)
					. = 0
			else
				if(wear_suit && wear_suit.flags & THICKMATERIAL && !penetrate_thick)
					. = 0
	if(!. && error_msg && user)
		if(!fail_msg)
			fail_msg = "There is no exposed flesh or thin material [target_zone == "head" ? "on their head" : "on their body"] to inject into."
		user << "<span class='alert'>[fail_msg]</span>"

/mob/living/carbon/human/proc/check_obscured_slots()
	var/list/obscured = list()

	if(wear_suit)
		if(wear_suit.flags_inv & HIDEGLOVES)
			obscured |= slot_gloves
		if(wear_suit.flags_inv & HIDEJUMPSUIT)
			obscured |= slot_w_uniform
		if(wear_suit.flags_inv & HIDESHOES)
			obscured |= slot_shoes

	if(head)
		if(head.flags_inv & HIDEMASK)
			obscured |= slot_wear_mask
		if(head.flags_inv & HIDEEYES)
			obscured |= slot_glasses
		if(head.flags_inv & HIDEEARS)
			obscured |= slot_r_ear
			obscured |= slot_l_ear

	if(obscured.len > 0)
		return obscured
	else
		return null

/mob/living/carbon/human/proc/check_has_mouth()
	// Todo, check stomach organ when implemented.
	var/obj/item/organ/external/head/H = get_organ("head")
	if(!H || !H.can_intake_reagents)
		return 0
	return 1

/mob/living/carbon/human/proc/vomit(hairball=0)
	if(stat==DEAD)return

	if(!check_has_mouth())
		return

	if(!lastpuke)
		lastpuke = 1
		src << "<spawn class='warning'>You feel nauseous..."
		spawn(150)	//15 seconds until second warning
			src << "<spawn class='warning'>You feel like you are about to throw up!"
			spawn(100)	//and you have 10 more for mad dash to the bucket
				Stun(5)

				if(hairball)
					src.visible_message("<span class='warning'>[src] hacks up a hairball!</span>","<span class='warning'>You hack up a hairball!</span>")
				else
					src.visible_message("<span class='warning'>[src] throws up!</span>","<span class='warning'>You throw up!</span>")
				playsound(loc, 'sound/effects/splat.ogg', 50, 1)

				var/turf/location = loc
				if (istype(location, /turf/simulated))
					location.add_vomit_floor(src, 1)

				var/stomach_len = src.stomach_contents.len
				if (stomach_len)
					var/content = src.stomach_contents[stomach_len]
					if (istype(content, /atom/movable))
						var/atom/movable/AM = content
						src.stomach_contents.Remove(AM)
						AM.loc = location

				if(!hairball)
					nutrition -= 40
					adjustToxLoss(-3)
				spawn(350)	//wait 35 seconds before next volley
					lastpuke = 0


/mob/living/carbon/human/proc/get_visible_gender()
	if(wear_suit && wear_suit.flags_inv & HIDEJUMPSUIT && ((head && head.flags_inv & HIDEMASK) || wear_mask))
		return NEUTER
	return gender

/mob/living/carbon/human/proc/increase_germ_level(n)
	if(gloves)
		gloves.germ_level += n
	else
		germ_level += n

/mob/living/carbon/human/revive()

	if(species && !(species.flags & NO_BLOOD))
		vessel.add_reagent("blood",560-vessel.total_volume)
		fixblood()

	// Fix up all organs.
	// This will ignore any prosthetics in the prefs currently.
	species.create_organs(src)

	if(!client || !key) //Don't boot out anyone already in the mob.
		for (var/obj/item/organ/brain/H in world)
			if(H.brainmob)
				if(H.brainmob.real_name == src.real_name)
					if(H.brainmob.mind)
						H.brainmob.mind.transfer_to(src)
						qdel(H)



	for (var/ID in virus2)
		var/datum/disease2/disease/V = virus2[ID]
		V.cure(src)

	..()

/mob/living/carbon/human/proc/is_lung_ruptured()
	var/obj/item/organ/lungs/L = internal_organs_by_name["lungs"]
	if(!L)
		return 0

	return L.is_bruised()

/mob/living/carbon/human/proc/rupture_lung()
	var/obj/item/organ/lungs/L = internal_organs_by_name["lungs"]
	if(!L)
		return 0

	if(!L.is_bruised())
		src.custom_pain("You feel a stabbing pain in your chest!", 1)
		L.damage = L.min_bruised_damage

/*
/mob/living/carbon/human/verb/simulate()
	set name = "sim"
	//set background = 1

	var/damage = input("Wound damage","Wound damage") as num

	var/germs = 0
	var/tdamage = 0
	var/ticks = 0
	while (germs < 2501 && ticks < 100000 && round(damage/10)*20)
		diary << "VIRUS TESTING: [ticks] : germs [germs] tdamage [tdamage] prob [round(damage/10)*20]"
		ticks++
		if (prob(round(damage/10)*20))
			germs++
		if (germs == 100)
			world << "Reached stage 1 in [ticks] ticks"
		if (germs > 100)
			if (prob(10))
				damage++
				germs++
		if (germs == 1000)
			world << "Reached stage 2 in [ticks] ticks"
		if (germs > 1000)
			damage++
			germs++
		if (germs == 2500)
			world << "Reached stage 3 in [ticks] ticks"
	world << "Mob took [tdamage] tox damage"
*/
//returns 1 if made bloody, returns 0 otherwise

/mob/living/carbon/human/add_blood(mob/living/carbon/human/M as mob)
	if (!..())
		return 0
	//if this blood isn't already in the list, add it
	if(blood_DNA[M.dna.unique_enzymes])
		return 0 //already bloodied with this blood. Cannot add more.
	blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
	hand_blood_color = blood_color
	src.update_inv_gloves()
	verbs += /mob/living/carbon/human/proc/bloody_doodle
	return 1 //we applied blood to the item

/mob/living/carbon/human/clean_blood(var/clean_feet)
	.=..()
	if(clean_feet && !shoes && istype(feet_blood_DNA, /list) && feet_blood_DNA.len)
		feet_blood_color = null
		qdel(feet_blood_DNA)
		update_inv_shoes(1)
		return 1

/mob/living/carbon/human/get_visible_implants(var/class = 0)

	var/list/visible_implants = list()
	for(var/obj/item/organ/external/organ in src.organs)
		for(var/obj/item/weapon/O in organ.implants)
			if(!istype(O,/obj/item/weapon/implant) && (O.w_class > class) && !istype(O,/obj/item/weapon/shard/shrapnel))
				visible_implants += O

	return(visible_implants)

/mob/living/carbon/human/generate_name()
	name = species.makeName(gender,src)
	real_name = name
	return name

/mob/living/carbon/human/proc/handle_embedded_objects()

	for(var/obj/item/organ/external/organ in src.organs)
		if(organ.status & ORGAN_SPLINTED) //Splints prevent movement.
			continue
		for(var/obj/item/weapon/O in organ.implants)
			if(!istype(O,/obj/item/weapon/implant) && prob(5)) //Moving with things stuck in you could be bad.
				// All kinds of embedded objects cause bleeding.
				var/msg = null
				switch(rand(1,3))
					if(1)
						msg ="<span class='warning'>A spike of pain jolts your [organ.name] as you bump [O] inside.</span>"
					if(2)
						msg ="<span class='warning'>Your movement jostles [O] in your [organ.name] painfully.</span>"
					if(3)
						msg ="<span class='warning'>[O] in your [organ.name] twists painfully as you move.</span>"
				src << msg

				organ.take_damage(rand(1,3), 0, 0)
				if(!(organ.status & ORGAN_ROBOT)) //There is no blood in protheses.
					organ.status |= ORGAN_BLEEDING
					src.adjustToxLoss(rand(1,3))

/mob/living/carbon/human/verb/check_pulse()
	set category = null
	set name = "Check pulse"
	set desc = "Approximately count somebody's pulse. Requires you to stand still at least 6 seconds."
	set src in view(1)
	var/self = 0

	if(usr.stat == 1 || usr.restrained() || !isliving(usr)) return

	if(usr == src)
		self = 1
	if(!self)
		usr.visible_message("\blue [usr] kneels down, puts \his hand on [src]'s wrist and begins counting their pulse.",\
		"You begin counting [src]'s pulse")
	else
		usr.visible_message("\blue [usr] begins counting their pulse.",\
		"You begin counting your pulse.")

	if(src.pulse)
		usr << "\blue [self ? "You have a" : "[src] has a"] pulse! Counting..."
	else
		usr << "\red [src] has no pulse!"	//it is REALLY UNLIKELY that a dead person would check his own pulse
		return

	usr << "Don't move until counting is finished."
	var/time = world.time
	sleep(60)
	if(usr.l_move_time >= time)	//checks if our mob has moved during the sleep()
		usr << "You moved while counting. Try again."
	else
		usr << "\blue [self ? "Your" : "[src]'s"] pulse is [src.get_pulse(GETPULSE_HAND)]."

/mob/living/carbon/human/proc/set_species(var/new_species, var/default_colour)

	var/datum/species/oldspecies = species
	if(!dna)
		if(!new_species)
			new_species = "Human"
	else
		if(!new_species)
			new_species = dna.species
		else
			dna.species = new_species

	if(species)
		if(species.name && species.name == new_species)
			return

		if(species.language)
			remove_language(species.language)

		if(species.default_language)
			remove_language(species.default_language)

	species = all_species[new_species]

	if(oldspecies)
		if(oldspecies.default_genes.len)
			oldspecies.handle_dna(src,1) // Remove any genes that belong to the old species

	if(vessel)
		vessel = null
	make_blood()

	maxHealth = species.total_health

	if(species.language)
		add_language(species.language)

	if(species.default_language)
		add_language(species.default_language)

	see_in_dark = species.darksight
	if(see_in_dark > 2)
		see_invisible = SEE_INVISIBLE_LEVEL_ONE
	else
		see_invisible = SEE_INVISIBLE_LIVING

	if(species.base_color && default_colour)
		//Apply colour.
		r_skin = hex2num(copytext(species.base_color,2,4))
		g_skin = hex2num(copytext(species.base_color,4,6))
		b_skin = hex2num(copytext(species.base_color,6,8))
	else
		r_skin = 0
		g_skin = 0
		b_skin = 0

	species.create_organs(src)

	if(!dna)
		dna = new /datum/dna(null)
		dna.species = species.name
		dna.real_name = real_name

	species.handle_post_spawn(src)

	spawn(0)
		overlays.Cut()
		update_mutantrace(1)
		regenerate_icons()
		fixblood()

	UpdateAppearance()

	if(species)
		return 1
	else
		return 0

/mob/living/carbon/human/get_default_language()
	if(default_language)
		return default_language

	if(!species)
		return null
	return species.default_language ? all_languages[species.default_language] : null


/mob/living/carbon/human/proc/bloody_doodle()
	set category = "IC"
	set name = "Write in blood"
	set desc = "Use blood on your hands to write a short message on the floor or a wall, murder mystery style."

	if (usr != src)
		return 0 //something is terribly wrong

	if (!bloody_hands)
		verbs -= /mob/living/carbon/human/proc/bloody_doodle

	if (src.gloves)
		src << "<span class='warning'>Your [src.gloves] are getting in the way.</span>"
		return

	var/turf/simulated/T = src.loc
	if (!istype(T)) //to prevent doodling out of mechs and lockers
		src << "<span class='warning'>You cannot reach the floor.</span>"
		return

	var/direction = input(src,"Which way?","Tile selection") as anything in list("Here","North","South","East","West")
	if (direction != "Here")
		T = get_step(T,text2dir(direction))
	if (!istype(T))
		src << "<span class='warning'>You cannot doodle there.</span>"
		return

	var/num_doodles = 0
	for (var/obj/effect/decal/cleanable/blood/writing/W in T)
		num_doodles++
	if (num_doodles > 4)
		src << "<span class='warning'>There is no space to write on!</span>"
		return

	var/max_length = bloody_hands * 30 //tweeter style

	var/message = stripped_input(src,"Write a message. It cannot be longer than [max_length] characters.","Blood writing", "")

	if (message)
		var/used_blood_amount = round(length(message) / 30, 1)
		bloody_hands = max(0, bloody_hands - used_blood_amount) //use up some blood

		if (length(message) > max_length)
			message += "-"
			src << "<span class='warning'>You ran out of blood to write with!</span>"

		var/obj/effect/decal/cleanable/blood/writing/W = new(T)

		W.add_fingerprint(src)

// Allows IPC's to change their monitor display
/mob/living/carbon/human/proc/change_monitor()
	set category = "IC"
	set name = "Change Monitor Display"
	set desc = "Change the display on your monitor."

	if(stat || paralysis || stunned || weakened)
		src << "<span class='warning'>You cannot change your monitor display in your current state.</span>"
		return

	var/list/hair = list()
	for(var/i in hair_styles_list)
		var/datum/sprite_accessory/hair/tmp_hair = hair_styles_list[i]
		if(species.name in tmp_hair.species_allowed)
			hair += i

	var/new_style = input(src, "Select a monitor display", "Monitor Display")  as null|anything in hair
	if(stat || paralysis || stunned || weakened)
		return
	if(new_style)
		h_style = new_style

	update_hair()

//Putting a couple of procs here that I don't know where else to dump.
//Mostly going to be used for Vox and Vox Armalis, but other human mobs might like them (for adminbuse).
/mob/living/carbon/human/proc/leap()
	set category = "Abilities"
	set name = "Leap"
	set desc = "Leap at a target and grab them aggressively."

	if(last_special > world.time)
		return

	if(stat || paralysis || stunned || weakened || lying || restrained() || buckled)
		src << "You cannot leap in your current state."
		return

	var/list/choices = list()
	for(var/mob/living/M in view(6,src))
		if(!istype(M,/mob/living/silicon))
			choices += M
	choices -= src

	var/mob/living/T = input(src,"Who do you wish to leap at?") as null|anything in choices

	if(!T || !src || src.stat) return

	if(get_dist(get_turf(T), get_turf(src)) > 6) return

	if(last_special > world.time)
		return

	if(stat || paralysis || stunned || weakened || lying || restrained() || buckled)
		src << "You cannot leap in your current state."
		return

	last_special = world.time + 75
	status_flags |= LEAPING

	src.visible_message("<span class='warning'><b>\The [src]</b> leaps at [T]!</span>")
	src.throw_at(get_step(get_turf(T),get_turf(src)), 5, 1, src)
	playsound(src.loc, 'sound/voice/shriek1.ogg', 50, 1)

	sleep(5)

	if(status_flags & LEAPING) status_flags &= ~LEAPING

	if(!src.Adjacent(T))
		src << "\red You miss!"
		return

	T.Weaken(5)

	//Only official raider vox get the grab and no self-prone."
	if(src.mind && src.mind.special_role != "Vox Raider")
		src.Weaken(5)
		return

	var/use_hand = "left"
	if(l_hand)
		if(r_hand)
			src << "\red You need to have one hand free to grab someone."
			return
		else
			use_hand = "right"

	src.visible_message("<span class='warning'><b>\The [src]</b> seizes [T] aggressively!</span>")

	var/obj/item/weapon/grab/G = new(src,T)
	if(use_hand == "left")
		l_hand = G
	else
		r_hand = G

	G.state = GRAB_AGGRESSIVE
	G.icon_state = "grabbed1"
	G.synch()

/mob/living/carbon/human/proc/gut()
	set category = "Abilities"
	set name = "Gut"
	set desc = "While grabbing someone aggressively, rip their guts out or tear them apart."

	if(last_special > world.time)
		return

	if(stat || paralysis || stunned || weakened || lying)
		src << "\red You cannot do that in your current state."
		return

	var/obj/item/weapon/grab/G = locate() in src
	if(!G || !istype(G))
		src << "\red You are not grabbing anyone."
		return

	if(G.state < GRAB_AGGRESSIVE)
		src << "\red You must have an aggressive grab to gut your prey!"
		return

	last_special = world.time + 50

	visible_message("<span class='warning'><b>\The [src]</b> rips viciously at \the [G.affecting]'s body with its claws!</span>")

	if(istype(G.affecting,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = G.affecting
		H.apply_damage(50,BRUTE)
		if(H.stat == 2)
			H.gib()
	else
		var/mob/living/M = G.affecting
		if(!istype(M)) return //wut
		M.apply_damage(50,BRUTE)
		if(M.stat == 2)
			M.gib()

/mob/living/carbon/human/assess_threat(var/obj/machinery/bot/secbot/judgebot, var/lasercolor)
	if(judgebot.emagged == 2)
		return 10 //Everyone is a criminal!

	var/threatcount = 0

	//Lasertag bullshit
	if(lasercolor)
		if(lasercolor == "b")//Lasertag turrets target the opposing team, how great is that? -Sieve
			if(istype(wear_suit, /obj/item/clothing/suit/redtag))
				threatcount += 4
			if((istype(r_hand,/obj/item/weapon/gun/energy/laser/redtag)) || (istype(l_hand,/obj/item/weapon/gun/energy/laser/redtag)))
				threatcount += 4
			if(istype(belt, /obj/item/weapon/gun/energy/laser/redtag))
				threatcount += 2

		if(lasercolor == "r")
			if(istype(wear_suit, /obj/item/clothing/suit/bluetag))
				threatcount += 4
			if((istype(r_hand,/obj/item/weapon/gun/energy/laser/bluetag)) || (istype(l_hand,/obj/item/weapon/gun/energy/laser/bluetag)))
				threatcount += 4
			if(istype(belt, /obj/item/weapon/gun/energy/laser/bluetag))
				threatcount += 2

		return threatcount

	//Check for ID
	var/obj/item/weapon/card/id/idcard = get_idcard()
	if(judgebot.idcheck && !idcard)
		threatcount += 4

	//Check for weapons
	if(judgebot.weaponscheck)
		if(!idcard || !(access_weapons in idcard.access))
			if(judgebot.check_for_weapons(l_hand))
				threatcount += 4
			if(judgebot.check_for_weapons(r_hand))
				threatcount += 4
			if(judgebot.check_for_weapons(belt))
				threatcount += 2

	//Check for arrest warrant
	if(judgebot.check_records)
		var/perpname = get_face_name(get_id_name())
		var/datum/data/record/R = find_record("name", perpname, data_core.security)
		if(R && R.fields["criminal"])
			switch(R.fields["criminal"])
				if("*Arrest*")
					threatcount += 5
				if("Incarcerated")
					threatcount += 2
				if("Parolled")
					threatcount += 2

	//Check for dresscode violations
	if(istype(head, /obj/item/clothing/head/wizard) || istype(head, /obj/item/clothing/head/helmet/space/rig/wizard))
		threatcount += 2


	//Loyalty implants imply trustworthyness
	if(isloyal(src))
		threatcount -= 1

	//Agent cards lower threatlevel.
	if(istype(idcard, /obj/item/weapon/card/id/syndicate))
		threatcount -= 5

	return threatcount

/mob/living/carbon/human/singularity_act()
	var/gain = 20
	if(mind)
		if((mind.assigned_role == "Station Engineer") || (mind.assigned_role == "Chief Engineer") )
			gain = 100
		if(mind.assigned_role == "Clown")
			gain = rand(-300, 300)
	investigate_log("([key_name(src)]) has been consumed by the singularity.","singulo") //Oh that's where the clown ended up!
	gib()
	return(gain)

/mob/living/carbon/human/singularity_pull(S, current_size)
	if(current_size >= STAGE_THREE)
		var/list/handlist = list(l_hand, r_hand)
		for(var/obj/item/hand in handlist)
			if(prob(current_size * 5) && hand.w_class >= ((11-current_size)/2)  && unEquip(hand))
				step_towards(hand, src)
				src << "<span class='warning'>\The [S] pulls \the [hand] from your grip!</span>"
	apply_effect(current_size * 3, IRRADIATE)
	if(mob_negates_gravity())
		return
	..()

/mob/living/carbon/human/canBeHandcuffed()
	return 1

/mob/living/carbon/human/InCritical()
	return (health <= config.health_threshold_crit && stat == UNCONSCIOUS)


/mob/living/carbon/human/IsAdvancedToolUser()
	if(species.has_fine_manipulation)
		return 1
	return 0

/mob/living/carbon/human/get_permeability_protection()
	var/list/prot = list("hands"=0, "chest"=0, "groin"=0, "legs"=0, "feet"=0, "arms"=0, "head"=0)
	for(var/obj/item/I in get_equipped_items())
		if(I.body_parts_covered & HANDS)
			prot["hands"] = max(1 - I.permeability_coefficient, prot["hands"])
		if(I.body_parts_covered & UPPER_TORSO)
			prot["chest"] = max(1 - I.permeability_coefficient, prot["chest"])
		if(I.body_parts_covered & LOWER_TORSO)
			prot["groin"] = max(1 - I.permeability_coefficient, prot["groin"])
		if(I.body_parts_covered & LEGS)
			prot["legs"] = max(1 - I.permeability_coefficient, prot["legs"])
		if(I.body_parts_covered & FEET)
			prot["feet"] = max(1 - I.permeability_coefficient, prot["feet"])
		if(I.body_parts_covered & ARMS)
			prot["arms"] = max(1 - I.permeability_coefficient, prot["arms"])
		if(I.body_parts_covered & HEAD)
			prot["head"] = max(1 - I.permeability_coefficient, prot["head"])
	var/protection = (prot["head"] + prot["arms"] + prot["feet"] + prot["legs"] + prot["groin"] + prot["chest"] + prot["hands"])/7
	return protection

/mob/living/carbon/human/proc/get_full_print()
	if(!dna || !dna.uni_identity)
		return
	return md5(dna.uni_identity)

/mob/living/carbon/human/can_see_reagents()
	for(var/obj/item/clothing/C in src) //If they have some clothing equipped that lets them see reagents, they can see reagents
		if(C.scan_reagents)
			return 1
