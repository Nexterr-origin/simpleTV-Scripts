-- скрапер TVS для загрузки плейлиста "Yandex" https://tv.yandex.ru (23/10/20)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: yandex.lua
-- расширение дополнения httptimeshift: yandex-timesift_ext.lua
-- ## глубина архива для всех каналов (в днях) ##
local arhiv = 7
-- 0 - по умолчанию
-- ## переименовать каналы ##
local filter = {
	{'1 HD Music Television', '1HD'},
	{'26 регион', '26 Регион HD (Ставрополь)'},
	{'360° Новости', '360 Новости (Москва)'},
	{'360°', '360 Подмосковье (Москва)'},
	{'8 канал - Красноярский край', '8 Канал (Красноярск)'},
	{'8-ой Канал Красноярск', '8 Канал (Красноярск)'},
	{'Global Star TV', 'Global Star TV HD'},
	{'HD Медиа', 'HD Media'},
	{'HITV', 'HITV HD'},
	{'HardLife TV', 'HardLife TV HD'},
	{'RT Doc', 'RTД HD'},
	{'RT', 'Russia Today HD'},
	{'RTVI (Онлайн-вещание)', 'RTVi'},
	{'RUTV', 'RU TV HD'},
	{'TV Губерния', 'TV Губерния (Воронеж)'},
	{'UTV', 'UTV (Уфа)'},
	{'Univer TV', 'Univer TV HD'},
	{'World Fashion Channel', 'World Fashion Channel HD'},
	{'Арктика 24', 'Арктика 24 (Ноябрьск)'},
	{'Архыз 24', 'Архыз 24 (Черкесск)'},
	{'Афонтово', 'Афонтово (Красноярск)'},
	{'Барс', 'Барс (Иваново)'},
	{'Большая Азия', 'Большая Азия HD'},
	{'Ветта', 'Ветта 24 (Пермь)'},
	{'Волга', 'Волга (Нижний Новгород)'},
	{'Волгоград 1', 'Волгоград 1 (Волгоград)'},
	{'Вся Уфа', 'Вся Уфа (Уфа)'},
	{'Губерния', 'Губерния ТВ (Хабаровск)'},
	{'Дагестан', 'Дагестан (Махачкала)'},
	{'Дождь', 'Дождь HD'},
	{'Евразия', 'Евразия (Орск)'},
	{'Екатеринбург-ТВ', 'Екатеринбург-ТВ (Екатеринбург)'},
	{'Загородный', 'Загородный Int'},
	{'Известия', 'Известия HD'},
	{'Инфо24', 'ИНФО 24 HD (Шадринск)'},
	{'Катунь 24', 'Катунь 24 (Барнаул)'},
	{'Классика кино', 'Классика кино HD'},
	{'Кубань 24', 'Кубань 24 Орбита (Краснодар)'},
	{'Курай', 'Курай (Уфа)'},
	{'Липецкое время', 'Липецкое время (Липецк)'},
	{'МАТЧ!', 'Матч ТВ HD'},
	{'Мотоспорт ТВ', 'Моторспорт ТВ'},
	{'НВК Саха', 'Саха (Якутск)'},
	{'Наш дом', '11 канал (Пенза)'},
	{'Наша Сибирь', 'Наша Сибирь HD'},
	{'Неизвестная планета', 'Неизвестная планета HD'},
	{'О, Кино!', 'О!КИНО'},
	{'О2ТВ', 'О2ТВ HD'},
	{'ОТВ 24', 'ОТВ 24 (Екатеринбург)'},
	{'ОТВ', 'ОТВ (Челябинск)'},
	{'Осетия-Ирыстон', 'Осетия-Ирыстон (Владикавказ)'},
	{'Охотник и Рыболов', 'Охотник и рыболов HD'},
	{'Первый тульский', 'Первый Тульский (Тула)'},
	{'Первый', 'Первый канал HD'},
	{'Пятый канал', 'Пятый канал HD'},
	{'РАЗ', 'РазТВ'},
	{'РТС - Абакан', 'РТС - Абакан (Абакан)'},
	{'Ратник', 'Ратник HD'},
	{'Рифей-ТВ', 'Рифей-ТВ (Пермь)'},
	{'Россия 24', 'Россия 24 HD'},
	{'Ростов-папа', 'Ростов-папа (Ростов)'},
	{'Русский Север', 'Русский Север (Вологда)'},
	{'Рыбинск-40', 'Рыбинск-40 (Рыбинск)'},
	{'Самара 24', 'Самара 24 (Самара)'},
	{'Своё ТВ', 'Своё ТВ (Ставрополь)'},
	{'СвоёТВ', 'СВОЁТВ (Ставрополь)'},
	{'Старт', 'Старт HD'},
	{'Сургут 24', 'Сургут 24 (Сургут)'},
	{'ТВ БРИКС', 'TV BRICS'},
	{'ТВ Центр Красноярск HD', 'Центр Красноярск (Красноярск)'},
	{'ТВ-21+', 'ТВ21+ (Мурманск)'},
	{'ТВ-3', 'ТВ 3 HD'},
	{'ТК Центр Красноярск HD', 'Центр Красноярск (Красноярск)'},
	{'ТНТ', 'ТНТ HD'},
	{'Тагил-ТВ', 'Тагил-ТВ (Нижний Тагил)'},
	{'Татарстан - 24', 'Татарстан-24 (Казань)'},
	{'Тверской проспект - Регион', 'Тверской Проспект (Тверь)'},
	{'Телеканал 86', '86 Канал (Сургут)'},
	{'Телеканал Осетия-Ирыстон', 'Осетия-Ирыстон (Владикавказ)'},
	{'ТиВиСи HD', 'ТиВиСи HD (Иркутск)'},
	{'Удмуртия', 'Моя Удмуртия (Ижевск)'},
	{'Футбол', 'Футбол HD'},
	{'ЦТВ', 'Центральное телевидение'},
	{'ШАДР-инфо', 'Шадр-Инфо (Шадринск)'},
	{'Эфир', 'Эфир (Казань)'},
	{'Югра', 'Югра (Тюмень)'},
	{'Юрган', 'Юрган (Сыктывкар)'},
	{'Якутия 24', 'Якутия 24 (Якутск)'},
	}
