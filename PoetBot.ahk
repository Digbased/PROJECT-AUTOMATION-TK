#Include NexusTK.ahk

#Include classes\Resources.ahk
#Include classes\Utilities.ahk


;; User-Defined Features, Macros, and Parameters
  ;; Features -- Set to False to disable a feature
  global F_AUTOLOAD_MACROS       := False    ; >> Doesn't work for everyone! <<
  global F_IM_SPECIAL            := True   ; Overrides SPELL_OFFSET to 0x18E09C


  global F_SELF_ASV              := True
  global F_SELF_ASV_CAST_VALOR   := False
  global F_USE_HARDEN_BODY       := True
  global F_USE_RESTORE           := True
  global F_SCOURGE_MOBS          := True
  global F_USE_INSPIRE           := True
  global F_USE_DISHEARTEN        := True
  global F_HEAL_GROUP            := True
  global F_UNGROUPED             := True
  global F_FOLLOWING
  global F_AUTO_RESPOND          := False
  global F_COLLAPSED             := True


;; Macro Setup
  ;;  Inventory Items (i.e., "ui" -- Use 'i')
  global M_HEAL_ORB          := ""
  global M_RESTORE_ORB       := ""
  global M_WINE              := ""
  ;;  Spells (i.e., "3" or "{CtrlDown}2{CtrlUp}")
  global M_HARDEN_BODY       := ""
  global M_INVOKE            := ""
  global M_HEAL              := ""
  global M_COMBO_HEAL        := ""
  global M_ARMOR             := ""
  global M_SANCTUARY         := ""
  global M_VALOR             := ""
  global M_SA_ASV            := ""
  global M_GROUP_ASV         := ""
  global M_RESTORE           := ""
  global M_SCOURGE           := ""
  global M_DISHEARTEN        := ""
  global M_INSPIRE           := ""
  ;; General
  global TAB				 := "{TAB}"
  global VTAB				 := "v"
  global RVTAB				 := "{ShiftDown}v{ShiftUp}"
  global CVTAB				 := "{CtrlDown}v{CtrlUp}"

  ;; Parameters
  global TARGETED_SC_DISTANCE         := 1
  global TARGETED_DH_DISTANCE         := 1
  global HEAL_SELF_VITA_RATIO         := 0.70
  global HEAL_GROUP_VITA_RATIO        := 0.90
  global FORCE_INVOKE_MANA_RATIO      := 0.05
  global TRY_INVOKE_MANA_RATIO        := 0.40
  global MIN_MANA_LEFT_SPIRE_RATIO    := 0.25
  global MISSING_MANA_SPIRE_THRESHOLD := 50000
  global RESTORE_MIN_MANA_RATIO       := 0.25
  global EXIT_SCOURGE_VITA_RATIO      := 0.60
