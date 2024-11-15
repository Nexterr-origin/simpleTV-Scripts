-- скрапер TVS для загрузки плейлиста "Movix" https://movix.ru (15/11/24)
-- Copyright © 2017-2024 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видеоскрипт: movix.lua
-- ## Переименовать каналы ##
local filter = {
		{'НТВ - Телекомпания НТВ', 'НТВ'},
		{'Пятый канал - Петербург - 5 канал', 'Пятый канал'},
		{'Карусель - Детско-юношеский телеканал', 'Карусель'},
		{'ОТР - Телеканал', 'ОТР'},
		{'ТВЦ - ТВ ЦЕНТР - Москва', 'ТВЦ'},
	}
	local host = 'https://movix.ru/'
	local my_src_name = 'Movix'
	module('movix_pls', package.seeall)
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\movix.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 0}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function LoadFromSite()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:129.0) Gecko/20100101 Firefox/129.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local rc, answer = m_simpleTV.Http.Request(session, {url = host})
			if rc ~= 200 then return end
		local token = answer:match('"token":"([^"]+)')
		
		local headers = 'View: stb3\n' ..
						'x-auth-token: ' .. token
		m_simpleTV.Http.SetTimeout(session, 8000)
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly9kaXNjb3Zlcnktc3RiMy5lcnRlbGVjb20ucnUvZXIvYmlsbGluZy9jaGFubmVsX2xpc3QvdXJs'), headers = headers})
			if rc ~= 200 then return end
		
		answer = answer:gsub('\\', '\\\\')
		answer = answer:gsub('\\"', '\\\\"')
		answer = answer:gsub('\\/', '/')
		answer = answer:gsub('%[%]', '""')
		require 'json'
		local err, tab = pcall(json.decode, answer)
			if not tab or not tab.collection then return end
		local t = {}
			for i = 1, #tab.collection do
					local id = tab.collection[i].id
					
					local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly9kaXNjb3Zlcnktc3RiMy5lcnRlbGVjb20ucnUvYXBpL3YzL2NoYW5uZWxz'), headers = headers})
						if rc ~= 200 then return end
					
					answer = answer:gsub('\\', '\\\\')
					answer = answer:gsub('\\"', '\\\\"')
					answer = answer:gsub('\\/', '/')
					answer = answer:gsub('%[%]', '""')
					--require 'json'
					local title = {}
					local url = {}
					local err, tab1 = pcall(json.decode, answer)
						if not tab1 or not tab1.data then return end
						for x = 1, #tab1.data do
							if tab1.data[x].id == id then
								title = tab1.data[x].title
								url = tab1.data[x].urn
							 break
							end
						end
					
					if url and title then
						t[#t + 1] = {}
						t[#t].name = unescape3(title)
						t[#t].address = host .. url
					end
			end
	 return t
	end
	function GetList(UpdateID, m3u_file)
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		local t_tmp = LoadFromSite()
			if not t_tmp or #t_tmp == 0 then return end
		t_pls = ProcessFilterTableLocal(t_tmp)
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')