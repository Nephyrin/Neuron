--Neuron Broker Plugin, a World of Warcraft® user interface addon.
--Copyright© 2006-2014 Connor H. Chenoweth, aka Maul - All rights reserved.

-- Original Broker Macaroon Comments retained --
-- Broker_Macaroon : A simple Data Broker minimap button replacement by Lightbright@Alexstrasza
-- based on ideas by Macaroon (Maul) and Broker_Recount (Elsia).
-- Most of this code comes from or is inspired by one or both of these addons and the credit
-- should go to them.

local NEURON, GDB = Neuron

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local ORB = CreateFrame("Button", "Neuron_Broker")

ORB:RegisterEvent("PLAYER_ENTERING_WORLD")

ORB.DataObj = LibStub:GetLibrary("LibDataBroker-1.1")

ORB.DataObj:NewDataObject("NeuronBroker", {

	type = "launcher",
	text = " "..L.NEURON,
	label = L.NEURON,
	icon = "Interface\\AddOns\\Neuron\\Images\\static_icon",
	OnClick = function(self, button, down)

		NEURON:MinimapButton_OnClick(NeuronMinimapButton, button)

	end,
	OnTooltipShow = function(tooltip)
		if not tooltip or not tooltip.AddLine then return end
		tooltip:SetText(L.NEURON)
		tooltip:AddLine(L.MINIMAP_TOOLTIP1, 1, 1, 1)
		tooltip:AddLine(L.MINIMAP_TOOLTIP2, 1, 1, 1)
		tooltip:AddLine(L.MINIMAP_TOOLTIP3, 1, 1, 1)
		tooltip:AddLine(L.MINIMAP_TOOLTIP4, 1, 1, 1)
	end,
})

local function updatePoint(self, elapsed)

	if (GDB.animate) then

		self.elapsed = self.elapsed + elapsed

		if (self.elapsed > 0.025) then

			self.l = self.l + 0.0625
			self.r = self.r + 0.0625

			if (self.r > 1) then
				self.l = 0
				self.r = 0.0625
				self.b = self.b + 0.0625
			end

			if (self.b > 1) then
				self.l = 0
				self.r = 0.0625
				self.b = 0.0625
			end

			self.t = self.b - (0.0625 * self.tadj)

			if (self.t < 0) then self.t = 0 end
			if (self.t > 1) then self.t = 1 end

			self.texture:SetTexCoord(self.l, self.r, self.t, self.b)

			self.elapsed = 0
		end
	end
end


local function createMiniOrb(parent, index, prefix)

	local point = CreateFrame("Frame", prefix..index, parent, "NeuronMiniOrbTemplate")

	point:SetScript("OnUpdate", updatePoint)
	point.tadj = 1
	point.elapsed = 0

	local row, col = random(0,15), random(0,15)

	point.l = 0.0625 * row; point.r = point.l + 0.0625
	point.t = 0.0625 * col; point.b = point.t + 0.0625

	point.texture:SetTexture("Interface\\AddOns\\Neuron\\Images\\seq_smoke")
	point.texture:SetTexCoord(point.l, point.r, point.t, point.b)

	return point
end


local function DelayedUpdate(self, elapsed)

	self.elapsed = self.elapsed + elapsed

	if (self.elapsed > 3) then

		--improved frame search by Phanx

		for key,value in pairs(_G) do
			local obj = _G[key]

			-- following line fix posted by corveroth on Wowinterface Neuron comments
			if (type(obj) == "table" and type(rawget(obj, 0)) == "userdata" and type(obj.GetName) == "function") and (type(obj.IsForbidden) == "function" and not obj:IsForbidden()) then

				local name = obj:GetName()

				if (name and name:find("NeuronBroker") and not ORB.foundicon) then
					if (name:find("Icon")) then
						ORB.anchorFrame = obj; ORB.foundicon = true
					end
				end
			end
		end

		--improved frame search by Phanx

		if (ORB.anchorFrame) then

			local frame

			if (ORB.foundicon) then
				frame = ORB.anchorFrame:GetParent()
			else
				frame = ORB.anchorFrame
			end

			local orb = createMiniOrb(frame, 1, "NeuronBrokerOrb")
			orb:SetPoint("LEFT", ORB.anchorFrame, "LEFT", 0, 0)
			orb:SetScale(1.5)
			orb:SetFrameStrata(frame:GetFrameStrata())
			orb:SetFrameLevel(frame:GetFrameLevel()+1)
			orb.texture:SetVertexColor(0,.54,.54)

			ORB.miniorb = orb

			NeuronMinimapButton:Hide()

			if (ORB.foundicon) then
				ORB.anchorFrame:SetAlpha(0)
			end
		end

		self:Hide()
	end
end

local LOGIN_Updater = CreateFrame("Frame", nil, UIParent)
	LOGIN_Updater:SetScript("OnUpdate", DelayedUpdate)
	LOGIN_Updater:Hide()
	LOGIN_Updater.elapsed = 0


ORB:SetScript("OnEvent", function(self, event, ...)

	if (not IsAddOnLoaded("Titan")) then

		LOGIN_Updater:Show()

		ORB.eventfired = true
	end

	GDB = NeuronGDB
end)
