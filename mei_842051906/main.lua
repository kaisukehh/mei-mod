--[[ current changes

Added support for bone hearts

]]

--[[ incomplete diplopia
	Guillotine
]]

--local TearFlags = TearFlags -- Fixes TearFlags related issues if Mei happens to load before a mod that overrides them

-- The above solution wasn't good enough at preventing the issue, so just copy the entire god damn tearflags table here
local TearFlags = {
    TEAR_NORMAL = 0,            -- Normal Tear
    TEAR_SPECTRAL = 1,          -- Ouija board type tear (goes thru obstacles)
    TEAR_PIERCING = 1 << 1,     -- Cupid's arrow type tear (goes thru enemy)
    TEAR_HOMING = 1 << 2,       -- Spoon bender type tear (homes to enemy)
    TEAR_SLOW = 1 << 3,         -- Spider bite type tear (slows on contact)
    TEAR_POISON = 1 << 4,       -- Common cold type tear (poisons on contact)
    TEAR_FREEZE = 1 << 5,       -- Mom's contact type tear (freezes on contact)
    TEAR_SPLIT = 1 << 6,        -- Parasite type tear (splits on collision)
    TEAR_GROW = 1 << 7,         -- Lump of coal type tear (grows by range)
    TEAR_BOMBERANG = 1 << 8,    -- My reflection type tear (returns back)
    TEAR_PERSISTENT = 1 << 9,   -- Polyphemus type tear (Damages the entity and if the damage is more then enemy hp it continues with less damage)
    TEAR_WIGGLE = 1 << 10,      -- Wiggle worm type tear (wiggles)
    TEAR_MIGAN = 1 << 11,   -- Migan type tear (creates fly on hit)
    TEAR_EXPLOSIVE = 1 << 12,   -- IPECAC type tear (explodes on hit)
    TEAR_CHARM = 1 << 13,       -- Mom's Eyeshadow tear
    TEAR_CONFUSION = 1 << 14,   -- Iron Bar tear
    TEAR_HP_DROP = 1 << 15, -- These tears cause enemy to drop hearts if killed (33% chance)
    TEAR_ORBIT = 1 << 16,       -- Used for Little Planet (orbit arounds the player)
    TEAR_WAIT = 1 << 17,        -- Anti gravity type tear (floats in place for some time before finally moving) (unset after first update)
    TEAR_QUADSPLIT = 1 << 18,   -- Splits into 4 smaller tears if it hits the ground
    TEAR_BOUNCE = 1 << 19,      -- Bounce off of enemies, walls, rocks (Higher priority than PERSISTENT & PIERCING)
    TEAR_FEAR = 1 << 20,        -- Mom's Perfume type tear of fear (fear on contact)
    TEAR_SHRINK = 1 << 21,      -- Proptosis tears start large and shrink
    TEAR_BURN = 1 << 22,        -- Fire Mind tears cause Burn effect on enemies
    TEAR_ATTRACTOR = 1 << 23,   -- Attracts enemies and pickups
    TEAR_KNOCKBACK = 1 << 24,   -- Tear impact pushes enemies back further
    TEAR_PULSE = 1 << 25,       -- Makes the tear pulse
    TEAR_SPIRAL = 1 << 26,      -- Makes the tear path spiral
    TEAR_FLAT = 1 << 27,        -- Makes the tear oval in the direction of travel
    TEAR_SAD_BOMB = 1 << 28,    -- Used by Bombs (Sad Bomb)
    TEAR_BUTT_BOMB = 1 << 29,   -- Used by Bombs (Butt Bomb)
    TEAR_GLITTER_BOMB = 1 << 30, -- Used by Bombs (Glitter Bomb)
    TEAR_SQUARE = 1 << 31,      -- Used for Hook Worm
    TEAR_GLOW = 1 << 32,    -- Used for GodHead (they will have a glow around them)
    TEAR_GISH = 1 << 33,    -- Used for Gish player tears (to color enemy black on slowing)
    TEAR_SCATTER_BOMB = 1 << 34, -- Used for Scatter bombs
    TEAR_STICKY = 1 << 35, -- Used for Sticky bombs and Explosivo tears
    TEAR_CONTINUUM = 1 << 36, -- Tears loop around the screen
    TEAR_LIGHT_FROM_HEAVEN = 1 << 37, -- Create damaging light beam on hit
    TEAR_COIN_DROP = 1 << 38, -- Used by Bumbo, spawns a coin when tear hits
    TEAR_BLACK_HP_DROP = 1 << 39, -- Enemy drops a black hp when dies
    TEAR_TRACTOR_BEAM = 1 << 40, -- Tear with this flag will follow parent player's beam
    TEAR_GODS_FLESH = 1 << 41, -- God's flesh flag to minimize enemies
    TEAR_GREED_COIN = 1 << 42, -- Greed coin tears that has a chance to generate a coin when hit
    TEAR_MYSTERIOUS_LIQUID_CREEP = 1 << 43, -- Greed coin tears that has a chance to generate a coin when hit
    TEAR_BIG_SPIRAL = 1 << 44, -- Ouroboros Worm, big radius oscilating tears
    TEAR_PERMANENT_CONFUSION = 1 << 45, -- Glaucoma tears, permanently confuses enemies
    TEAR_BOOGER = 1 << 46, -- Booger tears, stick and do damage over time
    TEAR_EGG = 1 << 47, -- Egg tears, leave creep and spawns spiders or flies
    TEAR_ACID = 1 << 48, -- Sulfuric Acid tears, can break grid entities
    TEAR_BONE = 1 << 49, -- Bone tears, splits in 2
    TEAR_BELIAL = 1 << 50, -- Belial tears, piecing tears gets double damage + homing
    TEAR_MIDAS = 1 << 51, -- Midas touch tears
    TEAR_NEEDLE = 1 << 52, -- Needle tears
    TEAR_JACOBS = 1 << 53, -- Jacobs ladder tears
    TEAR_HORN = 1 << 54, -- Little Horn tears
    TEAR_LASER = 1 << 55, -- Technology Zero
    TEAR_POP = 1 << 56, -- Pop!
    TEAR_ABSORB = 1 << 57, -- Lachryphagy
    TEAR_LASERSHOT = 1 << 58, -- Trisagion, generates a laser on top of the tear
    
    TEAR_LUDOVICO = 1 << 59 -- Used as a weapon for Ludovico Technique
}

local modRNG = RNG() -- The RNG to be used across the mod
local function random(min,max) -- Re-implements math.random() using the API's RNG class
	if min ~= nil and max ~= nil then -- Min and max passed, integer [min,max]
		return math.floor(modRNG:RandomFloat() * (max - min + 1) + min)
	elseif min ~= nil then -- Only min passed, integer [0,min]
		return math.floor(modRNG:RandomFloat() * (min + 1))
	end
	return modRNG:RandomFloat() -- float [0,1)
end

local SynergyProperties

local VECTOR_ZERO = Vector(0,0)
local VECTOR_Q = Vector(0,0)
local function QVector(x,y)
	VECTOR_Q.X = x
	VECTOR_Q.Y = y
	return VECTOR_Q
end

local function Distance(x1,y1,x2,y2)
	return math.sqrt((x2-x1)^2+(y2-y1)^2)
end

local function Sign(x)
	if x < 0 then
		return -1
	elseif x > 0 then
		return 1
	else
		return 0
	end
end

-- Some useful constants
local PI = math.pi
local HALF_PI = math.pi / 2
local TWO_PI = math.pi * 2
local DEGRAD = math.pi / 180
local RADDEG = 180 / math.pi
local COLOR_WHITE = Color(1,1,1,1,0,0,0)
local COLOR_MEI_WHITE = Color(0,0,0,0.5,249,236,255)

local DirectionVector = 
{
	UP = Vector(0,-1),
	LEFT = Vector(-1,0),
	DOWN = Vector(0,1),
	RIGHT = Vector(1,0)
}

local function IsHandled(entity)
	return entity:GetData().handled and true or false
end

-- Find the point on a general ellipse given an angle and rotation
local function PointOnEllipse(width,height,angle,rotation)
	local x = width * math.cos(angle) * math.cos(rotation) - height * math.sin(angle) * math.sin(rotation)
	local y = width * math.cos(angle) * math.sin(rotation) + height * math.sin(angle) * math.cos(rotation)
	return x,y
end

-- Wrap an angle between -PI and PI
local function WrapAngle(angle)
	if angle > 0 then
		angle = angle % TWO_PI
	else
		angle = -(math.abs(angle)%TWO_PI)
	end
	if angle > PI then
		angle = angle - TWO_PI
	elseif angle < -PI then
		angle = angle + TWO_PI
	end
	return angle
end

-- Wrap an angle between -PI and PI
local function WrapAngleDegrees(angle)
	if angle > 0 then
		angle = angle % 360
	else
		angle = -(math.abs(angle) % 360)
	end
	if angle > 180 then
		angle = angle - 360
	elseif angle < -180 then
		angle = angle + 360
	end
	return angle
end

-- Given a target angle, return the signed minimum distance to cover to reach it from the current angle
local function UnwrapAngle(targetAngle,currentAngle)
	return math.atan(math.sin(targetAngle - currentAngle), math.cos(targetAngle - currentAngle))
end

local function FindClosestEntity(entity,entities,maximumDistance)
	local closestDistance = 999999999
	local closestEntity = nil
	maximumDistance = maximumDistance or 9999999
	for i,testEntity in ipairs(entities) do
		local distance = (entity.Position-testEntity.Position):Length()
		if distance <= maximumDistance and distance < closestDistance then
			closestDistance = distance
			closestEntity = testEntity
		end
	end
	return closestEntity
end

local function ArcCallback(baseAngle,arc,amount,fill,halfOffset,callback)
	if amount == 1 then
		callback(baseAngle,1)
	elseif amount > 1 then
		local angleInterval = 0
		if halfOffset == true then
			baseAngle = baseAngle - arc / 2
		end
		if fill then
			angleInterval = arc / (amount-1)
		else
			angleInterval = arc / amount
		end
		for i=1,amount,1 do
			callback(baseAngle + angleInterval * (i-1),i)
		end
	end
end

local function RoundToNearestMultiple(number, multiple)
	return math.floor(((number + multiple/2) / multiple)) * multiple
end

local ringWormStrength = 24
local function GetRingWormOffset(velocity,frame)
	local f = frame
	return velocity + QVector(math.cos(f)*ringWormStrength,math.sin(f)*ringWormStrength)
end

local function GetWiggleWormOffset(velocity,frame)
	return velocity:Rotated(math.cos(frame) * 15)
end

local function GetHookWormOffset(velocity,frame)
	local targetAngle = RoundToNearestMultiple(velocity:GetAngleDegrees(),90)
	return velocity:Rotated(targetAngle-velocity:GetAngleDegrees())
end

local function GetPulseWormOffset(scale,frame)
	return scale * (1 + (math.cos(frame)+1) * 0.25)
end

local function GetOuroborosWormOffset(velocity,frame)
	return velocity * ((math.cos(frame/4)+1.2)/2) ^ 2
end

local function GetTinyPlanetModifier(frame,seed)
	return (seed % 6400 / 6400) * 0.75 + 0.75
end

-- Calculate an angle between the given angle and the calculated angle
local function EaseAngle(x1,y1,x2,y2,angle,easing)
	local dx = x1 - x2
    local dy = y1 - y2
	local len = math.sqrt(dx * dx + dy * dy)
	if len ~= 0 then dx = dx / len else dx = 1 end
	if len ~= 0 then dy = dy / len else dy = 1 end
	local dirX = math.cos(angle)
    local dirY = math.sin(angle)
	dirX = dirX + (dx - dirX) * easing
	dirY = dirY + (dy - dirY) * easing
	return math.atan(dirY, dirX)
end

local function CompareEntity(a,b) -- Checks to make sure the Entity being referenced is the right Entity
	-- IF the type and index are the same, it SHOULD be the Entity we're looking for
	if a and b then
		return a.Type == b.Type and a.Index == b.Index
	end
	return false
end

local function FindEntity(entityLike,entityList)
	local entities = entityList or Isaac.GetRoomEntities()
	for i,entity in ipairs(entities) do -- For every entity in the room
		if CompareEntity(entityLike,entity) then -- If a comparison between the entityLike and our entity is true
			return entity -- Return the entity we found
		end
	end
end

local function HasParent(entity,parent) -- Loops through all Parent to check if an Entity is an ancestor to another Entity
	-- Make sure entity are defined entity and parent aren't the same and the entity is not its own parent
	while entity ~= nil and not CompareEntity(entity,parent) and not CompareEntity(entity,entity.Parent) do
		-- If the Entity has a Parent and it's the Parent we're looking for
		if entity.Parent ~= nil and CompareEntity(entity.Parent,parent) then
			return true
		end
		-- We didn't find the Parent, so check the Parent's Parent
		entity = entity.Parent
	end
	-- We never found the parent, so the Entity we're checking is not an ancestor
	return false
end

local function IsEntityHomingTarget(entity)
	return entity:IsVulnerableEnemy() and entity:IsActiveEnemy() and not entity:HasEntityFlags(EntityFlag.FLAG_CHARM) and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
end

local mod = RegisterMod("Mei",1) -- Register the mod
MeiMod = mod -- Expose the mod table globally

mod.ModCallbacks = {
	MC_CONVERT_HEARTS = 0,
	MC_MORPH_TEAR = 1,
	MC_GRUDGE_POINTS = 2,
	MC_TELEKINESIS_VALIDITY = 3,
	MC_GRUDGE_VALIDITY = 4,
	MC_REFRESH_TEAR_SPRITE = 5
}
local modCallbacks = {}
-- This function returns a key that can be used to remove the mod callback.
-- If nil was returned, the callback was not successfully added.
function mod:AddModCallback(callbackId,callback,...)
	if callbackId == nil then
		error("[Mei] Callback Id invalid")
	end
	if type(callback) == "function" then
		if modCallbacks[callbackId] == nil then
			modCallbacks[callbackId] = {}
		end
		table.insert(modCallbacks[callbackId],callback)
		local key = #modCallbacks[callbackId]-1
		Isaac.DebugString("[Mei]: Mod callback added for ID "..callbackId.." with key "..key)
		return key
	end
	return nil
end
-- This function takes the key that AddModCallback returned to remove the the mod callback
function mod:RemoveModCallback(callbackId,key)
	if modCallbacks[callbackId] ~= nil then
		Isaac.DebugString("[Mei]: Mod callback remove for ID "..callbackId.." with key "..key)
		modCallbacks[callbackId][key] = -1
	end
end
function mod:HasModCallback(callbackId)
    return modCallbacks[callbackId] ~= nil
end
local function HandleCallbacks(callbackId,callback,...)
	if modCallbacks[callbackId] ~= nil then
		for i,entry in ipairs(modCallbacks[callbackId]) do
			if entry ~= -1 then
				if callback ~= nil then
					callback(entry(...))
				else
					entry(...)
				end
			end
		end
	end
end
local function HandleMeiMods()
	if MeiMods then
		for k,meiMod in pairs(MeiMods) do
			Isaac.DebugString("[Mei]: Mei mod " .. k .. " found and loaded")
			meiMod(MeiMod)
		end
	end
end

local costume = Isaac.GetCostumeIdByPath("gfx/characters/meisheavyblackhair.anm2")
local playerType = Isaac.GetPlayerTypeByName("Mei")

-- Collectible tracking
local Synergies = {
	AnalogStick = false,
	AntiGravity = false,
	BlackCandle = false,
	BlackLotus = false,
	BloodClot = false,
	BlueCandle = false,
	Brimstone = false,
	ChemicalPeel = false,
	ChocolateMilk = false,
	Conjoined = false,
    Continuum = false,
	CrowHeart = false,
	CursedEye = false,
	CurseOfTheTower = false,
	DeadCat = false,
	DeadEye = false,
	DeadTooth = false,
	DeathsTouch = false,
	DoubleShot = false,
	DrFetus = false,
	EpicFetus = false,
	Epiphora = false,
	EvilEye = false,
	EyeOfBelial = false,
	GhostPepper = false,
	GodHead = false,
    Haemolacria = false,
	Guillotine = false,
	HookWorm = false,
	Ipecac = false,
	IsaacsHeart = false,
	LargeZit = false,
	LokisHorns = false,
	LudovicoTechnique = false,
	Marked = false,
	MawOfTheVoid = false,
	MomsEye = false,
	MomsKnife = false,
	MonstrosLung = false,
	MyReflection = false,
	OuroborosWorm = false,
	Pisces = false,
	QuadShot = false,
	RainbowWorm = false,
	RedCandle = false,
	RingWorm = false,
	RubberCement = false,
	SacredHeart = false,
	SacrificialDagger = false,
	SecondHand = false,
	StrangeAttractor = false,
	SulfuricAcid = false,
	Tech5 = false,
	Technology = false,
    Technology2 = false,
	TechnologyZero = false,
	TechX = false,
	TheHalo = false,
	TheWiz = false,
	TractorBeam = false,
	TripleShot = false,
	WiggleWorm = false
}

SynergyProperties = 
{
	AntiGravityProc = false, -- When true, tears should unhandle
	BookwormChance = 0.1, -- The percantage chance for a bonus tear when bookworm
	ChocolateMilkMaximumScale = 4, -- How much chocolate milk should scale at a maximum
	ChocolateMilkMinimumScale = 1/3, -- How much chocolate milk should scale at a minimum
	ChocolateMilkTimeLossRate = 5, -- How much chocolate milk time should decrease per frame while not firing
	CursedEyeTeleportChance = 0.25, -- The chance to be randomly teleported if hit while firing with cursed eye
	CurseOfTheTowerGrudgeAmount = 300, -- How much grudge time to add from a curse of the tower damage
	DeadEyeRate = 0.1, -- How quickly the dead eye intensity increases
	EpiphoraBonusMaximum = 5, -- The epiphora bonus maximum
	EpiphoraBonusPerFrame = 0.01, -- The epiphora bonus gained per frame while firing
	GhostPepperChance = 0.025, -- The chance for an orbital to fire a ghost pepper shot
	LargeZitChance = 0.025, -- The chance for an orbital to fire a zit shot
	LudovicoMovementDrag = 0.3,
	LudovicoMovementSpeedMultiplier = 0.75,
	LumpOfCoalScaleMaximum = 3,
	MarkedMovementDrag = 0.3,
	MarkedMovementSpeedMultiplier = 1.5,
	MawOfTheVoidActivateFrame = 0, -- The frame on which maw of the void will activate
	MawOfTheVoidChargeTime = 90, -- how many frames maw of the void takes to charge
	MawOfTheVoidIsActivate = false, -- True if maw of the void is active
	MawOfTheVoidIsReady = false, -- True if Mei has been firing long enough that maw of the void should activate when she stops
	MawOfTheVoidLength = 60, -- How many frames maw of the void's effect should last
	MawOfTheVoidParticleColor = Color(0,0,0,1,0,0,0), -- The frame on which maw of the void will activate
	MawOfTheVoidRadius = 32, -- The radius of the maw of the void rings spawned around Mei's orbitals
	MawOfTheVoidShouldActivate = false, -- If the conditions are right for maw of the void to activate or not
	MonstrosLungRingCount = 7, -- How many orbital rings Mei gains from Monstro's Lung
	PiscesMassMultiplier = 3, -- A multiplier against tear mass applied during morph tear with Pisces
	ProptosisMinimumDamageScale = 0.3,
	ProptosisMinimumTearScale = 0.1,
	Tech5Chance = 0.10, -- The chance for an orbital to fire a tech .5 laser
	Technology2LaserDamageMultiplier = 1/5, -- The damage multiplier for Technology 2 lasers (1/5 or 20% normally)
    TechXRadius = 24, -- The radius of TechX orbitals
	TechnologyZeroStaticChargeNeeded = 128, -- The amount of stored static charge needed to discharge
	TractorBeamMaximumDistanceBonus = 48, -- The orbital distance minimum with tractor beam
	TractorBeamMinimumDistanceBonus = -24, -- The orbital distance minimum with tractor beam
	TractorBeamOrbitSpeedMultiplier = 1.5, -- A multiplier on orbit speed with tractor beam
	TractorBeamTearSpeedMultiplier = 1.25 -- A multiplier on tear speed with tractori beam
}

