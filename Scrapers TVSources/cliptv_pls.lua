-- скрапер TVS для загрузки плейлиста "CLİPTV" https://cliptv.az (23/4/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: cliptv.lua
-- ## переименовать каналы ##
local filter = {
	{'РЕН', 'РЕН ТВ'},
	{'Бобёр ТВ', 'Бобер'},
	{'Европа Плюс', 'Europa Plus TV'},
	{'XXI', 'TV XXI'},
	{'National Geographic Channel', 'National Geographic'},
	}
-- ##
	module('cliptv_pls', package.seeall)
	local my_src_name = 'CLİPTV'
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\cliptv.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 0, AutoSearch = 1, AutoNumber = 0, NumberM3U = 0, GetSettings = 0, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function showMess(str, color)
		local t = {text = str, color = color, showTime = 1000 * 10, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local function LoadFromSite()
		local session = m_simpleTV.Http.New('Embarcadero URI Client/1.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 12000)
		local api = decode64('aHR0cDovL2ZlLmNsaXB0di5hei9hcGkvdjE')
		local headers = 'Content-Type: application/json;charset=UTF-8'
		local rc, answer = m_simpleTV.Http.Request(session, {url = api .. '/device/authorize?uuid=' .. decode64('RTQ6Mjc6NzE6NEM6NjU6NUM'), headers = headers})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
			 return
			end
		rc, answer = m_simpleTV.Http.Request(session, {url = api .. '/channels/list?lang=en', headers = headers})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		answer = answer:gsub('%[%]', '""')
		require 'json'
		local tab = json.decode(answer)
			if not tab
				or not tab.result
				or not tab.result.list
			then
			 return
			end
		local t, i = {}, 1
			while tab.result.list[i] do
				t[i] = {}
				t[i].name = tab.result.list[i].name
				t[i].address = tab.result.list[i].url
				local catchupDays = math.floor((tab.result.list[i].tstvDuration or 0) / (3600 * 24))
				t[i].RawM3UString = 'catchup="append" catchup-days="' .. catchupDays .. '" catchup-source="?offset=-${offset}" catchup-record-source="?utcstart=${start}&utcend=${end}"'
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
