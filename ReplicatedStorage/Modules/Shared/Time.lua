local TimeUtil = {}

function TimeUtil.toHMS(seconds)
	return ("%02i:%02i:%02i"):format(seconds/60^2, seconds/60%60, seconds%60)
end

return TimeUtil