-- видеоскрипт для сайта https://ok.ru (9/12/22)
-- Copyright © 2017-2022 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- http://ok.ru/videoembed/2636779838
-- https://ok.ru/video/361515387611
-- http://ok.ru/video/23276948199
-- https://ok.ru/live/search/1115050286838
-- https://ok.ru/video/1951798069873
-- https://m.ok.ru/dk?st.cmd=movieLayer&st.discId=220851668368&st.retLoc=default&st.discType=MOVIE&st.mvId=220851668368&st.stpos=rec_5&_prevCmd=movieLayer&tkn=3933
-- https://m.ok.ru/dk?st.cmd=moviePlaybackRedirect&st.sig=923171edb53da243925fbfe90c1a285ea99c3fe9&st.mq=3&st.mvid=1565588916953&st.ip=178.57.98.107&st.exp=1575887947669&st.hls=off&_prevCmd=main&tkn=9594
-- https://ok.ru/video/4138886498843
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://[wm%.]*ok%.ru') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	if not (inAdr:find('videoembed')
		or inAdr:find('&isPlst=true')
		or m_simpleTV.Control.ChannelID ~= 268435455)
	then
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = 'https://ok.ru/res/i/p/toolbar/logo_wide.png', UseLogo = 1, Once = 1})
		end
	else
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
		end
	end
	local userAgent = 'Mozilla/5.0 (Windows NT 10.0; rv:91.0) Gecko/20100101 Firefox/91.0'
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.ok then
		m_simpleTV.User.ok = {}
	end
	local function unescape_html(str)
		str = str:gsub('&#39;', '\'')
		str = str:gsub('&ndash;', '-')
		str = str:gsub('&#8217;', '\'')
		str = str:gsub('&raquo;', '"')
		str = str:gsub('&laquo;', '"')
		str = str:gsub('&lt;', '<')
		str = str:gsub('&gt;', '>')
		str = str:gsub('&quot;', '"')
		str = str:gsub('&apos;', '\'')
		str = str:gsub('&#(%d+);', function(n) return string.char(n) end)
		str = str:gsub('&#x(%d+);', function(n) return string.char(tonumber(n, 16)) end)
		str = str:gsub('&amp;', '&')
	 return str
	end
	local function GetQltyName(str)
		local t = {
					{'mobile', 144},
					{'lowest', 240},
					{'low', 360},
					{'sd', 480},
					{'medium', 480},
					{'hd', 720},
					{'high', 720},
					{'full', 1080},
					{'quad', 1440},
					{'ultra', 2160},
				}
			for i = 1, #t do
				if str == t[i][1] then
				 return t[i][2]
				end
			end
	 return 4400
	end
	local function Thumbs(thumbsInfo)
			if m_simpleTV.Control.MainMode ~= 0 then return end
		m_simpleTV.User.ok.ThumbsInfo = nil
		thumbsInfo = thumbsInfo:match('&quot;collageInfo\\&quot;:{.-}')
			if not thumbsInfo then return end
		thumbsInfo = thumbsInfo:gsub('\\&quot;', '"'):gsub('\\u0026', '&'):gsub('\\', '')
		local urlPattern = thumbsInfo:match('url":"([^"]+)')
		local samplingFrequency = tonumber(thumbsInfo:match('"frequency":(%d+)') or 0)
		local thumbHeight = tonumber(thumbsInfo:match('"height":(%d+)') or 0)
		local thumbWidth = tonumber(thumbsInfo:match('"width":(%d+)') or 0)
		local thumbsPerImage = tonumber(thumbsInfo:match('"count":(%d+)') or 0)
			if not urlPattern
				or samplingFrequency == 0
				or thumbHeight == 0
				or thumbWidth == 0
				or thumbsPerImage == 0
			then
			 return
			end
		m_simpleTV.User.ok.ThumbsInfo = {}
		m_simpleTV.User.ok.ThumbsInfo.urlPattern = urlPattern
		m_simpleTV.User.ok.ThumbsInfo.samplingFrequency = samplingFrequency
		m_simpleTV.User.ok.ThumbsInfo.thumbHeight = thumbHeight
		m_simpleTV.User.ok.ThumbsInfo.thumbWidth = thumbWidth
		m_simpleTV.User.ok.ThumbsInfo.thumbsPerImage = thumbsPerImage
		if not m_simpleTV.User.ok.PositionThumbsHandler then
			local handlerInfo = {}
			handlerInfo.luaFunction = 'PositionThumbs_ok'
			handlerInfo.regexString = '.*\.ok\.ru/.*|kinogid\.com/.*'
			handlerInfo.sizeFactor = m_simpleTV.User.paramScriptForSkin_thumbsSizeFactor or 0.18
			handlerInfo.backColor = m_simpleTV.User.paramScriptForSkin_thumbsBackColor or 0x00000000
			handlerInfo.textColor = m_simpleTV.User.paramScriptForSkin_thumbsTextColor or 0x00000000
			handlerInfo.glowParams = m_simpleTV.User.paramScriptForSkin_thumbsGlowParams or ''
			handlerInfo.marginBottom = m_simpleTV.User.paramScriptForSkin_thumbsMarginBottom or 0
			handlerInfo.minImageWidth = 80
			handlerInfo.minImageHeight = 45
			m_simpleTV.User.ok.PositionThumbsHandler = m_simpleTV.PositionThumbs.AddHandler(handlerInfo)
		end
	end
	function PositionThumbs_ok(queryType, address, forTime)
		if queryType == 'testAddress' then
		 return false
		end
		if queryType == 'getThumbs' then
				if not m_simpleTV.User.ok.ThumbsInfo then
				 return true
				end
			local t = {}
			t.playAddress = address
			t.url = m_simpleTV.User.ok.ThumbsInfo.urlPattern
			t.httpParams = {}
			t.httpParams.userAgent = userAgent
			t.httpParams.extHeader = 'Referer: ' .. address
			t.elementWidth = m_simpleTV.User.ok.ThumbsInfo.thumbWidth
			t.elementHeight = m_simpleTV.User.ok.ThumbsInfo.thumbHeight
			t.startTime = 0
			t.elementsPerImage = m_simpleTV.User.ok.ThumbsInfo.thumbsPerImage
			t.length = m_simpleTV.User.ok.ThumbsInfo.samplingFrequency * m_simpleTV.User.ok.ThumbsInfo.thumbsPerImage * 1000
			m_simpleTV.PositionThumbs.AppendThumb(t)
		 return true
		end
	end
	function okSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('ok_qlty', id)
	end
	local id = inAdr:match('mv[Ii]d=(%d+)') or inAdr:match('%d+')
		if not id then return end
	local session = m_simpleTV.Http.New(userAgent)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = 'https://ok.ru/video/' .. id})
		if rc ~= 200 or (rc == 200 and answer:find('приостановлена')) then
			m_simpleTV.Http.Close(session)
		 return
		end
	local retAdr = answer:match('hlsMa.-;:\\&quot;(.-)\\&quot') or answer:match('ondemandHls.-;:\\&quot;(.-)\\&quot')
		if not retAdr then
			retAdr = answer:match('originalUrl\\&quot;:\\&quot;(.-)\\&quot')
			m_simpleTV.Http.Close(session)
				if not retAdr then return end
			retAdr = retAdr:gsub('\\\\u0026', '&')
			if inAdr:match('PARAMS=psevdotv') then
				retAdr = retAdr:gsub('%?.-$', '')
				retAdr = retAdr .. '?&isPlst=true$OPT:INT-SCRIPT-PARAMS=psevdotv'
			end
			m_simpleTV.Control.ChangeAddress = 'No'
			m_simpleTV.Control.CurrentAddress = retAdr
			dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
		 return
		end
	retAdr = retAdr:gsub('\\\\u0026', '&')
	local subtitle = answer:match('subtitleTracks\\&quot;:%[{\\&quot;url\\&quot;:\\&quot;(.-)\\&quot')
	if subtitle then
		subtitle = '$OPT:sub-track-id=0$OPT:input-slave=' .. subtitle:gsub('\\\\u0026', '&'):gsub('^//', 'https://'):gsub('://', '/webvtt://')
	end
	local extOpt = '$OPT:no-ts-cc-check$OPT:http-user-agent=' .. userAgent
	if not answer:match('"vid%-card_live __active">Live<') then
		extOpt = extOpt .. '$OPT:NO-STIMESHIFT'
	end
		if inAdr:match('&isPlst=true') then
			Thumbs(answer)
			m_simpleTV.Http.Close(session)
			answer = answer:gsub('\\\\\\&quot;', '"')
			local title = answer:match('title\\&quot;:\\&quot;(.-)\\&quot') or 'OK'
			title = title:gsub('\\\\u0026', '&')
			title = unescape_html(title)
			if inAdr:match('PARAMS=psevdotv') then
				local t = m_simpleTV.Control.GetCurrentChannelInfo()
				if t and t.MultiHeader then
					title = t.MultiHeader .. ': ' .. title
				end
				local name = title:gsub('%c.-$', '')
				m_simpleTV.Control.SetTitle(name)
				retAdr = retAdr .. '$OPT:NO-SEEKABLE'
			else
				m_simpleTV.Control.CurrentTitle_UTF8 = title
			end
			m_simpleTV.Control.CurrentAddress = retAdr .. (subtitle or '') .. extOpt .. '$OPT:POSITIONTOCONTINUE=0'
		 return
		end
	local title
	if not (inAdr:find('videoembed')
		or (answer:match('"vid%-card_live __active">Live<') and m_simpleTV.Control.ChannelID ~= 268435455))
	then
		local addTitle = 'OK'
		local answer = answer:gsub('\\\\\\&quot;', '"')
		title = answer:match('title\\&quot;:\\&quot;(.-)\\&quot')
		if not title then
			title = addTitle
		else
			if m_simpleTV.Control.MainMode == 0 then
				title = title:gsub('\\\\u0026', '&')
				title = unescape_html(title)
				m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
				local logo = answer:match('"og:image" content=".-url=([^"]+)')
				if logo then
					logo = m_simpleTV.Common.fromPercentEncoding(logo)
					logo = logo:gsub('&amp;', '&')
					m_simpleTV.Control.ChangeChannelLogo(logo, m_simpleTV.Control.ChannelID)
				end
			end
			title = addTitle .. ' - ' .. title
		end
	end
	local rc, answer0 = m_simpleTV.Http.Request(session, {url = retAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local base = retAdr:match('.+/')
	local t = {}
		for w in answer0:gmatch('EXT%-X%-STREAM%-INF.-\n.-\n') do
			local adr = w:match('\n(.-)\n')
			local name = w:match('QUALITY=(%a+)')
				if not adr or not name then break end
			name = GetQltyName(name)
			if name > 300 then
				if not adr:match('^http') then
					adr = base .. adr
				end
				t[#t + 1] = {}
				t[#t].Id = name
				t[#t].Name = name .. 'p'
				t[#t].Address = adr .. (subtitle or '') .. extOpt
			end
		end
	if not inAdr:find('videoembed') then
		m_simpleTV.Control.CurrentTitle_UTF8 = title
	end
		if #t == 0 then
			Thumbs(answer)
			m_simpleTV.Control.CurrentAddress = retAdr .. (subtitle or '') .. extOpt .. '$OPT:POSITIONTOCONTINUE=0'
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('ok_qlty') or 5000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 5000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
		t[#t + 1] = {}
		t[#t].Id = 10000
		t[#t].Name = '▫ адаптивное'
		t[#t].Address = retAdr .. (subtitle or '') .. extOpt
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
			t.ExtParams = {LuaOnOkFunName = 'okSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address .. '$OPT:POSITIONTOCONTINUE=0'
	Thumbs(answer)
-- debug_in_file(t[index].Address .. '\n')
