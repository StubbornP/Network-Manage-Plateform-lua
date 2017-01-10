package = {}
meta	= {}

function package.CompletionRoutine( completion )
	print("Here you get to the root completion ...")

	for k,v in pairs( completion )
	do
		if type( v ) == "number" or type( v ) == "string" then

			if k == "retCode" then
				print( ""..k..": ".. ZKError2String ( v ) )
			else
				print( ""..k..": "..v)
			end

		end
	end
end

return package
	
