##  Copyright 2009-2020 Intel Corporation
##  SPDX-License-Identifier: Apache-2.0

{.deadCodeElim: on.}
when defined(windows):
  const
    ospraydll* = "ospray.dll"
else:
  const
    ospraydll* = "libospray.so"
##  Give OSPRay handle types a concrete defintion to enable C++ type checking

import OSPEnums
export OSPEnums
type
    OSPDevice* = distinct pointer
    OSPObjectOpaque = object of RootObj
    OSPObject* = ptr OSPObjectOpaque
    OSPCameraOpaque = object of OSPObjectOpaque
    OSPCamera* = ptr OSPCameraOpaque
    OSPDataOpaque = object of OSPObjectOpaque
    OSPData* = ptr OSPDataOpaque
    OSPFrameBufferOpaque = object of OSPObjectOpaque
    OSPFrameBuffer* = ptr OSPFrameBufferOpaque
    OSPFutureOpaque = object of OSPObjectOpaque
    OSPFuture* = ptr OSPFutureOpaque
    OSPGeometricModelOpaque = object of OSPObjectOpaque
    OSPGeometricModel* = ptr OSPGeometricModelOpaque
    OSPGeometryOpaque = object of OSPObjectOpaque
    OSPGeometry* = ptr OSPGeometryOpaque
    OSPGroupOpaque = object of OSPObjectOpaque
    OSPGroup* = ptr OSPGroupOpaque
    OSPImageOperationOpaque = object of OSPObjectOpaque
    OSPImageOperation* = ptr OSPImageOperationOpaque
    OSPInstanceOpaque = object of OSPObjectOpaque
    OSPInstance* = ptr OSPInstanceOpaque
    OSPLightOpaque = object of OSPObjectOpaque
    OSPLight* = ptr OSPLightOpaque
    OSPMaterialOpaque = object of OSPObjectOpaque
    OSPMaterial* = ptr OSPMaterialOpaque
    OSPRendererOpaque = object of OSPObjectOpaque
    OSPRenderer* = ptr OSPRendererOpaque
    OSPTextureOpaque = object of OSPObjectOpaque
    OSPTexture* = ptr OSPTextureOpaque
    OSPTransferFunctionOpaque = object of OSPObjectOpaque
    OSPTransferFunction* = ptr OSPTransferFunctionOpaque
    OSPVolumeOpaque = object of OSPObjectOpaque
    OSPVolume* = ptr OSPVolumeOpaque
    OSPVolumetricModelOpaque = object of OSPObjectOpaque
    OSPVolumetricModel* = ptr OSPVolumetricModelOpaque
    OSPWorldOpaque = object of OSPObjectOpaque
    OSPWorld* = ptr OSPWorldOpaque

    int64_t* = int64
    uint64_t* = uint64
    uint32_t* = uint32
    int32_t* = int32

##  OSPRay Initialization ////////////////////////////////////////////////////
##  Initialize OSPRay using commandline arguments.
##
##    equivalent to doing ospNewDevice() followed by ospSetCurrentDevice()
##
##    returns OSPError value to report any errors during initialization

proc ospInit*(argc: ptr cint; argv: cstringArray): OSPError {.importc: "ospInit",
    dynlib: ospraydll.}
##  returns the OSPRay Version in use by the device

proc ospDeviceGetProperty*(a1: OSPDevice; a2: OSPDeviceProperty): int64_t {.
    importc: "ospDeviceGetProperty", dynlib: ospraydll.}
##  Shutdown the OSPRay engine...effectively deletes whatever device is currently
##  set.

proc ospShutdown*() {.importc: "ospShutdown", dynlib: ospraydll.}
##  Create an OSPRay engine backend using explicit device string.

proc ospNewDevice*(deviceType: cstring): OSPDevice {.importc: "ospNewDevice",
    dynlib: ospraydll.}
##  Set current device the API responds to

proc ospSetCurrentDevice*(a1: OSPDevice) {.importc: "ospSetCurrentDevice",
                                        dynlib: ospraydll.}
##  Get the currently set device

proc ospGetCurrentDevice*(): OSPDevice {.importc: "ospGetCurrentDevice",
                                      dynlib: ospraydll.}
proc ospDeviceSetParam*(a1: OSPDevice; id: cstring; a3: OSPDataType; mem: pointer) {.
    importc: "ospDeviceSetParam", dynlib: ospraydll.}
proc ospDeviceRemoveParam*(a1: OSPDevice; id: cstring) {.
    importc: "ospDeviceRemoveParam", dynlib: ospraydll.}
##  Status message callback function type

type
  OSPStatusFunc* = proc (messageText: cstring)

