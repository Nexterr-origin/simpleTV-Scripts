-- скрапер TVS для загрузки плейлиста "LimeHD" https://limehd.tv (4/1/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: limeHD.lua
-- расширение дополнения httptimeshift: limehd-timeshift_ext.lua
-- ## переименовать каналы ##
local filter = {
	{'Солнечногорск ТВ', 'Солнечногорск ТВ (Солнечногорск)'},
	{'Миллет (Крым)', 'Миллет (Симферополь)'},
	{'360° Новости', '360 Новости (Москва)'},
	{'47 канал (Санкт-Петербург)', 'Лен ТВ 24 (Санкт-Петербург)'},
	{'Bridge TV Russian Hit', 'BRIDGE TV Русский Хит'},
	{'O2TV', 'О2ТВ'},
	{'rodnoe', 'Родное кино'},
	{'Аист ТВ (Иркутск)', 'АИСТ (Иркутск)'},
	{'БИМ ТВ', 'BIM TV'},
	{'БСТ (Уфа)', 'БСТ (Челябинск)'},
	{'Вся Уфа', 'Вся Уфа (Уфа)'},
	{'Губерния 33 (Владимир)', 'Губерния-33 (Владимир)'},
	{'Губерния Самарская', 'Губерния (Самара)'},
	{'Губерния ТВ (Воронеж)', 'ТВ-Губерния (Воронеж)'},
	{'Дагестан', 'Дагестан (Махачкала)'},
	{'Дорама', 'Dorama'},
	{'ЗабТВ (Чита)', 'Заб.TV (Чита)'},
	{'ИКС-ТВ (Крым)', 'ИКС (Севастополь)'},
	{'Ингушетия', 'Ингушетия (Магас)'},
	{'Каскад24 (Калининград)', 'Каскад 24 (Калининград)'},
	{'Катунь-24 (Барнаул)', 'Катунь 24 (Барнаул)'},
	{'Краснодар он-лайн', 'Краснодар он-лайн (Краснодар)'},
	{'Крик ТВ', 'Крик ТВ (Екатеринбург)'},
	{'ЛДПР LIVE', 'ЛДПР ТВ'},
	{'Липецкое время', 'Липецкое время (Липецк)'},
	{'Луч (ЯНАО)', 'Луч (Тарко-Сале)'},
	{'Метео ТВ', 'Первый Метео'},
	{'Мордовия 24', 'Мордовия 24 (Саранск)'},
	{'ОРТ-Планета (Оренбург)', 'ОРТ Планета (Оренбург)'},
	{'ОТВ Екатеринбург', 'ОТВ (Екатеринбург)'},
	{'ОТС Новосибирск', 'ОТС (Новосибирск)'},
	{'Осетия Ирыстон (Владикавказ)', 'Осетия-Ирыстон (Владикавказ)'},
	{'Первый Волгоградский', 'Первый Волгоградский канал/МТВ (Волгоград)'},
	{'Первый Крымский', 'Первый Крымский (Симферополь)'},
	{'Первый студенческий канал', 'UniverTV'},
	{'Приморье', 'ОТВ (Приморье)'},
	{'Русский Хит', 'Bridge TV Русский хит'},
	{'Рыбинск-40', 'Рыбинск-40 (Рыбинск)'},
	{'ТВ Тур', 'ТВТУР'},
	{'ТКР Рязань', 'ТКР (Рязань)'},
	{'ТНВ Планета', 'ТНВ-Планета (Казань)'},
	{'ТНВ Татарстан', 'ТНВ-Татарстан (Казань)'},
	{'Тонус ТВ', 'Здоровье'},
	{'Тонус', 'Здоровье'},
	{'Фреш тв', 'FreshTV'},
	{'Чăваш Ен (Чувашия)', 'Чaваш Ен (Чебоксары)'},
	{'ЮТВ (Чувашия)', 'ЮТВ (Чебоксары)'},
	{'Юрган ТВ (Сыктывкар)', 'Юрган (Сыктывкар)'},
	}
-- ##
	module('limeHD_pls', package.seeall)
	local my_src_name = 'LimeHD'
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
		local scrap_settings = {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\LimeHD.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 0, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0}}
	 return scrap_settings
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function LoadFromSite()
		local session = m_simpleTV.Http.New(decode64('eyJwbGF0Zm9ybSI6ImFuZHJvaWQiLCJhcHAiOiJjb20uaW5mb2xpbmsubGltZWlwdHYiLCJ2ZXJzaW9uX25hbWUiOiIzLjMuMyIsInZlcnNpb25fY29kZSI6IjI1NiIsInNkayI6IjI5IiwibmFtZSI6InNka19waG9uZV94ODZfNjQrQW5kcm9pZCBTREsgYnVpbHQgZm9yIHg4Nl82NCIsImRldmljZV9pZCI6IjAwMEEwMDBBMDAwQTAwMEEifQ'))
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 12000)
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly9wbC5pcHR2MjAyMS5jb20vYXBpL3YxL3BsYXlsaXN0') .. '?t=' .. os.time(), method = 'post', body = '"tz":"3"', headers = 'X-Token:'})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
			if not answer:match('^{') then return end
		answer = answer:gsub('%[%]', '""')
		require 'json'
		local tab = json.decode(answer)
			if not tab
				or not tab.channels
			then
			 return
			end
		local t, i = {}, 1
		local j = 1
			while tab.channels[j] do
				if tab.channels[j].url
					and tab.channels[j].url ~= ''
				then
					t[i] = {}
					t[i].name = tab.channels[j].name_ru
					t[i].address = 'https://infolink/' .. tab.channels[j].id
					-- t[i].logo = tab.channels[j].image
					if tab.channels[j].with_archive == true
						and tab.channels[j].url_archive
						and tab.channels[j].url_archive ~= ''
						and tab.channels[j].day_archive
						and tab.channels[j].day_archive > 0
					then
						t[i].RawM3UString = 'catchup="append" catchup-days="' .. tab.channels[j].day_archive .. '" catchup-source=""'
					end
					i = i + 1
				end
				j = j + 1
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
