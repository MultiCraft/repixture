--[[
Doubly-Linked List

Function documentation:

* rp_mobs.DoublyLinkedList(): Create and return a doubly-linked list (henceforced called "list")
* list:append(data): Append data to the end of the list. data MUST NOT be nil. Returns entry
* list:prepend(data): Add data to the beginning of the list. data MUST NOT be nil. Returns entry
* list:insertBefore(data, previous): Insert data before the entry 'previous'. data MUST NOT be nil. Returns entry
* list:insertAfter(data, nexxt): Insert data after the entry 'nexxt'. data MUST NOT be nil. Returns entry
* list:remove(entry): Removes entry from list
* list:find(data, reverse): Returns the first entry that is equal to data and returns it.
       Returns nil if it does not exist. If `reverse` is `true`, will traverse the list backwards instead
* list:iterator(reverse): Returns a function that will return a new element data each time it is called,
       starting with the first, until it reaches the end of the list where it will return nil.
       If `reverse` is true, will traverse the list in reverse order instead
* list:getFirst(): Returns the first entry or nil if there is none
* list:getLast(): Returns the last entry or nil if there is none
* list:isEmpty(): Returns true if the list is empty
]]


-- Implementation of doubly-linked list

--[[
Internal data structure: list entry:
	entry = {
		nextEntry = , -- reference to next entry or nil
		prevEntry = , -- reference to previous entry or nil
	}

Internal data structure: DoublyLinkedList:
list = {
	first = , -- reference to first entry or nil
	last = , -- reference to last entry or nil

	append, prepend, ... = , -- references to all the functions
}
]]


-- The functions for the doubly-linked list

local append = function(self, data)
	local newEntry = {
		data = data,
	}
	local entry = self.last
	if not entry then
		self.first = newEntry
		self.last = newEntry
	else
		self.last.nextEntry = newEntry
		newEntry.prevEntry = self.last
		self.last = newEntry
	end
	return newEntry
end

local prepend = function(self, data)
	local newEntry = {
		data = data,
	}
	local entry = self.first
	if not entry then
		self.first = newEntry
		self.last = newEntry
	else
		self.first.prevEntry = newEntry
		newEntry.nextEntry = self.first
		self.first = newEntry
	end
	return newEntry
end

local insertAfter = function(self, data, previous)
	local newEntry = {
		data = data,
		prevEntry = previous,
	}
	if previous.nextEntry then
		newEntry.nextEntry = previous.nextEntry
		newEntry.nextEntry.prevEntry = newEntry
		previous.nextEntry = newEntry
	else
		previous.nextEntry = newEntry
		self.last = newEntry
	end
	return newEntry
end
local insertBefore = function(self, data, nexxt)
	local newEntry = {
		data = data,
		nextEntry = nexxt,
	}
	if nexxt.prevEntry then
		newEntry.prevEntry = nexxt.prevEntry
		newEntry.prevEntry.nextEntry = newEntry
		nexxt.prevEntry = newEntry
	else
		nexxt.prevEntry = newEntry
		self.first = newEntry
	end
	return newEntry
end
local remove = function(self, entryToRemove)
	local neighborNext = entryToRemove.nextEntry
	local neighborPrev = entryToRemove.prevEntry
	if neighborNext then
		neighborNext.prevEntry = neighborPrev
	end
	if neighborPrev then
		neighborPrev.nextEntry = neighborNext
	end
	if neighborNext == nil then
		self.last = neighborPrev
	end
	if neighborPrev == nil then
		self.first = neighborNext
	end
end

local find = function(self, dataToFind, inReverse)
	local entry
	if inReverse then
		entry = self.last
	else
		entry = self.first
	end
	while(entry) do
		if entry.data == dataToFind then
			return entry
		end
		if inReverse then
			entry = entry.prevEntry
		else
			entry = entry.nextEntry
		end
	end
end

local iterator = function(self, reverse)
	local elem
	if reverse then
		elem = self.last
	else
		elem = self.first
	end
	return function()
		if elem == nil then
			return
		end
		local ret = elem.data
		if reverse then
			elem = elem.prevEntry
		else
			elem = elem.nextEntry
		end
		return ret
	end
end

local getFirst = function(self)
	if self.first then
		return self.first
	else
		return nil
	end
end

local getLast = function(self)
	if self.last then
		return self.last
	else
		return nil
	end
end

local isEmpty = function(self)
	if not self.first then
		return true
	else
		return false
	end
end

rp_mobs.DoublyLinkedList = function()
	local dllist = {}
	dllist.append = append
	dllist.prepend = prepend
	dllist.insertAfter = insertAfter
	dllist.insertBefore = insertBefore
	dllist.remove = remove
	dllist.find = find
	dllist.iterator = iterator
	dllist.getFirst = getFirst
	dllist.getLast = getLast
	dllist.isEmpty = isEmpty
	dllist.first = nil -- reference to first entry
	dllist.last = nil -- reference to last entry
	return dllist
end

