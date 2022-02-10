-- видеоскрипт для видеобалансера "Hdvb" https://hdvb.tv (10/2/22)
-- Copyright © 2017-2022 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://vid1599090588.vb17112tiffanyhayward.pw/movie/ee643ffd63331ad268be64e6d4183eed/iframe
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://vid%d+.-/%a+/%x+/iframe')
			and not m_simpleTV.Control.CurrentAddress:match('^$hdvb')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://farsihd%.%a+/.+')
		then
		 return
		end
	local inAdr = m_simpleTV.Control.CurrentAddress
		if inAdr:match('%.m3u8') then return end
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
	if inAdr:match('^$hdvb') or not inAdr:match('&kinopoisk') then
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Interface.SetBackground({BackColor = 0, BackColorEnd = 255, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
		end
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'hdvb ошибка: ' .. str, showTime = 8000, color = 0xffff1000, id = 'channelName'})
	end
	require 'json'
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:81.0) Gecko/20100101 Firefox/81.0')
		if not session then
			showError('1')
		 return
		end
	m_simpleTV.Http.SetTimeout(session, 12000)
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.hdvb then
		m_simpleTV.User.hdvb = {}
	end
	if not m_simpleTV.User.hdvb.qlty then
		m_simpleTV.User.hdvb.qlty = tonumber(m_simpleTV.Config.GetValue('hdvb_qlty') or '10000')
	end
	local refer = 'http://filmhd1080.net/'
	local title
	if m_simpleTV.User.hdvb.Tabletitle then
		local index = m_simpleTV.Control.GetMultiAddressIndex()
		if index then
			title = m_simpleTV.User.hdvb.title .. ' - ' .. m_simpleTV.User.hdvb.Tabletitle[index].Name
		end
	end
	local function trim(s)
	 return s:gsub('^%s*(.-)%s*$', '%1')
	end
	local function GetAddress(Adr)
		local rc, answer = m_simpleTV.Http.Request(session, {url = Adr, headers = 'Referer: ' .. refer})
			if rc ~= 200 then return end
		answer = answer:match('data%-config=\'(.-)\'')
		answer = answer:gsub('(%[%])', '"nil"')
		local tab = json.decode(answer)
			if not tab then return end
		local retAdr = tab.hls
			if not retAdr then return end
	 return retAdr
	end
	local function GetMaxResolutionIndex(t)
		local index
		for u = 1, #t do
				if t[u].qlty and m_simpleTV.User.hdvb.qlty < t[u].qlty then break end
			index = u
		end
	 return index or 1
	end
	local function GetQualityFromAddress(url)
		url = url:gsub('^//', 'https://')
		local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = 'Referer: ' .. refer})
			if rc ~= 200 then return end
		local base = url:match('.+/')
		local t, i = {}, 1
		local qlty, adr
			for w in answer:gmatch('#EXT%-X%-STREAM%-INF:(.-\n.-)\n') do
				qlty = w:match('RESOLUTION=%d+x(%d+)')
				adr = w:match('\n(.+)')
					if not qlty or not adr then break end
				t[i] = {}
				t[i].Address = base .. adr:gsub('^%./', '') .. '$OPT:NO-STIMESHIFT$OPT:http-referrer=' .. refer
				t[i].qlty = qlty
				i = i + 1
			end
			if i == 1 then return end
			for _, v in pairs(t) do
				v.qlty = tonumber(v.qlty)
				if v.qlty > 0 and v.qlty <= 180 then
					v.qlty = 144
				elseif v.qlty > 180 and v.qlty <= 300 then
					v.qlty = 240
				elseif v.qlty > 300 and v.qlty <= 400 then
					v.qlty = 360
				elseif v.qlty > 400 and v.qlty <= 500 then
					v.qlty = 480
				elseif v.qlty > 500 and v.qlty <= 780 then
					v.qlty = 720
				elseif v.qlty > 780 and v.qlty <= 1200 then
					v.qlty = 1080
				elseif v.qlty > 1200 and v.qlty <= 1500 then
					v.qlty = 1444
				elseif v.qlty > 1500 and v.qlty <= 2800 then
					v.qlty = 2160
				elseif v.qlty > 2800 and v.qlty <= 4500 then
					v.qlty = 4320
				end
				v.Name = v.qlty .. 'p'
			end
		table.sort(t, function(a, b) return a.qlty < b.qlty end)
		for i = 1, #t do
			t[i].Id = i
		end
		m_simpleTV.User.hdvb.Table = t
		local index = GetMaxResolutionIndex(t)
		m_simpleTV.User.hdvb.Index = index
	 return t[index].Address
	end
	local function play(Adr, title)
		local retAdr = GetAddress(Adr:gsub('^$hdvb', ''))
			if not retAdr then
				showError('8')
				m_simpleTV.Http.Close(session)
			 return
			end
		retAdr = GetQualityFromAddress(retAdr)
			if not retAdr then
				showError('9')
				m_simpleTV.Http.Close(session)
			 return
			end
		m_simpleTV.Http.Close(session)
		m_simpleTV.Control.SetTitle(title)
		m_simpleTV.OSD.ShowMessageT({text = title, color = 0xff9999ff, showTime = 1000 * 5, id = 'channelName'})
		m_simpleTV.Control.CurrentAddress = retAdr or 'http://wonky.lostcut.net/vids/error_getlink.avi'
