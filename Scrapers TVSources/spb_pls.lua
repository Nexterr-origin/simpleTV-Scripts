-- скрапер TVS для загрузки плейлиста "spb" https://ru.spbtv.com (31/7/24)
-- Copyright © 2017-2024 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
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
	local function LoadFromSite()
		require 'json'
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:129.0) Gecko/20100101 Firefox/129.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local url = 'https://api.spbtv.com/v1/channels?locale=ru-RU&client_version=0.0.1-5462&timezone=10800&page[limit]=500&page[offset]=0&expand[channel]=live_stream,catchup_availability&client_id=3e28685c-fce0-4994-9d3a-1dad2776e16a'
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
			if rc ~= 200 then return end
		m_simpleTV.Http.Close(session)
		answer = answer:gsub('%[%]', '""')
		local tab = json.decode(answer)
			if not tab or not tab.data then return end
		local t= {}
			for i = 1, #tab.data do
				t[#t + 1] = {}
				t[#t].name = tab.data[i].name
				t[#t].address = 'https://ru.spbtv.com/' .. tab.data[i].id
				if tab.data[i].catchup_availability
					and tab.data[i].catchup_availability.available
					and tab.data[i].catchup_availability.available == true
				then
					local period = tab.data[i].catchup_availability.period.value
					t[#t].RawM3UString = 'catchup="append" catchup-days="' .. period
													.. '" catchup-source="?stream_start_offset=${offset}000000"'
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
