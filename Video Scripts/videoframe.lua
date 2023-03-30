-- видеоскрипт для видеобалансера "videoframe" (30/3/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- http://videoframe.space/frameindex.php?kp=5928
-- https://videoframe.at/movie/4204258p119/iframe
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
		if not inAdr then return end
		if not inAdr:match('^https?://videoframe%.') and not inAdr:match('^$videoframe') then return end
	require 'json'
	inAdr = inAdr:gsub('videoframe%.at', 'videoframe.space'):gsub('^https', 'http')
	if inAdr:match('^$videoframe') then
		m_simpleTV.Interface.SetBackground({BackColor = 0, BackColorEnd = 255, PictFileName = '', TypeBackColor = 0, UseLogo = 3, Once = 1})
	end
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
	if inAdr:match('^$videoframe') or not inAdr:match('&kinopoisk') then
		m_simpleTV.Interface.SetBackground({BackColor = 0, BackColorEnd = 255, PictFileName = '', TypeBackColor = 0, UseLogo = 3, Once = 1})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:96.0) Gecko/20100101 Firefox/96.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 16000)
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.videoframe then
		m_simpleTV.User.videoframe = {}
	end
	if not m_simpleTV.User.videoframe.qlty then
		m_simpleTV.User.videoframe.qlty = tonumber(m_simpleTV.Config.GetValue('Videoframe_qlty') or '10000')
	end
	local title
	if m_simpleTV.User.videoframe.Tabletitle then
		local index = m_simpleTV.Control.GetMultiAddressIndex()
		if index then
			title = m_simpleTV.User.videoframe.title .. ' - ' .. m_simpleTV.User.videoframe.Tabletitle[index].Name
		end
	end
	local host = inAdr:match('(https?://.-)/')
	local refer = 'http://the-cinema.online'
	local function GetMaxResolutionIndex(t)
		local index
		for u = 1, #t do
				if t[u].qlty and m_simpleTV.User.videoframe.qlty < t[u].qlty then break end
			index = u
		end
	 return index or 1
	end
	local function GetvideoframeAddress(answer)
		local typ = answer:match('type = \'(.-)\'')
		local token = answer:match('token = \'(.-)\'')
			if not token or not typ then return end
		local body = 'token=' .. token .. '&type=' .. typ
		local rc, answer = m_simpleTV.Http.Request(session, {body = body, url = 'https://videoframe.space/loadvideo', method = 'post', headers = 'Referer: https://videoframe.space/\nX-REF: empty-referrer\nOrigin: https://videoframe.space'})
			if rc ~= 200 or (rc == 200 and answer == '') then return end
		local tab = json.decode(answer:gsub('%[%]', '""'))
			if not tab then return end
		local retAdr
		if tab.url or tab.src then
			retAdr = tab.url or tab.src
		end
		if tab.show and tab.show.links and tab.show.links.url then
			retAdr = tab.show.links.url
		end
		rc, answer = m_simpleTV.Http.Request(session, {url = retAdr, headers = 'Referer: ' .. refer})
			if rc ~= 200 then return end
		local base = retAdr:match('(http.+/)')
		local t, i = {}, 1
		local qlty, adr
			for w in answer:gmatch('#EXT%-X%-STREAM%-INF:(.-m3u8)') do
				qlty = w:match('RESOLUTION=%d+x(%d+)')
				adr = w:match('\n(.+)')
					if not qlty or not adr then break end
				if not adr:match('^http') then
					adr = base .. adr:gsub('%.%./', ''):gsub('^/', ''):gsub('%./', '')
				end
				t[i] = {}
				t[i].Address = adr:gsub('https?://', 'http://'):gsub(':hls:manifest%.m3u8$', '')
							.. '$OPT:NO-STIMESHIFT$OPT:demux=mp4,any$OPT:NO-STIMESHIFT$OPT:http-referrer=' .. refer
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
		m_simpleTV.User.videoframe.Table = t
		local index = GetMaxResolutionIndex(t)
		m_simpleTV.User.videoframe.Index = index
	 return t[index].Address
	end
	function Qlty_Videoframe()
		local t = m_simpleTV.User.videoframe.Table
			if not t then return end
		local index = m_simpleTV.User.videoframe.Index
		t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		if #t > 1 then
			local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('⚙  Качество', index - 1, t, 10000, 1 + 4 + 2)
			if ret == 1 then
				m_simpleTV.User.videoframe.Index = id
				m_simpleTV.Control.SetNewAddress(t[id].Address, m_simpleTV.Control.GetPosition())
				m_simpleTV.Config.SetValue('Videoframe_qlty', t[id].qlty)
				m_simpleTV.User.videoframe.qlty = t[id].qlty
			end
		end
	end
	local function play(answer, title)
		local retAdr = GetvideoframeAddress(answer)
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
	 return
	end
	local url = inAdr:gsub('&kinopoisk.+', ''):gsub('^$videoframe', '')
	local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = 'Referer: ' .. refer})
		if rc == 404 and answer and answer:match('Sorry') then
			m_simpleTV.Http.Close(session)
			m_simpleTV.OSD.ShowMessageT({text = 'Контент недоступен в вашем регионе', color = 0xff99ff99, showTime = 1000 * 10, id = 'channelName'})
			m_simpleTV.Control.CurrentAddress = 'https://s3.ap-south-1.amazonaws.com/ttv-videos/InVideo___This_is_where_ypprender_1554571391885.mp4'
		 return
		end
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			m_simpleTV.OSD.ShowMessageT({text = 'videoframe ошибка[1]-' .. rc, color = 0xff99ff99, showTime = 1000 * 5, id = 'channelName'})
		 return
		end
		if inAdr:match('^$videoframe') then
			play(answer, title)
		 return
		end
	local typ = answer:match('type = \'(.-)\'')
		if not typ then
			m_simpleTV.Http.Close(session)
			m_simpleTV.OSD.ShowMessageT({text = 'videoframe ошибка[2]', color = 0xff99ff99, showTime = 1000 * 5, id = 'channelName'})
		 return
		end
	m_simpleTV.User.videoframe.Tabletitle = nil
	title = answer:match('\'main%-title\'>(.-)<') or 'videoframe'
	title = title:gsub('\n', ''):gsub('%s%s+', '')
	m_simpleTV.User.videoframe.title = title
	local season_title = ''
	local transl = answer:match('\'bar%-button pull%-right\'.-</div>')
	if transl then
		local t, i = {}, 1
		local name, Adr
			for vve in transl:gmatch('<a href.-</') do
				name = vve:match('.+>(.-)</')
				Adr = vve:match('href=\'(.-)\'')
					if not name or not Adr then break end
				t[i] = {}
				t[i].Id = i
				t[i].Name = name
				t[i].Address = host .. Adr
				i = i + 1
			end
		if i > 2 then
			local _, id = m_simpleTV.OSD.ShowSelect_UTF8('Выберете перевод - ' .. title, 0, t, 10000, 1)
			if not id then
				id = 1
			end
		 	inAdr = t[id].Address
			inAdr = inAdr:gsub('%?.-$', '')
			rc, answer = m_simpleTV.Http.Request(session, {url = inAdr, headers = 'Referer: ' .. refer})
				if rc ~= 200 then
					m_simpleTV.Http.Close(session)
					m_simpleTV.OSD.ShowMessageT({text = 'videoframe ошибка[3]-' .. rc, color = 0xff99ff99, showTime = 1000 * 5, id = 'channelName'})
				 return
				end
		end
	end
	if typ == 'serial' then
		local sesons = answer:match('fp%-title\'(.-)<span class=\'muted\'')
		if sesons then
			local t, i, nameepi = {}, 1
				for Address, nameseasons in sesons:gmatch('<a href=\'(.-)\'.->(.-)</a>') do
					t[i] = {}
					t[i].Name = nameseasons
					t[i].Address = host .. Address
					i = i + 1
				end
			t = table_reverse(t)
			for i = 1, #t do
				t[i].Id = i
			end
			if i > 2 then
				local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title .. ' - выберите сезон', 0, t, 10000, 1)
				if not id then id = 1 end
				inAdr = t[id].Address
				season_title = ' (' .. t[id].Name .. ')'
		 	else
				inAdr = t[1].Address
				local ses = t[1].Name:match('%d+')
				if tonumber(ses) > 1 then
					season_title = ' (' .. t[1].Name .. ')'
				end
			end
			rc, answer = m_simpleTV.Http.Request(session, {url = inAdr, headers = 'Referer: ' .. refer})
				if rc ~= 200 then
					m_simpleTV.Http.Close(session)
					m_simpleTV.OSD.ShowMessageT({text = 'videoframe ошибка[3.1]-' .. rc, color = 0xff99ff99, showTime = 1000 * 5, id = 'channelName'})
				 return
				end
		end
		local serias = answer:match('<span class=\'muted\'>.-</div>')
		if serias then
			local t, i = {}, 1
				for Address, nameserias in serias:gmatch('<a href=\'(.-)\'.->(.-)</a>') do
					t[i] = {}
					t[i].Name = nameserias
					t[i].Address = '$videoframe' .. host .. Address
					i = i + 1
				end
			t = table_reverse(t)
			for i = 1, #t do
				t[i].Id = i
			end
			m_simpleTV.User.videoframe.Tabletitle = t
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
			t.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'Qlty_Videoframe()'}
			t.ExtParams = {FilterType = 2}
			local p = 0
			if i == 2 then
				p = 32
			end
			title = title .. season_title
			local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title, 0, t, 10000, p)
			if not id then
				id = 1
			end
			inAdr = t[id].Address
			m_simpleTV.User.videoframe.title = title
			title = title .. ' - ' .. m_simpleTV.User.videoframe.Tabletitle[1].Name
			rc, answer = m_simpleTV.Http.Request(session, {url = inAdr:gsub('/$iframe', '/iframe'):gsub('%$videoframe', '')})
				if rc ~= 200 then
					m_simpleTV.Http.Close(session)
					m_simpleTV.OSD.ShowMessageT({text = 'videoframe ошибка[4]-' .. rc, color = 0xff99ff99, showTime = 1000 * 5, id = 'channelName'})
				 return
				end
		end
	else
		local t1 = {}
		t1[1] = {}
		t1[1].Id = 1
		t1[1].Name = title
		t1[1].Address = inAdr
		t1.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'Qlty_Videoframe()'}
		t1.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		m_simpleTV.OSD.ShowSelect_UTF8('Videoframe', 0, t1, 10000, 32 + 64 + 128)
	end
	play(answer, title)
