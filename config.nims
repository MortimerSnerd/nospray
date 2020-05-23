task build, "Builds debug version":
    var outName : string

    when defined(windows):
      outName = "nostest.exe"
    else:
      outName = "nostest"

    setCommand "c", "nostest"
    --gc:arc


    --listFullPaths
    --threads:on
    --threadAnalysis:on
    --define: debug

    --warnings:on
    --hints:on
    --colors:off

    switch("path", "src")
    switch("out", outName)

task buildWrapped, "Builds debug version of the wrapped test module":
    var outName : string

    when defined(windows):
      outName = "wrnostest.exe"
    else:
      outName = "wrnostest"

    setCommand "c", "wrapped_nostest"
    --gc:arc


    --listFullPaths
    --threads:on
    --threadAnalysis:on
    --define: debug

    --warnings:on
    --hints:on
    --colors:off

    switch("path", "src")
    switch("out", outName)

