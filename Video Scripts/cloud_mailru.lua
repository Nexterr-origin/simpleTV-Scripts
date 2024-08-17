-- видеоскрипт для https://cloud.mail.ru (19/8/24)
-- Copyright © 2017-2024 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- открывает подобные ссылки:
-- https://cloud.mail.ru/public/GuR9/CpdDRwxu1
-- https://cloud.mail.ru/public/58R9/4aZ83NdH2/%D0%90%D0%B1%D1%8D%20%D0%9A%D0%BE%D0%B1%D0%BE/%D0%9A%D0%BE%D0%B1%D0%BE%20%D0%90%D0%B1%D1%8D_%D0%92%D0%BE%D1%88%D0%B5%D0%B4%D1%87%D0%B8%D0%B5%20%D0%B2%20%D0%BA%D0%BE%D0%B2%D1%87%D0%B5%D0%B3/Kobe-Abe/Kobe-Abe/1_02.mp3
-- https://cloud.mail.ru/public/KxzK/2VAckVGaj/80-e%20mp3%20(D)
-- https://cloud.mail.ru/public/KxzK/2VAckVGaj
-- https://cloud.mail.ru/public/8tEC/3JrNcD9ot
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https://cloud%.mail%.ru/public/(%w+/%w+)')
			and not m_simpleTV.Control.CurrentAddress:match('^cloudMailFolder')
		then
		 return
		end
	local inAdr = m_simpleTV.Control.CurrentAddress
	local logo = 'https://img.imgsmail.ru/cloud/img/build/release-cloudweb-12166-76-0-0.202105270927/portal-menu/portal-menu__logo.svg'
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = logo, UseLogo = 1, Once = 1})
	end
	require 'json'
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:130.0) Gecko/20100101 Firefox/130.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr:gsub('^cloudMailFolder', '')})
		if rc ~= 200 then return end
	local folder = answer:match('"public":{"type":"folder"[^%[]+"list":(%[{.+}%])')
	if folder then
		local title = answer:match('"serverSideFolders":{"count".-"name":"([^"]+)') or ''
		local t = {}
		local tab = json.decode(folder)
			if not tab then return end
			for i = 1, #tab do
				if tab[i].kind and tab[i].kind == 'file' then
					if tab[i].weblink:match('%.mp3')
						or tab[i].weblink:match('%.wav')
						or tab[i].weblink:match('%.mp4')
						or tab[i].weblink:match('%.avi')
						or tab[i].weblink:match('%.ts')
					then
						t[#t + 1] = {}
						t[#t].Id = #t
						t[#t].Name = tab[i].name
						local id, nameFile = tab[i].weblink:match('^(%w+/%w+/)(.-)$')
						nameFile = m_simpleTV.Common.toPercentEncoding(nameFile)
						t[#t].Address = 'cloudMailFolderhttps://cloud.mail.ru/public/' .. id .. nameFile
					end
				end
			end
			if #t == 0 then return end
		t.ExtParams = {}
		t.ExtParams.PlayMode = 1
		t.ExtParams.AutoNumberFormat = '%1 - %2'
		m_simpleTV.Control.CurrentTitle_UTF8 = 'Облако Mail.ru - ' .. title
		m_simpleTV.OSD.ShowSelect_UTF8(title, 0, t, 10000)
		m_simpleTV.Control.ChangeAddress = 'No'
		m_simpleTV.Control.CurrentAddress = t[1].Address
		dofile(m_simpleTV.MainScriptDir .. 'user\\video\\video.lua')
	 return
	end
	local addTitle = 'Облако Mail.ru'
	local title = answer:match(':{"name":"([^"]+)')
	if not title then
		title = addTitle
	else
		if m_simpleTV.Control.MainMode == 0 then
			title = m_simpleTV.Common.fromPercentEncoding(title)
			local poster = answer:match('"og:image" content="([^"]+)') or logo
			poster = poster:gsub('/thumb/v/', '/thumb/v')
			m_simpleTV.Control.ChangeChannelLogo(poster, m_simpleTV.Control.ChannelID, 'CHANGE_IF_NOT_EQUAL')
		end
		title = addTitle .. ' - ' .. title
	end
	local id = inAdr:match('/public/([^/]+/[^?]+)')
	local retAdr = answer:match('"videowl_view":{"count":"1","url":"([^"]+)')
		if not retAdr then return end
	if not inAdr:match('^cloudMailFolder')  then
		m_simpleTV.Control.CurrentTitle_UTF8 = title
	end
	retAdr = retAdr .. '/0p/' .. encode64(id) .. '.m3u8?double_encode=1'
	retAdr = retAdr .. '$OPT:NO-STIMESHIFT$OPT:adaptive-logic=highest'
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
