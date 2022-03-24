-- Register the behaviour
behaviour("BO2HUD_MedalDisplay")

function BO2HUD_MedalDisplay:Start()
	self.script.StartCoroutine(self:DelayedStart())

	self.killStreakMedals = self.targets.killStreakMedals
	self.killMedals = self.targets.killMedals
	self.rapidKillMedals = self.targets.rapidKillMedals
	
	self.medalName = self.targets.name
	self.medalSprite = self.targets.medalImage
	self.flash = self.targets.flash
	self.flashAlpha = 0
	
	self.timeBetweenMedals = 2.5
	self.timer = self.timeBetweenMedals

	self.timeBeforeFade = 1.25
	self.fadeTimer = 0

	self.canvasAlpha = 0
	self.targets.canvasGroup.alpha = 0
end

function BO2HUD_MedalDisplay:DelayedStart()
	return function()
		coroutine.yield(WaitForSeconds(0.1))
		local scoreSystemObj = self.gameObject.Find("Score System")
		if scoreSystemObj then
			local medalSystemObj = scoreSystemObj.transform.Find("Medal System")
			if medalSystemObj then
				self.medalSystem = medalSystemObj.gameObject.GetComponent(ScriptedBehaviour)
				self.medalSystem.self:DisableDefaultHUD()
			end
		end
	end
end

function BO2HUD_MedalDisplay:Update()

	self.timer = self.timer + Time.deltaTime
	self.fadeTimer = self.fadeTimer + Time.deltaTime

	if(self.medalSystem) then
		if #self.medalSystem.self.medalQueue > 0  and self.timer > self.timeBetweenMedals  then
			self:Flash()
			self:ShowMedal()
			self.targets.audioSource.Play()
			self.timer = 0
			self.fadeTimer = 0
		end

		if self.fadeTimer >= self.timeBeforeFade then
			self.canvasAlpha = self.canvasAlpha - Time.deltaTime
			self.targets.canvasGroup.alpha = self.canvasAlpha
		end
	end

	if(self.flashAlpha >= 0) then
		self.flash.color = Color(1,1,1,self.flashAlpha)
		self.flashAlpha = self.flashAlpha - Time.deltaTime
		if(self.flashAlpha < 0) then
			self.flashAlpha = 0
		end
	end
	
end

function BO2HUD_MedalDisplay:ShowMedal()

	local medal = self.medalSystem.self.medalQueue[1]

	if(medal.medalType == "KillStreak") then
		self.medalSprite.sprite = self.killStreakMedals.GetSprite(medal.medalName)
		self.medalName.text = medal.medalName
	elseif(medal.medalType == "Kill") then
		self.medalSprite.sprite = self.killMedals.GetSprite(medal.medalName)
		self.medalName.text = medal.medalName
	elseif(medal.medalType == "RapidKills") then
		self.medalSprite.sprite = self.rapidKillMedals.GetSprite(medal.medalName)
		self.medalName.text = self:GetRapidKillMedalName(medal.medalName)
	end

	if medal.bonusPoints > 0 and medal.multiplierBonus == 0 then
		self.targets.bonusText.text = "+" .. medal.bonusPoints .. " points"
	elseif medal.bonusPoints == 0 and medal.multiplierBonus > 0 then
		self.targets.bonusText.text = "Score Multiplier +" .. medal.multiplierBonus
	end

	self.medalSystem.self:RemoveTopMedal()

	self.medalSprite.color = Color(1,1,1,1)
end

function BO2HUD_MedalDisplay:Flash()
	self.flashAlpha = 1
	self.canvasAlpha = 1
	self.targets.canvasGroup.alpha = 1
end

function BO2HUD_MedalDisplay:GetRapidKillMedalName(medalName)

	local toReturn = ""

	if medalName == "DoubleChain" then
		toReturn = "Double Kill"
	elseif medalName == "TripleChain" then
		toReturn = "Triple Kill"
	elseif medalName == "QuadChain" then
		toReturn = "Fury Kill"
	elseif medalName == "PentaChain" then
		toReturn = "Frenzy Kill"
	elseif medalName == "HexaChain" then
		toReturn = "Super Kill"
	elseif medalName == "HeptaChain" then
		toReturn = "Mega Kill"
	elseif medalName == "OctaChain" then
		toReturn = "Ultra Kill"
	elseif medalName == "KillChain" then
		toReturn = "Kill Chain"
	end	

	return toReturn
end