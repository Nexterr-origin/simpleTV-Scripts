-- видеоскрипт для сайта https://my.mail.ru/video, https://smotri.mail.ru (30/8/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видеоскрипт: mediavitrina.lua, ok.lua
-- ## открывает подобные ссылки ##
-- https://my.mail.ru/v/fresh_movie/video/_groupvideo/244.html
-- https://my.mail.ru/community/patj/video/embed/_groupvideo/2546
-- https://smotri.mail.ru/watch/537280
-- https://smotri.mail.ru/online-tv/3/
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://my%.mail%.ru')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://videoapi%.my%.mail%.ru')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://smotri%.mail%.ru/[^/]+/%d')
		then
		 return
		end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	if m_simpleTV.Control.MainMode == 0 and not inAdr:match('online%-tv') then
		local logo
		if inAdr:match('smotri%.mail') then
			logo = 'https://smotri.cdnmail.ru/assets/default/static/logo/logoMain.svg'
		else
			logo = 'https://www.walletone.com/logo/provider/o001.png'
		end
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = logo, UseLogo = 1, Once = 1})
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:91.0) Gecko/20100101 Firefox/91.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	function mailruSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('mailru_qlty', id)
	end
	local smotriTv = inAdr:match('smotri%.mail%.ru/online%-tv/(%d+)')
		if smotriTv then
			local rc, answer = m_simpleTV.Http.Request(session, {url = 'https://pulsarback.mail.ru/api/v2/tv_channels/get?ids=' .. smotriTv})
			m_simpleTV.Http.Close(session)
				if rc ~= 200 then return end
			local retAdr = answer:match('"player_url":"([^"]+)')
			if retAdr then
				retAdr = retAdr:gsub('\\/', '/')
				m_simpleTV.Control.ChangeAddress = 'No'
				m_simpleTV.Control.CurrentAddress = retAdr
				dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
			end
		 return
		end
	local smotri = inAdr:match('smotri%.mail%.ru/watch/(%d+)')
		if smotri then
			local url = 'https://pulsarback.mail.ru/api/v2/video/manifest?id=' .. smotri
			local rc, answer = m_simpleTV.Http.Request(session, {url = url})
			m_simpleTV.Http.Close(session)
				if rc ~= 200 then return end
			local extOpt = '$OPT:NO-STIMESHIFT'
			local t = {}
				for w in answer:gmatch('EXT%-X%-STREAM%-INF(.-\n.-)\n') do
					local adr = w:match('\n(.+)')
					local res = w:match('RESOLUTION=%d+x(%d+)')
					if adr and res then
						t[#t + 1] = {}
						t[#t].Id = tonumber(res)
						t[#t].Name = res .. 'p'
						t[#t].Address = adr .. extOpt
					end
				end
				if #t == 0 then
					m_simpleTV.Control.CurrentAddress = url .. extOpt
				 return
				end
			table.sort(t, function(a, b) return a.Id < b.Id end)
			local lastQuality = tonumber(m_simpleTV.Config.GetValue('mailru_qlty') or 5000)
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
			end
			if m_simpleTV.Control.MainMode == 0 then
				t.ExtParams = {LuaOnOkFunName = 'mailruSaveQuality'}
				t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
				m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
			end
			m_simpleTV.Control.CurrentAddress = t[index].Address
		 return
		end
	if not inAdr:match('/embed/') then
		inAdr = inAdr:gsub('/video/', '/video/embed/')
		inAdr = inAdr:gsub('%.html', '')
	end
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
		 return
		end
	local mUrl = answer:match('"metadataUrl":"([^"]+)')
		if not mUrl then return end
	mUrl = mUrl:gsub('^//', 'https://')
	rc, answer = m_simpleTV.Http.Request(session, {url = mUrl})
	local cooki = m_simpleTV.Http.GetCookies(session, mUrl, '')
	m_simpleTV.Http.Close(session)
		if rc ~= 200 or not cooki then return end
	answer = answer:gsub(':%s*%[%]', ':""')
	local tab = json.decode(answer)
		if not tab or not tab.videos then return end
	local addTitle = 'mailru'
	local title = tab.meta.title
	if not title then
		title = addTitle
	else
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
			local poster
			if tab.meta and tab.meta.poster then
				poster = tab.meta.poster
				poster = poster:gsub('^//', 'https://')
			end
			poster = poster or 'https://cdn.freebiesupply.com/logos/thumbs/1x/mail-ru-logo.png'
			m_simpleTV.Control.ChangeChannelLogo(poster, m_simpleTV.Control.ChannelID)
		end
		title = addTitle .. ' - ' .. title
	end
	local t, i = {}, 1
		while true do
				if not tab.videos[i] then break end
			t[i] = {}
			t[i].Name = tab.videos[i].key
			t[i].Id = tonumber(tab.videos[i].key:match('%d+'))
			t[i].Address = tab.videos[i].url:gsub('^//', 'https://') .. '$OPT:NO-STIMESHIFT$OPT:http-ext-header=cookie:' .. cooki
			i = i + 1
		end
		if i == 1 then return end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('mailru_qlty') or 5000)
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
			t.ExtParams = {LuaOnOkFunName = 'mailruSaveQuality'}
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
			t.ExtButton0 = {ButtonEnable = true, ButtonName = '📄', ButtonScript = 'm_simpleTV.Control.ExecuteAction(116)'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	m_simpleTV.Control.CurrentTitle_UTF8 = title
-- debug_in_file(t[index].Address .. '\n')
