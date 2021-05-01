-- видеоскрипт для сайта https://www.imdb.com (26/6/20)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://www.imdb.com/video/vi4095655705?playlistId=tt8579674&ref_=tt_ov_vi
-- http://www.imdb.com/video/imdb/vi2524815897
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://[%w%.]*imdb%.com.-vi%d+') then return end
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, color = 0xFF8080FF, id = 'channelName'})
	local inAdr = m_simpleTV.Control.CurrentAddress
	inAdr = inAdr:gsub('%?.-$', '')
	require 'json'
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local logo = 'https://m.media-amazon.com/images/G/01/AUIClients/IMDbHelpSiteAssets-IMDb_Primary-9feba87f52c383ff59810fdae66d87f34e69faf3._V2_.png'
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = logo, UseLogo = 1, Once = 1, Blur = 5})
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'imdb ошибка: ' .. str, showTime = 5000, color = 0xffff1000, id = 'channelName'})
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.79 Safari/537.36')
		if not session then
			showError('0')
		 return
		end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local function GetThemoviedb(d)
			if not d then return end
		local url = 'https://api.themoviedb.org/3/find/' .. d .. decode64('P2FwaV9rZXk9ZDU2ZTUxZmI3N2IwODFhOWNiNTE5MmVhYWE3ODIzYWQmbGFuZ3VhZ2U9cnUmZXh0ZXJuYWxfc291cmNlPWltZGJfaWQ')
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
			if rc ~= 200 then return end
		answer = answer:gsub('(%[%])', '"nil"')
		local tab = json.decode(answer)
			if not tab then return end
	 return tab.movie_results[1].title, tab.movie_results[1].poster_path
	end
	local id = inAdr:match('vi%d+')
	local key = '{"type":"VIDEO_PLAYER","subType":"FORCE_LEGACY","id":"' .. id .. '"}'
	key = encode64(key)
	local url = 'https://www.imdb.com/ve/data/VIDEO_PLAYBACK_DATA?key=' .. key
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			showError('1 - ' .. rc)
		 return
		end
	local retAdr = answer:match('definition":"AUTO","mimeType":"application/x%-mpegurl","url":"([^"]+)')
	local retAdr_mp4 = answer:match('video/mp4","url":"([^"]+)')
		if not retAdr and not retAdr_mp4 then
			showError('2')
		 return
		end
	local tt = inAdr:match('tt%d+')
	local title, poster = GetThemoviedb(tt)
	local addTitle = 'imdb'
	if not title then
		title = addTitle
	else
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
		end
		title = addTitle .. ' - ' .. title
	end
	if m_simpleTV.Control.MainMode == 0 then
		if poster and poster ~= '' then
			poster = 'http://image.tmdb.org/t/p/w300' .. poster
			m_simpleTV.Control.ChangeChannelLogo(poster, m_simpleTV.Control.ChannelID, 'CHANGE_IF_NOT_EQUAL')
		else
			m_simpleTV.Control.ChangeChannelLogo(logo, m_simpleTV.Control.ChannelID)
		end
	end
		if not retAdr then
			m_simpleTV.Http.Close(session)
			m_simpleTV.Control.CurrentAddress = retAdr_mp4
			m_simpleTV.Control.CurrentTitle_UTF8 = title
		 return
		end
	rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			showError('3 - ' .. rc)
		 return
		end
	local base = retAdr:match('.+/')
	local t0, i = {}, 1
	local name, adr
		for w in answer:gmatch('EXT%-X%-STREAM%-INF(.-%.m3u8)') do
			adr = w:match('\n(.-%.m3u8)')
			name = w:match('RESOLUTION=%d+x(%d+)')
				if not adr or not name then break end
			if not adr:match('^http') then
				adr = base .. adr:gsub('%.%./', ''):gsub('^/', '')
			end
			t0[i] = {}
			t0[i].Id = name
			t0[i].Address = adr .. '$OPT:NO-STIMESHIFT$OPT:POSITIONTOCONTINUE=0'
			i = i + 1
		end
		if i == 1 then
			m_simpleTV.Control.CurrentAddress = retAdr
			m_simpleTV.Control.CurrentTitle_UTF8 = title
		 return
		end
		for _, v in pairs(t0) do
			v.Id = tonumber(v.Id)
			if v.Id > 0 and v.Id <= 180 then
				v.Id = 144
			elseif v.Id > 180 and v.Id <= 300 then
				v.Id = 240
			elseif v.Id > 300 and v.Id <= 400 then
				v.Id = 360
			elseif v.Id > 400 and v.Id <= 500 then
				v.Id = 480
			elseif v.Id > 500 and v.Id <= 780 then
				v.Id = 720
			elseif v.Id > 780 and v.Id <= 1200 then
				v.Id = 1080
			elseif v.Id > 1200 and v.Id <= 1500 then
				v.Id = 1444
			elseif v.Id > 1500 and v.Id <= 2800 then
				v.Id = 2160
			elseif v.Id > 2800 and v.Id <= 4500 then
				v.Id = 4320
			end
			v.Name = v.Id .. 'p'
		end
	table.sort(t0, function(a, b) return a.Id < b.Id end)
	local hash, t = {}, {}
		for i = 1, #t0 do
			if not hash[t0[i].Name] then
				t[#t + 1] = t0[i]
				hash[t0[i].Name] = true
			end
		end
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('imdb_qlty') or 5000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 5000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
		t[#t + 1] = {}
		t[#t].Id = 10000
		t[#t].Name = '▫ адаптивное'
		t[#t].Address = retAdr .. '$OPT:NO-STIMESHIFT$OPT:POSITIONTOCONTINUE=0'
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
			t.ExtParams = {LuaOnOkFunName = 'imdbSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	function imdbSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('imdb_qlty', id)
	end
-- debug_in_file(t[index].Address .. '\n')