local ModItems = {
	
}

local ModSynergies = {
	
}

local HOMING_DISTANCE_TRESHOLD = 320 -- The minimum distance to find homing targets
local HOMING_FRICTION = 0.80 -- An exponent against homing effectiveness based on distance. 0 is flawless homing
local HOMING_ROTATION_MINIMUM = 3 -- The minimum amount a tear will rotate towards its homing target
local HOMING_ROTATION_SPEED_EXPONENT = 1 -- The exponent against the tear speed used for homing effectiveness. 0 
local HOMING_STRENGTH = 3 -- The speed at which shots with a homing target will move towards that target
local INFREQUENT_UPDATE_RATE = 15 -- Used for Dead Eye updating
local INITIALIZATION_FRAMES = 30 -- How many frames after spawning the tear should be fully effective
local ORBIT_DISTANCE_BONUS_MAXIMUM = 128 -- A bonus to orbit distance based on idle time
local ORBIT_GROWTH_RATE = 1 -- How much the orbit distance grows per frame when Mei is idle
local ORBIT_HEIGHT = -23.50 -- The height orbiting tears will be set to
local ORBIT_SHRINK_RATE = 8 -- How much the orbit distance shrinks per frame when Mei moves
local ORBIT_SPEED_MAXIMUM = 32 -- The high possible orbit speed
local TEAR_MORPH_MAX_FIRE_DELAY_MULTIPLIER = 2 -- A multiplier against MaxFireDelay to calculate the interval in which tears should morph
local TEAR_MORPH_MAX_FIRE_DELAY_OFFSET = 10 -- An offset against MaxFireDelay to calculate the interval in which tears should morph
local TEAR_SCALE_MAXIMUM = 4 -- The tear scale limit
local TEAR_SPEED_MAXIMUM = 48 -- The highest possible tear speed
local FOCUS_DELAY = 10 -- How long it should take for Mei to begin her focus
local FOCUS_TIME = 90 -- How long it takes Mei to focus completely
local LUDOVICO_TEAR_SCALE_OFFSET = 0.9 -- How much a ludovico tear should have its base scale offset by
local ENEMY_PROJECTILE_CLARITY_THRESHOLD = 10
local PLAYER_PROJECTILES_DEPTH_OFFSET = -100

local game = Game() -- The game
local sfx = SFXManager()
local gameFrame -- The games frame count, updated at the start of each PostUpdate
local room -- Stores the current room
local player -- The player
local isAlive -- True if the player is alive
local roomEntities -- A list of all the entities in the room updated every post update (or when necessary)

local airstrikes
local handledEntities -- Stores which entities the mod has spawned
local unhandledTears -- Stores tears which were unhandled, but still need to be managed
local homingTargets -- A list of all valid homing targets
local grudgeTargets -- A list of all valid grudge targets
local orbitals -- A table for keeping track of Mei's orbitals

local monstrosLungRings -- Stores the orbital rings Mei gains from Monstro's Lung
local wizRings -- The orbital ring Mei gains with the wiz item

local defaultRing -- Mei's default orbital ring
local lokisHornRing1 -- The upwards orbital ring Mei gains with loki's horns
local lokisHornRing2 -- The downwards orbital ring Mei gains with loki's horns
local momsEyeRing -- The backwards orbital ring Mei gains with mom's eye and loki's horns
local ludoRing -- The ring that follow the ludo tear

local playerVelocityPosition -- The most recent player position + velocity

local aimDirection -- Stores the player's aim direction based on if they have analog stick or not
local aimOffsetPercentage -- The aim offset percentage from 0 to 1 for general values
local collectibleCount-- Keeping track of the collectible count to reapply Mei's costume
local costumeEquipped -- Track if the costume is equipped so it's only toggled at the appropriate time
local customTearIndex -- A linear counter for tears spawn through fire custom tear (for left eye synergies)
local deadEyeIntensity -- Applied to tears every frame
local deadToothAura -- The dead tooth aura entity
local enemyProjectileCount -- The amount of active enemy projectiles
local epiphoraBonus -- The current epiphora bonus
local extraUpdate -- True if one more evaluateitems call should be made
local fireDelay -- Isn't really used anymore
local firing -- True if the last action triggers shooting flag is set
local focusPercent -- How focused Mei is based on idle time
local globalEasing -- The easing value used throughout Mei's actions
local idleTime -- How long Mei has been standing still
local ignoreOrbitalOffset -- When true, ignores the orbital track offset when the player fire's. For Marked and Ludovico
local isaacsHeartEntity -- Isaac's heart entity if it exists
local isMei -- True if the player is actually the player type that represents Mei
local hasTelekinesis -- True if the player can use telekinesis
local canGrudge -- True if the player can utilize grudges
local lastIdleTime -- The last frame Mei wasn't shooting
local ludoTear -- Marked target entity
local markedTarget -- Marked target entity
local notShootingTime -- The length of time Mei has not been shooting
local orbitalPositionOffset -- The natural origin of the orbit
local orbitalPositionOffsetEasing -- The easing value used to get orbitalPositionOffset to targetOrbitalPositionOffset
local orbitAngle -- The base orbit angle
local orbitAngleOffset -- A rising offset for the orbit angle
local orbitDistanceBonus -- A bonus to orbit distance based on idle time
local reverseOrbitalVelocity  -- Rotate orbitals inversely if true
local shootingTime -- The length of time Mei has been shooting
local shouldBecomeIncorporeal -- If false, shots will always be active instead of only when firing
local shouldClearTears -- If true, unhandle all orbiting tears and make fresh ones
local shouldReverseDirection -- If, when the action trigger is false, Mei's orbital direction should reverse
local spawnSynergyTears -- Should the annoying tears that spawn and expire fire?
local targetOrbitalPositionOffset -- The target orbit origin, used for easing
local tearCanBeEye  -- Convenience value passed to FireTear calls
local tearCanEndStreak -- Convenience value passed to FireTear calls
local tearMassMultiplier -- A multiplier to apply against Mei's tears in morph tear
local tearSpeed -- The top speed at which Mei's tears can reach their destination
local autoAimTarget = nil -- The entity Mei will attempt to attack automatically (Eye of the Subconscious)

local grudges = {} -- A list of Grudge objects
-- A list of points where Grudge affects enemies. For multiple Grudge locations (Scissors, Guillotine, Red/Blue Candle)
local grudgePoints = {}
local grudgeTotal = 0 -- The current Grudge amount
local grudgeFlame = nil

local function GetGrudgeColor(alpha)
	if Synergies.CrowHeart then
		return Color(0.8,0.45,0.65,alpha,0,0,0)
	end
	if Synergies.RedCandle then
		return Color(1.0,0.1,0.1,alpha,0,0,0)
	end
	if Synergies.BlueCandle then
		return Color(0.2,0.7,1.0,alpha,0,0,0)
	end
	if Synergies.CursedEye then
		return Color(1.5,1.5,1.5,alpha,0,0,0)
	end
	if Synergies.BlackCandle then
		return Color(0.2,0.2,0.2,alpha,0,0,0)
	end
	return Color(0.6,0.2,0.5,alpha,0,0,0)
end

local function GetAlphaAdjustedColor(color,alpha)
	return Color(color.R,color.G,color.B,alpha,math.floor(color.RO or 0),math.floor(color.GO or 0),math.floor(color.BO or 0))
end

local function GetEnemyProjectileAlphaAdjustment()
	return math.max(math.min(1,1-(((enemyProjectileCount or 0)-10) / 10)),0.15)
end

local function GetPlayerDistanceAlphaAdjustment(playerPosition,entityPosition,entityScale)
	return math.max(0.05,math.min(1,((playerPosition - entityPosition):Length()-32)/256/entityScale))
end

local function InitializeRun()
	airstrikes = {}
	gameFrame = 0 -- The games frame count, updated at the start of each PostUpdate
	roomEntities = nil -- A list of all the entities in the room updated every post update (or when necessary)
	isAlive = true -- True if the player is alive
	room = nil -- Stores the current room
	isMei = false
	hasTelekinesis = false
	canGrudge = false
	enemyProjectileCount = 0
end

local function InitializeTelekinesis()
	handledEntities = {} -- Stores which entities the mod has spawned
	unhandledTears = {} -- Stores tears which were unhandled, but still need to be managed
	homingTargets = {} -- A list of all valid homing targets
	orbitals = {} -- A table for keeping track of Mei's orbitals
	monstrosLungRings = {} -- Stores the orbital rings Mei gains from Monstro's Lung

	wizRings = {} -- The orbital ring Mei gains with the wiz item

	defaultRing = nil -- Mei's default orbital ring
	lokisHornRing1 = nil -- The upwards orbital ring Mei gains with loki's horns
	lokisHornRing2 = nil -- The downwards orbital ring Mei gains with loki's horns
	momsEyeRing = nil -- The backwards orbital ring Mei gains with mom's eye and loki's horns
	ludoRing = nil -- The ring that orbits the ludo tear

	aimDirection = nil -- Stores the player's aim direction based on if they have analog stick or not
	aimOffsetPercentage = 0 -- The aim offset percentage from 0 to 1 for general values
	collectibleCount = 0 -- Keeping track of the collectible count to reapply Mei's costume
	costumeEquipped = false -- Track if the costume is equipped so it's only toggled at the appropriate time
	customTearIndex = 0
	deadEyeIntensity = 0 -- Applied to tears every frame
	deadToothAura = nil -- The dead tooth aura entity
	epiphoraBonus = 0 -- The current epiphora bonus
	extraUpdate = false -- True if one more evaluateitems call should be made
	fireDelay = -1 -- Isn't really used anymore
	firing = false -- True if the last action triggers shooting flag is set
	focusPercent = 0 -- How focused Mei is based on idle time
	globalEasing = 8 -- The easing value used throughout Mei's actions
	idleTime = 0 -- How long Mei has been standing still
	ignoreOrbitalOffset = false -- When true, ignores the orbital track offset when the player fire's. For Marked and Ludovico
	isaacsHeartEntity = nil -- Isaac's heart entity if it exists
	lastIdleTime = game:GetFrameCount() -- The last frame Mei wasn't shooting
	ludoTear = nil -- Marked target entity
	markedTarget = nil -- Marked target entity
	notShootingTime = 0 -- The length of time Mei has not been shooting
	orbitalPositionOffset = Vector(0,-8) -- The natural origin of the orbit
	orbitalPositionOffsetEasing = 2 -- The easing value used to get orbitalPositionOffset to targetOrbitalPositionOffset
	orbitAngle = 0 -- The base orbit angle
	orbitAngleOffset = 0 -- A rising offset for the orbit angle
	orbitDistanceBonus = 0 -- A bonus to orbit distance based on idle time
	playerVelocityPosition = nil
	reverseOrbitalVelocity = false -- Rotate orbitals inversely if true
	shootingTime = 0 -- The length of time Mei has been shooting
	shouldBecomeIncorporeal = true -- If false, shots will always be active instead of only when firing
	shouldClearTears = false -- If true, unhandle all orbiting tears and make fresh ones
	shouldReverseDirection = false -- If, when the action trigger is false, Mei's orbital direction should reverse
	spawnSynergyTears = false -- Should the annoying tears that spawn and expire fire?
	targetOrbitalPositionOffset = VECTOR_ZERO -- The target orbit origin, used for easing
	tearCanBeEye = false -- Convenience value passed to FireTear calls
	tearCanEndStreak = false -- Convenience value passed to FireTear calls
	tearMassMultiplier = 0.33
	tearSpeed = 0 -- The top speed at which Mei's tears can reach their destination
end

local function InitializeGrudge()
	-- A list of points where Grudge affects enemies. For multiple Grudge locations (Scissors, Guillotine, Red/Blue Candle)
	grudgePoints = {}
	grudges = {} -- A list of Grudge objects
	grudgeTargets = {} -- A list of all valid homing targets
	grudgeTotal = 0 -- The current Grudge amount
	grudgeFlame = nil
end

local function Handle(entity)
	entity:GetData().handled = true
end

local function Unhandle(entity)
	entity:GetData().handled = false
	if entity.Type == EntityType.ENTITY_TEAR then
		table.insert(unhandledTears,entity)
	end
end

local function RefreshTearColor(tear,incorporeal)
	local color = tear:GetData().baseColor or tear:GetColor() or COLOR_WHITE
	if incorporeal then
		tear:SetColor(GetAlphaAdjustedColor(color,0.4),1,1,true,true)
	else
		--tear:SetColor(color,-1,1,true,true)
	end
end

local function RefreshTearScale(tear,tearScale)
    local tearData = tear:GetData()
    local bonusScale = 0
    if tear.Variant ~= TearVariant.SCHYTHE then
    	if tearData.isKnifeTear then
    		tear:GetSprite().Scale = QVector(tear.Scale * 2, tear.Scale * 2)
        end
    end
	if tear.Variant == TearVariant.SCHYTHE and not tearData.isScytheTear then
		--tearScale = tearScale * 0.5
	end
	tearScale = tearScale ^ 0.8
	tear.Scale = math.max(tearData.baseScale * tearScale + bonusScale, 0.34) -- Actually set the tear's scale
end

local function RefreshTearSprite(tear,orbitIndex)
	local sprite = tear:GetSprite()
	local tearData = tear:GetData()
	local targetFileName = nil
	local targetAnimation = nil
	local targetSpritesheet = nil
	local updateSpritesheet = false
    local isCardTear = false
	local isCoinTear = false
	local isHeartTear = false
	local isHaloTear = false
	local isJoypadTear = false
	local isBombTear = false
	local isEyeTear = false
	local isCoalTear = false
	local isScytheTear = false
	local isMushroomTear = false
	local isMagnetTear = false
	local isFireTear = false
	local isDarkTear = false
	local isContinuumTear = false
	local isMysteriousLiquidTear = false
	local isOpenBelialTear = false
	local isClosedBelialTear = false
	local bloodVariant = tear.Variant == TearVariant.BLOOD or
	tear.Variant == TearVariant.CUPID_BLOOD or
	tear.Variant == TearVariant.NAIL_BLOOD or
	tear.Variant == TearVariant.PUPULA_BLOOD or
	tear.Variant == TearVariant.GODS_FLESH_BLOOD or
	tear.Variant == TearVariant.GLAUCOMA_BLOOD

	if tearData.isEpicFetusTear then
		local prefix = "RegularTear"
		if bloodVariant then
			targetFileName = "gfx/002.001_blood tear.anm2"
			prefix = "BloodTear"
		else
			targetFileName = "gfx/002.000_tear.anm2"
		end
		targetSpritesheet = "gfx/rockets_mei.png"
	elseif tearData.isKnifeTear then
		local prefix = "RegularTear"
		if bloodVariant then
			targetFileName = "gfx/002.001_blood tear.anm2"
			prefix = "BloodTear"
		else
			targetFileName = "gfx/002.000_tear.anm2"
		end
		if not Synergies.Guillotine then
			targetSpritesheet = "gfx/knife_tears_mei.png"
		else
			targetSpritesheet = "gfx/serrated_knife_tears_mei.png"
		end
	elseif tear.Variant == TearVariant.COIN or tearData.coin == true then
		targetFileName = "gfx/002.000_tear.anm2"
		targetSpritesheet = "gfx/coin_tears_mei.png"
		isCoinTear = true
    elseif tear.Variant == TearVariant.SCHYTHE then
        targetFileName = "gfx/scythe_mei.anm2"
        targetSpritesheet = "gfx/scythe_mei.png"
        targetAnimation = sprite:GetDefaultAnimation()
        isScytheTear = true
	elseif tear.Variant == TearVariant.LOST_CONTACT then
		targetSpritesheet = "gfx/contact_tears_mei.png"
		updateSpritesheet = true
	elseif tear.Variant == TearVariant.METALLIC then
		targetSpritesheet = "gfx/magnet_tears_mei.png"
		updateSpritesheet = true
		isMagnetTear = true
	elseif tear.Variant == TearVariant.FIRE_MIND then
		targetSpritesheet = "gfx/fire_tears_mei.png"
		updateSpritesheet = true
		tear:GetData().baseColor = GetGrudgeColor(1)
		isFireTear = true
	elseif tear.Variant == TearVariant.DARK_MATTER then
		targetSpritesheet = "gfx/dark_tears_mei.png"
		updateSpritesheet = true
		isDarkTear = true
	elseif tear.Variant == TearVariant.MYSTERIOUS then
		targetSpritesheet = "gfx/mysterious_liquid_tears_mei.png"
		updateSpritesheet = true
		isMysteriousLiquidTear = true
	elseif tear.Variant == TearVariant.PUPULA or tear.Variant == TearVariant.PUPULA_BLOOD then
		targetSpritesheet = "gfx/pupula_tears_mei.png"
		updateSpritesheet = true
	else
		if tear.Variant == TearVariant.CUPID_BLUE or
		tear.Variant == TearVariant.CUPID_BLOOD or
		tear.Variant == TearVariant.BLUE or
		tear.Variant == TearVariant.BLOOD then
			if bloodVariant then
				targetFileName = "gfx/002.001_blood tear.anm2"
			else
				targetFileName = "gfx/002.000_tear.anm2"
			end
			if Synergies.GodHead then
				targetSpritesheet = "gfx/eye_tears_mei.png"
				isEyeTear = true
			elseif tearData.isBelialTear then
				targetSpritesheet = "gfx/belial_tears_mei.png"
				updateSpritesheet = true
			elseif Synergies.SacredHeart then
				targetSpritesheet = "gfx/hearts_mei.png"
				isHeartTear = true
			elseif Synergies.BlackLotus then
				targetSpritesheet = "gfx/card_tears_mei.png"
				isCardTear = true
			elseif Synergies.FunGuy then
				targetSpritesheet = "gfx/mushroom_tears_mei.png"
				isMushroomTear = true
			elseif tear.TearFlags & TearFlags.TEAR_EXPLOSIVE ~= 0 then
				targetSpritesheet = "gfx/bomb_tears_mei.png"
				isBombTear = true
			elseif Synergies.TheHalo then
				targetSpritesheet = "gfx/halo_tears_mei.png"
				isHaloTear = true
			--[[elseif tear.TearFlags & TearFlags.TEAR_CONTINUUM ~= 0 then
				targetSpritesheet = "gfx/continuum_tears_mei.png"
				isContinuumTear = true]]
			elseif Synergies.AnalogStick then
				targetSpritesheet = "gfx/joypad_tears_mei.png"
				isJoypadTear = true
			elseif tear.TearFlags & TearFlags.TEAR_GROW ~= 0 or tearData.coal then
				targetSpritesheet = "gfx/coal_tears_mei.png"
				isCoalTear = true
			elseif tear.Variant == TearVariant.CUPID_BLUE or tear.Variant == TearVariant.CUPID_BLOOD then
				targetSpritesheet = "gfx/arrow_mei.png"
			else
				targetSpritesheet = "gfx/tears_round_mei.png"
			end
			updateSpritesheet = true
		end
	end
	local tearOverride = false
	HandleCallbacks(mod.ModCallbacks.MC_REFRESH_TEAR_SPRITE,
		function(fileName, spritesheet, animation)
			if fileName == false then
				tearOverride = true
				targetFileName = nil
				targetSpritesheet = nil
				targetAnimation = nil
			end
			if fileName ~= targetFileName and type(fileName) == "string" then
				targetFileName = fileName
				tearOverride = true
			end
			if spritesheet ~= targetSpritesheet and type(spritesheet) == "string" then
				targetSpritesheet = spritesheet
				tearOverride = true
			end
			if animation ~= targetAnimation and type(animation) == "string" then
				targetAnimation = animation
				tearOverride = true
			end
		end
	, tear, targetFileName, targetSpritesheet, targetAnimation)
	if tearOverride == false then
		tearData.isCardTear = isCardTear
		tearData.isHeartTear = isHeartTear
		tearData.isJoypadTear = isJoypadTear
		tearData.isHaloTear = isHaloTear
		tearData.isEyeTear = isEyeTear
		tearData.isBombTear = isBombTear
		tearData.isScytheTear = isScytheTear
		tearData.isCoalTear = isCoalTear
		tearData.isMushroomTear = isMushroomTear
		tearData.isMagnetTear = isMagnetTear
		tearData.isFireTear = isFireTear
		tearData.isDarkTear = isDarkTear
		tearData.isContinuumTear = isContinuumTear
        tearData.isMysteriousLiquidTear = isMysteriousLiquidTear
		tearData.isCoinTear = isCoinTear
	end
	-- no code below		0.0061 @ 100 knives
	-- pre optimization		0.0136 @ 100 knives
	-- post optimization	0.0074 @ 100 knives

	if targetFileName ~= nil and sprite:GetFilename() ~= targetFileName then
		sprite:Load(targetFileName)
		updateSpritesheet = true
		sprite:Play(sprite:GetDefaultAnimation())
	end

	if updateSpritesheet and targetSpritesheet ~= nil then
		sprite:ReplaceSpritesheet(0,targetSpritesheet)
		sprite:LoadGraphics()
	end
	
	if targetAnimation ~= nil and not sprite:IsPlaying(targetAnimation) then
		sprite:Play(targetAnimation)
	end
	--[[EntityLog(tear,targetFileName)
	EntityLog(tear,targetSpritesheet)
	EntityLog(tear,targetAnimation)]]
