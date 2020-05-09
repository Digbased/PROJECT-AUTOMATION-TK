Class Spells {
	static KWI_SIN		:= 0
	static MING_KEN		:= 1
	static OHAENG		:= 2
	static UNALIGNED	:= 3

	static M_NORMAL		:= 0
	static M_CTRL		:= 1
	static M_ALT		:= 2

	static M_TYPE_TEXT	:= 1
	static M_TYPE_SPELL	:= 2
	static M_TYPE_ITEM	:= 3

	static N_GATEWAY    := "Gateway"
	static S_GATEWAY

	createKeyStroke(num, mode) {
		If (mode == this.M_CTRL) {
			Return % "{CtrlDown}" . num . "{CtrlUp}"
		} Else If (mode == this.M_ALT) {
			Return % "{AltDown}" . num . "{AltUp}"
		} Else {
			Return % num
		}
	}

	hasSpell(spell, spellList) {
		For idx in range(spellList.Length()) {
			If (spellList[idx]["spell"] == spell) {
				Return True
			}
		}

		Return False
	}

	getSpellSlot(spell, spellList) {
		For idx in range(spellList.Length()) {
			If (spellList[idx]["spell"] == spell) {
				Return spellList[idx]["slot"]
			}
		}

		Return ""
	}

	getGateway(macroList, spellList) {
		For idx in range(spellList.Length()) {
			For jdx in range(macroList.Length()) {
				;; N_GATEWAY
				If (!this.S_GATEWAY and spellList[idx]["spell"] == this.N_GATEWAY and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
					this.S_GATEWAY := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
				}
			}
		}

		If (!this.S_GATEWAY)
			this.S_GATEWAY := "{ShiftDown}z{ShiftUp}" . this.getSpellSlot(this.N_GATEWAY, spellList)

		return this.S_GATEWAY
	}
}

