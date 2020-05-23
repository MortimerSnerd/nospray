## Wrapped ospray_raw API that retains and releases Ospray handles 
## automatically.
import
  ospray_raw, ospray_util_raw, OSPEnums

export ospray_raw

type
  ManagedHandle* = object of RootObj
    ## Handle for an OSPRay object that will ospRelease()
    ## the underlying handle when it goes out of scope. 
    ## Also includes `set*()` functions for setting parameters
    ## on the handles.
    hndl: OSPObject

  # 1 level hierarchy of handles - everything can cast to a ManagedHandle, but
  # are otherwise not interchangable.
  Camera* = object of ManagedHandle
  Geometry* = object of ManagedHandle
  Data* = object of ManagedHandle
  Material* = object of ManagedHandle
  GeometricModel* = object of ManagedHandle
  Group* = object of ManagedHandle
  Instance* = object of ManagedHandle
  World* = object of ManagedHandle
  Light* = object of ManagedHandle
  Renderer* = object of ManagedHandle
  FrameBuffer* = object of ManagedHandle

  Library* = object
    ## Object that scopes the initialization and 
    ## shutdown for the entire library. Makes things
    ## work smoother with the other scoped objects
    ## if you don't have to call ospShutdown() explicitly, 
    ## so your call won't be ordered before destructors
    ## that still call into the library.
    initialized: bool

proc `=destroy`*(l: var Library) = 
  if l.initialized:
    when defined(loudDestroy):
      echo "library shutdown"
    ospShutdown()
    l.initialized = false

proc `=`*(l: var Library; ll: Library) {.error.}

template validHandle*(h: ManagedHandle) : bool = h.hndl != nil

proc `=destroy`*(mh: var ManagedHandle) = 
  if mh.hndl != nil:
    when defined(loudDestroy):
      echo "ospRelease " & repr(cast[pointer](mh.hndl))
    ospRelease(mh.hndl)
    mh.hndl = nil

proc `=`*(a: var ManagedHandle; b: ManagedHandle)  {.error.}

proc set*(h: ManagedHandle; name: string; val: float32) = 
  ## Sets a parameter on an object.  
  assert validHandle(h)
  ospSetFloat(h.hndl, name, val)

template setVec3f*(h: ManagedHandle; name: string; val: ptr float32) = 
  assert validHandle(h)
  ospSetParam(h.hndl, name, OSP_VEC3f, val)

proc commit*(h: ManagedHandle) = 
  assert validHandle(h)
  ospCommit(h.hndl)

proc set*(h: ManagedHandle; name: string; val: ManagedHandle) = 
  assert validHandle(h)
  ospSetObject(h.hndl, name, val.hndl)

proc setObjectAsData*(h: ManagedHandle; name: string; mdl: GeometricModel) = 
  ## Reminder - ospSetObjectAsData is a helper function for assigning a single
  ## item to an array, without having to create the array.  This is not the same
  ## as the other set* calls.
  ospSetObjectAsData(h.hndl, name, OSPDataType.OSP_GEOMETRIC_MODEL, mdl.hndl)

proc setObjectAsData*(h: ManagedHandle; name: string; inst: Instance) = 
  ospSetObjectAsData(h.hndl, name, OSPDataType.OSP_INSTANCE, inst.hndl)

proc setObjectAsData*(h: ManagedHandle; name: string; inst: Light) = 
  ospSetObjectAsData(h.hndl, name, OSPDataType.OSP_LIGHT, inst.hndl)

proc init*(args: openarray[string]): (OSPError, seq[string], Library) = 
  ## Initializes the library.  On success, returns 
  ## (OSP_NO_ERROR, args - any ospray args consumed by the library).
  ## Returns (Some OSPError, undefined) if there was an error.
  let csArgs = allocCStringArray(args)
  var numArgs = cint(len(args))

  try:
    let rc = ospInit(addr numArgs, csArgs)

    if rc == OSP_NO_ERROR:
      result = (rc, cstringArrayToSeq(csArgs, numArgs), 
                Library(initialized: true))
    else:
      result = (rc, @[], Library())

  finally:
    deallocCStringArray(csArgs)


proc newCamera*(kind: string): Camera = 
  Camera(hndl: ospNewCamera(kind))

proc newGeometry*(kind: string) : Geometry = 
  Geometry(hndl: ospNewGeometry(kind))

proc newSharedData1D*(sharedData: pointer; `type`: OSPDataType; 
                         numItems: uint64_t): Data = 
  Data(hndl: ospNewSharedData1D(sharedData, `type`, numItems))

proc newMaterial*(rendererType: string; materialType: cstring): Material = 
  Material(hndl: ospNewMaterial(rendererType, materialType))

proc newGeometricModel*(a1: Geometry): GeometricModel = 
  GeometricModel(hndl: ospNewGeometricModel(cast[OSPGeometry](a1.hndl)))

proc newGroup*(): Group = 
  Group(hndl: ospNewGroup())

proc newInstance*(a1: Group): Instance = 
  Instance(hndl: ospNewInstance(cast[OSPGroup](a1.hndl)))

proc newWorld*() : World = 
  World(hndl: ospNewWorld())

proc newLight*(kind: string) : Light = 
  Light(hndl: ospNewLight(kind))

proc getBounds*(obj: World|Instance|Group) : OSPBounds = 
  ospGetBounds(obj.hndl)

proc newRenderer*(kind: string) : Renderer = 
  Renderer(hndl: ospNewRenderer(kind))

proc newFrameBuffer*(size_x: cint; size_y: cint; format: OSPFrameBufferFormat;
                     frameBufferChannels: uint32_t): FrameBuffer  = 
  FrameBuffer(hndl: ospNewFrameBuffer(size_x, size_y, format, 
                                      frameBufferChannels))

proc resetAccumulation*(a1: FrameBuffer) = 
  ospResetAccumulation(cast[OSPFrameBuffer](a1.hndl))

proc renderFrameBlocking*(a1: FrameBuffer; a2: Renderer; a3: Camera;
                          a4: World): cfloat = 
  ospRenderFrameBlocking(cast[OSPFrameBuffer](a1.hndl), 
                         cast[OSPRenderer](a2.hndl),
                         cast[OSPCamera](a3.hndl),
                         cast[OSPWorld](a4.hndl))

proc mapFrameBuffer*[T](fb: FrameBuffer; channel: OSPFrameBufferChannel): ptr T = 
  cast[ptr T](ospMapFrameBuffer(cast[OSPFrameBuffer](fb.hndl), 
                                channel))


proc unmapFrameBuffer*[T](mapped: ptr T; fb: FrameBuffer) = 
  ospUnmapFrameBuffer(mapped, cast[OSPFrameBuffer](fb.hndl))