end

local function HandleTearStatic(tear, targets, player, force)
    local target = nil
    if #targets > 0 then
        target = targets[math.random(#targets)]
    end
    local tearData = tear:GetData()
    if tearData.staticCharge == nil then
        tearData.staticCharge = 0
    end
    tearData.staticCharge = tearData.staticCharge + player.Velocity:Length() * math.random()
    if tearData.staticCharge >= SynergyProperties.TechnologyZeroStaticChargeNeeded or force == true then
        tearData.staticCharge = tearData.staticCharge - SynergyProperties.TechnologyZeroStaticChargeNeeded
        local direction = nil
        if target ~= nil then
            direction = (target.Position - player.Position):Rotated((math.random() - 0.5) * 32)
        else
            direction = QVector(math.random()-0.5,math.random()-0.5)
        end
        laser = player:FireTechLaser(tear.Position + tear.Velocity, 0, direction, false, false)
        laser.Parent = player
        laser.SpriteOffset = VECTOR_ZERO
        laser.ParentOffset = VECTOR_ZERO
        laser.PositionOffset = QVector(0,ORBIT_HEIGHT)
        laser.MaxDistance = math.random() * 96 + 16
        laser.GridCollisionClass = GridCollisionClass.COLLISION_NONE
        laser.Timeout = 3
        laser.CollisionDamage = laser.CollisionDamage * 3
        --laser:SetColor(Color(0,0,0,1,0,255,255),-1,100,true,true)
        laser.Visible = false
        laser:Update()
        laser.Visible = true
        sfx:Play(SoundEffect.SOUND_SUMMONSOUND, 0.1, 0, false, math.random() * 0.5 + 5)
        sfx:Play(SoundEffect.SOUND_BEEP, 0.1, 0, false, math.random() * 0.3 + 2)
    end
end

local function HandleTearHoming(tear, velocity, homingTargets)

	local homingTarget = FindClosestEntity(tear,homingTargets,HOMING_DISTANCE_TRESHOLD)
	if homingTarget then -- If there is a target and Mei is firing
		local homingLocation = homingTarget.Position + homingTarget.Velocity
		local homingVector =  homingLocation - tear.Position
		local currentAngle = tear.Velocity:GetAngleDegrees() 
		local targetAngle = (homingLocation - tear.Position):GetAngleDegrees() 
		local homingEffectiveness = (1-math.max(0,math.min(1,homingVector:Length() / HOMING_DISTANCE_TRESHOLD))) ^ HOMING_FRICTION
		local targetDeviation = UnwrapAngle(targetAngle * DEGRAD, currentAngle * DEGRAD) * RADDEG --UnwrapAngle(currentAngle*DEGRAD,targetAngle*DEGRAD) * RADDEG 
		local speed = math.max(tear.Velocity:Length(),HOMING_STRENGTH)
		local rotationSpeed = (speed ^ HOMING_ROTATION_SPEED_EXPONENT + HOMING_ROTATION_MINIMUM) * homingEffectiveness
		if math.abs(targetDeviation) > rotationSpeed then
			targetDeviation = Sign(targetDeviation) * rotationSpeed
		end
		tear.Velocity = (Vector.FromAngle(currentAngle + targetDeviation) * speed) * homingEffectiveness + velocity * (1 - homingEffectiveness)
	else
		tear.Velocity = velocity
	end
end

local function HandleTearRotation(tear)
	local tearData = tear:GetData()
	-- Tears that rotate based on Velocity
	if tearData.isEpicFetusTear or 
		tearData.isKnifeTear or 
		tearData.isHeartTear or
		tear.Variant == TearVariant.FIRE_MIND or
		tear.Variant == TearVariant.DARK_MATTER or
		tear.Variant == TearVariant.CUPID_BLUE or
		tear.Variant == TearVariant.CUPID_BLOOD or
		tear.Variant == TearVariant.NAIL or
		tear.Variant == TearVariant.NAIL_BLOOD or
		tear.Variant == TearVariant.NEEDLE then
		tear.SpriteRotation = tear.Velocity:GetAngleDegrees()
	elseif tear.Variant == TearVariant.PUPULA or
		tear.Variant == TearVariant.PUPULA_BLOOD then
		tear.SpriteRotation = tear.Velocity:GetAngleDegrees() + 90
	-- Tears that rotate based on Time
	elseif tear.Variant == TearVariant.RAZOR or 
		tear.Variant == TearVariant.EGG or 
		tear.Variant == TearVariant.BONE or 
		tear.Variant == TearVariant.TOOTH or 
		tear.Variant == TearVariant.BLACK_TOOTH or
		tear.Variant == TearVariant.SCHYTHE or
		tearData.isJoypadTear or
		tearData.isMushroomTear or
		tearData.isMagnetTear or
		tearData.isCardTear or
		tearData.isCoalTear then
		tear:GetSprite():Stop() -- Make sure they don't go rotating on their own
		tear.SpriteRotation = WrapAngleDegrees(tear:GetSprite().Rotation + 30 * (reverseOrbitalVelocity and -1 or 1))
    -- Tears that don't rotate
    elseif tear.Variant == TearVariant.COIN then
        tear.SpriteRotation = 0
	end
end

local function MorphTear(player,tear,change,refresh,forceLudo)
	if refresh == nil then
		refresh = true
	end
	if change == nil then
		change = true
	end
	if forceLudo == nil then
		forceLudo = false
	end
	local tearData = tear:GetData()
	local tearHitParams = nil
	if change then
		tearData.homing = false
		tearData.magnetic = false
        tearData.parasite = false
		tearData.static = false
		tearData.jacobs = false
		tearData.rubber = false
        tearData.coal = false
        tearData.coin = false
		tearData.haemolacria = false

		tearHitParams = player:GetTearHitParams(WeaponType.WEAPON_TEARS,1,0)
		if tearData.baseMass == nil then
			tearData.baseMass = tear.Mass
		end
		tear.TearFlags = tearHitParams.TearFlags
		tear.CollisionDamage = tearHitParams.TearDamage
		local variant = tearHitParams.TearVariant
        if Synergies.Haemolacria == true then
            if variant == TearVariant.BLUE or variant == TearVariant.BLOOD then
                variant = TearVariant.BALLOON
            end
        end
		local extraScale = 0
		if Synergies.BloodClot and ( tearData.tearIndex or 0 ) % 2 == 0 then
			local amount = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BLOOD_CLOT)
			tear.CollisionDamage = tear.CollisionDamage + 1 * amount
			extraScale = extraScale + 0.2 * amount
			if variant == TearVariant.BLUE then
				variant = TearVariant.BLOOD
			end
		end
		if Synergies.ChemicalPeel and ( tearData.tearIndex or 0 ) % 2 == 0 then
			local amount = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_CHEMICAL_PEEL)
			tear.CollisionDamage = tear.CollisionDamage + 2 * amount
			extraScale = extraScale + 0.2 * amount
			if variant == TearVariant.BLUE then
				variant = TearVariant.BLOOD
			end
		end
        if variant == TearVariant.COIN then
            tearData.coin = true
            variant = TearVariant.BLUE
        end
		tearData.baseDamage = tear.CollisionDamage
        tearData.baseScale = math.min(tearHitParams.TearScale + extraScale,TEAR_SCALE_MAXIMUM)
		tearData.baseSize = tear.Size
		tearData.baseColor = tearHitParams.TearColor
		tear:SetColor(tearHitParams.TearColor,-1,1,true,true)
		if Synergies.EpicFetus and not forceLudo then
			if (tearData.orbitIndex or 0) <= player:GetCollectibleNum(CollectibleType.COLLECTIBLE_EPIC_FETUS) then
				if not tearData.isEpicFetusTear then
					tear:ChangeVariant(variant)
				end
				tearData.isEpicFetusTear = true
				--[[if variant ~= TearVariant.BLUE or variant ~= TearVariant.BLOOD then
					variant = TearVariant.BLUE
				end]]
			else
				tearData.isEpicFetusTear = false
			end
		else
			if tearData.isEpicFetusTear then
				tear:ChangeVariant(variant)
			end
			tearData.isEpicFetusTear = false
		end
		if Synergies.MomsKnife and not tearData.isEpicFetusTear then
			if not tearData.isKnifeTear then
				tear:ChangeVariant(variant)
			end
			tearData.isKnifeTear = true
			--[[if variant ~= TearVariant.BLUE or variant ~= TearVariant.BLOOD then
				variant = TearVariant.BLUE
			end]]
		elseif not Synergies.MomsKnife then
			if tearData.isKnifeTear then
				tear:ChangeVariant(variant)
			end
			tearData.isKnifeTear = false
		end
		if Synergies.EyeOfBelial then
			tearData.isBelialTear = true
		elseif not Synergies.EyeOfBelial then
			tearData.isBelialTear = false
		end
		if tear.Variant ~= variant then
			tear:ChangeVariant(variant)
		end
		tear.Mass = tearData.baseMass / player.ShotSpeed * tearMassMultiplier
		if Synergies.Pisces then
			tear.Mass = tear.Mass * SynergyProperties.PiscesMassMultiplier
		end
	end

	-- Prevent certain base tear flags and ensure spectral
	tear.TearFlags = (tear.TearFlags | TearFlags.TEAR_SPECTRAL ) & (~( 
		TearFlags.TEAR_ORBIT | 
		TearFlags.TEAR_SPIRAL | 
		TearFlags.TEAR_SQUARE | 
		TearFlags.TEAR_WIGGLE | 
		TearFlags.TEAR_BIG_SPIRAL |
		TearFlags.TEAR_TRACTOR_BEAM |
		TearFlags.TEAR_WAIT
	))

	if forceLudo then
		tear.StickTarget = nil
	end

	-- If the tear needs to be ludovico to work properly, make it
	if forceLudo or Synergies.MomsKnife then
		tear.TearFlags = tear.TearFlags | TearFlags.TEAR_LUDOVICO
	end
	
	-- If the tear ended up being a ludo tear
	if tear.TearFlags & TearFlags.TEAR_LUDOVICO ~= 0 then
		-- Make sure it is not also a rubber tear
		tear.TearFlags = tear.TearFlags & (~( TearFlags.TEAR_BOUNCE ))
		tear.Friction = 1.35
	else
		tear.Friction = 1.0
	end
	-- If the tear ended up being a coal tear
	if tear.TearFlags & TearFlags.TEAR_GROW ~= 0 then
		tearData.coal = true
		tear.TearFlags = tear.TearFlags & (~( TearFlags.TEAR_GROW ))
	end
	-- If the tear ended up being a homing tear
	if tear.TearFlags & TearFlags.TEAR_HOMING ~= 0 then
		tearData.homing = true
		tear.TearFlags = tear.TearFlags & (~( TearFlags.TEAR_HOMING ))
	end
	-- If the tear ended up being a magnetic tear
	if tear.TearFlags & TearFlags.TEAR_ATTRACTOR ~= 0 or tearData.magnetic == true then
		tearData.magnetic = true
		-- If Mei isn't firing, remove the magnetic flag
		if not firing then
			tear.TearFlags = tear.TearFlags & (~( TearFlags.TEAR_ATTRACTOR ))
		end
	end
	-- If the tear ended up being a rubber tear
	if tear.TearFlags & TearFlags.TEAR_BOUNCE ~= 0 then
		tearData.rubber = true
		-- Remove the rubber flag to prevent it from bouncing off of stuff until the time is right
        tear.TearFlags = tear.TearFlags & (~( TearFlags.TEAR_BOUNCE ))
	end
	if tear.TearFlags & TearFlags.TEAR_SPLIT ~= 0 then
		tearData.parasite = true
		if not firing then
			tear.TearFlags = tear.TearFlags & (~( TearFlags.TEAR_SPLIT ))
		end
	end
	if tear.TearFlags & TearFlags.TEAR_JACOBS ~= 0 then
		tearData.jacobs = true
		if not firing then
			tear.TearFlags = tear.TearFlags & (~( TearFlags.TEAR_JACOBS ))
		end
	end
    if tear.TearFlags & TearFlags.TEAR_LASER ~= 0 then
        tearData.static = true
        tear.TearFlags = tear.TearFlags & (~( TearFlags.TEAR_LASER ))
    end
	--[[if change and tear.TearFlags & TearFlags.TEAR_LUDOVICO ~= 0 then
		tearData.baseScale = tearData.baseScale + LUDOVICO_TEAR_SCALE_OFFSET
	end]]
	-- Both of these solutions cause problems...
	--tear.Scale = tearData.baseScale
	--[[if tearData.isScytheTear then
		tear:ResetSpriteScale()
	end]]
	tear:SetDeadEyeIntensity(deadEyeIntensity)
	tear.CollisionDamage = tearData.baseDamage
	if tearData.isEpicFetusTear then
		tear.CollisionDamage = tear.CollisionDamage * 20
		tear.TearFlags = (tear.TearFlags | TearFlags.TEAR_EXPLOSIVE) & (~(TearFlags.TEAR_PIERCING))
	end
	if tearData.isKnifeTear then
		tear.CollisionDamage = tear.CollisionDamage * 4
	end
	
	HandleCallbacks(mod.ModCallbacks.MC_MORPH_TEAR,nil,tear)

    if refresh then
        RefreshTearSprite(tear,tearData.orbitIndex or 0)
    end
end

local function FireCustomTear(player,position,velocity)
	local tear = Isaac.Spawn(EntityType.ENTITY_TEAR,TearVariant.BLUE, 0, position, velocity, player):ToTear()
	tear:GetData().tearIndex = customTearIndex
	customTearIndex = customTearIndex + 1
	tear.Parent = player
	return tear
end

local function Airstrike(position, spawner, damage, expireFrame)
	local airstrike = {}
	local expireFrame = expireFrame or 50
	local damage = damage or 60
	local rocketFrame = 40
	local rocketSpeed = 100
	local targetEntity = nil
	local rocketEntity = nil
	local roomIndex = -1
	local stageIndex = -1
	function airstrike.Update(index)
		if targetEntity == nil then
			targetEntity = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TARGET, 0, position, VECTOR_ZERO, spawner)
		end
		if targetEntity.FrameCount == rocketFrame then
			rocketEntity = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCKET, 0, position, VECTOR_ZERO, spawner)
			--rocketEntity.PositionOffset = QVector(0, (expireFrame - rocketFrame) * -rocketSpeed)
		end
		if rocketEntity ~= nil then
			rocketEntity:GetSprite():Play("Falling",true)
			rocketEntity.PositionOffset = rocketEntity.PositionOffset + QVector(0, rocketSpeed)
			if rocketEntity.FrameCount == expireFrame - rocketFrame then
				rocketEntity:Remove()
				targetEntity:Remove()
				Isaac.Explode(position, spawner, damage)
				table.remove(airstrikes,index)
			end
		end
	end
	table.insert(airstrikes,airstrike)
	return airstrike
end

-- [[ Grudge Section ]]