Class MageSpells Extends Spells {
	static N_ARMOR
	static N_DOZE
	static N_HEAL
	static N_HELLFIRE
	static N_INVOKE
	static N_PARALYZE
	static N_SAM_HELLFIRE
	static N_SANCTUARY
	static N_SCOURGE
	static N_SLEEP
	static N_UNPARALYZE

	static S_ARMOR
	static S_DOZE
	static S_HEAL
	static S_HELLFIRE
	static S_INVOKE
	static S_PARALYZE
	static S_SAM_HELLFIRE
	static S_SANCTUARY
	static S_SCOURGE
	static S_SLEEP
	static S_UNPARALYZE

	__new(macroList, spellList, alignment:="") {

		;; N_ARMOR :: Harden armor
		If (alignment == this.KWI_SIN) {
			this.N_ARMOR := "Thicken skin"
		} Else If (alignment == this.MING_KEN) {
			this.N_ARMOR := "Shield of life"
		} Else If (alignment == this.OHAENG) {
			this.N_ARMOR := "Elemental armor"
		} Else {
			this.N_ARMOR := "Harden armor"
		}

		;; N_DOZE :: Doze
		If (alignment == this.KWI_SIN) {
			this.N_DOZE := "Voids touch"
		} Else If (alignment == this.MING_KEN) {
			this.N_DOZE := "Still ethers"
		} Else If (alignment == this.OHAENG) {
			this.N_DOZE := "Still waters"
		} Else {
			this.N_DOZE := "Doze"
		}

		;; N_HEAL :: Heal
		If (alignment == this.KWI_SIN) {
			If (this.hasSpell("Laughter of Sagu", spellList)) {			;; Sa San
				this.N_HEAL := "Laughter of Sagu"
			} Else If (this.hasSpell("Spirit heal", spellList)) {		;; Sam san
				this.N_HEAL := "Spirit heal"
			} Else If (this.hasSpell("Death denied", spellList)) {		;; Ee san
				this.N_HEAL := "Death denied"
			} Else If (this.hasSpell("Festival of souls", spellList)) {	;; Il san
				this.N_HEAL := "Festival of souls"
			} Else {
				this.N_HEAL := "Still embrace"							;; 90
			}
		} Else If (alignment == this.MING_KEN) {
			If (this.hasSpell("Wisdom of Orb", spellList)) {			;; Sa San
				this.N_HEAL := "Wisdom of Orb"
			} Else If (this.hasSpell("Natures milk", spellList)) {		;; Sam san
				this.N_HEAL := "Natures milk"
			} Else If (this.hasSpell("Natures denial", spellList)) {	;; Ee san
				this.N_HEAL := "Natures denial"
			} Else If (this.hasSpell("Natures bounty", spellList)) {	;; Il san
				this.N_HEAL := "Natures bounty"
			} Else {
				this.N_HEAL := "Infuse life"							;; 90
			}
		} Else If (alignment == this.OHAENG) {
			If (this.hasSpell("Blessing of Hroth", spellList)) {		;; Sa San
				this.N_HEAL := "Blessing of Hroth"
			} Else If (this.hasSpell("Peaceful bliss", spellList)) {	;; Sam san
				this.N_HEAL := "Peaceful bliss"
			} Else If (this.hasSpell("Steel storm", spellList)) {		;; Ee san
				this.N_HEAL := "Steel storm"
			} Else If (this.hasSpell("Ohaeng's blessing", spellList)) {	;; Il san
				this.N_HEAL := "Ohaeng's blessing"
			} Else {
				this.N_HEAL := "Healing rain"							;; 90
			}
		} Else {
			If (this.hasSpell("Solace of LinSkrae", spellList)) {		;; Sa San
				this.N_HEAL := "Solace of LinSkrae"
			} Else If (this.hasSpell("Energy flow", spellList)) {		;; Sam san
				this.N_HEAL := "Energy flow"
			} Else If (this.hasSpell("Bekyun's heal", spellList)) {		;; Ee san
				this.N_HEAL := "Bekyun's heal"
			} Else If (this.hasSpell("Solace", spellList)) {			;; Il san
				this.N_HEAL := "Solace"
			} Else {
				this.N_HEAL := "Rejuvenate"								;; 90
			}
		}

		;; N_HELLFIRE :: Hellfire
		If (alignment == this.KWI_SIN) {
			this.N_HELLFIRE := "Consume soul"
		} Else If (alignment == this.MING_KEN) {
			this.N_HELLFIRE := "Flesh eaters"
		} Else If (alignment == this.OHAENG) {
			this.N_HELLFIRE := "Hurricane"
		} Else {
			this.N_HELLFIRE := "Hellfire"
		}

		;; N_INVOKE :: Invoke
		If (alignment == this.KWI_SIN) {
			this.N_INVOKE := "Spirits power"
		} Else If (alignment == this.MING_KEN) {
			this.N_INVOKE := "Life force"
		} Else If (alignment == this.OHAENG) {
			this.N_INVOKE := "Gather magic"
		} Else {
			this.N_INVOKE := "Invoke"
		}

		;; N_PARALYZE :: Paralyze
		If (this.hasSpell("Incantation of Chains", spellList)) {
			this.N_PARALYZE := "Incantation of Chains"
		} Else If (alignment == this.KWI_SIN) {
			this.N_PARALYZE := "Spirit leash"
		} Else If (alignment == this.MING_KEN) {
			this.N_PARALYZE := "Cold binds"
		} Else If (alignment == this.OHAENG) {
			this.N_PARALYZE := "Lockup"
		} Else {
			this.N_PARALYZE := "Paralyze"
		}

		;; N_SAM_HELLFIRE :: Dooms fire
		If (alignment == this.KWI_SIN) {
			this.N_SAM_HELLFIRE := "Deaths awakening"
		} Else If (alignment == this.MING_KEN) {
			this.N_SAM_HELLFIRE := "Soul rip"
		} Else If (alignment == this.OHAENG) {
			this.N_SAM_HELLFIRE := "Final blow"
		} Else {
			this.N_SAM_HELLFIRE := "Dooms fire"
		}

		;; N_SANCTUARY :: Sanctuary
		If (alignment == this.KWI_SIN) {
			this.N_SANCTUARY := "Protect soul"
		} Else If (alignment == this.MING_KEN) {
			this.N_SANCTUARY := "Guard life"
		} Else If (alignment == this.OHAENG) {
			this.N_SANCTUARY := "Magic shield"
		} Else {
			this.N_SANCTUARY := "Sanctuary"
		}

		;; N_SCOURGE :: Scourge -- For Mass Scourge
		If (alignment == this.KWI_SIN) {
			If (this.hasSpell("Deaths curse", spellList)) {					;; Suppress
				this.N_SCOURGE := "Deaths curse"
			} Else If (this.hasSpell("Death's face", spellList)) {			;; Vex
				this.N_SCOURGE := "Death's face"
			}
		} Else If (alignment == this.MING_KEN) {
			If (this.hasSpell("Weakest will", spellList)) {					;; Suppress
				this.N_SCOURGE := "Weakest will"
			} Else If (this.hasSpell("Un-natural selection", spellList)) {	;; Vex
				this.N_SCOURGE := "Un-natural selection"
			}
		} Else If (alignment == this.OHAENG) {
			If (this.hasSpell("Disrupt", spellList)) {						;; Suppress
				this.N_SCOURGE := "Disrupt"
			} Else If (this.hasSpell("Flaw", spellList)) {					;; Vex
				this.N_SCOURGE := "Flaw"
			}
		} Else {
			If (this.hasSpell("Suppress", spellList)) {						;; Suppress
				this.N_SCOURGE := "Suppress"
			} Else If (this.hasSpell("Vex", spellList)) {					;; Vex
				this.N_SCOURGE := "Vex"
			}
		}

		;; N_SLEEP :: Sleep
		If (alignment == this.KWI_SIN) {
			this.N_SLEEP := "Sweet musings"
		} Else If (alignment == this.MING_KEN) {
			this.N_SLEEP := "Essence of poppies"
		} Else If (alignment == this.OHAENG) {
			this.N_SLEEP := "Stillness"
		} Else {
			this.N_SLEEP := "Sleep"
		}

		;; N_UNPARALYZE :: Cure Paralysis
		If (alignment == this.KWI_SIN) {
			this.N_UNPARALYZE := "Release binds"
		} Else If (alignment == this.MING_KEN) {
			this.N_UNPARALYZE := "Return movement"
		} Else If (alignment == this.OHAENG) {
			this.N_UNPARALYZE := "Free movement"
		} Else {
			this.N_UNPARALYZE := "Cure paralysis"
		}

		If (macroList) {
			;; Map Spell Macros
			For idx in range(spellList.Length()) {
				For jdx in range(macroList.Length()) {
					;; S_ARMOR
					If (!this.S_ARMOR and spellList[idx]["spell"] == this.N_ARMOR and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
						this.S_ARMOR := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
					}
					;; S_DOZE
					If (!this.S_DOZE and spellList[idx]["spell"] == this.N_DOZE and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
						this.S_DOZE := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
					}
					;; S_HEAL
					If (!this.S_HEAL and spellList[idx]["spell"] == this.N_HEAL and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
						this.S_HEAL := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
					}
					;; S_HELLFIRE
					If (!this.S_HELLFIRE and spellList[idx]["spell"] == this.N_HELLFIRE and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
						this.S_HELLFIRE := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
					}
					;; S_INVOKE
					If (!this.S_INVOKE and spellList[idx]["spell"] == this.N_INVOKE and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
						this.S_INVOKE := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
					}
					;; S_PARALYZE
					If (!this.S_PARALYZE and spellList[idx]["spell"] == this.N_PARALYZE and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
						this.S_PARALYZE := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
					}
					;; S_SAM_HELLFIRE
					If (!this.S_SAM_HELLFIRE and spellList[idx]["spell"] == this.N_SAM_HELLFIRE and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
						this.S_SAM_HELLFIRE := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
					}
					;; S_SANCTUARY
					If (!this.S_SANCTUARY and spellList[idx]["spell"] == this.N_SANCTUARY and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
						this.S_SANCTUARY := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
					}
					;; S_SCOURGE
					If (!this.S_SCOURGE and spellList[idx]["spell"] == this.N_SCOURGE and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
						this.S_SCOURGE := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
					}
					;; S_SLEEP
					If (!this.S_SLEEP and spellList[idx]["spell"] == this.N_SLEEP and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
						this.S_SLEEP := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
					}
					;; S_UNPARALYZE
					If (!this.S_UNPARALYZE and spellList[idx]["spell"] == this.N_UNPARALYZE and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
						this.S_UNPARALYZE := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
					}
				}
			}
		}
	}
}

