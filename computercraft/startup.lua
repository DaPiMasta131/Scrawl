local user = "DaPiMasta131"
local repo = "Scrawl"
local url = "https://api.github.com/repos/" .. user .."/" .. repo
local branch = "main"

local function update()
  local response, version, err, data, sha, file
  version = settings.get("git.version")
  response, err = http.get(url .. "/commits/" .. branch)
  if not response then error(err) end
  data = textutils.unserializeJSON(response.readAll())
  response.close()
  sha = data.sha
  if version then
    if version == sha then return true end
    response, err = http.get(url .. "/compare/" .. version .. "..." .. sha .. ".diff")
    if not response then error(err) end
    data = response.readAll()
    response.close()
    -- process data as a diff
  else
    response, err = http.get(url .. "/git/trees/" .. branch .. "?recursive=1")
    if not response then error(err) end
    data = textutils.unserializeJSON(response.readAll())
    response.close()
    for _, leaf in ipairs(data.tree) do
      file, err = fs.open(leaf.path, "w")
      if not file then error(err) end
      response, err = http.get(leaf.url)
      if not response then error(err) end
      file.write(response.readAll())
      response.close()
    end
  end
  settings.set("git.version", sha)
  settings.save()
  os.reboot()
end

update()