local GrudgeProperties = {
	FlameEntityType							= Isaac.GetEntityTypeByName( "Mei Flame" ),
	FlameEntityVariant						= Isaac.GetEntityVariantByName( "Mei Flame" ),
	FlameEntitySubType						= 0,
	GrudgeEntityType						= Isaac.GetEntityTypeByName( "Mei Grudge" ),
	GrudgeEntityVariant						= Isaac.GetEntityVariantByName( "Mei Grudge" ),
	GrudgeEntitySubType						= 0,
	LightEntityType							= EntityType.ENTITY_EFFECT,
	LightEntityVariant						= EffectVariant.FIREWORKS,
	LightEntitySubType						= 5,
	MoveSpeed 								= 16,
	InitializationFrames 					= 15,
	ProximityRadius 						= 0, -- How close an entity must be to be grudged. Calculated based on Tear Height
	ProximityRadiusMultiplier 				= 4, -- How much the Mei's Range is multiplied by to calculate her Grudge distance
	ProximityDamageApplicationInterval		= 15, -- How often an enemy in Mei's Grudge proximity will be damaged by their current Grudge
	ProximityDamageMultiplier 				= 1, -- A multiplier against the normal damage a Grudge does when applied as proximity damage
	TimeAppliedOnHit						= 135, -- The amount of Grudge time applied when an enemy is hit by Mei's attacks
	TimeAppliedOnProximity					= 7, -- The amount of Grudge time applied when an enemy is within grudge proximity
	CursedEyeApplyTimeMultiplier			= 2, -- A multiplier on applied time with Cursed Eye
	RedCandleApplyTimeMultiplier			= 1.5, -- A multiplier on applied time with Cursed Eye
	LevelInterval							= 360, -- How much Grudge time is needed per level of grudge
	LevelIntervalModifier					= 0.25, -- A general modifier for the grudge level formula
	LevelMaximum							= 7, -- The maximum level a single Grudge can reach
	LossSpeed								= 1, -- How much a Grudge time is lost per frame
	LossSpeedMultiplier						= 1.00, -- A flat multiplier on loss speed
	DamageMultiplier						= 0.25, -- The multiplier against the player's damage used to calculate Grudge damage
	DamageInterval							= 60, -- How many frames between each tick of Grudge damage
	DamageIntervalMultiplier				= 1.00, -- A flat multiplier on damage interval
	LevelDamageMultiplierExponent			= 0.5, -- An exponent applied against grudge level before multiplying it against player damage when calculating total grudge damage
	PlayerDamageMultiplierPerGrudgeLevel	= 0.0125, -- How much Mei's damage multiplier is increased per Grudge level
	PlayerDamageBonusPerGrudgeLevel			= 0.0125, -- How much flat damage Mei gains per Grudge level
	BlackCandleDamageMultiplier				= 2, -- The damage multiplier applied when the player has Black Candle
	SacDaggerInstakillThreshold				= 0.25, -- The hit points percentage threshold for Grudge damage to instakill an enemy when Sac Dagger is held
	SecondHandLossSpeedMultiplier			= 0.5 -- The loss speed multiplier when Mei hold's the Second Hand
}

-- Test if an entity can be Grudged or not
local function CanGrudgeEntity(entity)
	return canGrudge and entity:IsVulnerableEnemy() and entity:IsActiveEnemy() and not entity:HasEntityFlags(EntityFlag.FLAG_CHARM) and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
end

--[[ Grudge Class ]]

	local Grudge = 
	{
		target = nil,
		flameEntity = nil,
		lightEntity = nil,
		targetPosition = VECTOR_ZERO,
		targetOffset = VECTOR_ZERO,
		offset = VECTOR_ZERO
	}
	function Grudge:New(target)
		object = {}
		object.target = target
		object.grudgeTime = 0
		object.deadTime = 0
        object.frame = 0
		object.lastDamageFrame = -1
		setmetatable(object, self)
		self.__index = self
		table.insert(grudges, object)
		return object
	end
	setmetatable(Grudge,{__call = Grudge.New})

	function Grudge:ApplyTime(amount)
		if Synergies.CursedEye then
			amount = amount * GrudgeProperties.CursedEyeApplyTimeMultiplier * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_CURSED_EYE)
		end
		if Synergies.RedCandle then
			amount = amount * GrudgeProperties.RedCandleApplyTimeMultiplier
		end
		self.grudgeTime = self.grudgeTime + amount
	end

	function Grudge:ApplyDamage(multiplier)
        if self.lastDamageFrame ~= self.frame then
            self.lastDamageFrame = self.frame
    		multiplier = multiplier or 1
    		local grudgeLevel = self:GrudgeLevel()
    		local baseDamage = player.Damage * (grudgeLevel ^ GrudgeProperties.LevelDamageMultiplierExponent) * GrudgeProperties.DamageMultiplier
    		if Synergies.BlackCandle then
    			baseDamage = baseDamage * GrudgeProperties.BlackCandleDamageMultiplier * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BLACK_CANDLE)
    		end
    		-- Damage the enemy
    		self.target:SetColor(GetGrudgeColor(1),10,10,true,true)
            self.target:TakeDamage( baseDamage *  multiplier, 0, EntityRef(player), 0 )
        end
	end

	function Grudge:ReduceTime(amount)
		self.grudgeTime = self.grudgeTime - amount
		if self.grudgeTime < 0 then
			self.grudgeTime = 0
		end
	end

	function Grudge:GrudgeLevel()
		--return math.min((grudgeTime) / GrudgeProperties.LevelInterval,GrudgeProperties.LevelMaximum)
		return math.min(self.grudgeTime/(GrudgeProperties.LevelInterval + self.grudgeTime ^ GrudgeProperties.LevelIntervalModifier),GrudgeProperties.LevelMaximum)
	end

	function Grudge:Update(grudgeIndex)
		player = Isaac.GetPlayer(0)
		local grudgeLevel = self:GrudgeLevel()
		grudgeTotal = grudgeTotal + grudgeLevel or 0
		if self.target ~= nil then
			if self.target:Exists() and not self.target:IsDead() then
				self.targetPosition = self.target.Position + self.target.Velocity
				self.targetOffset = self.target:GetSprite().Offset - QVector(0, self.target.Size * self.target.SizeMulti.Y )
				if self.grudgeTime > 0 then
					-- If grudge damage should be taken based on which frame the entity is on
					if self.frame % math.floor(GrudgeProperties.DamageInterval * GrudgeProperties.DamageIntervalMultiplier) == 0 then
						self:ApplyDamage()
					end
				else -- if the entity has no grudge time
					self.target:GetData().grudge = nil -- remove the grudge as well
					self.target = nil -- remove the target
				end
			else -- If the target doesn't exist or is dead
				self.target:GetData().grudge = nil
				self.target = nil -- Remove the target
			end
			if self.target ~= nil and (self.flameEntity == nil or not self.flameEntity:Exists() or self.flameEntity:IsDead()) then
				self.flameEntity = Isaac.Spawn(
					GrudgeProperties.GrudgeEntityType,
					GrudgeProperties.GrudgeEntityVariant,
					GrudgeProperties.GrudgeEntitySubType,
					self.targetPosition,
					VECTOR_ZERO,
					player
				)
			end
		end
		self:ReduceTime(GrudgeProperties.LossSpeed * GrudgeProperties.LossSpeedMultiplier)
		if self.grudgeTime <= 0 or self.target == nil then
			self.deadTime = self.deadTime + 1
		end	
		if self.flameEntity ~= nil then
			local flame = self.flameEntity
			local effectiveness = math.min(flame.FrameCount / GrudgeProperties.InitializationFrames,1)
			local deathPercent = math.min(self.deadTime / GrudgeProperties.InitializationFrames,1)
			local percent = self.deadTime == 0 and effectiveness or 1 - deathPercent
			
			offset = self.targetOffset - QVector(math.cos(flame.FrameCount/12) * 16, math.sin(flame.FrameCount/6) * 8 + 48)
			flame.Velocity = (self.targetPosition + offset) - flame.Position
			if flame.Velocity:Length() > GrudgeProperties.MoveSpeed then
				flame.Velocity = flame.Velocity:Normalized() * GrudgeProperties.MoveSpeed
			end
			flame:SetColor(GetGrudgeColor(percent),1,1,true,true)
			flame.RenderZOffset = 999999 -- Render grudge above everything else
			flame.SpriteScale = QVector(math.cos(flame.FrameCount/10)*.2+1, math.sin(flame.FrameCount/10)*-.2+1) * percent
			local scale = math.ceil(math.max(6,math.min(grudgeLevel/GrudgeProperties.LevelMaximum * 13,13) * percent) )
			local sprite = flame:GetSprite()
			if not sprite:IsPlaying("RegularTear"..scale) then
				sprite:Play("RegularTear"..scale,true)
			end
			if self.lightEntity == nil then
				self.lightEntity = Isaac.Spawn(GrudgeProperties.LightEntityType,GrudgeProperties.LightEntityVariant,GrudgeProperties.LightEntitySubType,flame.Position,flame.Velocity,flame)
			end
			if self.lightEntity ~= nil then
				self.lightEntity.Velocity = (flame.Position + flame.Velocity) - self.lightEntity.Position
				self.lightEntity:SetColor(GetGrudgeColor(percent * 2 * scale ^ 0.2),-1,1,true,true)
				self.lightEntity.SpriteScale = flame.SpriteScale
--				self.lightEntity:GetSprite():Play("Explode")
--				self.lightEntity:GetSprite():Stop()
				self.lightEntity:GetSprite():SetFrame("Explode",5)
			end
			if deathPercent >= 1 then
				if self.lightEntity ~= nil then
					self.lightEntity.Visible = false
					self.lightEntity:Remove()
					self.lightEntity = nil
				end
				flame.Visible = false
				flame:Remove()
				self.flameEntity = nil
			end
		end
		self.frame = self.frame + 1
	end

	function Grudge:Dispose()
		if self.flameEntity ~= nil then
			self.flameEntity:Remove()
		end
		if self.lightEntity ~= nil then
			self.lightEntity:Remove()
		end
	end
	function Grudge:IsDead()
		return self.grudgeTime <= 0 and self.deadTime >= GrudgeProperties.InitializationFrames
	end

local function GetGrudge(entity)
    local grudge = nil
    if entity:GetData() ~= nil then
	   grudge = entity:GetData().grudge
    	if grudge == nil then
    		grudge = Grudge(entity)
    		entity:GetData().grudge = grudge
    	end
    end
	return grudge
end

