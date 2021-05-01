-- скрапер TVS для загрузки плейлиста "Персик ТВ" http://persik.by (15/12/20)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## авторизация ##
-- логин, пароль установить в дополнении 'Password Manager', для id - persik
-- ## необходим ##
-- видоскрипт: persik-tv.lua
-- расширение дополнения httptimeshift: persik-timeshift_ext.lua
-- ## переименовать каналы ##
local filter = {
	{'1000', 'TV1000'},
	{'1000 Action', 'TV1000 Action'},
	}
-- ##
	module('persik-tv_pls', package.seeall)
	local my_src_name = 'Персик ТВ'
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\persik.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 0, AutoSearch = 1, AutoNumber = 0, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 0}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function showMess(str, color)
		m_simpleTV.OSD.ShowMessageT({text = str
									, showTime = 1000 * 5
									, color = color
									, id = 'channelName'})
	end
	local function LoadFromSite(login, pass)
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Linux; Android 10; SAMSUNG-SM-T377A Build/NMF26X) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.105 Mobile Safari/537.36')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 14000)
		local url = 'https://api.persik.by/v1/account/login?auth_token=&uuid=&device=android&email='
			.. login
			.. '&password=' .. pass
		local rc, answer = m_simpleTV.Http.Request(session, {url = url, method = 'post', body = '{}', headers = 'Accept: application/json, text/plain, */*'})
			if rc ~= 200 then return end
		local token = answer:match('"auth_token":"([^"]+)')
			if not token then return end
		url = 'https://api.persik.by/v2/content/channels?uuid=&device=android&auth_token=' .. token
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
			if rc ~= 200 then return end
		m_simpleTV.Http.Close(session)
		answer = answer:gsub('%[%]', '""')
		require 'json'
		local tab = json.decode(answer)
			if not tab
				or not tab.channels
			then
			 return
			end
		local t, i = {}, 1
			while tab.channels[i] do
				t[i] = {}
				t[i].address = 'http://persik.' .. tab.channels[i].channel_id
				t[i].name = tab.channels[i].name:gsub('?', '%%3F'):gsub(',', '%%2C')
				t[i].logo = tab.channels[i].logo:gsub('\\/', '/')
				t[i].RawM3UString = string.format('catchup="append" catchup-minutes="%s" catchup-source=""', tonumber(tab.channels[i].dvr_sec) / 60)
				i = i + 1
			end
			if #t == 0 then return end
	 return t
	end
	function GetList(UpdateID, m3u_file)
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		local error_text, pm = pcall(require, 'pm')
			if not package.loaded.pm then
				showMess('дополнение "Password Manager" не установлено', 0xffff6600)
			 return
			end
		local ret, login, pass = pm.GetTestPassword('persik', 'persik', true)
			if not login or not pass
				or login == '' or pass == ''
			then
				showMess('логин/пароль установить\nв дополнении "Password Manager"\nдля id - persik', 0xffff6600)
			 return
			end
		local t_pls = LoadFromSite(login, pass)
			if not t_pls then
				showMess(Source.name .. ' ошибка загрузки плейлиста', 0xffff6600)
			 return
			end
		t_pls = ProcessFilterTableLocal(t_pls)
		showMess(Source.name .. ' (' .. #t_pls .. ')', 0xff99ff99)
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')