-- ##
	module('yandex_pls', package.seeall)
	local my_src_name = 'Yandex'
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\yandex.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 0, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function LoadFromSite(url)
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:82.0) Gecko/20100101 Firefox/82.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 12000)
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly95YW5kZXgucnUvcG9ydGFsL3R2c3RyZWFtX2pzb24vY2hhbm5lbHM/c3RyZWFtX29wdGlvbnM9aGlyZXMmbG9jYWxlPXJ1JmZyb209bW9yZGE')})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		answer = answer:gsub('%[%]', '""')
		require 'json'
		local tab = json.decode(answer)
			if not tab or not tab.set then return end
		local t, i = {}, 1
		local k2
			while tab.set[i] do
				t[i] = {}
				t[i].name = tab.set[i].title
				t[i].address = tab.set[i].content_url
				t[i].special = tab.set[i].is_special_project
				t[i].channel_type = tab.set[i].channel_type or ''
				t[i].ya_plus = tab.set[i].ya_plus
				t[i].hidden = tab.set[i].hidden or ''
				if arhiv == 0 then
					t[i].catchup_age = tab.set[i].catchup_age or 0
				else
					t[i].catchup_age = 3600 * 24 * arhiv
				end
				k2 = 1
					while true do
							if not tab.set[i].status or not tab.set[i].status[k2] then break end
							if tab.set[i].status[k2] == 'hidden' then
								t[i].status = true
							 break
							end
						k2 = k2 + 1
					end
				if tab.set[i].channel_category
					and tab.set[i].channel_category[1] == 'yandex'
				then
					t[i].channel_category = true
				end
				i = i + 1
			end
			if #t == 0 then return end
		local t0, j = {}, 1
			for _, v in pairs(t) do
				if not (v.status == true
					or v.ya_plus
					or v.channel_category == true
					or v.special == true
					or v.hidden == '1'
					or v.channel_type:match('^yatv')
					or v.address:match('/non__fake/')
					or v.address:match('/kal/weather_')
					or v.address:match('/ya_chan_tv'))
					and v.address:match('^https?:')
				then
					v.RawM3UString = 'catchup="append" catchup-minutes="' .. (v.catchup_age / 60)
										.. '" catchup-source="?start=${start}"'
										.. ' catchup-record-source="?start=${start}&end=${end}"'
					v.address = v.address:gsub('^([^:]+://[^/]+/[^/]+/[^/]+).-(/[^/]+%.%w+).-$', '%1%2')
					t0[j] = v
					j = j + 1
				end
			end
			if j == 1 then return end
	 return t0
	end
	function GetList(UpdateID, m3u_file)
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		local t_pls = LoadFromSite()
			if not t_pls then
				m_simpleTV.OSD.ShowMessageT({text = Source.name .. ' - ошибка загрузки плейлиста'
											, color = 0xffff6600
											, showTime = 1000 * 5
											, id = 'channelName'})
			 return
			end
		m_simpleTV.OSD.ShowMessageT({text = Source.name .. ' (' .. #t_pls .. ')'
									, color = 0xff99ff99
									, showTime = 1000 * 5
									, id = 'channelName'})
		t_pls = ProcessFilterTableLocal(t_pls)
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')