--[[ Psychic Orbital Class ]]

	local PsychicOrbital = {
		entity = nil, -- The entity that represents the position of this orbital
		height = 0, -- The height of the orbital
		orbitalTears = nil, -- The tears the orbital handles
		orbitalOrbitDistance = 16, -- The radius of the arc the tears this orbital controls follow
		orbitalTearCount = 1, -- How many tears this orbital maintains
		orbitalFireDelay = -1, -- This orbital's fire delay
		orbitalOrbitAngleOffset = 0, -- What angle tears should rotate around this orbital (multishot synergies)
		orbitalOrbitSpeed = -3, -- What speed tears should rotate around this orbital (multishot synergies)
		ring = nil, -- The ring this orbital is a child of
		bonusTearCount = 0 -- How many bonus tears this orbital handles
	}

	function PsychicOrbital:New(ring)
		object = {}
		object.ring = ring
		object.orbitalTears = {}
		object.techXChildren = {}
		object.brimstoneChildren = {}
		setmetatable(object, self)
		self.__index = self
		return object
	end
	setmetatable(PsychicOrbital,{__call = PsychicOrbital.New})

	function PsychicOrbital:Update(orbitIndex)
		-- Orbital Entity Section
		-- This section handles the orbital itself, not the tears that orbit it
		if self.entity == nil then -- If the orbital entity is nil for whatever reason
			-- Spawn a new one and store it
			self.entity = Isaac.Spawn(
				GrudgeProperties.GrudgeEntityType,
				GrudgeProperties.GrudgeEntityVariant,
				GrudgeProperties.GrudgeEntitySubType,
				self.ring.targetLocation,VECTOR_ZERO,player
			)
			self.entity.Parent = player
			-- Make sure it doesn't "poof" when appearing
			self.entity:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			-- Make sure these very important entities don't get overwritten
			self.entity:AddEntityFlags(EntityFlag.FLAG_DONT_OVERWRITE)
			self.entity.PositionOffset = VECTOR_ZERO
			self.entity.SpriteOffset = VECTOR_ZERO
			self.entity.Visible = false -- Hide the orbital entity
			Handle(self.entity)
		elseif not self.entity:Exists() then -- Are these orbitals using dead entities?
			return -- Don't even bother updating
		end
		local entityData = self.entity:GetData() -- Store the orbital's data table for easy access
		self.orbitalOrbitDistance = 0 -- Reset the tear orbit distance
		self.orbitalTearCount = 0 -- Reset the tear count
		if Synergies.DoubleShot then -- If 20/20, add 2 shots and 8 orbit distance
			self.orbitalTearCount = self.orbitalTearCount + 2 * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_20_20)
		end
		if Synergies.TripleShot then -- If Inner Eye, add 3 shots and 10 orbit distance
			self.orbitalTearCount = self.orbitalTearCount + 3 * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_INNER_EYE)
		end
		if Synergies.QuadShot then -- If Mutant Spider, add 4 shots and 12 orbit distance
			self.orbitalTearCount = self.orbitalTearCount + 4 * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MUTANT_SPIDER)
		end
		-- If Black Lotus, add up to 3 shots and 10 orbit distance
		if Synergies.BlackLotus and self.orbitalTearCount < 3 * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BLACK_LOTUS) then
			self.orbitalTearCount = 3 * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BLACK_LOTUS)
		end
		if self.orbitalTearCount == 0 then -- If there are no multishot synergy items present, just use 1 tear
			self.orbitalTearCount = 1
		end
		if Synergies.MomsKnife then
			self.orbitalTearCount = self.orbitalTearCount + (player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MOMS_KNIFE)-1)
		end
		local currentTearCount = math.max(self.orbitalTearCount, #self.orbitalTears)
		self.orbitalOrbitDistance = currentTearCount * 4

		self.entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE -- Make it not hit entities
		self.entity.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS -- Make it hit walls
        if Synergies.Continuum then
            self.entity.GridCollisionClass = GridCollisionClass.COLLISION_NONE -- Make it not hit grid entities
        end
		local aimAngle = math.atan(aimDirection.Y,aimDirection.X) -- The angle the player is aiming
		local tinyPlanetModifier = Synergies.TinyPlanet and GetTinyPlanetModifier(self.entity.FrameCount,self.entity.DropSeed) or 1
		local angle = (TWO_PI / self.ring:OrbitalCount() * orbitIndex) + self.ring:Offset() * tinyPlanetModifier * DEGRAD

		local velocity = nil
		if firing then -- Only updated the ellipse angle when we're firing. This feels good.
			orbitAngle = aimAngle
		end

		local effectiveness = math.min(1, self.entity.FrameCount / INITIALIZATION_FRAMES)
		local percentage = 0
		local minimumDistance = 0
		local maximumDistance = 0
		local positionOffset = nil
		local offset = nil

		if Input.IsMouseBtnPressed(Mouse.MOUSE_BUTTON_LEFT) and Synergies.AnalogStick then
			percentage = 1
			local difference = Input.GetMousePosition(true) - self.ring.targetLocation
			orbitAngle = difference:GetAngleDegrees() * DEGRAD
			minimumDistance = self.ring:RadiusMinimum() * tinyPlanetModifier
			maximumDistance = math.min(difference:Length(),self.ring:RadiusMaximum()) * tinyPlanetModifier
		elseif Synergies.LudovicoTechnique and self.ring.ignoreLudo == false then
			percentage = 1
			local difference = ludoTear.Position - self.ring.targetLocation
			orbitAngle = difference:GetAngleDegrees() * DEGRAD
			minimumDistance = self.ring:RadiusMinimum() * tinyPlanetModifier
			maximumDistance = (difference:Length() + self.ring:RadiusMinimum()) * tinyPlanetModifier
		else
			minimumDistance = self.ring:RadiusMinimum() * tinyPlanetModifier
			maximumDistance = self.ring:RadiusMaximum() * tinyPlanetModifier
			percentage = 0
			if not ignoreOrbitalOffset then
				percentage = aimOffsetPercentage ^ 2
			end
		end

		local px,py = PointOnEllipse( minimumDistance + percentage * (maximumDistance - minimumDistance) * 0.5, minimumDistance, angle - orbitAngle, orbitAngle)
		offset = QVector( px + math.cos(orbitAngle) * (maximumDistance - minimumDistance) * 0.5 * percentage, py + math.sin(orbitAngle) * (maximumDistance - minimumDistance) * 0.5 * percentage)
		if self.ring.offsetAngleOffset ~= 0 then
			offset = offset:Rotated(self.ring.offsetAngleOffset)
		end
		--velocity = (offset - entity.Position + ring.targetLocation) + orbitalPositionOffset
		local entityVelocityPosition = self.entity.Position
		if not Synergies.MyReflection then
			velocity = (offset - entityVelocityPosition + self.ring.targetLocation) + orbitalPositionOffset			
		else
			velocity = (self.entity.Velocity + ((offset - entityVelocityPosition + self.ring.targetLocation) * 0.0167)) * 0.93 + orbitalPositionOffset
		end

		if Synergies.RingWorm or Synergies.RainbowWorm then
			velocity = GetRingWormOffset(velocity,self.entity.FrameCount)
		end
		if Synergies.WiggleWorm or Synergies.RainbowWorm then
			velocity = GetWiggleWormOffset(velocity,self.entity.FrameCount)
		end
		if Synergies.HookWorm or Synergies.RainbowWorm then
			velocity = GetHookWormOffset(velocity,self.entity.FrameCount)
		end
		if Synergies.OuroborosWorm or Synergies.RainbowWorm then
			velocity = GetOuroborosWormOffset(velocity,self.entity.FrameCount)
		end
		if velocity:Length() > tearSpeed then
			velocity = velocity:Normalized() * tearSpeed
		end
		self.entity.Velocity = velocity

		entityVelocityPosition = self.entity.Position + self.entity.Velocity

		if SynergyProperties.MawOfTheVoidShouldActivate then
			local laser = player:SpawnMawOfVoid(SynergyProperties.MawOfTheVoidLength)
			laser.TearFlags = laser.TearFlags ~ TearFlags.TEAR_PULSE
			laser.Parent = self.entity
			--laser.SpriteScale = Vector(0.5, 0.5)
			laser.Radius = SynergyProperties.MawOfTheVoidRadius
		end

		self.height = (math.sin(self.entity.FrameCount / 30 + HALF_PI / self.ring:OrbitalCount() * orbitIndex) + 1) * ORBIT_HEIGHT / 5
		
		-- The distance from the player this orbital is
		local vectorFromTargetLocation = (entityVelocityPosition) - self.ring.targetLocation
		local distanceFromTargetLocation = vectorFromTargetLocation:Length()
		-- The angle between the player and this orbital
		local angleFromTargetLocation = vectorFromTargetLocation:GetAngleDegrees() * DEGRAD
		-- The velocity any shots spawned from this orbital should have
		local velocityFromPlayer = (Vector(math.cos(angleFromTargetLocation) * tearSpeed, math.sin(angleFromTargetLocation) * tearSpeed)) + player.Velocity
		
		-- Orbital Tears Section
		-- This section handles the tears that orbit the orbital

		if self.orbitalFireDelay == -1 then -- If this orbital's fire delay is -1 (ready to fire)
			-- Iterate from 1 to either the amount of tears this orbital should have, or how many it does have
			-- whichever is higher
			local tearIndex = 1
			local bonusTears = 0
			--for i=1,math.max(self.orbitalTearCount,#self.orbitalTears) do
			while tearIndex <= math.max(self.orbitalTearCount + bonusTears, #self.orbitalTears) do
				local orbitalTear = self.orbitalTears[tearIndex] -- Store the current tear
				-- If it doesn't exist and it should exist
				if tearIndex <= self.orbitalTearCount + bonusTears then
					if (shouldClearTears or orbitalTear == nil or orbitalTear == -1 or not orbitalTear:Exists()) then
						local orbitalTear = nil -- Define this variable for later
						local orbitalTearData = nil
						if Synergies.Bookworm and bonusTears == 0 and random() < SynergyProperties.BookwormChance then
							bonusTears = bonusTears + 1
						end
						-- Spawn a tear
						--orbitalTear = player:FireTear(playerVelocityPosition,Vector(0,0),tearCanBeEye,true,tearCanEndStreak)
						orbitalTear = FireCustomTear(player,playerVelocityPosition,VECTOR_ZERO)
						orbitalTearData = orbitalTear:GetData() -- This tears data table
						orbitalTearData.isTear = true -- Keep track of it being a tear
						orbitalTearData.orbitIndex = orbitIndex
						MorphTear(player,orbitalTear)
						--RefreshTearSprite(orbitalTear,orbitalTearData.orbitIndex)

						orbitalTear.Parent = player
						if shouldBecomeIncorporeal then
							-- Store the tears original entity collision class
							orbitalTearData.entityCollisionClass = orbitalTear.EntityCollisionClass
							-- Store the tears original grid collision class
							orbitalTearData.gridCollisionClass = orbitalTear.GridCollisionClass
							orbitalTear.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE -- Make it not hit entities
							orbitalTear.GridCollisionClass = GridCollisionClass.COLLISION_NONE -- Make it not hit grid entities
						end
						-- Reset the position and sprite offsets so they appear in the right spot
						--orbitalTear.PositionOffset = Vector(0,0)
						self.orbitalTears[tearIndex] = orbitalTear -- Store the tear in this orbital's tear table
						-- Ensure this tear won't be overwritten (since this tear needs to orbit around potentially forever)
						-- Doesn't REALLY matter, but in high entity situations feels better than allowing them to be overwritten
						Handle(orbitalTear)
                        self.orbitalFireDelay = player.MaxFireDelay
					end
				else
					if orbitalTear == nil or orbitalTear == -1 or not orbitalTear:Exists() then
						self.orbitalTears[tearIndex] = nil
					end
				end
				tearIndex = tearIndex + 1
			end

			if firing or ignoreOrbitalOffset then -- If the player is firing
				local minimumSynergyDistance = self.ring:RadiusMaximum() * 0.90
				-- Fire a tear that is to be killed immediately so that on tear spawn and on tear expire synergies work
				-- Cricket's Body, Lead Pencil, Evil Eye etc
				if spawnSynergyTears and distanceFromTargetLocation >= minimumSynergyDistance  then
					if spawnSynergyTears then
						local tear = player:FireTear(entityVelocityPosition,Vector(0,0),tearCanBeEye,true,tearCanEndStreak)
						--tear = FireCustomTear(player,entity.Position + entity.Velocity,velocityFromPlayer)
						tear:GetData().synergyTear = true
						tear.Parent = player -- Make sure the tear counts as the players (it should)
						tear.Height = ORBIT_HEIGHT/3 + self.height
						if (tear.TearFlags & (TearFlags.TEAR_EXPLOSIVE)) == 0 then -- If the tear isn't explosive
							tear.Visible = false
							tear:GetData().invisible = true
							tear:SetColor(Color(1,1,1,0,255,255,255),-1,100,true,true) -- Make the tear invisible (hiding the splash)
						end
                        --tear.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE -- Make it not hit entities
                        --tear.GridCollisionClass = GridCollisionClass.COLLISION_NONE -- Make it not hit grid entities
						tear:Update() -- Update the tear once to make sure its collision is handled
                        tear.Velocity = velocityFromPlayer
						tear:Die() -- Kill the tear
					end
					--[[if Synergies.AntiGravity then
						local tear = player:FireTear(entityPosition + self.entity.Velocity,velocityFromPlayer,tearCanBeEye,true,tearCanEndStreak)
						tear.Parent = player -- Make sure the tear counts as the player's (it should)
						tear.Height = ORBIT_HEIGHT/3 + self.height
						tear:Update() -- Update the tear once to make sure its collision is handled
					end]]
					self.orbitalFireDelay = player.MaxFireDelay
				end

				-- If the player has technology or the player has tech.5 and a chance roll succeeded
				if (Synergies.Technology or (Synergies.Tech5 and random() < SynergyProperties.Tech5Chance * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_TECH_5))) then
					local technologyLaserCount = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_TECHNOLOGY) + player:GetCollectibleNum(CollectibleType.COLLECTIBLE_TECH_5) + (currentTearCount - 1)
					if technologyLaserCount == 1 then
						local laser = player:FireTechLaser(entityVelocityPosition, 0, vectorFromTargetLocation, true, false)
						laser.Parent = self.entity -- Set the laser's parent to the orbital
						-- Reset the laser's position and sprite offsets
						laser.PositionOffset = QVector(0,ORBIT_HEIGHT)
						laser.ParentOffset = VECTOR_ZERO
						self.orbitalFireDelay = player.MaxFireDelay
					else
						local baseAngle = angleFromTargetLocation * RADDEG
						local arc = 360
						local angleInterval = arc / (technologyLaserCount)
						for j=1,technologyLaserCount,1 do
							local newAngle = baseAngle - arc / 2 + angleInterval * (j-1) + 180
							-- Fire a laser outward from the player
							local laser = player:FireTechLaser(entityVelocityPosition, 0, Vector.FromAngle(newAngle), true, false)
							laser.Parent = self.entity -- Set the laser's parent to the orbital
							-- Reset the laser's position and sprite offsets
							laser.PositionOffset = QVector(0,ORBIT_HEIGHT)
							laser.ParentOffset = VECTOR_ZERO
						end
					end
					self.orbitalFireDelay = player.MaxFireDelay
				end

				-- Rotatey Brimstone
				if Synergies.Brimstone then
					local brimstoneLaserCount = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BRIMSTONE) + (currentTearCount - 1)
					ArcCallback(angleFromTargetLocation * RADDEG,360,brimstoneLaserCount,false,false,function(angle,index)
						local laser = self.brimstoneChildren[index]
						if (laser == nil or not laser:Exists() or laser:IsDead()) then
							laser = player:FireBrimstone(VECTOR_ZERO)
							laser.Parent = self.entity
							laser.PositionOffset = QVector(0,ORBIT_HEIGHT)
							laser.ParentOffset = VECTOR_ZERO
							laser.Timeout = 30
							laser.Angle = angle
							laser:Update()
							Handle(laser)
							self.brimstoneChildren[index] = laser
						end
					end)
					self.orbitalFireDelay = player.MaxFireDelay
				end

				-- If the player has ghost pepper and a chance roll succeeded
				if Synergies.GhostPepper and random() <= SynergyProperties.GhostPepperChance * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_GHOST_PEPPER) then
					-- Spawn a Red Candle flame outward from the orbital
					local flame = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.RED_CANDLE_FLAME,0,entityVelocityPosition,velocityFromPlayer,player)
					self.orbitalFireDelay = player.MaxFireDelay
				end

				-- If the player has large zit and a chance roll succeeded
				if Synergies.LargeZit and random() <= SynergyProperties.LargeZitChance * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_LARGE_ZIT) then
					player:DoZitEffect(aimDirection)
					self.orbitalFireDelay = player.MaxFireDelay
				end

				-- If the player has dr fetus only if the player is actually firing
				if Synergies.DrFetus then
					-- Spawn a player bomb outward from the player
					ArcCallback(angleFromTargetLocation * RADDEG, 135, player:GetCollectibleNum(CollectibleType.COLLECTIBLE_DR_FETUS) + (currentTearCount - 1), true, true, function(angle)
						local bomb = player:FireBomb(entityVelocityPosition, Vector.FromAngle(angle) * (player.ShotSpeed + 2) * 4)
						bomb.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
					end)
					self.orbitalFireDelay = player.MaxFireDelay
				end
			end
		end

		local orbitTearIndex = 1 -- Track which orbit tear we're actually working with
		for i=1,#self.orbitalTears do -- Iterate through this orbital's tear
			local orbitalTear = self.orbitalTears[i] -- Reference to the current tear
			-- If the tear really, really exists
			if orbitalTear ~= nil and orbitalTear ~= -1 and orbitalTear:Exists() then
				local orbitalTearPosition = orbitalTear.Position
				local orbitalTearData = orbitalTear:GetData() -- This tears data table
				-- Some easy access tear checks
				local isTear = orbitalTearData.isTear or false

				-- The angle offset based on which tear we're updating
				local angle = math.pi * 2 / currentTearCount * orbitTearIndex + self.orbitalOrbitAngleOffset / 30
				local offsetVector = VECTOR_ZERO
				if self.orbitalOrbitDistance ~= 0 then
					-- The point on a circle this tear should be
					offsetVector = Vector(math.cos( angle ) * ( self.orbitalOrbitDistance ),math.sin( angle ) * ( self.orbitalOrbitDistance )) -- Make a vector out of it for easy vector math
				end

				if isTear then -- The tear is actually an EntityTear
					if orbitalTear.StickTarget == nil then
						if orbitalTear.FrameCount % (player.MaxFireDelay * TEAR_MORPH_MAX_FIRE_DELAY_MULTIPLIER + TEAR_MORPH_MAX_FIRE_DELAY_OFFSET) == 0 then
							MorphTear(player,orbitalTear,true,true)
						else
							-- Only refresh every frame is it's a Ludovico Tear
							MorphTear(player,orbitalTear,false,orbitalTear.TearFlags & TearFlags.TEAR_LUDOVICO ~= 0)
						end
					end

					--HandleTearRotation(orbitalTear)
					
					orbitalTear.FallingSpeed = 0 -- Make the tear not fall (shouldn't matter with ludovico tears)
					orbitalTear.FallingAcceleration = 0 -- Make the tear not fall even more (shouldn't matter with ludovico tears)
					local tearHeightOffset = (math.cos(orbitalTear.FrameCount/30 + HALF_PI/#self.orbitalTears * orbitTearIndex)+1) * ORBIT_HEIGHT/5
					orbitalTear.Height = ORBIT_HEIGHT/3 + tearHeightOffset + self.height
					if firing or ignoreOrbitalOffset then
						orbitalTearData.shootingTime = (orbitalTearData.shootingTime or 0) + 1
						if Synergies.ChocolateMilk then
							orbitalTearData.chocolateMilkTime = math.min(orbitalTearData.shootingTime, player.MaxFireDelay)
						end
					else
						orbitalTearData.shootingTime = 0
						if Synergies.ChocolateMilk and (orbitalTearData.chocolateMilkTime or 0) > 0 then
							orbitalTearData.chocolateMilkTime = math.max(0,orbitalTearData.chocolateMilkTime - SynergyProperties.ChocolateMilkTimeLossRate)
						end
					end
				end

				if shouldBecomeIncorporeal and not firing then -- If the tear is incorporeal
					RefreshTearColor(orbitalTear,true)
					orbitalTear.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE -- Make it not hit entities
					orbitalTear.GridCollisionClass = GridCollisionClass.COLLISION_NONE -- Make it not hit grid entities
				else
					RefreshTearColor(orbitalTear,false)
					orbitalTear.EntityCollisionClass = orbitalTearData.entityCollisionClass or orbitalTear.EntityCollisionClass -- Reset its entity collision class
					orbitalTear.GridCollisionClass = orbitalTearData.gridCollisionClass or orbitalTear.GridCollisionClass -- Reset it grid collision class
				end

				orbitalTear.HomingFriction = 0
				orbitalTear.Target = nil
				-- Effectiveness is a percentage based on how long the entity has existed
				-- It is used to have tears move into position over a period of time
				local effectiveness = math.min(1,(orbitalTear.FrameCount+1)/INITIALIZATION_FRAMES)
				if orbitalTear.StickTarget == nil then -- If the shot doesn't have a stick target (explosivo, nose goblin, sinus infection)
					-- Easing from Player
					local velocity = nil
					local targetLocation = entityVelocityPosition + offsetVector
					local currentLocation = orbitalTear.Position + orbitalTear.Velocity
					velocity = ( targetLocation - orbitalTearPosition ) * effectiveness

					if Synergies.RingWorm or Synergies.RainbowWorm then
						velocity = GetRingWormOffset(velocity,self.entity.FrameCount)
					end
					if Synergies.WiggleWorm or Synergies.RainbowWorm then
						velocity = GetWiggleWormOffset(velocity,self.entity.FrameCount)
					end
					if Synergies.HookWorm or Synergies.RainbowWorm then
						velocity = GetHookWormOffset(velocity,self.entity.FrameCount)
					end
					if Synergies.OuroborosWorm or Synergies.RainbowWorm then
						velocity = GetOuroborosWormOffset(velocity,self.entity.FrameCount)
					end
					if velocity:Length() > tearSpeed then
						velocity = velocity:Normalized() * tearSpeed
					end
					if (firing or ignoreOrbitalOffset) and orbitalTearData.homing == true then
						HandleTearHoming(orbitalTear,velocity,homingTargets)
					else
						orbitalTear.Velocity = velocity
					end
					if (firing or ignoreOrbitalOffset) then
						--[[if orbitalTearData.rubber == true then
							if not room:IsPositionInRoom(orbitalTearPosition,14) then
								orbitalTearData.bounced = true
								orbitalTear.TearFlags = orbitalTear.TearFlags | TearFlags.TEAR_BOUNCE
							end
						end]]
						if orbitalTearData.parasite == true then
							orbitalTear.TearFlags = orbitalTear.TearFlags | TearFlags.TEAR_SPLIT
						end
						if orbitalTearData.jacobs == true then
							orbitalTear.TearFlags = orbitalTear.TearFlags | TearFlags.TEAR_JACOBS
						end
					end
				end

				--local distanceFomTargetLocation = (orbitalTearPosition - self.ring.targetLocation):Length()
				-- The percentage out of the maximum distance this tear is
				local distancePercent = math.min(1,math.abs( (distanceFromTargetLocation - self.ring:RadiusMinimum()) / (self.ring:RadiusMaximum() - self.ring:RadiusMinimum())))
				if ignoreOrbitalOffset then
					local distanceFromPlayer = (entityVelocityPosition - playerVelocityPosition):Length()
					distancePercent = math.min(1,math.abs( (distanceFromPlayer - self.ring:RadiusMinimum()) / (self.ring:RadiusMaximum() - self.ring:RadiusMinimum())))
				end
				if isTear then -- The tear is actually a tear
					
					local tearScale = 1 -- Define scale
					local damageMultiplier = 1 
					if Synergies.ChocolateMilk then -- Player has chocolate milk
						local chocolateMilkPercent = math.min(1,(orbitalTearData.chocolateMilkTime or 0) / player.MaxFireDelay)
						-- The scale should be based on chocolate milk's minimums and maximums
						--local scale = (SynergyProperties.ChocolateMilkMinimumScale + distancePercent * (SynergyProperties.ChocolateMilkMaximumScale - SynergyProperties.ChocolateMilkMinimumScale))
						local scale = (SynergyProperties.ChocolateMilkMinimumScale + chocolateMilkPercent * (SynergyProperties.ChocolateMilkMaximumScale - SynergyProperties.ChocolateMilkMinimumScale)) * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK)
						tearScale = tearScale * scale
						damageMultiplier = damageMultiplier * scale
					end
					if orbitalTearData.coal == true then -- Tear is flagged with lump of coal
						local scale = (1-(distancePercent * (1-SynergyProperties.LumpOfCoalScaleMaximum))) * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_LUMP_OF_COAL)
						local scale = math.max(1,distancePercent * SynergyProperties.LumpOfCoalScaleMaximum) * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_LUMP_OF_COAL)
						tearScale = tearScale * scale
						damageMultiplier = damageMultiplier * scale
					end
					if orbitalTear.TearFlags & TearFlags.TEAR_SHRINK ~= 0 then -- Tear is flagged with proptosis
						local scale = (1-(distancePercent * (1-SynergyProperties.ProptosisMinimumTearScale))) * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_PROPTOSIS)
						tearScale = tearScale * scale
						damageMultiplier = damageMultiplier * (1-(distancePercent * (1-SynergyProperties.ProptosisMinimumDamageScale))) * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_PROPTOSIS)
					end
					orbitalTear.CollisionDamage = orbitalTear.CollisionDamage  * damageMultiplier
					if orbitalTear.TearFlags & TearFlags.TEAR_PULSE ~= 0 then
						tearScale = GetPulseWormOffset(tearScale,orbitalTear.FrameCount)
					end
					RefreshTearScale(orbitalTear,tearScale)
				end

				-- If the tear should hit
				if firing then
					-- If the player has sulfuric acid and the tear actually has the sulfuric acid flag
					if Synergies.SulfuricAcid and orbitalTear.TearFlags & TearFlags.TEAR_ACID ~= 0 then
						-- Find the grid index under the tear...
						local gridIndexUnder = room:GetGridIndex(orbitalTearPosition)
						-- and destroy it
						room:DestroyGrid(gridIndexUnder,false)
					end
				else -- If the tear shouldn't hit
					-- Get the grid entity under the tear
					local gridEntityUnder = room:GetGridEntity(room:GetGridIndex(orbitalTearPosition))
					if gridEntityUnder ~= nil then -- If the grid entity exists
                        local desc = gridEntityUnder.Desc
                        -- 12 = TNT barrel
						if desc.Type == 12 and gridEntityUnder.State ~= 4 then -- If the grid entity is TNT and it's not blown up
							gridEntityUnder.State = 0 -- Set it back to new to avoid exploding on Mei
						end
					end
				end

				-- Make sure it doesn't get stuck forever to its stick target
				if orbitalTear.StickTarget ~= nil then
					--MorphTear(player,orbitalTear,true,true)
					orbitalTearData.unhandle = true
				end

				-- Rubber Cement Synergy
				if orbitalTearData.rubber == true and orbitalTearData.bounced == true then
                    orbitalTearData.unhandle = true
                    if orbitalTearData.bounceAngle ~= nil then
                        orbitalTear.Velocity = orbitalTear.Velocity:Rotated(orbitalTearData.bounceAngle-orbitalTear.Velocity:GetAngleDegrees())
                    end
                    --orbitalTearData.rubber = false
                    --orbitalTear.TearFlags = orbitalTear.TearFlags & (~( TearFlags.TEAR_BOUNCE ))
				end

				if orbitalTear.TearFlags & TearFlags.TEAR_LUDOVICO == 0 and orbitalTear.Variant == TearVariant.MULTIDIMENSIONAL then
					orbitalTearData.unhandle = true
				end

				--[[if Synergies.AntiGravity and SynergyProperties.AntiGravityProc then
					orbitalTearData.unhandle = true
				end]]

				if orbitalTearData.unhandle == true then
					orbitalTear.TearFlags = orbitalTear.TearFlags & (~( TearFlags.TEAR_LUDOVICO ))
					Unhandle(orbitalTear)
					self.orbitalTears[orbitTearIndex] = nil
				end

				-- Increment the tear index
				orbitTearIndex = orbitTearIndex + 1
			end
		end

		if Synergies.TechX then
			local techXLaserCount = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_TECH_X) + (currentTearCount - 1)
			local laserOrbitDistance = techXLaserCount * 8
			for i=1,techXLaserCount,1 do
				local laser = self.techXChildren[i]
				if laser == nil and (firing or ignoreOrbitalOffset) then
					laser = player:FireTechXLaser(entityVelocityPosition, VECTOR_ZERO, 0 )
					laser.Parent = self.entity
					laser.PositionOffset = QVector(0,ORBIT_HEIGHT)
					laser.ParentOffset = VECTOR_ZERO
					self.techXChildren[i] = laser
					Handle(laser)
				end
				if laser ~= nil then
					laser.Radius = (SynergyProperties.TechXRadius + self.orbitalOrbitDistance) * math.min(1,laser.FrameCount/player.MaxFireDelay)
					laser.Timeout = 2
					local angle = (TWO_PI / techXLaserCount * i) + self.ring:Offset() * tinyPlanetModifier * DEGRAD
					--laser.Velocity = (entityVelocityPosition) - laser.Position
					laser.Position = entityVelocityPosition + QVector(math.cos(angle) * laserOrbitDistance, math.sin(angle) * laserOrbitDistance)
					if not (firing or ignoreOrbitalOffset) or not laser:Exists() or laser:IsDead() then
						Unhandle(laser)
						laser:Remove()
						self.techXChildren[i] = nil
					end
				end
			end
		end

		if SynergyProperties.MawOfTheVoidIsReady and gameFrame % 4 == 0 then
			local particle = Isaac.Spawn(1000,66,0,entityVelocityPosition,QVector(random(4)-2,random(4)-2),self.entity):ToEffect()
			particle.Position = entityVelocityPosition
			particle.PositionOffset = QVector(0,ORBIT_HEIGHT)
			particle:SetColor(SynergyProperties.MawOfTheVoidParticleColor,-1,1,true,true)
		end

		-- If the orbital is not ready to fire
		if self.orbitalFireDelay > -1 then
			-- Count down until it is
			self.orbitalFireDelay = self.orbitalFireDelay - 1
		end

		-- Rotate the orbital angle based on the base orbital rotation speed and the player's shot speed
		self.orbitalOrbitAngleOffset = self.orbitalOrbitAngleOffset + self.orbitalOrbitSpeed
	end

	-- Orbital disposal function which removes all tears this orbital handles and kills the entity that represents this orbital
	function PsychicOrbital:Dispose()
		for i=1,#self.orbitalTears do
			if self.orbitalTears[i] ~= nil then
				self.orbitalTears[i]:Remove()
			end
		end
		if self.entity ~= nil then
			self.entity:Remove()
		end
	end

	-- If the entity is not instantiated, does not exist, or is dead, the orbital is considered dead
	function PsychicOrbital:IsDead()
		if self.entity == nil or not self.entity:Exists() or self.entity:IsDead() then
			return true
		end
		return false
	end

