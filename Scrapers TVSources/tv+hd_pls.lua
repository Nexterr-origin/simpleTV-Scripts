-- скрапер TVS для загрузки плейлиста "TV+ HD" http://www.tvplusonline.ru (21/3/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: tv+hd.lua
-- расширение дополнения httptimeshift: tvhd-timeshift_ext.lua
-- ## переименовать каналы ##
local filter = {
	{'Майдан', 'Майдан (Казань)'},
	{'ОТВ24', 'ОТВ 24 (Екатеринбург)'},
	{'ТНВ Планета', 'ТНВ-Планета (Казань)'},
	{'ТК-КВАНТ', 'ТМ-КВАНТ (Междуреченск)'},
	{'5 канал', 'Пятый канал'},
	{'Москва 24', 'Москва 24 (Москва)'},
	{'Наш дом', '11 канал (Пенза)'},
	{'ТВ3', 'ТВ-3'},
	}
	module('tv+hd_pls', package.seeall)
	local my_src_name = 'TV+ HD'
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\TVplus.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 0, AutoSearch = 1, AutoNumber = 0, NumberM3U = 0, GetSettings = 0, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function showMsg(str, color)
		local t = {text = str, color = color, showTime = 1000 * 5, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local function LoadFromSite()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:86.0) Gecko/20100101 Firefox/86.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly93d3cudHZwbHVzb25saW5lLnJ1L2FwaS9jaGFubmVscw')})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
			 return
			end
		answer = answer:gsub('%[%]', '')
		answer = answer:gsub('\u0', '\\u0')
		require 'json'
		local tab = json.decode(answer)
			if not tab then return end
		local dvr = {}
		rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly93d3cudHZwbHVzb25saW5lLnJ1L3ZlcnNpb250di50eHQ')})
		m_simpleTV.Http.Close(session)
			if rc == 200 then
				dvr = answer:match('dvr,([^%c%s]+)') or ''
				dvr = split(dvr, ';')
			end
			local function catchup(adr)
				for i = 1, #dvr do
					if adr == dvr[i] then
					 return 'catchup="append" catchup-days="1" catchup-source=""'
					end
				end
			 return
			end
		local t = {}
			for i = 1, #tab do
				local title = tab[i].title
				local adr = tab[i].name
				if title and adr then
					t[#t +1] = {}
					t[#t].name = unescape1(title)
					t[#t].RawM3UString = catchup(adr)
					if tab[i].closed == 1 then
						adr = string.format('%s&plus=true', adr)
					end
					t[#t].address = string.format('https://tv+hd.%s', adr)
				end
			end
			if #t == 0 then return end
		local plus = {
				{'ntvp2', 'НТВ (+2)'},
				{'ntvp4', 'НТВ (+4)'},
				{'ntvp6', 'НТВ (+6)'},
				{'perviyp2', 'Первый (+2)'},
				{'perviyp4', 'Первый (+4)'},
				{'perviyp6', 'Первый (+6)'},
				{'renp2', 'РЕН ТВ (+2)'},
				{'renp4', 'РЕН ТВ (+4)'},
				{'renp6', 'РЕН ТВ (+6)'},
				{'russiap2', 'Россия 1 (+2)'},
				{'russiap4', 'Россия 1 (+4)'},
				{'russiap6', 'Россия 1 (+6)'},
				{'stsp2', 'СТС (+2)'},
				{'stsp4', 'СТС (+4)'},
				{'stsp6', 'СТС (+6)'},
				{'tntp2', 'ТНТ (+2)'},
				{'tntp4', 'ТНТ (+4)'},
				{'tntp6', 'ТНТ (+6)'},
				{'tv3p2', 'ТВ-3 (+2)'},
				{'tv3p4', 'ТВ-3 (+4)'},
				{'tv3p6', 'ТВ-3 (+6)'},
				{'karuselp2', 'Карусель (+2)'},
				{'karuselp4', 'Карусель (+4)'},
				{'karuselp6', 'Карусель (+6)'},
				{'centrtv', 'Центральное телевидение'},
				{'fridayp2', 'Пятница! (+2)'},
				{'fridayp4', 'Пятница! (+4)'},
				{'fridayp6', 'Пятница! (+6)'},
				{'stshd', 'СТС HD'},
				{'renhd', 'РЕН ТВ HD'},
				{'russia', 'Россия 1'},
				{'tv3hd', 'ТВ-3 HD'},
				{'bridgetvhd', 'Bridge TV Deluxe'},
				{'perviy', 'Первый'},
				{'fridayhd', 'Пятница! HD'},
			}
			-- for i = 1, #plus do
				-- table.insert(t, {name = plus[i][2], address = string.format('https://tv+hd.%s&plus=true', plus[i][1])})
			-- end
	 return t
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
