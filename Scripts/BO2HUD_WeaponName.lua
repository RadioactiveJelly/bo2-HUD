-- Register the behaviour
behaviour("BO2HUD_WeaponName")

function BO2HUD_WeaponName:Start()
	GameEvents.onActorSpawn.AddListener(self,"onActorSpawn")

	self.displayText = ""
	self.textToDisplay = ""
	self.currentCharacterIndex = 1
	self.stringLength = 0

	self.timer = 0

	self.script.AddValueMonitor("monitorCurrentWeapon", "onChangeWeapon")
end

function BO2HUD_WeaponName:Update()
	-- Run every frame
	if self.displayText ~= self.textToDisplay then
		if self.timer < 7.5 then
			self.timer = self.timer + (Time.deltaTime * 200)
			if self.timer >= 7.5 then
				self.timer = 0
				local c = self.textToDisplay:sub(self.currentCharacterIndex, self.currentCharacterIndex)
				self.currentCharacterIndex = self.currentCharacterIndex + 1
				self.displayText = self.displayText .. c
			end
		end
	end
	self.targets.weaponName.text = self.displayText
end

function BO2HUD_WeaponName:CleanString(str, target, format)
	if string.find(str, target) then
		str = string.gsub(str, format, "")
	end
	return str
end

function BO2HUD_WeaponName:monitorCurrentWeapon()
	return Player.actor.activeWeapon
end

function BO2HUD_WeaponName:onChangeWeapon()
	if Player.actor.activeWeapon == nil then
		return
	end

	local name = ""
	if Player.actor.activeWeapon.weaponEntry then
		name = Player.actor.activeWeapon.weaponEntry.name
		name = self:CleanString(name,"EXTAS", "EXTAS%s+-%s")
		name = self:CleanString(name,"RWP2_", "RWP2_")
		name = self:CleanString(name," Suppressed", " Suppressed")
	else
		name = Player.actor.activeWeapon.gameObject.name
		name = self:CleanString(name,"(Clone)", "%(Clone%)")
	end

	self.displayText = ""
	self.textToDisplay = name
	self.stringLength = #name
	self.currentCharacterIndex = 1
end

function BO2HUD_WeaponName:onActorSpawn(actor)
	if actor.isPlayer then
		self.displayText = ""
		self.currentCharacterIndex = 1
	end
end