--[[ Psychic Orbital Ring Class ]]
	local PsychicOrbitalRing = 
	{
		orbitals = nil,
		radiusMultiplier = 1.0,
		angleIntervalOffset = 0,
		offsetVelocityMultiplier = 1,
		orbitalCountMultiplier = 1,
		orbitalCountMinimum = 1,
		orbitalCountMaximum = 8,
		offsetAngleOffset = 0,
		orbitalCountOverride = nil,
		offset = 0,
		radiusMinimum = 40,
		radiusMaximum = 232,
		radius = 40,
		offsetVelocity = 6,
		targetLocation = VECTOR_ZERO
	}

	function PsychicOrbitalRing:New( offsetAngleOffset, radiusMultiplier, angleIntervalOffset, offsetVelocityMultiplier, orbitalCountMinimum, orbitalCountMaximum, orbitalCountMultiplier, orbitalCountOverride )
		local object = {}
		object.orbitals = {}
		object.radiusMultiplier = radiusMultiplier
		object.angleIntervalOffset = angleIntervalOffset
		object.offsetVelocityMultiplier = offsetVelocityMultiplier
		object.orbitalCountMultiplier = orbitalCountMultiplier
		object.orbitalCountMinimum = orbitalCountMinimum
		object.orbitalCountMaximum = orbitalCountMaximum
		object.offsetAngleOffset = offsetAngleOffset
		object.orbitalCountOverride = orbitalCountOverride
		object.ignoreLudo = false
		setmetatable(object, self)
		self.__index = self
		return object
	end
	setmetatable(PsychicOrbitalRing,{__call = PsychicOrbitalRing.New})

	function PsychicOrbitalRing:Offset()
		return self.offset + (360 / self:OrbitalCount()) * self.angleIntervalOffset
	end

	function PsychicOrbitalRing:OffsetVelocity()
		return self.offsetVelocity * self.offsetVelocityMultiplier
	end

	--[[ Common MFDs
		Soft Cap - 5
		Blue Cap - 7
		Screw - 8
		Brimstone - 30
		Mascara - 20
		Poly - 24
		Sacred Heart - 14
		Monstrosity Lung - 43
		Inner - 24
		Mutant - 24
		Chocolate - 25
	]]
	function PsychicOrbitalRing:OrbitalCount()
		if self.orbitalCountOverride ~= nil then
			return self.orbitalCountOverride
		end
		-- Calculate how many orbitals the ring should have based on the player's maximum fire delay limited between 3 and 8 orbitals
		-- Magic numbers for better orbital count management
		local a = 16
		local b = 0.555
		local countBonus = 0
		--[[if Synergies.MomsKnife then
			countBonus = (player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MOMS_KNIFE)-1)
		end]]
		return math.min(math.max(math.floor(a / (player.MaxFireDelay ^ b) * self.orbitalCountMultiplier), self.orbitalCountMinimum), self.orbitalCountMaximum) + countBonus
	end

	function PsychicOrbitalRing:Radius()
		return self.radius * self.radiusMultiplier
	end

	function PsychicOrbitalRing:RadiusMinimum(ignoreBonus)
		local distance = self.radiusMinimum
		if not ignoreBonus then
			 distance = distance + orbitDistanceBonus
		end
		if Synergies.TractorBeam then
			distance = distance + SynergyProperties.TractorBeamMinimumDistanceBonus
		end
		return distance * self.radiusMultiplier
	end

	function PsychicOrbitalRing:RadiusMaximum(ignoreBonus)
		local distance = self.radiusMaximum + orbitDistanceBonus
		--local distance = player.ShotSpeed * math.abs(player.TearHeight) * 10
		if not ignoreBonus then
			 distance = distance + orbitDistanceBonus
		end
		if Synergies.TractorBeam then
			distance = distance + SynergyProperties.TractorBeamMaximumDistanceBonus
		end
		return distance * self.radiusMultiplier
	end
	function PsychicOrbitalRing:Update()
		--If there are any orbitals missing, create them and store them in the orbitals table
		for i=1,self:OrbitalCount() do
			local orbital = self.orbitals[i]
			if orbital == nil or orbital == -1 then
				self.orbitals[i] = PsychicOrbital(self)
			end
		end

		local orbitalOrder = {} -- For storing the proper order of orbitals (for laser synergies for example)
		local orbitalIndex = 1 -- Start at index 1
		for i=1,#self.orbitals do
			local orbital = self.orbitals[i]
			-- If the orbital at this index exists
			if orbital ~= nil and orbital ~= -1 then
				orbital:Update(orbitalIndex) -- Update it
				orbitalIndex = orbitalIndex + 1
				table.insert(orbitalOrder,orbital) -- Push the orbital into the orbital order table
				-- If the orbital is dead or is excess, dipose of it
				if orbital:IsDead() or i > self:OrbitalCount() then
					self.orbitals[i] = -1
					orbital:Dispose()
				end
			end
		end
		
		-- Iterate through the orbitals in the order they need to be iterated in
		for i=1,#orbitalOrder do
			local orbital = orbitalOrder[i].entity -- Get the entity that represents the orbital
			if orbital ~= nil then
				local orbitalData = orbital:GetData() -- The entities data table
				if Synergies.Technology2 then
					local angle = (orbital.Position - player.Position):GetAngleDegrees()
					local maxDistance = nil
					if #orbitalOrder > 2 then
						local index = i % (self:OrbitalCount())+1
						local nextOrbital = orbitalOrder[index] -- Get the next orbital in the list
						if nextOrbital ~= nil and nextOrbital ~= -1 then -- If the orbital actually exists
							nextOrbital = nextOrbital.entity -- Get the entity from that orbital
							if nextOrbital ~= nil then -- If the entity actually exists
								-- The position of the next orbital in the chain including velocity
								local nextOrbitalPosition = nextOrbital.Position + nextOrbital.Velocity
								local difference = nextOrbitalPosition - orbital.Position
								angle = difference:GetAngleDegrees() -- Set the laser's angle
								maxDistance = difference:Length() -- Set the laser's max distance
							end
						end
					end
					-- If the orbital's tech 2 child is not created yet and should be
					if orbitalData.tech2Children == nil then
						orbitalData.tech2Children = {}
					end
					local lasers = orbitalData.tech2Children
					local technologyLaserCount = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_TECHNOLOGY_2)
					ArcCallback(angle, 360, technologyLaserCount, false, true, function(angle, index)
						local laser = lasers[index]
						if laser == nil and (firing or ignoreOrbitalOffset) then
							-- Fire a tech 2 laser
							if not Synergies.Brimstone then
								laser = player:FireTechLaser(orbital.Position + orbital.Velocity, 0, orbital.Position - player.Position, false, false)
								laser.CollisionDamage = laser.CollisionDamage * SynergyProperties.Technology2LaserDamageMultiplier
							else
								laser = player:FireBrimstone(orbital.Position - player.Position)
							end
							--local laser = EntityLaser.ShootAngle(2,orbital.Position + orbital.Velocity,0,1,VECTOR_ZERO,player)
							laser:GetData().isTechnology2 = true
							laser.Parent = orbital
							laser.PositionOffset = QVector(0,ORBIT_HEIGHT)
							laser.ParentOffset = VECTOR_ZERO
							lasers[index] = laser -- Keep track of it
							Handle(laser)
						end
						if laser ~= nil then
							laser.Timeout = 2
							laser.Angle = angle -- Set the laser's angle
							if maxDistance ~= nil then
								laser.MaxDistance = maxDistance -- Set the laser's angle
							end
							if not (firing or ignoreOrbitalOffset) or not laser:Exists() or laser:IsDead() then
								Unhandle(laser)
								laser:Remove()
								lasers[index] = nil
							end
						end
					end)
				end
			end
		end

		local offsetAmount = (self:OffsetVelocity() + epiphoraBonus) * math.min(player.ShotSpeed, 5)
		if reverseOrbitalVelocity then
			offsetAmount = offsetAmount * -1 -- Invert the speed at which the ring rotates
		end
		local orbitSpeedBonus = 1
		if Synergies.TractorBeam then
			orbitSpeedBonus = orbitSpeedBonus * SynergyProperties.TractorBeamOrbitSpeedMultiplier
		end
		self.offset = self.offset + math.min( offsetAmount * orbitSpeedBonus, ORBIT_SPEED_MAXIMUM )
	end

	function PsychicOrbitalRing:Dispose()
		for i=1,#self.orbitals do
			local orbital = self.orbitals[i]
			if orbital ~= nil and orbital ~= -1 then
				orbital:Dispose()
			end
		end
	end

local function ConvertRedHearts(player)
	local skipConversion = false
	local redHeartContainerCost = 2
	local blackHeartsGained = 3
    local boneHeartContainerCost = 1
    local boneBlackHeartsGained = 4
	local healBeforeConversion = true

	HandleCallbacks(mod.ModCallbacks.MC_CONVERT_HEARTS,
		function(redCost, blackGain, heal)
			if redCost == false then
				skipConversion = true
				return
			end
			redHeartContainerCost = redCost or redHeartContainerCost
			blackHeartsGained = blackGain or blackHeartsGained
			if heal ~= nil then healBeforeConversion = heal end
		end,
	redHeartContainerCost, blackHeartsGained)
	if skipConversion == false then
		if healBeforeConversion == true then
			player:SetFullHearts() -- Heal all red hearts
		end
		while player:GetHearts() + player:GetBoneHearts() >= redHeartContainerCost do -- While Mei has enough red hearts containers to convert
            if player:GetBoneHearts() >= boneHeartContainerCost then
                player:AddBoneHearts(-boneHeartContainerCost ) -- Remove them
                player:AddBlackHearts(boneBlackHeartsGained) -- Add their value in black hearts
            else
                player:AddMaxHearts(-redHeartContainerCost, true) -- Remove them
                player:AddBlackHearts(blackHeartsGained) -- Add their value in black hearts
            end
		end
	end
end

