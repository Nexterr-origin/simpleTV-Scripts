-- видеоскрипт для сайта https://live.vkplay.ru (30/7/24)
-- Copyright © 2017-2024 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://vkplay.live/swat2k
-- https://vkplay.live/app/embed/swat2k
-- https://live.vkplay.ru/kuplinov
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://vkplay%.live')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://live%.vkplay%.ru')
		then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	local logo = 'https://static.live.vkplay.ru/static/favicon.png?v='
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = logo, TypeBackColor = 0, UseLogo = 1, Once = 1})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local ua = 'Mozilla/5.0 (Windows NT 10.0; rv:129) Gecko/20100101 Firefox/129'
	local session = m_simpleTV.Http.New(ua)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 12000)
	local user = inAdr:match('/embed/([^/]+)') or inAdr:match('%.live/([^/]+)') or inAdr:match('vkplay.ru/([^/]+)')
	local url = 'https://api.live.vkplay.ru/v1/blog/' .. user .. '/public_video_stream'
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		if rc ~= 200 then return end
	answer = answer:gsub('%[%\"', '"')
	answer = answer:gsub('%[%]%]"', '"')
	answer = answer:gsub('%[%]"', '""')
	require 'json'
	local err, tab = pcall(json.decode, answer)
		if not tab
			or not tab.data
			or not tab.data[1]
			or not tab.data[1].playerUrls
			or not tab.data[1].playerUrls[1]
		then
		 return
		end
	local retAdr
		for i = 1, #tab.data[1].playerUrls do
			local typeUrl = tab.data[1].playerUrls[i].type
			local adr = tab.data[1].playerUrls[i].url
			if typeUrl == 'live_hls'
				or typeUrl == 'live_playback_hls'
				or typeUrl == 'hls'
				and adr ~= ''
			then
				retAdr = adr
			 break
			end
		end
		if not retAdr then return end
	retAdr = retAdr:gsub('_offset_p' , ''):gsub('%?p' , '')
	local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
		if rc ~= 200 then return end
	local addTitle = 'vkplay'
	local title
	if tab.user
		and tab.user.displayName
		and tab.data[1].title
		and tab.user.displayName ~= ''
		and tab.data[1].title ~= ''
	then
		title = tab.user.displayName .. ' / ' .. tab.data[1].title
	end
	if not title then
		title = addTitle
	else
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
			if tab.user.avatarUrl
				and tab.user.avatarUrl
				and tab.user.avatarUrl ~= ''
			then
				logo = tab.user.avatarUrl
			end
			m_simpleTV.Control.ChangeChannelLogo(logo, m_simpleTV.Control.ChannelID, 'CHANGE_IF_NOT_EQUAL')
		end
		title = addTitle .. ' - ' .. title
	end
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	local extOpt = '$OPT:http-user-agent=' .. ua
	local t = {}
		for w in answer:gmatch('EXT%-X%-STREAM%-INF(.-)\n') do
			local bw = w:match('BANDWIDTH=(%d+)')
			local res = w:match('RESOLUTION=%d+x(%d+)')
			if bw and res then
				bw = tonumber(bw)
				bw = math.ceil(bw / 100000) * 100
				t[#t + 1] = {}
				t[#t].Id = tonumber(res)
				t[#t].Name = res .. 'p (' .. bw .. ' кбит/с)'
				t[#t].Address = string.format('%s$OPT:adaptive-logic=highest$OPT:adaptive-max-bw=%s%s', retAdr, bw, extOpt)
			end
		end
		if #t == 0 then
			m_simpleTV.Control.CurrentAddress = retAdr .. extOpt
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('vkplaylive_qlty') or 30000)
	t[#t + 1] = {}
	t[#t].Id = 30000
	t[#t].Name = '▫ всегда высокое'
	t[#t].Address = t[#t - 1].Address
	t[#t + 1] = {}
	t[#t].Id = 50000
	t[#t].Name = '▫ адаптивное'
	t[#t].Address = retAdr .. extOpt
	local index = #t
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
		t.ExtParams = {LuaOnOkFunName = 'vkplayliveSaveQuality'}
		m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 8000, 32 + 64 + 128 + 8)
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function vkplayliveSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('vkplaylive_qlty', id)
	end
-- debug_in_file(m_simpleTV.Control.CurrentAddress .. '\n')
