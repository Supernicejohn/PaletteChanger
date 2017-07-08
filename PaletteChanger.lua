-- V 0.1 Proof of concept!

local palette = {}
local previousPalette = {}
local MaxX,MaxY = term.getSize()

local function setCol(index,R,G,B)
	term.setPaletteColor(2^index,R/255,G/255,B/255)
end

local function storeCurrentPalette()
	for i=0,15 do
		palette[i] = {term.getPaletteColor(2^i)}
	end
	return {unpack(palette)}
end

local function modifyColor(index)
	local oldPalette = storeCurrentPalette()
	for i=1,3 do
		palette[0][i] = palette[index][i]*255
	end
	currentColorMod = 1
	while true do
		local a = {term.getPaletteColor(4)}
		term.setPaletteColor(4,1,1,1)
		term.setTextColor(4)
		term.clear()
		term.setCursorPos(1,1)
		term.setBackgroundColor(2^index)
		print("UP/DOWN - cycle RGB")
		print("LEFT/RIGHT - change value")
		print("Enter - confirm")
		print("Space - Undo & Exit")
		for i=1,3 do
			term.setCursorPos(math.floor(MaxX/2)-(i==currentColorMod and 2 or 1),5+i)
			print((i==currentColorMod and "[" or "")..palette[0][i]..(i==currentColorMod and "]" or ""))
		end
		local e = {os.pullEvent("key")}
		if e[2] == keys.up then
			currentColorMod = math.max(currentColorMod-1,1)
		elseif e[2] == keys.down then
			currentColorMod = math.min(currentColorMod+1,3)
		elseif e[2] == keys.left then
			palette[0][currentColorMod] = math.max(palette[0][currentColorMod]-1,0)
		elseif e[2] == keys.right then
			palette[0][currentColorMod] = math.min(palette[0][currentColorMod]+1,255)
		elseif e[2] == keys.enter then
			setCol(index,palette[0][1],palette[0][2],palette[0][3])
			return true
		elseif e[2] == keys.space then
			setCol(index,oldPalette[index-1][1],oldPalette[index-1][2],oldPalette[index-1][3])
			return
		end
		setCol(index,palette[0][1],palette[0][2],palette[0][3])
		term.setPaletteColor(4,unpack(a))
	end	
end

storeCurrentPalette()
for i=0,15 do
	previousPalette[i] = {palette[i][1]*255,palette[i][2]*255,palette[i][3]*255}
end

while true do
	term.clear()
	term.setCursorPos(1,1)
	write("Click on a color to change it!")
	local c = {"0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"}
	for i=1,16 do
		term.setCursorPos(1,i+1)
		term.blit("   ","000",c[i]:rep(3))
	end
	term.setCursorPos(1,MaxY)
	term.blit("Save & Exit",("0"):rep(11),("5"):rep(11))
	term.setCursorPos(12,MaxY)
	term.blit("Exit",("0"):rep(4),("e"):rep(4))


	local e = {os.pullEvent("mouse_click")}
	if e[3] < 4 and e[4] < 18 and e[4] > 1 then
		modifyColor(e[4]-2)
	elseif e[4] == MaxY then
		if e[3] < 12 then
			term.setCursorPos(1,1)
			term.setTextColor(1)
			term.setBackgroundColor(colors.black)
			term.clear()
			error("Quit",0)
		elseif e[3] < 16 then
			for i=0,15 do
				setCol(i,previousPalette[i][1],previousPalette[i][2],previousPalette[i][3])
			end
			term.setCursorPos(1,1)
			term.setTextColor(1)
			term.setBackgroundColor(colors.black)
			term.clear()
			error("Quit",0)
		end
	end
end
