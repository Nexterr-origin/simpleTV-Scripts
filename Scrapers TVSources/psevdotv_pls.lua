-- скрапер TVS для загрузки плейлиста "Псевдо ТВ" (22/1/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: psevdotv.film_ussr.lua, psevdotv.bond_007.lua, psevdotv.jackie_chan.lua
-- psevdotv.ivi_kinoteatr.lua
	module('psevdotv_pls', package.seeall)
	local my_src_name = 'Псевдо ТВ'
	function GetSettings()
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\psevdotv.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 0, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 0, AutoSearch = 1, AutoNumber = 0, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function outm3u()
	 return [[
#EXTM3U
#EXTINF:-1 group-title="Фильмы" tvg-logo="https://lh4.googleusercontent.com/proxy/QeqL1b6TeDDb4ksmwf6XyIMsofrP90HCHe1GL_NpKzEX_X4fZD0ioar3kMdG6RI0xIopJaBn97iudZ-JXKFYXDLj4Q" video-title="Фильмы" video-desk="http://www.ivi.ru",Фильмы СССР ☭🎞️
https://psevdotv.film_ussr
#EXTINF:-1 group-title="Фильмы" tvg-logo="https://gambit-parent.dfs.ivi.ru/static/23.01.04/images/apple/192x192-precomposed.png" video-title="Фильмы" video-desk="http://www.ivi.ru",Иви Кинотеатр 🎞
https://psevdotv.ivi_kinoteatr
#EXTINF:-1 group-title="Фильмы" tvg-logo="https://raw.githubusercontent.com/Nexterr-origin/simpleTV-Images/main/jackie_chan.png" video-title="Фильмы" video-desk="https://videocdn.tv",Джеки Чан ТВ 👊🎞️
https://psevdotv.jackie_chan
#EXTINF:-1 group-title="Фильмы" tvg-logo="https://raw.githubusercontent.com/Nexterr-origin/simpleTV-Images/main/bond_007.png" video-title="Фильмы" video-desk="https://videocdn.tv",Бонд 007 🔫🎞️
https://psevdotv.bond_007
	 ]]
	end
	function GetList(UpdateID, m3u_file)
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		local t_pls = tvs_core.GetPlsAsTable(outm3u())
		local text = {text = Source.name .. ' (' .. #t_pls .. ')', color = ARGB(255, 153, 255, 153), showTime = 1000 * 5, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(text)
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')
