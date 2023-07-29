-- Register the behaviour
behaviour("BO2HUD_FlagIndicator")

function BO2HUD_FlagIndicator:Start()
	-- Run when behaviour is created
	self.captureIndicator = nil
	self.dataContainer = self.gameObject.GetComponent(DataContainer)

	self.blueTeamColor = self.dataContainer.GetColor("blueTeamColor")
	self.redTeamColor = self.dataContainer.GetColor("redTeamColor")

	self.targets.indicatorObject.SetActive(false)

	--[[if Player.actor then
		self.script.AddValueMonitor("MonitorCapturePoint", "OnCapturePointChange")
	end]]--
	if GameManager.buildNumber > 26 then
		PlayerHud.HideUIElement(UIElement.FlagCaptureProgress)
	end
end

function BO2HUD_FlagIndicator:Update()
	-- Run every frame
	if Player.actor.currentCapturePoint then
		local capPoint = Player.actor.currentCapturePoint
		if GameManager.buildNumber <= 26 then
			if self.captureIndicator == nil then
				self.captureIndicator = GameObject.Find("Flag Capture Indicator")
				local bg = GameObject.Find("Flag Capture Indicator Edge")
				self.captureIndicator.transform.parent.position = Vector3(5000,5000,0)
				bg.transform.position = Vector3(5000,5000,0)
			end
		end
		
		self.targets.indicatorObject.SetActive(true)

		if capPoint.pendingOwner == Team.Blue then
			self.targets.fill.color = self.blueTeamColor
		else
			self.targets.fill.color = self.redTeamColor
		end

		if capPoint.owner == Team.Blue then
			local color = Color(self.blueTeamColor.r, self.blueTeamColor.g,self.blueTeamColor.b, 0.43)
			self.targets.flag.color = color
		elseif capPoint.owner == Team.Red then
			local color = Color(self.redTeamColor.r, self.redTeamColor.g,self.redTeamColor.b, 0.43)
			color.a = 0.43
			self.targets.flag.color = color
		else
			local color = Color.white
			color.a = 0.43
			self.targets.flag.color = color
		end

		self.targets.fill.fillAmount = capPoint.captureProgress
		self.targets.capPointName.text = capPoint.name
	else
		self.targets.indicatorObject.SetActive(false)
	end

	--[[if Input.GetKeyDown(KeyCode.U) then
		local objects = {}
		objects = GameObject.FindObjectsOfType(GameObject)
		for i = 1, #objects, 1 do
			if string.find(objects[i].name, "Capture") then
				print(objects[i].name)
			end
		end
	end]]--
end

function BO2HUD_FlagIndicator:MonitorCapturePoint()
	return Player.actor.currentCapturePoint
end

function BO2HUD_FlagIndicator:OnCapturePointChange()
	if Player.actor.currentCapturePoint then
		local capPoint = Player.actor.currentCapturePoint
		if self.captureIndicator == nil then
			self.captureIndicator = GameObject.Find("Flag Capture Indicator")
			local bg = GameObject.Find("Flag Capture Indicator Edge")
			self.captureIndicator.transform.parent.position = Vector3(5000,5000,0)
			bg.transform.position = Vector3(5000,5000,0)
		end
		
		self.targets.indicatorObject.SetActive(true)

		if capPoint.pendingOwner == Team.Blue then
			self.targets.fill.color = self.blueTeamColor
		else
			self.targets.fill.color = self.redTeamColor
		end

		if capPoint.owner == Team.Blue then
			local color = self.blueTeamColor
			color.a = 0.43
			self.targets.flag.color = color
		elseif capPoint.owner == Team.Red then
			local color = self.redTeamColor
			color.a = 0.43
			self.targets.flag.color = color
		else
			local color = Color.white
			color.a = 0.43
			self.targets.flag.color = color
		end

		self.targets.fill.fillAmount = capPoint.captureProgress
		self.targets.capPointName.text = capPoint.name
	else
		self.targets.indicatorObject.SetActive(false)
	end
end