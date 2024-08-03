-- скрапер TVS для загрузки плейлиста "Смотреть TV" https://smotret.tv (3/8/24)
-- Copyright © 2017-2024 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видеоскрипт: smotrettv.lua
-- ## переименовать каналы ##
local filter = {
	{'В мире животных HD', 'Zooпарк'},
	}
local host = 'https://smotret.tv'
	local my_src_name = 'Смотреть TV'
	module('smotrettv_pls', package.seeall)
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\smotrettv.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 0, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function LoadFromSite()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:129.0) Gecko/20100101 Firefox/129.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 15000)
		local rc, answer = m_simpleTV.Http.Request(session, {url = host})
			if rc ~= 200 then return end
		local t = {}
			for w in answer:gmatch('<li class="categories_item">(.-)</li>') do
				local adr = w:match('<a href="([^"]+)')
				if adr then
					t[#t + 1] = {}
					t[#t].address = adr
				end
			end
			if #t == 0 then return end
		local sum = {}
		for _, val in pairs(t) do
			local url = host .. val.address
			local rc, answer = m_simpleTV.Http.Request(session, {url = url})
				if rc ~= 200 then return end
			local d = {}
				for w in answer:gmatch('<a class="vest".-</div>') do
					local adr = w:match('href="([^"]+)')
					local title = w:match('"tv_channel_name">([^<]+)')
					if adr and title then
						d[#d + 1] = {}
						d[#d].name = title
						d[#d].address = host .. adr
					end
				end
				if #d == 0 then return end
				for i = 1, #d do
					sum[#sum + 1] = d[i]
				end
		end
	 return sum
	end
	function GetList(UpdateID, m3u_file)
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		local t_pls = LoadFromSite()
			if not t_pls or t_pls == 0 then return end
		t_pls = ProcessFilterTableLocal(t_pls)
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')
