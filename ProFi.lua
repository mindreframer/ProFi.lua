--[[
	ProFi, by Luke Perkin 2012. MIT Licence http://www.opensource.org/licenses/mit-license.php.

	Example:
		ProFi = require 'ProFi'
		ProFi:start()
		some_function()
		another_function()
		coroutine.resume( some_coroutine )
		ProFi:end()
		ProFi:writeReport( 'MyProfilingReport.txt' )
]]

-----------------------
-- Locals:
-----------------------

local ProFi = {}
local onFunctionCalled, onFunctionReturn, sortByDurationDesc, sortByCallCount
local DEFAULT_DEBUG_HOOK_COUNT  = 0
local FORMAT_TITLE 		= "%-50.50s: %-40.40s: %-20s"
local FORMAT_HEADER 		= "| %-50s: %-40s: %-20s: %-20s: %-20s|\n"
local FORMAT_OUTPUT_LINE 	= "| %s: %-20s: %-20s|\n"

-----------------------
-- Public Methods:
-----------------------

--[[
	Starts profiling any method that is called between this and ProFi:stop().
	Pass the parameter 'once' to so that this methodis only run once.
	Example: 
		ProFi:start( 'once' )
]]
function ProFi:start( param )
	if param == 'once' then
		if self:shouldReturn() then
			return
		else
			self.should_run_once = true
		end
	end
	self.has_finished = false
	self:startHooks()
end

--[[
	Stops profiling.
]]
function ProFi:stop()
	if self:shouldReturn() then 
		return
	end
	self:stopHooks()
	self.has_finished = true
end

--[[
	Writes the profile report to a file.
	Param: [filename:string:optional] defaults to 'ProFi.txt' if not specified.
]]
function ProFi:writeReport( filename )
	filename = filename or 'ProFi.txt'
	self:sortReportsWithSortMethod( self.reports, self.sortMethod )
	self:writeReportsToFilename( self.reports, filename )
	print( string.format("[ProFi]\t Report written to %s", filename) )
end

--[[
	Resets any profile information stored.
]]
function ProFi:reset()
	self.reports = {}
	self.reportsByTitle = {}
	self.has_finished = false
	self.should_run_once = false
	self.hookCount = self.hookCount or DEFAULT_DEBUG_HOOK_COUNT
	self.sortMethod = self.sortMethod or sortByDurationDesc
end

--[[
	Set how often a hook is called.
	See http://pgl.yoyo.org/luai/i/debug.sethook for information.
	Param: [hookCount:number] if 0 ProFi counts every time a function is called.
	if 2 ProFi counts every other 2 function calls.
]]
function ProFi:setHookCount( hookCount )
	self.hookCount = hookCount
end

--[[
	Set how the report is sorted when written to file.
	Param: [sortType:string] either 'duration' or 'count'.
	'duration' sorts by the time a method took to run.
	'count' sorts by the number of times a method was called.
]]
function ProFi:setSortMethod( sortType )
	if sortType == 'duration' then
		self.sortMethod = sortByDurationDesc
	elseif sortType == 'count' then
		self.sortMethod = sortByCallCount
	end
end

-----------------------
-- Implementations methods:
-----------------------

function ProFi:shouldReturn( )
	return self.should_run_once and self.has_finished
end

function ProFi:getFuncReport( funcInfo )
	local title = self:getTitleFromFuncInfo( funcInfo )
	local funcReport = self.reportsByTitle[ title ]
	if not funcReport then
		funcReport = self:createFuncReport( funcInfo )
		self.reportsByTitle[ title ] = funcReport
		table.insert( self.reports, funcReport )
	end
	return funcReport
end

function ProFi:getTitleFromFuncInfo( funcInfo )
	local name        = funcInfo.name or 'anonymous'
	local source      = funcInfo.short_src or 'C_FUNC'
	local linedefined = funcInfo.linedefined or 0
	linedefined = string.format( "%04i", linedefined )
	return string.format(FORMAT_TITLE, source, name, linedefined)
end

function ProFi:createFuncReport( funcInfo )
	local name = funcInfo.name or 'anonymous'
	local source = funcInfo.source or 'C Func'
	local linedefined = funcInfo.linedefined or 0
	local funcReport = {
		['title']         = self:getTitleFromFuncInfo( funcInfo );
		['calledCounter'] = 0;
		['timer']         = 0;
	}
	return funcReport
end

function ProFi:startHooks()
	debug.sethook( onFunctionCalled, 'c', self.hookCount )
	debug.sethook( onFunctionReturn, 'r', self.hookCount )
end

function ProFi:stopHooks()
	debug.sethook()
end

function ProFi:sortReportsWithSortMethod( reports, sortMethod )
	if reports then
		table.sort( reports, sortMethod )
	end
end

function ProFi:writeReportsToFilename( reports, filename )
	local file, err = io.open( filename, 'w' )
	assert( file, err )
	local header = string.format( FORMAT_HEADER, "FILE", "FUNCTION", "LINE", "TIME", "CALLED" )
	file:write( header )
 	for i, funcReport in ipairs( reports ) do
		local timer         = string.format("%04.3f", funcReport.timer)
		local calledCounter = string.format("%07i", funcReport.calledCounter)
		local outputLine    = string.format(FORMAT_OUTPUT_LINE, funcReport.title, timer, calledCounter )
		file:write( outputLine )
	end
	file:close()
end

-----------------------
-- Local Functions:
-----------------------

onFunctionCalled = function()
	local funcInfo = debug.getinfo( 2, 'nfS' )
	local funcReport = ProFi:getFuncReport( funcInfo )
	funcReport.timer = os.clock()
end

onFunctionReturn = function()
	local funcInfo = debug.getinfo( 2, 'nfS' )
	local funcReport = ProFi:getFuncReport( funcInfo )
	funcReport.timer = os.clock() - funcReport.timer
	funcReport.calledCounter = funcReport.calledCounter + 1
end

sortByDurationDesc = function( a, b )
	return a.timer > b.timer
end

sortByCallCount = function( a, b )
	return a.calledCounter > b.calledCounter
end

-----------------------
-- Return Module:
-----------------------

ProFi:reset()
return ProFi