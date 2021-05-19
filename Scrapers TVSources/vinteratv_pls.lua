-- скрапер TVS для загрузки плейлиста "Винтера" http://www.vintera.tv (19/5/21)
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\vinteratv.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 0, AutoSearch = 1, AutoNumber = 0, NumberM3U = 0, GetSettings = 0, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function showMsg(str, color)
		local t = {text = str, color = color, showTime = 1000 * 10, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	function LoadFromSite()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Linux; Android 5.1.1; Nexus 4 Build/LMY48T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.89 Mobile Safari/537.36')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		htmlEntities = require 'htmlEntities'
		local urlsTab ={'aHR0cDovL3htbC52aW50ZXJhLnR2L2FuZHJvaWRfdjExMTcvcHJvdnR2LnhtbD9sYW5nPXJ1', 'aHR0cDovL3htbC52aW50ZXJhLnR2L2FuZHJvaWRfdjExMTcvcHJlbWl1bS9wYWNrYWdlc19ydS54bWw', 'aHR0cDovL3htbC52aW50ZXJhLnR2L2FuZHJvaWRfdjExMTcvaW50ZXJuZXR0di54bWw/bGFuZz1ydXM'}
		local t = {}
			for i = 1, #urlsTab do
				local rc, answer = m_simpleTV.Http.Request(session, {url = decode64(urlsTab[i])})
				if rc == 200 then
					for w in answer:gmatch('<track(.-)</track>') do
						local adr = w:match('<location>([^<]+)')
						local title = w:match('<title>([^<]+)')
							if adr and adr:match('%.m3u8') and title then
								t[#t + 1] = {}
								t[#t].name = htmlEntities.decode(title)
								t[#t].address = adr:gsub('&amp;', '&') .. '&tvin'
							end
					end
				end
			end
		local hash, t0 = {}, {}
			for _, v in ipairs(t) do
				if not hash[v.address] then
					t0[#t0 + 1] = v
					hash[v.address] = true
				end
			end
	 return t0
	end
	function GetList(UpdateID, m3u_file)
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		local t_pls = LoadFromSite()
			if not t_pls then
				showMsg(Source.name .. ' ошибка загрузки плейлиста', ARGB(255, 255, 102, 0))
			 return
			end
		t_pls = ProcessFilterTableLocal(t_pls)
		showMsg(Source.name .. ' (' .. #t_pls .. ')', ARGB(255, 153, 255, 153))
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')