Class PoetSpells Extends Spells {
	static N_ARMOR
	static N_HARDEN_BODY
	static N_HEAL
	static N_INVOKE
	static N_SANCTUARY
	static N_VALOR
	static N_SCOURGE
	static N_SA_ASV
	static N_SA_GROUP_ASV
	static N_INSPIRE
	static N_DH

	static S_ARMOR
	static S_HARDEN_BODY
	static S_HEAL
	static S_INVOKE
	static S_SANCTUARY
	static S_VALOR
	static S_SCOURGE
	static S_SA_ASV
	static S_SA_GROUP_ASV
	static S_INSPIRE
	static S_RESTORE
	static S_DH

	__new(macroList, spellList, alignment:="") {

		;; N_ARMOR :: Harden armor
		If (alignment == this.KWI_SIN) {
			this.N_ARMOR := "Thicken skin"
		} Else If (alignment == this.MING_KEN) {
			this.N_ARMOR := "Shield of life"
		} Else If (alignment == this.OHAENG) {
			this.N_ARMOR := "Elemental armor"
		} Else {
			this.N_ARMOR := "Harden armor"
		}

		;; N_HARDEN_BODY :: Harden body
		If (alignment == this.KWI_SIN) {
			this.N_HARDEN_BODY := "Death's guard"
		} Else If (alignment == this.MING_KEN) {
			this.N_HARDEN_BODY := "Life's protection"
		} Else If (alignment == this.OHAENG) {
			this.N_HARDEN_BODY := "Body of alignment"
		} Else {
			this.N_HARDEN_BODY := "Harden body"
		}

		;; N_HEAL :: Heal
		If (alignment == this.KWI_SIN) {
			If (this.hasSpell("Requiem of Mupa", spellList)) {					;; Sa San
				this.N_HEAL := "Requiem of Mupa"
			} Else If (this.hasSpell("Vital charge", spellList)) {				;; Sam san
				this.N_HEAL := "Vital charge"
			} Else If (this.hasSpell("Kwi-Sin Essence of life", spellList)) {	;; Ee san
				this.N_HEAL := "Kwi-Sin Essence of life"
			} Else If (this.hasSpell("Purity of Spirit", spellList)) {			;; Il san
				this.N_HEAL := "Purity of Spirit"
			} Else {
				this.N_HEAL := "Breath of power"								;; 95
			}
		} Else If (alignment == this.MING_KEN) {
			If (this.hasSpell("Fanfare of WinSong", spellList)) {				;; Sa San
				this.N_HEAL := "Fanfare of WinSong"
			} Else If (this.hasSpell("Blessing of life", spellList)) {			;; Sam san
				this.N_HEAL := "Blessing of life"
			} Else If (this.hasSpell("Life's embrace", spellList)) {			;; Ee san
				this.N_HEAL := "Life's embrace"
			} Else If (this.hasSpell("Natures abundance", spellList)) {			;; Il san
				this.N_HEAL := "Natures abundance"
			} Else {
				this.N_HEAL := "Healing breath"									;; 95
			}
		} Else If (alignment == this.OHAENG) {
			If (this.hasSpell("Aria of InSu", spellList)) {						;; Sa San
				this.N_HEAL := "Aria of InSu"
			} Else If (this.hasSpell("Sacred soil", spellList)) {				;; Sam san
				this.N_HEAL := "Sacred soil"
			} Else If (this.hasSpell("Earths cradle", spellList)) {				;; Ee san
				this.N_HEAL := "Earths cradle"
			} Else If (this.hasSpell("Forge of life", spellList)) {				;; Il san
				this.N_HEAL := "Forge of life"
			} Else {
				this.N_HEAL := "Breath of life"									;; 95
			}
		} Else {
			If (this.hasSpell("Ballad of Min", spellList)) {					;; Sa San
				this.N_HEAL := "Ballad of Min"
			} Else If (this.hasSpell("Charge of life", spellList)) {			;; Sam san
				this.N_HEAL := "Charge of life"
			} Else If (this.hasSpell("Essence of life", spellList)) {			;; Ee san
				this.N_HEAL := "Essence of life"
			} Else If (this.hasSpell("Stream of life", spellList)) {			;; Il san
				this.N_HEAL := "Stream of life"
			} Else {
				this.N_HEAL := "Water of life"									;; 95
			}
		}

		;; N_DH :: Heal
		If (alignment == this.KWI_SIN) {
			If (this.hasSpell("Nocturne of Wilting", spellList)) {					;; Sa San
				this.N_DH := "Nocturne of Wilting"
			} Else If (this.hasSpell("Death coil", spellList)) {				;; Sam san
				this.N_DH := "Death coil"
			} Else If (this.hasSpell("Dark fear", spellList)) {	;; Ee san
				this.N_DH := "Dark fear"
			}
		} Else If (alignment == this.MING_KEN) {
			If (this.hasSpell("Barcarolle of Exhaustion", spellList)) {				;; Sa San
				this.N_DH := "Barcarolle of Exhaustion"
			} Else If (this.hasSpell("Hearts breaking", spellList)) {			;; Sam san
				this.N_DH := "Hearts breaking"
			} Else If (this.hasSpell("Break will", spellList)) {			;; Ee san
				this.N_DH := "Break will"
			}
		} Else If (alignment == this.OHAENG) {
			If (this.hasSpell("Capriccio of Denial", spellList)) {						;; Sa San
				this.N_DH := "Capriccio of Denial"
			} Else If (this.hasSpell("Quicksand", spellList)) {				;; Sam san
				this.N_DH := "Quicksand"
			} Else If (this.hasSpell("Harshen attack", spellList)) {				;; Ee san
				this.N_DH := "Harshen attack"
			}
		} Else {
			If (this.hasSpell("Hymn of Rejection", spellList)) {					;; Sa San
				this.N_DH := "Hymn of Rejection"
			} Else If (this.hasSpell("Deteriorate", spellList)) {			;; Sam san
				this.N_DH := "Deteriorate"
			} Else If (this.hasSpell("Dishearten", spellList)) {			;; Ee san
				this.N_DH := "Dishearten"
			}
		}


		;; N_INVOKE :: Invoke
		If (alignment == this.KWI_SIN) {
			this.N_INVOKE := "Spirits power"
		} Else If (alignment == this.MING_KEN) {
			this.N_INVOKE := "Life force"
		} Else If (alignment == this.OHAENG) {
			this.N_INVOKE := "Gather magic"
		} Else {
			this.N_INVOKE := "Invoke"
		}

		;; N_SANCTUARY :: Sanctuary
		If (alignment == this.KWI_SIN) {
			this.N_SANCTUARY := "Protect soul"
		} Else If (alignment == this.MING_KEN) {
			this.N_SANCTUARY := "Guard life"
		} Else If (alignment == this.OHAENG) {
			this.N_SANCTUARY := "Magic shield"
		} Else {
			this.N_SANCTUARY := "Sanctuary"
		}

		;; N_SCOURGE :: Scourge
		If (alignment == this.KWI_SIN) {
			this.N_SCOURGE := "Damage will"
		} Else If (alignment == this.MING_KEN) {
			this.N_SCOURGE := "Drop guard"
		} Else If (alignment == this.OHAENG) {
			this.N_SCOURGE := "Unalign armor"
		} Else {
			this.N_SCOURGE := "Scourge"
		}

		;; N_VALOR :: Valor
		If (alignment == this.KWI_SIN) {
			this.N_VALOR := "Strengthen"
		} Else If (alignment == this.MING_KEN) {
			this.N_VALOR := "Bless muscles"
		} Else If (alignment == this.OHAENG) {
			this.N_VALOR := "Power burst"
		} Else {
			this.N_VALOR := "Valor"
		}

		;; N_SA_ASV :: Sa ASV
		If (alignment == this.KWI_SIN) {
			this.N_SA_ASV := "Tragedy of Johaih"
		} Else If (alignment == this.MING_KEN) {
			this.N_SA_ASV := "Blason of SeaNymph"
		} Else If (alignment == this.OHAENG) {
			this.N_SA_ASV := "Haiku of Qantao"
		} Else {
			this.N_SA_ASV := "Sonnet of ReShor"
		}

		;; N_SA_GROUP_ASV :: Sa Group ASV
		If (alignment == this.KWI_SIN) {
			this.N_SA_GROUP_ASV := "Epigram of Sute"
		} Else If (alignment == this.MING_KEN) {
			this.N_SA_GROUP_ASV := "Fable of Claw"
		} Else If (alignment == this.OHAENG) {
			this.N_SA_GROUP_ASV := "Nonet of Ugh"
		} Else {
			this.N_SA_GROUP_ASV := "Rhyme of Walsuk"
		}

		;; N_INSPIRE :: Inspire
		If (alignment == this.KWI_SIN) {
			this.N_INSPIRE := "Share energy"
		} Else If (alignment == this.MING_KEN) {
			this.N_INSPIRE := "Bestow power"
		} Else If (alignment == this.OHAENG) {
			this.N_INSPIRE := "Release focus"
		} Else {
			this.N_INSPIRE := "Inspire"
		}

		;; Map Spell Macros
		For idx in range(spellList.Length()) {
			For jdx in range(macroList.Length()) {
				;; S_ARMOR
				If (!this.S_ARMOR and spellList[idx]["spell"] == this.N_ARMOR and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
					this.S_ARMOR := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
				}
				;; S_HARDEN_BODY
				If (!this.S_HARDEN_BODY and spellList[idx]["spell"] == this.N_HARDEN_BODY and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
					this.S_HARDEN_BODY := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
				}
				;; S_HEAL
				If (!this.S_HEAL and spellList[idx]["spell"] == this.N_HEAL and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
					this.S_HEAL := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
				}
				;; S_INVOKE
				If (!this.S_INVOKE and spellList[idx]["spell"] == this.N_INVOKE and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
					this.S_INVOKE := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
				}
				;; S_SANCTUARY
				If (!this.S_SANCTUARY and spellList[idx]["spell"] == this.N_SANCTUARY and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
					this.S_SANCTUARY := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
				}
				;; S_VALOR
				If (!this.S_VALOR and spellList[idx]["spell"] == this.N_VALOR and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
					this.S_VALOR := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
				}
				;; S_SCOURGE
				;If (spellList[idx]["spell"] == "Unalign armor") {
				;	MsgBox % "S_SCOURGE = " . this.S_SCOURGE "`nspell = " . spellList[idx]["spell"] . "`nN_SCOURGE = " . this.N_SCOURGE . "`nsSlot = " . spellList[idx]["slot"] . "`nmSlot = " .  macroList[jdx]["slot"] . "`nmType = " .  macroList[jdx]["type"]
				;}
				If (!this.S_SCOURGE and spellList[idx]["spell"] == this.N_SCOURGE and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
					;MsgBox % "Found scourge"
					this.S_SCOURGE := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
				}
				;; S_SA_ASV
				If (!this.S_SA_ASV and spellList[idx]["spell"] == this.N_SA_ASV and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
					this.S_SA_ASV := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
				}
				;; S_SA_GROUP_ASV
				If (!this.S_SA_GROUP_ASV and spellList[idx]["spell"] == this.N_SA_GROUP_ASV and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
					this.S_SA_GROUP_ASV := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
				}
				;; S_INSPIRE
				If (!this.S_INSPIRE and spellList[idx]["spell"] == this.N_INSPIRE and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
					this.S_INSPIRE := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
				}
				;; S_RESTORE
				If (!this.S_RESTORE and spellList[idx]["spell"] == "Restore" and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
					this.S_RESTORE := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
				}
				;; S_DH
				If (!this.S_DH and spellList[idx]["spell"] == this.N_DH and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
					this.S_DH := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
				}
			}
		}

		;; Check Unmapped Spells
		If (!this.S_ARMOR)
			this.S_ARMOR := "{ShiftDown}z{ShiftUp}" . this.getSpellSlot(this.N_ARMOR, spellList)
		If (!this.S_HARDEN_BODY)
			this.S_HARDEN_BODY := "{ShiftDown}z{ShiftUp}" . this.getSpellSlot(this.N_HARDEN_BODY, spellList)
		If (!this.S_HEAL)
			this.S_HEAL := "{ShiftDown}z{ShiftUp}" . this.getSpellSlot(this.N_HEAL, spellList)
		If (!this.S_INVOKE)
			this.S_INVOKE := "{ShiftDown}z{ShiftUp}" . this.getSpellSlot(this.N_INVOKE, spellList)
		If (!this.S_SANCTUARY)
			this.S_SANCTUARY := "{ShiftDown}z{ShiftUp}" . this.getSpellSlot(this.N_SANCTUARY, spellList)
		If (!this.S_VALOR)
			this.S_VALOR := "{ShiftDown}z{ShiftUp}" . this.getSpellSlot(this.S_VALOR, spellList)
		If (!this.S_SCOURGE)
			this.S_SCOURGE := "{ShiftDown}z{ShiftUp}" . this.getSpellSlot(this.N_SCOURGE, spellList)
		If (!this.S_SA_ASV)
			this.S_SA_ASV := "{ShiftDown}z{ShiftUp}" . this.getSpellSlot(this.N_SA_GROUP_ASV, spellList)
		If (!this.S_SA_GROUP_ASV)
			this.S_SA_GROUP_ASV := "{ShiftDown}z{ShiftUp}" . this.getSpellSlot(this.N_SA_GROUP_ASV, spellList)
		If (!this.S_INSPIRE)
			this.S_INSPIRE := "{ShiftDown}z{ShiftUp}" . this.getSpellSlot(this.N_INSPIRE, spellList)
		If (!this.S_RESTORE)
			this.S_RESTORE := "{ShiftDown}z{ShiftUp}" . this.getSpellSlot("Restore", spellList)
		If (!this.S_DH)
			this.S_DH := "{ShiftDown}z{ShiftUp}" . this.getSpellSlot("N_DH", spellList)
	}
}


