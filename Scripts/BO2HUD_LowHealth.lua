-- Register the behaviour
behaviour("BO2HUD_LowHealth")

function BO2HUD_LowHealth:Start()
	-- Run when behaviour is created
	GameEvents.onActorSpawn.AddListener(self,"onActorSpawn")
	GameEvents.onActorDied.AddListener(self,"onActorDied")
	self.script.AddValueMonitor("monitorCurrentHealth","onHealthChanged")

	local enhancedHealthObj = self.gameObject.Find("EnhancedHealth")
	if enhancedHealthObj then
		self.enhancedHealth = enhancedHealthObj.GetComponent(ScriptedBehaviour)
	end

	self.isLowHealth = false

	self.maxHealth = 100
end

function BO2HUD_LowHealth:Update()
	-- Run every frame
	if(self.isLowHealth) then
		local ratio = Mathf.Abs(Mathf.Sin(Time.time * 2))
		local color = Color.Lerp(Color.red, Color.white, ratio)
		self.targets.leftBg.color = color
		self.targets.rightBg.color = color
		self.targets.teamIcon.color = color
		self.targets.healthNumber.color = color
	end
end

function BO2HUD_LowHealth:monitorCurrentHealth()
	return Player.actor.health
end

function BO2HUD_LowHealth:onHealthChanged()
	local scale = Player.actor.health/self.maxHealth
	if(scale <= 0.45) then
		self.isLowHealth = true
	else
		self.isLowHealth = false
		local color = Color.white
		self.targets.leftBg.color = color
		self.targets.rightBg.color = color
		self.targets.teamIcon.color = color
		self.targets.healthNumber.color = color
	end
end

function BO2HUD_LowHealth:onActorSpawn(actor)
	if self.enhancedHealth then
		self.maxHealth = self.enhancedHealth.self.maxHP
		self.isLowHealth = false
		local color = Color.white
		self.targets.leftBg.color = color
		self.targets.rightBg.color = color
		self.targets.teamIcon.color = color
		self.targets.healthNumber.color = color
	end
end

function BO2HUD_LowHealth:onActorDied(actor,source,isSilent)
	if actor.isPlayer then
		self.isLowHealth = false
	end
end