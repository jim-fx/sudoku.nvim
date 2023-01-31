local M = {}

M.tableConcat = function(t1, t2)
  for i = 1, #t2 do
    t1[#t1 + 1] = t2[i]
  end
  return t1
end

M.pickRandom = function(T)
  return T[math.random(#T)]
end

M.tableLength = function(T)
  local count = 0
  for _ in pairs(T) do
    count = count + 1
  end
  return count
end

M.shallowCopy = function(t)
  local copy = {}
  for key, value in pairs(t) do
    copy[key] = value
  end
  return copy
end

M.shuffle = function(x)
  local shuffled = {}
  for _, v in ipairs(x) do
    local pos = math.random(1, #shuffled + 1)
    table.insert(shuffled, pos, v)
  end
  return shuffled
end

M.getPos = function()
  local y = vim.fn.line(".")
  local x = vim.fn.virtcol(".")

  local fx = math.floor((x - 3) / 2)
  if (fx + 1) % 4 == 0 or x % 2 == 0 then
    fx = -1
  else
    fx = fx - math.floor((fx + 1) / 4)
  end

  local fy = y - 2
  if (fy + 1) % 4 == 0 then
    fy = -1
  else
    fy = fy - math.floor(fy / 4)
  end

  if fx > 8 then
    fx = -1
  end

  if fy > 8 then
    fy = -1
  end

  return fx, fy
end


return M
