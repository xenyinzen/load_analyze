#!./lua
--------------------------------------------------------
module( ..., package.seeall )

dofile("config.txt")

local version = "0.3"

function print_usage()
	print("|  The usage of datafilter is:")
	print("|")
	print("|\t./datafilter [input_filename.txt] [output_filename.txt]")
	print("|")

end

-------------------------------
-- parameters filter
function param_filter()
        if arg[1] and arg[1] == "-h" then
                print_usage()
                return 0
        end
        if arg[1] and arg[1]:match("%-") then
                print("|  Wrong parameters: filename.txt can't contain the char '-'!")
                print_usage()
                return 0
        end
end

function run( inputfile, outputfile )

        -- filter the parameters
        param_filter()

        local fd = assert(io.open( inputfile, "r" ))
        local content = fd:read("*all")
        fd:close()

        --------------------------------------------------------
        local timesequence = {}
        local timesequence_pattern = "top %- (%d%d:%d%d:%d%d)"
        local tasksequence = {}
        local tasksequence_pattern = "Tasks:%s+(%d+) total"
        local idlesequence = {}
        local idlesequence_pattern = "([%d%.]+)%%id,"
        local memsequence = {}
        local memsequence_pattern = "Mem:%s+%d+k total,%s+(%d+)k used,"
        local process = {}
        -- initialize the process table
        for _, v in ipairs(wanted) do process[v] = {} end

        -----------------------------------------------------------
        local front = 1
        local nextfront = front
        local N = 0
        local piece = ""
        while true do
                if not front then break end

                nextfront, _ = content:find("top - ", nextfront + 1, true)
                if not nextfront then
                        piece = content:sub(front, -1)
                else
                        piece = content:sub(front, nextfront - 1)
                end      
                --------------------------------------------------------
                -- Timesequence
                local l = 0
                while l do
                        _, l, timesequence[#timesequence + 1] = piece:find(timesequence_pattern, l + 1)
                end
                --------------------------------------------------------
                -- Tasks
                local l = 0
                while l do
                        _, l, tasksequence[#tasksequence + 1] = piece:find(tasksequence_pattern, l + 1)
                end
                --------------------------------------------------------
                -- CPU idle
                local l = 0
                while l do
                        _, l, idlesequence[#idlesequence + 1] = piece:find(idlesequence_pattern, l + 1)
                end
                --------------------------------------------------------
                -- Memory occupied
                local l = 0
                while l do
                        _, l, memsequence[#memsequence + 1] = piece:find(memsequence_pattern, l + 1)
                end

                --------------------------------------------------------
                -- Process Data
                --------------------------------------------------------
                for _, pro in ipairs(wanted) do 
                        local l = 0
                        local str = ""
                        
                        -- preprocess on the process name
                        if pro:find(".", 1, true) then
                                str = pro:gsub("%.", "%%%.")
                        elseif pro:find("-", 1, true) then
                                str = pro:gsub("%-", "%%%-")
                        else
                                str = pro
                        end 


                        local pattern = "([%d%.]+)%s+([%d%.]+)%s+[%d:%.]+%s+"..str.."%s+\n"
                        local cpu, mem = 0, 0
                        local shou = {}
                        while true do
                                _, l, cpu, mem = piece:find(pattern, l + 1)
                                if not l then break end
                                shou[#shou + 1] = {
                                        cpu, mem
                                }
                        end

                        local cpu_sum, mem_sum = 0, 0
                        if #shou == 0 then
                                cpu_sum = "Nil"
                                mem_sum = "Nil"
                        else
                                for _, v in ipairs(shou) do
                                        cpu_sum = cpu_sum + v[1]
                                        mem_sum = mem_sum + v[2]
                                end
                        end
                        
                        table.insert(process[pro], { cpu_sum, mem_sum } )
        --		print(pro, #process[pro])

                end
                -----------------------------------------------------------------------------------------
                N = N + 1
                front = nextfront
        end

        --------------------------------------------------------
        --[==[ Print out
        for i, v in ipairs(timesequence) do
                print(i, v)
        end

        print("===================================")

        for i, v in ipairs(tasksequence) do
                print(i, v)
        end

        print("===================================")

        for i, v in ipairs(idlesequence) do
                print(i, v)
        end

        print("===================================")

        for i, v in ipairs(memsequence) do
                print(i, v)
        end

        for t = 1, #wanted do
                print("===================================")
                for i, v in ipairs(process[wanted[t]]) do
                        print(i, unpack(v))
                end

        end
        --]==]

        ----------------------------------------------------------
        -- Write to file
        local fd = assert(io.open(outputfile, "w"))
        local str = table.concat(wanted, "\t")
        fd:write(string.format("Num\tTime\tTasks(n)\tCPU Idle(%%)\tMem Occ(k)\t"..str.."\n"))

        for i = 1, N do
                fd:write(
                        string.format("%d\t%s\t%s\t%s\t%s\t", 
                                i,
                                timesequence[i],
                                tasksequence[i],
                                idlesequence[i],
                                memsequence[i]
                        )
                )
                for _, t in ipairs(wanted) do
                        fd:write( string.format("%s\t", process[t][i][1] ))
                end
                fd:write( string.format("\n") )
        end

        fd:close() 

end
