local parser = {}

function parser:advance()
	if (self.pos == #self.tokens) then
		self.token = nil
		return
	end

	self.pos += 1
	self.token = self.tokens[self.pos]

	return self.token
end

function parser.new(tokens)
	assert(typeof(tokens) == "table", "Tokens must be a table")
	local self = setmetatable({}, {__index=parser})
	self.tokens = tokens
	self.pos = 0
	self.vars = {}
	self:advance()
	return self
end

function parser:parse_print()
	local result = {}
	self:advance()
	if self.token[1] == "LPAREN" then
		self:advance()
		while self.token ~= nil and self.token[1] ~= "RPAREN" do
			if self.token[1] == "NUMBER" or self.token[1] == "BOOLEAN" or self.token[1] == "STRING" then
				table.insert(result, self.token[2])
				self:advance()
			elseif self.token[1] == "IDENTIFIER" then
				if self.vars[self.token[2]] then
					table.insert(result, self.vars[self.token[2]][2])
				else
					print("Unknown identifier '"..self.token[2].."'")
					return
				end
				self:advance()
			else
				print("Error: expected NUMBER, STRING, or BOOLEAN, got "..self.token[1])
				return
			end
		end
	end
	return table.concat(result, "\n")
end

function parser:parse_var_declaration()
	self:advance()
	if self.token == nil or self.token[1] ~= "IDENTIFIER" then print("Error: expected IDENTIFIER after 'let'") return end
	local var_name = self.token[2]
	self:advance()
	if self.token[1] == "EQ" then
		self:advance()
		if self.token == nil then print("Error: expected NUMBER, STRING, or BOOLEAN after '='") return end
		if self.token[1] == "NUMBER" or self.token[1] == "BOOLEAN" or self.token[1] == "STRING" then
			self.vars[var_name] = self.token
		end
	else
		print("Error: expected '=' after "..var_name)
		return
	end
end

function parser:parse()
	while self.token ~= nil do
		if self.token[1] == "KEYWORD" then
			if self.token[2] == "println" then
				local res = self:parse_print()
				if res ~= nil then print(res) end
				self:advance()
			elseif self.token[2] == "let" then
				self:parse_var_declaration()
				self:advance()
			end
		else
			self:advance()
		end
	end
end

return parser
