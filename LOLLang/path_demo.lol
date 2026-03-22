-- Path & filesystem demo  (CMD mode)

print("=== LOLang Path API Demo ===")
print("")

-- ── scriptParent / scriptFile ─────────────────────────────
print("scriptFile   = " + scriptFile)
print("scriptParent = " + scriptParent)
print("")

-- ── path_join ─────────────────────────────────────────────
let sounds   = path_join(scriptParent, "sounds")
let savefile = path_join(scriptParent, "save.txt")
print("sounds folder = " + sounds)
print("save file     = " + savefile)
print("")

-- ── path decomposition ────────────────────────────────────
let ex = path_join(scriptParent, "shoot.wav")
print("path_name   = " + path_name(ex))
print("path_stem   = " + path_stem(ex))
print("path_ext    = " + path_ext(ex))
print("path_parent = " + path_parent(ex))
print("path_abs    = " + path_abs(ex))
print("")

-- ── existence checks ──────────────────────────────────────
print("scriptParent exists? " + tostr(path_exists(scriptParent)))
print("shoot.wav exists?    " + tostr(path_isFile("shoot.wav")))
print("sounds/ is a dir?    " + tostr(folder_exists(sounds)))
print("")

-- ── folder listing ────────────────────────────────────────
print("Files in script folder:")
print(folder_list(scriptParent))

-- ── writeFile / readFile / appendFile ────────────────────
writeFile(savefile, "score=999\nwave=5\nlives=2\n")
print("Wrote save.txt:")
print(readFile(savefile))

appendFile(savefile, "kills=42\n")
print("After append:")
print(readFile(savefile))

-- ── folder_create ─────────────────────────────────────────
let logdir = path_join(scriptParent, "logs")
folder_create(logdir)
if folder_exists(logdir) == 1 then
    print("Created logs/ OK")
    writeFile(path_join(logdir, "session.log"), "game started\n")
    print("Wrote logs/session.log")
end

print("=== Done ===")
