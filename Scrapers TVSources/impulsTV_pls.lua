-- скрапер TVS для загрузки плейлиста "impulsTV" http://impulstv.ru (26/2/22)
-- Copyright © 2017-2022 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## авторизация ##
-- логин, пароль установить в дополнении 'Password Manager', для id - impulstv
-- ## необходим ##
-- видоскрипт: impulsTV
-- расширение дополнения httptimeshift: impulstv-timeshift_ext.lua
-- ## прокси (для пробного периода, т.к. ограничение на количество регистраций по IP адресу) ##
local proxy = ''
-- '' -- нет
-- 'http://169.57.1.85:8123' -- (пример)
-- ## переименовать каналы ##
local filter = {
	{'Кино 24', 'KINO 24'},
	{'Pro100TV', 'Про100ТВ'},
	{'HD-Life', 'HDL'},
	{'O2', 'О2ТВ'},
	{'RT News HD', 'Russia Today'},
	{'Russia Today Documentary', 'RTД'},
	{'ЕГЭ ТВ', 'ЕГЭ'},
	{'ТНТ-Music', 'ТНТ Music'},
	{'ТЕЛЕКАНАЛ 360', '360 Подмосковье (Москва)'},
	}
-- ##
	module('impulsTV_pls', package.seeall)
	local my_src_name = 'impulsTV'
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\impulstv.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 0, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 0, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 0, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 0, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function showMess(str, color)
		m_simpleTV.OSD.ShowMessageT({text = str
									, showTime = 1000 * 10
									, color = color
									, id = 'channelName'})
	end
	local function autoregistration(prx)
		local userAgent = 'Kodi (XBMC) smarty plugin on linux'
		local session = m_simpleTV.Http.New(userAgent, prx, nil)
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 20000)
		local url = decode64('aHR0cDovL3NtYXJ0eS5taWNyb2ltcHVscy5jb20vYXBpL3R2bWlkZGxld2FyZS9hcGkvYWNjb3VudC9yZWdpc3Rlci8/Y29tbWVudD1BdXRvcmVnaXN0cmF0aW9uJTIwZnJvbSUyMCZhdXRvX2FjdGl2YXRpb25fcGVyaW9kPTcmZGV2aWNlPWtvZGkmY2xpZW50X2lkPTc3JmFwaV9rZXk9bVMwWDAzY0Exbmdta1czS0oyU3hESE00OHRZUGVHM3FveVJiUGNsQlpYcGkyME1JUElwQ1NYWEl3d0JpT0tHciZsYW5nPXJ1JmF1dGhrZXk9JnNlc3Nfa2V5PTAmZGV2aWNlX3VpZD0') .. (math.random(1000, 1000000) * math.random(1000, 1000000))
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
	 return answer:match('"abonement":([^,]+),"password":([^,]+)')
	end
	local function LoadFromSite(login, pass)
		local userAgent = 'mag'
		local session = m_simpleTV.Http.New(userAgent)
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 16000)
		local url = decode64('aHR0cDovL2ltcHVsc3R2Lm1pY3JvLmltL2FwaS90dm1pZGRsZXdhcmUvYXBpL2xvZ2luLz9kZXZpY2VfdWlkPTAmZGV2aWNlX21vZGVsPU1vZGVsJTIwQSZkZXZpY2Vfc2VyaWFsPTAmZGV2aWNlPW1hZyZjbGllbnRfaWQ9NzcmYXBpX2tleT1tUzBYMDNjQTFuZ21rVzNLSjJTeERITTQ4dFlQZUczcW95UmJQY2xCWlhwaTIwTUlQSXBDU1hYSXd3QmlPS0dyJnNlc3Nfa2V5PTAmbGFuZz1ydSZhdXRoa2V5PSZhYm9uZW1lbnQ9') .. login .. '&password=' .. pass
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
			 return
			end
		local authkey = answer:match('<authkey>([^<]+)')
			if not authkey then
				m_simpleTV.Http.Close(session)
			 return
			end
		url = decode64('aHR0cDovL2ltcHVsc3R2Lm1pY3JvLmltL2FwaS90dm1pZGRsZXdhcmUvYXBpL2NoYW5uZWwvbGlzdC8/dGltZXpvbmU9MTUmdGltZXNoaWZ0PTAmZGV2aWNlPW1hZyZjbGllbnRfaWQ9NzcmbGFuZz1ydSZhcGlfa2V5PW1TMFgwM2NBMW5nbWtXM0tKMlN4REhNNDh0WVBlRzNxb3lSYlBjbEJaWHBpMjBNSVBJcENTWFhJd3dCaU9LR3Imc2Vzc19rZXk9MCZhdXRoa2V5PQ') .. authkey
		rc, answer = m_simpleTV.Http.Request(session, {url = url})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		local t, i = {}, 1
			for w in answer:gmatch('<is_hidden>.-</name>') do
				local name = w:match('<name>([^<]+)')
				local cid = w:match('<id>([^<]+)')
				if name and cid then
					t[i] = {}
					t[i].name = name
					local days = w:match('<max_archive_duration>(%d+)') or 0
					t[i].RawM3UString = 'catchup="append" catchup-days="' .. days .. '" catchup-source=""'
					t[i].address = 'http://impulstv/' .. cid
					i = i + 1
				end
			end
				if i == 1 then return end
			m_simpleTV.Config.SetValue('impulsTV_authkey', authkey)
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
		local ret, login, pass = pm.GetTestPassword('impulstv', 'impulstv', true)
		if not login or not pass
			or login == '' or pass == ''
		then
			login, pass = autoregistration()
			if proxy ~= '' and not (login or pass) then
				login, pass = autoregistration(proxy)
			end
		end
			if not login or not pass then
				showMess(Source.name .. ' логин/пароль установить\nв дополнении "Password Manager"\nдля id - impulstv\n\nдля пробного периода\nпоменяйте прокси в скрапере\nили IP адрес подключения', 0xffff6600)
			 return
			end
		login = m_simpleTV.Common.toPersentEncoding(login)
		pass = m_simpleTV.Common.toPersentEncoding(pass)
		local t_pls = LoadFromSite(login, pass)
			if not t_pls then
				showMess(Source.name .. ' ошибка загрузки плейлиста', 0xffff6600)
			 return
			end
		showMess(Source.name .. ' (' .. #t_pls .. ')', 0xff99ff99)
		t_pls = ProcessFilterTableLocal(t_pls)
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')
