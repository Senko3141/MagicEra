local module = {
    instanceTypes = {
        ['boolean'] = 'BoolValue';
        ['string'] = 'StringValue';
        ['number'] = 'IntValue';
    };
    ToInstance = function(self, tbl, parent)
        for i,v in pairs(tbl) do
            local number = tonumber(v)
            if number then
                tbl[i] = number
            end
            if type(v) == 'table' then
                local currentFolder = Instance.new('Folder')
                currentFolder.Parent = parent
                currentFolder.Name = i
                self:ToInstance(v, currentFolder)
            else
                for i2,v2 in pairs(self.instanceTypes) do
                    if type(v) == i2 then
                        local currentValue = Instance.new(v2)
                        currentValue.Parent = parent
                        currentValue.Name = i
						currentValue.Value = v
                    end
                end
            end
        end
    end;

    ToTable = function(self, parent)
        local function currentFunction(newParent)
            local returnedData = {}
            for i,v in pairs(newParent:GetChildren()) do
                if v:IsA('Folder') then
                    returnedData[v.Name] = currentFunction(v)
                else
                    returnedData[v.Name] = v.Value
                end
            end
            return returnedData
        end
        local constructedTable = currentFunction(parent)
        return constructedTable
	end;
	DeepCopyTable = function(self, t)
		local copy = {}
		for key, value in pairs(t) do
			if type(value) == "table" then
				copy[key] = self:DeepCopyTable(value)
			else
				copy[key] = value
			end
		end
		return copy
	end,
	AddToTable = function(self, toAdd, targetTable)
		if type(toAdd) ~= "table" then return targetTable end
		if type(targetTable) ~= "table" then return targetTable end
		-- Adding Objects
		for name, value in pairs(toAdd) do
			if type(value) == "table" then
				targetTable[name] = self:AddToTable(value)
			else
				targetTable[name] = value
			end
		end
		return targetTable
	end,
	reconcile = function(self, target, template)
		for k, v in pairs(template) do
			if type(k) == "string" then
				if target[k] == nil then
					if type(v) == "table" then
						target[k] = self:DeepCopyTable(v)
					else
						target[k] = v
					end
				elseif type(target[k]) == "table" and type(v) == "table" then
					self:reconcile(target[k], v)
				end
			end
		end

		return target
	end,
	Clone = function(self, t)
		return self:DeepCopyTable(t)
	end,
};

return module