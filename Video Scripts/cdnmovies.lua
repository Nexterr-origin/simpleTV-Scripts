-- видеоскрипт для видеобалансера "CDN Movies" https://cdnmovies.net (19/12/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://amuck-planes.cdnmovies-stream.online/content/def65d0bf564ebfc8b5b5dbc43bf58ff/iframe
-- https://amuck-planes.cdnmovies-stream.online/content/ee0dc1a5d76a4506a257a45ab399f5e0/iframe
-- https://cdnmovies-stream.online/kinopoisk/4948219/iframe
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('cdnmovies%-stream%.online')
			and not m_simpleTV.Control.CurrentAddress:match('^$cdnmovies')
		then
		 return
		end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if not inAdr:match('&kinopoisk') then
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
		end
	end
	require 'json'
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.cdnmovies then
		m_simpleTV.User.cdnmovies = {}
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	m_simpleTV.User.cdnmovies.DelayedAddress = nil
	local function dataClean(file)
		file = file:gsub('\\/\\/', '')
		local t = {'YldRdFQyUXlSemxTVjA5blUyRTFTRzlDVTFOaVYzSkRlVWx4VVhsWg', 'ZDA1d01uZENWRTVqVUZKUmRsUkRNRjlEY0hoRGMzRmZPRlF4ZFRsUg', 'TmkxNFVWZE5hRGRsY25STWNEaDBYMDA1YUhWVlJHc3hUVEJXY2xsSw', 'VW5sVWQzUm1NVFZmUjB4RmMxaDRibkJWTkV4cWFtUXdVbVZaTFZaSQ', 'YTNwMVQxbFJjVUpmVVZOUFRDMTRlazVmUzNvemEydG5hMGhvU0dsMA'}
		local c = 0
			while c < 32 do
					for i = 1, #t do
						file = file:gsub(decode64(t[i]), '')
					end
				c = c + 1
			end
	 return file
	end
	local function showMsg(str, msg)
		local color
		if not msg then
			msg = 'CDN Movies ошибка: ' .. str
			color = ARGB(255, 255, 102, 0)
		end
		local t = {text = msg, showTime = 1000 * 8, color = color, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local function subtitle(url)
		local subt = {}
			for w in url:gmatch('%[[^%]]+%]([^%[,]+)') do
				subt[#subt + 1] = w:gsub('://', '/webvtt://')
			end
			if #subt > 0 then
			 return '$OPT:input-slave=' .. table.concat(subt, '#')
			end
	 return
	end
	local function getIndex(t)
		local lastQuality = tonumber(m_simpleTV.Config.GetValue('cdnmovies_qlty') or 5000)
		local index = #t
			for i = 1, #t do
				if t[i].qlty >= lastQuality then
					index = i
				 break
				end
			end
		if index > 1 then
			if t[index].qlty > lastQuality then
				index = index - 1
			end
		end
	 return index
	end
	local function getAdr(url)
			if not url then return end
		url = url:gsub('^$cdnmovies', '')
		-- local subt = subtitle(url) or ''
		local t = {}
			for qlty, adr in url:gmatch('%[(%d+)p%]([^,]+)') do
					t[#t + 1] = {}
					t[#t].Id = #t
					t[#t].qlty = tonumber(qlty)
					t[#t].Name = qlty .. 'p'
					t[#t].Address = adr
			end
			if #t == 0 then return end
		table.sort(t, function(a, b) return a.qlty < b.qlty end)
		m_simpleTV.User.cdnmovies.Tab = t
		local index = getIndex(t)
		m_simpleTV.User.cdnmovies.Index = index
	 return t[index].Address
	end
	local function play(adr, title)
		local retAdr = getAdr(adr)
			if not retAdr then return end
-- debug_in_file(retAdr .. '\n')
		m_simpleTV.Control.SetTitle(title)
		showMsg(nil, title)
		m_simpleTV.Control.CurrentAddress = retAdr
	end
	local function transl(movie)
		local tab = m_simpleTV.User.cdnmovies.tabEpisode
		local transl_name = m_simpleTV.User.cdnmovies.transl_name or m_simpleTV.User.cdnmovies.tabEpisode[1].title
		local transl_id = m_simpleTV.User.cdnmovies.transl_id
		local found_transl_name
		local t = {}
			for i = 1, #tab do
				t[i] = {}
				t[i].Id = i
				t[i].Address = tab[i].file
				-- .. (tab[i].subtitle or '')
				t[i].Name = tab[i].title
				if t[i].Name == transl_name then
					transl_id = i
					found_transl_name = true
				end
			end
			if #t == 0 then return end
		m_simpleTV.User.cdnmovies.transl_name = transl_name or t[1].Name
		if not transl_id or transl_id > #t or not found_transl_name then
			transl_id = 1
		end
		m_simpleTV.User.cdnmovies.transl_id = transl_id
		m_simpleTV.User.cdnmovies.transl = t
		if movie then
			m_simpleTV.User.cdnmovies.adr = t[1].Address
		end
	 return true
	end
	local function seasons(transl_menu)
		local tab = m_simpleTV.User.cdnmovies.tab
		local title = m_simpleTV.User.cdnmovies.title
		local t = {}
			for i = 1, #tab do
				t[#t +1] = {}
				t[#t].Id = #t
				t[#t].Name = tab[#t].title
			end
			if #t == 0 then return end
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		if not transl_menu then
			t.ExtButton0 = {ButtonEnable = true, ButtonName = '🎞️'}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonClose then
			t.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonClose}
		else
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕'}
		end
		local season_chk = m_simpleTV.User.cdnmovies.season or 1
		local fl = 0
		if transl_menu and m_simpleTV.Control.GetState() == 0 then
			fl = 8
		end
		local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('сезоны - ' .. title, season_chk - 1, t, 10000, 1 + 2 + 4 + fl)
			if ret == 2 and not transl_menu then
				m_simpleTV.Control.Restart(-2.0, true)
			 return
			end
			if (not id or ret == 3) and transl_menu then
				m_simpleTV.Control.ExecuteAction(37)
			 return
			elseif ret == 3 and not transl_menu then
				m_simpleTV.Control.ExecuteAction(37)
			 return
			end
		id = id or 1
		m_simpleTV.User.cdnmovies.season = id
		m_simpleTV.User.cdnmovies.seasonName = ' (' .. t[id].Name .. ')'
	 return true
	end
	local function episodes()
		local tab = m_simpleTV.User.cdnmovies.tab
		local season = m_simpleTV.User.cdnmovies.season
		local t, i = {}, 1
			while tab[season].folder[i] do
				t[i] = {}
				t[i].Id = i
				t[i].Name = tab[season].folder[i].title
				t[i].Address = '$cdnmovies' .. tab[season].folder[i].folder[1].file
				t[i].Table = tab[season].folder[i].folder
				i = i + 1
			end
			if #t == 0 then return end
		local retAdr = getAdr(t[1].Address)
			if not retAdr then return end
		m_simpleTV.User.cdnmovies.tabEpisode = t[1].Table
		transl()
		m_simpleTV.User.cdnmovies.DelayedAddress = retAdr
		local title = m_simpleTV.User.cdnmovies.title .. m_simpleTV.User.cdnmovies.seasonName
		m_simpleTV.Control.SetTitle(title)
		if m_simpleTV.User.paramScriptForSkin_buttonOptions then
			t.ExtButton0 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOptions, ButtonScript = 'qlty_cdnmovies()'}
		else
			t.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'qlty_cdnmovies()'}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonPlst then
			t.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonPlst, ButtonScript = 'transl_cdnmovies()'}
		else
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '📋', ButtonScript = 'transl_cdnmovies()'}
		end
		t.ExtParams = {}
		t.ExtParams.LuaOnCancelFunName = 'OnMultiAddressCancel_cdnmovies'
		t.ExtParams.LuaOnOkFunName = 'OnMultiAddressOk_cdnmovies'
		t.ExtParams.LuaOnTimeoutFunName = 'OnMultiAddressCancel_cdnmovies'
		t.ExtParams.StopOnError = 1
		t.ExtParams.StopAfterPlay = 1
		t.ExtParams.PlayMode = 1
		m_simpleTV.OSD.ShowSelect_UTF8(title, 0, t, 10000, 2 + 64)
		m_simpleTV.User.cdnmovies.episodeTitle = title .. ': ' .. t[1].Name
		m_simpleTV.Control.CurrentAddress = 'wait'
		m_simpleTV.Control.SetNewAddressT({address = m_simpleTV.Control.CurrentAddress})
	end
	local function movie()
		local title = m_simpleTV.User.cdnmovies.title
		local adr = m_simpleTV.User.cdnmovies.adr
		local t = {}
		t[1] = {}
		t[1].Id = 1
		t[1].Name = title
		if m_simpleTV.User.paramScriptForSkin_buttonOptions then
			t.ExtButton0 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOptions, ButtonScript = 'qlty_cdnmovies()'}
		else
			t.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'qlty_cdnmovies()'}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonPlst then
			t.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonPlst, ButtonScript = 'transl_cdnmovies(true)'}
		else
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '📋', ButtonScript = 'transl_cdnmovies(true)'}
		end
		m_simpleTV.OSD.ShowSelect_UTF8('CDN Movies', 0, t, 10000, 64 + 32 + 128)
		play(adr, title)
	end
	local function getData()
		local url = inAdr:gsub('&kinopoisk.+', ''):gsub('^http:', 'https:')
		local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = 'Referer: https://cdnmovies.net/'})
			if rc ~= 200 then return end
		local file = answer:match('#2([^&]+)')
			if not file then return end
		file = dataClean(file)
		file = decode64(file)
		file = file:gsub('\\/', '/')
		file = file:gsub('%[%]', '""')
		local err, tab = pcall(json.decode, file)
		local ser = file:match('folder')
		local titleAnswer = answer:match('ru_title&quot;:&quot;(.-)&quot;,')
		titleAnswer = unescape3(titleAnswer)
	 return tab, ser, titleAnswer
	end
	function transl_cdnmovies(movie)
		local t = m_simpleTV.User.cdnmovies.transl
			if not t then return end
		m_simpleTV.Control.ExecuteAction(37)
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonClose then
			t.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonClose, ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		else
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		end
		if not movie then
			t.ExtButton0 = {ButtonEnable = true, ButtonName = 'Сезоны'}
		end
		local transl_id = m_simpleTV.User.cdnmovies.transl_id
		m_simpleTV.User.cdnmovies.transl_name = m_simpleTV.User.cdnmovies.transl[transl_id].Name
		local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('Перевод', transl_id - 1, t, 10000, 1 + 2 + 4)
		if ret == 1 then
			local retAdr = getAdr(t[id].Address)
				if not retAdr then return end
			local position
			if m_simpleTV.Control.GetState() == 0 then
				position = 0
			else
				position = m_simpleTV.Control.GetPosition()
			end
			m_simpleTV.User.cdnmovies.transl_id = id
			m_simpleTV.User.cdnmovies.transl_name = m_simpleTV.User.cdnmovies.transl[id].Name
			m_simpleTV.Control.SetNewAddressT({address = retAdr, position = position})
		end
		if ret == 2 then
			if seasons(true) then
				m_simpleTV.User.cdnmovies.transl_id = nil
				m_simpleTV.User.cdnmovies.transl_name = nil
				episodes()
			end
		end
		if (not id or ret == 3) and m_simpleTV.Control.GetState() == 0 then
			m_simpleTV.Control.ExecuteAction(108)
		end
	end
	function qlty_cdnmovies()
		local t = m_simpleTV.User.cdnmovies.Tab
			if not t then return end
		m_simpleTV.Control.ExecuteAction(37)
		local index = getIndex(t)
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonClose then
			t.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonClose, ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		else
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		end
		local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 10000, 1 + 2 + 4)
		if ret == 1 then
			m_simpleTV.Control.SetNewAddressT({address = t[id].Address, position = m_simpleTV.Control.GetPosition()})
			m_simpleTV.Config.SetValue('cdnmovies_qlty', t[id].qlty)
		end
	end
	function OnMultiAddressOk_cdnmovies(Object, id)
		if id == 1 then
			OnMultiAddressCancel_cdnmovies(Object)
		else
			m_simpleTV.User.cdnmovies.DelayedAddress = nil
		end
	end
	function OnMultiAddressCancel_cdnmovies(Object)
		if m_simpleTV.User.cdnmovies.DelayedAddress then
			if m_simpleTV.Control.GetState() == 0 then
				m_simpleTV.Control.SetNewAddressT({address = m_simpleTV.User.cdnmovies.DelayedAddress, position = 0})
				local title = m_simpleTV.User.cdnmovies.episodeTitle
				m_simpleTV.Control.SetTitle(title)
				showMsg(nil, title)
			end
			m_simpleTV.User.cdnmovies.DelayedAddress = nil
		end
	end
		if inAdr:match('^$cdnmovies') then
			local title = ''
			local t = m_simpleTV.Control.GetCurrentChannelInfo()
			if t
				and t.MultiHeader
				and t.MultiName
			then
				title = t.MultiHeader .. ': ' .. t.MultiName
				m_simpleTV.User.cdnmovies.tabEpisode = m_simpleTV.User.cdnmovies.tab[m_simpleTV.User.cdnmovies.season].folder[t.MultiIndex +1].folder
				transl()
				local transl_id = m_simpleTV.User.cdnmovies.transl_id
				play(m_simpleTV.User.cdnmovies.tab[m_simpleTV.User.cdnmovies.season].folder[t.MultiIndex +1].folder[transl_id].file, title)
			end
		 return
		end
	local tab, ser, titleAnswer = getData()
		if type(tab) ~= 'table' then
			m_simpleTV.Http.Close(session)
			showMsg('нет данных')
		 return
		end
	local title = inAdr:match('&kinopoisk=(.+)')
	if title then
		title = m_simpleTV.Common.fromPercentEncoding(title)
	else
		title = titleAnswer or 'CDN Movies'
	end
	m_simpleTV.User.cdnmovies.title = title
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
	end
	m_simpleTV.User.cdnmovies.tab = tab
	m_simpleTV.User.cdnmovies.transl = nil
	m_simpleTV.User.cdnmovies.transl_id = nil
	m_simpleTV.User.cdnmovies.season = nil
	m_simpleTV.User.cdnmovies.transl_name = nil
	if ser then
		if seasons() then
			episodes()
		end
	else
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
		end
		m_simpleTV.User.cdnmovies.tabEpisode = m_simpleTV.User.cdnmovies.tab
		if transl(true) then
			movie()
		end
	end
