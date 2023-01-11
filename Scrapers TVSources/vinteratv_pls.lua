-- скрапер TVS для загрузки плейлиста "Винтера" https://vintera.tv (11/1/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: mediavitrina.lua, vinteratv.lua
-- ## переименовать каналы ##
local filter = {
	{'26 Регион', '26 Регион HD (Ставрополь)'},
	{'Липецкое время', 'Липецкое время (Липецк)'},
	{'РБК.', 'РБК'},
	{'ТНТ (500 кб/с)', 'ТНТ'},
	{'СЕВЕР', 'Север (Нарьян-Мар)'},
	{'Юрган', 'Юрган (Сыктывкар)'},
	{'ЮТВ', 'ЮТВ (Чебоксары)'},
	{'БИМ', 'BIM TV'},
	{'СТВ', 'СвоёТВ (Ставрополь)'},
	{'Немецкая волна', 'Deutsche Welle'},
	{'АТВ-Ставрополь', 'АТВ-Ставрополь (Ставрополь)'},
	{'Ю.', 'Ю'},
	{'МТВ', 'МТВ (Волгоград)'},
	{'Беларусь24', 'Беларусь 24'},
	{'АСВ ТВ', 'ACB TV'},
	{'2x2.', '2x2'},
	{'Первый Тульский', 'Первый Тульский (Тула)'},
	{'ОТВ', 'ОТВ (Екатеринбург)'},
	{'Нано HD', 'Nano HD'},
	{'МТВ (Волгоград)', 'Первый Волгоградский канал/МТВ (Волгоград)'},
	{'FOODMAN club', 'Foodman.club'},
	{'Губерния', 'Губерния ТВ (Хабаровск)'},
	{'Дагестан', 'Дагестан (Махачкала)'},
	{'Ростов-ПАПА', 'Ростов-папа (Ростов)'},
	{'Тагил ТВ', 'Тагил-ТВ (Тагил)'},
	{'Телеканал 86', '86 Канал (Сургут)'},
	{'Телеканал С-1', 'С1 (Сургут)'},
	{'Психология ТВ', 'Психология 21'},
	}
	module('vinteratv_pls', package.seeall)
	local my_src_name = 'Винтера'
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\vinteratv.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, show_progress = 0, RefreshButton = 1, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 0, AutoSearch = 1, AutoNumber = 0, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1, TypeFindUseGr = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function LoadFromSite()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		require 'json'
			local function GetTab(url)
				url = decode64(url)
				local rc, answer = m_simpleTV.Http.Request(session, {url = url})
					if rc ~= 200 then return end
				answer = answer:gsub('\\', '\\\\')
				answer = answer:gsub('\\"', '\\\\"')
				answer = answer:gsub('\\/', '/')
				answer = answer:gsub('%[%]', '""')
				answer = unescape3(answer)
				local err, tab = pcall(json.decode, answer)
				local t = {}
				if url:match('premium') then
						if not tab
							or not tab.package
						then
						 return
						end
					local j = 1
						while tab.package[j] do
							local i = 1
								while tab.package[j].trackList.track[i] do
							t[#t + 1] = {}
							t[#t].name = tab.package[j].trackList.track[i].title
							t[#t].address = 'https://www.vinteratv.com/?channel=' .. tab.package[j].trackList.track[i].id
							t[#t].logo = tab.package[j].trackList.track[i].image
							i = i + 1
						end
						j = j + 1
					end
				else
						if not tab
							or not tab.trackList
							or not tab.trackList.track
						then
						 return
						end
					local i = 1
						while tab.trackList.track[i] do
							t[#t + 1] = {}
							t[#t].name = tab.trackList.track[i].title
							t[#t].address = 'https://www.vinteratv.com/?channel=' ..tab.trackList.track[i].id
							t[#t].logo = tab.trackList.track[i].image
							i = i + 1
						end
					end
			 return t
			end
			local function tables_concat(t1, t2)
				local t3 = {unpack(t1)}
				local p = #t3
					for i = 1, #t2 do
						p = p + 1
						t3[p] = t2[i]
					end
			 return t3
			end
		local tab1 = GetTab('aHR0cHM6Ly94bWwudmludGVyYS50di93aWRnZXRfYXBpL2ludGVybmV0dHYueG1sP2Zvcm1hdD1qc29uJmxhbmc9cnU') or {}
		local tab2 = GetTab('aHR0cHM6Ly94bWwudmludGVyYS50di93aWRnZXRfYXBpL3Byb3Z0di54bWw/Zm9ybWF0PWpzb24mbGFuZz1ydQ') or {}
		local tab3 = GetTab('aHR0cHM6Ly94bWwudmludGVyYS50di93aWRnZXRfYXBpL3ByZW1pdW0vcGFja2FnZXNfcnUueG1sP2Zvcm1hdD1qc29uJmxhbmc9cnU') or {}
		local tab = tables_concat(tab1, tab2)
		tab = tables_concat(tab, tab3)
		m_simpleTV.Http.Close(session)
			if #tab == 0 then return end
		local hash, t = {}, {}
			for _, v in ipairs(tab) do
				if not hash[v.name] then
					t[#t + 1] = v
					hash[v.name] = true
				end
			end
	 return t
	end
	function GetList(UpdateID, m3u_file)
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		local t_pls = LoadFromSite()
			if not t_pls or #t_pls == 0 then return end
		t_pls = ProcessFilterTableLocal(t_pls)
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')
