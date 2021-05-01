-- скрапер TVS для загрузки плейлиста "spb" https://tv.spbtv.com + https://ru.spbtv.com (7/3/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: spb.lua
-- ## переименовать каналы ##
local filter = {
	{'12 канал', '12 канал (Омск)'},
	{'Архыз 24', 'Архыз 24 (Черкесск)'},
	{'Барс+', 'Барс плюс (Иваново)'},
	{'Беларусь24', 'Беларусь 24'},
	{'Дон24', 'Дон 24 (Ростов-на-Дону)'},
	{'Мир-ТВ', 'МИР'},
	{'Настоящее страшное кино', 'Настоящее страшное ТВ'},
	{'ОТВ', 'ОТВ (Челябинск)'},
	{'ТВ-ПЕНЗА', 'ТВ-Пенза (Пенза)'},
	{'ШАДР-инфо', 'Шадр-Инфо (Шадринск)'},
	{'Fine Living HD', 'Fine Living Network'},
	{'Север', 'Север (Нарьян-Мар)'},
	{'ОТВ 24', 'ОТВ 24 (Екатеринбург)'},
	{'ЛенТВ24', 'Лен ТВ 24 (Санкт-Петербург)'},
	{'Планета', 'Планета (spb)'},
	{'Боевик', 'Боевик (spb)'},
	{'Ретро', 'Ретро (spb)'},
	{'Мультик', 'Мультик (spb)'},
	{'Детектив', 'Детектив (spb)'},
	{'Романтика', 'Романтика (spb)'},
	{'Военный', 'Военный (spb)'},
	{'Сидим дома', 'Сидим дома (spb)'},
	}
-- ##
	module('spb_pls', package.seeall)
	local my_src_name = 'spb'
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\spb.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 0, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2,'UTF-8'
	end
	local function showMsg(str, color)
		local t = {text = str, color = color, showTime = 1000 * 5, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local function LoadFromSite()
		require 'json'
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.3785.143 Safari/537.36')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local client_id = '66797942-ff54-46cb-a109-3bae7c855370'
			local function correctName(str)
				str = str:gsub('Теледом', 'ТелеДом')
				str = str:gsub('ТВ3', 'ТВ 3')
				str = str:gsub('GLOBAL STAR TV', 'Global Star TV')
				str = str:gsub('Пятница!', 'Пятница')
				str = str:gsub('МИР', 'Мир')
				str = str:gsub('МУЗ ТВ', 'Муз ТВ')
				str = str:gsub('о2тв', 'О2ТВ')
				str = str:gsub('ТНТ MUSIC', 'ТНТ Music')
				str = str:gsub('о2тв', 'О2ТВ')
				str = str:gsub('RTDoc', 'RT Doc')
				str = str:gsub('Культура', 'Россия К')
			 return str
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
			local function GetTab(api)
				local url = api .. '/channels?locale=ru-RU&client_version=0.0.1-5462&timezone=10800&page[limit]=500&page[offset]=0&expand[channel]=live_stream,catchup_availability&client_id=' .. client_id
				local rc, answer = m_simpleTV.Http.Request(session, {url = url})
					if rc ~= 200 then return end
				answer = answer:gsub('%[%]', '""')
				local tab = json.decode(answer)
					if not tab or not tab.data then return end
				local t, i = {}, 1
				local j = 1
				api = encode64(api)
					while tab.data[j] do
						if tab.data[j].free == true then
							t[i] = {}
							if tab.data[j].catchup_availability
								and tab.data[j].catchup_availability.available
								and tab.data[j].catchup_availability.available == true
							then
								local period = tab.data[j].catchup_availability.period.value
								if tab.data[j].catchup_availability.period.unit == 'hours' then
									period = period * 60
									t[i].RawM3UString = 'catchup="append" catchup-minutes="' .. period
											.. '" catchup-source="?stream_start_offset=${offset}000000"'
								else
									t[i].RawM3UString = 'catchup="append" catchup-days="' .. period
													.. '" catchup-source="?stream_start_offset=${offset}000000"'
								end
							end
							t[i].name = correctName(tab.data[j].name)
							t[i].address = 'https://ru.spbtv.com/' .. api .. '/' .. tab.data[j].id
							i = i + 1
						end
						j = j + 1
					end
				 return t
			end
		local api1 = 'https://api.spbtv.com/v1'
		local api2 = 'https://api-tv.spbtv.com/v1'
		local tab1 = GetTab(api1) or {}
		local tab2 = GetTab(api2) or {}
		local tab = tables_concat(tab1, tab2)
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
			if not t_pls then
				showMsg(Source.name .. ' ошибка загрузки плейлиста', ARGB(255, 255, 102, 0))
			 return
			end
		showMsg(Source.name .. ' (' .. #t_pls .. ')', ARGB(255, 153, 255, 153))
		t_pls = ProcessFilterTableLocal(t_pls)
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')