-- Perform the callback on the passed in entity and all its children (and its children's children, etc)
local function DoWithAllChildren(entity,callback,...)
	local rootEntity = entity
	while entity ~= nil and entity ~= rootEntity and entity.Child ~= entity do
		callback(entity,...)
		entity = entity.Child
	end
end

function mod:PostUpdate()
	if player == nil then
		player = Isaac.GetPlayer(0) -- Store the player
	end
	isAlive = not player:IsDead()
	if player:GetPlayerType() == playerType then
		isMei = true
		hasTelekinesis = true
		canGrudge = true
		if player:GetCollectibleCount() ~= collectibleCount then
			player:TryRemoveNullCostume(costume) -- Apply her costume again
			player:AddNullCostume(costume) -- Apply her costume again
			costumeEquipped = true
			collectibleCount = player:GetCollectibleCount() -- Update the collectible count tracker
			--shouldClearTears = true
		end
	else -- The player isn't Mei anymore
		isMei = false
		hasTelekinesis = false
		canGrudge = false
		HandleCallbacks(mod.ModCallbacks.MC_TELEKINESIS_VALIDITY,function(telekinesisAvailable)
			hasTelekinesis = telekinesisAvailable or false
		end, hasTelekinesis)
		HandleCallbacks(mod.ModCallbacks.MC_GRUDGE_VALIDITY,function(grudgeAvailable)
			canGrudge = grudgeAvailable or false
		end, canGrudge)
		if costumeEquipped then
			player:TryRemoveNullCostume(costume) -- Remove Mei's costume
			costumeEquipped = false
		end
	end
	if hasTelekinesis or (canGrudge or #grudges > 0) then
		gameFrame = game:GetFrameCount()
		playerVelocityPosition = player.Position + player.Velocity
		roomEntities = Isaac.GetRoomEntities()
	end
	if hasTelekinesis and isAlive then -- If the player is Mei
		room = game:GetRoom() -- Update the current room
		-- If the player is shooting
		firing = player:GetLastActionTriggers() & ActionTriggers.ACTIONTRIGGER_SHOOTING ~= 0

		--local target = Input.GetMousePosition(true)
		----local diff = target - player.Position
		--player:FireTear(player.Position, Vector.FromAngle(RoundToNearestMultiple(player:GetAimDirection():GetAngleDegrees(),90))*10, false,false,false)

		local effects = player:GetEffects()

		-- Collectible tracking
		Synergies.AnalogStick = player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK)
		Synergies.AntiGravity = player:HasCollectible(CollectibleType.COLLECTIBLE_ANTI_GRAVITY)
		Synergies.BlackCandle = player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE)
		Synergies.BlackLotus = player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_LOTUS)
		Synergies.BloodClot = player:HasCollectible(CollectibleType.COLLECTIBLE_BLOOD_CLOT)
		Synergies.Bookworm = player:HasPlayerForm(PlayerForm.PLAYERFORM_BOOK_WORM)
		Synergies.Brimstone = player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE)
		Synergies.ChemicalPeel = player:HasCollectible(CollectibleType.COLLECTIBLE_CHEMICAL_PEEL)
		Synergies.ChocolateMilk = player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK)
		Synergies.Conjoined = player:HasPlayerForm(PlayerForm.PLAYERFORM_BABY)
        Synergies.Continuum = player:HasCollectible(CollectibleType.COLLECTIBLE_CONTINUUM)
		Synergies.DeadEye = player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_EYE)
		Synergies.DeadTooth = player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_TOOTH)
		Synergies.DeathsTouch = player:HasCollectible(CollectibleType.COLLECTIBLE_DEATHS_TOUCH)
		Synergies.DoubleShot = player:HasCollectible(CollectibleType.COLLECTIBLE_20_20)
		Synergies.DrFetus = player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS)
		Synergies.EpicFetus = player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS)
		Synergies.Epiphora = player:HasCollectible(CollectibleType.COLLECTIBLE_EPIPHORA)
		Synergies.EvilEye = player:HasCollectible(CollectibleType.COLLECTIBLE_EVIL_EYE)
		Synergies.EyeOfBelial = player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_OF_BELIAL)
		Synergies.FunGuy = player:HasPlayerForm(PlayerForm.PLAYERFORM_MUSHROOM)
		Synergies.GhostPepper = player:HasCollectible(CollectibleType.COLLECTIBLE_GHOST_PEPPER)
        Synergies.GodHead = player:HasCollectible(CollectibleType.COLLECTIBLE_GODHEAD)
        Synergies.Haemolacria = player:HasCollectible(CollectibleType.COLLECTIBLE_HAEMOLACRIA)
		Synergies.Ipecac = player:HasCollectible(CollectibleType.COLLECTIBLE_IPECAC)
		Synergies.IsaacsHeart = player:HasCollectible(CollectibleType.COLLECTIBLE_ISAACS_HEART)
		Synergies.LargeZit = player:HasCollectible(CollectibleType.COLLECTIBLE_LARGE_ZIT)
		Synergies.LokisHorns = player:HasCollectible(CollectibleType.COLLECTIBLE_LOKIS_HORNS)
		Synergies.LudovicoTechnique = player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE)
		Synergies.Marked = player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED)
		Synergies.MawOfTheVoid = player:HasCollectible(CollectibleType.COLLECTIBLE_MAW_OF_VOID)
		Synergies.MomsEye = player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_EYE)
		Synergies.MomsKnife = player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE)
		Synergies.MonstrosLung = player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG)
		Synergies.MyReflection = player:HasCollectible(CollectibleType.COLLECTIBLE_MY_REFLECTION)
        Synergies.Pisces = player:HasCollectible(CollectibleType.COLLECTIBLE_PISCES)
		Synergies.Pop = player:HasCollectible(CollectibleType.COLLECTIBLE_POP)
		Synergies.QuadShot = player:HasCollectible(CollectibleType.COLLECTIBLE_MUTANT_SPIDER)
		Synergies.RubberCement = player:HasCollectible(CollectibleType.COLLECTIBLE_RUBBER_CEMENT)
		Synergies.SacredHeart = player:HasCollectible(CollectibleType.COLLECTIBLE_SACRED_HEART)
		Synergies.StrangeAttractor = player:HasCollectible(CollectibleType.COLLECTIBLE_STRANGE_ATTRACTOR)
		Synergies.SulfuricAcid = player:HasCollectible(CollectibleType.COLLECTIBLE_SULFURIC_ACID)
		Synergies.Tech5 = player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_5)
		Synergies.Technology = player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY)
        Synergies.Technology2 = player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_2)
		Synergies.TechnologyZero = player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_ZERO)
		Synergies.TechX = player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X)
		Synergies.TheHalo = player:HasCollectible(CollectibleType.COLLECTIBLE_HALO)
		Synergies.TheWiz = player:HasCollectible(CollectibleType.COLLECTIBLE_THE_WIZ) or effects:HasNullEffect(NullItemID.ID_WIZARD)
		Synergies.TinyPlanet = player:HasCollectible(CollectibleType.COLLECTIBLE_TINY_PLANET)
		Synergies.TractorBeam = player:HasCollectible(CollectibleType.COLLECTIBLE_TRACTOR_BEAM)
		Synergies.TripleShot = player:HasCollectible(CollectibleType.COLLECTIBLE_INNER_EYE)
		Synergies.HookWorm = player:HasTrinket(TrinketType.TRINKET_HOOK_WORM)
		Synergies.OuroborosWorm = player:HasTrinket(TrinketType.TRINKET_OUROBOROS_WORM)
		Synergies.RainbowWorm = player:HasTrinket(TrinketType.TRINKET_RAINBOW_WORM)
		Synergies.RingWorm = player:HasTrinket(TrinketType.TRINKET_RING_WORM)
		Synergies.WiggleWorm = player:HasTrinket(TrinketType.TRINKET_WIGGLE_WORM)

		local hadDeadCat = Synergies.DeadCat
		Synergies.DeadCat = player:HasCollectible(CollectibleType.COLLECTIBLE_DEAD_CAT)
		-- If the player just acquired dead cat remove all of her health
		if Synergies.DeadCat and not hadDeadCat then 
			player:AddBlackHearts(-player:GetBlackHearts())
			player:AddSoulHearts(-player:GetSoulHearts())
			player:AddMaxHearts(2)
		end

		shouldBecomeIncorporeal = true
		if Synergies.LudovicoTechnique or Synergies.Marked then
			shouldBecomeIncorporeal = false
		end

		tearCanEndStreak = Synergies.DeadEye
		tearCanBeEye = Synergies.EvilEye

		if Synergies.DeadTooth and firing then
			if deadToothAura == nil then
				deadToothAura = Isaac.Spawn(EntityType.ENTITY_EFFECT, 106,0,player.Position+player.Velocity,VECTOR_ZERO,player)
				deadToothAura.Parent = player
			end
		else
			if deadToothAura ~= nil and not deadToothAura:GetSprite():IsPlaying("Dissappear") then
				deadToothAura:GetSprite():Play("Dissappear",true)
			end
		end

		if deadToothAura ~= nil then
			if not firing or not deadToothAura:Exists() or deadToothAura:IsDead() then
				deadToothAura:GetSprite():Play("Dissappear",true)
				deadToothAura = nil
			end
		end

		if Synergies.AnalogStick and not Synergies.TractorBeam then
			aimDirection = player:GetAimDirection() -- Use the natural joystick direction
		else -- No analog stick collectible
			local direction = player:GetFireDirection() -- Get the direction the player is firing
			-- Set the aim direction vector based on that direction
			if direction == Direction.UP then
				aimDirection = DirectionVector.UP
			elseif direction == Direction.LEFT then
				aimDirection = DirectionVector.LEFT
			elseif direction == Direction.DOWN then
				aimDirection = DirectionVector.DOWN
			elseif direction == Direction.RIGHT then
				aimDirection = DirectionVector.RIGHT
			else
				aimDirection = VECTOR_ZERO
			end
		end

		aimOffsetPercentage = aimOffsetPercentage + ((firing and 1 or 0) * aimDirection:Length() - aimOffsetPercentage) / globalEasing

		--[[if Synergies.AntiGravity then
			targetOrbitalPositionOffset = aimDirection * 48 * aimOffsetPercentage
		end]]


		if gameFrame == 1 then -- new run
			SynergyProperties.MawOfTheVoidActivateFrame = 0
		end

		-- Ease the orbital position offset towards its target destination
		orbitalPositionOffset = orbitalPositionOffset + (targetOrbitalPositionOffset - orbitalPositionOffset) / orbitalPositionOffsetEasing

		-- If Mei moved last frame
		if player:GetLastActionTriggers() & ActionTriggers.ACTIONTRIGGER_MOVED ~= 0 or (Synergies.Marked and player:GetLastActionTriggers() & ActionTriggers.ACTIONTRIGGER_SHOOTING ~= 0) then
			orbitDistanceBonus = orbitDistanceBonus - ORBIT_SHRINK_RATE -- Reduce the orbit distance bonus
			idleTime = 0 -- Reset the idle counter
		else -- If Mei didn't move last frame
			idleTime = idleTime + 1 -- Increase the idle counter
		end

		focusPercent = math.max(0,math.min((idleTime - FOCUS_DELAY) / (FOCUS_TIME - FOCUS_DELAY),1)) ^ 3
		orbitDistanceBonus = ORBIT_DISTANCE_BONUS_MAXIMUM * focusPercent -- Increase the orbit distance bonus

		tearSpeed = math.max(1,player.ShotSpeed)  * 15 * ( 1 + focusPercent )
		if Synergies.TractorBeam then
			tearSpeed = tearSpeed * SynergyProperties.TractorBeamTearSpeedMultiplier
			globalEasing = 1
		end
		tearSpeed = math.min( tearSpeed, TEAR_SPEED_MAXIMUM + orbitDistanceBonus )

		-- Limit the orbit distance bonus to the relevant range
		if orbitDistanceBonus < 0 then
			orbitDistanceBonus = 0
		elseif orbitDistanceBonus > ORBIT_DISTANCE_BONUS_MAXIMUM then
			orbitDistanceBonus = ORBIT_DISTANCE_BONUS_MAXIMUM
		end

		local shouldFire = false -- Should tears actually fire
		SynergyProperties.MawOfTheVoidShouldActivate = false
		if firing then
			if Synergies.Epiphora then
				epiphoraBonus = epiphoraBonus + SynergyProperties.EpiphoraBonusPerFrame * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_EPIPHORA)
				if epiphoraBonus > SynergyProperties.EpiphoraBonusMaximum then
					epiphoraBonus = SynergyProperties.EpiphoraBonusMaximum
				end
				--player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
				--player:EvaluateItems()
			end
			if fireDelay <= 0 then
				shouldfire = true
			end
			shootingTime = shootingTime + 1
			notShootingTime = 0
			SynergyProperties.AntiGravityProc = false
		else
			epiphoraBonus = 0
			if lastIdleTime ~= nil and gameFrame - lastIdleTime > SynergyProperties.MawOfTheVoidChargeTime and Synergies.MawOfTheVoid then
				SynergyProperties.MawOfTheVoidShouldActivate = true
				SynergyProperties.MawOfTheVoidActivateFrame = gameFrame + SynergyProperties.MawOfTheVoidLength
			end
			lastIdleTime = gameFrame
			shootingTime = 0
			--[[if notShootingTime == 0 then
				SynergyProperties.AntiGravityProc = true
			else
				SynergyProperties.AntiGravityProc = false
			end]]
			notShootingTime = notShootingTime + 1
		end
		SynergyProperties.MawOfTheVoidIsActive = SynergyProperties.MawOfTheVoidActivateFrame > gameFrame
		SynergyProperties.MawOfTheVoidIsReady = Synergies.MawOfTheVoid and gameFrame - lastIdleTime > SynergyProperties.MawOfTheVoidChargeTime
		if fireDelay > -1 then -- If Mei isn't ready to fire
			fireDelay = fireDelay - 1 -- Tick down until she is
		else -- If Mei is ready to fire
			shouldFire = true -- Then she should fire
		end

		-- Ring Target Location
		-- The point at which Mei's orbital rings should orbit around
		ignoreOrbitalOffset = false
		local ringTargetLocation = playerVelocityPosition
		if guillotineEntity ~= nil then
			ringTargetLocation = guillotineEntity.Position + guillotineEntity.Velocity
			if not Synergies.Guillotine then
				guillotineEntity = nil
			end
		end
		if isaacsHeartEntity ~= nil then -- Isaac's Heart
			ringTargetLocation = isaacsHeartEntity.Position + isaacsHeartEntity.Velocity
			if not Synergies.IsaacsHeart then
				isaacsHeartEntity = nil
			end
		end
		if isaacsHeartEntity == nil then -- Doesn't have Isaac's Heart
			if Synergies.Marked --[[and not Synergies.LudovicoTechnique]] then
				ignoreOrbitalOffset = true
				if markedTarget == nil or not markedTarget:Exists() or markedTarget:IsDead() then
					markedTarget = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.TARGET,0,playerVelocityPosition,VECTOR_ZERO,player)
					markedTarget:GetSprite():Play("Blink",true)
					markedTarget.Parent = player
				end
				if markedTarget ~= nil then
					local velocity = 0
					local moveSpeed = tearSpeed * SynergyProperties.MarkedMovementSpeedMultiplier
					if not Input.IsMouseBtnPressed (Mouse.MOUSE_BUTTON_LEFT) then
						velocity = markedTarget.Velocity + player:GetAimDirection() * moveSpeed
					else
						velocity = Input.GetMousePosition(true) - markedTarget.Position
					end
					if velocity:Length() > moveSpeed then
						velocity = velocity:Normalized() * moveSpeed
					end
					markedTarget.Friction = 1
					markedTarget.Velocity = (markedTarget.Velocity + velocity) * SynergyProperties.MarkedMovementDrag
					ringTargetLocation = markedTarget.Position + markedTarget.Velocity
				end
			end
			if Synergies.LudovicoTechnique then
				ignoreOrbitalOffset = true
				if ludoTear == nil or not ludoTear:Exists() or ludoTear:IsDead() then
					--ludoTear = player:FireTear(playerVelocityPosition, player.Velocity, false, false, false)
					ludoTear = FireCustomTear(player,playerVelocityPosition,VECTOR_ZERO)
					ludoTear:AddEntityFlags(EntityFlag.FLAG_DONT_OVERWRITE)
					ludoTear:GetData().orbitIndex = 0
					MorphTear(player,ludoTear)
					ludoTear.Parent = player
					ludoTear.TearFlags = (ludoTear.TearFlags | TearFlags.TEAR_LUDOVICO )
					Handle(ludoTear)
				end
				if ludoTear ~= nil and ludoTear:Exists() then
					local velocity = 0
					local moveSpeed = tearSpeed * SynergyProperties.LudovicoMovementSpeedMultiplier
					if not Input.IsMouseBtnPressed (Mouse.MOUSE_BUTTON_LEFT) then
						velocity = ludoTear.Velocity + player:GetAimDirection() * moveSpeed
					else
						velocity = Input.GetMousePosition(true) - ludoTear.Position
					end
					if velocity:Length() > moveSpeed then
						velocity = velocity:Normalized() * moveSpeed
					end
					ludoTear.Friction = 1
					ludoTear.Velocity = (ludoTear.Velocity + velocity) * SynergyProperties.LudovicoMovementDrag
					--ringTargetLocation = ludoTear.Position + ludoTear.Velocity
					if ludoTear.FrameCount % (player.MaxFireDelay * TEAR_MORPH_MAX_FIRE_DELAY_MULTIPLIER + TEAR_MORPH_MAX_FIRE_DELAY_OFFSET) == 0 then
						MorphTear(player,ludoTear,true,true,true)
					else
						MorphTear(player,ludoTear,false,true,true)
					end
					HandleTearRotation(ludoTear)
					RefreshTearColor(ludoTear,false)
					RefreshTearScale(ludoTear,1)
				end
			end
		end
		if not Synergies.Marked --[[or Synergies.LudovicoTechnique]] then
			if markedTarget ~= nil then -- Doesn't have marked, but the entity exists
				markedTarget:Remove() -- Remove it
				markedTarget = nil
			end
		end
		if not Synergies.LudovicoTechnique then
			if ludoTear ~= nil then -- Doesn't have ludo, but the entity exists
				ludoTear:Remove() -- Remove it
				ludoTear = nil
			end
		end
		if Synergies.AntiGravity and firing and room:GetFrameCount() > 1 then
			ringTargetLocation = nil -- Don't update orbital ring locations
		end

		if defaultRing == nil and (not Synergies.TheWiz or Synergies.Conjoined) then
			defaultRing = PsychicOrbitalRing()
		end
		if defaultRing ~= nil then
			defaultRing.offsetAngleOffset = 0
			defaultRing.orbitalCountMultiplier = 1.0
			defaultRing.targetLocation = ringTargetLocation or defaultRing.targetLocation
			defaultRing:Update()
			if Synergies.TheWiz and not Synergies.Conjoined then
				defaultRing:Dispose()
				defaultRing = nil
			end
		end

		for i=1,SynergyProperties.MonstrosLungRingCount * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MONSTROS_LUNG),1 do
			local ring = monstrosLungRings[i]
			if ring == nil and Synergies.MonstrosLung then
				ring = PsychicOrbitalRing( random() * 360, 0.4 + random() * 0.8, random() * 360, 0.9 + random() * 0.2, 1, 3, 0.3)
				monstrosLungRings[i] = ring
			end
			if ring ~= nil then
				ring.targetLocation = ringTargetLocation or ring.targetLocation
				ring:Update()
			end
		end
		if not Synergies.MonstrosLung then
			for k,ring in pairs(monstrosLungRings) do
				if ring ~= nil then
					ring:Dispose()
				end
				monstrosLungRings[k] = nil
			end
		end

		local wizRingCount = math.max(player:GetCollectibleNum(CollectibleType.COLLECTIBLE_THE_WIZ) * 2,2)
		if Synergies.TheWiz or Synergies.Conjoined then
			local arc = 135
			local baseAngle = 0
			local angleInterval = arc / (wizRingCount-1)
			for i=1,wizRingCount,1 do
				local ring = wizRings[i]
				local newAngle = baseAngle - arc / 2 + angleInterval * (i-1)
				if ring == nil then
					
					ring = PsychicOrbitalRing(newAngle,1,1)
					wizRings[i] = ring
				end
				if ring ~= nil then
					ring.offsetAngleOffset = newAngle
					ring.targetLocation = ringTargetLocation or ring.targetLocation
					ring:Update()
				end
			end
		end
		for k,ring in pairs(wizRings) do
			if ring ~= nil and k > wizRingCount then
				ring:Dispose()
				wizRings[k] = nil
			end
		end

		if lokisHornRing1 == nil and Synergies.LokisHorns then
			lokisHornRing1 = PsychicOrbitalRing(-90, 1, 0, 1, 1, 4, 0.35 )
		elseif not Synergies.LokisHorns then
			if lokisHornRing1 ~= nil then
				lokisHornRing1:Dispose()
			end
			lokisHornRing1 = nil
		end
		if lokisHornRing1 ~= nil then
			lokisHornRing1.targetLocation = ringTargetLocation or lokisHornRing1.targetLocation
			lokisHornRing1:Update()
		end

		if lokisHornRing2 == nil and Synergies.LokisHorns then
			lokisHornRing2 = PsychicOrbitalRing( 90, 1, 0, 1, 1, 4, 0.35 )
		elseif not Synergies.LokisHorns then
			if lokisHornRing2 ~= nil then
				lokisHornRing2:Dispose()
			end
			lokisHornRing2 = nil
		end
		if lokisHornRing2 ~= nil then
			lokisHornRing2.targetLocation = ringTargetLocation or lokisHornRing2.targetLocation
			lokisHornRing2:Update()
		end

		if momsEyeRing == nil and (Synergies.MomsEye or Synergies.LokisHorns) then
	--function PsychicOrbitalRing:New( offsetAngleOffset, radiusMultiplier, angleIntervalOffset, offsetVelocityMultiplier, orbitalCountMinimum, orbitalCountMaximum, orbitalCountMultiplier, orbitalCountOverride )
			momsEyeRing = PsychicOrbitalRing(180, 1, 0, 1, nil, nil, 0.35 )
		elseif not (Synergies.MomsEye or Synergies.LokisHorns) then
			if momsEyeRing ~= nil then
				momsEyeRing:Dispose()
			end
			momsEyeRing = nil
		end
		if momsEyeRing ~= nil then
			momsEyeRing.targetLocation = ringTargetLocation or momsEyeRing.targetLocation
			momsEyeRing:Update()
		end

		-- radiusMultiplier, angleOffset, offsetVelocityMultiplier, orbitalCountMinimum, orbitalCountMaximum, orbitalCountMultiplier, offsetAngleOffset)
		if Synergies.LudovicoTechnique then
			if ludoRing == nil then
				ludoRing = PsychicOrbitalRing(0, 0.5, 0, 1, 1, 8, 1, 0, true)
				ludoRing.ignoreLudo = true
			end
		else
			if ludoRing ~= nil then
				ludoRing:Dispose()
			end
			ludoRing = nil
		end
		if ludoRing ~= nil then
			ludoRing.targetLocation = ludoTear.Position + ludoTear.Velocity
			ludoRing.orbitalCountOverride = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) - 1
			ludoRing:Update()
		end

		-- If any of the handled entities need to be removed, remove them
		for i=#handledEntities,1,-1 do
			local entity = handledEntities[i]
			if entity ~= nil and (not entity:Exists() or not entity:GetData().handled) then
				if not entity:ToTear() or entity.StickTarget == nil then
					entity:Remove()
				end
				table.remove(handledEntities,i)
			end
		end

		shouldClearTears = false
	
		deadEyeIntensity = deadEyeIntensity - 0.0035
		if deadEyeIntensity < 0 then
			deadEyeIntensity = 0
		end

		for i=1,#unhandledTears,1 do
			local tear = unhandledTears[i]
			if tear ~= nil then
				if not tear:IsDead() and tear:Exists() then
					if tear:GetData().homing == true then
						HandleTearHoming(tear, tear.Velocity, homingTargets)
					end
					RefreshTearSprite(tear)
					HandleTearRotation(tear)
					RefreshTearColor(tear,false)
					tear.Velocity = tear.Velocity * 0.95
				else
					table.remove(unhandledTears,i)
				end
			end
		end
	end

	if (canGrudge or #grudges > 0) and isAlive then
		GrudgeProperties.LossSpeedMultiplier = 1.0
		GrudgeProperties.DamageIntervalMultiplier = 1.0
		GrudgeProperties.ProximityRadius = -player.TearHeight * GrudgeProperties.ProximityRadiusMultiplier

		Synergies.BlueCandle = player:HasCollectible(CollectibleType.COLLECTIBLE_CANDLE)
		Synergies.CursedEye = player:HasCollectible(CollectibleType.COLLECTIBLE_CURSED_EYE)
		Synergies.CurseOfTheTower = player:HasCollectible(CollectibleType.COLLECTIBLE_CURSE_OF_THE_TOWER)
		Synergies.CrowHeart = player:HasTrinket(TrinketType.TRINKET_CROW_HEART)
		Synergies.Guillotine = player:HasCollectible(CollectibleType.COLLECTIBLE_GUILLOTINE)
		Synergies.RedCandle = player:HasCollectible(CollectibleType.COLLECTIBLE_RED_CANDLE)
		Synergies.SacrificialDagger = player:HasCollectible(CollectibleType.COLLECTIBLE_SACRIFICIAL_DAGGER)
		Synergies.SecondHand = player:HasTrinket(TrinketType.TRINKET_SECOND_HAND)

		if Synergies.SecondHand then
			GrudgeProperties.LossSpeedMultiplier = GrudgeProperties.LossSpeedMultiplier * GrudgeProperties.SecondHandLossSpeedMultiplier -- Cut Grudge loss time in half
		end

		if Synergies.BlueCandle then
			GrudgeProperties.LossSpeedMultiplier = GrudgeProperties.LossSpeedMultiplier * 2
			GrudgeProperties.DamageIntervalMultiplier = GrudgeProperties.DamageIntervalMultiplier * 0.5 -- Increase the rate at which Grudge damage ticks by 100%
		end

		if Synergies.CrowHeart then
			GrudgeProperties.DamageIntervalMultiplier = GrudgeProperties.DamageIntervalMultiplier * (1/1.5) -- Increase the rate at which Grudge damage ticks by 50%
		end

		grudgeTotal = 0
		for i=#grudges,1,-1 do
			local grudge = grudges[i]
			if grudge ~= nil then
				grudge:Update(i)
				if grudge:IsDead() then
					grudge:Dispose()
					table.remove(grudges,i)
				end
			end
		end
		if grudgeTotal > 0 then
			if grudgeFlame == nil or not grudgeFlame:Exists() or grudgeFlame:IsDead() then
				grudgeFlame = Isaac.Spawn(
					GrudgeProperties.GrudgeEntityType,
					GrudgeProperties.GrudgeEntityVariant,
					GrudgeProperties.GrudgeEntitySubType,
					player.Position,
					VECTOR_ZERO,
					player
				)
				grudgeFlame:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			end
			if grudgeFlame ~= nil then
				local percent = math.min(grudgeFlame.FrameCount / INITIALIZATION_FRAMES,1)
				if grudgeTotal < 1 then
					percent = grudgeTotal ^ .7
				end
				local scaleBase = grudgeTotal^.5
				local scale = math.max(1,math.min(scaleBase,13))
				local offset = player:GetSprite().Offset - QVector(0, player.Size * player.SizeMulti.Y ) - 
				QVector(math.cos(grudgeFlame.FrameCount/12) * 16, math.sin(grudgeFlame.FrameCount/6) * 8 + 64)
				local sprite = grudgeFlame:GetSprite()
				grudgeFlame:SetColor(GetGrudgeColor(percent),1,1,true,true)
				grudgeFlame.SpriteScale = QVector(scaleBase/50+1,scaleBase/50+1)
				grudgeFlame.RenderZOffset = 999999 -- Render grudge above everything else
				local animation = "RegularTear"..math.ceil(scale)
				if not sprite:IsPlaying(animation) then
					sprite:Play(animation,true)
				end
				grudgeFlame.Velocity = (playerVelocityPosition + offset) - grudgeFlame.Position
				if grudgeFlame.Child == nil then
					grudgeFlame.Child = Isaac.Spawn(GrudgeProperties.LightEntityType,GrudgeProperties.LightEntityVariant,GrudgeProperties.LightEntitySubType,grudgeFlame.Position,grudgeFlame.Velocity,grudgeFlame)
				end
				if grudgeFlame.Child ~= nil then
					grudgeFlame.Child.Velocity = (grudgeFlame.Position + grudgeFlame.Velocity) - grudgeFlame.Child.Position
					grudgeFlame.Child:SetColor(GetGrudgeColor(percent * 2 * scale ^ 0.2),-1,1,true,true)
					grudgeFlame.Child.SpriteScale = grudgeFlame.SpriteScale
					--[[grudgeFlame.Child:GetSprite():Play("Explode")
					grudgeFlame.Child:GetSprite():Stop()]]
					grudgeFlame.Child:GetSprite():SetFrame("Explode",5)
				end
			end
		end
		if grudgeTotal <= 0 then
			if grudgeFlame ~= nil then
				if grudgeFlame.Child ~= nil then
					grudgeFlame.Child.Visible = false
					grudgeFlame.Child:Remove()
				end
				grudgeFlame.Visible = false
				grudgeFlame:Remove()
				grudgeFlame = nil
			end
		end
	end

	if canGrudge or hasTelekinesis then
		-- Grudge Mechanic
		while #homingTargets > 0 do
			table.remove(homingTargets,1)
		end
		while #grudgeTargets > 0 do
			table.remove(grudgeTargets,1)
		end
		while #grudgePoints > 0 do
			table.remove(grudgePoints,1)
		end
		table.insert(grudgePoints,playerVelocityPosition)
		enemyProjectileCount = 0
		--for i,entity in ipairs(roomEntities) do
		for i=1,#roomEntities do
			local entity = roomEntities[i]
			if entity.Type ~= EntityType.ENTITY_EFFECT then
				if entity.Type == EntityType.ENTITY_FAMILIAR then
					if entity.Variant == FamiliarVariant.ISAACS_HEART then
						isaacsHeartEntity = entity
					end
					if entity.Variant == FamiliarVariant.GUILLOTINE then
						if canGrudge then
							table.insert(grudgePoints,entity.Position)
						end
						guillotineEntity = entity
					end
					if canGrudge then
						if entity.Variant == FamiliarVariant.SCISSORS then
							table.insert(grudgePoints,entity.Position)
						end
					end
				else
					if canGrudge and CanGrudgeEntity(entity) then
						table.insert(grudgeTargets,entity)
					end
				end

				if entity.Type == EntityType.ENTITY_PROJECTILE then
					enemyProjectileCount = enemyProjectileCount + 1
				end

				if hasTelekinesis then
					if IsEntityHomingTarget(entity) then
						table.insert(homingTargets,entity)
					end
					if (entity.Type == EntityType.ENTITY_TEAR or entity.Type == EntityType.ENTITY_KNIFE or entity.Type == EntityType.ENTITY_LASER) then
						local tear = entity:ToTear()
						if not IsHandled(entity) then -- If it's a Tear or a Knife and not being handled
							if tear ~= nil and tear.SpawnerType == EntityType.ENTITY_PLAYER then
								if not entity:GetData().invisible and entity:GetData().unhandle == nil then
									tear:SetColor(COLOR_WHITE,1,1,true,true) -- Make the tear visible (hiding the splash)
								end
								if (tear.TearFlags & TearFlags.TEAR_LUDOVICO) ~= 0 then -- If it's a ludovico tear
									tear.TearFlags = tear.TearFlags & (~( TearFlags.TEAR_LUDOVICO )) -- Make it not ludovico
								end
							end
						end
						if shouldClearTears then -- The tear is being handled and tears should be cleared
							local cast = entity:ToTear() or entity:ToKnife()
							if cast ~= nil then
								cast:Remove()
							end
						end
					end
				end

				if isMei then
					if entity.Type == EntityType.ENTITY_TEAR and entity.SpawnerType == EntityType.ENTITY_PLAYER and entity.SpawnerVariant == 0 then
						local tear = entity:ToTear()
						local tearData = tear:GetData()
						--MorphTear(player,tear)
						RefreshTearSprite(tear,tearData.orbitIndex)
                        HandleTearRotation(tear)
                        if (firing or ignoreOrbitalOffset) and Synergies.TechnologyZero then
    						HandleTearStatic(tear,Isaac.FindInRadius(tear.Position, 256, EntityPartition.ENEMY), player)
                        end
					end
				end
				if enemyProjectileCount > ENEMY_PROJECTILE_CLARITY_THRESHOLD and entity.SpawnerType == EntityType.ENTITY_PLAYER then
					--[[local projectileAlpha = GetPlayerDistanceAlphaAdjustment(playerVelocityPosition,entity.Position,entity.SpriteScale:Length())
					if projectileAlpha ~= 1 then
						entity:SetColor(GetAlphaAdjustedColor(entity:GetColor(),projectileAlpha),1,1,true,true)
					end]]
					entity.DepthOffset = PLAYER_PROJECTILES_DEPTH_OFFSET
				end
			else
				if canGrudge then
					if entity.Variant == EffectVariant.RED_CANDLE_FLAME or entity.Variant == EffectVariant.BLUE_FLAME then
						table.insert(grudgePoints,entity.Position)
					end
				end
				--[[if entity.Variant == EffectVariant.PLAYER_CREEP_GREEN then
					--entity:SetColor(COLOR_MEI_WHITE,-1,1,true,true)
				end]]
			end
		end
		if canGrudge then
			HandleCallbacks(mod.ModCallbacks.MC_GRUDGE_POINTS, nil, grudgePoints)
			for grudgeTargetIndex,entity in ipairs(grudgeTargets) do
				for grudgePointIndex,point in ipairs(grudgePoints) do
					local distance = (point - entity.Position):Length()
					if distance <= GrudgeProperties.ProximityRadius then -- If the enemy is close enough
						-- Increase the entities grudge time by the proximity amount
						GetGrudge(entity):ApplyTime(GrudgeProperties.TimeAppliedOnProximity)
						if player.FrameCount % GrudgeProperties.ProximityDamageApplicationInterval == 0 then
							GetGrudge(entity):ApplyDamage(GrudgeProperties.ProximityDamageMultiplier)
						end
					end
				end
			end
		end

		if gameFrame % INFREQUENT_UPDATE_RATE == 0 then
			-- Only re-evaluate grudge and dead eye damage every so often
			if (extraUpdate or Synergies.DeadEye) then
				player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
				player:EvaluateItems()
				extraUpdate = false
			end
		end
		if grudgeTotal ~= 0 then
			extraUpdate = true
		end
	end
end
mod:AddCallback( ModCallbacks.MC_POST_UPDATE, mod.PostUpdate)

function mod:PostPlayerInit(newPlayer)
	-- If the player is Mei
	if newPlayer.Variant == 0 then
		player = newPlayer
		InitializeRun()
		if player:GetPlayerType() == playerType then
			isMei = true
			hasTelekinesis = true
			canGrudge = true
			-- Add Mei's costume
			player:AddNullCostume(costume)
			--player:AddCollectible(costumeItem,0,false)
		end
		HandleCallbacks(mod.ModCallbacks.MC_TELEKINESIS_VALIDITY,function(telekinesisAvailable)
			hasTelekinesis = telekinesisAvailable or false
		end, hasTelekinesis)
		HandleCallbacks(mod.ModCallbacks.MC_GRUDGE_VALIDITY,function(grudgeAvailable)
			canGrudge = grudgeAvailable or false
		end, canGrudge)
		
		if hasTelekinesis then
			InitializeTelekinesis()
		end
		if canGrudge or #grudges > 0 then
			InitializeGrudge()
		end
		modRNG:SetSeed(player:GetDropRNG():GetSeed(),0)
	end
	HandleMeiMods()
end
mod:AddCallback( ModCallbacks.MC_POST_PLAYER_INIT, mod.PostPlayerInit)

function mod:EntityTakeDamage(entity, amount, flag, source, countdownFrames)
	local isDamageToPlayer = CompareEntity(entity,player)
	local isDamageFromPlayer = (source.Entity ~= nil and (
			source.Entity.SpawnerType == EntityType.ENTITY_PLAYER or
			source.Entity.SpawnerType == EntityType.ENTITY_FAMILIAR or
			source.Entity.Type == EntityType.ENTITY_FAMILIAR or
			CompareEntity(source.Entity,player) or
			(source.Entity.Parent and HasParent(source.Entity,player))
	))
	if canGrudge then
		if isDamageFromPlayer and CanGrudgeEntity(entity) then
			GetGrudge(entity):ApplyTime(GrudgeProperties.TimeAppliedOnHit)
            GetGrudge(entity):ApplyDamage()
			if Synergies.SacrificialDagger == true and entity:IsVulnerableEnemy() and not entity:IsBoss() and entity.HitPoints > 0 and entity.HitPoints/entity.MaxHitPoints < GrudgeProperties.SacDaggerInstakillThreshold and entity:GetData().grudge ~= nil then
				entity.HitPoints = 0
                entity:GetData().grudge = nil
				entity:TakeDamage(entity.HitPoints + 1, flag, source, 0)
				return false
			end
		end
		if isDamageToPlayer then
			if Synergies.CurseOfTheTower then
				for i=1,#roomEntities do
					local entity = roomEntities[i]
					if CanGrudgeEntity(entity) then
						GetGrudge(entity):ApplyTime(SynergyProperties.CurseOfTheTowerGrudgeAmount * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_CURSE_OF_THE_TOWER))
					end
				end
			end
		end
	end
	if hasTelekinesis then
		if source ~= nil and source.Entity ~= nil then
			if source.Entity.Type == EntityType.ENTITY_TEAR then
                --local sourceEntity = EntityPtr(source.Entity).Ref
				local sourceEntity = FindEntity(source.Entity)
				if sourceEntity ~= nil then
					local tear = sourceEntity:ToTear()
					local tearData = tear:GetData()
					if tear	~= nil then
                        if Synergies.TechnologyZero then
                            HandleTearStatic(tear,Isaac.FindInRadius(tear.Position, 256, EntityPartition.ENEMY), player, true)
                        end
						if tearData.rubber and Synergies.RubberCement then
							tearData.bounced = true
						end
						if tear.TearFlags & TearFlags.TEAR_LUDOVICO == 0 and ( tear.TearFlags & TearFlags.TEAR_PIERCING ~= 0 or tear.TearFlags & TearFlags.TEAR_PERSISTENT ~= 0 ) then
							tearData.unhandle = true
						end
					end
				end
			end
		end
	end
	if isMei then -- If the player is Mei
		local takeDamage = nil
		if isDamageToPlayer then
			if flag & DamageFlag.DAMAGE_LASER ~= 0 and
            source.Entity ~= nil and 
            source.Entity.Parent ~= nil and
            ( CompareEntity(source.Entity.Parent,player) == true or HasParent(source.Entity,player) == true ) then
				takeDamage = false
			end
			if firing and ( Synergies.CursedEye and not Synergies.BlackCandle ) and random() < SynergyProperties.CursedEyeTeleportChance then
				game:GetLevel().LeaveDoor = -1
				game:StartRoomTransition(game:GetLevel():GetRandomRoomIndex(),Direction.NO_DIRECTION,3)
			end
			-- Ignore damage from own explosions if the player has Ipecac and Dr Fetus
			if Synergies.Ipecac == true and 
            (Synergies.DrFetus == true or Synergies.EpicFetus == true) and
            source.Type == EntityType.ENTITY_BOMBDROP and
            source.Entity and
            (source.Entity.SpawnerType == EntityType.ENTITY_PLAYER or
            (source.Entity.Parent and source.Entity.Parent.Type == EntityType.ENTITY_PLAYER)) then
				return false
			end
		end
		-- If the damage was from an entity
		if source ~= nil and source.Entity ~= nil then
			if isDamageFromPlayer then
				if Synergies.DeadEye then
					deadEyeIntensity = deadEyeIntensity + SynergyProperties.DeadEyeRate * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_DEAD_EYE)
					if deadEyeIntensity > 1 then
						deadEyeIntensity = 1
					end
				end
			end
		end
		return takeDamage
	end
