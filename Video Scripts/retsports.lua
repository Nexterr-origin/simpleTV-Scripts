-- http://iptv.gen12.net/bugtracker/view.php?id=1420#c37163 (28/2/23)
-- ## открывает подобные ссылки ##
-- http://retsports.com/nhl/Coyotes.php
function retsports_HttpLiveKeyLoaderEvent(eventType, id, url)
 if eventType == 'get' then
  if string.match(url,"https://playback%.svcs%.plus%.espn%.com/events") then

    httpLiveKeyLoader_Log('key request id:' ..  id .. ',url:' .. url)
	--debug_in_file('key request id:' ..  id .. ',url:' .. url .. '\n')
	if m_simpleTV.User == nil or m_simpleTV.User.Retsports == nil then return 2,'' end

	local keyServer = m_simpleTV.User.Retsports.LastKeyserver

	local mediaId = findpattern(url, "media/.-/",1,6,1)
    --debug_in_file('mediaId from key url:' ..  mediaId .. '\n')

    if mediaId and m_simpleTV.User.Retsports.MediasId and m_simpleTV.User.Retsports.MediasId[mediaId] then
	  keyServer = m_simpleTV.User.Retsports.MediasId[mediaId]
	  --debug_in_file('keyServer from t:' .. keyServer .. '\n')
	end

    if keyServer == nil then return 2,'' end

	url = string.gsub(url,"https://playback%.svcs%.plus%.espn%.com/events", keyServer)
    httpLiveKeyLoader_Log('changed url:' .. url)

	local session = m_simpleTV.Http.New()
	if session==nil then return 2,'' end
    local rc, answer = m_simpleTV.Http.Request(session,{url=url})
	m_simpleTV.Http.Close(session)
    if rc~=200 or answer == nil then return 2,'' end
	local key = encode64(answer)
	httpLiveKeyLoader_Log('Got key:' .. key)
	return 1,key
  end
 end

 return 0,''
end
---------------------------------------------------------------------------------------
if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
local inAdr =  m_simpleTV.Control.CurrentAddress

if not string.match( inAdr, 'https?://retsports%.com' )  then return end
m_simpleTV.Control.ChangeAddress = 'Yes'
m_simpleTV.Control.CurrentAddress = 'error'

local session = m_simpleTV.Http.New()
if session==nil then return end
local rc, answer = m_simpleTV.Http.Request(session,{url=inAdr})
m_simpleTV.Http.Close(session)
if rc~=200 or answer == nil then return end

local s = findpattern(answer, 'var sou = (%b"")',1,11,1)
--debug_in_file(s .. '\n')
if s then

  local mediaId = findpattern(s,'data=.-~',1,5,1)

  --debug_in_file('mediaId:' .. mediaId .. '\n')

  local keyServer = findpattern(answer, "/keys/.-'",1,1,1);
  if keyServer then keyServer = 'https://retsports.com/' .. keyServer end

  --debug_in_file('keyServer:' .. keyServer .. '\n')

  if keyServer then
	if m_simpleTV.User == nil then m_simpleTV.User = {} end
	if m_simpleTV.User.Retsports == nil then m_simpleTV.User.Retsports = {} end
	if m_simpleTV.User.Retsports.MediasId == nil then m_simpleTV.User.Retsports.MediasId = {} end

	m_simpleTV.User.Retsports.LastKeyserver = keyServer
	if mediaId then m_simpleTV.User.Retsports.MediasId[mediaId] = keyServer end

	if httpLiveKeyLoader_AddEventExecutor == nil then
	  --m_simpleTV.setShowExtIntError(true)
	  dofile (m_simpleTV.MainScriptDir .. "user/httpLiveKeyLoader/httpLiveKeyLoader.lua")
	end

	httpLiveKeyLoader_AddEventExecutor('retsports_HttpLiveKeyLoaderEvent')

	m_simpleTV.Control.CurrentAddress = s .. '$OPT:POSITIONTOCONTINUE=0$OPT:NO-STIMESHIFT'
  end
end

