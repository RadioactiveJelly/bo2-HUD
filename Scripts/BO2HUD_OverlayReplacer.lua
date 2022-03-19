-- Register the behaviour
behaviour("BO2HUD_OverlayReplacer")

function BO2HUD_OverlayReplacer:Start()
	self.dataContainer = self.gameObject.GetComponent(DataContainer)

	local overlayGO = GameObject.Find("Overlay Text").gameObject
	self.overlayText = overlayGO.GetComponentInChildren(Text)
	self.overlayText.color = Color(0,0,0,0)
	self.overlayText.supportRichText = false

	
	

	self.hasSpawned = false

	self.lifeTime = 1

	self.currentCharacterIndex = 1
	self.stringLength = 0

	local bString = self.script.mutator.GetConfigurationString("blueTeamName")
	local rString = self.script.mutator.GetConfigurationString("redTeamName")

	if bString == "" then
		self.blueTeamName = "<color=white>The</color> Eagles"
	else
		self.blueTeamName = bString
	end
	
	if rString == "" then
		self.redTeamName = "<color=white>The</color> Ravens"
	else
		self.redTeamName = rString
	end 

	self.script.AddValueMonitor("monitorOverlayText", "onOverlayTextChange")

	self.textToDisplay = ""
	self.displayText = ""

	self.blueTeamHexCode = self.dataContainer.GetString("blueTeamHex")
	self.redTeamHexCode = self.dataContainer.GetString("redTeamHex")
	
	self.blueTeamColor = self.dataContainer.GetColor("blueTeamColor")
	self.redTeamColor = self.dataContainer.GetColor("redTeamColor")

	self.blueTeamText = "<color=" .. self.blueTeamHexCode .. ">" .. self.blueTeamName .. "</color>"
	self.redTeamText = "<color=" .. self.redTeamHexCode .. ">" .. self.redTeamName .. "</color>"

	self.timer = 0
	self.jumbleTimer = 0

	self.trueDisplayText = ""
	self.jumbledText = ""
	self.inTag = false

	self.isValid = true

	self.transparentColor = Color(1,1,1,0)

	self.alpha = 1

	GameEvents.onActorSpawn.AddListener(self,"onActorSpawn")
	GameEvents.onCapturePointNeutralized.AddListener(self,"onCapturePointNeutralized")
end

function BO2HUD_OverlayReplacer:OnDisable()
	self.isValid = false
end

function BO2HUD_OverlayReplacer:Update()
	if self.displayText ~= self.textToDisplay then
		if self.jumbleTimer < 4 then
			self.jumbleTimer = self.jumbleTimer + (Time.deltaTime * 200)
			if(self.jumbleTimer >= 4) then
				self:JumbleText(self.currentCharacterIndex)
				self.displayText = self.jumbledText
				self.jumbleTimer = 0
			end
		end
		if self.timer < 8 then
			self.timer = self.timer + (Time.deltaTime * 200)
			if self.timer >= 8 then
				self.currentCharacterIndex = self.currentCharacterIndex + 1
				local c = self.textToDisplay:sub(self.currentCharacterIndex,self.currentCharacterIndex)
				if c == "<" then
					self.inTag = true
				elseif c == ">" then
					self.inTag = false
				end
				
				if not self.inTag then
					self.timer = 0
				else
					self.timer = 8 - Time.deltaTime
				end
			end
		end
	elseif self.displayText == self.textToDisplay then
		if self.lifeTime > 0 then
			self.lifeTime = self.lifeTime - Time.deltaTime
		else
			self.alpha = self.alpha - (Time.deltaTime)
			self.targets.canvasGroup.alpha = self.alpha
		end
		
		--[[if self.lifeTime <= 0 then
			self.displayText = ""
			self.textToDisplay = ""
		end]]--
	end
	self.targets.textObject.text = self.displayText

	--[[if Input.GetKeyDown(KeyCode.O) then
		Overlay.ShowMessage("This text is <color=blue>blue</color>", 5)
	end

	if Input.GetKeyDown(KeyCode.I) then
		Overlay.ShowMessage("<color=#FF0000>RAVEN</color> LOST A BATTALION!", 5)
	end

	if Input.GetKeyDown(KeyCode.U) then
		Overlay.ShowMessage("<color=#0000FF>EAGLE</color> LOST A BATTALION!", 5)
	end]]--

	
end

function BO2HUD_OverlayReplacer:monitorOverlayText()
	return self.overlayText.text
end

function BO2HUD_OverlayReplacer:onOverlayTextChange()
	self:UpdateText(self.overlayText.text)
end

function BO2HUD_OverlayReplacer:UpdateText(text)
	self.lifeTime = 3

	local formattedText = text

	if string.find(text, "<color=#0000FF>EAGLE</color>") then
		formattedText = string.gsub(text, "<color=#0000FF>EAGLE</color>", self.blueTeamText)
	elseif string.find(text, "<color=#FF0000>RAVEN</color>") then
		formattedText = string.gsub(text, "<color=#FF0000>RAVEN</color>", self.redTeamText)
	end

	formattedText = string.upper(formattedText)

	self.alpha = 1
	self.targets.canvasGroup.alpha = 1

	self.displayText = ""
	self.textToDisplay = formattedText
	self.stringLength = #formattedText
	self.currentCharacterIndex = 1
end

function BO2HUD_OverlayReplacer:JumbleText(idx)
	self.jumbledText = ""
	local trg = string.byte(" ")
	local tagStart = string.byte("<")
	local tagEnd = string.byte(">")

	local textTag = false
	for i = 1, #self.textToDisplay do
		local textByte = self.textToDisplay:byte(i)
		if textByte == tagStart then
			textTag = true
		end

		if i > idx and not textTag then
			if textByte ~= trg then
				local rand = Random.Range(1,9)
				rand = Mathf.Ceil(rand)
				self.jumbledText = self.jumbledText .. rand
			else
				self.jumbledText = self.jumbledText .. " "
			end
		else
			local c = self.textToDisplay:sub(i,i)
			self.jumbledText = self.jumbledText .. c
		end

		if textByte == tagEnd then
			textTag = false
		end
	end
end

function BO2HUD_OverlayReplacer:onCapturePointNeutralized(capturePoint, previousOwner)
	if self.isValid and self.hasSpawnedOnce or Player.actor.team == Team.Neutral then
		local capturePointText = capturePoint.name
		if previousOwner == Team.Red then
			Overlay.ShowMessage("<color=#0000FF>EAGLE</color> NEUTRALIZED " .. capturePointText)
		else
			Overlay.ShowMessage("<color=#FF0000>RAVEN</color> NEUTRALIZED " .. capturePointText)
		end
	end
end

function BO2HUD_OverlayReplacer:onActorSpawn(actor)
	if(actor == Player.actor) then
		self.hasSpawnedOnce = true
	end
end