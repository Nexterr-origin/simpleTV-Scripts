-- скрапер TVS для загрузки плейлиста "TV+ HD" http://www.tvplusonline.ru (15/4/22)
-- Copyright © 2017-2022 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: tv+hd.lua
-- ## переименовать каналы ##
local filter = {
	{'Майдан', 'Майдан (Казань)'},
	{'ОТВ24', 'ОТВ 24 (Екатеринбург)'},
	{'ТНВ Планета', 'ТНВ-Планета (Казань)'},
	{'ТК-КВАНТ', 'ТМ-КВАНТ (Междуреченск)'},
	{'5 канал', 'Пятый канал'},
	{'Москва 24', 'Москва 24 (Москва)'},
	{'Наш дом', '11 канал (Пенза)'},
	{'ТВ3', 'ТВ-3'},
	}
	module('tv+hd_pls', package.seeall)
	local my_src_name = 'TV+ HD'
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\TVplus.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 0, AutoSearch = 1, AutoNumber = 0, NumberM3U = 0, GetSettings = 0, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function LoadFromSite()
		local session = m_simpleTV.Http.New('TV+Android/1.1.20.0 (Linux;Android 7.1.2) ExoPlayerLib/2.14.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly93d3cudHZwbHVzb25saW5lLnJ1L2FwaS9jaGFubmVscw')})
			if rc ~= 200 then return end
		answer = answer:gsub('%[%]', '')
		answer = answer:gsub('\\', '\\\\')
		require 'json'
		local tab = json.decode(answer)
			if not tab then return end
		local dvr = {}
		rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly93d3cudHZwbHVzb25saW5lLnJ1L3ZlcnNpb250di50eHQ')})
			if rc == 200 then
				dvr = answer:match('dvr,([^%c%s]+)') or ''
				dvr = split(dvr, ';')
			end
			local function catchup(adr)
				for i = 1, #dvr do
					if adr == dvr[i] then
					 return 'catchup="flussonic-hls" catchup-days="1" catchup-source=""'
					end
				end
			 return
			end
		local t = {}
			for i = 1, #tab do
				local title = tab[i].title
				local adr = tab[i].name
				local closed = tab[i].closed
				if title and adr and closed then
					local RawM3UString = catchup(adr)
					if #dvr == 0 then
						RawM3UString = ''
					end
					if (closed == 1 and RawM3UString) or closed == 0 then
						title = unescape1(title)
						if title == 'Матч! Футбол 3' then
							adr = 'matchfootball3'
						end
						t[#t + 1] = {}
						t[#t].name = title
						t[#t].RawM3UString = RawM3UString
						if closed == 1 then
							adr = adr .. '&plus=true'
							if #dvr == 0 then
								t[#t].RawM3UString = 'catchup="flussonic-hls" catchup-days="1" catchup-source=""'
							end
						end
						t[#t].address = 'https://tv+hd.' .. adr
					end
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
			if not t_pls then return end
		t_pls = ProcessFilterTableLocal(t_pls)
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')
