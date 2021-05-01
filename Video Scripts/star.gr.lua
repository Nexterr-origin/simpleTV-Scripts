-- видеоскрипт для сайта https://www.star.gr (12/3/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://www.star.gr/lifestyle/celebrities/535875/elenh-menegakh-pozarei-me-dermatino-synolo
-- https://www.star.gr/tv/live-stream/
-- https://www.star.gr/video/masterchef=535853
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://www%.star%.gr') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
	end
	htmlEntities = require 'htmlEntities'
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'Star.gr ένα λάθος: ' .. str, showTime = 8000, color = ARGB(255, 255, 102, 0), id = 'channelName'})
	end
	local function unescape_html(str)
	 return htmlEntities.decode(str)
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:86.0) Gecko/20100101 Firefox/86.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			showError('1')
			m_simpleTV.Http.Close(session)
		 return
		end
	answer = answer:gsub('<!%-%-.-%-%->', ''):gsub('/%*.-%*/', '')
	local retAdr = answer:match('https?://[^\'"<>]+%.m3u8[^<>\'"]*')
		if not retAdr then
			showError('2')
		 return
		end
	local title = answer:match('"og:title" content="([^"]+)')
				or answer:match('"name":%s*"([^"]+)')
				or answer:match('\'Publisher Name\':%s*\'([^\']+)')
				or 'Star.gr'
	if m_simpleTV.Control.MainMode == 0 then
		title = unescape_html(title)
		m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
		local poster = answer:match('"twitter:image" content="([^"]+)')
					or answer:match('"thumbnailUrl":%s*"([^"]+)')
					or answer:match('\'Publisher Logo\':%s*\'([^\']+)')
					or 'https://scdn.star.gr/images/news-logo.png'
		poster = poster:gsub('^/', 'https://www.star.gr/tv/')
		m_simpleTV.Control.ChangeChannelLogo(poster, m_simpleTV.Control.ChannelID)
	end
	rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
		if rc ~= 200 then
			showError('3')
		 return
		end
	m_simpleTV.Http.Close(session)
	local t = {}
	local base = retAdr:match('.+/')
		for w in answer:gmatch('EXT%-X%-STREAM%-INF(.-\n.-)\n') do
			local adr = w:match('\n(.-)$')
			local res = w:match('RESOLUTION=%d+x(%d+)')
			local bw = w:match('BANDWIDTH=(%d+)')
			if adr and res and bw then
				bw = tonumber(bw)
				t[#t +1] = {}
				t[#t].Id = tonumber(res)
				bw = math.floor(bw / 10000) * 10
				t[#t].Name = res .. 'p' .. ' (' .. bw .. ' kb/c)'
				if not adr:match('https?:') then
					adr = base .. adr
				end
				t[#t].Address = adr
			end
		end
		if #t == 0 then
			m_simpleTV.Control.CurrentAddress = retAdr
			m_simpleTV.Control.CurrentTitle_UTF8 = title
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('starGr_qlty') or 10000000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 10000000
		t[#t].Name = '▫ πάντα ψηλά'
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
			t.ExtParams = {LuaOnOkFunName = 'starGrSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Ποιότητα', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	function starGrSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('starGr_qlty', tostring(id))
	end
-- debug_in_file(t[index].Address .. '\n')