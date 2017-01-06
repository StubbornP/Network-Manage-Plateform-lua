package = {}
meta	= {}

function package.CompletionRoutine( completion )
	print("Here you get to the root completion ...")

	for k,v in pairs( completion )
	do
		if type( v ) == "number" or type( v ) == "string" then
			print( ""..k..": "..v)
		end
	end
end

return package
	
