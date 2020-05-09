#Include classes\classMemory.ahk

#Include classes\GridStencilReader.ahk
#Include classes\Utilities.ahk
#Include classes\Resources.ahk

#MaxThreadsPerHotkey 2

Class NexusTK {
	static nexusMemory
	static baseAddress
	static windowHandle
	static gridStencil
	static mapId
	static GoProContinue            := true
	static classMOBS
	static mobSlotArray				:= Array()

	static SPELL_OFFSET				:= 0x18E08C ; May be: 0x18E09C for some
	static SPELL_OFFSET_2			:= 0x18E08C
	static DIRECTION_OFFSET			:= 0x2DD490
	static GROUP_SIZE_OFFSET		:= 0x2DD490
	static CHAT_OFFSET				:= 0x2DD494
	static TALK_READ_OFFSET			:= 0x2DD4AC
	static STATUS_OFFSET_1			:= 0x2DD5A8
	static STATUS_OFFSET_2			:= 0x2FDB3C
	static MACRO_OFFSET_1			:= 0x2FE1A8 ; May be: 0x?????? for some
	static MACRO_OFFSET_2			:= 0x358	; May be: 0x??? for some
	static MAP_NAME_OFFSET			:= 0x2FE204
	static STAT_OFFSET				:= 0x2FE238
	static MOB_LIST_OFFSET			:= 0x2FE61C
	static NAME_OFFSET				:= 0x2FEC70
	static GROUP_LIST_OFFSET		:= 0x2FECB8
	static SPELL_LIST_OFFSET		:= 0x2FECBC
	static MOB_MEM_LOCATION_OFFSET	:= 0x2FE620
	static GROUND_LIST_OFFSET       := 0x2FE734
	static CREATION_MENU_OFFSET     := 0x2FE05C
	static TINY_DELAY				:= 60
	static SMALL_DELAY				:= 60
	static MEDIUM_DELAY				:= 300
	static LARGE_DELAY				:= 600

	;; Sage / Worldshout / System / Whispers / Clan chat / Subpath chat
	static SYSTEM_READ_ADDRESSES 	:= [0x1359EC, 0x1359F0, 0x145960]
	static SYSTEM_READ_INDEX		:= 1

	static MACRO_RANGE				:= 31
	static MACRO_SIZE				:= 0x108
	static MAX_SPELL_SIZE			:= 53
	static INVENTORY_ITEM_SIZE		:= 0x1FC
	static SPELL_SIZE				:= 0x148
	static GROUP_SIZE				:= 0x12C
	static MOB_SIZE					:= 0x20C
	static GROUND_SIZE              := 0x12C
	
	static KWI_SIN					:= 0
	static MING_KEN					:= 1
	static OHAENG					:= 2
	static UNALIGNED				:= 3

	static M_NORMAL					:= 0
	static M_CTRL					:= 1
	static M_ALT					:= 2

	static M_TYPE_TEXT				:= 1
	static M_TYPE_SPELL				:= 2
	static M_TYPE_ITEM				:= 3

	static SCREEN_REFRESH :=		"{CtrlDown}r{CtrlUp}"

	static DIRECTION_UP				:= 0
	static DIRECTION_RIGHT			:= 1
	static DIRECTION_DOWN			:= 2
	static DIRECTION_LEFT			:= 3

	static K_NONE					:= "NONE"
	static K_UP						:= "{Up}"
	static K_RIGHT					:= "{Right}"
	static K_DOWN					:= "{Down}"
	static K_LEFT					:= "{Left}"

	static K_BACKSPACE				:= "{Backspace}"
	static K_ENTER					:= "{Enter}"
	static K_ESC					:= "{Esc}"
	static K_HOME					:= "{Home}"
	static K_SPACE					:= "{Space}"
	static K_TAB					:= "{Tab}"

	static T_AUTO_ENVELOPE			:= 5000
	static LT_AUTO_ENVELOPE			:= 0
	static T_SCREEN_REFRESH			:= 25000
	static LT_SCREEN_REFRESH		:= 0

	static T_SPELL_CAST             := 250
	static LT_SPELL_CAST            := 0

	static T_ITEM_USE               := 180
	static LT_ITEM_USE              := 0

	static N_GATEWAY                := "Gateway"
	static S_GATEWAY

	static NEXUSTK_INI				:= A_ScriptDir . "\" . "NexusTK.ini"

	static NEXUSCE_APPDATA			:= A_AppData . "\" . "NexusCE"
	static LOG_FILE					:= "nexus-chat.log"

	__new(program:="ahk_exe NexusTK.exe") {
		this.nexusMemory := new _ClassMemory(program, "", hProcessCopy)
		this.baseAddress := this.nexusMemory.baseAddress

		WinGet, hwnd, List, Nexus
		this.windowHandle := hwnd1
		
		this.I_EXP_ENVELOPE := "u" . this.getInventorySlot("Experience envelope pack")
	}

	;----------------------------------------
	; Core Functions
	;----------------------------------------

	sendKeyStroke(key, delay:=0, randomize:=True, slowDown:=False) {
		; Built-in randomization for key strokes
		If (randomize) {
			min := delay - (delay / 10)
			max := delay + (delay / 10)
			Random, x, min, max
		}
		Else {
			x := delay
		}

		hwnd := this.windowHandle
		If (slowDown) {
			SetKeyDelay, 100
		}
		While (GetKeyState("Shift") or GetKeyState("Control")) {
			Sleep 10
		}
		ControlSend,, %key%, AHK_ID %hwnd%
		If (slowDown) {
			SetKeyDelay, 10
		}
		Sleep %x%
	}

	sendKeyClassic(key, keyDelay:=25, refocus:=False) {
		If (refocus) {
			WinGet, winid,, A
		}
		hwnd := this.windowHandle
		SetKeyDelay, %keyDelay%
		If !(WinActive(hwnd)) {
			WinActivate, AHK_ID %hwnd%
		}
		Send, %key%
		If (refocus) {
			WinActivate, ahk_id %winid%
		}
	}

	dropSlot(slot, dropAll:=True) {
		dropType := dropAll?"D":"d"
		dropString := dropType . "{Blind}{" . slot . " DownTemp}{" . slot . "Up}"
		this.sendKeyClassic(dropString, 25, True)
	}

	dropItem(itemName, dropAll:=True) {
		itemSlot := this.getInventorySlot(itemName, False)
		if (itemSlot) {
			dropType := dropAll?"D":"d"
			dropString := dropType . "{Blind}{" . itemSlot . " DownTemp}{" . itemSlot . "Up}"
			this.sendKeyClassic(dropString, 25, True)
		}
	}

	itemInSlot(itemName, slot) {
		for idx, item in this.getInventoryItems() {
			if (item["slot"] == slot) {
				if (item["item"] == itemName) {
					return true
				} else {
					return false
				}
			}
		}

		return false
	}

	moveItem(slotX, slotY) {
		changeString := "c" . "{Blind}{" . slotX . " DownTemp}{" . slotX . "Up}" . "," . "{Blind}{" . slotY . " DownTemp}{" . slotY . "Up}"
		this.sendKeyClassic(changeString, 25, True)
		this.sendKeyStroke(this.K_ENTER, 200)
	}

	sendChat(chatString) {
		SetKeyDelay, 25, 10
		this.sendKeyStoke(this.K_ESC, 100)
		this.sendKeyStroke("'", 80)
		this.sendKeyStroke(chatString, 30)
		this.sendKeyStroke("{Enter}",400)
	}
	
	sendSpellCast(key) {
		If (A_TickCount < (this.LT_SPELL_CAST + this.T_SPELL_CAST)) {
			Random, x, 0, 100
			timeDelta := (this.LT_SPELL_CAST + this.T_SPELL_CAST) - A_TickCount + x
			If (timeDelta > 0) {
				Sleep %timeDelta%
			}
		}

		; Built-in randomization for key strokes
		hwnd := this.windowHandle
		While (GetKeyState("Shift") or GetKeyState("Control")) {
			Sleep 10
		}
		ControlSend,, %key%, AHK_ID %hwnd%
		this.LT_SPELL_CAST := A_TickCount
    }

	sendItemUse(key) {
		If (A_TickCount < (this.LT_ITEM_USE + this.T_ITEM_USE)) {
			Random, x, 0, 40
			timeDelta := (this.LT_ITEM_USE + this.T_ITEM_USE) - A_TickCount + x
			If (timeDelta > 0) {
				Sleep %timeDelta%
			}
		}

		; Built-in randomization for key strokes
		hwnd := this.windowHandle
		ControlSend,, %key%, AHK_ID %hwnd%
		this.LT_ITEM_USE := A_TickCount
	}

	sendClick(x, y) {
		hwnd := this.windowHandle
		ControlClick, x%x% y%y%, AHK_ID %hwnd%
	}

	;----------------------------------------
	; Character Functions
	;----------------------------------------

	getCurrentMana(manaOffset=0x10C) {
		mana := this.nexusMemory.read(this.baseAddress + this.STAT_OFFSET, "UInt", manaOffset)

		return %mana%
	}

	getCurrentVita(vitaOffset:=0x104) {
		vita := this.nexusMemory.read(this.baseAddress + this.STAT_OFFSET, "UInt", vitaOffset)

		return %vita%
	}

	getExp(expOffset=0x114) {
		exp := this.nexusMemory.read(this.baseAddress + this.STAT_OFFSET, "UInt", expOffset)

		return %exp%
	}

	getGrace(graceOffset=0x282) {
		grace := this.nexusMemory.read(this.baseAddress + this.STATUS_OFFSET_2, "UChar", graceOffset)

		Return %grace%
	}

	getGold(goldOffset=0x11C) {
		gold := this.nexusMemory.read(this.baseAddress + this.STAT_OFFSET, "UInt", goldOffset)

		return %gold%
	}

	getMaxVita(vitaOffset=0x28C) {
		vita := this.nexusMemory.read(this.baseAddress + this.STATUS_OFFSET_2, "UInt", vitaOffset)

		Return %vita%
	}

	getVitaRatio() {
		Return (this.getCurrentVita() / this.getMaxVita())
	}

	getMaxMana(manaOffset=0x294) {
		mana := this.nexusMemory.read(this.baseAddress + this.STATUS_OFFSET_2, "UInt", manaOffset)

		Return %mana%
	}

	getManaRatio() {
		Return (this.getCurrentMana() / this.getMaxMana())
	}

	getMight(mightOffset=0x281) {
		might := this.nexusMemory.read(this.baseAddress + this.STATUS_OFFSET_2, "UChar", mightOffset)

		Return %might%
	}

	getWill(willOffset=0x283) {
		will := this.nexusMemory.read(this.baseAddress + this.STATUS_OFFSET_2, "UChar", willOffset)

		Return %will%
	}

	getXCoordinate(xCoordOffset=0xFC) {
		xCoord := this.nexusMemory.read(this.baseAddress + this.STAT_OFFSET, "UInt", xCoordOffset)

		return %xCoord%
	}
	
	getXCoordinateAlt(xCoordOffset=0x100) {
		xCoord := this.nexusMemory.read(this.baseAddress + this.DIRECTION_OFFSET, "UInt", xCoordOffset)

		return %xCoord%
	}

	getDrawXCoordinate(xCoordOffset=0x108) {
		xCoord := this.nexusMemory.read(this.baseAddress + this.DIRECTION_OFFSET, "UInt", xCoordOffset)

		return %xCoord%
	}

	getDrawX2Coordinate(xCoordOffset=0x110) {
		xCoord := this.nexusMemory.read(this.baseAddress + this.DIRECTION_OFFSET, "UInt", xCoordOffset)

		return %xCoord%
	}

	getYCoordinate(yCoordOffset=0x100) {
		yCoord := this.nexusMemory.read(this.baseAddress + this.STAT_OFFSET, "UInt", yCoordOffset)

		return %yCoord%
	}
	
	getYCoordinateAlt(yCoordOffset=0x104) {
		yCoord := this.nexusMemory.read(this.baseAddress + this.DIRECTION_OFFSET, "UInt", yCoordOffset)

		return %yCoord%
	}

	getDrawYCoordinate(yCoordOffset=0x10C) {
		yCoord := this.nexusMemory.read(this.baseAddress + this.DIRECTION_OFFSET, "UInt", yCoordOffset)

		return %yCoord%
	}

	getDrawY2Coordinate(yCoordOffset=0x114) {
		yCoord := this.nexusMemory.read(this.baseAddress + this.DIRECTION_OFFSET, "UInt", yCoordOffset)

		return %yCoord%
	}

	getDrawWidth() {
		Return (this.getDrawX2Coordinate() - this.getDrawXCoordinate())
	}

	getDrawHeight() {
		Return (this.getDrawY2Coordinate() - this.getDrawYCoordinate())
	}

	getDamage(offset_1=0x4, offset_2=0x1F15) {
		damage := this.nexusMemory.read(this.baseAddress + this.STATUS_OFFSET_1, "Char", offset_1, offset_2)

		Return %damage%
	}

	getHit(offset_1=0x4, offset_2=0x1F16) {
		hit := this.nexusMemory.read(this.baseAddress + this.STATUS_OFFSET_1, "Char", offset_1, offset_2)

		Return %hit%
	}

	getAC(offset_1=0x4, offset_2=0x1F14) {
		ac := this.nexusMemory.read(this.baseAddress + this.STATUS_OFFSET_1, "Char", offset_1, offset_2)

		Return %ac%
	}

	getSubpath(offset_1=0x4, offset_2=0x1D0A) {
		subpath := this.nexusMemory.readString(this.baseAddress + this.STATUS_OFFSET_1, 0, "UTF-16", offset_1, offset_2)

		return %subpath%
	}
	
	getPartner(offset_1=0x4, offset_2=0x1F38) {
		partner := this.nexusMemory.readString(this.baseAddress + this.STATUS_OFFSET_1, 0, "UTF-16", offset_1, offset_2)

		return %partner%
	}
	
	getName() {
		name := this.nexusMemory.readString(this.baseAddress + this.NAME_OFFSET, 0, "UTF-16")

		return %name%
	}
	
	getQueriedName(base_offset:=0x2DD480) {
		offsets := [0xF0, 0xA0, 0x1A4, 0x2C, 0x90, 0x764]
		name := this.nexusMemory.readString(this.baseAddress + base_offset, 0, "UTF-16", offsets*)
	}
	
	getChat(offset_1=0x30, offset_2=0x0, offset_3=0x134, offset_4=0x10, offset_5=0x0) {
		chat := this.nexusMemory.readString(this.baseAddress + this.CHAT_OFFSET, 0, "UTF-16", offset_1, offset_2, offset_3, offset_4, offset_5)

		Return %chat%
	}

	getLastTalk(offset_1:=0x424, offset_2:=0x2C, offset_3:=0x10, offset_4:=0x0, offset_5:=0x12C) {
		talk := this.nexusMemory.readString(this.baseAddress + this.TALK_READ_OFFSET, 0, "UTF-16", offset_1, offset_2, offset_3, offset_4, offset_5)

		return talk
	}

	isInvisible(invisibleOffset:=0x19A) {
		invisible := this.nexusMemory.read(this.baseAddress + this.DIRECTION_OFFSET, "UChar", invisibleOffset)
		return invisible > 0
	}
	
	getDirection(asString=false, directionOffset=0x1C5) {
		direction := this.nexusMemory.read(this.baseAddress + this.DIRECTION_OFFSET, "UChar", directionOffset)

		If (asString) {
			Return this.directionToString(direction)
		}

		Return %direction%
	}
	
	turn(directionBit:="", directionString:="") {
		if (directionBit) {
			directionString := this.directionToString(directionBit)
		}
		currentDir := this.getDirection(true)
		if (currentDir != directionString) {
			this.sendKeyStroke(directionString, 100)
		}
	}
	isSelfTargeted(offset=0x1E8) {
		targeted := this.nexusMemory.read(this.baseAddress + this.DIRECTION_OFFSET, "UChar", offset)

		If (targeted == 1) {
			Return True
		}

		Return False
	}
	
	isGroupOn(offset_1=0x4, offset_2=0x1F24) {
		partner := this.nexusMemory.read(this.baseAddress + this.STATUS_OFFSET_1, "UChar", offset_1, offset_2)
	}
	
	directionToString(direction) {
		If (direction == this.DIRECTION_UP) {
			Return "{Up}"
		}
		Else if (direction == this.DIRECTION_RIGHT) {
			Return "{Right}"
		}
		Else if (direction == this.DIRECTION_DOWN) {
			Return "{Down}"
		}
		Else {
			Return "{Left}"
		}
	}

	getActiveSpells() {
		activeSpells := this.nexusMemory.readString(this.SPELL_OFFSET, 0, "UTF-16")
		;; Sometimes this pointer goes blank for just a moment, give it a second shot to prevent bugs
		if (!activeSpells) {
			sleep 300
			activeSpells := this.nexusMemory.readString(this.SPELL_OFFSET, 0, "UTF-16")
		}
		Return %activeSpells%
	}
	
	;; TODO:: figure out a way to parse the integer time and spell name from memory
	;; Comment:: every time the status log changes, this pointer breaks for a split second,
	;;  (i.e. anything that makes a message below your spell box like dropping an item))
	;; maybe we can find a better pointer?  The commented out offsets below point to
	;; the time left on the top spell in your spell box on your screen.  Going 4 bytes
	;; back and reading a 4 byte pointer takes you to a location in memory where
	;; the string of the spell name is.  
	; getActiveSpells(baseOffset := 0x2DD874, offset_1 := 0xC, offset_2 := 0x30, offset_3 := ) {
		
	; }
	
	isSpellActive(spellName, spellList := "") {
		if (!spellList) {
			spellList := this.getActiveSpells()
		}

		result := InStr(spellList, spellName)
		If (result > 0) {
			Return True
		}
		Else {
			Return False
		}
	}

	getLegend(offset_1=0x4, offset_2=0x104, offset_3=0x134, offset_4=0x10, offset_5=0x4) {
		legend := this.nexusMemory.readString(this.baseAddress + this.STATUS_OFFSET_1, 0, "UTF-16", offset_1, offset_2, offset_3, offset_4, offset_5)

		Return legend
	}

	getAlignment() {
		legend := this.getLegend()

		If (InStr(legend, "Kwi-Sin")) {
			Return this.KWI_SIN
		} Else If (InStr(legend, "Ming-Ken")) {
			Return this.MING_KEN
		} Else If (InStr(legend, "Ohaeng")) {
			Return this.OHAENG
		} Else {
			return this.UNALIGNED
		}
	}

	getMark() {
		legend := this.getLegend()

		If (InStr(legend, "Attained Fourth Mark")) {
			Return 4
		} Else If (InStr(legend, "Attained Third Mark")) {
			Return 3
		} Else If (InStr(legend, "Attained Second Mark")) {
			Return 2
		} Else If (InStr(legend, "Attained First Mark")) {
			Return 1
		} Else {
			Return 0
		}
	}

	getAlignmentString(alignment:="") {
		If (!alignment) {
			alignment := this.getAlignment()
		}

		If (alignment == this.KWI_SIN) {
			Return "Kwi-Sin"
		} Else If (alignment == this.MING_KEN) {
			Return "Ming-Ken"
		} Else If (alignment == this.OHAENG) {
			Return "Ohaeng"
		} Else {
			Return "Unaligned"
		}
	}

	getMapName(offset=0xF8) {
		mapName := this.nexusMemory.readString(this.baseAddress + this.MAP_NAME_OFFSET, 0, "UTF-16", offset)

		Return mapName
	}

	isASVed(castValor:=False) {
		armor := False
		sanctuary := False
		valor := castValor?False:True

		;; Sa Spells
		If (this.isSpellActive("Tragedy of Johaih")
			or this.isSpellActive("Blason of SeaNymph")
			or this.isSpellActive("Haiku of Qantao")
			or this.isSpellActive("Epigram of Sute")
			or this.isSpellActive("Fable of Claw")
			or this.isSpellActive("Nonet of Ugh"))
			Return True

		;; Or

		;; Harden armor
		If (this.isSpellActive("Thicken skin")
			or this.isSpellActive("Shield of life")
			or this.isSpellActive("Elemental armor"))
			armor := True
		;; Sanctuary
		If (this.isSpellActive("Protect soul")
			or this.isSpellActive("Guard life")
			or this.isSpellActive("Magic shield"))
			sanctuary := True
		;; Valor
		If (this.isSpellActive("Strengthen")
			or this.isSpellActive("Bless muscles")
			or this.isSpellActive("Power burst"))
			valor := True

		Return (armor and sanctuary and valor)
	}

	;----------------------------------------
	; New Mob-List Functions
	;----------------------------------------
	getMobAllocationSlots() {
		mobBucketArray := Array() ;empty bucket

		; Always add base slot 1 to the bucket array
		arrayReads := [0x00]
		mobBucketArray.Push(this.nexusMemory.read(this.baseAddress + this.MOB_LIST_OFFSET,"UInt"))
		While (mobBaseLocation := this.nexusMemory.read(this.baseAddress + this.MOB_LIST_OFFSET,"UInt", arrayReads*)) {
			mobBucketArray.Push(mobBaseLocation)
			arrayReads.Push(0x00)
		}

		this.mobSlotArray := Array()
		slotNDX := 1
		For index, element In mobBucketArray {
			this.mobSlotArray.Push(mobBucketArray[index])
			Loop 31 {
				this.mobSlotArray.Push(this.mobSlotArray[slotNDX] + this.MOB_SIZE)
				slotNDX++
			}
			slotNDX := slotNDX + 1 ; need to add an extra 1 because each element
								   ; in mob base slot array is not necessarily contiguous in memory
		}

		Return

	}
	
	getGroundAllocationSlots() {
		groundBucketArray := Array() ;empty bucket

		; Always add base slot 1 to the bucket array
		arrayReads := [0x00]
		groundBucketArray.Push(this.nexusMemory.read(this.baseAddress + this.GROUND_LIST_OFFSET,"UInt"))
		While (groundBaseLocation := this.nexusMemory.read(this.baseAddress + this.GROUND_LIST_OFFSET,"UInt", arrayReads*)) {
			groundBucketArray.Push(groundBaseLocation)
			arrayReads.Push(0x00)
		}

		groundSlotArray := Array()
		slotNDX := 1
		For index, element In groundBucketArray {
			groundSlotArray.Push(groundBucketArray[index])
			Loop 7 {
				groundSlotArray.Push(groundSlotArray[slotNDX] + this.GROUND_SIZE)
				slotNDX++
			}
			slotNDX := slotNDX + 1 ; need to add an extra 1 because each element
								   ; in mob base slot array is not necessarily contiguous in memory
		}

		Return groundSlotArray
	}


	;----------------------------------------
	; Mob-List Functions
	;----------------------------------------


	isMobInvisible(mobIndex, offset_1=0x19E) {
		;; mobIndex: 0 is the first mob in list
		invisibleByte := this.nexusMemory.read(offset_1 + this.mobSlotArray[mobIndex], "UChar")

		If (invisibleByte == 2) {
			Return True
		}

		Return False
	}

	isMobValid(mobIndex, mob_offset1:=0x174, mob_offset2:=0x1D4, player_offset:=0x1E8) { ;; 0x174?  0x178?  0x1C0?
		;; mobIndex: 0 is the first mob in list
		if (this.isPlayer("", mobIndex)) {
			validByte := this.nexusMemory.read(player_offset + this.mobSlotArray[mobIndex], "UInt")
			return validByte
		} Else {
			validByte1 := this.nexusMemory.read(mob_offset1 + this.mobSlotArray[mobIndex], "UInt")
			if (validByte1) {
				validByte2 := this.nexusMemory.read(mob_offset2 + this.mobSlotArray[mobIndex], "UChar")
				return !validByte2
			}
			Return validByte1 > 0
		}
	}
	
	isPlayer(mob:="", mobIndex:=0) {
		if (mobIndex) {
			name := this.getMobName(mobIndex)
			isInvis := this.isMobInvisible(mobIndex)
		} else if (mob) {
			name := mob["name"]
			isInvis := mob["isInvisible"]
		} else {
			return false
		}
		
		If (name == "" and isInvis) {
			return true
		} Else If (name == "") {
			return false
		} Else {
			return true
		}
	}

	getMobNumGraphics(mobIndex, offset_1=0x178, offset_2=0xC) {
		;; mobIndex: 0 is the first mob in list
		numGraphics := this.nexusMemory.read(offset_1 + this.mobSlotArray[mobIndex], "UChar",  offset_2)
		Return %numGraphics%
	}
	
	getMobPercentVita(mobIndex, healthbar_offset:=0x1E0, percent_offset:=0x12C) {
		check := this.nexusMemory.read(healthbar_offset + this.mobSlotArray[mobIndex], "Int")
		if (check == 0) {
			return 100
		}
		percentVita := this.nexusMemory.read(healthbar_offset + this.mobSlotArray[mobIndex], "UChar", percent_offset)
		return percentVita
	}
	
	getMobActiveSpells(mobIndex, offset_1=0x178, offset_2=0x10, uidOffset=0x148) {
		numSpells := this.getMobNumGraphics(mobIndex)
		slept := false
		scourged := false
		poisoned := false
		if (numSpells) {
			for idx in rangeincl(1, numSpells) {
				graphicId := this.nexusMemory.read(offset_1 + this.mobSlotArray[mobIndex], "Short",  offset_2, multiplyHex(0x04, idx - 1), uidOffset)
				if (graphicId == 1) {
					slept := true
				} else if (graphicId == 33) {
					scourged := true
				} else if (graphicId == 0) {
					poisoned := true
				}
			}
		}
		return {"scourged":scourged, "slept":slept, "poisoned":poisoned}
	}

	getMobXCoordinate(mobIndex, offset_1=0x104) {
		;; mobIndex: 0 is the first mob in list
		xCoord := this.nexusMemory.read(offset_1 + this.mobSlotArray[mobIndex], "Int")

		Return %xCoord%
	}

	getMobDrawXCoordinate(mobIndex, offset_1=0x10C) {
		;; mobIndex: 0 is the first mob in list
		xCoord := this.nexusMemory.read(offset_1 + this.mobSlotArray[mobIndex], "Int")

		Return %xCoord%
	}

	getMobDrawX2Coordinate(mobIndex, offset_1=0x114) {
		;; mobIndex: 0 is the first mob in list
		xCoord := this.nexusMemory.read(offset_1 + this.mobSlotArray[mobIndex], "Int")

		Return %xCoord%
	}

	getMobYCoordinate(mobIndex, offset_1=0x108) {
		;; mobIndex: 0 is the first mob in list
		yCoord := this.nexusMemory.read(offset_1 + this.mobSlotArray[mobIndex], "Int")

		Return %yCoord%
	}

	getMobDrawYCoordinate(mobIndex, offset_1=0x110) {
		;; mobIndex: 0 is the first mob in list
		yCoord := this.nexusMemory.read(offset_1 + this.mobSlotArray[mobIndex], "Int")

		Return %yCoord%
	}

	getMobDrawY2Coordinate(mobIndex, offset_1=0x118) {
		;; mobIndex: 0 is the first mob in list
		yCoord := this.nexusMemory.read(offset_1 + this.mobSlotArray[mobIndex], "Int")

		Return %yCoord%
	}

	getMobDrawWidth(mobIndex) {
		Return (this.getMobDrawX2Coordinate(mobIndex) - this.getMobDrawXCoordinate(mobIndex))
	}

	getMobDrawHeight(mobIndex) {
		Return (this.getMobDrawY2Coordinate(mobIndex) - this.getMobDrawYCoordinate(mobIndex))
	}

	getMobName(mobIndex, offset_1=0x12E) {
		;; mobIndex: 0 is the first mob in list
		name := this.nexusMemory.readString(offset_1 + this.mobSlotArray[mobIndex], 0, "UTF-16")

		Return %name%
	}

	getMobDirection(mobIndex, offset_1=0x1C9, asString=false) {
		;; mobIndex: 0 is the first mob in list
		directionBit := this.nexusMemory.read(offset_1 + this.mobSlotArray[mobIndex], "UChar")

		If (asString) {
			If (directionBit == this.DIRECTION_UP) {
				Return "up"
			}
			Else if (directionBit == this.DIRECTION_RIGHT) {
				Return "right"
			}
			Else if (directionBit == this.DIRECTION_DOWN) {
				Return "down"
			}
			Else {
				Return "left"
			}
		}

		Return directionBit
	}

	getMobUID(mobIndex, offset_1=0x180) {
		;; mobIndex: 0 is the first mob in list
		UID := this.nexusMemory.read(offset_1 + this.mobSlotArray[mobIndex], "Int")

		Return %UID%
	}

	queryMobInfo(mobIndex) {
		this.getMobAllocationSlots()
		name := this.getMobName(mobIndex)
		validity := this.isMobValid(mobIndex)
		invisBit := this.isMobInvisible(mobIndex)
		xCoord := this.getMobXCoordinate(mobIndex)
		xDrawCoord := this.getMobDrawXCoordinate(mobIndex)
		yCoord := this.getMobYCoordinate(mobIndex)
		yDrawCoord := this.getMobDrawYCoordinate(mobIndex)
		direction := this.getMobDirection(mobIndex, true) ; asString := true

		MsgBox, Mob Info:`n Name: %name%`n isValid?: %validity%`n Direction: %direction%`n X: %xCoord%, Y: %yCoord%`n Invisible: %invisBit%
	}
	
	getTargetedMob() {
		validMobs := this.getValidMobs()
		for ndx, mobindex in validMobs {
			if this.isMobTargeted(mobindex) {
				mob := this.getMobInfo(mobindex)
				return mob
			}
		}
		return false
	}

	isMobTargeted(mobIndex, offset_1=0x1EC) {
		targetBit := this.nexusMemory.read(offset_1 + this.mobSlotArray[mobIndex], "UChar")
		Return targetBit
	}

	getValidMobs() {
		this.getMobAllocationSlots()
		validMobs := Array()

		mobIndex := 1
		maxMobs := this.mobSlotArray.Length()
		Loop %maxMobs% {
			mobValidity := this.isMobValid(mobIndex)
			if (mobValidity) {
				validMobs.Push(mobIndex)
			}
			mobIndex := mobIndex + 1
		}

		Return %validMobs%
	}
	
	getMobIndexByUID(UID, mobInfo) {
		For idx, member in mobInfo {
			If (member["UID"] == UID) {
				Return member["index"]
			}
		}
		Return False
	}
	
	getMobIndex(name, mobInfo) {
		For idx, member in mobInfo {
			If (member["name"] == name) {
				Return member["index"]
			}
		}
		Return False
	}

	getPlayer(name, playerInfo:="") {
		if !(playerInfo) {
			playerInfo := this.compilePlayerInfo()
		}
		For idx, member in playerInfo {
			If (member["name"] == name) {
				Return member
			}
		}
		Return False
	}
	
	getMobInfo(mobIndex) {
		direction := this.getMobDirection(mobIndex)
		UID := this.getMobUID(mobIndex)
		xCoord := this.getMobXCoordinate(mobIndex)
		xDrawCoord := this.getMobDrawXCoordinate(mobIndex)
		yCoord := this.getMobYCoordinate(mobIndex)
		yDrawCoord := this.getMobDrawYCoordinate(mobIndex)
		drawWidth := this.getMobDrawWidth(mobIndex)
		drawHeight := this.getMobDrawHeight(mobIndex)
		name := this.getMobName(mobIndex)
		isInvisible := this.isMobInvisible(mobIndex)
		activeSpells := this.getMobActiveSpells(mobIndex)
		percentVita := this.getMobPercentVita(mobIndex)
		if (xCoord > 256 or yCoord > 256) {
			return ""
		} Else {
			mob := {"index": mobIndex, "direction": direction, "UID": uid, "xCoord": xCoord, "xDrawCoord": xDrawCoord, "yCoord": yCoord, "yDrawCoord": yDrawCoord, "drawWidth": drawWidth, "drawHeight": drawHeight, "name": name, "isInvisible": isInvisible, "activeSpells": activeSpells, "percentVita":percentVita}
			return mob
		}
	}
	
	compileMobInfo2() {
		mobInfo := Array()
		validMobs := this.getValidMobs()

		For index, mobIndex in validMobs {
			mob := this.getMobInfo(mobIndex)
			if (mob) {
				mobInfo.push(mob)
			}
		}

		Return mobInfo
	}
	
	getMonsterTypes(monsterInfo:=False) {
		if !(monsterInfo) {
			monsterInfo := this.compileMobInfo2()
		}
		hash := {}
		uidArray := []

		for index, monster in monsterInfo {
			if (!hash[monster["uid"]]) {
				hash[monster["uid"]] := 1
				uidArray.push(monster["uid"])
			}
		}
		return uidArray
	}
	
	compilePlayerInfo() {
		playerInfo := Array()
		validMobs := this.getValidMobs()
		For index, mobIndex in validMobs {
			if (this.isPlayer("", mobIndex)) {
				player := this.getMobInfo(mobIndex)
				; MsgBox % "PlayerX: " . player["xCoord"] . "`nPlayerY: " . player["yCoord"] . "`nPlayerName: " . player["name"]
				if (player) {
					playerInfo.push(player)
				}
			}
		}
		
		Return playerInfo
	}
	
	compileMonsterInfo() {
		monsterInfo := Array()
		validMobs := this.getValidMobs()
		For index, mobIndex in validMobs {
			if !(this.isPlayer("", mobIndex)) {
				monster := this.getMobInfo(mobIndex)
				; MsgBox % "PlayerX: " . player["xCoord"] . "`nPlayerY: " . player["yCoord"] . "`nPlayerName: " . player["name"]
				if (monster) {
					monsterInfo.push(monster)
				}
			}
		}
		
		Return monsterInfo
	}
	
	printMobCoordinates() {
		mobInfo := this.compileMobInfo2()
		printStr := "Mob Coords:"
		For idx, mob in mobInfo {
			printStr := printStr . "`n" . mob["xCoord"] . ", " . mob["yCoord"]
		}
		MsgBox % printStr
	}
	
	checkForSurroundingMobs() {
		mobInfo := this.compileMobInfo2()
		myXCoord := this.getXCoordinate()
		myYCoord := this.getYCoordinate()

		left := this.checkForMobAtCoordinate(myXCoord-1, myYCoord, mobInfo)
		right := this.checkForMobAtCoordinate(myXCoord+1, myYCoord, mobInfo)
		up := this.checkForMobAtCoordinate(myXCoord, myYCoord-1, mobInfo)
		down := this.checkForMobAtCoordinate(myXCoord, myYCoord+1, mobInfo)

		directions := {"left" : left, "right" : right, "up" : up, "down" : down}
		Return directions
	}

	checkForMobAtCoordinate(xCoord, yCoord, mobInfo) {
		For index, element in mobInfo {
			If (!element["name"]) {
				If (element["xCoord"] == xCoord) {
					If (element["yCoord"] == yCoord) {
						Return True
					}
				}
			}
		}
		Return False
	}

	targetCloseMob(tabKey, maxDistance, maxLoops:=10) {
		mobInfo := this.compileMobInfo2()
		mob := this.getTargetedMob(mobInfo)
		loops := 0
		While (this.checkDistance(this.getXCoordinate(), this.getYCoordinate(), mob["xCoord"], mob["yCoord"]) > maxDistance) {
			this.sendKeyStroke(tabKey, this.SMALL_DELAY)
			mobInfo := this.compileMobInfo2()
			mob := this.getTargetedMob(mobInfo)

			loops := loops + 1
			If (loops >= maxLoops) {
				Break
			}
		}
	}

	isMonsterTargeted() {
		mobInfo := this.compileMobInfo2()
		mob := this.getTargetedMob(mobInfo)

		Return (mob["name"] == "")
	}

	getClosestAdjacentCoord(mobX, mobY) {
		sX := this.getXCoordinate()
		sY := this.getYCoordinate()
		adjX := [mobX    , mobX,     mobX - 1, mobX + 1]
		adjY := [mobY - 1, mobY + 1, mobY,     mobY    ]
		dist := Array()
		min_idx := 0
		min_dist := 999
		For idx in rangeincl(1, adjX.Length()) {
			dist[idx] := this.checkDistance(sX, sY, adjX[idx], adjY[idx])
			If (dist[idx] < min_dist) {
				min_idx := idx
				min_dist := dist[idx]
			}
		}
		coords := {"xCoord" : adjX[min_idx], "yCoord" : adjY[min_idx]}
		return coords
	}
	isMonsterAdjacent() {
		mobInfo := this.compileMobInfo2()
		mob := this.getTargetedMob(mobInfo)

		If (mob["xCoord"] == (this.getXCoordinate() - 1) and mob["yCoord"] == this.getYCoordinate()) {
			Return True
		} Else If (mob["xCoord"] == (this.getXCoordinate() + 1) and mob["yCoord"] == this.getYCoordinate()) {
			Return True
		} Else If (mob["xCoord"] == this.getXCoordinate() and (mob["yCoord"] == this.getYCoordinate() - 1)) {
			Return True
		} Else If (mob["xCoord"] == this.getXCoordinate() and (mob["yCoord"] == this.getYCoordinate() + 1)) {
			Return True
		}

		Return False
	}
	
	;----------------------------------------
	; Movement Functions
	;----------------------------------------
	tryMove(targetX, targetY) {
		myX := this.getXCoordinate()
		myY := this.getYCoordinate()

		if (xCoord != oldXCoord and yCoord != oldYCoord) {
		moveDir := this.determineBestMoveDirection(myX, myY, targetX, targetY)

			If !(moveDir == this.K_NONE) {
				;MsgBox % "moveDir = " . moveDir . "`n this.K_NONE = " . this.K_NONE
				this.sendKeyStroke(moveDir, 0)
				this.sendKeyStroke(moveDir, 2000)
			}

			newX := this.getXCoordinate()
			newY := this.getYCoordinate()
			If (!(myX == newX) || !(myY == newY)) {
				this.sendKeyStroke(this.SCREEN_REFRESH, 2000)
			}
		}
	}

	;----------------------------------------
	; Follow Functions
	;----------------------------------------

	checkDistanceFromSelf(tX, tY) {
		sX := this.getXCoordinate()
		sY := this.getYCoordinate()
		distance := Abs(Sqrt((tX - sX)**2 + (tY - sY)**2))

		Return distance
	}
	
	screenRefresh(use_Timer := True) {
		if (use_Timer) {
			if (A_TickCount - this.LT_SCREEN_REFRESH > this.T_SCREEN_REFRESH) {
				this.sendKeyStroke(this.SCREEN_REFRESH, 1000)
				random, x, 25000, 30000
				this.T_SCREEN_REFRESH := x
				this.LT_SCREEN_REFRESH := A_TickCount
			}
		} 	else {
			this.sendKeyStroke(this.SCREEN_REFRESH, 1000)
		}
	}

	checkDistance(sX, sY, tX, tY) {
		distance := Abs(Sqrt((tX - sX)**2 + (tY - sY)**2))

		Return distance
	}

	; Check the actual number of tiles a target is away
	checkTileDistance(sX, sY, tX, tY) {
		distance := Abs(sX - tX) + Abs(sY - tY)

		Return distance
	}

	determineBestMoveDirection(sX, sY, tX, tY, bit:=False) {
		xDistance := tX - sX
		yDistance := tY - sY


		If (Abs(xDistance) > Abs(yDistance)) {
			If (xDistance > 0) {
				If (bit)
					Return this.DIRECTION_RIGHT
				Return this.K_RIGHT
			} Else {
				If (bit)
					Return this.DIRECTION_LEFT
				Return this.K_LEFT
			}
		} Else {
			If (yDistance > 0) {
				If (bit)
					Return this.DIRECTION_DOWN
				Return this.K_DOWN
			} Else {
				If (bit)
					Return this.DIRECTION_UP
				Return this.K_UP
			}
		}
		Return False
	}
	
	go(tX, tY, distanceThreshold:=3.0, sX="", sY="") {
		if (!sX) {
			sX := this.getXCoordinate()
			sY := this.getYCoordinate()
		}

		distance := this.checkDistance(sX, sY, tX, tY)
		If (distance > distanceThreshold) {
			direction := this.determineBestMoveDirection(sX, sY, tX, tY)

			SetKeyDelay, 5, 5
			this.sendKeyStroke(direction)
			this.sendKeyStroke(direction)
			SetKeyDelay, 5
		}

		return direction
	}

	;----------------------------------------
	; Group Functions
	;----------------------------------------

	getGroupSize(offset=0x3CB0) {
		groupSize := this.nexusMemory.read(this.baseAddress + this.GROUP_SIZE_OFFSET, "UInt", offset)

		return %groupSize%
	}

