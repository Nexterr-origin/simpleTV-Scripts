-- скрапер TVS для загрузки плейлиста киноаоиска "Фильмы" (29/1/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: kinopoisk.lua
-- ##
	module('films_kinopoisk_pls', package.seeall)
	local my_src_name = 'Фильмы'
	function GetSettings()
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\films.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 0, RefreshButton = 0, AutoBuild = 0, show_progress = 1, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 0, FilterCH = 0, FilterGR = 0, GetGroup = 0, LogoTVG = 0}, STV = {add = 1, ExtFilter = 0, FilterCH = 0, FilterGR = 0, GetGroup = 1, HDGroup = 0, AutoSearch = 0, AutoNumber = 0, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function showMess(str, color, showT)
		local t = {text = '🎞 ' .. str, color = color, showTime = showT or (1000 * 5), id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local function LoadFromSite()
		require 'json'
			local function round(str)
			 return string.format('%.' .. (1 or 0) .. 'f', str)
			end
			local function getReting(kpR, imdR)
				local kp, imd
				if kpR then
					kpR = tonumber(kpR)
				end
				if imdR then
					imdR = tonumber(imdR)
				end
				if kpR and kpR > 0 then
					kp = string.format('КП: %s', round(kpR))
				end
				if imdR and imdR > 0 then
					imd = string.format('IMDb: %s', round(imdR))
				end
					if not kp and not imd then
					 return ''
					end
				local slsh = ''
				if kp and imd then
					slsh = ' / '
				end
			 return string.format(' (%s%s%s)', kp or '', slsh, imd or '')
			end
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:85.0) Gecko/20100101 Firefox/85.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		showMess('«Фильмы» загрузка ...', ARGB(255, 153, 255, 153), 600000)
		local t, i = {}, 1
			local function getTbl(t, k, tab)
				local j = 1
					while tab.results[j] do
						local kinopoisk_id = tab.results[j].kinopoisk_id
						if kinopoisk_id then
							t[k] = {}
							t[k].address = string.format('https://www.kinopoisk.ru/film/%s', kinopoisk_id)
							t[k].logo = tab.results[j].info.poster
							local year = tab.results[j].info.year or 0
							t[k].group = year
							t[k].video_title = tab.results[j].info.genre:gsub(',', ' ')
							local kpR, imdR
							if tab.results[j].info.rating then
								kpR = tab.results[j].info.rating.rating_kp
								imdR = tab.results[j].info.rating.rating_imdb
							end
							t[k].name = string.format('%s %s', tab.results[j].info.rus:gsub('"', '%%22'), getReting(kpR, imdR))
							t[k].video_desc = string.format('%s | %s | %s', tab.results[j].info.country, year, tab.results[j].info.description:gsub('%c', ' '):gsub('"', '%%22'))
							k = k + 1
						end
						j = j + 1
					end
			 return t, k
			end
			for c = 1, 600 do
				local url = string.format(decode64('aHR0cHM6Ly9iYXpvbi5jYy9hcGkvanNvbi8/dG9rZW49Mjg0OGY3OWNhMDlkNGJiYmY0MTliY2RiNDY0YjRkMTEmdHlwZT1maWxtJnBhZ2U9JXM'), c)
				local rc, answer = m_simpleTV.Http.Request(session, {url = url})
				if rc == 200 and answer:match('"results"') then
					answer = answer:gsub('%[%]', '""')
					local tab = json.decode(answer)
					if tab and tab.results then
						t, i = getTbl(t, i, tab)
					end
				else
				 break
				end
			end
		m_simpleTV.Http.Close(session)
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
				showMess(Source.name .. ': ошибка загрузки плейлиста', ARGB(255, 255, 102, 0))
			 return
			end
		showMess(Source.name .. ' (' .. #t_pls .. ')', ARGB(255, 153, 255, 153))
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')