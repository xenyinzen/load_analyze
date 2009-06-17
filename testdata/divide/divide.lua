
module(..., package.seeall)


---------------------------------------------------------------------------------------------------
-- Splits a string on a delimiter.  Adapted from http://lua-users.org/wiki/SplitJoin.
-- 
-- @param text           the text to be split.
-- @param delimiter      the delimiter.
-- @return               unpacked values.
---------------------------------------------------------------------------------------------------
function split(text, delimiter)
   local list = {}
   local pos = 1
   if string.find("", delimiter, 1) then 
      error("delimiter matches empty string!")
   end
   while 1 do
      local first, last = string.find(text, delimiter, pos)
      if first then -- found?
	 table.insert(list, string.sub(text, pos, first-1))
	 pos = last+1
      else
	 table.insert(list, string.sub(text, pos))
	 break
      end
   end
   return list
end

function run( filename, indir, outdir )
        dofile("config.txt")
        
        local array = {}
        -- local fd = assert(io.open( filename, 'r'))
        for line in io.lines(indir.."/"..filename) do
                array[#array + 1] = split(line, '\t')
        end
        
        local rev_t = {}
        for _, k in ipairs(wanted) do
                for i, key in ipairs(array[1]) do
                        if k == key then rev_t[k] = i end
                end
        end
        
        for i, k in ipairs(wanted) do
                local fd = assert(io.open(outdir.."/"..k.."_"..filename, "w"))
                for _, v in ipairs(array) do
                        if rev_t[k] and v[rev_t[k]] ~= "Nil" then 
                                fd:write( v[rev_t[k]]..'\n' )
                        else
                                fd:write( "0.0\n" ) 
                        end
                end
                fd:close()
        end

end