##  Set callback for given Device to call when a status message occurs

proc ospDeviceSetStatusFunc*(a1: OSPDevice; a2: OSPStatusFunc) {.
    importc: "ospDeviceSetStatusFunc", dynlib: ospraydll.}
##  Error message callback function type

type
  OSPErrorFunc* = proc (a1: OSPError; errorDetails: cstring)

##  Set callback for given Device to call when an error occurs

proc ospDeviceSetErrorFunc*(a1: OSPDevice; a2: OSPErrorFunc) {.
    importc: "ospDeviceSetErrorFunc", dynlib: ospraydll.}
##  Get the OSPError code for the last error that has occurred on the device

proc ospDeviceGetLastErrorCode*(a1: OSPDevice): OSPError {.
    importc: "ospDeviceGetLastErrorCode", dynlib: ospraydll.}
##  Get the message for the last error that has occurred on the device

proc ospDeviceGetLastErrorMsg*(a1: OSPDevice): cstring {.
    importc: "ospDeviceGetLastErrorMsg", dynlib: ospraydll.}
##  Commit parameters on a given device

proc ospDeviceCommit*(a1: OSPDevice) {.importc: "ospDeviceCommit", dynlib: ospraydll.}
##  OSPDevice handle lifetimes

proc ospDeviceRelease*(a1: OSPDevice) {.importc: "ospDeviceRelease",
                                     dynlib: ospraydll.}
proc ospDeviceRetain*(a1: OSPDevice) {.importc: "ospDeviceRetain", dynlib: ospraydll.}
##  Load module 'name' from shard lib libospray_module_<name>.so
##    returns OSPError value to report any errors during initialization

proc ospLoadModule*(name: cstring): OSPError {.importc: "ospLoadModule",
    dynlib: ospraydll.}
##  OSPRay Data Arrays ///////////////////////////////////////////////////////

proc ospNewSharedData*(sharedData: pointer; a2: OSPDataType; numItems1: uint64_t;
                      byteStride1: int64_t; numItems2: uint64_t;
                      byteStride2: int64_t; numItems3: uint64_t;
                      byteStride3: int64_t): OSPData {.importc: "ospNewSharedData",
    dynlib: ospraydll.}
proc ospNewData*(a1: OSPDataType; numItems1: uint64_t; numItems2: uint64_t;
                numItems3: uint64_t): OSPData {.importc: "ospNewData",
    dynlib: ospraydll.}
proc ospCopyData*(source: OSPData; destination: OSPData; destinationIndex1: uint64_t;
                 destinationIndex2: uint64_t; destinationIndex3: uint64_t) {.
    importc: "ospCopyData", dynlib: ospraydll.}
##  Renderable Objects ///////////////////////////////////////////////////////

proc ospNewLight*(`type`: cstring): OSPLight {.importc: "ospNewLight",
    dynlib: ospraydll.}
proc ospNewCamera*(`type`: cstring): OSPCamera {.importc: "ospNewCamera",
    dynlib: ospraydll.}
proc ospNewGeometry*(`type`: cstring): OSPGeometry {.importc: "ospNewGeometry",
    dynlib: ospraydll.}
proc ospNewVolume*(`type`: cstring): OSPVolume {.importc: "ospNewVolume",
    dynlib: ospraydll.}
proc ospNewGeometricModel*(a1: OSPGeometry): OSPGeometricModel {.
    importc: "ospNewGeometricModel", dynlib: ospraydll.}
proc ospNewVolumetricModel*(a1: OSPVolume): OSPVolumetricModel {.
    importc: "ospNewVolumetricModel", dynlib: ospraydll.}
##  Model Meta-Data //////////////////////////////////////////////////////////

proc ospNewMaterial*(rendererType: cstring; materialType: cstring): OSPMaterial {.
    importc: "ospNewMaterial", dynlib: ospraydll.}
proc ospNewTransferFunction*(`type`: cstring): OSPTransferFunction {.
    importc: "ospNewTransferFunction", dynlib: ospraydll.}
proc ospNewTexture*(`type`: cstring): OSPTexture {.importc: "ospNewTexture",
    dynlib: ospraydll.}
##  Instancing ///////////////////////////////////////////////////////////////

proc ospNewGroup*(): OSPGroup {.importc: "ospNewGroup", dynlib: ospraydll.}
proc ospNewInstance*(a1: OSPGroup): OSPInstance {.importc: "ospNewInstance",
    dynlib: ospraydll.}
##  Top-level Worlds /////////////////////////////////////////////////////////

