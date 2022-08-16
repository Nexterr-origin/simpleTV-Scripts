-- видеоскрипт для сайта https://t.me (16/8/22)
-- Copyright © 2017-2022 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://t.me/SolovievLive/121389
-- https://t.me/SolovievLive/121418?single
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://t%.me/.+') then return end
	local logo = 'https://telegram.org/img/favicon-32x32.png'
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = logo, TypeBackColor = 0, UseLogo = 1, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:103.0) Gecko/20100101 Firefox/103.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local function showErr(str)
		local t = {text = 'Telegram ошибка: ' .. str, color = ARGB(255, 255, 102, 0), showTime = 1000 * 5, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	inAdr = inAdr:gsub('%?.-', '')
	inAdr = inAdr .. '?embed=1'
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then return end
	local t = {}
		for w in answer:gmatch('<video[^>]+src="([^"]+)') do
				local name = #t + 1
				t[#t + 1] = {}
				t[#t].Id = name
				t[#t].Name = 'видео ' .. name
				t[#t].Address = w .. '$OPT:POSITIONTOCONTINUE=0'
		end
		for w in answer:gmatch('class="tgme_widget_message_photo[^>]+image:url%(\'([^\']+)') do
				local name = #t + 1
				t[#t + 1] = {}
				t[#t].Id = name
				t[#t].Name = 'картинка ' .. name
				t[#t].Address = w .. '$OPT:image-duration=10'
		end
			if #t == 0 then
				showErr('Медиа не найдено')
			 return
			end
	local addTitle = 'Telegram'
	local title = answer:match('<a class="tgme_widget_message_owner_name"[^>]+><span[^>]+>([^<]+)')
	if not title then
		title = addTitle
	else
		if m_simpleTV.Control.MainMode == 0 then
			title = title:gsub('%%22', '"')
			m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
			local poster = answer:match('"tgme_widget_message_user_photo[^>]+><img src="([^"]+)') or logo
			m_simpleTV.Control.ChangeChannelLogo(poster, m_simpleTV.Control.ChannelID, 'CHANGE_IF_NOT_EQUAL')
		end
		title = addTitle .. ' - ' .. title
	end
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	t.ExtParams = {}
	t.ExtParams.PlayMode = 0
	local _, id = m_simpleTV.OSD.ShowSelect_UTF8(title , 0, t, 10000, 32)
	m_simpleTV.Control.CurrentAddress = t[1].Address
-- debug_in_file(m_simpleTV.Control.CurrentAddress .. '\n')