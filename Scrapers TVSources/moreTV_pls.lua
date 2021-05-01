-- скрапер TVS для загрузки плейлиста "moreTV" https://more.tv (7/3/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: mediavitrina.lua
-- ## переименовать каналы ##
local filter = {
	{'5 канал', 'Пятый канал'},
	{'Animal Planet', 'Animal Planet HD'},
	{'Cartoon Network', 'Cartoon Network HD'},
	{'Discovery Science', 'Discovery Science HD'},
	{'Discovery', 'Discovery Channel HD'},
	{'EUROSPORT 1', 'Eurosport 1 HD'},
	{'Fox life', 'FOX Life HD'},
	{'Fox', 'FOX HD'},
	{'National Geographic', 'National Geographic HD'},
	{'TLC', 'TLC HD'},
	{'TV1000 Action', 'TV 1000 Action HD'},
	{'TV1000 Русское кино', 'TV 1000 Русское кино HD'},
	{'TV1000', 'TV 1000 HD'},
	{'VIASAT SPORT', 'Viasat Sport HD'},
	{'ViP COMEDY', 'VIP Comedy HD'},
	{'ViP MEGAHIT', 'VIP Megahit HD'},
	{'ViP Premiere', 'ViP Premiere HD'},
	{'Viasat Explore', 'Viasat Explore HD'},
	{'Viasat History', 'Viasat History HD'},
	{'Viasat Nature', 'Viasat Nature HD'},
	{'Vip Serial', 'ViP Serial HD'},
	{'Первый канал', 'Первый канал HD'},
	{'Россия 1', 'Россия 1 HD'},
	{'Россия-1', 'Россия 1 HD'},
	{'Россия-К', 'Россия К'},
	{'СТС Kids', 'СТС Kids HD'},
	}
-- ##
	module('moreTV_pls', package.seeall)
	local my_src_name = 'moreTV'
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\moretv.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 0, NumberM3U = 0, GetSettings = 0, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function showMsg(str, color)
		local t = {text = str, color = color, showTime = 1000 * 5, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local function LoadFromSite()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:82.0) Gecko/20100101 Firefox/82.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly9tb3JlLnR2L2FwaS93ZWIvY2hhbm5lbHM')})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		answer = answer:gsub(':%s*%[%]', ':""')
		answer = answer:gsub('%[%]', ' ')
		require 'json'
		local tab = json.decode(answer)
			if not tab or not tab.data then return end
		local t, i = {}, 1
		local j	= 1
		local adr
			while tab.data[j] do
				adr = tab.data[j].vitrinaSamsungTizenSDK
				if adr then
					t[i] = {}
					t[i].name = tab.data[j].title
					t[i].address = adr
					i = i + 1
				end
				j = j + 1
			end
			if i == 1 then return end
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