return function (Source : string)
	local Tokens, Error = require(script.Lexer).new(Source):generate_tokens()
	if Tokens then
		require(script.Parser).new(tokens):parse()
	else
		warn(Error)
	end
end
