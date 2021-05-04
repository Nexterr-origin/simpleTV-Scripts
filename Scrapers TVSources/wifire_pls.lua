-- скрапер TVS для загрузки плейлиста "wifire" https://wifire.tv (23/10/20)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: wifire.lua
-- ## переименовать каналы ##
local filter = {
	{'5 канал', 'Пятый канал'},
	}
-- ##
	module('wifire_pls', package.seeall)
	local my_src_name = 'wifire'
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\wifire.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 0, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 0, AutoSearch = 1, AutoNumber = 0, NumberM3U = 0, GetSettings = 0, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function LoadFromSite()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.122 Safari/537.36')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 14000)
		local url = 'https://api.wifire.tv/api/v1/salt/web'
		local headers = 'Referer: https://wifire.tv/'
		local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = headers})
			if rc ~= 200 then return end
		local user_id = decode64('NzUwN2YwMDUtNzZmYi00NWFiLWE4NjktNjlkN2RjY2E2Yjcz')
		local timeSt = math.floor(os.time() / 1e3) * 1000
		timeSt = timeSt - timeSt % 600
		local secret = timeSt .. user_id .. 'register;salt=' .. answer
		url = 'https://api.wifire.tv/api/v1/register?userId=' .. user_id .. '&secret=' .. m_simpleTV.Common.CryptographicHash(secret) .. '&client=web'
		rc, answer = m_simpleTV.Http.Request(session, {url = url, method = 'post', headers = headers})
			if rc ~= 200 then return end
		local token = answer:match('"session_token":"([^"]+)')
			if not token then return end
		url = 'https://api.wifire.tv/api/v1/channels?categoryId=0'
		rc, answer = m_simpleTV.Http.Request(session, {url = url})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		answer = answer:gsub('\\', '\\\\')
		answer = answer:gsub('\\"', '\\\\"')
		answer = answer:gsub('\\/', '/')
		answer = answer:gsub(':%s*%[%]', ':""')
		answer = answer:gsub('%[%]', ' ')
		require 'json'
		tab = json.decode(answer)
			if not tab or not tab.result then return end
		local t, i = {}, 1
			while true do
					if not tab.result[i] then break end
				t[i] = {}
				t[i].name = unescape3(tab.result[i].name)
				t[i].address = 'https://wifire.tv/' .. tab.result[i].ip
				i = i + 1
			end
			if i == 1 then return end
		if not m_simpleTV.User then
			m_simpleTV.User = {}
		end
		if not m_simpleTV.User.wifire then
			m_simpleTV.User.wifire = {}
		end
		m_simpleTV.User.wifire.token = token
	 return t
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