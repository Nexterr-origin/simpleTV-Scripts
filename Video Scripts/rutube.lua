-- видеоскрипт для сайта https://rutube.ru (17/1/22)
-- Copyright © 2017-2022 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видеоскрипт: mediavitrina.lua
-- ## открывает подобные ссылки ##
-- https://rutube.ru/video/49bde61061d4db358977418d89f0bf83/
-- https://rutube.ru/live/video/ef31151c1c1af2e9eb85fc213abb4ef2/
-- https://rutube.ru/live/video/54395b96ad1a7b49966f46a6eee370a4
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://rutube%.ru/.+') then return end
	local logo ='https://raw.githubusercontent.com/Nexterr-origin/simpleTV-Images/main/rutube.png'
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.OSD.ShowMessageT({text = 'RUTUBE', showTime = 5000, id = 'channelName'})
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = logo, UseLogo = 1, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local function showMsg(str)
		local t = {text = 'RUTUBE - ошибка ' .. str, showTime = 1000 * 8, color = ARGB(255, 255, 102, 0), id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local id = inAdr:match('/video/(%w+)') or inAdr:match('/audio/(%w+)')
		if not id or inAdr:match('/tags/') then
			showMsg('неверная ссылке')
		 return
		end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:86.0) Gecko/20100101 Firefox/86.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	function rutubeSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('rutube_qlty', tostring(id))
	end
	function rutubeLiveSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('rutube_live_qlty', tostring(id))
	end
	local url = decode64('aHR0cHM6Ly9ydXR1YmUucnUvYXBpL3BsYXkvb3B0aW9ucy8') .. id
	local headers = 'Referer: ' .. inAdr
	local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = headers})
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
	local tab = json.decode(answer)
		if not tab then
			showMsg('2')
		 return
		end
	local retAdr, live
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
		m_simpleTV.Http.Close(session)
			if tab.player == 'iframe' and tab.iframe_url then
				retAdr = tab.iframe_url:gsub('^//', 'https://')
				m_simpleTV.Control.ChangeAddress = 'No'
				m_simpleTV.Control.CurrentAddress = retAdr
				dofile(m_simpleTV.MainScriptDir .. 'user/video/video.lua')
			 return
			end
		showMsg('3, стрим не найден')
	 return
	end
	local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			showMsg('4')
		 return
		end
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
			local thumbnail_url
			if tab.thumbnail_url then
				thumbnail_url = tab.thumbnail_url .. '?size=1'
			end
			thumbnail_url = thumbnail_url or logo
			m_simpleTV.Control.ChangeChannelLogo(thumbnail_url, m_simpleTV.Control.ChannelID)
		end
	end
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	m_simpleTV.OSD.ShowMessageT({text = title, showTime = 5000, id = 'channelName'})
	local exOpt = '$OPT:NO-STIMESHIFT'
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
				t0[#t0].Address = adr .. exOpt
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