end
mod:AddCallback( ModCallbacks.MC_ENTITY_TAKE_DMG, mod.EntityTakeDamage)

function mod:PostBombUpdate( bomb )
    --[[if bomb:GetData().mei == true and bomb:GetData().replaced ~= true then
        for i=0,100,1 do
            bomb:GetSprite():ReplaceSpritesheet(i,"gfx/multibombs_mei.png")
        end
        bomb:GetSprite():LoadGraphics()
    end]]
end
mod:AddCallback( ModCallbacks.MC_POST_BOMB_UPDATE, mod.PostBombUpdate)

function mod:EvaluateCache(player, cacheFlag)
	-- If the player is Mei, set her base stats
	if isMei then
		if cacheFlag == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed * 0.8 + 0.1
		elseif cacheFlag == CacheFlag.CACHE_SHOTSPEED then
			player.ShotSpeed = player.ShotSpeed * 0.8 + 0.5
		elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * 0.25 + 0.4
		elseif cacheFlag == CacheFlag.CACHE_TEARCOLOR then
			player.LaserColor = COLOR_MEI_WHITE
		end
	end
	if canGrudge then
		if cacheFlag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * (1 + grudgeTotal * GrudgeProperties.PlayerDamageMultiplierPerGrudgeLevel) + (grudgeTotal * GrudgeProperties.PlayerDamageBonusPerGrudgeLevel)
		end
	end
end
mod:AddCallback( ModCallbacks.MC_EVALUATE_CACHE, mod.EvaluateCache)

function mod:PostRender()
	if hasTelekinesis then
		if player == nil then
			player = Isaac.GetPlayer(0)
		end
		if isAlive then -- If the player is Mei and alive
			if isMei then
				ConvertRedHearts(player)
			end
			if Input.IsActionTriggered (ButtonAction.ACTION_DROP, player.ControllerIndex) then -- If the drop trinket button was pressed
				shouldReverseDirection = true -- Store the fact we should reverse direction
			end
			-- If the drop trinket button is not being held and we should reverse direction
			if not Input.IsActionPressed (ButtonAction.ACTION_DROP, player.ControllerIndex) and shouldReverseDirection then
				reverseOrbitalVelocity = not reverseOrbitalVelocity -- Reverse direction
				shouldReverseDirection = false
			end
			-- If the player holds drop trinket long enough to actually drop it
			if player:GetLastActionTriggers() & ActionTriggers.ACTIONTRIGGER_ITEMSDROPPED ~= 0 then
				shouldReverseDirection = false -- Don't reverse direction when they let go of the button
			end
		end
	end
end
mod:AddCallback( ModCallbacks.MC_POST_RENDER, mod.PostRender)

function mod:NewRoom()
	for i=#grudges,1,-1 do
		local grudge = grudges[i]
		if grudge ~= nil then
			grudge:Dispose()
		end
	end
end
mod:AddCallback( ModCallbacks.MC_POST_NEW_ROOM, mod.NewRoom)


--[[            This has to be disabled until Nicalis fixes the API issue
function mod:PreTearCollision(tear, collider, low)
    if collider:IsEnemy() and tear:GetData().rubber == true and (tear:GetData().lastBounceTarget == nil or tear:GetData().lastBounceTarget ~= collider.Index) then
        tear:GetData().bounced = true
        tear:GetData().lastBounceTarget = collider.Index
        tear:GetData().bounceAngle = (tear.Position - collider.Position):GetAngleDegrees()
        tear.TearFlags = tear.TearFlags | TearFlags.TEAR_BOUNCE
    end
end
mod:AddCallback( ModCallbacks.MC_PRE_TEAR_COLLISION, mod.PreTearCollision)
]]

--[[ Does not work for tears against Angelic Prism
function mod:PreFamiliarCollision(familiar, collider, low)
    Log(collider.Type,collider.Variant)
    if collider.Type == EntityType.ENTITY_TEAR and not firing then
        return false
    end
end
mod:AddCallback( ModCallbacks.MC_PRE_FAMILIAR_COLLISION, mod.PreFamiliarCollision)
]]
HandleMeiMods()
InitializeTelekinesis()
InitializeGrudge()
