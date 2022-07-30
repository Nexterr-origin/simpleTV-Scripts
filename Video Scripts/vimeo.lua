-- видеоскрипт для сайта https://vimeo.com/watch (30/7/22)
-- Copyright © 2017-2022 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://vimeo.com/channels/musicvideoland/368152561
-- https://vimeo.com/channels/staffpicks/204150149?autoplay=1
-- https://vimeo.com/156942975
-- https://vimeo.com/2196013
-- https://player.vimeo.com/video/344303837?wmode=transparent$OPT:http-referrer=https://www.clubbingtv.com/video/play/4194/live-dj-set-with-dan-lo/
-- https://vimeo.com/27945056
-- https://vimeo.com/showcase/3717822/video/329792082
-- https://vimeo.com/718108412
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://[%a%.]*vimeo%.com/.+') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
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
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:103.0) Gecko/20100101 Firefox/103.0')
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
			or not tab.video
			or not tab.request
			or not tab.request.files
		then
			showError('3')
		 return
		end
	local title = tab.video.title
	if not inAdr:match('player%.vimeo%.com/') then
		local addTitle = 'vimeo'
		if not title then
			title = addTitle
		else
			if m_simpleTV.Control.MainMode == 0 then
				title = unescape3(title)
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
	if tab.request.files.progressive and tab.request.files.progressive ~= '' then
		local i = 1
			while true do
					if not tab.request.files.progressive[i] then break end
				t[i] = {}
				t[i].Id = tab.request.files.progressive[i].height
				t[i].Name = tab.request.files.progressive[i].quality
				t[i].Address = tab.request.files.progressive[i].url:gsub('%?.-$', '') .. '$OPT:NO-STIMESHIFT'
				i = i + 1
			end
	else
		if tab.request.files.hls and tab.request.files.hls.cdns then
			local url
			if tab.request.files.hls.cdns.akamai_live and tab.request.files.hls.cdns.akamai_live.json_url then
				url = tab.request.files.hls.cdns.akamai_live.json_url
				rc, answer = m_simpleTV.Http.Request(session, {url = url})
					if rc ~= 200 then
						showError('4')
					 return
					end
				url = answer:match('"url":"([^"]+)')
					if not url then
						showError('4.1')
					 return
					end
			elseif tab.request.files.hls.cdns.akfire_interconnect_quic and tab.request.files.hls.cdns.akfire_interconnect_quic.url then
			url = tab.request.files.hls.cdns.akfire_interconnect_quic.url
			end
				rc, answer = m_simpleTV.Http.Request(session, {url = url})
					if rc ~= 200 then
						showError('4.21')
					 return
					end
				local base = url:match('.+/')
					for w in answer:gmatch('EXT%-X%-STREAM%-INF.-\n.-\n') do
						local adr = w:match('\n(.-)\n')
						local name = w:match('RESOLUTION=%d+x(%d+)')
						if adr and name then
							if not adr:match('^http') then
								if adr:match('^%.%./') then
									base = url:match('.+/video/') or ''
								end
								adr = base .. adr:gsub('^[%./]+', '')
							end
							t[#t + 1] = {}
							t[#t].Id = tonumber(name)
							t[#t].Name = name .. 'p'
							t[#t].Address = adr
						end
					end
		end
	end
	m_simpleTV.Http.Close(session)
		if #t == 0 then
			showError('5')
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('vimeo_qlty') or 5000)
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
			t.ExtParams = {LuaOnOkFunName = 'vimeoSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	if not inAdr:match('player%.vimeo%.com/') then
		m_simpleTV.Control.CurrentTitle_UTF8 = title
	end
-- debug_in_file(t[index].Address .. '\n')
