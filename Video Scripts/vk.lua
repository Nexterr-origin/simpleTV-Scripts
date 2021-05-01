-- видеоскрипт для сайта http://vk.com (24/12/20)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: YT.lua, vimeo.lua ...
-- ## открывает подобные ссылки ##
-- https://vk.com/video-33598391_456239036
-- https://vk.com/video2797862_166856999?list=e957bb0f2a63f9c911
-- http://vkontakte.ru/video-208344_73667683
-- https://vk.com/feed?z=video-101982925_456239539%2F1900258e458f45eccc%2Fpl_post_-101982925_3149238
-- https://vk.com/video.php?act=s&oid=-21693490&id=159155218
-- https://vk.com/video_ext.php?oid=-24136539&id=456239830&hash=34e326ffb9cbb93e
-- https://vk.com/videos-53997646?section=album_49667766&z=video-53997646_456239913%2Fclub53997646%2Fpl_-53997646_49667766
-- https://vk.com/video537396248_456239159
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://vk%.com/.+')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://vkontakte%.ru/.+')
		then
		 return
		end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = 'https://smajlik.ru/wp-content/uploads/2017/12/3.png', UseLogo = 1, Once = 1})
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'vk ошибка: ' .. str, showTime = 1000 * 5, color = 0xffff1000, id = 'vk'})
	end
	inAdr = inAdr:gsub('vkontakte%.ru', 'vk%.com')
	inAdr = inAdr:gsub('&id=', '_')
	local oidvid = inAdr:match('(%-?%d+_%d+)')
		if not oidvid then
			showError('1')
		 return
		end
	local userAgent = 'Mozilla/5.0 (Windows NT 10.0; rv:84.0) Gecko/20100101 Firefox/84.0'
	local session = m_simpleTV.Http.New(userAgent)
		if not session then
			showError('2')
		 return
		end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local url = decode64('aHR0cHM6Ly9hcGkudmsuY29tL21ldGhvZC92aWRlby5nZXQ/dmlkZW9zPQ==')
		.. oidvid
		.. decode64('JmFjY2Vzc190b2tlbj02NjcxM2U0N2M4YjU4MDNiZDhlOWIyOGVjMzFiMDFkMDVmZjY1ZTFiZTFjMWYwYTI0Zjc3MjVlMzEwZTAxNzFlOTdjN2MyMjRlOTZlNjQ5MGE2MmJlJnY9NS43Mw==')
	local extOpt = '$OPT:http-user-agent=' .. userAgent
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			showError('3 - ' .. rc)
		 return
		end
	answer = answer:gsub('%[%]', '""')
	require 'json'
	local tab = json.decode(answer)
		if not tab
			or not tab.response
			or not tab.response.count
			or not tab.response.items
			or not tab.response.items[1]
			or not tab.response.items[1].files
			or tab.response.count == 0
		then
			showError('4')
		 return
		end
	local title = tab.response.items[1].title
	local addTitle = 'vk'
	if not title then
		title = addTitle
	else
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
			local poster = tab.response.items[1].photo_320 or 'https://smajlik.ru/wp-content/uploads/2017/12/3.png'
			m_simpleTV.Control.ChangeChannelLogo(poster, m_simpleTV.Control.ChannelID)
		end
		title = addTitle .. ' - ' .. title
	end
		if tab.response.items[1].files.flv_320 then
			m_simpleTV.Control.CurrentAddress = tab.response.items[1].files.flv_320 .. extOpt
		 return
		end
		if tab.response.items[1].files.external
			and not (tab.response.items[1].files.live or tab.response.items[1].files.hls)
		then
			m_simpleTV.Control.ChangeAddress = 'No'
			m_simpleTV.Control.CurrentAddress = tab.response.items[1].files.external
			dofile(m_simpleTV.MainScriptDir_UTF8 .. 'user\\video\\video.lua')
		 return
		end
	local t0 = {}
	if tab.response.items[1].files.mp4_1080 then
		t0[1080] = tab.response.items[1].files.mp4_1080
	end
	if tab.response.items[1].files.mp4_720 then
		t0[720] = tab.response.items[1].files.mp4_720
	end
	if tab.response.items[1].files.mp4_480 then
		t0[480] = tab.response.items[1].files.mp4_480
	end
	if tab.response.items[1].files.mp4_360 then
		t0[360] = tab.response.items[1].files.mp4_360
	end
	if tab.response.items[1].files.mp4_240 then
		t0[240] = tab.response.items[1].files.mp4_240
	end
	local t, i = {}, 1
	local hls
	if #t0 == 0 and (tab.response.items[1].files.hls or tab.response.items[1].files.live) then
		hls = tab.response.items[1].files.hls or tab.response.items[1].files.live
		local rc, answer = m_simpleTV.Http.Request(session, {url = hls})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
				showError('5 - ' .. rc)
			 return
			end
		for w in answer:gmatch('EXT%-X%-STREAM%-INF(.-\n.-)\n') do
			adr = w:match('\n(.+)')
			name = w:match('RESOLUTION=%d+x(%d+)')
				if not adr or not name then break end
			t[i] = {}
			t[i].Name = name .. 'p'
			if not adr:match('^https?://') then
				adr = hls:match('.+/') .. adr
			end
			t[i].Address = adr .. '$OPT:no-ts-trust-pcr' .. extOpt
			t[i].Id = tonumber(name)
			i = i + 1
		end
	else
		for k, v in pairs(t0) do
			t[i] = {}
			t[i].Id = k
			t[i].Name = k .. 'p'
			t[i].Address = v .. '$OPT:NO-STIMESHIFT' .. extOpt
			i = i + 1
		end
	end
	m_simpleTV.Http.Close(session)
		if i == 1 then
				if hls then
					m_simpleTV.Control.CurrentAddress = hls .. '$OPT:no-ts-trust-pcr'
					m_simpleTV.Control.CurrentTitle_UTF8 = title
				 return
				end
			showError('6')
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('vk_qlty') or 5000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 5000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
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
			t.ExtParams = {LuaOnOkFunName = 'vkSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	function vkSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('vk_qlty', id)
	end
-- debug_in_file(t[index].Address .. '\n')