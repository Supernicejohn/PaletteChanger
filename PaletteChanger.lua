local palettes = {default = {},new = {}}
local MaxX,MaxY = term.getSize()
term.setBackgroundColor(colors.black)
term.clear()
local function translateHEX(d) -- credit to Lostgallifreyan on Lua-users.org
   local k,res,I,D="0123456789ABCDEF","",0
   while d>0 do
      I=I+1
      d,D=math.floor(IN/16),math.mod(IN,16)+1
      res=string.sub(k,D,D)..res
   end
   return res
end

local function toHEX(R,G,B)
	local r,g,b = R*255,G*255,B*255
	return translateHEX(r)..translateHEX(g)..translateHEX(b)
end
local function fromHEX(hex)
	local r,g,b = hex:sub(1,2),hex:sub(3,4),hex:sub(5,6)
	return tonumber(r,16),tonumber(g,16),tonumber(b,16)
end
local function currentPalette()
	local p = {}
	for i=0,15 do
		p[i] = {term.getPaletteColor(2^i)} -- p[i] = 3.1415
	end
	return p
end
local function setPalette(p)

	for i=0,15 do
		if type(p[i]) ~= "table" then error("!",2) end
		term.setPaletteColor(2^i,p[i][1],p[i][2],p[i][3])
	end
end
palettes.default = currentPalette()
palettes.new = currentPalette()
local function generatePalette(maxR,maxG,maxB,index) -- linear scale from 0,0,0 to values.
	for i=1,4 do
		term.setPaletteColor(2^(i+index-1),maxR*i/4,maxG*i/4,maxB*i/4)
	end
end
local function drawSlider(x,y,b,index) -- x and y pos, color, index for color table
	generatePalette(b[1],b[2],b[3],index)
	for i=0,4 do
		term.setCursorPos(x+i*3,y)
		term.setTextColor(2^(i+index))
		if i>0 then
			term.setBackgroundColor(2^(i+index-1))
		else
			term.setBackgroundColor(2^12)
		end
		write(i==4 and " " or " *#")
	end
end
local function changeColor(index)
	palettes.new = currentPalette()
	term.setPaletteColor(2^15,unpack(palettes.new[index]))
	term.setPaletteColor(2^14,term.getPaletteColor(2^15))
	term.setPaletteColor(2^12,0,0,0)
	term.setPaletteColor(2^13,1,1,1)
	term.setBackgroundColor(2^12)
	term.clear()
	local colorChange = 1
	local temp
	while true do
		temp = {term.getPaletteColor(2^14)}
		term.clear()
		drawSlider(4,4,{1,0,0},0)
		drawSlider(4,6,{0,1,0},4)
		drawSlider(4,8,{0,0,1},8)
		paintutils.drawFilledBox(2,10,7,15,2^15)
		paintutils.drawFilledBox(12,10,17,15,2^14)
		term.setTextColor(2^13)
		term.setBackgroundColor(2^12)
		for i=1,3 do
			term.setCursorPos(30,2+2*i)
			write(math.floor(255*temp[i]))
		end
		term.setCursorPos(1,MaxY)
		term.setTextColor(2^13)
		term.setBackgroundColor(2^7)
		write("Confirm")
		term.setCursorPos(8,MaxY)
		term.setBackgroundColor(2^3)
		write("Cancel")
		term.setBackgroundColor(2^12)
		term.setCursorPos(3,2+2*colorChange)
		write(">")
		term.setCursorPos(17,2+2*colorChange)
		write("<")
		for i=1,3 do
			term.setCursorPos(4+temp[i]*12,1+2*i)
			write("v")
		end
		local e = {os.pullEvent()}
		if e[1] == "key" then
			if e[2] == keys.up then
				colorChange = math.max(1,colorChange-1)
			elseif e[2] == keys.down then
				colorChange = math.min(3,colorChange+1)
			elseif e[2] == keys.left then
				temp[colorChange] = math.max(0,temp[colorChange]-(1/255))
			elseif e[2] == keys.right then
				temp[colorChange] = math.min(1,temp[colorChange]+(1/255))
			elseif e[2] == keys.enter then
				break
			elseif e[2] == keys.backspace then
				temp = term.getPaletteColor(2^15)
				break
			end
		elseif e[1]:sub(1,5) == "mouse" then
			if e[3] > 3 and e[3] < 17 and e[4] > 2 and e[4] < 9 then
				colorChange = math.floor((e[4]-1)/2)
				temp[colorChange] = (e[3]-4)/12
			elseif e[4] == MaxY then
				if e[3] < 8 then
					break
				elseif e[3] < 14 then
					temp = {term.getPaletteColor(2^15)}
					break
				end
			end
		end
		term.setPaletteColor(2^14,unpack(temp))
	end
	palettes.new[index] = {unpack(temp)}
	setPalette(palettes.new)
	term.setBackgroundColor(2^15)
	term.clear()
end
while true do
	for i=0,15 do
		term.setCursorPos(i*3+4,4)
		term.setBackgroundColor(2^i)
		write("   ")
	end
	term.setTextColor(colors.white)
	term.setBackgroundColor(colors.green)
	term.setCursorPos(1,MaxY)
	write("Save & Exit")
	term.setBackgroundColor(colors.red)
	term.setCursorPos(12,MaxY)
	write("Cancel & Exit")
	local selectedIndex = 0
	local e = {os.pullEvent()}
	if e[1] == "mouse_click" then
		if e[4] == 4 then
			e[3] = math.floor((e[3]-4)/3)
			if e[3] >= 0 and e[3] < 16 then
				changeColor(e[3])
			end
		elseif e[4] == MaxY then
			if e[3] < 12 then
				setPalette(palettes.new)
				break
			elseif e[3] < 25 then
				setPalette(palettes.default)
				break
			end
		end
	end
end
term.setTextColor(colors.white)
term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1,1)
