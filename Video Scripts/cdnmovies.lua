-- видеоскрипт для видеобалансера "CDN Movies" https://cdnmovies.net (11/4/22)
-- Copyright © 2017-2022 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- модуль: /core/playerjs.lua
-- ## открывает подобные ссылки ##
-- http://moonwalk.cam/movie/4514
-- http://moonwalk.cam/serial/5311
-- https://700filmov.ru/serial/2042
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://moonwalk%.cam')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://700filmov%.ru')
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
	require 'playerjs'
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.cdnmovies then
		m_simpleTV.User.cdnmovies = {}
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:98.0) Gecko/20100101 Firefox/98.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	m_simpleTV.User.cdnmovies.DelayedAddress = nil
	local function showMsg(str, msg)
		local color
		if not msg then
			msg = 'CDN Movies ошибка: ' .. str
			color = ARGB(255, 255, 102, 0)
		end
		local t = {text = msg, showTime = 1000 * 8, color = color, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
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
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
			if rc ~= 200 then return end
		local base = url:match('.+/')
		local t = {}
			for w in answer:gmatch('#EXT%-X%-STREAM.-\n.-\n') do
				local qlty = w:match('RESOLUTION=%d+x(%d+)')
				local adr = w:match('\n(.+)')
				if qlty and adr then
					t[#t + 1] = {}
					t[#t].Id = #t
					t[#t].qlty = tonumber(qlty)
					adr = adr:gsub('^[/.]+', base)
					adr = adr:gsub(':hls:manifest.-$', '')
					t[#t].Address = adr .. '$OPT:NO-STIMESHIFT'
					t[#t].Name = qlty .. 'p'
				end
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
	local function transl()
		local tab = m_simpleTV.User.cdnmovies.tab
		local t = {}
			for i = 1, #tab do
				t[i] = {}
				t[i].Id = i
				t[i].Address = tab[i].file
				t[i].Name = tab[i].title
			end
			if #t == 0 then return end
		m_simpleTV.User.cdnmovies.transl = t
		m_simpleTV.User.cdnmovies.adr = t[1].Address
	 return true
	end
	local function seasons()
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
		t.ExtButton0 = {ButtonEnable = true, ButtonName = '🎞️'}
		local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('сезон: ' .. title, 0, t, 10000, 1 + 2 + 4 + 8)
			if ret == 2 then
				m_simpleTV.Control.Restart(-2.0, true)
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
				i = i + 1
			end
			if #t == 0 then return end
		local retAdr = getAdr(t[1].Address)
			if not retAdr then return end
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
			t.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonPlst, ButtonScript = 'transl_cdnmovies()'}
		else
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '📋', ButtonScript = 'transl_cdnmovies()'}
		end
		m_simpleTV.OSD.ShowSelect_UTF8('CDN Movies', 0, t, 10000, 64 + 32 + 128)
		play(adr, title)
	end
	local function getData()
		local url = inAdr:gsub('&kinopoisk.+', ''):gsub('^http:', 'https:')
		local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = 'Referer: https://cdnmovies.net/'})
			if rc ~= 200 then return end
		local file = answer:match('file:\'([^\']+)')
			if not file then return end
		if file:match('^#') then
			local playerjs_url = answer:match('script src="([^"]+)')
				if not playerjs_url then return end
			local host = url:match('^https?://[^/]+')
			if not playerjs_url:match('^https?://') then
				playerjs_url = host .. playerjs_url
			end
			file = playerjs.decode(file, playerjs_url)
				if not file or file == '' then return end
			file = m_simpleTV.Common.multiByteToUTF8(file)
		end
		local titleAnswer = answer:match('<title>([^<]+)')
		file = file:gsub('%[%]', '""')
		local err, tab = pcall(json.decode, file)
		local ser = file:match('folder')
	 return tab, ser, titleAnswer
	end
	function serials_cdnmovies()
		if seasons() then
			episodes()
		end
	end
	function transl_cdnmovies()
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
		local transl_id = m_simpleTV.User.cdnmovies.transl_id or 1
		local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('Перевод', transl_id - 1, t, 10000, 1 + 2 + 4)
		if ret == 1 then
			local retAdr = getAdr(t[id].Address)
				if not retAdr then return end
			m_simpleTV.User.cdnmovies.transl_id = id
			m_simpleTV.Control.SetNewAddressT({address = retAdr, position = m_simpleTV.Control.GetPosition()})
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
			end
			play(inAdr, title)
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
	if ser then
		serials_cdnmovies()
	else
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
		end
		if transl() then
			movie()
		end
	end
