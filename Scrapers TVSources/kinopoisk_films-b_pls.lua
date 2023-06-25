-- скрапер TVS для загрузки плейлиста кинопоиска "Фильмы B" (26/6/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: kinopoisk.lua
	module('kinopoisk_films-b_pls', package.seeall)
	local my_src_name = 'Фильмы B'
	function GetSettings()
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\films.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 0, RefreshButton = 0, AutoBuild = 0, show_progress = 1, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 0, FilterCH = 0, FilterGR = 0, GetGroup = 0, LogoTVG = 0}, STV = {add = 1, ExtFilter = 0, FilterCH = 0, FilterGR = 0, GetGroup = 1, HDGroup = 0, AutoSearch = 0, AutoNumber = 0, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 1, TypeSkip = 1, TypeFind = 1, TypeMedia = 1, TypeFindUseGr = 0, AutoSearchLogo = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function LoadFromSite()
		require 'json'
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local t = {}
			for c = 1, 1400 do
				local url = string.format(decode64('aHR0cHM6Ly9iYXpvbi5jYy9hcGkvanNvbi8/dG9rZW49NGY2YWRkZDUzMjdhY2RkNzY5NjljOTc3OTk1MzViMTQmdHlwZT1maWxtJnBhZ2U9JXM'), c)
				local rc, answer = m_simpleTV.Http.Request(session, {url = url})
				if rc == 200 then
						if answer:match('^%s*{"error"') then break end
					answer = answer:gsub('%[%]', '""')
					local err, tab = pcall(json.decode, answer)
					if tab and tab.results then
						local j = 1
							while tab.results[j] do
								local kinopoisk_id = tostring(tab.results[j].kinopoisk_id or '0')
								if kinopoisk_id and kinopoisk_id ~= '' and kinopoisk_id ~= '0'  and tab.results[j].info then
									t[#t +1] = {}
									t[#t].address = string.format('https://www.kinopoisk.ru/film/%s', kinopoisk_id)
									t[#t].logo = string.format('https://st.kp.yandex.net/images/film_iphone/iphone360_%s.jpg', kinopoisk_id)
									t[#t].group = tab.results[j].info.year or '0'
									local kpRating, imdbRating = '0', '0'
									if tab.results[j].info.rating then
										kpRating = tostring(tab.results[j].info.rating.rating_kp or '0')
										imdbRating = tostring(tab.results[j].info.rating.rating_imdb or '0')
									end
									t[#t].name = string.format('%s (КП: %s / IMDb: %s', tab.results[j].info.rus:gsub('"', '%%22'), kpRating:sub(1, 3), imdbRating:sub(1, 3))
									t[#t].video_title = tab.results[j].info.genre:gsub(',', ' ')
									t[#t].video_desc = string.format('%s | %s | %s', tab.results[j].info.country, t[#t].group, tab.results[j].info.description:gsub('%c', ' '):gsub('"', '%%22'))
								end
								j = j + 1
							end
					end
				else
				 break
				end
			end
	 return t
	end
	function GetList(UpdateID, m3u_file)
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		local t_pls = LoadFromSite()
			if not t_pls or #t_pls == 0 then return end
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')