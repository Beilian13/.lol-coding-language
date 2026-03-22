-- LOLang Feature Showcase  (CMD mode)
-- Demonstrates: math, functions, loops, strings, recursion,
--               path API, file I/O, tones

print("╔══════════════════════════════════════╗")
print("║   LOLang Feature Showcase            ║")
print("╚══════════════════════════════════════╝")
print("")

-- ── 1. FizzBuzz ───────────────────────────────────────────
print("── FizzBuzz 1-20 ──────────────────────")
for i = 1, 20 do
    if i % 15 == 0 then
        print("FizzBuzz")
    elseif i % 3 == 0 then
        print("Fizz")
    elseif i % 5 == 0 then
        print("Buzz")
    else
        print(i)
    end
end
print("")

-- ── 2. Fibonacci (recursive) ──────────────────────────────
print("── Fibonacci 0-12 ─────────────────────")
func fib(n)
    if n <= 1 then return n end
    return fib(n-1) + fib(n-2)
end
let fibline = ""
for i = 0, 12 do
    fibline = fibline + tostr(fib(i))
    if i < 12 then fibline = fibline + "  " end
end
print(fibline)
print("")

-- ── 3. Math functions ─────────────────────────────────────
print("── Math ───────────────────────────────")
print("sqrt(144)   = " + tostr(sqrt(144)))
print("floor(3.9)  = " + tostr(floor(3.9)))
print("ceil(3.1)   = " + tostr(ceil(3.1)))
print("abs(-42)    = " + tostr(abs(-42)))
print("sin(PI/2)   = " + tostr(sin(1.5708)))
print("cos(0)      = " + tostr(cos(0)))
print("2^10        = " + tostr(2^10))
print("rand(1,100) = " + tostr(rand(1,100)))
print("")

-- ── 4. String building ────────────────────────────────────
print("── Strings ────────────────────────────")
func repeat_str(s, n)
    let out = ""
    let i = 0
    while i < n do
        out = out + s
        i = i + 1
    end
    return out
end
print(repeat_str("█", 20))
print(repeat_str("▓░", 10))
print("")

-- ── 5. Path API ───────────────────────────────────────────
print("── Path API ───────────────────────────")
print("scriptFile   = " + scriptFile)
print("scriptParent = " + scriptParent)
print("path_name    = " + path_name(scriptFile))
print("path_ext     = " + path_ext(scriptFile))
print("path_exists? = " + tostr(path_exists(scriptParent)))
print("")

-- ── 6. File I/O ───────────────────────────────────────────
print("── File I/O ───────────────────────────")
let savepath = path_join(scriptParent, "showcase_save.txt")
writeFile(savepath, "run=1\nfib12=" + tostr(fib(12)) + "\n")
appendFile(savepath, "greeting=hello from LOLang!\n")
print("Wrote + appended to showcase_save.txt")
let contents = readFile(savepath)
print("Contents:")
print(contents)

-- ── 7. Tone demo ──────────────────────────────────────────
print("── Playing tones (no WAV needed) ──────")
print("Ascending scale...")
tone(261,100,0.4,0)
tone(293,100,0.4,0)
tone(329,100,0.4,0)
tone(349,100,0.4,0)
tone(392,100,0.4,0)
tone(440,100,0.4,0)
tone(493,100,0.4,0)
tone(523,150,0.5,0)
print("Done!")
print("")
print("╔══════════════════════════════════════╗")
print("║   All features working correctly!    ║")
print("╚══════════════════════════════════════╝")
