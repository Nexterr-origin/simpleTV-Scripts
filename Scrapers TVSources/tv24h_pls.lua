-- скрапер TVS для загрузки плейлиста "24часаТВ" https://24h.tv (6/6/25)
-- Copyright © 2017-2024 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видеоскрипт: tv24h.lua
-- ## Переименовать каналы ##
local filter = {
	--{'Setanta Sports Plus', 'Setanta Sports+'},
	--{'Евроспорт 2', 'Eurosport 2'},
	}
	local my_src_name = '24часаТВ'
	module('tv24h_pls', package.seeall)
	local function ProcessFilterTableLocal(t)
		if not type(t) == 'table' then return end
		for i = 1, #t do
			t[i].name = tvs_core.tvs_clear_double_space(t[i].name)
			for _, ff in ipairs(filter) do
				if (type(ff) == 'table' and t[i].name == ff[1]) then
					t[i].name = ff[2]
				end
			end
		end
	 return t
	end
	function GetSettings()
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\24tv.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 0}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:134.0) Gecko/20100101 Firefox/134.0')
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL0F6YXRob3RoYXMvV29yZGxpc3RzLzM2ZDk1ZjU0MWU5NGJmMmZmNTYyNzIwZjhjZjU0OWQyZjk3MWVjMDMvTWlzYy9Vc2VyLUFnZW50cy91YV9maXJlZm94X3dpbmRvd3NfbGF0ZXN0LnR4dA')})
		if rc ~= 200 or not answer then return end
	answer = answer:gsub('[%c]', '')
	local user_agent = answer
	
	-----
	math.randomseed( os.time() )
	math.random()
	-----
	local function num2bs(num)
		local _mod = math.fmod or math.mod
		local _floor = math.floor
		--
		local result = ""
		if(num == 0) then return "0" end
		while(num  > 0) do
			 result = _mod(num,2) .. result
			 num = _floor(num*0.5)
		end
		return result
	end
	--
	local function bs2num(num)
		local _sub = string.sub
		local index, result = 0, 0
		if(num == "0") then return 0; end
		for p=#num,1,-1 do
			local this_val = _sub( num, p,p )
			if this_val == "1" then
				result = result + ( 2^index )
			end
			index=index+1
		end
		return result
	end
	--
	local function padbits(num,bits)
		if #num == bits then return num end
		if #num > bits then print("too many bits") end
		local pad = bits - #num
		for i=1,pad do
			num = "0" .. num
		end
		return num
	end
	--
	local function getUUID()
		local _rnd = math.random
		local _fmt = string.format
		--
		_rnd()
		--
		local time_low_a = _rnd(0, 65535)
		local time_low_b = _rnd(0, 65535)
		--
		local time_mid = _rnd(0, 65535)
		--
		local time_hi = _rnd(0, 4095 )
		time_hi = padbits( num2bs(time_hi), 12 )
		local time_hi_and_version = bs2num( "0100" .. time_hi )
		--
		local clock_seq_hi_res = _rnd(0,63)
		clock_seq_hi_res = padbits( num2bs(clock_seq_hi_res), 6 )
		clock_seq_hi_res = "10" .. clock_seq_hi_res
		--
		local clock_seq_low = _rnd(0,255)
		clock_seq_low = padbits( num2bs(clock_seq_low), 8 )
		--
		local clock_seq = bs2num(clock_seq_hi_res .. clock_seq_low)
		--
		local node = {}
		for i=1,6 do
			node[i] = _rnd(0,255)
		end
		--
		local guid = ""
		guid = guid .. padbits(_fmt("%X",time_low_a), 4)
		guid = guid .. padbits(_fmt("%X",time_low_b), 4) .. "-"
		guid = guid .. padbits(_fmt("%X",time_mid), 4) .. "-"
		guid = guid .. padbits(_fmt("%X",time_hi_and_version), 4) .. "-"
		guid = guid .. padbits(_fmt("%X",clock_seq), 4) .. "-"
		--
		for i=1,6 do
			guid = guid .. padbits(_fmt("%X",node[i]), 2)
		end
		--
		return guid
	end
	--
	
	local function GetToken(name)
	
		local login = getUUID()
		local pass = string.sub(encode64(login), 0, 32)
		
		local session = m_simpleTV.Http.New(user_agent)
			if not session then return end
			
		m_simpleTV.Http.SetTimeout(session, 8000)
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly8yNGh0di5wbGF0Zm9ybTI0LnR2L3YyL3VzZXJzL3NlbGYvbmV0d29yaw')})
			if rc ~= 200 or not answer then return end
		
		local headers = 'Content-Type: application/json\n'
		local body = '{"username":"' .. login .. '","password":"' .. pass .. '","is_guest":true,"app_version":"v30"}'
		m_simpleTV.Http.SetTimeout(session, 8000)
		local rc, answer = m_simpleTV.Http.Request(session, {method = 'post', url = decode64('aHR0cHM6Ly8yNGh0di5wbGF0Zm9ybTI0LnR2L3YyL3VzZXJz'), body = body, headers = headers})
			if rc ~= 200 or not answer then return end
		
		local body1 = '{"login":"' .. login .. '","password":"' .. pass .. '","app_version":"v30"}'
		m_simpleTV.Http.SetTimeout(session, 8000)
		local rc, answer = m_simpleTV.Http.Request(session, {method = 'post', url = decode64('aHR0cHM6Ly8yNGh0di5wbGF0Zm9ybTI0LnR2L3YyL2F1dGgvbG9naW4'), body = body1, headers = headers})
		local user_token = answer:match('access_token":"([^"]+)')
				if rc ~= 200 or not user_token then return end
				
		local serial = getUUID()

		local body2 = '{"device_type":"pc","vendor":"PC","model":"Firefox 132","version":"166","os_name":"Windows","os_version":"10","application_type":"web","serial":"' .. serial .. '"}'

		local rc, answer = m_simpleTV.Http.Request(session, {method = 'post', url = decode64('aHR0cHM6Ly8yNGh0di5wbGF0Zm9ybTI0LnR2L3YyL3VzZXJzL3NlbGYvZGV2aWNlcz9hY2Nlc3NfdG9rZW49') .. user_token, body = body2, headers = headers})
	
		local device_id = answer:match('id":"([^"]+)')
				if rc ~= 200 or not device_id then return end
		
		local body3 = '{"device_id":"' .. device_id .. '"}'

		local rc, answer = m_simpleTV.Http.Request(session, {method = 'post', url = decode64('aHR0cHM6Ly8yNGh0di5wbGF0Zm9ybTI0LnR2L3YyL2F1dGgvZGV2aWNl'), body = body3, headers = headers})
		local device_token = answer:match('access_token":"([^"]+)')
				if rc ~= 200 or not device_token then return end
		
		local sql_string = 'UPDATE ExtFilter SET PlaylistLoadOptions = \'' .. device_token .. '\' WHERE ExtFilter.Name = \'' .. name .. '\';'
		m_simpleTV.Database.ExecuteSql(sql_string,true)
		
		return device_token
	end

	local function LoadFromSite(source_name)
		
		local sql_str = 'SELECT ExtFilter.PlaylistLoadOptions FROM ExtFilter WHERE ExtFilter.Name = \'' .. source_name .. '\';'
		local x = m_simpleTV.Database.GetTable(sql_str,true)
		local access_token
		if x == nil or #x == 0 then 
			access_token = GetToken(source_name)
		end
		for i,w in pairs(x) do  
			for r,e in pairs(w) do
				if e == nil or e == '' then
					access_token = GetToken(source_name)
				else
					access_token = e
				end
			end
		end
		
		if not access_token then return end
		
		local function GetChannels(access_token)
			local url = decode64('aHR0cHM6Ly8yNGh0di5wbGF0Zm9ybTI0LnR2L3YyL2NoYW5uZWxzL2NoYW5uZWxfbGlzdD9hY2Nlc3NfdG9rZW49')
			local session = m_simpleTV.Http.New(user_agent)
			m_simpleTV.Http.SetTimeout(session, 8000)
			local rc, answer
			rc, answer = m_simpleTV.Http.Request(session, {url = url .. access_token})
			if rc == 401 then access_token = GetToken(source_name)
				rc, answer = m_simpleTV.Http.Request(session, {url = url .. access_token})
					if rc ~= 200 then return end
			end
			return answer
		end
		
		local answer = GetChannels(access_token)
			if not answer then return end
		
		answer = answer:gsub('\\', '\\\\')
		answer = answer:gsub('\\"', '\\\\"')
		answer = answer:gsub('\\/', '/')
		answer = answer:gsub('%[%]', '""')
		require 'json'
		local err, tab = pcall(json.decode, answer)
			if not tab then return end
		
		local t = {}
			for i = 1, #tab do
				if tab[i].is_free then
					local slug = tab[i].slug
					local id = tab[i].id
					local title = tab[i].name
					if slug and id and title then
						t[#t + 1] = {}
						t[#t].name = unescape3(title)
						t[#t].address = 'https://tv24h/channels/' .. slug .. '/' .. id
						t[#t].RawM3UString = string.format('catchup="append" catchup-days="%s" catchup-source=""', (tab[i].archived_days or 0))
						t[#t].logo = tab[i].cover.full or ''
					end
				end
			end
	 return t
	end
	function GetList(UpdateID, m3u_file)
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		local t_pls = LoadFromSite(Source.name)
			if not t_pls or #t_pls == 0 then return end
		t_pls = ProcessFilterTableLocal(t_pls)
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(token .. '\n', "D:\xxx.txt")