-- debug_in_file(retAdr .. '\n')
	end
	function Qlty_hdvb()
		local t = m_simpleTV.User.hdvb.Table
			if not t then return end
		local index = m_simpleTV.User.hdvb.Index
		t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		if #t > 0 then
			local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 1 + 4)
			if ret == 1 then
				m_simpleTV.User.hdvb.Index = id
				m_simpleTV.Control.SetNewAddress(t[id].Address, m_simpleTV.Control.GetPosition())
				m_simpleTV.Config.SetValue('hdvb_qlty', t[id].qlty)
				m_simpleTV.User.hdvb.qlty = t[id].qlty
			end
		end
	end
		if inAdr:match('^$hdvb') then
			play(inAdr, title)
		 return
		end
	local url = inAdr:gsub('&kinopoisk.+', '')
	local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = 'Referer: ' .. refer})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			showError('2')
		 return
		end
	title = inAdr:match('&kinopoisk=(.+)')
	if title then
		title = m_simpleTV.Common.fromPercentEncoding(title)
	else
		title = 'Hdvb'
	end
	m_simpleTV.User.hdvb.Tabletitle = nil
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	m_simpleTV.Control.SetTitle(title)
	local season = ''
	local season_title = ''
	local seasons = answer:match('name="seasons">.-</select>')
	if seasons then
		local t, i = {}, 1
			for Adr, name in seasons:gmatch('<option.-value="(.-)".->(.-)</option>') do
				t[i] = {}
				t[i].Id = i
				t[i].Name = trim(name)
				t[i].Address = trim(Adr)
				i = i + 1
			end
			if i == 1 then
				showError('5')
			 return
			end
		if i > 2 then
			local _, id = m_simpleTV.OSD.ShowSelect_UTF8('Выберете сезон - ' .. title, 0, t, 5000, 1)
			id = id or 1
			season = t[id].Address
			season_title = ' (' .. t[id].Name .. ')'
			rc, answer = m_simpleTV.Http.Request(session, {url = inAdr:gsub('%?.-$', '') .. '?s=' .. season, headers = 'Referer: ' .. refer})
				if rc ~= 200 then
					m_simpleTV.Http.Close(session)
					showError('6')
				 return
				end
		else
			season = t[1].Address
			local ses = t[1].Name:match('%d+') or '0'
			if tonumber(ses) > 1 then
				season_title = ' (' .. t[1].Name .. ')'
			end
		end
		season = '&s=' .. season
	end
	local transl = ''
	local tr = answer:match('name="translation">.-</div>')
	if tr then
		local t, i = {}, 1
			for Adr, name in tr:gmatch('<option.-value="(.-)".->(.-)</option>') do
				t[i] = {}
				t[i].Id = i
				t[i].Name = trim(name)
				t[i].Address = trim(Adr)
				i = i + 1
			end
			if i == 1 then
				showError('3')
			 return
			end
		if i > 2 then
			local _, id = m_simpleTV.OSD.ShowSelect_UTF8('Выберете перевод - ' .. title, 0, t, 5000, 1)
			id = id or 1
			transl = t[id].Address
			rc, answer = m_simpleTV.Http.Request(session, {url = inAdr:gsub('%?.-$', '') .. '?t=' .. transl, headers = 'Referer: ' .. refer})
				if rc ~= 200 then
					m_simpleTV.Http.Close(session)
					showError('4')
				 return
				end
		else
			transl = t[1].Address
		end
		transl = '&t=' .. transl
	end
	local episodes = answer:match('name="episodes".-</select>')
	if episodes then
		local t, i = {}, 1
			for Adr, name in episodes:gmatch('<option.-value="(.-)".->(.-)</option>') do
				t[i] = {}
				t[i].Id = i
				t[i].Name = trim(name)
				t[i].Address = '$hdvb' .. inAdr:gsub('%?.-$', '') .. '?e=' .. trim(Adr) .. season .. transl
				i = i + 1
			end
			if i == 1 then
				showError('7')
			 return
			end
		m_simpleTV.User.hdvb.Tabletitle = t
		t.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'Qlty_hdvb()'}
		t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		local p = 0
		if i == 2 then
			p = 32 + 128
		end
		t.ExtParams = {FilterType = 2}
		title = title .. season_title
		local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title, 0, t, 5000, p)
		id = id or 1
		inAdr = t[id].Address
		m_simpleTV.User.hdvb.title = title
		title = title .. ' - ' .. m_simpleTV.User.hdvb.Tabletitle[1].Name
	else
		inAdr = inAdr .. transl
		local t1 = {}
		t1[1] = {}
		t1[1].Id = 1
		t1[1].Name = title
		t1[1].Address = inAdr
		t1.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'Qlty_hdvb()'}
		t1.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		m_simpleTV.OSD.ShowSelect_UTF8('Hdvb', 0, t1, 5000, 64+32+128)
	end
	play(inAdr, title)