proc ospNewWorld*(): OSPWorld {.importc: "ospNewWorld", dynlib: ospraydll.}
type
  OSPBounds* {.bycopy.} = object
    lower*: array[3, cfloat]
    upper*: array[3, cfloat]


##  Return bounds if the object is able (OSPWorld, OSPInstance, and OSPGroup)

proc ospGetBounds*(a1: OSPObject): OSPBounds {.importc: "ospGetBounds",
    dynlib: ospraydll.}
##  Object + Parameter Lifetime Management ///////////////////////////////////
##  Set a parameter, where 'mem' points the address of the type specified

proc ospSetParam*(a1: OSPObject; id: cstring; a3: OSPDataType; mem: pointer) {.
    importc: "ospSetParam", dynlib: ospraydll.}
proc ospRemoveParam*(a1: OSPObject; id: cstring) {.importc: "ospRemoveParam",
    dynlib: ospraydll.}
##  Make parameters which have been set visible to the object

proc ospCommit*(a1: OSPObject) {.importc: "ospCommit", dynlib: ospraydll.}
##  Reduce the application-side object ref count by 1

proc ospRelease*(a1: OSPObject) {.importc: "ospRelease", dynlib: ospraydll.}
##  Increace the application-side object ref count by 1

proc ospRetain*(a1: OSPObject) {.importc: "ospRetain", dynlib: ospraydll.}
##  FrameBuffer Manipulation /////////////////////////////////////////////////

proc ospNewFrameBuffer*(size_x: cint; size_y: cint; format: OSPFrameBufferFormat;
                       frameBufferChannels: uint32_t): OSPFrameBuffer {.
    importc: "ospNewFrameBuffer", dynlib: ospraydll.}
proc ospNewImageOperation*(`type`: cstring): OSPImageOperation {.
    importc: "ospNewImageOperation", dynlib: ospraydll.}
##  Pointer access (read-only) to the memory of the given frame buffer channel

proc ospMapFrameBuffer*(a1: OSPFrameBuffer; a2: OSPFrameBufferChannel): pointer {.
    importc: "ospMapFrameBuffer", dynlib: ospraydll.}
##  Unmap a previously mapped frame buffer pointer

proc ospUnmapFrameBuffer*(mapped: pointer; a2: OSPFrameBuffer) {.
    importc: "ospUnmapFrameBuffer", dynlib: ospraydll.}
##  Get variance from last rendered frame

proc ospGetVariance*(a1: OSPFrameBuffer): cfloat {.importc: "ospGetVariance",
    dynlib: ospraydll.}
##  Reset frame buffer accumulation for next render frame call

proc ospResetAccumulation*(a1: OSPFrameBuffer) {.importc: "ospResetAccumulation",
    dynlib: ospraydll.}
##  Frame Rendering //////////////////////////////////////////////////////////

proc ospNewRenderer*(`type`: cstring): OSPRenderer {.importc: "ospNewRenderer",
    dynlib: ospraydll.}
##  Render a frame (non-blocking), return a future to the task executed by OSPRay

proc ospRenderFrame*(a1: OSPFrameBuffer; a2: OSPRenderer; a3: OSPCamera; a4: OSPWorld): OSPFuture {.
    importc: "ospRenderFrame", dynlib: ospraydll.}
##  Ask if all events tracked by an OSPFuture handle have been completed

proc ospIsReady*(a1: OSPFuture; a2: OSPSyncEvent): cint {.importc: "ospIsReady",
    dynlib: ospraydll.}
##  Wait on a specific event

proc ospWait*(a1: OSPFuture; a2: OSPSyncEvent) {.importc: "ospWait", dynlib: ospraydll.}
##  Cancel the given task (may block calling thread)

proc ospCancel*(a1: OSPFuture) {.importc: "ospCancel", dynlib: ospraydll.}
##  Get the completion state of the given task [0.f-1.f]

proc ospGetProgress*(a1: OSPFuture): cfloat {.importc: "ospGetProgress",
    dynlib: ospraydll.}
##  Get the execution duration (in seconds) state of the given task

proc ospGetTaskDuration*(a1: OSPFuture): cfloat {.importc: "ospGetTaskDuration",
    dynlib: ospraydll.}
type
  OSPPickResult* {.bycopy.} = object
    hasHit*: cint
    worldPosition*: array[3, cfloat]
    instance*: OSPInstance
    model*: OSPGeometricModel
    primID*: uint32_t


proc ospPick*(result: ptr OSPPickResult; a2: OSPFrameBuffer; a3: OSPRenderer;
             a4: OSPCamera; a5: OSPWorld; screenPos_x: cfloat; screenPos_y: cfloat) {.
    importc: "ospPick", dynlib: ospraydll.}