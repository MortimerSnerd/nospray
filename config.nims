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

    switch("path", "vendor/ospray-2.1.0/include")
    switch("out", outName)

