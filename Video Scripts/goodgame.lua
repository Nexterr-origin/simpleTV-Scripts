-- видеоскрипт для сайта https://goodgame.ru (28/4/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: twitch.lua, youtube.lua
-- ## открывает подобные ссылки ##
-- https://goodgame.ru/channel/Pomi
-- https://goodgame.ru/video/63424/
-- https://goodgame.ru/clip/506085/
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
		if not inAdr then return end
		if not inAdr:match('^https?://goodgame%.ru') then return end
	local logo = '/images/svg/new-logo.svg'
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = 'https://goodgame.ru' .. logo, TypeBackColor = 0, UseLogo = 1, Once = 1})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'erorr'
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'goodgame ошибка: ' .. str, showTime = 1000 * 5, color = 0xffff1000, id = 'channelName'})
	end
	local userAgent = 'Mozilla/5.0 (Windows NT 10.0; rv:88.0) Gecko/20100101 Firefox/88.0'
	local session = m_simpleTV.Http.New(userAgent)
		if not session then
			showError('0')
		 return
		end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			showError('1 - ' .. rc)
		 return
		end
	answer = answer:gsub('\\/', '/')
	local extOpt = '$OPT:http-user-agent=' .. userAgent
	local channelTopInfo = answer:match('var channelTopInfo =.-}')
		if not channelTopInfo then
			local twitch = answer:match('https?://player%.twitch%.tv/%?channel=([^"]+)')
				if twitch then
					m_simpleTV.Control.ChangeAddress = 'No'
					twitch = 'https://www.twitch.tv/' .. twitch
					m_simpleTV.Control.CurrentAddress = twitch
					dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
				 return
				end
			local youtube = answer:match('https?://www%.youtube%.com/embed/[^"]+')
				if youtube then
					m_simpleTV.Control.ChangeAddress = 'No'
					m_simpleTV.Control.CurrentAddress = youtube
					dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
				 return
				end
			local clip = answer:match('http[^\'"<>]+%.mp4')
				if clip then
					clip = clip .. extOpt .. '$OPT:POSITIONTOCONTINUE=0$OPT:NO-STIMESHIFT'
					local title = answer:match('game="([^"]+.)') or 'goodgame'
					local header = answer:match('streamer="([^"]+)') or ''
					local avatar = answer:match('avatar="([^"]+)')
					title = header .. ': ' .. title
					m_simpleTV.Control.CurrentAddress = clip
					m_simpleTV.Control.CurrentTitle_UTF8 = title
					m_simpleTV.OSD.ShowMessageT({text = title, showTime = 1000 * 5, color = 0xff9bffff, id = 'channelName'})
					if m_simpleTV.Control.MainMode == 0 then
						avatar = avatar or logo
						avatar = avatar:gsub('^/', 'https://goodgame.ru/')
						m_simpleTV.Control.ChangeChannelLogo(avatar, m_simpleTV.Control.ChannelID)
						m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
					end
				 return
				end
			showError('3')
		 return
		end
	local channel = answer:match('/player%?([^"]+)') or answer:match('channel="(%d+)')
		if not channel then
			showError('2')
		 return
		end
	local title = channelTopInfo:match('"title":"(.-)",') or 'goodgame'
	local header = channelTopInfo:match('"streamer":"(.-)",') or ''
	local avatar = channelTopInfo:match('"avatar":"([^"]+)')
	title = unescape3(title)
	title = title:gsub('%?%?', '')
	title = header .. ': ' .. title
	if m_simpleTV.Control.MainMode == 0 then
		avatar = avatar or logo
		avatar = avatar:gsub('^/', 'https://goodgame.ru/')
		m_simpleTV.Control.ChangeChannelLogo(avatar, m_simpleTV.Control.ChannelID)
		m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
	end
	local offline, poster = answer:match('"channel_status":"(.-)","channel_poster":"(.-)"')
		if offline == 'offline' then
			if poster then
				m_simpleTV.Control.CurrentAddress = poster .. '$OPT:image-duration=5'
			end
			title = 'НЕ В СЕТИ\n\n' .. title
			m_simpleTV.Control.CurrentTitle_UTF8 = title
			m_simpleTV.OSD.ShowMessageT({text = title, showTime = 1000 * 6, color = 0xffff1000, id = 'channelName'})
		 return
		end
	local retAdr = 'https://hls.goodgame.ru/manifest/' .. channel .. '_master.m3u8'
	local rc, answer1 = m_simpleTV.Http.Request(session, {url = retAdr})
	m_simpleTV.Http.Close(session)
	if rc ~= 200 then
		answer1 = ''
	end
	local t, i = {}, 1
	local name, adr
		for w in answer1:gmatch('EXT%-X%-STREAM%-INF(.-%.m3u8)') do
			adr = w:match('\n(.-%.m3u8)')
			name = w:match('RESOLUTION=%d+x(%d+)')
			if adr and name then
				t[i] = {}
				t[i].Id = tonumber(name)
				t[i].Name = name .. 'p'
				t[i].Address = 'https://hls.goodgame.ru' .. adr .. extOpt .. '$OPT:adaptive-hls-ignore-discontinuity'
				i = i + 1
			end
		end
		if i == 1 then
			local twitch = answer:match('https?://player%.twitch%.tv/%?channel=([^"]+)')
				if twitch then
					m_simpleTV.Control.ChangeAddress = 'No'
					twitch = 'https://www.twitch.tv/' .. twitch
					m_simpleTV.Control.CurrentAddress = twitch
					dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
				 return
				end
			local youtube = answer:match('https?://www%.youtube%.com/embed/[^"]+')
				if youtube then
					m_simpleTV.Control.ChangeAddress = 'No'
					m_simpleTV.Control.CurrentAddress = youtube
					dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
				 return
				end
			local smil = channelTopInfo:match('"source":"([^"]+)')
				if smil then
					smil = smil:gsub('%.smil', '.m3u8')
					smil = smil .. extOpt
					m_simpleTV.Control.CurrentAddress = smil .. extOpt .. '$OPT:adaptive-hls-ignore-discontinuity'
					m_simpleTV.Control.CurrentTitle_UTF8 = title
					m_simpleTV.OSD.ShowMessageT({text = title, showTime = 1000 * 5, color = 0xff9bffff, id = 'channelName'})
				 return
				end
			showError('4')
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('goodgame_qlty') or 5000)
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
			t.ExtParams = {LuaOnOkFunName = 'goodgameSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	m_simpleTV.OSD.ShowMessageT({text = title, showTime = 1000 * 5, color = 0xff9bffff, id = 'channelName'})
	function goodgameSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('goodgame_qlty', id)
	end
-- debug_in_file(t[index].Address .. '\n')
