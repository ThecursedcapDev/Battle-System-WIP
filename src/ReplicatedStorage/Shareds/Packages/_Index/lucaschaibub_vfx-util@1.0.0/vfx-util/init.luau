--!strict
--@author: crusherfire
--@date: 12/30/24
--[[@description:
	Useful utility functions for VFX
]]
-----------------------------
-- VARIABLES --
-----------------------------
local Module = {}

-----------------------------
-- PUBLIC FUNCTIONS --
-----------------------------

-- Goes through <code>container</code>'s children and sets <code>.Enabled</code> to <code>enable</code>.
-- You can optionally include beams/trails and search through all descendants.
function Module.toggleAllEmitters(container: Instance, enable: boolean, includeBeams: boolean?, descendants: boolean?)
	local function handleChild(child: Instance)
		if child:IsA("ParticleEmitter") then
			child.Enabled = enable
		elseif includeBeams and (child:IsA("Beam") or child:IsA("Trail")) then
			(child :: any).Enabled = enable
		end
	end

	if descendants then
		for _, descendant in ipairs(container:GetDescendants()) do
			handleChild(descendant)
		end
	else
		for _, child in ipairs(container:GetChildren()) do
			handleChild(child)
		end
	end
end

-- Goes through the <code>container</code> and copies any child emitters into <code>target</code>.
-- <strong>copyAttachments</strong>: Optionally copy over any child attachments. If attachments are present and copied, then
-- <code>target</code> must be a BasePart! Otherwise, this function will error.
-- <strong>copyBeams</strong>: If true, will also automatically copy attachments. Attachment property references will be maintained.
-- Returns all copied child instances.
function Module.copyEmittersTo(
	container: Instance,
	target: Instance,
	copyAttachments: boolean?,
	copyBeams: boolean?
): { any }
	local result: { any } = {}
	local dontClone: { [Instance]: boolean } = {}
	for _, child in ipairs(container:GetChildren()) do
		if
			not (
				child:IsA("ParticleEmitter")
				or ((copyAttachments or copyBeams) and child:IsA("Attachment"))
				or (copyBeams and (child:IsA("Beam") or child:IsA("Trail")))
			)
		then
			continue
		end
		if dontClone[child] then
			continue
		end
		local clone = child:Clone() :: Instance

		if clone:IsA("Beam") or clone:IsA("Trail") then
			if clone.Attachment0 then
				local a0 = clone.Attachment0:Clone()
				dontClone[clone.Attachment0] = true
				a0.Parent = target;
				(clone :: any).Attachment0 = a0
				table.insert(result, a0)
			end
			if clone.Attachment1 then
				local a1 = clone.Attachment1:Clone()
				dontClone[clone.Attachment1] = true
				a1.Parent = target;
				(clone :: any).Attachment1 = a1
				table.insert(result, a1)
			end
		end

		clone.Parent = target
		table.insert(result, clone)
	end
	return result
end

-- Goes through the array and destroys the instances. Useful for cleaning up instances returned from <code>copyEmittersTo()</code>.
function Module.destroyVFX(instances: { any })
	for _, instance in ipairs(instances) do
		instance:Destroy()
	end
end

-- Emits the emitter according to <code>count</code> or <code>EmitCount</code> attribute or 1 by default.
function Module.emit(emitter: ParticleEmitter, count: number?)
	emitter:Emit(count or emitter:GetAttribute("EmitCount") or 1)
end

-- Goes through <code>container</code>'s children and emits particles from emitters based on their <code>EmitCount</code> attribute.
-- Also accounts for <code>EmitDelay</code> attribute (if it exists).
-- You can optionally search through all descendants.
function Module.emitAll(container: Instance, descendants: boolean?)
	local function handleChild(child: Instance)
		if child:IsA("ParticleEmitter") then
			local delay = child:GetAttribute("EmitDelay")
			local count = child:GetAttribute("EmitCount")
			if not count then
				warn(`emitter: {child} missing EmitCount attribute, defaulting to 1`)
				count = 1
			end
			if delay then
				task.delay(delay, function()
					child:Emit(count)
				end)
			else
				child:Emit(count)
			end
		end
	end

	if descendants then
		for _, descendant in ipairs(container:GetDescendants()) do
			handleChild(descendant)
		end
	else
		for _, child in ipairs(container:GetChildren()) do
			handleChild(child)
		end
	end
end

-----------------------------
-- MAIN --
-----------------------------
return Module
