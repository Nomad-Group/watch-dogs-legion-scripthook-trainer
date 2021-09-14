local script = Script()

-- Math
function lerp(pos1, pos2, perc)
    return (1-perc)*pos1 + perc*pos2 -- Linear Interpolation
end

function linearInterpolate(vecA, vecB, perc)
	return {
		lerp(vecA[1], vecB[1], perc),
		lerp(vecA[2], vecB[2], perc),
		lerp(vecA[3], vecB[3], perc),
	}
end

-- Settings
local CinematicInfo = {
	active = false,
	updateButton = false,
	loop = false,
	boomerang = false,

	duration = 5,
	timeStart = 0,
	timeEnd = 0,
	step = 1,
	inBoomerang = false,

	numPositions = 2,
	positions = {},
	rotations = {}
}

local function CanStartCinema()
	for i = 1, CinematicInfo.numPositions, 1 do
		if not CinematicInfo.positions[i] then
			return false
		end
	end

	return true
end

local function ResetCinematic()
	ScriptHook.ResetCamera()
	CinematicInfo.step = 1
	CinematicInfo.inBoomerang = false
end

-- Main Logic
function script:UpdateCinematic(time, dt)
	if not CinematicInfo.active then
		return
	end

	if CinematicInfo.timeStart == 0 then
		-- Just started
		CinematicInfo.timeStart = time
		CinematicInfo.timeEnd = time + CinematicInfo.duration
		CinematicInfo.updateButton = true

		print("Cinematic Start", time, CinematicInfo.duration)
	end

	if time >= CinematicInfo.timeEnd then
		if CinematicInfo.boomerang and not CinematicInfo.inBoomerang then
			CinematicInfo.timeStart = 0
			CinematicInfo.inBoomerang = true
			CinematicInfo.step = 1
		elseif CinematicInfo.loop then
			CinematicInfo.timeStart = 0
			CinematicInfo.step = 1
			CinematicInfo.inBoomerang = not CinematicInfo.inBoomerang
		else
			CinematicInfo.active = false
			CinematicInfo.updateButton = true
			print("Cinematic End")
			
			ResetCinematic()
		end

		return
	end

	local timeElapsed = time - CinematicInfo.timeStart
	local timePerStep = CinematicInfo.duration / (CinematicInfo.numPositions - 1)
	if CinematicInfo.step < (CinematicInfo.numPositions - 1) and timeElapsed >= (CinematicInfo.step * timePerStep) then
		print("Cinematic Step++", CinematicInfo.step + 1)
		CinematicInfo.step = CinematicInfo.step + 1
	end

	local timeElapsedThisStep = timeElapsed - (CinematicInfo.step - 1) * timePerStep
	local perc = timeElapsedThisStep / timePerStep

	local stepA, stepB = CinematicInfo.step, CinematicInfo.step + 1
	if CinematicInfo.boomerang and CinematicInfo.inBoomerang then
		stepA = CinematicInfo.numPositions - CinematicInfo.step + 1
		stepB = CinematicInfo.numPositions - CinematicInfo.step
	end

	local pos = linearInterpolate(CinematicInfo.positions[stepA], CinematicInfo.positions[stepB], perc)
	local rot = linearInterpolate(CinematicInfo.rotations[stepA], CinematicInfo.rotations[stepB], perc)
	ScriptHook.SetCustomCamera(pos[1], pos[2], pos[3], rot[1], rot[2], rot[3])
end

-- Menu
local function SelectPosition(idx)
	local localPlyIdx = GetLocalPlayerEntityId()

	CinematicInfo.positions[idx] = {
		ScriptHook.GetCameraPosition()
	}

	CinematicInfo.rotations[idx] = {
		ScriptHook.GetCameraRotation()
	}

	return CinematicInfo.positions[idx], CinematicInfo.rotations[idx]
end

local function VectorToString(vec)
	return string.format("%.2f  %.2f  %.2f", vec[1], vec[2], vec[3])
end

function script:CinematicMenu()
	local menu = UI.SimpleMenu()
	menu:SetTitle("Cinematic")

	-- Helper
	local freecamIdx = menu:AddCheckbox("Freecam", "Enable/Disable Freecam", function()
		ScriptHook.SetLocalPlayerFreeCamera(not ScriptHook.HasLocalPlayerFreeCamera())
	end)
	
	-- Positions
	local MAX_POSITIONS = 3

	local numPositionsIdx
	local function UpdateButtons()
		for i = 1, MAX_POSITIONS, 1 do
			local isEnabled = (i - 1) < CinematicInfo.numPositions
			menu:SetEntryEnabled(numPositionsIdx - 1 + i * 2, isEnabled)

			if isEnabled then
				local pos, rot = CinematicInfo.positions[i], CinematicInfo.rotations[i]
				if not pos then
					menu:SetEntryText(numPositionsIdx + i * 2, "(Empty)")
				else
					menu:SetEntryText(numPositionsIdx + i * 2, "Position:   " .. VectorToString(pos) .. "\nRotation:   " .. VectorToString(rot))
				end
			else
				menu:SetEntryText(numPositionsIdx + i * 2, "(Disabled)")
			end
		end
	end
	
	numPositionsIdx = menu:AddList("Position Count", function(_,_,_,_, idx, val)
		CinematicInfo.numPositions = tonumber(val)
		UpdateButtons()		
	end)

	for v = 1, MAX_POSITIONS, 1 do
		if v > 1 then
			menu:AddListEntry(numPositionsIdx, tostring(v))
		end

		menu:AddButton("Position " .. tostring(v), "Saves current position", function()
			SelectPosition(v)
			UpdateButtons()
		end)

		menu:AddText("")
	end

	-- Duration
	local durationIdx = menu:AddList("Duration (seconds)", function(_,_,_,_, idx, val)
		CinematicInfo.duration = tonumber(val)
	end)

	for _,v in pairs({ 1, 2, 3, 5, 10, 15, 20, 25, 30, 60, 90, 120 }) do
		menu:AddListEntry(durationIdx, tostring(v))
	end

	-- Options
	menu:AddCheckbox("Loop", "Restart scene after finish", function(_,_,_, val)
		CinematicInfo.loop = val
	end)

	menu:AddCheckbox("Boomerang", "Rewind the scene after finish (Boomerang-effect)", function(_,_,_, val)
		CinematicInfo.boomerang = val

		if not val then
			CinematicInfo.inBoomerang = false
		end
	end)

	-- Start
	local startIdx = menu:AddButton("Start", function()
		if CinematicInfo.active then
			CinematicInfo.active = false
			CinematicInfo.updateButton = true
			CinematicInfo.inBoomerang = false
			ResetCinematic()

			return
		end

		CinematicInfo.active = true
		CinematicInfo.timeStart = 0
	end)

	menu:OnUpdate(function()
		menu:SetChecked(freecamIdx, ScriptHook.HasLocalPlayerFreeCamera())
		menu:SetEntryEnabled(startIdx, CanStartCinema())

		if CinematicInfo.updateButton then
			if CinematicInfo.active then
				menu:SetEntryText(startIdx, "Stop")
			else
				menu:SetEntryText(startIdx, "Start")
			end

			CinematicInfo.updateButton = false
		end
	end)

	UpdateButtons()
	return menu
end
