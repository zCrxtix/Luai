return function (source : string)
	local tokens, error_ = require(script.Lexer).new(source):generate_tokens()
	if tokens then
		require(script.Parser).new(tokens):parse()
	else
		warn(error_)
	end
end
