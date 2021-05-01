-- скрапер TVS для загрузки плейлиста "myvideoge" http://tv.myvideo.ge (10/3/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видеоскрипт: myvideoge.lua
-- ## прокси ##
local proxy = ''
-- '' - нет
-- 'https://proxy-nossl.antizapret.prostovpn.org:29976' (пример)
-- ## переименовать каналы ##
local filter = {
	{'Auto Plus', 'Авто Плюс'},
	}
-- ##
	module('myvideoge_pls', package.seeall)
	local my_src_name = 'myvideoge'
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\myvideoge.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 0, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 0, AutoSearch = 1, AutoNumber = 0, NumberM3U = 0, GetSettings = 0, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 0}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function showMsg(str, color)
		local t = {text = str, showTime = 1000 * 5, color = color, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local function LoadFromSite()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:86.0) Gecko/20100101 Firefox/86.0', proxy, false)
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
			local function getToken()
				local url = 'http://api.myvideo.ge/api/v1/auth/token'
				local body = 'client_id=7&grant_type=client_implicit'
				local headers = 'Origin: http://tv.myvideo.ge\nReferer: http://tv.myvideo.ge/'
				local rc, answer = m_simpleTV.Http.Request(session, {url = url, method = 'post', body = body, headers = headers})
					if rc ~= 200 then return end
			 return answer:match('"access_token":"([^"]+)')
			end
		local token = getToken()
			if not token then
				m_simpleTV.Http.Close(session)
			 return
			end
		local headers = 'Referer: http://tv.myvideo.ge/index.html?cache=' .. os.time()
					.. '&act=dvr&chan=pirvelitv&newApi=true'
					.. '&newApi=true\nauthorization: Bearer ' .. token
		local url = 'http://api.myvideo.ge/api/v1/channel?type=tv'
		local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = headers})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		answer = answer:gsub('\\/', '/')
		answer = answer:gsub('\\', '\\\\')
		answer = answer:gsub('\\"', '\\\\"')
		answer = answer:gsub('%[%]', '""')
		require 'json'
		local tab = json.decode(answer)
			if not tab
				or not tab.data
			then
			 return
			end
		local t, i = {}, 1
			while tab.data[i] do
				t[i] = {}
				t[i].name = unescape3(tab.data[i].attributes.name)
				t[i].address = 'http://tv.myvideo.ge/tv/' .. tab.data[i].attributes.slug
				t[i].logo = tab.data[i].relationships.logo.data.relationships.sizes.data.original.attributes.url
				if tab.data[i].attributes
					and tab.data[i].attributes.recordingDuration
					and tab.data[i].attributes.recordingDuration > 0
				then
					t[i].RawM3UString = 'catchup="flussonic" catchup-minutes="'
										.. (tab.data[i].attributes.recordingDuration / 60)
					t[i].address = t[i].address .. '&tshift=true'
				else
					t[i].address = t[i].address .. '&tshift=false'
				end
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