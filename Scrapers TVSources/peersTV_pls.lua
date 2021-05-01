-- скрапер TVS для загрузки плейлиста "PeersTV" http://peers.tv (23/3/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: peersTV.lua
-- расширение дополнения httptimeshift: peerstv-timeshift_ext.lua
-- ## переименовать каналы ##
local filter = {
	{'360', '360 Подмосковье (Москва)'},
	{'8 канал Красноярский край', '8 канал (Красноярск)'},
	{'86', '86 Канал (Сургут)'},
	{'Brazzers TV Europe (18+)', 'Brazzers TV Europe'},
	{'Erox (18+)', 'Erox HD'},
	{'FastNFunBOX', 'Fast&FunBox'},
	{'Travel Adventure', 'Travel+ Adventure'},
	{'a2', 'A2'},
	{'blue HUSTLER (18+)', 'Blue Hustler'},
	{'Алмазный край', 'Алмазный край (Якутск)'},
	{'Альтес', 'Альтес (Чита)'},
	{'Арктика 24', 'Арктика 24 (Ноябрьск)'},
	{'Барс плюс', 'Барс плюс (Иваново)'},
	{'Вся Уфа', 'Вся Уфа (Уфа)'},
	{'ЗабТВ', 'Заб.TV (Чита)'},
	{'Катунь 24', 'Катунь 24 (Барнаул)'},
	{'Кино 24', 'KINO 24'},
	{'Липецкое время', 'Липецкое время (Липецк)'},
	{'Муз ТВ', 'МУЗ-ТВ'},
	{'НАШ ДОМ', '11 канал (Пенза)'},
	{'НВК САХА', 'Саха (Якутск)'},
	{'НТВ-Право', 'НТВ Право'},
	{'НТВ-Сериал', 'НТВ Сериал'},
	{'НТВ-Стиль', 'НТВ Стиль'},
	{'НТВ-Хит', 'НТВ Хит'},
	{'НТН24', 'НТН24 (Новосибирск)'},
	{'Нижний Новгород 24', 'Нижний Новгород 24 (Нижний Новгород)'},
	{'ОРТРК-12 КАНАЛ', '12 канал (Омск)'},
	{'ОТС [HD]', 'ОТС (Новосибирск)'},
	{'Петербург-5 канал', 'Пятый канал'},
	{'Салям', 'Салям (Уфа)'},
	{'ТВ Центр Красноярск', 'Центр Красноярск (Красноярск)'},
	{'ТИВИКОМ', 'Тивиком (Улан-Удэ)'},
	{'ТК Центр Красноярск HD', 'Центр Красноярск (Красноярск)'},
	{'Тайны Галактики', 'Galaxy'},
	{'ТиВиСи', 'ТиВиСи HD (Иркутск)'},
	{'Фест-ТВ', '1HD'},
	{'ШАДР-инфо', 'Шадр-Инфо (Шадринск)'},
	{'Эфир-Казань', 'Эфир (Казань)'},
	{'ЮТВ', 'Ю'},
	{'Юрган', 'Юрган (Сыктывкар)'},
	{'Якутия 24', 'Якутия 24 (Якутск)'},
	}
-- ##
	module('peersTV_pls', package.seeall)
	local my_src_name = 'PeersTV'
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\peerstv.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 0, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function trim(s)
	 return (s:gsub("^%s*(.-)%s*$", "%1"))
	end
	local function showMsg(str, color)
		local t = {text = str, color = color, showTime = 1000 * 5, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local function LoadFromSite()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:81.0) Gecko/20100101 Firefox/81.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local rc, answer = m_simpleTV.Http.Request(session, {body = decode64('Z3JhbnRfdHlwZT1pbmV0cmElM0Fhbm9ueW1vdXMmY2xpZW50X2lkPTI5NzgzMDUxJmNsaWVudF9zZWNyZXQ9YjRkNGViNDM4ZDc2MGRhOTVmMGFjYjViYzZiNWM3NjA='), url = decode64('aHR0cDovL2FwaS5wZWVycy50di9hdXRoLzIvdG9rZW4='), method = 'post', headers = 'Content-Type: application/x-www-form-urlencoded'})
		answer = answer or ''
		local token = answer:match('"access_token":"[^"]+') or ''
		rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cDovL2FwaS5wZWVycy50di9pcHR2LzIvcGxheWxpc3QubTN1'), headers = decode64('Q2xpZW50LUNhcGFiaWxpdGllczogcGFpZF9jb250ZW50LGFkdWx0X2NvbnRlbnRcbkF1dGhvcml6YXRpb246IEJlYXJlciA') .. token})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		local t, i = {}, 1
			for w in answer:gmatch('STREAM%-INF.-%.m3u8') do
				local name, adr = w:match(',(.-)\n(.+)')
				if not w:match('access=denied')
					and name
					and adr
					and not adr:match('/data/tv/')
				then
					t[i] = {}
					t[i].name = name
					id = w:match('%sid=(%d+)')
					if w:match('timeshift=true') and id then
						t[i].RawM3UString = 'catchup="append" catchup-minutes="360" catchup-source="&offset=${offset}"'
						adr = adr .. '$id=' .. id
					end
					t[i].address = adr
					i = i + 1
				end
			end
			if i == 1 then return end
			for _, v in pairs(t) do
				v.name = trim(v.name)
				if v.address:match('/16/')
					and (v.name == 'Россия 1'
						or v.name == 'НТВ'
						or v.name == 'СТС'
						or v.name == 'Россия К'
						or v.name == 'ТВЦ'
						or v.name == 'Рен ТВ'
						or v.name == 'Домашний'
						or v.name == 'Рен ТВ'
						or v.name == 'Домашний'
						or v.name == 'Муз ТВ'
						or v.name == 'Че!'
						or v.name == 'Первый HD'
						or v.name == 'Первый'
						or v.name == 'Звезда'
						or v.name == '2x2'
						or v.name == 'ОТР')
				then
					v.name = v.name .. ' (+4)'
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
