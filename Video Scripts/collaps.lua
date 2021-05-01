-- видеоскрипт для видеобалансера "Collaps" https://collaps.org (5/2/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://api1603044906.placehere.link/embed/movie/7059
-- https://api.kinogram.best/embed/kp/5928
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://api[%d]*%..-/embed/movie/%d+')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://api[%d]*%..-/embed/kp/%d+')
			and not m_simpleTV.Control.CurrentAddress:match('^%$collaps')
		then
		 return
		end
	local inAdr = m_simpleTV.Control.CurrentAddress
	require 'json'
	if inAdr:match('^$collaps') or not inAdr:match('&kinopoisk') then
		m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
		m_simpleTV.Interface.SetBackground({BackColor = 0, BackColorEnd = 255, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:85.0) Gecko/20100101 Firefox/85.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 12000)
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.collaps then
		m_simpleTV.User.collaps = {}
	end
	local refer = 'https://filmhd1080.xyz/'
	local host = inAdr:match('https?://.-/')
	local function collapsIndex(t)
		local lastQuality = tonumber(m_simpleTV.Config.GetValue('collaps_qlty') or 5000)
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
	local function GetcollapsAdr(url)
		url = url:gsub('^$collaps', '')
		url = url:gsub('https://', 'http://')
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
			if rc ~= 200 then return end
		local base = url:match('https?://.+/')
		local t, i = {}, 1
			for w in answer:gmatch('EXT%-X%-STREAM.-\n.-\n') do
				adr = w:match('\n(.-)%c')
				name = w:match('RESOLUTION=%d+x(%d+)')
					if not adr or not name then break end
				name = tonumber(name)
				t[i] = {}
				t[i].Name = name .. 'p'
				if not adr:match('^http') then
					adr = base .. adr
				end
				t[i].Address = adr
				t[i].qlty = name
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
			t[i].Address = m_simpleTV.Common.fromPercentEncoding(t[i].Address)
			t[i].Address = t[i].Address:gsub('%.m3u8$', '-a1.m3u8'):gsub('https://', 'http://') .. '$OPT:NO-STIMESHIFT'
		end
		m_simpleTV.User.collaps.Tab = t
		local index = collapsIndex(t)
	 return t[index].Address
	end
	function Qlty_collaps()
		local t = m_simpleTV.User.collaps.Tab
			if not t or #t == 0 then return end
		m_simpleTV.Control.ExecuteAction(37)
		local index = collapsIndex(t)
		t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 1 + 4)
		if ret == 1 then
			m_simpleTV.Control.SetNewAddress(t[id].Address, m_simpleTV.Control.GetPosition())
			m_simpleTV.Config.SetValue('collaps_qlty', t[id].qlty)
		end
	end
	local function play(Adr, title)
		local retAdr = GetcollapsAdr(Adr)
		m_simpleTV.Http.Close(session)
			if not retAdr then
				m_simpleTV.Control.CurrentAddress = 'http://wonky.lostcut.net/vids/error_getlink.avi'
			 return
			end
		if m_simpleTV.Control.CurrentTitle_UTF8 then
			m_simpleTV.Control.CurrentTitle_UTF8 = title
		end
		m_simpleTV.OSD.ShowMessageT({text = title, color = 0xff9999ff, showTime = 1000 * 5, id = 'channelName'})
		m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
	end
		if inAdr:match('^$collaps') then
			play(inAdr, title)
		 return
		end
	inAdr = inAdr:gsub('&kinopoisk', ''):gsub('buildplayer%.com', 'iframecdn.club')
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr, headers = 'Referer: ' .. refer})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			m_simpleTV.OSD.ShowMessageT({text = 'collaps ошибка[1]-' .. rc, color = 0xffff1000, showTime = 1000 * 5, id = 'channelName'})
		 return
		end
	local season_title = ''
	local seson = ''
	local title = m_simpleTV.Control.CurrentTitle_UTF8 or 'Collaps'
	m_simpleTV.Control.SetTitle(title)
	local serials = answer:match('seasons:(%[.-%]}%])')
	if serials then
		serials = serials:gsub('%[%]', '""')
		local tab = json.decode(serials)
			if not tab then return end
		local t0, i = {}, 1
			while true do
					if not tab[i] then break end
				t0[i] = {}
				t0[i].Name = tab[i].season .. ' сезон'
				t0[i].Address = i
				i = i + 1
			end
			if i == 1 then return end
		if i > 2 then
			table.sort(t0, function(a, b) return a.Name < b.Name end)
			for i = 1, #t0 do
				t0[i].Id = i
			end
			t0.ExtParams = {FilterType = 2}
			local _, id = m_simpleTV.OSD.ShowSelect_UTF8('Выберете сезон - ' .. title, 0, t0, 5000, 1)
			id = id or 1
		 	seson = t0[id].Address
			season_title = ' (' .. t0[id].Name .. ')'
		else
			seson = t0[1].Address
			local ses = t0[1].Name:match('%d+') or '0'
			if tonumber(ses) > 1 then
				season_title = ' (' .. t0[1].Name .. ')'
			end
		end
		local t, i = {}, 1
			while tab[seson].episodes[i] do
				t[i] = {}
				t[i].Id = i
				t[i].Name = tab[seson].episodes[i].episode .. ' серия'
				t[i].Address = '$collaps' .. tab[seson].episodes[i].hls
				i = i + 1
			end
			if i == 1 then return end
		t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		t.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'Qlty_collaps()'}
		local p = 0
		if i == 2 then
			p = 32 + 128
		end
		t.ExtParams = {FilterType = 2}
		title = title .. season_title
		local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title, 0, t, 5000, p)
		id = id or 1
		inAdr = t[id].Address
	else
		inAdr = answer:match('hls:%s*"([^"]+)')
			if not inAdr then
				m_simpleTV.Http.Close(session)
				m_simpleTV.OSD.ShowMessageT({text = 'collaps ошибка[3]', color = 0xff99ff99, showTime = 1000 * 5, id = 'channelName'})
			 return
			end
		title = answer:match('title:%s*"(.-)",') or 'Collaps'
		title = title:gsub('\\u0026', '&')
		local t1 = {}
		t1[1] = {}
		t1[1].Id = 1
		t1[1].Name = title
		t1[1].Address = inAdr
		t1.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'Qlty_collaps()'}
		t1.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		m_simpleTV.OSD.ShowSelect_UTF8('Collaps', 0, t1, 5000, 64+32+128)
	end
	play(inAdr, title)