Class RogueSpells Extends Spells {
	static S_AMBUSH
	static S_CUNNING
	static S_DESPERATE_ATTACK
	static S_INVISIBLE
	static S_LETHAL_STRIKE
	static S_SLEEP_TRAP
	static S_ZAP

	static N_AMBUSH
	static N_CUNNING
	static N_DESPERATE_ATTACK
	static N_INVISIBLE
	static N_LETHAL_STRIKE
	static N_SLEEP_TRAP
	static N_ZAP

	__new(macroList, spellList, alignment:="") {

		;; N_AMBUSH :: Ambush
		If (alignment == this.KWI_SIN) {
			this.N_AMBUSH := "Displacement"
		} Else If (alignment == this.MING_KEN) {
			this.N_AMBUSH := "Waylay"
		} Else If (alignment == this.OHAENG) {
			this.N_AMBUSH := "Reflect"
		} Else {
			this.N_AMBUSH := "Ambush"
		}
		
		;; N_CUNNING :: Baekho's cunning
		this.N_CUNNING := "Baekho's cunning"

		;; N_DESPERATE_ATTACK ::
		If (alignment == this.KWI_SIN) {
			this.N_DESPERATE_ATTACK := "The voids measure"
		} Else If (alignment == this.MING_KEN) {
			this.N_DESPERATE_ATTACK := "Beastly frenzy"
		} Else If (alignment == this.OHAENG) {
			this.N_DESPERATE_ATTACK := "Tilting the balance"
		} Else {
			this.N_DESPERATE_ATTACK := "Desperate attack"
		}

		;; N_INVISIBLE :: Invisible
		If (alignment == this.KWI_SIN) {
			this.N_INVISIBLE := "Spirits form"
		} Else If (alignment == this.MING_KEN) {
			this.N_INVISIBLE := "Lifes cloak"
		} Else If (alignment == this.OHAENG) {
			this.N_INVISIBLE := "Glass form"
		} Else {
			this.N_INVISIBLE := "Invisible"
		}

		;; N_LETHAL_STRIKE :: Harden body
		If (alignment == this.KWI_SIN) {
			this.N_LETHAL_STRIKE := "Afterlifes embrace"
		} Else If (alignment == this.MING_KEN) {
			this.N_LETHAL_STRIKE := "Ming kens judgement"
		} Else If (alignment == this.OHAENG) {
			this.N_LETHAL_STRIKE := "Calculating blow"
		} Else {
			this.N_LETHAL_STRIKE := "Lethal strike"
		}

		;; N_SLEEP_TRAP
		this.N_SLEEP_TRAP := "Sleep trap"

		;; N_ZAP :: Zap
		If (alignment == this.KWI_SIN) {
			If (this.hasSpell("Spirit strike", spellList)) {				;; 24
				this.N_ZAP := "Spirit strike"
			} Else If (this.hasSpell("Embrace of the void", spellList)) {	;; 18
				this.N_ZAP := "Embrace of the void"
			}
		} Else If (alignment == this.MING_KEN) {
			If (this.hasSpell("Wrath of nature", spellList)) {				;; 24
				this.N_ZAP := "Wrath of nature"
			} Else If (this.hasSpell("Lightning", spellList)) {				;; 18
				this.N_ZAP := "Lightning"
			}
		} Else If (alignment == this.OHAENG) {
			If (this.hasSpell("Thunderclap", spellList)) {					;; 24
				this.N_ZAP := "Thunderclap"
			} Else If (this.hasSpell("Natures storm", spellList)) {			;; 18
				this.N_ZAP := "Natures storm"
			}
		} Else {
			If (this.hasSpell("Ignite", spellList)) {						;; 24
				this.N_ZAP := "Ignite"
			} Else If (this.hasSpell("Singe", spellList)) {					;; 18
				this.N_ZAP := "Singe"
			}
		}

		;; Map Spell Macros
		if (macroList) {
			For idx in range(spellList.Length()) {
				For jdx in range(macroList.Length()) {
					;; S_AMBUSH
					If (!this.S_AMBUSH and spellList[idx]["spell"] == this.N_AMBUSH and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
						this.S_AMBUSH := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
					}
					;; S_CUNNING
					If (!this.S_CUNNING and spellList[idx]["spell"] == this.N_CUNNING and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
						this.S_CUNNING := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
					}
					;; S_DESPERATE_ATTACK
					If (!this.S_DESPERATE_ATTACK and spellList[idx]["spell"] == this.N_DESPERATE_ATTACK and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
						this.S_DESPERATE_ATTACK := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
					}
					;; S_INVISIBLE
					If (!this.S_INVISIBLE and spellList[idx]["spell"] == this.N_INVISIBLE and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
						this.S_INVISIBLE := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
					}
					;; S_LETHAL_STRIKE
					If (!this.S_LETHAL_STRIKE and spellList[idx]["spell"] == this.N_LETHAL_STRIKE and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
						this.S_LETHAL_STRIKE := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
					}
					;; S_SLEEP_TRAP
					If (!this.S_SLEEP_TRAP and spellList[idx]["spell"] == this.N_SLEEP_TRAP and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
						this.S_SLEEP_TRAP := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
					}
					;; S_ZAP
					If (!this.S_ZAP and spellList[idx]["spell"] == this.N_ZAP and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
						this.S_ZAP := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
					}
				}
			}
		}

		;; Check Unmapped Spells
		If (!this.S_AMBUSH)
			this.S_AMBUSH := "{ShiftDown}z{ShiftUp}" . this.getSpellSlot(this.N_AMBUSH, spellList)
		If (!this.S_CUNNING)
			this.S_CUNNING := "{ShiftDown}z{ShiftUp}" . this.getSpellSlot(this.N_CUNNING, spellList)
		If (!this.S_DESPERATE_ATTACK)
			this.S_DESPERATE_ATTACK := "{ShiftDown}z{ShiftUp}" . this.getSpellSlot(this.N_DESPERATE_ATTACK, spellList)
		If (!this.S_INVISIBLE)
			this.S_INVISIBLE := "{ShiftDown}z{ShiftUp}" . this.getSpellSlot(this.N_INVISIBLE, spellList)
		If (!this.S_LETHAL_STRIKE)
			this.S_LETHAL_STRIKE := "{ShiftDown}z{ShiftUp}" . this.getSpellSlot(this.N_LETHAL_STRIKE, spellList)
		If (!this.S_SLEEP_TRAP)
			this.S_SLEEP_TRAP := "{ShiftDown}z{ShiftUp}" . this.getSpellSlot(this.N_SLEEP_TRAP, spellList)
		If (!this.S_ZAP)
			this.S_ZAP := "{ShiftDown}z{ShiftUp}" . this.getSpellSlot(this.N_ZAP, spellList)
	}
}

