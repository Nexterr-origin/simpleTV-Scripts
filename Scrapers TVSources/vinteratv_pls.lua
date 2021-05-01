-- скрапер TVS для загрузки плейлиста "Винтера" с сайта http://www.vintera.tv (7/1/19)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: vintera.lua
-- ## переименовать каналы ##
local filter = {
	{'26 Регион', '26 Регион HD (Ставрополь)'},
	{'Липецкое время', 'Липецкое время (Липецк)'},
	{'Матч ТВ (500 кб/с)', 'Матч ТВ'},
	{'НТВ (500 кб/с)', 'НТВ'},
	{'Первый канал (500 кб/с)', 'Первый канал'},
	{'РБК.', 'РБК'},
	{'РЕН ТВ (500 кб/с)', 'РЕН ТВ'},
	{'Россия 1 (500 кб/с)', 'Россия 1'},
	{'Россия 24 (500 кб/с)', 'Россия 24'},
	{'ТНТ (500 кб/с)', 'ТНТ'},
	{'СЕВЕР', 'Север (Нарьян-Мар)'},
	{'Юрган', 'Юрган (Сыктывкар)'},
	{'ЮТВ', 'ЮТВ (Чебоксары)'},
	{'БИМ', 'BIM TV'},
	{'СТВ', 'СвоёТВ (Ставрополь)'},
	{'Немецкая волна', 'Deutsche Welle'},
	{'БОЙЦОВСКИЙ ДУХ', 'Бойцовский дух'},
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
-- ##
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
		local scrap_settings = {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\vinteratv.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 0, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0}}
	 return scrap_settings
	end
	function GetVersion() return 2,'UTF-8' end
	function LoadFromSite()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Linux; Android 5.1.1; Nexus 4 Build/LMY48T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.89 Mobile Safari/537.36')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cDovL3htbC52aW50ZXJhLnR2L2FuZHJvaWRfdjExMTcvaW50ZXJuZXR0di54bWw/bGFuZz1ydSZwcm92dHYueG1sJmxhbmc9cnU=')})
			if rc ~= 200 then m_simpleTV.Http.Close(session) return end
		answer = answer:gsub('&#x(%x%x%x);', function(h) local i = tonumber(h, 16)
		return m_simpleTV.Common.UTF16ToUTF8(string.char(i%256, math.floor(i/256), 0, 0)) end)
		if not m_simpleTV.Common.isUTF8(answer) then
			answer = m_simpleTV.Common.UTF8ToMultiByte(answer)
		end
		local t, i = {}, 1
		local title, adr
			for w in answer:gmatch('<track(.-)</track>') do
				adr = w:match('<location>(.-)</location>')
				title = w:match('<title>(.-)</title>')
					if not adr or not title then break end
				t[i] = {}
				t[i].Id = i
				t[i].name = title
				t[i].address = adr:gsub('&amp;', '&') .. '&tvin'
				i = i + 1
			end
		rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cDovL3htbC52aW50ZXJhLnR2L2FuZHJvaWRfdjA1MTcvcHJlbWl1bS9wYWNrYWdlc19ydS54bWw=')})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return t end
		if not m_simpleTV.Common.isUTF8(answer) then
			answer = m_simpleTV.Common.UTF8ToMultiByte(answer)
		end
		local t2, i = {}, 1
			for w in answer:gmatch('<track>(.-)</track>') do
				adr = w:match('<location>(.-)</location>')
				title = w:match('<title>(.-)</title>')
					if not adr or not title then break end
				t2[i] = {}
				t2[i].Id = i
				t2[i].name = title
				t2[i].address = adr:gsub('amp;', '') .. '&tvin'
				i = i + 1
			end
			for _, v in pairs(t2) do
				if v.address and v.name then
					id = v.address or ''
					if type(t[id]) ~= 'table' then t[id] = {} end
					t[id].address = v.address
					t[id].name = v.name
				end
			end
		local ret, i = {}, 1, 0
			for k, v in pairs(t) do
				ret[i] = v
				i = i + 1
			end
	 return ret
	end
	function GetList(UpdateID, m3u_file)
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		local t_pls = LoadFromSite()
			if not t_pls then m_simpleTV.OSD.ShowMessageT({text = Source.name .. ' -> ошибка загрузки плейлиста', color = 0xffff6600, showTime = 1000 * 5, id = 'channelName'}) return end
		t_pls = ProcessFilterTableLocal(t_pls)
		m_simpleTV.OSD.ShowMessageT({text = Source.name .. ' -> ' .. #t_pls, color = 0xff99ff99, showTime = 1000 * 5, id = 'channelName'})
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return nil end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')