;; GUI / Script Controls (Don't edit)
  global POET_BOT_LOADED     := False
  global POET_BOT_RUNNING    := False
  global GROUP_LIST_INSPIRE
  global GROUP_LIST_DISHEARTEN
  global GROUP_LIST_HEAL
  global GROUP_LIST
  global GROUP_LIST_UIDS := []
  global SELF_NAME
  global MEMORY_HANDLE
  
  ;; Responses
  global RECENTLY_RESPONDED_PLAYERS := []
  global CHAT_BUFFER
  global RESPONSES_HI		:= ["whats up", "yoo", "hey"]
  global RESPONSES_HEY	:= ["hey","hi!", "sup my guy"]


;; Load PoetBot
	MEMORY_HANDLE := new PoetBot("ahk_exe NexusTK.exe")
	SELF_NAME := MEMORY_HANDLE.getName()
	;; Set special offsets
	If (F_IM_SPECIAL) {
		MEMORY_HANDLE.SPELL_OFFSET := 0x18E08C
	} else {
		MEMORY_HANDLE.SPELL_OFFSET := 0x18E08C
	}

	;; Initialize GUI

	;; Add Inventory Items
	  ;; Heal Orb
	Gui, Add, Text, x20 y15, Heal orb:
	Gui, Add, Edit, x100 y10 w120 vC_HEAL_ORB
	GuiControl,, C_HEAL_ORB, %M_HEAL_ORB%
	  ;; Restore Orb
	Gui, Add, Text, x20 y40, Restore orb:
	Gui, Add, Edit, x100 y35 w120 vC_RESTORE_ORB
	GuiControl,, C_RESTORE_ORB, %M_RESTORE_ORB%
	  ;; Wine
	Gui, Add, Text, x20 y65, Wine / Pipe:
	Gui, Add, Edit, x100 y60 w120 vC_WINE
	GuiControl,, C_WINE, %M_WINE%

	;; Add Spells
	  ;; Harden Armor
	Gui, Add, Text, x20 y105, Harden Armor:
	Gui, Add, Edit, x100 y100 w120 vC_ARMOR
	GuiControl,, C_ARMOR, %M_ARMOR%

	  ;; Sanctuary
	Gui, Add, Text, x20 y130, Sanctuary:
	Gui, Add, Edit, x100 y125 w120 vC_SANCTUARY
	GuiControl,, C_SANCTUARY, %M_SANCTUARY%

	  ;; Valor
	Gui, Add, Text, x20 y155, Valor:
	Gui, Add, Edit, x100 y150 w120 vC_VALOR
	GuiControl,, C_VALOR, %M_VALOR%

	  ;; Sa ASV
	Gui, Add, Text, x20 y180, Sa ASV:
	Gui, Add, Edit, x100 y175 w120 vC_SA_ASV
	GuiControl,, C_SA_ASV, %M_SA_ASV%

	  ;; Sa Group ASV
	Gui, Add, Text, x20 y205, Sa Group ASV:
	Gui, Add, Edit, x100 y200 w120 vC_GROUP_ASV
	GuiControl,, C_GROUP_ASV, %M_GROUP_ASV%

	  ;; Harden Body
	Gui, Add, Text, x20 y230, Harden Body:
	Gui, Add, Edit, x100 y225 w120 vC_HARDEN_BODY
	GuiControl,, C_HARDEN_BODY, %M_HARDEN_BODY%

	  ;; Invoke
	Gui, Add, Text, x20 y255, Invoke:
	Gui, Add, Edit, x100 y250 w120 vC_INVOKE
	GuiControl,, C_INVOKE, %M_INVOKE%

	  ;; Heal
	Gui, Add, Text, x20 y280, Heal:
	Gui, Add, Edit, x100 y275 w120 vC_HEAL
	GuiControl,, C_HEAL, %M_HEAL%

	  ;; Restore
	Gui, Add, Text, x20 y305, Restore:
	Gui, Add, Edit, x100 y300 w120 vC_RESTORE
	GuiControl,, C_RESTORE, %M_RESTORE%


	  ;; Scourge
	Gui, Add, Text, x20 y330, Scourge:
	Gui, Add, Edit, x100 y325 w120 vC_SCOURGE
	GuiControl,, C_SCOURGE, %M_SCOURGE%

	  ;; Dishearten
	Gui, Add, Text, x20 y355, Dishearten:
	Gui, Add, Edit, x100 y350 w120 vC_DISHEARTEN
	GuiControl,, C_DISHEARTEN, %M_DISHEARTEN%

	  ;; Inspire
	Gui, Add, Text, x20 y380, Inspire:
	Gui, Add, Edit, x100 y375 w120 vC_INSPIRE
	GuiControl,, C_INSPIRE, %M_INSPIRE%

	  ;; Tab
	Gui, Add, Text, x20 y415, Tab:
	Gui, Add, Edit, x100 y410 w120 vC_TAB
	GuiControl,, C_TAB, %TAB%

	  ;; VTab
	Gui, Add, Text, x20 y440, VTab:
	Gui, Add, Edit, x100 y435 w120 vC_VTAB
	GuiControl,, C_VTAB, %VTAB%
	  ;; CVTab
	Gui, Add, Text, x20 y465, CVTab:
	Gui, Add, Edit, x100 y460 w120 vC_CVTAB
	GuiControl,, C_CVTAB, %CVTAB%
	  ;; RVTab
	Gui, Add, Text, x20 y490, RVTab:
	Gui, Add, Edit, x100 y485 w120 vC_RVTAB
	GuiControl,, C_RVTAB, %RVTAB%

	  ;; Follow
	Gui, Add, Text, x20 y515, Follow a group member
	Gui, Add, ListBox,  x20 y535 r5 vC_FOLLOW_LIST
	;; To be added -- follow distance
	; Gui, Add, Text, x20 y600, Follow Distance
	; Gui, Add, Edit, x270 y252 w20 vC_TARGETED_DH_DISTANCE
	; GuiControl,, C_TARGETED_DH_DISTANCE, %TARGETED_DH_DISTANCE%
	
	;; Start / Pause Button
	Gui, Add, Button, x20 y725 w120 gStartStop vC_START_PAUSE, % "Start [F8]"
	;; Open Config Button
	Gui, Add, Button, x20 y695 w120 gOpenConfig, Open config
	;; Save Config Button
	Gui, Add, Button, x20 y665 w120 gSaveConfig, Save config

	;; Add Features
	  ;; Self ASV
	Gui, Add, Checkbox, x225 y15 vC_SELF_ASV, Self ASV
	GuiControl,, C_SELF_ASV, %F_SELF_ASV%
	Gui, Add, Checkbox, x245 y35 vC_SELF_ASV_CAST_VALOR, Cast Valor
	GuiControl,, C_SELF_ASV_CAST_VALOR, %F_SELF_ASV_CAST_VALOR%
	  ;; Harden Body
	Gui, Add, Checkbox, x225 y55 vC_USE_HARDEN_BODY, Use Harden Body
	GuiControl,, C_USE_HARDEN_BODY, %F_USE_HARDEN_BODY%
	  ;; Scourge
	Gui, Add, Checkbox, x225 y75 vC_SCOURGE_MOBS, Scourge Mobs
	GuiControl,, C_SCOURGE_MOBS, %F_SCOURGE_MOBS%
	  ;; Restore
	Gui, Add, Checkbox, x225 y95 vC_USE_RESTORE, Use Restore
	GuiControl,, C_USE_RESTORE, %F_USE_RESTORE%
	  ;; Im Special
	Gui, Add, Checkbox, x225 y115 vC_IM_SPECIAL, IM SO, SO SPECIAL
	GuiControl,, C_IM_SPECIAL, %F_IM_SPECIAL%
	  ;; Inspire
	Gui, Add, Checkbox, x225 y135 vC_USE_INSPIRE, Inspire group members
	GuiControl,, C_USE_INSPIRE, %F_USE_INSPIRE%
	Gui, Add, ListBox,  x230 y155 r5 Multi vC_INSPIRE_LIST
	  ;; Dishearten
	Gui, Add, Checkbox, x225 y235 vC_USE_DISHEARTEN, DH (around group members)
	GuiControl,, C_USE_DISHEARTEN, %F_USE_DISHEARTEN%
	Gui, Add, Text, x270 y255, Targeted DH Distance
	Gui, Add, Edit, x245 y252 w20 vC_TARGETED_DH_DISTANCE
	GuiControl,, C_TARGETED_DH_DISTANCE, %TARGETED_DH_DISTANCE%
	Gui, Add, ListBox, x230 y275 r5 Multi vC_DISHEARTEN_LIST
	  ;; Heal group members
	Gui, Add, Checkbox, x225 y355 vC_HEAL_GROUP, Heal Group Members
	GuiControl,, C_HEAL_GROUP, %F_HEAL_GROUP%
	Gui, Add, ListBox,  x230 y375 r5 Multi vC_HEAL_GROUP_LIST
	  ;; Ungrouped
	Gui, Add, Checkbox, x225 y455 vC_UNGROUPED, Use Another Clients Group Data
	GuiControl,, C_UNGROUPED, %F_UNGROUPED%
	Gui, Add, ListBox,  x230 y475 r3 vC_UNGROUPED_LIST
	  ;; Heal Self Vita Ratio
	Gui, Add, Text, x250 y550, Heal Self Vita Ratio:
	Gui, Add, Edit, x345 y545 w50 vC_HEAL_GROUP_VITA_RATIO
	GuiControl,, C_HEAL_GROUP_VITA_RATIO, %HEAL_GROUP_VITA_RATIO%
	  ;; Heal Group Vita Ratio
	Gui, Add, Text, x238 y575, Heal Group Vita Ratio:
	Gui, Add, Edit, x345 y570 w50 vC_HEAL_SELF_VITA_RATIO
	GuiControl,, C_HEAL_SELF_VITA_RATIO, %HEAL_SELF_VITA_RATIO%
	  ;; Force Invoke Mana Ratio
	Gui, Add, Text, x220 y600, Force Invoke Mana Ratio:
	Gui, Add, Edit, x345 y595 w50 vC_FORCE_INVOKE_MANA_RATIO
	GuiControl,, C_FORCE_INVOKE_MANA_RATIO, %FORCE_INVOKE_MANA_RATIO%
	  ;; Try Invoke Mana Ratio
	Gui, Add, Text, x230 y625, Try Invoke Mana Ratio:
	Gui, Add, Edit, x345 y620 w50 vC_TRY_INVOKE_MANA_RATIO
	GuiControl,, C_TRY_INVOKE_MANA_RATIO, %TRY_INVOKE_MANA_RATIO%
	  ;; Min Mana Left Spire Ratio
	Gui, Add, Text, x215 y650, Min Mana Left Spire Ratio:
	Gui, Add, Edit, x345 y645 w50 vC_MIN_MANA_LEFT_SPIRE_RATIO
	GuiControl,, C_MIN_MANA_LEFT_SPIRE_RATIO, %MIN_MANA_LEFT_SPIRE_RATIO%
	  ;; Missing Mana Spire Threshold
	Gui, Add, Text, x199 y675, Missing Mana Spire Threshold:
	Gui, Add, Edit, x345 y670 w50 vC_MISSING_MANA_SPIRE_THRESHOLD
	GuiControl,, C_MISSING_MANA_SPIRE_THRESHOLD, %MISSING_MANA_SPIRE_THRESHOLD%
	  ;; Restore Min Mana Ratio
	Gui, Add, Text, x222 y700, Restore Min Mana Ratio:
	Gui, Add, Edit, x345 y695 w50 vC_RESTORE_MIN_MANA_RATIO
	GuiControl,, C_RESTORE_MIN_MANA_RATIO, %RESTORE_MIN_MANA_RATIO%
	   ;; Exit Scourge Vita Ratio
	Gui, Add, Text, x222 y725, Exit Scourge Vita Ratio:
	Gui, Add, Edit, x345 y720 w50 vC_EXIT_SCOURGE_VITA_RATIO
	GuiControl,, C_EXIT_SCOURGE_VITA_RATIO, %EXIT_SCOURGE_VITA_RATIO%

	;; Collapse Button
	Gui, Font, S16, Wingdings
	Gui, Add, Button, x405 y0 w20 h750 gCollapse vC_COLLAPSED, % Chr(216)
	Gui, Font

	;; Navigation Buttons (Left, Right, Up, Down)
	Gui, Font, S16, Wingdings
	Gui, Add, Button, x435 y70 w58 h58 gMoveLeft, % Chr(223)		;; Left
	Gui, Add, Button, x555 y70 w58 h58 gMoveRight, % Chr(224)	;; Right
	Gui, Add, Button, x495 y10 w58 h58 gMoveUp, % Chr(225)		;; Up
	Gui, Add, Button, x495 y70 w58 h58 gMoveDown, % Chr(226)	;; Down
	Gui, Font
		
	;; Responses
	Gui, Add, Button, x435 y10 w28 h28 gSayHi, % "Hi"
	Gui, Add, Button, x435 y40 w28 h28 gSayHey, % "Hey"
	Gui, Font, S16, Wingdings
	Gui, Add, Button, x464 y10 w28 h28 gSayLaugh, % Chr(74)
	Gui, Add, Button, x464 y40 w28 h28 gSayDance, % Chr(92)
	Gui, Font
	Gui, Add, Text, x435 y135 w180 h20 center, Type below to chat (press enter)
	Gui, Add, Edit, x435 y155 w180 h20 vEditChat -WantReturn
	Gui, Add, Button, x-10 y-10 w1 h1 +default gSendChat
	Gui, Add, Checkbox, x435 y180 w100 h20 vC_AUTO_RESPOND, Auto respond
	GuiControl,, C_AUTO_RESPOND, %F_AUTO_RESPOND%
	Gui, Show, w400 h675, WarriorBot - Build %WARRIOR_BOT_BUILD%

	;; Gateway buttons
	Gui, Add, Button, x555 y10 w28 h28 gGateNorth, % "N"
	Gui, Add, Button, x584 y10 w28 h28 gGateEast, % "E"
	Gui, Add, Button, x555 y40 w28 h28 gGateSouth, % "S"
	Gui, Add, Button, x585 y40 w28 h28 gGateWest, % "W"
	GATEWAY := MEMORY_HANDLE.getSpellSlot("Gateway", True)	

	Gui, Show, w425 h750, PoetBot - %SELF_NAME%
	
	;; Read in Character Config (if it exists)
	characterName := MEMORY_HANDLE.getName()
	characterCfg := A_ScriptDir . "\configs\" . characterName . ".cfg"
			
	if FileExist(characterCfg) {
		openConfig(characterCfg)
	}



	;; Initialize Variables
	groupList := []
	otherClientsList := []
	omitNames  := [MEMORY_HANDLE.getName()]

	T_UPDATE_CLIENTS_LIST  := 10000
	LT_UPDATE_CLIENTS_LIST := 0
	loop_idx := 0

    ;; Main Script
    Loop {
		loop_idx++

        ;; display a tooltip
        MouseGetPos,,,, OutputVarControl ; Find out what button their mouse is hovering over
        If (OutputVarControl == "Button9") {
            Tooltip % "Uses alternate pointer to find spell lists, generally used for windows 10 users"
        } Else If (OutputVarControl == "Static20" or OutputVarControl == "Edit20")  {
            Tooltip % "Number of tiles away bot disheartens from target(1 = 4 surrounding tiles, 2 = diamond, etc)"
        } Else If (OutputVarControl == "Static21" or OutputVarControl == "Edit21")  {
            Tooltip % "Heal yourself when below this vita percentage"
        } Else If (OutputVarControl == "Static22" or OutputVarControl == "Edit22")  {
            Tooltip % "Heal group members when they are below this vita percentage"
        } Else If (OutputVarControl == "Static23" or OutputVarControl == "Edit23")  {
            Tooltip % "Stop poeting and focus on invoking when below this mana percentage"
        } Else If (OutputVarControl == "Static24" or OutputVarControl == "Edit24")  {
            Tooltip % "Use your invoke if its convenient when below this mana percentage"
        } Else If (OutputVarControl == "Static25" or OutputVarControl == "Edit25")  {
            Tooltip % "Don't Inspire if you would be left with less than this mana percentage, unless your invoke is off aethers"
        } Else If (OutputVarControl == "Static26" or OutputVarControl == "Edit26")  {
            Tooltip % "Only Inspire group members when they are missing this much mana"
        } Else If (OutputVarControl == "Static27" or OutputVarControl == "Edit27")  {
            Tooltip % "Dont Use restore if you have less than this mana percentage"
        } Else If (OutputVarControl == "Static28" or OutputVarControl == "Edit28")  {
            Tooltip % "Exit any scourge loops when you find yourself or a group member below this vita percentage"
        } Else {
            Tooltip
        }

        GuiControlGet, M_HEAL_ORB   ,,    C_HEAL_ORB
        GuiControlGet, M_RESTORE_ORB,,    C_RESTORE_ORB
        GuiControlGet, M_WINE       ,,    C_WINE
        GuiControlGet, M_HARDEN_BODY,,    C_HARDEN_BODY
        GuiControlGet, M_INVOKE     ,,    C_INVOKE
        GuiControlGet, M_HEAL       ,,    C_HEAL
        GuiControlGet, M_ARMOR      ,,    C_ARMOR
        GuiControlGet, M_SANCTUARY  ,,    C_SANCTUARY
        GuiControlGet, M_VALOR      ,,    C_VALOR
        GuiControlGet, M_SA_ASV     ,,    C_SA_ASV
        GuiControlGet, M_GROUP_ASV  ,,    C_GROUP_ASV
        GuiControlGet, M_RESTORE    ,,    C_RESTORE
        GuiControlGet, M_SCOURGE    ,,    C_SCOURGE
        GuiControlGet, M_DISHEARTEN ,,    C_DISHEARTEN
        GuiControlGet, M_INSPIRE    ,,    C_INSPIRE
        GuiControlGet, TAB          ,,    C_TAB
        GuiControlGet, VTAB         ,,    C_VTAB
        GuiControlGet, CVTAB        ,,    C_CVTAB
        GuiControlGet, RVTAB        ,,    C_RVTAB

        GuiControlGet, HEAL_SELF_VITA_RATIO            ,,   C_HEAL_SELF_VITA_RATIO
        GuiControlGet, HEAL_GROUP_VITA_RATIO           ,,   C_HEAL_GROUP_VITA_RATIO
        GuiControlGet, FORCE_INVOKE_MANA_RATIO         ,,   C_FORCE_INVOKE_MANA_RATIO
        GuiControlGet, TRY_INVOKE_MANA_RATIO           ,,   C_TRY_INVOKE_MANA_RATIO
        GuiControlGet, MIN_MANA_LEFT_SPIRE_RATIO       ,,   C_MIN_MANA_LEFT_SPIRE_RATIO
        GuiControlGet, MISSING_MANA_SPIRE_THRESHOLD    ,,   C_MISSING_MANA_SPIRE_THRESHOLD
        GuiControlGet, RESTORE_MIN_MANA_RATIO          ,,   C_RESTORE_MIN_MANA_RATIO
        GuiControlGet, EXIT_SCOURGE_VITA_RATIO         ,,   C_EXIT_SCOURGE_VITA_RATIO

        GuiControlGet, F_SELF_ASV,, C_SELF_ASV
		GuiControlGet, F_SELF_ASV_CAST_VALOR,, C_SELF_ASV_CAST_VALOR
		GuiControl, % (F_SELF_ASV)?"Enable":"Disable", C_SELF_ASV_CAST_VALOR
		GuiControl, % (F_SELF_ASV and F_SELF_ASV_CAST_VALOR)?"Enable":"Disable", C_VALOR

        GuiControlGet, F_USE_HARDEN_BODY,, C_USE_HARDEN_BODY
		GuiControl, % (F_USE_HARDEN_BODY)?"Enable":"Disable", C_HARDEN_BODY

        GuiControlGet, F_USE_RESTORE,, C_USE_RESTORE
		GuiControl, % (F_USE_RESTORE)?"Enable":"Disable", C_RESTORE
        GuiControl, % (F_USE_RESTORE)?"Enable":"Disable", C_RESTORE_MIN_MANA_RATIO

        GuiControlGet, F_SCOURGE_MOBS,, C_SCOURGE_MOBS
		GuiControl, % (!F_SCOURGE_MOBS and !F_TARGETED_SC)?"Disable":"Enable", C_SCOURGE
        GuiControl, % (!F_SCOURGE_MOBS and !F_TARGETED_SC)?"Disable":"Enable", C_EXIT_SCOURGE_VITA_RATIO

		GuiControlGet, F_AUTO_RESPOND,, C_AUTO_RESPOND
	
        ;; Update Inspire/TargetDH/TargetSC group list boxes if necessary
        newGroupList := MEMORY_HANDLE.OTHER_CLIENT.getGroupList(omitNames)
        updateGroupLists := Join("|", newGroupList*) != Join("|", groupList*)
        If (updateGroupLists) {
			groupListString := "|" . Join("|", newGroupList*)
            ;; Inspire List Updates
              ;; Parse out currently selected members
            GuiControlGet, SelectedMembers,, C_INSPIRE_LIST
            SelectedMembers := StrSplit(SelectedMembers, "|")
              ;; Update the list (selection resets to null)
            GuiControl,, C_INSPIRE_LIST, %groupListString%
              ;; Loop over members in group list, select if member in previous selection

            For idx, member in newGroupList {
                If (HasVal(SelectedMembers, member)) {
                    GuiControl, Choose, C_INSPIRE_LIST, %idx%
                }
            }

		    ;; Dishearten List Updates
              ;; Parse out currently selected members
            GuiControlGet, SelectedMembers,, C_DISHEARTEN_LIST
            SelectedMembers := StrSplit(SelectedMembers, "|")
              ;; Update the list (selection resets to null)
            GuiControl,, C_DISHEARTEN_LIST, %groupListString%
              ;; Loop over members in group list, select if member in previous selection
            For idx, member in newGroupList {
                If (HasVal(SelectedMembers, member)) {
                    GuiControl, Choose, C_DISHEARTEN_LIST, %idx%
                }
            }

			;; Heal List Updates
              ;; Parse out currently selected members
            GuiControlGet, SelectedMembers,, C_HEAL_GROUP_LIST
            SelectedMembers := StrSplit(SelectedMembers, "|")
              ;; Update the list (selection resets to null)
            GuiControl,, C_HEAL_GROUP_LIST, %groupListString%
              ;; Loop over members in group list, select if member in previous selection
            For idx, member in newGroupList {
                If (HasVal(SelectedMembers, member)) {
                    GuiControl, Choose, C_HEAL_GROUP_LIST, %idx%
                }
            }
			
			;; Follow List Updates
              ;; Parse out currently selected members
            GuiControlGet, SelectedMember,, C_FOLLOW_LIST
			
			;; Update the list (selection resets to null)
			GuiControl,, C_FOLLOW_LIST, %groupListString%
			GuiControl, ChooseString, C_FOLLOW_LIST, %SelectedMember%
			
			groupList := MEMORY_HANDLE.OTHER_CLIENT.getGroupList(omitNames)
        }


        GuiControlGet, F_USE_INSPIRE,, C_USE_INSPIRE
		GuiControl, % (F_USE_INSPIRE)?"Enable":"Disable", C_INSPIRE
        GuiControl, % (F_USE_INSPIRE)?"Enable":"Disable", C_INSPIRE_LIST
        GuiControl, % (F_USE_INSPIRE)?"Enable":"Disable", C_MISSING_MANA_SPIRE_THRESHOLD
        GuiControl, % (F_USE_INSPIRE)?"Enable":"Disable", C_MIN_MANA_LEFT_SPIRE_RATIO
        GuiControlGet, SelectedMembers,, C_INSPIRE_LIST
        GROUP_LIST_INSPIRE := StrSplit(SelectedMembers, "|")

        GuiControlGet, F_USE_DISHEARTEN,, C_USE_DISHEARTEN
        GuiControlGet, TARGETED_DH_DISTANCE,, C_TARGETED_DH_DISTANCE
		GuiControl, % (F_USE_DISHEARTEN)?"Enable":"Disable", C_DISHEARTEN
        GuiControl, % (F_USE_DISHEARTEN)?"Enable":"Disable", C_TARGETED_DH_DISTANCE
        GuiControl, % (F_USE_DISHEARTEN)?"Enable":"Disable", C_DISHEARTEN_LIST
        GuiControlGet, SelectedMembers,, C_DISHEARTEN_LIST
        GROUP_LIST_DISHEARTEN := StrSplit(SelectedMembers, "|")

        GuiControlGet, F_HEAL_GROUP,, C_HEAL_GROUP
		GuiControl, % (F_HEAL_GROUP)?"Enable":"Disable", C_HEAL_GROUP_LIST
        GuiControlGet, SelectedMembers,, C_HEAL_GROUP_LIST
        GROUP_LIST_HEAL := StrSplit(SelectedMembers, "|")
		
		GuiControlGet, F_FOLLOWING,, C_FOLLOW_LIST
		;; Grab other clients for Ungrouped feature
		clientList := MEMORY_HANDLE.getOtherClients()
		clientListString := "|" . Join("|", clientList*)
		  ;; Parse out currently selected members
		GuiControlGet, SelectedMember,, C_UNGROUPED_LIST
		  ;; Update the list (selection resets to null)
		GuiControl,, C_UNGROUPED_LIST, %clientListString%
		GuiControl, ChooseString, C_UNGROUPED_LIST, %SelectedMember%
		
        ;; Update Im_Special
        GuiControlGet, F_IM_SPECIAL,, C_IM_SPECIAL



		GuiControlGet, F_UNGROUPED,, C_UNGROUPED
        GuiControl, % (F_UNGROUPED)?"Enable":"Disable", C_UNGROUPED_LIST
        GuiControlGet, SelectedMember,, C_UNGROUPED_LIST
		If (F_UNGROUPED) {
			MEMORY_HANDLE.OTHER_CLIENT := MEMORY_HANDLE.getClientByName(SelectedMember) ;; returns this if no member is selected
		} Else {
			MEMORY_HANDLE.OTHER_CLIENT := MEMORY_HANDLE
		}


        If (M_HEAL_ORB != "u" and M_HEAL_ORB) {
			M_COMBO_HEAL := M_HEAL . M_HEAL_ORB
		} Else {
			M_COMBO_HEAL := M_HEAL
		}

        If (!POET_BOT_RUNNING) {
			Sleep MEMORY_HANDLE.LARGE_DELAY
			Continue
		}
		MEMORY_HANDLE.getGroupUIDs(omitNames)

		If (F_AUTO_RESPOND) {
			playerInfo := MEMORY_HANDLE.compilePlayerInfo()
			groupInfo := MEMORY_HANDLE.getGroupInfo()
			if (playerInfo) {
				for ndx, player in playerInfo {
					;; tab target players to get their name if they are invisible
					; if (player["isInvisible"]) {
						; targeted := MEMORY_HANDLE.tabTargetMob(player["index"])
						; if (targeted) {
							; MEMORY_HANDLE.sendKeyStroke(MEMORY_HANDLE.K_ENTER, MEMORY_HANDLE.LARGE_DELAY)
							; name := MEMORY_HANDLE.getQueriedName()
							; MsgBox % name
							; player["name"] := name
							
						; }
					; }
					;; skip invisible people where query failed
					if (!player["name"]) {
						continue
					}
					;; skip group members
					skipPlayer := false
					if (groupInfo.length() > 1) {
						for jdx, member in groupInfo {
							if (player["name"] == member["name"]) {
								skipPlayer := true
							}
						}
					}
					if (skipPlayer) {
						continue
					}
					
					playerInRecent:=False	
					for idx, recent in RECENTLY_RESPONDED_PLAYERS {
						if (recent["name"] == player["name"]) {
							playerInRecent:=True
							if (A_TickCount - recent["time"] > 360000) {
								RECENTLY_RESPONDED_PLAYERS[idx]["time"] := A_TickCount
								Random, response_type, 0, 1
								if (response_type) {
									Random, chat_idx, 1, RESPONSES_HEY.Length()
									CHAT_BUFFER := RESPONSES_HEY[chat_idx]
								} else {
									Random, chat_idx, 1, RESPONSES_HI.Length()
									CHAT_BUFFER := RESPONSES_HI[chat_idx]
								}
							}
						}
					}
					
					if (!playerInRecent) {
						RECENTLY_RESPONDED_PLAYERS.Push({"name":player["name"], "time":A_TickCount})
						Random, response_type, 0, 1
						if (response_type) {
							Random, chat_idx, 1, RESPONSES_HEY.Length()
							CHAT_BUFFER := RESPONSES_HEY[chat_idx]
						} else {
							Random, chat_idx, 1, RESPONSES_HI.Length()
							CHAT_BUFFER := RESPONSES_HI[chat_idx]
						}
					}
				}
			}
		}
		
		sendChat()
		
		;; Heal Group Members
		MEMORY_HANDLE.healGroup()

		;; Auto Harden Body Feature
		MEMORY_HANDLE.selfHardenBody()

		;; Auto Self-ASV Feature
		MEMORY_HANDLE.selfASV()
		
		;; Heal Group Members
		MEMORY_HANDLE.healGroup()

		;; Heal Self
		MEMORY_HANDLE.selfHeal()
		
		;; Invoke
		MEMORY_HANDLE.invoke()
		
		;; Heal Group Members
		MEMORY_HANDLE.healGroup()

		;; Auto Envelope Experience
		MEMORY_HANDLE.envelopeExp()
		
		;; Heal Group Members
		MEMORY_HANDLE.healGroup()

		;; inspire group members
		MEMORY_HANDLE.inspireGroup()

		;; Scourge
		MEMORY_HANDLE.massScourge()
		
		;; DH
		If (Mod(loop_idx, 3) == 1) {
			MEMORY_HANDLE.dhAroundTarget()
		}

		;; Heal Group Members
		MEMORY_HANDLE.healGroup()
	
    }

StartStop:
	POET_BOT_RUNNING := !POET_BOT_RUNNING
	GuiControl,, C_START_PAUSE, % POET_BOT_RUNNING?"Pause [F8]":"Start [F8]"
Return

F8::
	POET_BOT_RUNNING := !POET_BOT_RUNNING
	GuiControl,, C_START_PAUSE, % POET_BOT_RUNNING?"Pause [F8]":"Start [F8]"
Return

OpenConfig:
	openConfig()
Return

openConfig(config:="") {
	if (!config) {
		FileSelectFile, config, 1, %A_ScriptDir%\configs\%SELF_NAME%.cfg, Open PoetBot config, Config (*.cfg)
	}
	
	If (!config) {
		Return
	}


	;; Load in Configuration
	Loop, Read, %config%
	{
		If (!InStr(A_LoopReadLine, "=")) {
			Continue
		}

		key := StrSplit(A_LoopReadLine, "=")[1]
		val := StrSplit(A_LoopReadLine, "=")[2]
		If (key == "F_AutoloadMacros") {
			F_AUTOLOAD_MACROS := val
		}
        If (key == "Targeted_DH_Distance") {
			TARGETED_DH_DISTANCE := val
            GuiControl,, C_TARGETED_DH_DISTANCE, %val%
		}
        If (key == "Heal_Self_Vita_Ratio") {
			HEAL_SELF_VITA_RATIO := val
            GuiControl,, C_HEAL_SELF_VITA_RATIO, %val%
		}
        If (key == "Heal_Group_Vita_Ratio") {
			HEAL_GROUP_VITA_RATIO := val
            GuiControl,, C_HEAL_GROUP_VITA_RATIO, %val%
		}
        If (key == "Force_Invoke_Mana_Ratio") {
			FORCE_INVOKE_MANA_RATIO := val
            GuiControl,, C_FORCE_INVOKE_MANA_RATIO, %val%
		}
        If (key == "Try_Invoke_Mana_Ratio") {
			TRY_INVOKE_MANA_RATIO := val
            GuiControl,, C_TRY_INVOKE_MANA_RATIO, %val%
		}
        If (key == "Min_Mana_Left_Spire_Ratio") {
			MIN_MANA_LEFT_SPIRE_RATIO := val
            GuiControl,, C_MIN_MANA_LEFT_SPIRE_RATIO, %val%
		}
        If (key == "Missing_Mana_Spire_Threshold") {
			MISSING_MANA_SPIRE_THRESHOLD := val
            GuiControl,, C_MISSING_MANA_SPIRE_THRESHOLD, %val%
		}
        If (key == "Restore_Min_Mana_Ratio") {
			RESTORE_MIN_MANA_RATIO := val
            GuiControl,, C_RESTORE_MIN_MANA_RATIO, %val%
		}
        If (key == "Exit_Scourge_Vita_Ratio") {
			EXIT_SCOURGE_VITA_RATIO := val
            GuiControl,, C_EXIT_SCOURGE_VITA_RATIO, %val%
		}
        If (key == "F_Im_Special") {
			F_IM_SPECIAL := val
            GuiControl,, C_IM_SPECIAL, %val%
		}
		If (key == "F_SelfASV") {
			F_SELF_ASV := val
			GuiControl,, C_SELF_ASV, %val%
		}
		If (key == "F_SelfASVCastValor") {
			F_SELF_ASV_CAST_VALOR := val
			GuiControl,, C_SELF_ASV_CAST_VALOR, %val%
		}
		If (key == "F_UseHardenBody") {
			F_USE_HARDEN_BODY := val
			GuiControl,, C_USE_HARDEN_BODY, %val%
		}
		If (key == "F_Use_Restore") {
			F_USE_RESTORE := val
			GuiControl,, C_USE_RESTORE, %val%
		}
		If (key == "F_Scourge_Mobs") {
			F_SCOURGE_MOBS := val
			GuiControl,, C_SCOURGE_MOBS, %val%
		}
		If (key == "F_Use_Inspire") {
			F_USE_INSPIRE := val
			GuiControl,, C_USE_INSPIRE, %val%
		}
		If (key == "F_Use_Dishearten") {
			F_USE_DISHEARTEN := val
			GuiControl,, C_USE_DISHEARTEN, %val%
		}
		If (key == "F_Heal_Group") {
			F_HEAL_GROUP := val
			GuiControl,, C_HEAL_GROUP, %val%
		}
		If (key == "HealOrb") {
			M_HEAL_ORB := val
			GuiControl,, C_HEAL_ORB, %val%
		}
		If (key == "RestoreOrb") {
			M_RESTORE_ORB := val
			GuiControl,, C_RESTORE_ORB, %val%
		}
		If (key == "Wine") {
			M_WINE := val
			GuiControl,, C_WINE, %val%
		}
		If (key == "Armor") {
			M_ARMOR := val
			GuiControl,, C_ARMOR, %val%
		}
		If (key == "Sanctuary") {
			M_SANCTUARY := val
			GuiControl,, C_SANCTUARY, %val%
		}
		If (key == "Valor") {
			M_VALOR := val
			GuiControl,, C_VALOR, %val%
		}
		If (key == "HardenBody") {
			M_HARDEN_BODY := val
			GuiControl,, C_HARDEN_BODY, %val%
		}
		If (key == "Heal") {
			M_HEAL := val
			GuiControl,, C_HEAL, %val%
		}
		If (key == "SaASV") {
			M_SA_ASV := val
			GuiControl,, C_SA_ASV, %val%
		}
		If (key == "GroupASV") {
			M_GROUP_ASV := val
			GuiControl,, C_GROUP_ASV, %val%
		}
		If (key == "Invoke") {
			M_INVOKE := val
			GuiControl,, C_INVOKE, %val%
		}
		If (key == "Restore") {
			M_RESTORE := val
			GuiControl,, C_RESTORE, %val%
		}
		If (key == "Scourge") {
			M_SCOURGE := val
			GuiControl,, C_SCOURGE, %val%
		}
		If (key == "Dishearten") {
			M_DISHEARTEN := val
			GuiControl,, C_DISHEARTEN, %val%
		}
		If (key == "Inspire") {
			M_INSPIRE := val
			GuiControl,, C_INSPIRE, %val%
		}
	}
}

SaveConfig:
	FileSelectFile, outFile, S16, %A_ScriptDir%\configs\%SELF_NAME%.cfg, Save PoetBot Config, Config (*.cfg)
	If (outFile == "") {
		Return
	}

	cfgFile := FileOpen(outFile, "w")
	cfg =
	(
F_AutoloadMacros=%F_AUTOLOAD_MACROS%
F_SelfASV=%F_SELF_ASV%
F_SelfASVCastValor=%F_SELF_ASV_CAST_VALOR%
F_UseHardenBody=%F_USE_HARDEN_BODY%
F_Use_Restore=%F_USE_RESTORE%
F_Scourge_Mobs=%F_SCOURGE_MOBS%
F_Use_Inspire=%F_USE_INSPIRE%
F_Use_Dishearten=%F_USE_DISHEARTEN%
F_Heal_Group=%F_HEAL_GROUP%
F_Im_Special=%F_IM_SPECIAL%
Targeted_DH_Distance=%TARGETED_DH_DISTANCE%
Heal_Self_Vita_Ratio=%HEAL_SELF_VITA_RATIO%
Heal_Group_Vita_Ratio=%HEAL_GROUP_VITA_RATIO%
Force_Invoke_Mana_Ratio=%FORCE_INVOKE_MANA_RATIO%
Try_Invoke_Mana_Ratio=%TRY_INVOKE_MANA_RATIO%
Min_Mana_Left_Spire_Ratio=%MIN_MANA_LEFT_SPIRE_RATIO%
Missing_Mana_Spire_Threshold=%MISSING_MANA_SPIRE_THRESHOLD%
Restore_Min_Mana_Ratio=%RESTORE_MIN_MANA_RATIO%
Exit_Scourge_Vita_Ratio=%EXIT_SCOURGE_VITA_RATIO%
HealOrb=%M_HEAL_ORB%
RestoreOrb=%M_RESTORE_ORB%
Wine=%M_WINE%
Armor=%M_ARMOR%
Sanctuary=%M_SANCTUARY%
Valor=%M_VALOR%
HardenBody=%M_HARDEN_BODY%
Heal=%M_HEAL%
SaASV=%M_SA_ASV%
GroupASV=%M_GROUP_ASV%
Invoke=%M_INVOKE%
Restore=%M_RESTORE%
Scourge=%M_SCOURGE%
Dishearten=%M_DISHEARTEN%
Inspire=%M_INSPIRE%
	)

	cfgFile.Write(cfg)
	cfgFile.Close()

	MsgBox, Saved configuration
Return

Class PoetBot Extends NexusTK {
	;; Feature Parameters
	static T_HARDEN_BODY				:= 1500
	static LT_HARDEN_BODY				:= 0

	;; Ex:. Ohaeng Poet Spells (Adjust to Alignment)
	static N_ARMOR
	static N_SANCTUARY
	static N_VALOR
	static N_SA_ASV
	static N_GROUP_ASV
	static N_RESTORE
	static N_RESTORE_ORB
	static N_INSPIRE
	static N_INVOKE
	static N_SCOURGE
	static N_DISHEARTEN
	static N_HEAL
	static N_HARDEN_BODY

	;; Parameters

	static MIN_MANA						:= 30
	static RESTORE_MIN_MANA_RATIO	    := 0.25

	static PER_HEAL

	static OTHER_CLIENT
	static MARK

	__new(program) {
		base.__new(program)

		this.MARK := this.getMark()

		;; Configure Inventory
		If (!M_RESTORE_ORB) {
			M_RESTORE_ORB		:= "u" . this.getInventorySlot("Fragile Orb of Restore")
		}
		If (!M_HEAL_ORB) {
			M_HEAL_ORB	        := "u" . this.getInventorySlot("Fragile Orb of Ballad of Miin")
		}
		If (!M_WINE) {
			M_WINE				:= "u"
			wineTypes := []
			wineTypes.Push("Rice wine")
			wineTypes.Push("Memory Blossom")
			wineTypes.Push("Herb pipe")
			wineTypes.Push("Sonhi pipe")
			wineTypes.Push("Merchant pipe")
			For idx in range(wineTypes.Length()) {
				If (M_WINE == "u") {
					M_WINE		:= "u" . this.getInventorySlot(wineTypes[idx])
				} Else {
					Break
				}
			}
		}

		;; Configure Spell Names
		If (F_AUTOLOAD_MACROS) {
			macroList := this.getMacroList()
		} Else {
			macroList := ""
		}
		spellList := this.getSpellList()
		poetSpells := new PoetSpells(macroList, spellList, alignment:=this.getAlignment())

		this.N_ARMOR			:= poetSpells.N_ARMOR
		this.N_HARDEN_BODY		:= poetSpells.N_HARDEN_BODY
		this.N_HEAL				:= poetSpells.N_HEAL
		this.N_INVOKE			:= poetSpells.N_INVOKE
		this.N_SANCTUARY		:= poetSpells.N_SANCTUARY
		this.N_VALOR			:= poetSpells.N_VALOR
		this.N_SCOURGE			:= poetSpells.N_SCOURGE
		this.N_RESTORE			:= "Restore"
		this.N_RESTORE_ORB		:= "Fragile Orb of Restore"
		this.N_SA_ASV			:= poetSpells.N_SA_ASV
		this.N_GROUP_ASV		:= poetSpells.N_SA_GROUP_ASV
		this.N_INSPIRE			:= poetSpells.N_INSPIRE
		this.N_DISHEARTEN       := poetSpells.N_DH

		;; Auto load spell macros
		If (F_AUTO_LOAD_MACROS) {
			If (!M_ARMOR) {
				M_ARMOR := poetSpells.S_ARMOR
			}
			If (!M_HARDEN_BODY) {
				M_HARDEN_BODY := poetSpells.S_HARDEN_BODY
			}
			If (!M_HEAL) {
				M_HEAL := poetSpells.S_HEAL
			}
			If (!M_INVOKE) {
				M_INVOKE := poetSpells.S_INVOKE
			}
			If (!M_SANCTUARY) {
				M_SANCTUARY := poetSpells.S_SANCTUARY
			}
			If (!M_VALOR) {
				M_VALOR := poetSpells.S_VALOR
			}
			If (!M_SCOURGE) {
				M_SCOURGE := poetSpells.S_SCOURGE
			}
			If (!M_RESTORE) {
				M_RESTORE := poetSpells.S_RESTORE
			}
			If (!M_SA_ASV) {
				M_SA_ASV := poetSpells.S_SA_ASV
			}
			If (!M_SA_GROUP_ASV) {
				M_GROUP_ASV := poetSpells.S_SA_GROUP_ASV
			}
			If (!M_INSPIRE) {
				M_INSPIRE := poetSpells.S_INSPIRE
			}
			If (!M_DISHEARTEN) {
				M_DISHEARTEN := poetSpells.S_DH
			}
		}
	}

	selfHardenBody() {
		if (F_USE_HARDEN_BODY and (A_TickCount - this.LT_HARDEN_BODY > this.T_HARDEN_BODY)) {
			this.sendKeyStroke(this.K_ESC, this.SMALL_DELAY)

			if !(this.isSpellActive(this.N_HARDEN_BODY)) {
				this.sendSpellCast(M_HARDEN_BODY, 50)
				this.sendSpellCast(M_HARDEN_BODY, 50)
			}

			this.LT_HARDEN_BODY := A_TickCount
		}
	}
	
	follow(dist:=4) {
		if (F_FOLLOWING) {
			player := this.getPlayer(F_FOLLOWING) 
			if (player) {
				if (this.checkTileDistance(player["xCoord"], player["yCoord"], this.getXCoordinate(), this.getYCoordinate()) > dist) {
					this.sendKeyStroke(this.K_ESC, 50)
					this.GoProForce(player["xCoord"], player["yCoord"], 1, dist, true)
				}
			}
		}
	}
	
	getGroupUIDs(omitNames) {
		mobInfo := this.compileMobInfo2()
		GROUP_LIST := this.OTHER_CLIENT.getGroupList(omitNames)
		for idx, mob in mobInfo {
			if (mob["name"] != "") {
				groupIdx := HasVal(GROUP_LIST, mob["name"])
				if (groupIdx) {
					GROUP_LIST_UIDS[groupIdx] := mob["UID"]
				}
			}
		}
	}
	
	selfASV() {
		If (F_SELF_ASV) {
			If (!this.isASVed(F_SELF_ASV_CAST_VALOR)) {
				this.sendKeyStroke(this.K_ESC, this.SMALL_DELAY)
				this.sendKeyStroke(CVTAB, this.MEDIUM_DELAY)
				;; Sa san ASV Logic
				If (this.MARK == 4) {
					;; Use Group ASV if grouped
					groupSize := this.getGroupSize()
					If (groupSize and !this.isSpellActive(this.N_GROUP_ASV)) {
						this.sendSpellCast(M_GROUP_ASV)
					} Else {
						this.sendSpellCast(M_SA_ASV)
						this.asvGroup()
					}
				;; All the other plebs
				} Else {
					this.sendSpellCast(M_ARMOR)
					this.sendSpellCast(M_SANCTUARY)
					If (F_SELF_ASV_CAST_VALOR) {
						this.sendSpellCast(M_VALOR)
					}
					this.asvGroup()
				}

			this.sendKeyStroke(this.K_ESC, this.SMALL_DELAY)
			}
		}
	}

	selfHeal() {
		vita := this.getCurrentVita()
		maxVita := this.getMaxVita()
		mana := this.getCurrentMana()
		maxMana := this.getMaxMana()
		If (vita / maxVita < HEAL_SELF_VITA_RATIO) and (mana / maxMana > FORCE_INVOKE_MANA_RATIO) {
			this.sendKeyStroke(this.K_ESC, this.SMALL_DELAY)
			this.sendKeyStroke(CVTAB, this.SMALL_DELAY)
			Random, HEAL_AMOUNT, 3, 5
			Loop %HEAL_AMOUNT% {
				this.sendSpellCast(M_COMBO_HEAL)
			}
			this.sendKeyStroke(this.K_ESC, this.MEDIUM_DELAY)
		}
	}

	invoke() {
		mana := this.getCurrentMana()
		maxMana := this.getMaxMana()
		While ((mana / maxMana < TRY_INVOKE_MANA_RATIO and !this.isSpellActive(this.N_INVOKE)) or mana < FORCE_INVOKE_MANA_RATIO) {
			If (mana < this.MIN_MANA) {
				this.sendKeyStroke(M_WINE, this.MEDIUM_DELAY)
			}
			this.sendSpellCast(M_INVOKE)
			mana := this.getCurrentMana()
			Sleep, 250
		}
	}

	healGroup() {
		if (F_HEAL_GROUP) {
			mobInfo := this.compileMobInfo2()
			groupInfo := this.OTHER_CLIENT.getGroupInfo()
			selfName := this.getName()
			UseRestoreOrb := this.getInventorySlot("Fragile Orb of Restore") != ""
			For idx, member in groupInfo {
				if (HasVal(GROUP_LIST_HEAL, member["name"])) {
					; MsgBox % member["vita"] . " | " . member["maxVita"] . " | " . HEAL_GROUP_VITA_RATIO
					If (member["vita"] / member["maxVita"] < HEAL_GROUP_VITA_RATIO) {
						memberIdx := HasVal(GROUP_LIST, member["name"])
						targeted := this.targetPlayerByUID(GROUP_LIST_UIDS[memberIdx], mobInfo)
						if (!targeted) {
							continue
						}
						;; Restore Check
						mana := this.getCurrentMana()
						maxMana := this.getMaxMana()
						If (F_USE_RESTORE and this.shouldRestore(member["vita"], member["maxVita"], mana, maxMana)) {
							If (UseRestoreOrb) {
								If (!this.isSpellActive(this.N_RESTORE_ORB)) {
									this.sendSpellCast(M_RESTORE_ORB)
								}
							} Else {
								If (!this.isSpellActive(this.N_RESTORE)) {
									this.sendSpellCast(M_RESTORE)
								}
							}
						}
						
						;;; Inspire Check
						;If (F_USE_INSPIRE) {
						;	If HasVal(GROUP_LIST_INSPIRE, member["name"]) {
						;		mana := this.getCurrentMana()
						;		memberManaRatio := member["mana"] / member["maxMana"]
						;		memberMissingMana := member["maxMana"] - member["mana"]
						;		If (memberMissingMana >= MISSING_MANA_SPIRE_THRESHOLD) {
						;			manaRatioLeftAfterSpire := (mana - memberMissingMana) / maxMana
						;			;MsgBox % "mana = " . mana . "`nmemberManaRatio = " . memberManaRatio . "`nmemberMissingMana = " . memberMissingMana . "`nmanaRatioLeftAfterSpire = " . manaRatioLeftAfterSpire . "`nthis.MIN_MANA_SPIRE_RATIO = " . this.MIN_MANA_SPIRE_RATIO
						;			If (manaRatioLeftAfterSpire >= MIN_MANA_LEFT_SPIRE_RATIO) {
						;				this.sendSpellCast(M_INSPIRE)
						;			} Else If (!this.isSpellActive(this.N_INVOKE)) {
						;				this.sendSpellCast(M_INSPIRE)
						;				this.invoke()
						;			}
						;		}
						;	}
						;}
						
						
						;; Heal
						groupInfo := this.OTHER_CLIENT.getGroupInfo
						targetedMember := groupInfo[idx]
						If (targetedMember["vita"] / targetedMember["maxVita"] < HEAL_GROUP_VITA_RATIO) {
							Random, HEAL_AMOUNT, 3, 5
							Loop %HEAL_AMOUNT% {
								this.sendKeyStroke(M_COMBO_HEAL, this.SMALL_DELAY)
							}
						}
						
						this.sendKeyStroke(this.K_ESC, this.SMALL_DELAY)
					}
				}
			}
		}
		this.follow()
	}
	
	targetPlayerByUID(UID, mobInfo) {
		; MsgBox % UID
		if (!UID) {
			return False
		}
		targetIndex := this.getMobIndexByUID(UID, mobInfo)
		If (targetIndex) {
			;; Target User
			this.sendKeyStroke(this.K_ESC, this.SMALL_DELAY)
			this.sendKeyStroke(CVTAB, this.SMALL_DELAY)
			Loop 30 {
				If (!this.isMobTargeted(targetIndex)) {
					this.sendKeyStroke(VTAB, this.SMALL_DELAY)
				} Else {
					return True
				}
			}
		}
		return False
	}
	
	inspireGroup() {
		If (F_USE_INSPIRE) {
			groupInfo := this.OTHER_CLIENT.getGroupInfo()
			mobInfo := this.compileMobInfo2()
			maxMana := this.getMaxMana()
			selfName := this.getName()
			For idx, member in groupInfo {
				if (member["name"] != selfName) {
					if (HasVal(GROUP_LIST_INSPIRE, member["name"])) {
						memberMissingMana := member["maxMana"] - member["mana"]
						if (memberMissingMana > MISSING_MANA_SPIRE_THRESHOLD) {
							mana := this.getCurrentMana()
							manaRatioLeftAfterSpire := (mana - memberMissingMana) / maxMana
							if (manaRatioLeftAfterSpire >= MIN_MANA_LEFT_SPIRE_RATIO) {
								memberIdx := HasVal(GROUP_LIST, member["name"])
								targeted := this.targetPlayerByUID(GROUP_LIST_UIDS[memberIdx], mobInfo)
								if (!targeted) {
									continue
								}
								this.sendSpellCast(M_INSPIRE)
							} Else If (!this.isSpellActive(this.N_INVOKE)) {
								memberIdx := HasVal(GROUP_LIST, member["name"])
								targeted := this.targetPlayerByUID(GROUP_LIST_UIDS[memberIdx], mobInfo)
								if (!targeted) {
									continue
								}
								this.sendSpellCast(M_INSPIRE)
								this.invoke()
							}
						}
					}
				}
			}
		}
	}

	asvGroup() {
		mobInfo := this.compileMobInfo2()
		groupInfo := this.OTHER_CLIENT.getGroupInfo()
		selfName := this.getName()
		For idx, member in groupInfo {
			If !(member["name"] == selfName) {
				targetIndex := this.getMobIndex(member["name"], mobInfo)
				If (targetIndex) {
					;; Target User
					this.sendKeyStroke(this.K_ESC, this.SMALL_DELAY)
					this.sendKeyStroke(CVTAB, this.SMALL_DELAY)
					Loop 20 {
						If (!this.isMobTargeted(targetIndex)) {
							this.sendKeyStroke(VTAB, this.SMALL_DELAY)
						} Else {
							If (this.MARK == 4) {
								this.sendSpellCast(M_SA_ASV)
							} Else {
								this.sendSpellCast(M_ARMOR)
								this.sendSpellCast(M_SANCTUARY)
								If (F_SELF_ASV_CAST_VALOR) {
									this.sendSpellCast(M_VALOR)
								}
							}
							this.sendKeyStroke(this.K_ESC, this.MEDIUM_DELAY)
							break
						}
					}
				}
			}
		}
	}

	shouldRestore(vita, maxVita, mana, maxMana) {
		If (this.MARK == 4) {
			If (this.getInventorySlot("Fragile Orb of Ballad of Miin") != "") {
				perHeal := 0.025 * maxMana + 200000
			} Else {
				perHeal := 100000
			}
		} Else {
			perHealArray := [5000, 10000, 20000, 50000]
			perHeal := perHealArray[this.MARK + 1] ;; fekin 1 indexed arrays huh bud
		}
		healAmount := maxVita - vita
		healCount := healAmount / perHeal

		;; Can we Regular Heal?
		If (healCount < 8) {
			Return False
		}

		;; Is it Overkill?
		restoreAmount := (mana * 1.5)
		If (restoreAmount > healAmount * 2) {
			Return False
		}

		;; Low Mana?
		If (mana / maxMana < RESTORE_MIN_MANA_RATIO) {
			Return False
		}

		Return True
	}

	massScourge() {
		If (F_SCOURGE_MOBS) {
			;; find group members coordinates
			mobInfo := this.compileMobInfo2()
			myX := this.getXCoordinate()
			myY := this.getYCoordinate()
			scourgeMobs := False
			; Reduce list of mob info to mobs that are on screen
			; Keep count of how many mobs are not scourged
			For idx in rangeincl(mobInfo.Length(), 1, -1) {
				mob := mobInfo[idx]
				If (mob["name"] != "" or HasVal(GROUP_LIST_UIDS, mob["UID"])) {
					mobInfo.Remove(idx)
					Continue
				} Else If (mob["activeSpells"]["scourged"]) {
					mobInfo.Remove(idx)
					Continue
				} Else If (mob["xCoord"] < myX - 7) {
					mobInfo.Remove(idx)
					Continue
				} Else If (mob["xCoord"]  > myX + 7) {
					mobInfo.Remove(idx)
					Continue
				} Else If (mob["yCoord"]  < myY - 7) {
					mobInfo.Remove(idx)
					Continue
				} Else If (mob["yCoord"] > myY + 7) {
					mobInfo.Remove(idx)
					Continue
				}
			}
			this.follow()
			If (mobInfo.Length()) {
				this.sendKeyStroke(this.K_ESC, this.SMALL_DELAY)

				idx := 0
				this.sendKeyStroke(VTAB, this.SMALL_DELAY)
				Loop 10 {
					idx += 1
					mob := this.getTargetedMob()
					If (mob) {
						If (!mob["activeSpells"]["scourged"]) {
							this.sendSpellCast(M_SCOURGE)
						}
					}

					this.sendKeyStroke(VTAB, this.SMALL_DELAY)
					If (this.healingNeeded()) {
						break
					}
				}
			}
		}
	}

	healingNeeded() {
		groupInfo := this.OTHER_CLIENT.getGroupInfo()
		mobInfo   := this.compileMobInfo2()
		selfName  := this.getName()
		vita      := this.getCurrentVita()
		maxVita   := this.getMaxVita()
		If (vita / maxVita < EXIT_SCOURGE_VITA_RATIO) {
			Return True
		}
		For idx, member in groupInfo {
			If (member["name"] != selfName) {
				If (member["vita"] / member["maxVita"] < EXIT_SCOURGE_VITA_RATIO) {
					targetIndex := this.getMobIndex(member["name"], mobInfo)
					If (targetIndex) {
						Return True
					}
				}
			}
		}
		Return False
	}



	dhAroundTarget() {
		If (F_USE_DISHEARTEN) {
			For idx, playerName in GROUP_LIST_DISHEARTEN {
				mobInfo := this.compileMobInfo2()
				playerX := ""
				playerY := ""
				;; find group members coordinates
				For idx, mob in mobInfo {
					If (mob["name"] == playerName) {
						playerX := mob["xCoord"]
						playerY := mob["yCoord"]
						break
					}
				}
				If (playerX) {
					this.sendKeyStroke(this.K_ESC, this.SMALL_DELAY)
					this.sendKeyStroke(VTAB, this.SMALL_DELAY)
					mobInfo := this.compileMobInfo2()
					idx := 0
					Loop 20 {
						idx += 1
						mob := this.getTargetedMob()
						If (mob) {
							x := mob["xCoord"]
							y := mob["yCoord"]
							dist := this.checkTileDistance(playerX, playerY, x, y)
							If (dist <= TARGETED_DH_DISTANCE)  {
								this.sendSpellCast(M_DISHEARTEN)
							}
						}
						this.sendKeyStroke(VTAB, this.SMALL_DELAY)
						If (this.healingNeeded()) {
							break
						}
					}
				}
			}
		}
	}
}

Collapse:
	F_COLLAPSED := !F_COLLAPSED
	If (F_COLLAPSED) {
		Gui, Show, w425 h750
	} Else {
		Gui, Show, w625 h750
	}

	Gui, Font, S16, Wingdings
	GuiControl,, C_COLLAPSED, % F_COLLAPSED?Chr(216):Chr(215)
Return

MoveLeft:
	MEMORY_HANDLE.sendKeyStroke(MEMORY_HANDLE.K_LEFT, 5)
Return


MoveRight:
	MEMORY_HANDLE.sendKeyStroke(MEMORY_HANDLE.K_RIGHT, 5)
Return


MoveUp:
	MEMORY_HANDLE.sendKeyStroke(MEMORY_HANDLE.K_UP, 5)
Return


MoveDown:
	MEMORY_HANDLE.sendKeyStroke(MEMORY_HANDLE.K_DOWN, 5)
Return

;; Responses
SayHi:
	Random, idx, 1, RESPONSES_HI.Length()
	CHAT_BUFFER := RESPONSES_HI[idx]
Return

SayHey:
	Random, idx, 1, RESPONSES_HEY.Length()
	CHAT_BUFFER := RESPONSES_HEY[idx]
Return

SayLaugh:
	SetKeyDelay, 50
	MEMORY_HANDLE.sendKeyStroke(MEMORY_HANDLE.K_ESC, 200)
	MEMORY_HANDLE.sendKeyStroke("{ShiftDown};{ShiftUp}", 200)
	MEMORY_HANDLE.sendKeyStroke("a", 200)
	SetKeyDelay, 10
Return

SayDance:
	SetKeyDelay, 50
	MEMORY_HANDLE.sendKeyStroke(MEMORY_HANDLE.K_ESC, 200)
	MEMORY_HANDLE.sendKeyStroke("{ShiftDown};{ShiftUp}", 200)
	MEMORY_HANDLE.sendKeyStroke("l", 200)
	SetKeyDelay, 10
Return

SendChat:
	Gui, Submit, NoHide
	CHAT_BUFFER := EditChat
	GuiControl,, EditChat, % ""
Return

sendChat() {
	if (CHAT_BUFFER) {
		MEMORY_HANDLE.sendKeyStroke(MEMORY_HANDLE.K_ESC, MEMORY_HANDLE.MEDIUM_DELAY)
		MEMORY_HANDLE.sendChat(CHAT_BUFFER)
		CHAT_BUFFER := ""
	}
}

GateNorth:
	SetKeyDelay, 50
	MEMORY_HANDLE.sendKeyStroke(MEMORY_HANDLE.K_ESC, 200)
	MEMORY_HANDLE.sendKeyStroke("{ShiftDown}z{ShiftUp}", 200)
	MEMORY_HANDLE.sendKeyStroke(GATEWAY, 200)
	MEMORY_HANDLE.sendKeyStroke("n", 200)
	MEMORY_HANDLE.sendKeyStroke(MEMORY_HANDLE.K_ENTER, 100)
	SetKeyDelay, 10
Return
GateSouth:
	SetKeyDelay, 50
	MEMORY_HANDLE.sendKeyStroke(MEMORY_HANDLE.K_ESC, 200)
	MEMORY_HANDLE.sendKeyStroke("{ShiftDown}z{ShiftUp}", 200)
	MEMORY_HANDLE.sendKeyStroke(GATEWAY, 200)
	MEMORY_HANDLE.sendKeyStroke("s", 200)
	MEMORY_HANDLE.sendKeyStroke(MEMORY_HANDLE.K_ENTER, 100)
	SetKeyDelay, 10
Return
GateEast:
	SetKeyDelay, 50
	MEMORY_HANDLE.sendKeyStroke(MEMORY_HANDLE.K_ESC, 200)
	MEMORY_HANDLE.sendKeyStroke("{ShiftDown}z{ShiftUp}", 200)
	MEMORY_HANDLE.sendKeyStroke(GATEWAY, 200)
	MEMORY_HANDLE.sendKeyStroke("e", 200)
	MEMORY_HANDLE.sendKeyStroke(MEMORY_HANDLE.K_ENTER, 100)
	SetKeyDelay, 10
Return
GateWest:
	SetKeyDelay, 50
	MEMORY_HANDLE.sendKeyStroke(MEMORY_HANDLE.K_ESC, 200)
	MEMORY_HANDLE.sendKeyStroke("{ShiftDown}z{ShiftUp}", 200)
	MEMORY_HANDLE.sendKeyStroke(GATEWAY, 200)
	MEMORY_HANDLE.sendKeyStroke("w", 200)
	MEMORY_HANDLE.sendKeyStroke(MEMORY_HANDLE.K_ENTER, 100)
	SetKeyDelay, 10
Return

GuiClose:
GuiEscape:
ExitApp