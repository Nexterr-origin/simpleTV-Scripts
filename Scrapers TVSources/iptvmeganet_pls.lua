-- скрапер TVS для загрузки плейлиста "iptv.mega.net" http://iptv.mega.net.ru (7/9/24)
-- Copyright © 2017-2024 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## переименовать каналы ##
local filter = {
	{'Мир-ТВ', 'МИР'},
	}
	module('iptvmeganet_pls', package.seeall)
	local my_src_name = 'Iptv.Mega.Net'
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\seversk.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 0, AutoSearch = 1, AutoNumber = 0, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	function GetList(UpdateID, m3u_file)
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		local outm3u, err = tvs_func.get_m3u(decode64('aHR0cDovL2lwdHYubWVnYS5uZXQucnU'))
		if err ~= '' then
			tvs_core.tvs_ShowError(err)
			m_simpleTV.Common.Wait(1000)
		end
			if not outm3u or outm3u == '' then
			 return ''
			end
		local t_pls = tvs_core.GetPlsAsTable(outm3u, UpdateID)
		local t = {}
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:130.0) Gecko/20100101 Firefox/130.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 12000)
			for i = 1, #t_pls do
				local url = t_pls[i].address
				local rc, answer = m_simpleTV.Http.Request(session, {url = url})
				if rc == 200 then
					t[#t +1] = t_pls[i]
				end
			end
		t = ProcessFilterTableLocal(t)
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')
