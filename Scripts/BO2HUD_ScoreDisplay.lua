-- Register the behaviour
behaviour("BO2HUD_ScoreDisplay")

function BO2HUD_ScoreDisplay:Start()
	-- Run when behaviour is created
	self.script.StartCoroutine(self:DelayedStart())

	self.displayTotal = 0

	self.flashAlpha = 0

	self.timer = 0
	self.fadeTimer = 0

	self.timeBeforeFade = 3

	self.flashAlpha = 0

	self.canvasAlpha = 0
	self.targets.canvasGroup.alpha = 0

	self.flash = self.targets.flash

	self.targets.finalScore.text = ""

	GameEvents.onMatchEnd.AddListener(self,"MatchEnd")

	--Disable Ingame Kill Indicators though that can be done in the games' settings lol
	--GameObject.Find("Kill Indicator (1)").gameObject.SetActive(false)
	--GameObject.Find("Kill Indicator (2)").gameObject.SetActive(false)
	--GameObject.Find("Kill Indicator").gameObject.SetActive(false)
	--GameObject.Find("Kill Indicator Parent Panel").gameObject.SetActive(false)
end

function BO2HUD_ScoreDisplay:DelayedStart()
	return function()
		coroutine.yield(WaitForSeconds(0.1))
		local scoreSystemObj = self.gameObject.Find("Score System")
		if scoreSystemObj then
			self.scoreSystem = scoreSystemObj.GetComponent(ScriptedBehaviour)
			self.scoreSystem.self:DisableDefaultHUD()
		end
	end
end

function BO2HUD_ScoreDisplay:Update()
	self.timer = self.timer + Time.deltaTime
	self.fadeTimer = self.fadeTimer + Time.deltaTime

	if self.scoreSystem then
		if #self.scoreSystem.self.pointsHistory > 0 then
			local score = self.scoreSystem.self.pointsHistory[1]
			table.remove(self.scoreSystem.self.pointsHistory,1)
			self.displayTotal = self.displayTotal + score
			self.fadeTimer = 0
			self:Flash()
			self.targets.scoreText.text = "+" .. self.displayTotal
			if(self.scoreSystem.self.scoreMultiplier > 1) then
				self.targets.multiplierText.text = "Multiplier x" .. self.scoreSystem.self.scoreMultiplier
				self.flash.gameObject.SetActive(false)
				self.flash = self.targets.bigFlash
				self.flash.gameObject.SetActive(true)
			else
				self.targets.multiplierText.text = ""
				self.flash.gameObject.SetActive(false)
				self.flash = self.targets.flash
				self.flash.gameObject.SetActive(true)
			end
		end
		--self.targets.finalScore.text = "Score: " .. self.scoreSystem.self.totalPoints
	end

	if self.fadeTimer >= self.timeBeforeFade and self.displayTotal > 0 then
		self.displayTotal = 0
		self:Flash()
		self.targets.scoreText.text = ""
		self.targets.multiplierText.text = ""
	end

	if(self.flashAlpha >= 0) then
		self.flash.color = Color(1,1,1,self.flashAlpha)
		self.flashAlpha = self.flashAlpha - (Time.deltaTime * 2)
		if(self.flashAlpha < 0) then
			self.flashAlpha = 0
		end
	end

	
end

function BO2HUD_ScoreDisplay:Flash()
	self.flashAlpha = 1
	self.canvasAlpha = 1
	self.targets.canvasGroup.alpha = 1
end

function BO2HUD_ScoreDisplay:MatchEnd(team)
	self.targets.finalScore.text = "Final Score: " .. self.scoreSystem.self.totalPoints
end