-- видеоскрипт для видеобалансера "Hdvb" https://hdvb.tv (25/3/22)
-- Copyright © 2017-2022 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://vid1647324294.vb17121coramclean.pw/movie/c77fd8d3ec03509000778d9af49f8d86/iframe
-- https://vid1648222294.vb17121coramclean.pw/serial/77de2d434d279e861121237797af59a26ae2a19b53718d36ce15bcca908eaed2/iframe
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://vid%d+.-/%a+/%x+/iframe')
			and not m_simpleTV.Control.CurrentAddress:match('^$hdvb')
		then
		 return
		end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
	if inAdr:match('^$hdvb') or not inAdr:match('&kinopoisk') then
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Interface.SetBackground({BackColor = 0, BackColorEnd = 255, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
		end
	end
	local function showMsg(str)
		local t = {text = 'hdvb ошибка: ' .. str, color = ARGB(255, 255, 102, 0), showTime = 5000, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	require 'json'
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:98.0) Gecko/20100101 Firefox/98.0')
		if not session then return end
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
	local headers = 'Referer: http://filmhd1080.net/'
	local title
	if m_simpleTV.User.hdvb.Tabletitle then
		local index = m_simpleTV.Control.GetMultiAddressIndex()
		if index then
			title = m_simpleTV.User.hdvb.title .. ' - ' .. m_simpleTV.User.hdvb.Tabletitle[index].Name
		end
	end
	local function GetAddress(Adr)
			if Adr:match('^http') then
			 return Adr
			end
		Adr = host .. '/playlist/' .. file .. '.txt'
		rc, answer = m_simpleTV.Http.Request(session, {url = Adr, headers = m_simpleTV.User.hdvb.headers, method = 'post'})
			if rc ~= 200 then return end
	 return answer
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
		local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = headers})
			if rc ~= 200 then return end
		local base = url:match('.+/')
		local t, i = {}, 1
		local qlty, adr
			for w in answer:gmatch('#EXT%-X%-STREAM%-INF:(.-\n.-)\n') do
				qlty = w:match('RESOLUTION=%d+x(%d+)')
				adr = w:match('\n(.+)')
					if not qlty or not adr then break end
				t[i] = {}
				t[i].Address = base .. adr:gsub('^%./', '') .. '$OPT:NO-STIMESHIFT'
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
				showMsg('8')
				m_simpleTV.Http.Close(session)
			 return
			end
		retAdr = GetQualityFromAddress(retAdr)
			if not retAdr then
				showMsg('9')
				m_simpleTV.Http.Close(session)
			 return
			end
		m_simpleTV.Http.Close(session)
		m_simpleTV.Control.SetTitle(title)
		m_simpleTV.OSD.ShowMessageT({text = title, color = ARGB(255, 153, 153, 255), showTime = 5000, id = 'channelName'})
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
	local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = headers})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			showMsg('2')
		 return
		end
	title = inAdr:match('&kinopoisk=(.+)')
	m_simpleTV.User.hdvb.host = inAdr:match('^https?://[^/]+')
	if title then
		title = m_simpleTV.Common.fromPercentEncoding(title)
	else
		title = 'Hdvb'
	end
	m_simpleTV.User.hdvb.Tabletitle = nil
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	m_simpleTV.Control.SetTitle(title)
	answer = answer:gsub('\\/', '/')
	local file = answer:match('"file":"([^"]+)')
	local key = answer:match('"key":"([^"]+)')
		if not file or not key then return end
	inAdr = file:gsub('^~', '/playlist/')
	url = m_simpleTV.User.hdvb.host .. inAdr
	if not url:match('%.txt') then
		url = url .. '.txt'
	end
	m_simpleTV.User.hdvb.headers = headers .. '\nX-CSRF-TOKEN: ' .. key
	rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = m_simpleTV.User.hdvb.headers, method = 'post'})
		if rc ~= 200 then return end
	local seasons = answer:match('^%s*[%[{]+')
	if seasons then
-- debug_in_file(retAdr .. '\n')
m_simpleTV.OSD.ShowMessageT({text = 'TODO', color = ARGB(255, 153, 153, 255), showTime = 5000, id = 'channelName'})
	 return
	else
		inAdr = answer
		local t1 = {}
		t1[1] = {}
		t1[1].Id = 1
		t1[1].Name = title
		t1[1].Address = inAdr
		t1.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'Qlty_hdvb()'}
		t1.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		m_simpleTV.OSD.ShowSelect_UTF8('Hdvb', 0, t1, 10000, 64 + 32 + 128)
	end
	play(inAdr, title)