;	isGrouped(offset=0x3CB0) {
;		groupSize := this.getGroupSize()
;		If (groupSize) {
;			return True
;		}
;		return False
;	}

	getGroupMember(groupIndex, offset=0x220, maxVitaOffset=0x118, vitaOffset=0x11C, maxManaOffset=0x120, manaOffset=0x124) {
		name := this.nexusMemory.readString(this.baseAddress + this.GROUP_LIST_OFFSET, 0, "UTF-16", multiplyHex(this.GROUP_SIZE, groupIndex) + offset)
		maxVita := this.nexusMemory.read(this.baseAddress + this.GROUP_LIST_OFFSET, "UInt", multiplyHex(this.GROUP_SIZE, groupIndex) + offset + maxVitaOffset)
		vita := this.nexusMemory.read(this.baseAddress + this.GROUP_LIST_OFFSET, "UInt", multiplyHex(this.GROUP_SIZE, groupIndex) + offset + vitaOffset)
		maxMana := this.nexusMemory.read(this.baseAddress + this.GROUP_LIST_OFFSET, "UInt", multiplyHex(this.GROUP_SIZE, groupIndex) + offset + maxManaOffset)
		mana := this.nexusMemory.read(this.baseAddress + this.GROUP_LIST_OFFSET, "UInt", multiplyHex(this.GROUP_SIZE, groupIndex) + offset + manaOffset)

		member := { "name": name, "maxVita": maxVita, "vita": vita, "maxMana": maxMana, "mana": mana }
		Return member
	}

	getGroupInfo() {
		groupSize := this.getGroupSize()

		groupInfo := []

		If (groupSize) {
			For idx in range(groupSize) {
				member := this.getGroupMember(idx)
				groupInfo.Push(member)
			}
		} Else {
			name := this.getName()
			maxVita := this.getMaxVita()
			vita := this.getCurrentVita()
			maxMana := this.getmaxMana()
			mana := this.getCurrentMana()
			member := { "name": name, "maxVita": maxVita, "vita": vita, "maxMana": maxMana, "mana": mana }
			groupInfo.Push(member)
		}

		Return groupInfo
	}

	getGroupList(omitNames="") {
		If !(omitNames) {
			omitNames := []
		}
		groupList := []
		groupInfo := this.getGroupInfo()
		If (groupInfo) {
			For idx, member in groupInfo {
				If !(HasVal(omitNames,member["name"])) {
					groupList.Push(member["name"])
				}
			}
		}
		return groupList
	}

	getOtherClients() {
		selfName := this.getName()
		otherClientsList := []
		WinGet, nexusProcesses, List, Nexus
		Loop %nexusProcesses% {
			WinGet, PID, PID, % "ahk_id " nexusProcesses%A_Index%
			Process, Exist, %PID%
			processId := ErrorLevel
			tempClient := new NexusTK("ahk_pid " processId)
			name := tempClient.getName()
			If (name != selfName) {
				otherClientsList.Push(name)
			}
		}
		return otherClientsList
	}

	getClientByName(name) {
		client := this
		WinGet, nexusProcesses, List, Nexus
		Loop %nexusProcesses% {
			WinGet, PID, PID, % "ahk_id " nexusProcesses%A_Index%
			Process, Exist, %PID%
			processId := ErrorLevel
			tempClient := new NexusTK("ahk_pid " processId)
			tempName := tempClient.getName()
			If (tempName == name) {
				client := tempClient
				Return client
			}
		}
		Return client
	}
	;----------------------------------------
	; Inventory / Spell Functions
	;----------------------------------------

	getSlot(idx, upperAscii=39, lowerAscii=97) {
		If (idx > 25) {
			Return Chr(idx + upperAscii)
		} Else {
			Return Chr(idx + lowerAscii)
		}
	}

	getInventorySlotCount(offset=0x76E8, offset_1=0x1F2) {
		;; a-z
		inventoryCount := 26

		;; A-Z
		For idx in range(26) {
			validBit := this.nexusMemory.read(this.baseAddress + this.SPELL_LIST_OFFSET, "UChar", multiplyHex(this.INVENTORY_ITEM_SIZE, (idx)) - offset + offset_1)
			If (validBit == 0xF) {
				inventoryCount++
			} Else If (validBit == 0x3) {
				;; Last Slot
				inventoryCount++
				Break
			}
		}

		Return inventoryCount
	}

	getEmptyInventorySlotCount() {
		emptySlots := 0

		items := this.getInventoryItems()
		For idx, item in items {
			If (!item["inUse"]) {
				emptySlots++
			}
		}

		Return emptySlots
	}

	getInventoryItems(offset=0xAA80, uidOffset=0x02, labelOffset=0x06, itemOffset=0xA6, ownerOffset=0x146, quantityOffset=0x1E8) {
		inventoryItems := []
		For idx in range(this.MAX_SPELL_SIZE) {
			slot := this.getSlot(idx)
			inUse := this.nexusMemory.read(this.baseAddress + this.SPELL_LIST_OFFSET, "UChar", multiplyHex(this.INVENTORY_ITEM_SIZE, idx) - offset)

			If (!inUse) {
				UID := 0
				label := ""
				item := ""
				owner := ""
				quantity := 0
			} Else {
				UID := this.nexusMemory.read(this.baseAddress + this.SPELL_LIST_OFFSET, "UInt", multiplyHex(this.INVENTORY_ITEM_SIZE, idx) - offset + uidOffset)
				label := this.nexusMemory.readString(this.baseAddress + this.SPELL_LIST_OFFSET, 0, "UTF-16", multiplyHex(this.INVENTORY_ITEM_SIZE, idx) - offset + labelOffset)
				item := this.nexusMemory.readString(this.baseAddress + this.SPELL_LIST_OFFSET, 0, "UTF-16", multiplyHex(this.INVENTORY_ITEM_SIZE, idx) - offset + itemOffset)
				owner := this.nexusMemory.readString(this.baseAddress + this.SPELL_LIST_OFFSET, 0, "UTF-16", multiplyHex(this.INVENTORY_ITEM_SIZE, idx) - offset + ownerOffset)
				quantity:= this.nexusMemory.read(this.baseAddress + this.SPELL_LIST_OFFSET, "UInt", multiplyHex(this.INVENTORY_ITEM_SIZE, idx) - offset + quantityOffset)
			}

			inventoryItem := { "slot": slot, "UID": UID, "label": label, "item": item, "owner": owner, "quantity": quantity, "inUse": inUse }
			inventoryItems.Push(inventoryItem)
		}

		Return inventoryItems
	}

	getInventoryItem(itemName, exactMatch:=False) {
		inventoryItems := this.getInventoryItems()

		for idx, item in inventoryItems {
			if (item["item"] == itemName) {
				return item
			} else if (!exactMatch and InStr(item["item"], itemName)) {
				return item
			}
		}
	}

	shiftWrap(slot) {
		if (isUpper(slot)) {
			Return ("{ShiftDown}" . slot . "{ShiftUp}")
		} Else {
			Return slot
		}
	}

	getInventorySlot(item, shiftWrap:=True) {
		inventoryItem := this.getInventoryItem(item)

		slot := (inventoryItem)?inventoryItem["slot"]:""

		If (shiftWrap and slot and isUpper(slot)) {
			Return ("{ShiftDown}" . slot . "{ShiftUp}")
		} Else {
			Return slot
		}
	}

	getNumberOfItems(itemName) {
		itemCount := 0

		inventoryItems := this.getInventoryItems()

		For idx in range(inventoryItems.Length()) {
			If (inventoryItems[idx]["item"] == itemName) {
				itemCount++
			}
		}

		Return itemCount
	}

	getGroundItems(validOffset:=0x58, xCoordOffset:=0x104, yCoordOffset:=0x108, xDrawCoordOffset:=0x10C, yDrawCoordOffset:=0x110, uidOffset:=0x12C) {
		allocationSlots := this.getGroundAllocationSlots()

		groundItems := []
		For index, slot in allocationSlots {
			valid := this.nexusMemory.read(slot + validOffset, "UShort")
			xCoord := this.nexusMemory.read(slot + xCoordOffset, "UInt")
			xDrawCoord := this.nexusMemory.read(slot + xDrawCoordOffset, "UInt")
			yCoord := this.nexusMemory.read(slot + yCoordOffset, "UInt")
			yDrawCoord := this.nexusMemory.read(slot + yDrawCoordOffset, "UInt")
			drawWidth := this.nexusMemory.read(slot + xDrawCoordOffset + 0x08, "UInt") - xDrawCoord
			drawHeight := this.nexusMemory.read(slot + yDrawCoordOffset + 0x08, "UInt") - yDrawCoord
			uid := this.nexusMemory.read(slot + uidOffset, "UShort")

			If (valid == 0x8CBC) {
				groundItem := { "xCoord": xCoord, "yCoord": yCoord, "xDrawCoord": xDrawCoord, "yDrawCoord": yDrawCoord, "drawWidth": drawWidth, "drawHeight": drawHeight, "uid": uid, "index":index}
				groundItems.Push(groundItem)
			}
		}

		Return groundItems
	}

	getResourceCapacity(resource, fullStackCount) {
		bag5 := "Empty " . StrLower(resource) . " bag"
		bag4 := "Spacious " . StrLower(resource) . " bag"
		bag3 := "Expanding " . StrLower(resource) . " bag"
		bag2 := "Half-full " . StrLower(resource) . " bag"
		bag1 := "Stuffed " . StrLower(resource) . " bag"
		; bag0 := "Filled " . StrLower(resource) . " bag"

		resourceCapacity := this.getNumberOfItems(bag5) * fullStackCount * 5
		+ this.getNumberOfItems(bag4) * fullStackCount * 4
		+ this.getNumberOfItems(bag3) * fullStackCount * 3
		+ this.getNumberOfItems(bag2) * fullStackCount * 2
		+ this.getNumberOfItems(bag5) * fullStackCount * 1
		+ fullStackCount - this.getNumberOfItems(resource)

		return resourceCapacity
	}

	getBaggedResourceQty(resource, fullStackCount) {
		bag1 := "Spacious " . StrLower(resource) . " bag"
		bag2 := "Expanding " . StrLower(resource) . " bag"
		bag3 := "Half-full " . StrLower(resource) . " bag"
		bag4 := "Stuffed " . StrLower(resource) . " bag"
		bag5 := "Filled " . StrLower(resource) . " bag"


		baggedResourceQty := this.getNumberOfItems(bag5) * fullStackCount * 5
		+ this.getNumberOfItems(bag4) * fullStackCount * 4
		+ this.getNumberOfItems(bag3) * fullStackCount * 3
		+ this.getNumberOfItems(bag2) * fullStackCount * 2
		+ this.getNumberOfItems(bag1) * fullStackCount * 1

		return baggedResourceQty
	}

	getSpellList(offset=0x4350, spellOffset=0x08, actionOffset=0xA8) {
		spellList := []
		For idx in range(this.MAX_SPELL_SIZE) {
			slot := this.getSlot(idx)
			inUse := this.nexusMemory.read(this.baseAddress + this.SPELL_LIST_OFFSET, "UChar", multiplyHex(this.SPELL_SIZE, idx) - offset)

			If (!inUse) {
				spell := ""
				action := ""
			} Else {
				spell := this.nexusMemory.readString(this.baseAddress + this.SPELL_LIST_OFFSET, 0, "UTF-16", multiplyHex(this.SPELL_SIZE, idx) - offset + spellOffset)
				action := this.nexusMemory.readString(this.baseAddress + this.SPELL_LIST_OFFSET, 0, "UTF-16", multiplyHex(this.SPELL_SIZE, idx) - offset + actionOffset)
			}

			spellItem := { "slot": slot, "spell": spell, "action": action }
			spellList.Push(spellItem)
		}

		Return spellList
	}

	getSpellSlot(spell, shiftWrap:=True) {
		spellList := this.getSpellList()

		slot := ""
		For idx in range(spellList.Length()) {
			If (spellList[idx]["spell"] == spell) {
				slot := spellList[idx]["slot"]
				Break
			}
		}

		If (shiftWrap and slot and isUpper(slot)) {
			Return ("{ShiftDown}" . slot . "{ShiftUp}")
		} Else {
			Return slot
		}
	}

	getMacroList(typeOffset=0x4, slotOffset=0x8) {
		;; Get Initial Pointer -- User needs to open their Hotkey List first.
		macroPointer := this.nexusMemory.read(this.baseAddress + this.MACRO_OFFSET_1, "UInt", this.MACRO_OFFSET_2)
		While (macroPointer == 0) {
			MsgBox % "Open your 'Menu > Hotkey' to map spells"
			macroPointer := this.nexusMemory.read(this.baseAddress + this.MACRO_OFFSET_1, "UInt", this.MACRO_OFFSET_2)
		}

		macroList := []
		For idx in range(this.MACRO_RANGE) {
			type := this.nexusMemory.read(macroPointer + multiplyHex(this.MACRO_SIZE, idx) + typeOffset, "UChar")
			slot := this.nexusMemory.readString(macroPointer + multiplyHex(this.MACRO_SIZE, idx) + slotOffset)

			If (idx < 10) {
				mode := this.M_NORMAL
			} Else If (idx >= 10 and idx < 20) {
				mode := this.M_CTRL
			} Else If (idx >= 20) {
				mode := this.M_ALT
			}

			macro := { "type": type, "slot": slot, "mode": mode, "num": Mod(idx + 1, 10) }
			macroList.Push(macro)
		}

		return macroList
	}

	envelopeExp(envelopeMacro:="") {
		;; Auto-Enveloping Feature
		If (envelopeMacro == "") {
			envelopeMacro := this.I_EXP_ENVELOPE
		}

		If (envelopeMacro != "u") {
			If (A_TickCount - this.LT_AUTO_ENVELOPE > this.T_AUTO_ENVELOPE) {
				Random, EXP_ENVELOPE_DELAY, 1000000000, 1100000000
				exp := this.getExp()

				If (exp > EXP_ENVELOPE_DELAY) {
					this.sendKeyStroke(this.K_ESC, this.TINY_DELAY)
					this.sendKeyStroke(envelopeMacro, this.MEDIUM_DELAY)
				}

				this.LT_AUTO_ENVELOPE := A_TickCount
			}
		}
	}
	
	;----------------------------------------
	; Menu related functions
	;----------------------------------------
	menuIsOpen(menuOpenOffset:=0x6FE0C4) {
		isOpen := this.nexusMemory.read(menuOpenOffset, "UChar")
		return isOpen
	}

	;; Alias
	isMenuOpen() {
		return this.menuIsOpen()
	}
	
	;; Creation Menu Number of objects to read
	getCreationCount(offset_1:=0x1FC, offset_2:=0x10, offset_3:=0x14, offset_4:=0x108, offset_5:=0x130, offset_6:=0xC) {
		count := this.nexusMemory.read(this.baseAddress + this.CREATION_MENU_OFFSET, "UChar", offset_1, offset_2, offset_3, offset_4, offset_5, offset_6)
		return count
	}
	
	getCreationList(offset_1:=0x1FC, offset_2:=0x10, offset_3:=0x14, offset_4:=0x108, offset_5:=0x130, offset_6:=0x10) {
		creationCount := this.getCreationCount()
		creationListAddress := this.nexusMemory.read(this.baseAddress + this.CREATION_MENU_OFFSET, "UInt", offset_1, offset_2, offset_3, offset_4, offset_5, offset_6)
		objectSize := 0x20C
		stringStart := 0x06
		itemNames := Array()
		for idx in range(creationCount) {
			offset := stringStart + multiplyHex(objectSize, idx)
			itemNames.push(this.nexusMemory.readString(creationListAddress + offset, 0, "UTF-16"))
		}

		return itemNames
	}

	;----------------------------------------
	; Map related functions
	;----------------------------------------
	getMapId(offset_1:=0x2DD4AC, offset_2:=0x3F2) {
		mapId := this.nexusMemory.read(this.baseAddress + offset_1, "UShort", offset_2)
		return mapId
	}


	;----------------------------------------
	; Path finding
	;----------------------------------------
	PathFind(EndX, EndY, Threshold:=0, debug:=False) {
		this.parseGrid()
		;; Overlay Mob Data ontop of grid, dont ever add mobData directly to this.gridStencil
		Grid := this.addMobDataToGrid()

		;; transmute coords to grid coords
		StartX := this.TKCoord2GridCoord(this.getXCoordinate())
		StartY := this.TKCoord2GridCoord(this.getYCoordinate())
		EndX := this.TKCoord2GridCoord(EndX)
		EndY := this.TKCoord2GridCoord(EndY)

		;; Check if there is a mob on this coordinate
		If (Grid[EndX, EndY] == 1) {
			;; Reset the mob data for that specific location
			Grid[EndX, EndY] := this.gridStencil[EndX, EndY]
			Grid[EndX - 1, EndY] := this.gridStencil[EndX - 1, EndY]
			Grid[EndX + 1, EndY] := this.gridStencil[EndX + 1, EndY]
			Grid[EndX, EndY + 1] := this.gridStencil[EndX, EndY + 1]
			Grid[EndX, EndY - 1] := this.gridStencil[EndX, EndY - 1]
			If (Grid[EndX, EndY] == 1) {
				Return [] ;; Bad Waypoint
			}
		}

		Threshold := Threshold * 2

		CurrentScores := []
		CurrentScores[StartX, StartY] := 0 ;map of current scores
		HeuristicScores := []              ;map of heuristic scores
		TotalScores := []
		TotalScores[StartX, StartY] := 0

		OpenHeap := [Object("X", StartX, "Y", StartY)] ;heap containing open nodes
		OpenMap := []
		OpenMap[StartX, StartY] := 1
		VisitedNodes := [] ;map of visited nodes
		Parents := [] ;mapping of nodes to their parents

		While (MaxIndex := ObjMaxIndex(OpenHeap)) ;loop while there are entries in the open list
		{
			; select the node having the lowest total score
			Node := OpenHeap[1]
			NodeX := Node.X
			NodeY := Node.Y ;obtain the minimum value in the heap
			OpenHeap[1] := OpenHeap[MaxIndex], OpenHeap.RemoveAt(MaxIndex), MaxIndex -- ;move the last entry in the heap to the beginning
			Index := 1, ChildIndex := 2
			While (ChildIndex <= MaxIndex) ;; does not get hit on first iteration
			{
				Node1 := OpenHeap[ChildIndex]
				Node2 := OpenHeap[ChildIndex + 1]
				If (ChildIndex < MaxIndex && TotalScores[Node1.X, Node1.Y] > TotalScores[Node2.X, Node2.Y]) { ;obtain the index of the lower of the two child nodes if there are two of them
					ChildIndex ++
				} Else {
					Node2 := Node1
				}
				Node1 := OpenHeap[Index]
				If (TotalScores[Node1.X, Node1.Y] < TotalScores[Node2.X, Node2.Y]) { ;stop updating if the parent is less than or equal to the child
					Break
				}
				Temp1 := OpenHeap[Index]
				OpenHeap[Index] := OpenHeap[ChildIndex]
				OpenHeap[ChildIndex] := Temp1 ;swap the two elements so that the child entry is greater than the parent
				Index := ChildIndex
				ChildIndex <<= 1 ;move to the child entry
			}
			OpenMap[NodeX, NodeY] := 0 ;remove the entry from the open map

			;check if the node is the goal
			; MsgBox % this.checkTileDistance(NodeX, NodeY, EndX, EndY)
			; MsgBox % "NodeX = " . NodeX . "`nNodeY = " . NodeY . "`nEndX = " . EndX . "`nEndY = " . EndY
			If (this.checkTileDistance(NodeX, NodeY, EndX, EndY) <= Threshold)
			{ ; Assemble all nodes
				Path := []
				Loop
				{
					Path.InsertAt(1,Object("X", NodeX, "Y", NodeY))
					Node := Parents[NodeX, NodeY]
					If (!IsObject(Node)) {
						Break
					}
					NodeX := Node.X
					NodeY := Node.Y
				}

				;; Transform the node list into TK coords only prior to returning
				For idxRmv in rangeincl(Path.Length()-1, 2, -2) {
					Path.RemoveAt(idxRmv)
				}
				Path.RemoveAt(1) ; Dont need to include currently standing node in waypoints to some target
				For idxTransform, node in Path {
					Path[idxTransform]["X"] := this.GridCoord2TKCoord(Path[idxTransform]["X"])
					Path[idxTransform]["Y"] := this.GridCoord2TKCoord(Path[idxTransform]["Y"])
				}
				; this.printNodeList(Path)
				Return Path
			}

			VisitedNodes[NodeX, NodeY] := 1

			If (NodeX > 1) {
				this.ScoreNode(EndX, EndY, NodeX, NodeY, Grid, NodeX - 1, NodeY, OpenHeap, OpenMap, VisitedNodes, CurrentScores, HeuristicScores, TotalScores, Parents)
			}
			If (NodeX < ObjMaxIndex(Grid)) {
				this.ScoreNode(EndX, EndY, NodeX, NodeY, Grid, NodeX + 1, NodeY, OpenHeap, OpenMap, VisitedNodes, CurrentScores, HeuristicScores, TotalScores, Parents)
			}
			If (NodeY > 1) {
				this.ScoreNode(EndX, EndY, NodeX, NodeY, Grid, NodeX, NodeY - 1, OpenHeap, OpenMap, VisitedNodes, CurrentScores, HeuristicScores, TotalScores, Parents)
			}
			If (NodeY < ObjMaxIndex(Grid[1])) {
				this.ScoreNode(EndX, EndY, NodeX, NodeY, Grid, NodeX, NodeY + 1, OpenHeap, OpenMap, VisitedNodes, CurrentScores, HeuristicScores, TotalScores, Parents)
			}
		}
		; MsgBox % "could not find a path"
		Return, [] ;could not find a path
	}

	ScoreNode(EndX, EndY, NodeX, NodeY, Grid, NextNodeX, NextNodeY, OpenHeap, OpenMap, VisitedNodes, CurrentScores, HeuristicScores, TotalScores, Parents) {
		 ;next node is a wall or is in the closed list
		If (Grid[NextNodeX, NextNodeY] or VisitedNodes[NextNodeX, NextNodeY]) {
			Return
		}
		BestCurrentScore := CurrentScores[NodeX, NodeY] + 1 ;add the distance between the current node and the next to the current distance

		If (!OpenMap[NextNodeX, NextNodeY])
		{
			HeuristicScores[NextNodeX, NextNodeY] := Abs(EndX - NextNodeX) + Abs(EndY - NextNodeY) ;wip: diagonal distance: Max(Abs(EndX - NextNodeX),Abs(EndY - NextNodeY))

			CurrentScores[NextNodeX, NextNodeY] := BestCurrentScore
			TotalScores[NextNodeX, NextNodeY] := BestCurrentScore + HeuristicScores[NextNodeX, NextNodeY]
			Parents[NextNodeX, NextNodeY] := Object("X", NodeX, "Y", NodeY)

			;append the value to the end of the heap array
			Index := ObjMaxIndex(OpenHeap)
			Index := Index ? (Index + 1) : 1
			OpenHeap[Index] := Object("X", NextNodeX, "Y", NextNodeY)
			OpenMap[NextNodeX, NextNodeY] := 1 ;add the entry to the open map

			;rearrange the array to satisfy the minimum heap property
			ParentIndex := Index >> 1 ; divide by 2
			Node1 := OpenHeap[Index]
			Node2 := OpenHeap[ParentIndex]
			While (Index > 1 && TotalScores[Node1.X, Node1.Y] < TotalScores[Node2.X, Node2.Y]) ;child entry is less than its parent
			{
				Temp1 := OpenHeap[ParentIndex]
				OpenHeap[ParentIndex] := OpenHeap[Index]
				OpenHeap[Index] := Temp1 ;swap the two elements so that the child entry is greater than its parent
				Index := ParentIndex
				ParentIndex >>= 1 ;move to the parent entry
			}
		}
		Else If (BestCurrentScore >= CurrentScores[NextNodeX, NextNodeY])
		{
			CurrentScores[NextNodeX, NextNodeY] := BestCurrentScore
			TotalScores[NextNodeX, NextNodeY] := BestCurrentScore + HeuristicScores[NextNodeX, NextNodeY]
			Parents[NextNodeX, NextNodeY] := Object("X", NodeX, "Y", NodeY)
		}
	}

	parseGrid() {
		mapId := this.getMapId()
		If (mapId != this.mapId) {
			this.mapId := mapId
			stencilReader := new GridStencilReader(mapId)
			this.gridStencil := stencilReader.getGridStencil()
		}
	}

	blockGridCoord(x, y) {
		gridX := this.TKCoord2GridCoord(x)
		gridY := this.TKCoord2GridCoord(y)

		;; Itself, Left, Right, Above, and Below := 1
		this.gridStencil[gridX, gridY] := 1
		this.gridStencil[(gridX - 1), gridY] := 1
		this.gridStencil[(gridX + 1), gridY] := 1
		this.gridStencil[gridX, (gridY-1)] := 1
		this.gridStencil[gridX, (gridY+1)] := 1
	}

	TKCoord2GridCoord(val) {
		Return (val + 1) * 2
	}

	GridCoord2TKCoord(val) {
		Return val  / 2 - 1
	}
	
	areWallsNear(tX, tY) {
		gridX := this.TKCoord2GridCoord(tX)
		gridY := this.TKCoord2GridCoord(tY)
		
		leftwall := this.gridStencil[gridX - 2, gridY]
		rightwall := this.gridStencil[gridX + 2, gridY]
		upwall := this.gridStencil[gridX, gridY - 2]
		downwall := this.gridStencil[gridX, gridY + 2]
		
		return {left: leftwall, right: rightwall, up: upwall, down: downwall}
	}
	
	
 GoProForce(targetX, targetY, steps:=1, targetThreshold:=0, breakIfStuck:=true) {
        mapId := this.getMapId()
        T_GOPRO_CHECK_SCREENSHIFT := 2500
        LT_GOPRO_CHECK_SCREENSHIFT := A_TickCount
        ;; Break condition
        selfX := this.getXCoordinate()
        servX := this.getXCoordinateAlt()
        selfY := this.getYCoordinate()
        servY := this.getYCoordinateAlt()    
        originX := selfX
        originY := selfY
        lastServX := servX
        lastServY := servY
        While (this.checkTileDistance(selfX, selfY, targetX, targetY) > targetThreshold 
        and this.checkTileDistance(selfX, selfY, originX, originY) < steps) { ;; and mapId == this.getMapId()) {
            if (!this.GoProContinue) {
                break
            }
            nodeList := this.PathFind(targetX, targetY, targetThreshold)
            If (nodeList.Length()) {
                this.go(nodeList[1]["X"], nodeList[1]["Y"], 0)
            }
            
            ;; If a menu is open, stop trying to move
            if (this.isMenuOpen()) {
                break
            }
            
            selfX := this.getXCoordinate()
            selfY := this.getYCoordinate()
            ;; If you haven't moved in %T_GO_PRO% ms, break
            if (breakIfStuck) {
                servX := this.getXCoordinateAlt()
                servY := this.getYCoordinateAlt()    
                if ((servX != lastServX or servY != lastServY) or (selfX == servX and selfY == servY)) {
                    LT_GOPRO_CHECK_SCREENSHIFT := A_TickCount
                }
                if (A_TickCount - T_GOPRO_CHECK_SCREENSHIFT > LT_GOPRO_CHECK_SCREENSHIFT) {
                    this.sendKeyStroke(this.SCREEN_REFRESH, 1000)
                    LT_CHECK_SCREENSHIFT := A_TickCount
                }    
            }
            lastServX := servX
            lastServY := servY
        }
    }

	goWithWaypoints(waypoints) {
		for idx, waypoint in waypoints {
			;; Go to waypoint
			if (waypoint.x != this.getXCoordinate() or waypoint.y != this.getYCoordinate()) {
				this.GoProForce(waypoint.x, waypoint.y)
			}

			;; Do Post Move
			If (waypoint.direction != -1) {
				Sleep, 700
				servX := this.getXCoordinateAlt()
				servY := this.getYCoordinateAlt()
				if (servX == waypoint.x and servY == waypoint.y) {
					this.sendKeyStroke(waypoint.direction . waypoint.direction, 700)
				} else {
					this.sendKeyStroke(this.SCREEN_REFRESH, 3000)
					continue
				}
			}
		}
	}

	printNodeList(nodeList, useMsgBox:=true) {
		printStr := "NodeList:`n"
		If (nodeList.Length()) {
			For ndx in rangeincl(1, nodeList.length()){
				printStr := printStr . nodeList[ndx]["X"] . ", " . nodeList[ndx]["Y"] . "`n"
			}
		}
		if (useMsgBox) {
			MsgBox % printStr
		} else {
			return printStr
		}
	}


	addMobDataToGrid() {
		;; copy grid
		Grid := []
		For y in rangeincl(1, this.gridStencil.Length()) {
			Grid[y] := this.gridStencil[y].Clone()
		}
		
		mobInfo := this.compileMobInfo2()
		For idx, mob in mobInfo {
			Grid[this.TKCoord2GridCoord(mob["xCoord"]), this.TKCoord2GridCoord(mob["yCoord"])] := 1
			Grid[this.TKCoord2GridCoord(mob["xCoord"]) + 1, this.TKCoord2GridCoord(mob["yCoord"])] := 1
			Grid[this.TKCoord2GridCoord(mob["xCoord"]) - 1, this.TKCoord2GridCoord(mob["yCoord"])] := 1
			Grid[this.TKCoord2GridCoord(mob["xCoord"]), this.TKCoord2GridCoord(mob["yCoord"]) + 1] := 1
			Grid[this.TKCoord2GridCoord(mob["xCoord"]), this.TKCoord2GridCoord(mob["yCoord"]) - 1] := 1
		}
		return Grid
	}

	writeStencil(filepath:="") {
		If (!filepath) {
			FileSelectFile, filepath, 1, %A_ScriptDir%, Choose Gridstencil Outfile, Config (*.gridstencil)
		}
		this.parseGrid()
		stencilFile := FileOpen(filepath,"w")
		For y in rangeincl(1, this.gridStencil.Length()) {
			printStr := "`n"
			For x in rangeincl(1, this.gridStencil[1].Length()) {
				printStr := printStr . this.gridStencil[x, y]
			}
			stencilFile.Write(printStr)
		}
		stencilFile.Close()
		MsgBox % "File Writing Complete"
	}

	printStencilToMsgBox(stencil) {
		if stencil.Length() {
			printStr := "`n"
			for y in rangeincl(1,stencil.Length()) {
				for x in rangeincl(1, stencil[y].Length()) {
					printStr .= stencil[x, y] 
				}
				printStr .= "`n"
			}
		}
		MsgBox % printStr
	}

	;----------------------------------------
	; General Bot Functions
	;----------------------------------------
	gateIfLow(lowVitaRatio := .15) {
		; Check vita ratio
		vita := this.getCurrentVita()
		maxVita := this.getMaxVita()
		vitaRatio := vita/maxVita

		If (vitaRatio <= lowVitaRatio) {
			; Get gateway spell
			If (!this.S_GATEWAY) {
				macroList := this.getMacroList()
				spellList := this.getSpellList()
				mySpells := new Spells()
				this.S_GATEWAY := mySpells.getGateway(macroList, spellList)
			}

			; Try to cast gateway until map name changes
			currentMapName := this.getMapName()
			newMapName := currentMapName
			while (newMapName == currentMapName) {
				this.sendKeyStroke(this.S_GATEWAY, 200)
				this.sendKeyStroke("S{Enter}", 400)
				newMapName := this.getMapName()
			}

			; Pause any bots that are running
			Pause
		}
	}
	
	logout() {
		this.sendKeyStroke("{AltDown}x{AltUp}", 600)
		this.sendKeyStroke("{Enter}", 100)
	}
}
