-- скрапер TVS для загрузки плейлиста кинопоиска "Аниме A" (29/6/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: kinopoisk.lua
	module('kinopoisk_anime-a_pls', package.seeall)
	local my_src_name = 'Аниме A'
	function GetSettings()
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\anime.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 0, RefreshButton = 0, AutoBuild = 0, show_progress = 1, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 0, FilterCH = 0, FilterGR = 0, GetGroup = 0, LogoTVG = 0}, STV = {add = 1, ExtFilter = 0, FilterCH = 0, FilterGR = 0, GetGroup = 1, HDGroup = 0, AutoSearch = 0, AutoNumber = 0, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 1, TypeSkip = 1, TypeFind = 1, TypeMedia = 1, TypeFindUseGr = 0, AutoSearchLogo = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function LoadFromSite()
		require 'json'
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 12000)
		local t = {}
			for c = 1, 1500 do
				local url = string.format(decode64('aHR0cHM6Ly9hcGkuYXBidWdhbGwub3JnLz90b2tlbj0wNDk0MWE5YTNjYTNhYzE2ZTJiNDMyNzM0N2JiYzEmb3JkZXI9ZGF0ZSZsaXN0PWFuaW1lJnBhZ2U9JXM'), c)
				local rc, answer = m_simpleTV.Http.Request(session, {url = url})
				if rc == 200 then
						if answer:match('^%s*{"status":"error"') then break end
					answer = answer:gsub('\\', '\\\\')
					answer = answer:gsub('null', 'false')
					answer = answer:gsub('%[%]', '""')
					local err, tab = pcall(json.decode, answer)
					if tab and tab.data then
						local j = 1
							while tab.data[j] do
								local kinopoisk_id = tostring(tab.data[j].id_kp or 0)
								if kinopoisk_id and kinopoisk_id ~= '' and kinopoisk_id ~= '0' then
									t[#t +1] = {}
									t[#t].address = string.format('https://www.kinopoisk.ru/film/%s', kinopoisk_id)
									t[#t].logo = string.format('https://st.kp.yandex.net/images/film_iphone/iphone360_%s.jpg', kinopoisk_id)
									t[#t].group = tostring(tab.data[j].year or 0)
									local kpRating = tab.data[j].rating_kp or 0
									local imdbRating = tab.data[j].rating_imdb or 0
									local description = unescape3(tab.data[j].description or '')
									local country = unescape3(tab.data[j].country or '')
									local genre = unescape3(tab.data[j].genre or '')
									t[#t].name = string.format('%s (КП: %s / IMDb: %s)', unescape3(tab.data[j].name):gsub('"', '%%22'), kpRating, imdbRating)
									t[#t].video_title = genre:gsub(',', ' ')
									t[#t].video_desc = string.format('%s | %s | %s', country, t[#t].group, description:gsub('%c', ' '):gsub('"', '%%22'))
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