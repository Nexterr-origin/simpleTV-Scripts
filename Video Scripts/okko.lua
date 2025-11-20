-- видеоскрипт для плейлиста "ОККО" https://okko.tv (20/11/25)
-- Copyright © 2017-2025 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- Обновляемый токен предоставлен @FC_Sparta4
-- ## необходим ##
-- скрапер TVS: 'okko_pls.lua
-- ## открывает подобные ссылки ##
-- https://okko.tv/ce77474b-6ea1-46d3-977d-3fa2f6c86968

		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://okko%.tv')
		then return end

	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	
	local inAdr = m_simpleTV.Control.CurrentAddress
	inAdr = inAdr:gsub('$OPT:.+', '')
	local id = inAdr:match('([^/]+)$')
	local url = decode64('aHR0cHM6Ly9jdHgucGxheWZhbWlseS5ydS9zY3JlZW5hcGkvdjIvcHJlcGFyZXBsYXliYWNrL3dlYi8xP2VsZW1lbnRzPQ') .. url_encode('[{"id":"' .. id .. '"}]') .. '&sid='
	
	local function showMsg(str, color)
		local t = {text = str, showTime = 1000 * 3, color = color, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''

	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:144.0) Gecko/20100101 Firefox/144.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	
	local function GetHeader()
		local sum = 0;
		local characters = 'abcdefghijklmnopqrstuvwxyz0123456789'
		for i = 1, 32 do
			local rand = math.floor(math.random() * #characters)
			local character = characters:sub(rand,rand)
			sum = sum .. character
		end	
		local header = 'x-scrapi-signature: ' .. sum
	  return header
	end
	
	local function GetJson(token)
		local rc, answer = m_simpleTV.Http.Request(session, {url = url .. token, headers = GetHeader()})
			if rc ~= 200 then return end
		answer = answer:gsub('\\', '\\\\')
		answer = answer:gsub('\\"', '\\\\"')
		answer = answer:gsub('\\/', '/')
		answer = answer:gsub('%[%]', '""')
		require 'json'
		local err, tab = pcall(json.decode, answer)
	  return tab
	end
	
	local function CheckToken(token)
		local stat
		local tab = GetJson(token)
			if not tab then return end
		if tab.authorized and tab.elements.items[1].assets.items then
			stat = 200
		else 
			stat = 'Нет рабочего токена'
		end
	 return stat
	end
	
	local function GetToken()
		local saveToken = m_simpleTV.Config.GetValue('okko_token')
		local tok
		if saveToken and CheckToken(saveToken) == 200 then
			tok = saveToken
		else
			local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly9rb3Zyb3YtMzMucnUvb2trby50eHQ')})
			if rc ~= 200 then return end
				if answer then
					answer = decode64(answer)
					if CheckToken(answer) == 200 then
						tok = answer
						m_simpleTV.Config.SetValue('okko_token', tok)
					else
						showMsg(CheckToken(answer), ARGB(255,255, 0, 0))
					end
				else
					showMsg('Нет рабочего токена', ARGB(255,255, 0, 0))
				end
		end
	 return tok
	end

	local token = GetToken()
		if not token then return end
	
	local tab = GetJson(token)
		if not tab or not tab.elements.items[1].assets.items then return end
	local adr
	for i = 1, #tab.elements.items[1].assets.items do
		if tab.elements.items[1].assets.items[i].media.drmType == 'NO_DRM'
		and tab.elements.items[1].assets.items[i].url:match('m3u8$')
		then
			adr = tab.elements.items[1].assets.items[i].url
		end
	end
	if not adr then return end

	local rc, answer = m_simpleTV.Http.Request(session, {url = adr})
		if rc ~= 200 then return end
	m_simpleTV.Http.Close(session)
	
	local t = {}
	for w in answer:gmatch('EXT%-X%-STREAM%-INF.-\n') do
		local bw = w:match('BANDWIDTH=(%d+)')
		local res = w:match('RESOLUTION=%d+x(%d+)')
		if bw then
			bw = tonumber(bw)
			bw = math.ceil(bw / 100000) * 100
			t[#t + 1] = {}
			if res then
				t[#t].Name = res .. 'p (' .. bw .. ' кбит/с)'
				t[#t].Id = tonumber(res)
				t[#t].Address = string.format('%s$OPT:adaptive-logic=highest$OPT:adaptive-maxheight=%s', adr, res)
			else
				t[#t].Name = bw .. ' кбит/с'
				t[#t].Id = bw
				t[#t].Address = string.format('%s$OPT:adaptive-logic=highest$OPT:adaptive-max-bw=%s', adr, bw)
			end
		end
	end
	
	if #t == 0 then
		m_simpleTV.Control.CurrentAddress = adr
	 return
	end

	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('okko_qlty') or 20000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 20000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
		t[#t + 1] = {}
		t[#t].Id = 50000
		t[#t].Name = '▫ адаптивное'
		t[#t].Address = retAdr
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
			t.ExtParams = {LuaOnOkFunName = 'okkoSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128 + 8)
		end
	end

	m_simpleTV.Control.CurrentAddress = t[index].Address

	function okkoSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('okko_qlty', id)
	end

 --debug_in_file(m_simpleTV.Control.CurrentAddress .. '\n'\)