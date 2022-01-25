-- видеоскрипт для сайта https://ufcfightpass.com (26/1/22)
-- Copyright © 2017-2022 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- логин, пароль установить в 'Password Manager', для id: ufcfightpass
-- ## открывает подобные ссылки ##
-- https://ufcfightpass.com/live/129428/fight-pass-247
-- https://ufcfightpass.com/video/206187/ufc---vs--?playlistId=2939
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://ufcfightpass%.com')
			and not m_simpleTV.Control.CurrentAddress:match('PARAMS=ufcfightpass')
		then
		 return
		end
	local inAdr = m_simpleTV.Control.CurrentAddress
	local logo = 'https://static.diceplatform.com/prod/AUTOx100/dce.ufc/settings/UFC-FIGHT-PASS-Vertical_White.98nci.png'
	if m_simpleTV.Control.MainMode == 0 then
		local pic = logo
		if inAdr:match('PARAMS=ufcfightpass') then
			pic = ''
		end
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = pic, UseLogo = 1, Once = 1})
	end
	inAdr = inAdr:match('PARAMS=ufcfightpass([^$]+)') or inAdr
	local function showMsg(str)
		local t = {text = 'UFC Fight Pass: ' .. str, color = ARGB(255, 255, 102, 0), showTime = 1000 * 5, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local id = inAdr:match('/live/([^/]+)')
	local id_vod = inAdr:match('/video/([^/]+)')
		if not id and not id_vod then
			showMsg('неправильная ссылка')
		 return
		end
	local userAgent = 'Mozilla/5.0 (Windows NT 10.0; rv:97.0) Gecko/20100101 Firefox/97.0'
	local session = m_simpleTV.Http.New(userAgent)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local headers = 'Content-Type: application/json\nRealm: dce.ufc\nx-api-key: 857a1e5d-e35e-4fdf-805b-a87b6f8364bf\nAuthorization: Bearer '
	local apiUrl = 'https://dce-frontoffice.imggaming.com/api/v2/'
	local function Chapters(answer)
		local chaptersUrl = answer:match('"chaptersUrl":"([^"]+)')
			if not chaptersUrl then return end
		local rc, answer = m_simpleTV.Http.Request(session, {url = chaptersUrl})
			if rc ~= 200 then return end
		local t = {}
			for w in answer:gmatch('%d+:%d+:.-\n.-\n') do
					local start = w:match('%d+:%d+:%d+')
					local name = w:match('\n(.-)\n')
					if start and name then
						local hour, min, sec = start:match('(%d+):(%d+):(%d+)')
						hour = tonumber(hour)
						min = tonumber(min)
						sec = tonumber(sec)
						t[#t + 1] = {}
						t[#t].title = name
						t[#t].seekpoint = sec + (min * 60) + (hour * 3600)
					end
				end
			if #t == 0 then return end
		if t[1].seekpoint ~= 0 then
			table.insert(t, 1, {seekpoint = 0, title = ''})
		end
		local chaptersT = {}
		chaptersT.chapters = {}
			for i = 1, #t do
				chaptersT.chapters[i] = {}
				chaptersT.chapters[i].seekpoint = t[i].seekpoint * 1000
				chaptersT.chapters[i].name = t[i].title
			end
		m_simpleTV.Control.SetChaptersDesc(chaptersT)
	end
	local function GetTokens(headers, apiUrl)
		local error_text, pm = pcall(require, 'pm')
			if not package.loaded.pm then return end
		local ret, login, pass = pm.GetTestPassword('ufcfightpass', 'ufcfightpass', true)
			if not login or not pass or login == '' or pass == '' then return end
		local url = apiUrl .. 'login'
		headers = headers .. 'null'
		local body = string.format('{"id":"%s","secret":"%s"}', login, pass)
		local rc, answer = m_simpleTV.Http.Request(session, {url = url, method = 'post', body = body, headers = headers})
			if rc ~= 201 then return end
	 return answer:match('"authorisationToken":"([^"]+)')
	end
	local function GetAddress(id, id_vod, token, headers, apiUrl)
		local url
		if id then
			url = '?eventId=' .. id
		else
			url = '/vod/' .. id_vod
		end
		headers = headers .. token
		local rc, answer = m_simpleTV.Http.Request(session, {url = apiUrl .. 'stream' .. url, headers = headers})
			if rc ~= 200 then return end
		url = answer:match('"playerUrlCallback":"([^"]+)')
			if not url then return end
		rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = headers})
			if rc ~= 200 then return end
		url = answer:match('"hlsUrl":"([^"]+)')
			if not url then return end
		local thumbnailUrl, title
		if id then
			rc, answer = m_simpleTV.Http.Request(session, {url = apiUrl .. 'event/' .. id, headers = headers})
			title = answer:match('"title":"(.-)","startDate"')
		else
			thumbnailUrl = answer:match('"thumbnailUrl":"([^"]+)')
			title = answer:match('RU","title":"(.-)"}') or answer:match('"title":"(.-)"}')
			Chapters(answer)
		end
	 return url, title, thumbnailUrl
	end
	local authToken = GetTokens(headers, apiUrl)
		if not authToken then
			showMsg('необходима авторизация')
		 return
		end
	local retAdr, title, pic = GetAddress(id, id_vod, authToken, headers, apiUrl)
		if not retAdr then
			showMsg('нет адреса трансляции/видео')
		 return
		end
	title = title or 'UFC Fight Pass'
	if m_simpleTV.Control.MainMode == 0 then
		pic = pic or logo
		m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
		pic = pic:gsub('/original/', '/346x200/')
		m_simpleTV.Control.ChangeChannelLogo(pic, m_simpleTV.Control.ChannelID)
	end
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	local extOpt = '$OPT:INT-SCRIPT-PARAMS=ufcfightpass' .. inAdr .. '$OPT:adaptive-use-avdemux$OPT:http-user-agent=' .. userAgent
	local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
		if rc ~= 200 then
			m_simpleTV.Control.CurrentAddress = retAdr .. extOpt
		 return
		end
	local t0 = {}
		for w in string.gmatch(answer,'EXT%-X%-STREAM%-INF:BANDWIDTH.-\n') do
			local name = w:match('RESOLUTION=%d+x(%d+)')
			local br = w:match('BANDWIDTH=(%d+)')
			if name and br then
				t0[#t0 +1] = {}
				br = tonumber(br)
				br = math.ceil(br / 1000)
				t0[#t0].Address = retAdr .. '$OPT:adaptive-logic=highest$OPT:adaptive-max-bw=' .. br .. extOpt
				t0[#t0].Id = br
				t0[#t0].Name = name .. 'p' .. ' (' .. br .. ' кбит/с)'
			end
		end
		if #t0 == 0 then
			m_simpleTV.Control.CurrentAddress = retAdr .. extOpt
		 return
		end
	table.sort(t0, function(a, b) return a.Id < b.Id end)
	local hash, t = {}, {}
		for i = 1, #t0 do
			if not hash[t0[i].Id] then
				t[#t + 1] = t0[i]
				hash[t0[i].Id] = true
			end
		end
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('ufcfightpass_qlty') or 20000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 20000
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
			t.ExtParams = {LuaOnOkFunName = 'ufcfightpassSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 10000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function ufcfightpassSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('ufcfightpass_qlty', id)
	end
-- debug_in_file(t[index].Address .. '\n')
