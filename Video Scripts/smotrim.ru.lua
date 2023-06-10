-- видеоскрипт для сайта https://smotrim.ru (10/6/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## Необходим ##
-- видеоскприпт: mediavitrina.lua
-- ## открывает подобные ссылки ##
-- https://smotrim.ru/video/2393207
-- https://smotrim.ru/article/2512070
-- https://smotrim.ru/brand/7321
-- https://smotrim.ru/channel/267
-- https://smotrim.ru/channel/254
-- https://smotrim.ru/channel/248 -- радио
-- https://smotrim.ru/podcast/45
-- https://smotrim.ru/audio/2650807
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://smotrim%.ru')
			and not m_simpleTV.Control.CurrentAddress:match('^smotrim_podcast=')
		then
		 return
		end
	local logo = 'https://cdnmg-st.smotrim.ru/smotrimru/smotrimru/i/logo-main-white.svg'
	local UseLogo = 1
	if m_simpleTV.Control.ChannelID ~= 268435455 then
		UseLogo = 0
	end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = logo, TypeBackColor = 0, UseLogo = UseLogo, Once = 1})
	end
	require 'json'
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.smotrim_ru then
		m_simpleTV.User.smotrim_ru = {}
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 14000)
	m_simpleTV.User.smotrim_ru.ThumbsInfo = nil
	local function showErr(str)
		local t = {text = 'smotrim.ru ошибка: ' .. str, color = ARGB(255, 255, 102, 0), showTime = 1000 * 5, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local function Thumbs(thumbsInfo)
			if m_simpleTV.Control.MainMode ~= 0 then return end
		thumbsInfo = thumbsInfo:match('"tooltip":{.-}}')
			if not thumbsInfo then return end
		thumbsInfo = thumbsInfo:match('"high":{.-}') or thumbsInfo:match('"low":{.-}')
			if not thumbsInfo then return end
		local samplingFrequency = tonumber(thumbsInfo:match('"periodSlide":(%d+)') or 0)
		local column = tonumber(thumbsInfo:match('"column":(%d+)') or 0)
		local row = tonumber(thumbsInfo:match('"row":(%d+)') or 0)
		local thumbsPerImage = column * row
		local thumbWidth = tonumber(thumbsInfo:match('"width":(%d+)') or 0)
		local thumbHeight = tonumber(thumbsInfo:match('"height":(%d+)') or 0)
		local urlPattern = thumbsInfo:match('"url":"([^"]+)')
			if samplingFrequency == 0
				or thumbsPerImage == 0
				or thumbWidth == 0
				or thumbHeight == 0
				or not urlPattern
			then
			 return
			end
		m_simpleTV.User.smotrim_ru.ThumbsInfo = {}
		m_simpleTV.User.smotrim_ru.ThumbsInfo.samplingFrequency = samplingFrequency
		m_simpleTV.User.smotrim_ru.ThumbsInfo.thumbsPerImage = thumbsPerImage
		m_simpleTV.User.smotrim_ru.ThumbsInfo.thumbWidth = thumbWidth / column
		m_simpleTV.User.smotrim_ru.ThumbsInfo.thumbHeight = thumbHeight / row
		m_simpleTV.User.smotrim_ru.ThumbsInfo.urlPattern = urlPattern
		if not m_simpleTV.User.smotrim_ru.PositionThumbsHandler then
			local handlerInfo = {}
			handlerInfo.luaFunction = 'PositionThumbs_smotrim_ru'
			handlerInfo.regexString = '//smotrim\.ru/video|//smotrim\.ru/brand'
			handlerInfo.sizeFactor = m_simpleTV.User.paramScriptForSkin_thumbsSizeFactor or 0.20
			handlerInfo.backColor = m_simpleTV.User.paramScriptForSkin_thumbsBackColor or ARGB(255, 0, 0, 0)
			handlerInfo.textColor = m_simpleTV.User.paramScriptForSkin_thumbsTextColor or ARGB(240, 127, 255, 0)
			handlerInfo.glowParams = m_simpleTV.User.paramScriptForSkin_thumbsGlowParams or 'glow="7" samples="5" extent="4" color="0xB0000000"'
			handlerInfo.marginBottom = m_simpleTV.User.paramScriptForSkin_thumbsMarginBottom or 0
			handlerInfo.showPreviewWhileSeek = true
			handlerInfo.clearImgCacheOnStop = false
			handlerInfo.minImageWidth = 80
			handlerInfo.minImageHeight = 45
			m_simpleTV.User.smotrim_ru.PositionThumbsHandler = m_simpleTV.PositionThumbs.AddHandler(handlerInfo)
		end
	end
	function PositionThumbs_smotrim_ru(queryType, address, forTime)
		if queryType == 'testAddress' then
		 return false
		end
		if queryType == 'getThumbs' then
				if not m_simpleTV.User.smotrim_ru.ThumbsInfo then
				 return true
				end
			local imgLen = m_simpleTV.User.smotrim_ru.ThumbsInfo.samplingFrequency * m_simpleTV.User.smotrim_ru.ThumbsInfo.thumbsPerImage * 1000
			local index = math.floor(forTime / imgLen)
			local t = {}
			t.playAddress = address
			t.url = m_simpleTV.User.smotrim_ru.ThumbsInfo.urlPattern:gsub('__num__', index)
			t.httpParams = {}
			t.httpParams.extHeader = 'Referer: ' .. address
			t.elementWidth = m_simpleTV.User.smotrim_ru.ThumbsInfo.thumbWidth
			t.elementHeight = m_simpleTV.User.smotrim_ru.ThumbsInfo.thumbHeight
			t.startTime = index * imgLen
			t.length = imgLen
			t.marginLeft = 2
			t.marginRight = 2
			t.marginTop = 0
			t.marginBottom = 0
			m_simpleTV.PositionThumbs.AppendThumb(t)
		 return true
		end
	end
	local function player_vgtrk(data)
		local retAdr = data:match('download_url%s*=%s*[\'"]([^\'"]+)')
		m_simpleTV.Control.CurrentAddress = retAdr
	end
	local function Podcast(data)
		local title = data:match('"og:title" content="([^"]+)') or 'Podcast'
		local pic = data:match('"og:image" content="([^"]+)') or logo
		m_simpleTV.Control.CurrentTitle_UTF8 = title
		local podcastId = inAdr:match('/podcast/(%d+)')
		local url = 'https://api.smotrim.ru/api/v1/audios/?includes=anons:datePub:duration:episodeTitle:rubrics:title&limit=1000&plan=free,free&sort=date&rubrics=' .. podcastId
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
			if rc ~= 200 then return end
		answer = unescape3(answer)
		answer = answer:gsub('%[%]', '""')
		local tab = json.decode(answer)
			if not tab or not tab.data then return end
		local t, i = {}, 1
			while tab.data[i] do
				local name = tab.data[i].episodeTitle
				t[i] = {}
				t[i].Id = i
				t[i].Name = name
				t[i].Address = 'smotrim_podcast=https://player.vgtrk.com/iframe/audio/id/' .. tab.data[i].id .. '/sid/smotrim/'
				t[i].InfoPanelLogo = pic
				t[i].InfoPanelDesc = tab.data[i].anons
				t[i].InfoPanelName = title
				t[i].InfoPanelTitle = name
				t[i].InfoPanelShowTime = 5000
				i = i + 1
			end
			if i == 1 then return end
		t.ExtParams = {}
		t.ExtParams.AutoNumberFormat = '%1 - %2'
		m_simpleTV.OSD.ShowSelect_UTF8(title, 0, t, 5000)
		local rc, answer = m_simpleTV.Http.Request(session, {url = t[1].Address:gsub('smotrim_podcast=', '')})
			if rc ~= 200 then return end
		player_vgtrk(answer)
	end
	function smotrim_ru_SaveQuality(obj, id)
		m_simpleTV.Config.SetValue('smotrim_ru_qlty', tostring(id))
	end
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr:gsub('smotrim_podcast=', '')})
		if rc ~= 200 then
			showErr(1)
		 return
		end
		if inAdr:match('/podcast/') then
			Podcast(answer)
		 return
		end
		if inAdr:match('^smotrim_podcast=') then
			player_vgtrk(answer)
		 return
		end
	answer = answer:gsub('\\/', '/'):gsub('&quot;', '"'):gsub('&amp;', '&')
	local embedUrl = answer:match('http[^\'\"<>]+player%.[^<>\'\"]+') or answer:match('http[^\'\"<>]+/iframe/[^/]+/id/[^<>\'\"]+') or answer:match('http[^\'\"<>]+icecast%-[^<>\'\"]+')
		if not embedUrl then
			showErr('Медиа контент не найден')
		 return
		end
		if embedUrl:match('mediavitrina') then
			m_simpleTV.Control.ChangeAddress = 'No'
			m_simpleTV.Control.CurrentAddress = embedUrl
			dofile(m_simpleTV.MainScriptDir .. 'user/video/video.lua')
		 return
		end
	answer = answer:gsub('%s+', '')
	local dataUrl = embedUrl:gsub('[%w_]+/false/?', ''):gsub('[%w_]+/true/?', ''):gsub('%?.+', '')
	dataUrl = dataUrl:gsub('^//', 'https://')
	local islive = dataUrl:match('/live/')
	dataUrl = dataUrl:gsub('/live/', '/datalive/'):gsub('/video/', '/datavideo/'):gsub('/audio/', '/dataaudio/'):gsub('/audio/', '/dataaudio/'):gsub('/audio%-live/', '/dataaudiolive/')
	if not dataUrl:match('/sid/') then
		dataUrl = dataUrl:gsub('/$', '') .. '/sid/smotrim'
	end
	rc, answer = m_simpleTV.Http.Request(session, {url = dataUrl, headers = 'Referer: ' .. embedUrl})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			showErr(5)
		 return
		end
	local audio_url = answer:match('"audio_url":"([^"]+)')
	local retAdr = answer:match('"auto":"([^"]+)')
		if not retAdr and not audio_url then
			local err = answer:match('%[{"errors":"([^"]+)')
			if err and err ~= '' then
				err = unescape3(err)
				err = err:gsub('\\r\\n', '')
			end
			showErr(err or 6)
		 return
		end
	answer = answer:gsub('\\"', '%%22')
	if not islive then
	local addTitle = 'Смотрим'
	local title = answer:match('"title":"([^"]+)')
	if not title then
		title = addTitle
	else
		if m_simpleTV.Control.MainMode == 0 then
			title = unescape3(title)
			title = title:gsub('%%22', '"')
			m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
			local poster = answer:match('"pictures":{"[^}]+"16:9":"([^"]+)') or 'https://smotrim.ru/i/smotrim_logo_soc.png'
			m_simpleTV.Control.ChangeChannelLogo(poster, m_simpleTV.Control.ChannelID, 'CHANGE_IF_NOT_EQUAL')
		end
		title = addTitle .. ' - ' .. title
	end
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	end
		if (retAdr and retAdr:match('icecast')) or audio_url then
			m_simpleTV.Control.CurrentAddress = retAdr or audio_url
		 return
		end
	local duration = answer:match('"duration":(%d+)')
	if not islive then
		Thumbs(answer)
	end
	rc, answer = m_simpleTV.Http.Request(session, {url = retAdr, headers = 'Referer: https://player.smotrim.ru/'})
		if rc ~= 200 then
			showErr(7)
		 return
		end
	local extOpt = '$OPT:no-spu'
	local t, i = {}, 1
		for w in answer:gmatch('EXT%-X%-STREAM%-INF(.-)\n') do
			local res = w:match('RESOLUTION=%d+x(%d+)')
			local bw = w:match('BANDWIDTH=(%d+)')
			if bw then
				bw = tonumber(bw)
				bw = math.ceil(bw / 10000) * 10
				t[#t + 1] = {}
				if res then
					t[#t].Name = res .. 'p (' .. bw .. ' кбит/с)'
				else
					t[#t].Name = bw .. ' кбит/с'
				end
				t[#t].Id = bw
				t[#t].Address = string.format('%s$OPT:adaptive-logic=highest$OPT:adaptive-max-bw=%s%s', retAdr, bw, extOpt)
				end
			end
		if #t == 0 then
			m_simpleTV.Control.CurrentAddress = retAdr .. extOpt
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('smotrim_ru_qlty') or 30000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 30000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
		t[#t + 1] = {}
		t[#t].Id = 50000
		t[#t].Name = '▫ адаптивное'
		t[#t].Address = retAdr .. extOpt
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
			t.ExtParams = {LuaOnOkFunName = 'smotrim_ru_SaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	retAdr = t[index].Address
	if duration and tonumber(duration) < 300 then
		retAdr = retAdr .. '$OPT:POSITIONTOCONTINUE=0'
	end
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
