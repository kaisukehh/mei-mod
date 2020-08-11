Log("qvector")
Log(package)

local VECTOR_ZERO = Vector(0,0)
local VECTOR_Q = Vector(0,0)
local function QVector(x,y)
	VECTOR_Q.X = x
	VECTOR_Q.Y = y
	return VECTOR_Q
end

return _G
