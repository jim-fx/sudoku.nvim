local M = {}

M.tableConcat = function(t1, t2)
  for i = 1, #t2 do
    t1[#t1 + 1] = t2[i]
  end
  return t1
end

local function dump(o)
  if type(o) == 'table' then
    local s = '{ '
    for k, v in pairs(o) do
      if type(k) ~= 'number' then k = '"' .. k .. '"' end
      s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
    end
    return s .. '}\n '
  else
    return "  " .. tostring(o)
  end
end

M.dump = function(o)
  print(dump(o));
end

M.pickRandom = function(T)
  return T[math.random(#T)]
end

M.tableLength = function(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
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

return M
