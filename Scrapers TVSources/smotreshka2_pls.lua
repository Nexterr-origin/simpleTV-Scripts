-- скрапер TVS для загрузки плейлиста "Смотрёшка 2" https://smotreshka.tv (26/1/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: smotreshka
-- расширение дополнения httptimeshift: smotreshka-timeshift_ext.lua
-- ## авторизация ##
-- логин, пароль установить в 'Password Manager', для id - smotreshka2
-- ## переименовать каналы ##
local filter = {
	{'TV 5 Monde', 'TV5 Monde'},
	{'Ростов-папа', 'Ростов-папа (Ростов)'},
	{'Точка', 'Точка ТВ'},
	{'ТНВ Планета', 'ТНВ-Планета (Казань)'},
	{'O2', 'О2ТВ'},
	{'Русский Экстрим', 'Russian Extreme'},
	}
-- ##
	module('smotreshka2_pls', package.seeall)
	local my_src_name = 'Смотрёшка 2'
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\smotreshka.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 0, AutoSearch = 1, AutoNumber = 0, NumberM3U = 0, GetSettings = 0, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function showMess(str, color)
		local t = {text = str, color = color, showTime = 1000 * 5, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local function LoadFromSite(login, pass)
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:85.0) Gecko/20100101 Firefox/85.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 12000)
		login = m_simpleTV.Common.toPersentEncoding(login)
		pass = m_simpleTV.Common.toPersentEncoding(pass)
		local body = 'email=' .. login .. '&password=' .. pass
		local url = 'https://fe.smotreshka.tv/'
		local headers = 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8\nReferer: ' .. url
		local rc, answer = m_simpleTV.Http.Request(session, {body = body, url = url .. 'login', method = 'post', headers = headers})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
				answer = answer or ''
			 return answer:match('"msg":"([^"]+)') or 'Неправильный логин или пароль'
			end
		rc, answer = m_simpleTV.Http.Request(session, {url = url .. 'channels', headers = headers})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
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
				if tab.channels[j].info
					and tab.channels[j].info.purchaseInfo
					and tab.channels[j].info.purchaseInfo.bought
					and tab.channels[j].info.purchaseInfo.bought == true
				then
					t[i] = {}
					t[i].name = tab.channels[j].info.metaInfo.title:gsub('^%d+_', ''):gsub('%sOTT', '')
					t[i].address = 'https://smotreshka2.tv/' .. tab.channels[j].id
					if tab.channels[j].info.playbackInfo.dvrRestriction == false then
						t[i].RawM3UString = 'catchup="append" catchup-days="5" catchup-source="&shift=${offset}"'
					end
					i = i + 1
				end
				j = j + 1
			end
			if j > 1 and #t == 0 then
			 return 'подписка не оплачена'
			elseif j > 1 and #t > 0 then
			 return t
			end
	 return
	end
	function GetList(UpdateID, m3u_file)
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		local error_text, pm = pcall(require, 'pm')
			if not package.loaded.pm then
				showMess('дополнение "Password Manager" не установлено', ARGB(255, 255, 102, 0))
			 return
			end
		local ret, login, pass = pm.GetTestPassword('smotreshka2', 'Смотрёшка 2', true)
			if not login
				or not pass
				or login == ''
				or pass == ''
			then
				showMess('логин/пароль установить\nв дополнении "Password Manager"\nдля id - smotreshka2', ARGB(255, 255, 102, 0))
			 return
			end
		local t_pls = LoadFromSite(login, pass)
			if not t_pls then
				showMess(Source.name .. ' ошибка загрузки плейлиста', ARGB(255, 255, 102, 0))
			 return
			elseif type(t_pls) ~= 'table' then
				showMess(Source.name .. '\n' .. t_pls, ARGB(255, 255, 102, 0))
			 return
			end
		t_pls = ProcessFilterTableLocal(t_pls)
		showMess(Source.name .. ' (' .. #t_pls .. ')', ARGB(255, 153, 255, 153))
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')