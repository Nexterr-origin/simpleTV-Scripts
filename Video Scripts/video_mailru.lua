-- видеоскрипт для сайта https://my.mail.ru/video (29/11/20)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://my.mail.ru/v/fresh_movie/video/_groupvideo/244.html
-- https://my.mail.ru/community/patj/video/embed/_groupvideo/2546
-- https://videoapi.my.mail.ru/videos/embed/mail/coldfilmupload/_myvideo/4006.html
-- https://smotri.mail.ru/watch/537280
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://my%.mail%.ru')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://videoapi%.my%.mail%.ru')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://smotri%.mail%.ru/watch/%d')
		then
		 return
		end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = 'https://www.walletone.com/logo/provider/o001.png', UseLogo = 1, Once = 1})
	end
	local smotri = inAdr:match('smotri%.mail%.ru/watch/(%d+)')
		if smotri then
			m_simpleTV.Control.CurrentAddress = 'https://pulsarback.mail.ru/api/v2/video/manifest?id=' .. smotri .. '$OPT:NO-STIMESHIFT'
		 return
		end
	if not inAdr:match('/embed/') then
		inAdr = inAdr:gsub('/video/', '/video/embed/')
		inAdr = inAdr:gsub('%.html', '')
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:81.0) Gecko/20100101 Firefox/81.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
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
	function mailruSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('mailru_qlty', id)
	end
-- debug_in_file(t[index].Address .. '\n')