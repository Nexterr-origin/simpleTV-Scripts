-- видеоскрипт для сайта https://vimeo.com/watch (24/2/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://vimeo.com/channels/musicvideoland/368152561
-- https://vimeo.com/channels/staffpicks/204150149?autoplay=1
-- https://vimeo.com/156942975
-- https://vimeo.com/2196013
-- https://player.vimeo.com/video/344303837?wmode=transparent$OPT:http-referrer=https://www.clubbingtv.com/video/play/4194/live-dj-set-with-dan-lo/
-- https://vimeo.com/27945056
-- https://vimeo.com/showcase/3717822/video/329792082
-- https://vimeo.com/771846252
-- https://vimeo.com/801794678
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://[%a%.]*vimeo%.com/.+') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.vimeo then
		m_simpleTV.User.vimeo = {}
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	if not inAdr:match('player%.vimeo%.com') then
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
			m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = 'https://raw.githubusercontent.com/Nexterr-origin/simpleTV-Images/main/vimeo.png', UseLogo = 1, Once = 1})
		end
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'vimeo ошибка: ' .. str, showTime = 1000 * 5, color = ARGB(255, 255, 102, 0), id = 'vimeo'})
	end
	local id = inAdr:match('/video/(%d+)') or inAdr:match('/(%d+/?%x+)')
		if not id then
			showError('not found \'id\' in url')
		 return
		end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	function vimeoSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('vimeo_qlty', id)
	end
	local function getConfig_url()
		local rc, answer = m_simpleTV.Http.Request(session, {url = 'https://vimeo.com/_rv/viewer'})
			if rc ~= 200 then return end
		local jwt = answer:match('"jwt":"([^"]+)')
			if rc ~= 200 then return end
		id = id:gsub('/', ':')
		local url = 'https://api.vimeo.com/videos/' .. id .. '?fields=embed_player_config_url'
		local headers = 'Content-Type: application/json\nOrigin: https://vimeo.com\nReferer: '
				.. inAdr
				.. '\nAuthorization: jwt ' .. jwt
		rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = headers})
			if rc ~= 200 then return end
		local config_url = answer:match('config_url":%s*"([^"]+)')
	 return config_url, headers
	end
	local config_url, headers
	if not inAdr:match('player%.vimeo%.com/') then
		config_url, headers = getConfig_url()
		if not config_url or not headers then
				m_simpleTV.Http.Close(session)
				showError('1')
			 return
			end
	else
		config_url = 'https://player.vimeo.com/video/' .. id .. '/config'
		headers = 'Referer: ' .. (inAdr:match('$OPT:http%-referrer=(.+)') or inAdr)
	end
	local rc, answer = m_simpleTV.Http.Request(session, {url = config_url, headers = headers})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			showError('2')
		 return
		end
	answer = answer:gsub('\\', '\\\\')
	answer = answer:gsub('\\"', '\\\\"')
	answer = answer:gsub('\\/', '/')
	answer = answer:gsub(':%s*%[%]', ':""')
	answer = answer:gsub('%[%]', ' ')
	require 'json'
	local tab = json.decode(answer)
		if not tab
			and not tab.video
			and not tab.request
			and not tab.request.files
			and not tab.request.files.hls
			and not tab.request.files.hls.cdns
		then
			showError('видео не найдено')
		 return
		end
	local retAdr
	local noProgressive = true
	if not tab.request.files.progressive
		or not tab.request.files.progressive[1]
		or not tab.request.files.progressive[1].url
	then
		if tab.request.files.hls.cdns.akamai_live then
			retAdr = tab.request.files.hls.cdns.akamai_live.url
		elseif tab.request.files.hls.cdns.akfire_interconnect_quic	then
			retAdr = tab.request.files.hls.cdns.akfire_interconnect_quic.avc_url
		else
			retAdr = false
		end
	else
		retAdr = true
		noProgressive = false
	end
		if not retAdr then
			showError('видео не найдено')
		 return
		end
	local function Thumbs(thumbsInfo)
			if m_simpleTV.Control.MainMode ~= 0 then return end
		m_simpleTV.User.vimeo.ThumbsInfo = nil
			if not tab.request.thumb_preview
				or not tab.video.duration
			then
			 return
			end
		local urlPattern = tab.request.thumb_preview.url
		local thumbHeight = tab.request.thumb_preview.frame_height or 0
		local thumbWidth = tab.request.thumb_preview.frame_width or 0
		local thumbsPerImage = tab.request.thumb_preview.frames or 0
			if not urlPattern
				or thumbHeight == 0
				or thumbWidth == 0
				or thumbsPerImage == 0
			then
			 return
			end
		m_simpleTV.User.vimeo.ThumbsInfo = {}
		m_simpleTV.User.vimeo.ThumbsInfo.urlPattern = urlPattern
		m_simpleTV.User.vimeo.ThumbsInfo.duration = tab.video.duration
		m_simpleTV.User.vimeo.ThumbsInfo.thumbHeight = thumbHeight
		m_simpleTV.User.vimeo.ThumbsInfo.thumbWidth = thumbWidth
		m_simpleTV.User.vimeo.ThumbsInfo.thumbsPerImage = thumbsPerImage
		if not m_simpleTV.User.vimeo.PositionThumbsHandler then
			local handlerInfo = {}
			handlerInfo.luaFunction = 'PositionThumbs_vimeo'
			handlerInfo.regexString = '.*vimeo\.com/.*'
			handlerInfo.sizeFactor = 0.20
			handlerInfo.backColor = ARGB(255, 0, 0, 0)
			handlerInfo.textColor = ARGB(240, 127, 255, 0)
			handlerInfo.glowParams = 'glow="7" samples="5" extent="4" color="0xB0000000"'
			handlerInfo.marginBottom = 0
			handlerInfo.showPreviewWhileSeek = true
			handlerInfo.clearImgCacheOnStop = false
			handlerInfo.minImageWidth = 80
			handlerInfo.minImageHeight = 44
			m_simpleTV.User.YT.PositionThumbsHandler = m_simpleTV.PositionThumbs.AddHandler(handlerInfo)
		end
	end
	function PositionThumbs_vimeo(queryType, address, forTime)
		if queryType == 'testAddress' then
		 return false
		end
		if queryType == 'getThumbs' then
				if not m_simpleTV.User.vimeo.ThumbsInfo then
				 return true
				end
			local t = {}
			t.playAddress = address
			t.url = m_simpleTV.User.vimeo.ThumbsInfo.urlPattern
			t.elementWidth = m_simpleTV.User.vimeo.ThumbsInfo.thumbWidth
			t.elementHeight = m_simpleTV.User.vimeo.ThumbsInfo.thumbHeight
			t.startTime = 0
			t.elementsPerImage = m_simpleTV.User.vimeo.ThumbsInfo.thumbsPerImage
			t.length = m_simpleTV.User.vimeo.ThumbsInfo.duration * 1000
			m_simpleTV.PositionThumbs.AppendThumb(t)
		 return true
		end
	end
	local title = tab.video.title
	if not inAdr:match('player%.vimeo%.com/') then
		local addTitle = 'vimeo'
		if not title then
			title = addTitle
		else
			if m_simpleTV.Control.MainMode == 0 then
				title = unescape3(title):gsub('\\"', '"')
				answer = answer:gsub('\\"', '"')
				m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
				local thumbs
				if tab.video.thumbs and tab.video.thumbs.base then
					thumbs = tab.video.thumbs.base .. '?mw=240&q=85'
				end
				thumbs = thumbs or 'https://image.flaticon.com/icons/png/128/889/889149.png'
				m_simpleTV.Control.ChangeChannelLogo(thumbs, m_simpleTV.Control.ChannelID)
			end
			title = addTitle .. ' - ' .. title
		end
	end
	local t = {}
	if noProgressive then
		retAdr = retAdr:gsub('\\u0026', '&')
		rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then
				showError('3.1')
			 return
			end
		for w in answer:gmatch('EXT%-X%-STREAM%-INF.-\n') do
			local bw = w:match('[^%-]BANDWIDTH=(%d+)')
			local res = w:match('RESOLUTION=%d+x(%d+)')
			if bw and res then
				bw = bw / 1000
				t[#t + 1] = {}
				t[#t].Id = tonumber(res)
				t[#t].Name = res .. 'p'
				t[#t].Address = string.format('%s$OPT:adaptive-logic=highest$OPT:adaptive-max-bw=%s', retAdr, bw)
			end
		end
	else
		for i = 1, #tab.request.files.progressive do
			t[#t + 1] = {}
			t[#t].Id = tonumber(tab.request.files.progressive[i].height)
			t[#t].Name = tab.request.files.progressive[i].quality
			t[#t].Address = tab.request.files.progressive[i].url
		end
	end
		if #t == 0 then
			showError('5')
		 return
		end
	Thumbs(tab)
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('vimeo_qlty') or 20000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 20000
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
			t.ExtParams = {LuaOnOkFunName = 'vimeoSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	if not inAdr:match('player%.vimeo%.com/') then
		m_simpleTV.Control.CurrentTitle_UTF8 = title
	end
-- debug_in_file(t[index].Address .. '\n')
