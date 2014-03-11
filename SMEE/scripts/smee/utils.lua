utils = {}

function utils.val_to_str ( v )
	if "string" == type( v ) then
		v = string.gsub( v, "\n", "\\n" )
		if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
			return "'" .. v .. "'"
		end
		return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
	else
		return "table" == type( v ) and utils.tabletostring( v ) or tostring( v )
	end
end

function utils.key_to_str ( k )
	if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
		return k
	else
		return "[" .. utils.val_to_str( k ) .. "]"
	end
end

function utils.tabletostring( tbl )
	local result, done = {}, {}
	for k, v in ipairs( tbl ) do
		table.insert( result, utils.val_to_str( v ) )
		done[ k ] = true
	end
	for k, v in pairs( tbl ) do
		if not done[ k ] then
			table.insert( result, utils.key_to_str( k ) .. "=" .. utils.val_to_str( v ) )
		end
	end
	return "{" .. table.concat( result, "," ) .. "}"
end