Class WarriorSpells Extends Spells {
	static N_RAGE
	static N_BACKSTAB
	static N_FLANK
	static N_BLESSING
	static N_POTENCE
	static N_INGRESS
	static N_MOCK
	static N_SLASH		; 63
	static N_BERSERK	; 80
	static N_WHIRLWIND	; 99
	static N_ASSAULT	; Ee san
	static N_SIEGE		; Sam san
	static N_RAMPAGE	; Sa san
	static N_SCREAM
	
	static S_RAGE
	static S_BACKSTAB
	static S_FLANK
	static S_BLESSING
	static S_POTENCE
	static S_INGRESS
	static S_MOCK
	static S_SLASH		; 63
	static S_BERSERK	; 80
	static S_WHIRLWIND	; 99
	static S_ASSAULT	; Ee san
	static S_SIEGE		; Sam san
	static S_RAMPAGE	; Sa san
	static S_SCREAM
	
	__new(macroList, spellList, alignment:="") {

		;; N_RAGE :: Chung ryong's rage
		this.N_RAGE := "Chung ryong's rage"

		;; N_BACKSTAB :: Backstab
		If (alignment == this.KWI_SIN) {
			this.N_BACKSTAB := "Back battle"
		} Else If (alignment == this.MING_KEN) {
			this.N_BACKSTAB := "Back attack"
		} Else If (alignment == this.OHAENG) {
			this.N_BACKSTAB := "Back damage"
		} Else {
			this.N_BACKSTAB := "Backstab"
		}

		;; N_FLANK :: Flank
		If (alignment == this.KWI_SIN) {
			this.N_FLANK := "Flank battle"
		} Else If (alignment == this.MING_KEN) {
			this.N_FLANK := "Flank attack"
		} Else If (alignment == this.OHAENG) {
			this.N_FLANK := "Flank damage"
		} Else {
			this.N_FLANK := "Flank"
		}

		;; N_BLESSING :: Greater blessing
		this.N_BLESSING := "Greater blessing"

		;; N_POTENCE :: Potence
		If (alignment == this.KWI_SIN) {
			this.N_POTENCE := "Spirit arm"
		} Else If (alignment == this.MING_KEN) {
			this.N_POTENCE := "Touch of the bear"
		} Else If (alignment == this.OHAENG) {
			this.N_POTENCE := "Sharpen"
		} Else {
			this.N_POTENCE := "Potence"
		}

		;; N_INGRESS :: Ingress
		If (this.hasSpell("Chung Ryong's Wrath", spellList)) {		;; Sa san
			this.N_INGRESS := "Chung Ryong's Wrath"
		} Else If (this.hasSpell("Dragon's harness", spellList)) {	;; Sam san
			this.N_INGRESS := "Dragon's harness"
		} Else If (this.hasSpell("Dragon's flame", spellList)) {	;; Ee san
			this.N_INGRESS := "Dragon's flame"
		} Else If (this.hasSpell("Viper's venom", spellList)) {		;; Il san
			this.N_INGRESS := "Viper's venom"
		} Else If (alignment == this.KWI_SIN) {						;; 70
			this.N_INGRESS := "Hand of darkness"
		} Else If (alignment == this.MING_KEN) {
			this.N_INGRESS := "Dragons claw"
		} Else If (alignment == this.OHAENG) {
			this.N_INGRESS := "Razors edge"
		} Else {
			this.N_INGRESS := "Ingress"
		}

		;; N_MOCK :: Mock
		this.N_MOCK := "Mock"

		;; N_SLASH :: Slash
		this.N_SLASH := "Slash"

		;; N_BERSERK :: Berserk
		If (alignment == this.KWI_SIN) {
			this.N_BERSERK := "No fear"
		} Else If (alignment == this.MING_KEN) {
			this.N_BERSERK := "Tigers pounce"
		} Else If (alignment == this.OHAENG) {
			this.N_BERSERK := "Winds blast"
		} Else {
			this.N_BERSERK := "Berserk"
		}

		;; N_WHIRLWIND :: Whirlwind -- 99 Vita
		If (alignment == this.KWI_SIN) {
			this.N_WHIRLWIND := "Deaths angel"
		} Else If (alignment == this.MING_KEN) {
			this.N_WHIRLWIND := "Natures own"
		} Else If (alignment == this.OHAENG) {
			this.N_WHIRLWIND := "Bladedance"
		} Else {
			this.N_WHIRLWIND := "Whirlwind"
		}

		;; N_ASSAULT :: Assault -- Ee san Vita
		If (alignment == this.KWI_SIN) {
			this.N_ASSAULT := "Deaths challenge"
		} Else If (alignment == this.MING_KEN) {
			this.N_ASSAULT := "Cold snap"
		} Else If (alignment == this.OHAENG) {
			this.N_ASSAULT := "Volley"
		} Else {
			this.N_ASSAULT := "Assault"
		}

		;; N_SIEGE :: Siege -- Sam san Vita
		If (alignment == this.KWI_SIN) {
			this.N_SIEGE := "Souls freedom"
		} Else If (alignment == this.MING_KEN) {
			this.N_SIEGE := "Life's end"
		} Else If (alignment == this.OHAENG) {
			this.N_SIEGE := "Winter chill"
		} Else {
			this.N_SIEGE := "Siege"
		}

		;; N_RAMPAGE :: Rampage -- Sa san Vita
		If (alignment == this.KWI_SIN) {
			this.N_RAMPAGE := "Destruction Wave"
		} Else If (alignment == this.MING_KEN) {
			this.N_RAMPAGE := "Aura explosion"
		} Else If (alignment == this.OHAENG) {
			this.N_RAMPAGE := "Thousand Blades"
		} Else {
			this.N_RAMPAGE := "Rampage"
		}
		
		
		;; N_SCREAM :: Scream -- Sa san Para
		If (alignment == this.KWI_SIN) {
			this.N_SCREAM := "Violent Voice"
		} Else If (alignment == this.MING_KEN) {
			this.N_SCREAM := "Soul Shout"
		} Else If (alignment == this.OHAENG) {
			this.N_SCREAM := "Raging Roar"
		} Else {
			this.N_SCREAM := "Scream"
		}
		
		;; Map Spell Macros
		For idx in range(spellList.Length()) {
			For jdx in range(macroList.Length()) {
				;; S_RAGE
				If (!this.S_RAGE and spellList[idx]["spell"] == this.N_RAGE and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
					this.S_RAGE := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
				}
				;; S_BACKSTAB
				If (!this.S_BACKSTAB and spellList[idx]["spell"] == this.N_BACKSTAB and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
					this.S_BACKSTAB := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
				}
				;; S_FLANK
				If (!this.S_FLANK and spellList[idx]["spell"] == this.N_FLANK and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
					this.S_FLANK := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
				}
				;; S_BLESSING
				If (!this.S_BLESSING and spellList[idx]["spell"] == this.N_BLESSING and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
					this.S_BLESSING := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
				}
				;; S_POTENCE
				If (!this.S_POTENCE and spellList[idx]["spell"] == this.N_POTENCE and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
					this.S_POTENCE := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
				}
				;; S_INGRESS
				If (!this.S_INGRESS and spellList[idx]["spell"] == this.N_INGRESS and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
					this.S_INGRESS := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
				}
				;; S_MOCK
				If (!this.S_MOCK and spellList[idx]["spell"] == this.N_MOCK and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
					this.S_MOCK := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
				}
				;; S_SLASH
				If (!this.S_SLASH and spellList[idx]["spell"] == this.N_SLASH and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
					this.S_SLASH := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
				}
				;; S_BERSERK
				If (!this.S_BERSERK and spellList[idx]["spell"] == this.N_BERSERK and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
					this.S_BERSERK := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
				}
				;; S_WHIRLWIND
				If (!this.S_WHIRLWIND and spellList[idx]["spell"] == this.N_WHIRLWIND and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
					this.S_WHIRLWIND := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
				}
				;; S_ASSAULT
				If (!this.S_ASSAULT and spellList[idx]["spell"] == this.N_ASSAULT and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
					this.S_ASSAULT := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
				}
				;; S_SIEGE
				If (!this.S_SIEGE and spellList[idx]["spell"] == this.N_SIEGE and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
					this.S_SIEGE := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
				}
				;; S_RAMPAGE
				If (!this.S_RAMPAGE and spellList[idx]["spell"] == this.N_RAMPAGE and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
					this.S_RAMPAGE := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
				}
				;; S_SCREAM
				If (!this.S_SCREAM and spellList[idx]["spell"] == this.N_SCREAM and spellList[idx]["slot"] == macroList[jdx]["slot"] and macroList[jdx]["type"] == this.M_TYPE_SPELL) {
					this.S_SCREAM := this.createKeyStroke(macroList[jdx]["num"], macroList[jdx]["mode"])
				}				
			}
		}
	}
}

