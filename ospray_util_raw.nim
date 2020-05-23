##  Copyright 2009-2019 Intel Corporation
##  SPDX-License-Identifier: Apache-2.0

import
  ospray_raw

{.deadCodeElim: on.}
when defined(windows):
  const
    ospraydll* = "ospray.dll"
else:
  const
    ospraydll* = "libospray.so"
##  OSPData helpers //////////////////////////////////////////////////////////

proc ospNewSharedData1D*(sharedData: pointer; `type`: OSPDataType; numItems: uint64_t): OSPData {.
    importc: "ospNewSharedData1D", dynlib: ospraydll.}
proc ospNewSharedData1DStride*(sharedData: pointer; `type`: OSPDataType;
                              numItems: uint64_t; byteStride: int64_t): OSPData {.
    importc: "ospNewSharedData1DStride", dynlib: ospraydll.}
proc ospNewSharedData2D*(sharedData: pointer; `type`: OSPDataType;
                        numItems1: uint64_t; numItems2: uint64_t): OSPData {.
    importc: "ospNewSharedData2D", dynlib: ospraydll.}
proc ospNewSharedData2DStride*(sharedData: pointer; `type`: OSPDataType;
                              numItems1: uint64_t; byteStride1: int64_t;
                              numItems2: uint64_t; byteStride2: int64_t): OSPData {.
    importc: "ospNewSharedData2DStride", dynlib: ospraydll.}
proc ospNewSharedData3D*(sharedData: pointer; `type`: OSPDataType;
                        numItems1: uint64_t; numItems2: uint64_t;
                        numItems3: uint64_t): OSPData {.
    importc: "ospNewSharedData3D", dynlib: ospraydll.}
proc ospNewData1D*(`type`: OSPDataType; numItems: uint64_t): OSPData {.
    importc: "ospNewData1D", dynlib: ospraydll.}
proc ospNewData2D*(`type`: OSPDataType; numItems1: uint64_t; numItems2: uint64_t): OSPData {.
    importc: "ospNewData2D", dynlib: ospraydll.}
proc ospCopyData1D*(source: OSPData; destination: OSPData; destinationIndex: uint64_t) {.
    importc: "ospCopyData1D", dynlib: ospraydll.}
proc ospCopyData2D*(source: OSPData; destination: OSPData;
                   destinationIndex1: uint64_t; destinationIndex2: uint64_t) {.
    importc: "ospCopyData2D", dynlib: ospraydll.}
##  Parameter helpers //////////////////////////////////////////////////////////

proc ospSetString*(a1: OSPObject; n: cstring; s: cstring) {.importc: "ospSetString",
    dynlib: ospraydll.}
proc ospSetObject*(a1: OSPObject; n: cstring; obj: OSPObject) {.
    importc: "ospSetObject", dynlib: ospraydll.}
proc ospSetBool*(a1: OSPObject; n: cstring; x: cint) {.importc: "ospSetBool",
    dynlib: ospraydll.}
proc ospSetFloat*(a1: OSPObject; n: cstring; x: cfloat) {.importc: "ospSetFloat",
    dynlib: ospraydll.}
proc ospSetInt*(a1: OSPObject; n: cstring; x: cint) {.importc: "ospSetInt",
    dynlib: ospraydll.}
##  clang-format off

proc ospSetVec2f*(a1: OSPObject; n: cstring; x: cfloat; y: cfloat) {.
    importc: "ospSetVec2f", dynlib: ospraydll.}
proc ospSetVec3f*(a1: OSPObject; n: cstring; x: cfloat; y: cfloat; z: cfloat) {.
    importc: "ospSetVec3f", dynlib: ospraydll.}
proc ospSetVec4f*(a1: OSPObject; n: cstring; x: cfloat; y: cfloat; z: cfloat; w: cfloat) {.
    importc: "ospSetVec4f", dynlib: ospraydll.}
proc ospSetVec2i*(a1: OSPObject; n: cstring; x: cint; y: cint) {.importc: "ospSetVec2i",
    dynlib: ospraydll.}
proc ospSetVec3i*(a1: OSPObject; n: cstring; x: cint; y: cint; z: cint) {.
    importc: "ospSetVec3i", dynlib: ospraydll.}
proc ospSetVec4i*(a1: OSPObject; n: cstring; x: cint; y: cint; z: cint; w: cint) {.
    importc: "ospSetVec4i", dynlib: ospraydll.}
##  Take 'obj' and put it in an opaque OSPData array with given element type, then set on 'target'

proc ospSetObjectAsData*(target: OSPObject; n: cstring; `type`: OSPDataType;
                        obj: OSPObject) {.importc: "ospSetObjectAsData",
                                        dynlib: ospraydll.}
##  clang-format on
##  Rendering helpers //////////////////////////////////////////////////////////
##  Start a frame task and immediately wait on it, return frame buffer varaince

proc ospRenderFrameBlocking*(a1: OSPFrameBuffer; a2: OSPRenderer; a3: OSPCamera;
                            a4: OSPWorld): cfloat {.
    importc: "ospRenderFrameBlocking", dynlib: ospraydll.}