-- видеоскрипт для плейлиста "LimeHD" https://new.info-link.ru (5/12/20)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: LimeHD_pls.lua
-- расширение дополнения httptimeshift: limehd-timeshift_ext.lua
-- ## открывает подобные ссылки ##
-- https://infolink/1
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://infolink/%d') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.infolink then
		m_simpleTV.User.infolink = {}
	end
	m_simpleTV.User.infolink.catchup = nil
	m_simpleTV.User.infolink.url_archive = nil
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local extopt = '$OPT:no-ts-cc-check'
	local function track_archive(url)
		local session = m_simpleTV.Http.New()
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		url = url .. 'index.m3u8'
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		local track = answer:match('.+#EXT%-X%-STREAM.-\n(.-)\n')
			if not track then return end
		url = url:match('.+/') .. track
		url = url:gsub('/mono%.', '/index.')
		url = url .. extopt
	 return url
	end
	local function GetPlst()
		local session = m_simpleTV.Http.New(decode64('eyJwbGF0Zm9ybSI6ImFuZHJvaWQiLCJhcHAiOiJjb20uaW5mb2xpbmsubGltZWlwdHYiLCJ2ZXJzaW9uX25hbWUiOiIzLjMuMyIsInZlcnNpb25fY29kZSI6IjI1NiIsInNkayI6IjI5IiwibmFtZSI6InNka19waG9uZV94ODZfNjQrQW5kcm9pZCBTREsgYnVpbHQgZm9yIHg4Nl82NCIsImRldmljZV9pZCI6IjAwMEEwMDBBMDAwQTAwMEEifQ'))
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 12000)
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly9wbC5pcHR2MjAyMS5jb20vYXBpL3YxL3BsYXlsaXN0') .. '?t=' .. os.time(), method = 'post', body = '"tz":"3"', headers = 'X-Token:'})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
			if not answer:match('^{') then return end
		answer = answer:gsub('%[%]', '""')
		require 'json'
		local tab = json.decode(answer)
			if not tab then return end
		local t, i = {}, 1
		local adr
		local j = 1
			while true do
					if not tab.channels[j] then break end
				adr = tab.channels[j].url
				if adr and adr ~= '' then
					t[i] = {}
					t[i].ServerId = tab.channels[j].id
					t[i].url_archive = tab.channels[j].url_archive
					t[i].day_archive = tab.channels[j].day_archive
					t[i].with_archive = tab.channels[j].with_archive
					t[i].videoUrl = adr
					i = i + 1
				end
				j = j + 1
			end
			if i == 1 then return end
	 return t
	end
	if not m_simpleTV.User.infolink.plst then
		local plst = GetPlst()
			if not plst then return end
		m_simpleTV.User.infolink.plst = plst
	end
	local id = inAdr:match('%d+')
	local retAdr, url_archive, day_archive
		for i = 1, #m_simpleTV.User.infolink.plst do
			if tonumber(id) == tonumber(m_simpleTV.User.infolink.plst[i].ServerId) then
				retAdr = m_simpleTV.User.infolink.plst[i].videoUrl
				if m_simpleTV.User.infolink.plst[i].with_archive == true then
					day_archive = m_simpleTV.User.infolink.plst[i].day_archive
					url_archive = m_simpleTV.User.infolink.plst[i].url_archive
					if url_archive
						and url_archive ~= ''
						and day_archive
						and day_archive > 0
					then
						m_simpleTV.User.infolink.catchup = 'catchup="flussonic" catchup-days="' .. day_archive
						m_simpleTV.User.infolink.url_archive = track_archive(url_archive) or (retAdr .. extopt)
					end
				end
			 break
			end
		end
		if not retAdr then
			m_simpleTV.User.infolink = nil
		 return
		end
	m_simpleTV.Control.CurrentAddress = retAdr .. extopt
-- debug_in_file(retAdr .. '\n')