class Mobs {

	static MOBS := []

	;; Add Mobs during initialization of "Mobs" class
	__new() {
		this.addMob(688217,  "Dark buck",        true )
		this.addMob(1998973, "Golden rabbit",    true )
		this.addMob(229397,	 "Rabbit",           false)
		this.addMob(688218,	 "Rat",              false)
		this.addMob(294938,	 "Rock snake",       false)
		this.addMob(753837,	 "Sheep",            false)
		this.addMob(360473,	 "Squirrel",         false)
		this.addMob(229402,	 "Wild snake",       true )
		this.addMob(360536,  "Doe",              false)
		this.addMob(360470,  "Fox",              false)
		this.addMob(688151,  "Wolf",             false)
		;; Shadow 3                              
		this.addMob(98582,   "Vanish",           true ) ;; Black pool mobs
		this.addMob(33046,   "Unseen",           true ) ;; Black pool mobs
		this.addMob(164118,  "Masked Illusion",  true ) ;; Black pool mobs
		this.addMob(98580,   "Silent (yellow)",  true ) ;; Yellow Fighter
		this.addMob(164116,  "Swift (pink)",     true ) ;; Purple Fighter
		this.addMob(010101,  "Shadow Sentry",    true ) ;; Sentry
		this.addMob(33032,   "Fatal Ninja",      true ) ;; Boss
		;; Bird 4
		this.addMob(33731,    "Egg",             true )
		this.addMob(295539,   "Brown Bird",      true )
		this.addMob(623219,   "Light Blue Bird", true )
		this.addMob(426611,   "Green Bird",      true )
		this.addMob(688755,   "Yellow Bird",     true )
		this.addMob(1081971,  "Dark blue Bird",  true )
		this.addMob(819827,   "Orange Bird",     true )
		this.addMob(1344115,  "Black Bird",      true )
		this.addMob(1933939,  "Purple Bird",     true )
		this.addMob(1540723,  "Red Bird",        true )
		;; Aklak Training Grounds (Bears)
		this.addMob(164462,  "Brown Bear",       true )
		this.addMob(1409646, "Black Bear",       true )
		this.addMob(33390,   "Blue Bear",        true )
		this.addMob(2065006, "Red Bear",         true )
		;; Omphalos Training Grounds (Deers)
		this.addMob(33398,   "Brown Deer",       true )
		this.addMob(557686,  "Green Deer",       true )
		this.addMob(295542,  "Blue Deer",        true )
		this.addMob(492150,  "Purple Deer",      true )
		

		

		
		
		
	}

	addMob(uid, name:="", aggro:=false) {
		this.MOBS.push({ "uid": uid, "name": name, "aggro": aggro })
	}

	getMobFromName(name) {
		for idx, mob in this.MOBS {
			if (mob["name"] == name) {
				return mob
			}
		}
	}

	getMobFromUid(uid) {
		for idx, mob in this.MOBS {
			if (mob["uid"] == uid) {
				return mob
			}
		}
	}
	
	getMobNameFromUid(uid) {
		for idx, mob in this.MOBS {
			if (mob["uid"] == uid) {
				return mob["name"]
			}
		}
		return ""
	}
	
	getMobUidFromNamed(name) {
		for idx, mob in this.MOBS {
			if (mob["name"] == name) {
				return mob["uid"]
			}
		}
		return ""
	}
}