-- видеоскрипт для сайта https://www.dailymotion.com (16/7/20)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://www.dailymotion.com/video/x55kod7_ring-tv-live-3_sport
-- http://www.dailymotion.com/embed/video/x51y5j8?logo=0&related=0&info=0&autoPlay=1
-- http://www.dailymotion.com/video/x3m6nld
-- ## прокси ##
local proxy = 'http://proxy-nossl.antizapret.prostovpn.org:29976'
-- '' - нет
-- например 'http://proxy-nossl.antizapret.prostovpn.org:29976'
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://www%.dailymotion%.com') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local logo = 'https://static1.dmcdn.net/neon/prod/img/logo-white.49be20dee5b3f7e3c2a50580c545d6b1.svg'
	local userAgent = 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.79 Safari/537.36'
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = logo, UseLogo = 1, Once = 1})
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'dailymotion ошибка: ' .. str, showTime = 8000, color = 0xffff6600, id = 'channelName'})
	end
	inAdr = inAdr:gsub('http://', 'https://')
	local id = inAdr:match('/video/(%w+)')
		if not id then
			showError('1')
		 return
		end
	local session = m_simpleTV.Http.New(userAgent, proxy, true)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.dailymotion then
		m_simpleTV.User.dailymotion = {}
	end
	local function Thumbs(filmstrip_url, duration, mode)
			if m_simpleTV.Control.MainMode ~= 0 then return end
		m_simpleTV.User.dailymotion.ThumbsInfo = nil
			if not filmstrip_url
				or not duration
				or mode == 'live'
			then
			 return
			end
		m_simpleTV.User.dailymotion.ThumbsInfo = {}
		m_simpleTV.User.dailymotion.ThumbsInfo.duration = duration
		m_simpleTV.User.dailymotion.ThumbsInfo.urlPattern = filmstrip_url
		if not m_simpleTV.User.dailymotion.PositionThumbsHandler then
			local handlerInfo = {}
			handlerInfo.luaFunction = 'PositionThumbs_dailymotion'
			handlerInfo.regexString = '\.dailymotion\.com/.*'
			handlerInfo.sizeFactor = m_simpleTV.User.paramScriptForSkin_thumbsSizeFactor or 0.18
			handlerInfo.backColor = m_simpleTV.User.paramScriptForSkin_thumbsBackColor or 0xfa000000
			handlerInfo.textColor = m_simpleTV.User.paramScriptForSkin_thumbsTextColor or 0xffffffff
			handlerInfo.glowParams = m_simpleTV.User.paramScriptForSkin_thumbsGlowParams or 'glow="7" samples="5" extent="4" color="0xB0000000"'
			handlerInfo.marginBottom = m_simpleTV.User.paramScriptForSkin_thumbsMarginBottom or 0
			handlerInfo.minImageWidth = 80
			handlerInfo.minImageHeight = 45
			m_simpleTV.User.dailymotion.PositionThumbsHandler = m_simpleTV.PositionThumbs.AddHandler(handlerInfo)
		end
	end
	function PositionThumbs_dailymotion(queryType, address, forTime)
		if queryType == 'testAddress' then
		 return false
		end
		if queryType == 'getThumbs' then
				if not m_simpleTV.User.dailymotion.ThumbsInfo then
				 return true
				end
			local t = {}
			t.playAddress = address
			t.url = m_simpleTV.User.dailymotion.ThumbsInfo.urlPattern
			t.httpParams = {}
			t.httpParams.userAgent = userAgent
			t.httpParams.extHeader = 'Referer: ' .. address
			t.httpParams.proxy = proxy
			t.elementWidth = 106
			t.elementHeight = 60
			t.startTime = 0
			t.length = m_simpleTV.User.dailymotion.ThumbsInfo.duration * 1000
			m_simpleTV.PositionThumbs.AppendThumb(t)
		 return true
		end
	end
	function dailymotionSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('dailymotion_qlty', id)
	end
	local url = 'https://www.dailymotion.com/player/metadata/video/' .. id
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			showError('2 - ' .. rc)
		 return
		end
	local header = m_simpleTV.Http.GetRawHeader(session)
		if not header:match('application/json') then
			m_simpleTV.Http.Close(session)
			showError('3')
		 return
		end
	answer = answer:gsub(':%s*%[%]', ':""')
	answer = answer:gsub('%[%]', ' ')
	answer = answer:gsub('\\', '\\\\')
	answer = answer:gsub('\\\\"', '\\"')
	answer = answer:gsub('\\/', '/')
	require 'json'
	local tab = json.decode(answer)
		if not tab
			or not tab.qualities
			or not tab.qualities.auto
			or not tab.qualities.auto[1]
			or not tab.qualities.auto[1].url
		then
			m_simpleTV.Http.Close(session)
			local error_message = '4'
			if tab and tab.error and tab.error.message then
				local error_title = tab.title or tab.error.title
				if error_title then
					error_title = unescape3(error_title) .. '\n'
				end
				error_message = error_message .. '\n'
						.. (error_title or '')
						.. unescape3(tab.error.message)
				error_message = error_message:gsub('<.->', '')
			end
			showError(error_message)
		 return
		end
	local retAdr = tab.qualities.auto[1].url
	local addTitle = 'dailymotion'
	local title = tab.title
	if not title then
		title = addTitle
	else
		if m_simpleTV.Control.MainMode == 0 then
			title = unescape3(title)
			m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
			local poster = answer:match('"posters":{.-"240":"([^"]+).-}') or logo
			poster = poster:gsub('\\/', '/')
			m_simpleTV.Control.ChangeChannelLogo(poster, m_simpleTV.Control.ChannelID)
		end
		title = addTitle .. ' - ' .. title
	end
	retAdr = retAdr:gsub('http://', 'https://')
	if tab.mode == 'live' then
		retAdr = retAdr .. '&redirect=0'
	end
	rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			showError('5 - ' .. rc)
		 return
		end
	local extOpt
	if tab.mode == 'live' then
		extOpt = ''
	else
		extOpt = '$OPT:NO-STIMESHIFT'
	end
	if proxy ~= '' then
		extOpt = '$OPT:http-proxy=' .. proxy
	end
	m_simpleTV.Http.Close(session)
	local i, t0 = 1, {}
	local name, adr
		for w in answer:gmatch('EXT%-X%-STREAM%-INF(.-%.m3u8)') do
			adr = w:match('\n(.-%.m3u8)')
			name = w:match('RESOLUTION=%d+x(%d+)')
				if not adr or not name then break end
			name = tonumber(name)
			name = math.ceil(name / 10) * 10
			if name > 200 then
				if not adr:match('^http') then
					adr = adr:gsub('^%.%./', ''):gsub('^/', '')
					adr = retAdr:match('.+/') .. adr
				end
				t0[i] = {}
				t0[i].Id = name
				t0[i].Name = name .. 'p'
				t0[i].Address = adr:gsub('https://', 'http://') .. extOpt
				i = i + 1
			end
		end
		if i == 1 then return end
	table.sort(t0, function(a, b) return a.Id < b.Id end)
	local hash, t = {}, {}
		for i = 1, #t0 do
			if not hash[t0[i].Name] then
				t[#t + 1] = t0[i]
				hash[t0[i].Name] = true
			end
		end
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('dailymotion_qlty') or 5000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 5000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
		-- t[#t + 1] = {} -- путин капут!
		-- t[#t].Id = 10000
		-- t[#t].Name = '▫ адаптивное'
		-- t[#t].Address = retAdr .. extOpt
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
			t.ExtParams = {LuaOnOkFunName = 'dailymotionSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	Thumbs(tab.filmstrip_url, tab.duration, tab.mode)
-- debug_in_file(t[index].Address .. '\n')