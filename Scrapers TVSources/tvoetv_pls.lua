-- скрапер TVS для загрузки плейлиста "ТВОЄ ТВ" https://tvoetv.in.ua (18/1/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## авторизация ##
-- логин, ключ доступа установить в дополнении 'Password Manager', для id - tvoetv
-- ## необходим ##
-- расширение дополнения httptimeshift: tvoetv-timeshift_ext.lua
-- ## кеш (сек.) ##
local cacheT = 0
-- 0 - по умолчанию
-- ## группы ##
local no_group = 1
-- 0 - да
-- 1 - нет
-- ## переименовать каналы ##
local filter = {
	{'FOX', 'Fox'},
	{'KidZone HD', 'KidZone+ HD'},
	{'Наука', 'Наука UA'},
	}
-- ##
	module('tvoetv_pls', package.seeall)
	local my_src_name = 'ТВОЄ ТВ'
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\tvoetv.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, AutoBuild = 1, show_progress = 1, AutoBuildDay = {1, 0, 1, 0, 1, 0, 0}, LastStart = 0, TVS = {add = 0, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 0, AutoSearch = 0, AutoNumber = 0, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function showMess(str, color)
		local t = {text = str, color = color, showTime = 1000 * 5, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local function PlstApi(login, pass)
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0) AppleWebKit/538.1 (KHTML, like Gecko) SmartUP TV/1.0.1 Safari/538.1')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 16000)
		local n = {8, 4, 4, 4, 12}
		local duid = {}
			for i = 1, 5 do
				local d = {}
					for z = 1, n[i] do
						d[z] = {}
						d[z] = string.format('%x', math.random(0, 15))
					end
				duid[i] = {}
				duid[i] = table.concat(d)
			end
		duid = table.concat(duid, '-')
		local b = 'platform=smartup&lid=ru&duid=' .. duid
		local body = b
		local url = 'http://ott.onlineott.tv'
		local headers =	'X-Requested-With: XMLHttpRequest'
		local rc, answer = m_simpleTV.Http.Request(session, {url = url .. '/auth', method = 'post', headers = headers, body = body})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
			 return
			end
		local aid = answer:match('"aid":"(%x+)')
			if not aid then return end
		body = b .. '&signin[login]=' .. login
				.. '&signin[key]=' .. pass
				.. '&aid=' .. aid
		rc, answer = m_simpleTV.Http.Request(session, {url = url .. '/auth', method = 'post', headers = headers, body = body})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
			 return
			end
		local token = answer:match('"token":"([^"]+)')
			if not token then return end
		body = b .. '&token=' .. token
		rc, answer = m_simpleTV.Http.Request(session, {url = url .. '/tv/playlist', method = 'post', headers = headers, body = body})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		answer = answer:gsub('\\', '\\\\')
		answer = answer:gsub('\\"', '\\\\"')
		answer = answer:gsub('\\/', '/')
		answer = answer:gsub('%[%]', '""')
		require 'json'
		local tab = json.decode(answer)
			if not tab
				or not tab.playlist
				or not tab.playlist.groups
				or not tab.playlist.channels
			then
			 return
			end
		local grp, j = {}, 1
			while tab.playlist.groups[j] do
				grp[j] = {}
				grp[j].nom_grp = tab.playlist.groups[j].id
				grp[j].grp_name = unescape3(tab.playlist.groups[j].title)
				j = j + 1
			end
		if type(cacheT) == 'number' and cacheT > 0 then
			cacheT = '$OPT:network-caching=' .. (cacheT * 1000)
		else
			cacheT = ''
		end
		local t, i = {}, 1
			while tab.playlist.channels[i] do
				t[i] = {}
				if tab.playlist.channels[i].archive then
					t[i].RawM3UString = 'catchup="append" catchup-days="3" catchup-source=""'
				end
				t[i].address = tab.playlist.channels[i].url .. '&cid=' .. tab.playlist.channels[i].id .. cacheT
				t[i].name = unescape3(tab.playlist.channels[i].name)
				t[i].logo = tab.playlist.channels[i].logo:gsub('^%.', url)
				if no_group ~= 1 then
					for c = 1, #grp do
						if grp[c].nom_grp == tab.playlist.channels[i].group then
							t[i].group = grp[c].grp_name
						 break
						end
					end
				end
				i = i + 1
			end
			if #t == 0 then return end
	 return t
	end
	local function Plst(login, pass)
		local url = decode64('aHR0cDovL290dC5vbmxpbmVvdHQudHYvdG9vbHMvbTN1L3BsYXlsaXN0LnBocD9sb2dpbj0')
					.. login .. '&key=' .. pass
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:85.0) Gecko/20100101 Firefox/85.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 16000)
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		answer = answer .. '\n'
		if type(cacheT) == 'number' and cacheT > 0 then
			cacheT = '$OPT:network-caching=' .. (cacheT * 1000)
		else
			cacheT = ''
		end
		local t, i = {}, 1
			for w in answer:gmatch('%#EXTINF:.-\n.-\n') do
				local title = w:match(',(.-)\n')
				local adr = w:match('\n(.-)\n')
					if not adr or not title then break end
				t[i] = {}
				t[i].name = title
				t[i].address = adr .. cacheT
				if no_group ~= 1 then
					t[i].group = w:match('group%-title="([^"]+')
				end
				t[i].logo = w:match('tvg%-logo="([^"]+')
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
				showMess('дополнение "Password Manager" не установлено', ARGB(255, 255, 102, 0))
			 return
			end
		local ret, login, pass = pm.GetTestPassword('tvoetv', 'ТВОЄ ТВ', true)
			if not login or not pass
				or login == '' or pass == ''
			then
				showMess('логин/пароль установить\nв дополнении "Password Manager"\nдля id - tvoetv', ARGB(255, 255, 102, 0))
			 return
			end
		local t_pls = PlstApi(login, pass) or PlstApi(login, pass) or Plst(login, pass)
			if not t_pls then
				showMess(Source.name .. ' ошибка загрузки плейлиста', ARGB(255, 255, 102, 0))
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