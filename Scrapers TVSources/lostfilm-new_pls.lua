-- скрапер TVS "LostFilm новинки серий / сезонов" https://www.lostfilm.tv (10/3/21)
-- Copyright © 2017-2020 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## Авторизация ##
-- логин, пароль установить в 'Password Manager', для id - lostfilm
-- ## необходим ##
-- Acestream
-- видоскрипт: lostfilm.lua
-- ## зеркало ##
local url = ''
-- '' = нет
-- 'https://www.lostfilm.run' (пример)
-- ## прокси ##
local prx = ''
-- '' - нет
-- 'https://proxy-nossl.antizapret.prostovpn.org:29976' (пример)
-- ##
	module('lostfilm-new_pls', package.seeall)
	local my_src_name = 'LostFilm новинки серий'
	function GetSettings()
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\lostfilm.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 0, show_progress = 0, AutoBuild = 1, AutoBuildDay = {1, 1, 1, 1, 1, 1, 1}, LastStart = 0, TVS = {add = 0, FilterCH = 0, FilterGR = 0, GetGroup = 0, LogoTVG = 0}, STV = {add = 1, ExtFilter = 1, FilterCH = 0, FilterGR = 0, GetGroup = 1, HDGroup = 0, AutoSearch = 0, AutoNumber = 0, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 2, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function showMsg(str, color)
		local t = {text = str, showTime = 1000 * 5, color = color, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local function LoadFromSite()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:86.0) Gecko/20100101 Firefox/86.0', prx, false)
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 12000)
		if url == '' then
			url = 'https://www.lostfilm.tv'
		end
		local rc, answer = m_simpleTV.Http.Request(session, {url = url .. '/new/'})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		local t = {}
			for w in answer:gmatch('<div class="row">(.-)</a>') do
				local logo = w:match('<img src="([^"]+)" class="thumb"')
				local season_seria, data = w:match('<div class="overlay">%s*<div class="left%-part">([^<]+)</div>%s*<div class="right%-part">(%d+%.%d+)')
				local episode_name = w:match('<div class="details%-pane">%s*<div class="alpha">([^<]+)')
				local adr = w:match('href="([^"]+)')
				local name = w:match('<div class="name%-ru">([^<]+)')
				if name and adr and episode_name and season_seria and data and logo then
					t[#t + 1] = {}
					t[#t].group = my_src_name
					t[#t].group_logo = 'https://raw.githubusercontent.com/Nexterr-origin/simpleTV-Images/main/logo-lostfilm.png'
					t[#t].group_is_unique = 1
					t[#t].logo = logo:gsub('^//', 'https://')
					t[#t].name = string.format('%s %s %s, %s', data, name, season_seria, episode_name)
					t[#t].address = string.format('%s%s', url, adr)
				end
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
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')