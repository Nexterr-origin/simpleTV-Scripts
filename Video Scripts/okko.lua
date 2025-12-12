-- видеоскрипт для плейлиста "ОККО" https://okko.tv (9/12/25)
-- Copyright © 2017-2025 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
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
			local headers = m_simpleTV.Common.CryptographicHash(m_simpleTV.Common.GetCModuleExtension(), Md5) .. ': ' .. m_simpleTV.Common.CryptographicHash(os.date("!%Y|%m|%d", os.time()), Md5)
			local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cDovL285Njg4OW5vLmJlZ2V0LnRlY2gvdGtuLnBocD90dj1va2tv'), headers = headers})
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
	
	local function GetKey(id)
		local ids_keys = {
			{'7595fa8b-858c-4735-b458-217781481fe6', 'ZGY1MjNkM2Y5YTE2ZGQzMmU4OTkzZjk3Nzg2NzdiNDk'},
			{'f24eb142-0bbe-4ba2-b540-722eefc775c2', 'YTdjZjc5N2FiZWE3MWQzZDNiNGE5YTk3OTAzYzc0NTQ'},
			{'808c1342-e6fc-4fa9-852b-9c8a0e784b27', 'NjMzMDRjNmI2ZTc0NjI0ODc1ZWM1OTEzYWUyNWMyMWI'},
			{'222e6ac7-0349-4dc5-9e80-97c62f624ab5', 'YTQ3MTViMWE5ZmVmNTdjYzMzN2YzNTI0ZTM3NDY4ZGQ'},
			{'25fa7830-881c-4bd8-a8f2-9d9aa095cede', 'NjY3ZDU1YWI2NjE0OTIxMTE2Njk5NjI1YjY0ZTNjOGQ'},
			{'ba41a258-97e6-4e47-8a93-45860325501d', 'NmU5OGY5Y2QyYjVlZDMzM2Y0ZWY1Y2EwZmFlYTNmOWU'}
		}
		for _, v in pairs(ids_keys) do
			if v[1] == id then
				return v[2]
			end
		end
	end
	
	local token = GetToken()
		if not token then return end
	
	local tab = GetJson(token)
		if not tab or not tab.elements.items[1].assets.items then return end
	local adr
	
	local t = {}
	for i = 1, #tab.elements.items[1].assets.items do
		if tab.elements.items[1].assets.items[i].media.fps == 50 then
			t[#t + 1] = {}
			t[#t].Name = 'Частота кадров ' .. tab.elements.items[1].assets.items[i].media.fps .. ' fps'
			t[#t].Id = tab.elements.items[1].assets.items[i].media.fps
			t[#t].Address = tab.elements.items[1].assets.items[i].url
		end
	end
			
	local hash = {}
	local x = {}
	for _,v in ipairs(t) do
	   if (not hash[v.Id]) then
		   x[#x+1] = v
		   hash[v.Id] = true
	   end
	end
	
	if #x > 0 and GetKey(tab.elements.items[1].id) then
		for i = 1, #x do
			x[i].Address = string.format('%s$OPT:adaptive-use-avdemux$OPT:avdemux-options={decryption_key=%s}', x[i].Address, decode64(GetKey(tab.elements.items[1].id)))
		end
	end
	
	for i = 1, #tab.elements.items[1].assets.items do
		if GetKey(tab.elements.items[1].id) then
			adr = string.format('%s$OPT:adaptive-use-avdemux$OPT:avdemux-options={decryption_key=%s}', tab.elements.items[1].assets.items[i].url, decode64(GetKey(tab.elements.items[1].id)))
		else
			if tab.elements.items[1].assets.items[i].media.drmType == 'NO_DRM'
			and tab.elements.items[1].assets.items[i].url:match('m3u8$')
			then
				adr = tab.elements.items[1].assets.items[i].url
			end
		end
	end
	if not adr then return end
	
	local gm, rs, bn
	if adr:match('.m3u8') then
		gm = 'EXT%-X%-STREAM%-INF.-\n'
		rs = 'resolution=%d+x(%d+)'
		bn = ':bandwidth=(%d+)'
	else
		gm = '<Representation id="video(.-)>'
		rs = 'height="([^"]+)'
		bn = 'bandwidth="([^"]%d+)'
	end
	
		local rc, answer = m_simpleTV.Http.Request(session, {url = adr:gsub('$OPT.+', '')})
			if rc ~= 200 then return end
		m_simpleTV.Http.Close(session)
	
		local t = {}
		for w in answer:gmatch(gm) do
			w = w:lower()
			local bw = w:match(bn)
			local res = w:match(rs)
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
			t[#t].Address = adr
			index = #t
			for i = 1, #t do
				if t[i].Id >= lastQuality and lastQuality ~= 50 then
					index = i
				 break
				end
			end
			if index > 1 then
				if t[index].Id > lastQuality and lastQuality == 50 then
					index = index - 1
				end
			end
			if #x > 0 then
				for i = 1, #x do
					t[#t + 1] = {}
					t[#t].Id = x[i].Id
					t[#t].Name = x[i].Name
					t[#t].Address = x[i].Address
				end
			end
			if lastQuality == 50 then
				for i = 1, #t do
					if t[i].Id == 50 then
						index = i
					 break
					end
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
