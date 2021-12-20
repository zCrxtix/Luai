local token_types = {
	NUMBER = "NUMBER",
	STRING = "STRING",
	BOOLEAN = "BOOLEAN",
	IDENTIFIER = "IDENTIFIER",
	KEYWORD = "KEYWORD",
	LPAREN = "LPAREN",
	RPAREN = "RPAREN",
	EQ = "EQ",
	OP = "OP"
}

local lexer = {}
lexer.__index = lexer

function lexer:advance()
	if (self.pos == string.len(self.text)) then
		self.char = nil
		return
	end

	self.pos += 1
	self.char = string.sub(self.text, self.pos, self.pos)
	
	return self.char
end

function lexer:make_identifier()
	local result = ""
	for _=1,string.len(self.text) do
		if string.match(self.char, "%a") or self.char == "_" then
			result ..= self.char
			self:advance()
		else
			self.pos -= 1
			break
		end
	end
	if result == "let" or result == "println" then
		return {token_types.KEYWORD, result}
	elseif result == "true" or result == "false" then
		return {token_types.BOOLEAN, result}
	else
		return {token_types.IDENTIFIER, result}
	end
end

function lexer:make_number()
	local result = ""
	while self.char ~= nil do
		if table.find({"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}, self.char) then
			result ..= self.char
			self:advance()
		else
			self.pos -= 1
			break
		end
	end
	return {token_types.NUMBER, tonumber(result)}
end

function lexer.new(source : string)
	local self = setmetatable({}, {__index=lexer})
	self.text = source
	self.pos = 0
	self:advance()
	return self
end

function lexer:generate_tokens()
	local tokens = {}
	while self.char ~= nil do
		if table.find({"", " ", "\n", "\t"}, self.char) then
			self:advance()
		elseif self.char == "(" then
			table.insert(tokens, {token_types.LPAREN, self.char})
			self:advance()
		elseif self.char == ")" then
			table.insert(tokens, {token_types.RPAREN, self.char})
			self:advance()
		elseif self.char == "=" then
			table.insert(tokens, {token_types.EQ, self.char})
			self:advance()
		elseif string.match(self.char, "%a") or self.char == "_" then
			table.insert(tokens, self:make_identifier())
			self:advance()
		elseif table.find({"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}, self.char) then
			table.insert(tokens, self:make_number())
			self:advance()
		elseif table.find({"+", "-", "*", "/"}, self.char) then
			table.insert(tokens, {token_types.OP, self.char})
			self:advance()
		else
			return nil, "Error: unknown character '"..self.char.."'"
		end
	end
	return tokens, nil
end

return lexer
