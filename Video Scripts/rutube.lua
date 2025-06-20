-- видеоскрипт для сайта https://rutube.ru https://rutube.sport (19/5/25)
-- Copyright © 2017-2025 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видеоскрипт: mediavitrina.lua
-- ## открывает подобные ссылки ##
-- https://rutube.ru/video/c32bacf2f2ef213d4cf86cedc0f88cf5
-- https://rutube.ru/live/video/54395b96ad1a7b49966f46a6eee370a4
-- https://rutube.ru/video/c58f502c7bb34a8fcdd976b221fca292/
-- https://rutube.sport/video/aznaur-kalsynov-vs-vyacheslav-borisenok/
-- https://rutube.ru/video/private/884fb55f07a97ab673c7d654553e0f48/?p=x2QojCumHTS3rsKHWXN8Lg
-- https://rutube.ru/shorts/69f465c1279f02766a5eb341e127a546/
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://rutube%.ru/.+')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://rutube%.sport/.+')
		then
		 return
		end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local function showMsg(str)
		local t = {text = 'RUTUBE - ошибка ' .. str, showTime = 1000 * 8, color = ARGB(255, 255, 102, 0), id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:134.0) Gecko/20100101 Firefox/134.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local id
	if inAdr:match('//rutube%.sport') then
		local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			answer = ''
		end
		id = answer:match('/play/embed/([^&"]+)')
	else
		id = inAdr:match('/video/private/([^&"]+)' or inAdr:match('/audio/([^&"]+)') ) or inAdr:match('/play/embed/([^&"]+)') or inAdr:match('/video/([^&"]+)') or inAdr:match('/shorts/([^&"]+)')
	end
		if not id or inAdr:match('/tags/') then
			showMsg('неверная ссылке')
		 return
		end
	function rutubeSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('rutube_qlty', tostring(id))
	end
	function rutubeLiveSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('rutube_live_qlty', tostring(id))
	end
	local url = decode64('aHR0cHM6Ly9ydXR1YmUucnUvYXBpL3BsYXkvb3B0aW9ucy8') .. id ..  '/?no_404=true&referer=https%253A%252F%252Ftnt-online.ru%252F&pver=v2&client=wdp'
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			showMsg('1, видео не доступно')
		 return
		end
	answer = answer:gsub('\\', '\\\\')
	answer = answer:gsub('\\"', '\\\\"')
	answer = answer:gsub('\\/', '/')
	answer = answer:gsub('%s*%[%]', '""')
	require 'json'
	local err, tab = pcall(json.decode, answer)
		if not tab then
			showMsg('2')
		 return
		end
	local retAdr, live
		if tab.player == 'iframe' and tab.iframe_url then
			m_simpleTV.Http.Close(session)
			retAdr = tab.iframe_url:gsub('^//', 'https://')
			m_simpleTV.Control.ChangeAddress = 'No'
			m_simpleTV.Control.CurrentAddress = retAdr
			dofile(m_simpleTV.MainScriptDir .. 'user/video/video.lua')
		 return
		end
	if tab.video_balancer
		and tab.video_balancer.m3u8
	then
		retAdr = tab.video_balancer.m3u8
	elseif tab.live_streams
		and tab.live_streams.hls
		and tab.live_streams.hls[1]
		and tab.live_streams.hls[1].url
	then
		retAdr = tab.live_streams.hls[1].url
		live = true
	else
		showMsg('3, стрим не найден')
	 return
	end
	local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			showMsg('4')
		 return
		end
	local exOpt = ''
	if not live then
		local title = tab.title
		local addTitle = 'RUTUBE'
		if not title then
			title = addTitle
		else
			if m_simpleTV.Control.MainMode == 0 then
				title = unescape3(title)
				title = title:gsub('\\"', '"')
				title = addTitle .. ' - ' .. title
				m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
				local thumbnail_url = tab.thumbnail_url or 'https://raw.githubusercontent.com/Nexterr-origin/simpleTV-Images/main/rutube.png'
				m_simpleTV.Control.ChangeChannelLogo(thumbnail_url, m_simpleTV.Control.ChannelID)
			end
		end
		m_simpleTV.Control.CurrentTitle_UTF8 = title
		m_simpleTV.OSD.ShowMessageT({text = title, showTime = 5000, id = 'channelName'})
		exOpt = '$OPT:NO-STIMESHIFT'
	end
	local t0 = {}
	if live then
		for w in answer:gmatch('EXT%-X%-STREAM%-INF.-\n.-\n') do
			local adr = w:match('\n(.-)\n')
			local name = w:match('BANDWIDTH=(%d+)')
			if adr and name then
				name = tonumber(name)
				t0[#t0 + 1] = {}
				t0[#t0].Id = name
				t0[#t0].Name = math.floor(name / 100000) * 100 .. ' кбит/с'
				t0[#t0].Address = adr
			end
		end
	else
		for w in answer:gmatch('EXT%-X%-STREAM%-INF.-\n.-\n') do
			local adr = w:match('\n(.-)\n')
			local name = w:match('RESOLUTION=%d+x(%d+)')
			if adr and name then
				name = tonumber(name)
				t0[#t0 + 1] = {}
				t0[#t0].Id = name
				t0[#t0].Name = name .. 'p'
				t0[#t0].Address = adr .. exOpt
			end
		end
	end
		if #t0 == 0 then
			m_simpleTV.Control.CurrentAddress = retAdr .. exOpt
		 return
		end
	local hash, t = {}, {}
		for i = 1, #t0 do
			if not hash[t0[i].Id] then
				t[#t + 1] = t0[i]
				hash[t0[i].Id] = true
			end
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality
	if live then
		lastQuality = tonumber(m_simpleTV.Config.GetValue('rutube_live_qlty') or 100000000)
	else
		lastQuality = tonumber(m_simpleTV.Config.GetValue('rutube_qlty') or 100000000)
	end
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 100000000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
		t[#t + 1] = {}
		t[#t].Id = 500000000
		t[#t].Name = '▫ адаптивное'
		t[#t].Address = retAdr .. exOpt
		index = #t
			for i = 1, #t do
				if t[i].Id >= lastQuality then
					index = i
				 break
				end
			end
		if index > 1 then
			if t[index].Id > lastQuality then
				index = index - 1
			end
		end
		if m_simpleTV.Control.MainMode == 0 then
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
			if live then
				t.ExtParams = {LuaOnOkFunName = 'rutubeLiveSaveQuality'}
			else
				t.ExtParams = {LuaOnOkFunName = 'rutubeSaveQuality'}
			end
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
-- debug_in_file(t[index].Address .. '\n')
