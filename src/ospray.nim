## Wrapped ospray_raw API that retains and releases Ospray handles 
## automatically.
import
  ospray_raw, ospray_util_raw, OSPEnums, strformat, typetraits

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

template declareTypeBoundFunctions(T: typedesc) : untyped = 
  ## Generates some type bound functions.  Noisy, but necessary since
  ## we made the handles a shallow type hierarchy.
  proc `$`*(h: T) : string = 
    "[" & T.name & " " & repr(cast[pointer](h.hndl)) & "]"
    
  proc `=destroy`*(mh: var T) = 
    if mh.hndl != nil:
      when defined(loudDestroy):
        echo "ospRelease " & T.name & " " & repr(cast[pointer](mh.hndl))
      ospRelease(mh.hndl)
      mh.hndl = nil

  proc `=`*(a: var T; b: T) = 
    if a.hndl != b.hndl:
      `=destroy`(a)
      a.hndl = b.hndl
      ospRetain(a.hndl)
      when defined(loudDestroy):
        echo "retaining " & T.name & " " &  cast[pointer](a.hndl).repr

  proc `=sink`*(a: var T; b: T) = 
    `=destroy`(a)
    a.hndl = b.hndl
    when defined(loudDestroy):
      echo "sinking " & T.name & " " &  cast[pointer](a.hndl).repr

declareTypeBoundFunctions(ManagedHandle)
declareTypeBoundFunctions(Camera)
declareTypeBoundFunctions(Geometry)
declareTypeBoundFunctions(Data)
declareTypeBoundFunctions(Material)
declareTypeBoundFunctions(GeometricModel)
declareTypeBoundFunctions(Group)
declareTypeBoundFunctions(Instance)
declareTypeBoundFunctions(World)
declareTypeBoundFunctions(Light)
declareTypeBoundFunctions(Renderer)
declareTypeBoundFunctions(FrameBuffer)

proc `=destroy`*(l: var Library) = 
  if l.initialized:
    when defined(loudDestroy):
      echo "library shutdown"
    ospShutdown()
    l.initialized = false

proc `=`*(l: var Library; ll: Library) {.error.}

template validHandle*(h: ManagedHandle) : bool = h.hndl != nil

template mkh(tname: typedesc; hnd0: untyped) : untyped = 
  let newh = hnd0
  when defined(loudDestroy):
    echo "making " & tname.name & " " & cast[pointer](newh).repr
  tname(hndl: newh)

proc retain*(h: ManagedHandle) = 
  ## If the handle is valid, bumps it's reference count up so it 
  ## will not be destroyed when `h` goes out of scope.
  ## The object the handle refers to will be leaked unless 
  ## an explicit call to `release()` is made later.
  ospRetain(h.hndl)

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
  # It's expecting C argv, so position 0 is expected to be the 
  # program name.  
  var argv = @["program"]

  add(argv, args)
  let csArgs = allocCStringArray(argv)
  var numArgs = cint(len(argv))

  try:
    let rc = ospInit(addr numArgs, csArgs)

    if rc == OSP_NO_ERROR:
      var rarr = cstringArrayToSeq(csArgs, numArgs)
      delete(rarr, 0)
      csArgs[0] = nil # Don't free our fake param.
      result = (rc, rarr, 
                Library(initialized: true))
    else:
      result = (rc, @[], Library())

  finally:
    deallocCStringArray(csArgs)


proc newCamera*(kind: string): Camera = 
  mkh(Camera, ospNewCamera(kind))

proc newGeometry*(kind: string) : Geometry = 
  mkh(Geometry, ospNewGeometry(kind))

proc newSharedData1D*(sharedData: pointer; `type`: OSPDataType; 
                         numItems: uint64_t): Data = 
  mkh(Data, ospNewSharedData1D(sharedData, `type`, numItems))

proc newMaterial*(rendererType: string; materialType: cstring): Material = 
  mkh(Material, ospNewMaterial(rendererType, materialType))

proc newGeometricModel*(a1: Geometry): GeometricModel = 
  mkh(GeometricModel, ospNewGeometricModel(cast[OSPGeometry](a1.hndl)))

proc newGroup*(): Group = 
  mkh(Group, ospNewGroup())

proc newInstance*(a1: Group): Instance = 
  mkh(Instance, ospNewInstance(cast[OSPGroup](a1.hndl)))

proc newWorld*() : World = 
  mkh(World, ospNewWorld())

proc newLight*(kind: string) : Light = 
  mkh(Light, ospNewLight(kind))

proc getBounds*(obj: World|Instance|Group) : OSPBounds = 
  ospGetBounds(obj.hndl)

proc newRenderer*(kind: string) : Renderer = 
  mkh(Renderer, ospNewRenderer(kind))

proc newFrameBuffer*(size_x: cint; size_y: cint; format: OSPFrameBufferFormat;
                     frameBufferChannels: uint32_t): FrameBuffer  = 
  mkh(FrameBuffer, ospNewFrameBuffer(size_x, size_y, format, 
                                      frameBufferChannels))

proc resetAccumulation*(a1: FrameBuffer) = 
  ospResetAccumulation(cast[OSPFrameBuffer](a1.hndl))

proc renderFrameBlocking*(a1: FrameBuffer; a2: Renderer; a3: Camera;
                          a4: World): cfloat = 
  ospRenderFrameBlocking(cast[OSPFrameBuffer](a1.hndl), 
                         cast[OSPRenderer](a2.hndl),
                         cast[OSPCamera](a3.hndl),
                         cast[OSPWorld](a4.hndl))

proc mapFrameBuffer*[T](fb: FrameBuffer; channel: OSPFrameBufferChannel): ptr UncheckedArray[T] = 
  cast[ptr UncheckedArray[T]](ospMapFrameBuffer(cast[OSPFrameBuffer](fb.hndl), 
                                                channel))


proc unmapFrameBuffer*[T](mapped: ptr UncheckedArray[T]; fb: FrameBuffer) = 
  ospUnmapFrameBuffer(mapped, cast[OSPFrameBuffer](fb.hndl))
