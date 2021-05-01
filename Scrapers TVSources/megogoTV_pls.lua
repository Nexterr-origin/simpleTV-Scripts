-- скрапер TVS для загрузки плейлиста "megogoTV" https://megogo.ru (7/3/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## авторизация ##
-- логин, пароль установить в 'Password Manager', для id - megogo
-- ## необходим ##
-- видоскрипт: megogoTV.lua
-- расширение дополнения httptimeshift: megogotv-timeshift_ext.lua
-- ## переименовать каналы ##
local filter = {
	{'1000', 'TV1000'},
	{'1000 Action', 'TV1000 Action'},
	}
-- ##
	module('megogoTV_pls', package.seeall)
	local my_src_name = 'megogoTV'
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\megogo.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 0, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function showMsg(str, color)
		local t = {text = str, showTime = 1000 * 5, color = color, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local function LoadFromSite(login, pass)
		require 'json'
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:81.0) Gecko/20100101 Firefox/81.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
			local function GetSign(r)
				r = r:gsub('&', '')
				r = r .. '5066390625'
			 return '&sign=' .. m_simpleTV.Common.CryptographicHash(r) .. '_android_tvbox_j6'
			end
			local function GetToken(login, pass)
				local strSign = 'login=' .. login .. '&password=' .. pass .. '&remember=1'
				local sign = GetSign(strSign)
				login = m_simpleTV.Common.toPercentEncoding(login)
				pass = m_simpleTV.Common.toPercentEncoding(pass)
				local str = 'login=' .. login .. '&password=' .. pass .. '&remember=1'
				local url = 'https://api.megogo.net/v1/auth/login'
				local body = str .. sign
				local headers = 'Content-Type: application/x-www-form-urlencoded'
				local rc, answer = m_simpleTV.WinInet.Request(session, {url = url, method = 'post', body = body, headers = headers})
					if rc ~= 200 then return end
				answer = answer:gsub('%[%]', '""')
				local tab = json.decode(answer)
					if not tab
						or not tab.data
						or not tab.data.tokens.remember_me_token
					then
					 return
					end
			 return '&token=' .. tab.data.tokens.remember_me_token
			end
		local token = GetToken(login, pass)
			if not token then
				m_simpleTV.Http.Close(session)
			 return
			end
		local sign = GetSign(token)
			if not sign then
				m_simpleTV.Http.Close(session)
			 return
			end
		local url = 'https://api.megogo.net/v1/tv/channels?' .. token .. sign
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		answer = answer:gsub('%[%]', '""')
		local tab = json.decode(answer)
			if not tab
				or not tab.data
				or not tab.data.channels
			then
			 return
			end
		local t, i = {}, 1
		local j = 1
			while tab.data.channels[j] do
				if not tab.data.channels[j].vod_channel then
					t[i] = {}
					t[i].name = tab.data.channels[j].title
					t[i].address = 'http://TVmegogo/' .. tab.data.channels[j].id
					if tab.data.channels[j].is_dvr then
						t[i].RawM3UString = 'catchup="append" catchup-days="2" catchup-source=""'
					end
					i = i + 1
				end
				j = j + 1
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
				showMsg('дополнение "Password Manager" не установлено', ARGB(255, 255, 102, 0))
			 return
			end
		local ret, login, pass = pm.GetTestPassword('megogo', 'megogo', true)
			if not login or not pass
				or login == '' or pass == ''
			then
				showMsg('логин/пароль установить\nв дополнении "Password Manager"\nдля id - megogo', ARGB(255, 255, 102, 0))
			 return
			end
		local t_pls = LoadFromSite(login, pass)
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