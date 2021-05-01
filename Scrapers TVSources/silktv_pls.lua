-- скрапер TVS для загрузки плейлиста "silktv" https://silktv.ge (10/3/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## переименовать каналы ##
local filter = {
	{'Auto Plus', 'Авто Плюс'},
	{'Dojd', 'Дождь'},
	{'Indijskoe kino', 'Индийское кино'},
	{'KVN TV', 'КВН ТВ'},
	{'Kinohit', 'Кинохит'},
	{'Kinokomediya', 'Кинокомедия'},
	{'Kinomiks', 'Киномикс'},
	{'Kinopremiera', 'Кинопремьера'},
	{'Kinosemya', 'Киносемья'},
	{'Kinoseriya', 'Киносерия'},
	{'Kinosvidanie', 'Киносвидание'},
	{'Kuhnia TV', 'Кухня ТВ'},
	{'Muzhskoe kino', 'Мужское кино'},
	{'Nashe Novoe Kino', 'Наше новое кино'},
	}
-- ##
	module('silktv_pls', package.seeall)
	local my_src_name = 'silktv'
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\silktv.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 0, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function showMsg(str, color)
		local t = {text = str, showTime = 1000 * 5, color = color, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local function LoadFromSite()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:86.0) Gecko/20100101 Firefox/86.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local url = 'https://silktv.ge/v1.5/?m=son'
		local body = '&device_id1=' .. math.random()
		.. '&device_type=Browser&player_id=Flash&location=Tbilisi&resolution=1280&os_version=71&device_name=Win64 Chrome'
		local headers = 'Referer: https://silktv.ge/?page=silktv'
		local rc, answer = m_simpleTV.Http.Request(session, {url = url, method = 'post', body = body, headers = headers})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
			 return
			end
		local sid = answer:match('"data":"([^"]+)')
			if not sid then
				m_simpleTV.Http.Close(session)
			 return
			end
		url = 'https://silktv.ge/v1.5/?m=list-channels-all&sid=' .. sid
		rc, answer = m_simpleTV.Http.Request(session, {url = url})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		answer = answer:gsub('%[%]', '""')
		require 'json'
		local tab = json.decode(answer)
			if not tab
				or not tab.data
			then
			 return
			end
		local t, j = {}, 1
			while tab.data[j] do
				if tab.data[j].physicalSettings
					and tab.data[j].physicalSettings.HLS_URL
				then
					t[#t + 1] = {}
					t[#t].name = tab.data[j].name
					t[#t].address = tab.data[j].physicalSettings.HLS_URL
								.. '$OPT:http-ext-header=Origin:https://silktv.ge'
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