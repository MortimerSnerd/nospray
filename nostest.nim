# A pretty straight conversion of ospTutorial.c
import 
  ospray, ospray_util, strformat

proc writePPM(fileName: string; size_x, size_y: int; pixels: ptr uint32) = 
  let fh = open(fileName, fmWrite)

  try:
    write(fh, &"P6\n{size_x} {size_y}\n255\n")
    var outrow = newSeq[byte](3 * size_x)

    for y in 0..<size_y:
      let inrow = cast[ptr UncheckedArray[byte]](cast[ptr byte](cast[int](pixels) + (size_y - 1 - y) * size_x * 4))

      for x in 0..<size_x:
        outrow[3*x + 0] = inrow[4*x + 0]
        outrow[3*x + 1] = inrow[4*x + 1]
        outrow[3*x + 2] = inrow[4*x + 2]

      discard writeBuffer(fh, addr outrow[0], len(outrow))

    write(fh, "\n")

  finally:
    close(fh)


proc go() = 
  const
   imgSize_x = 1024
   imgSize_y = 768

  var cam_pos = [0.0f, 0.0f, 0.0f]
  var cam_up = [0.0f, 1.0f, 0.0f]
  var cam_view = [0.1f, 0.0f, 1.0f]
  var vertex = [
    -1.0f, 
    -1.0f,
    3.0f,
    -1.0f,
    1.0f,
    3.0f,
    1.0f,
    -1.0f,
    3.0f,
    0.1f,
    0.1f,
    0.3f
  ]
  var color = [
    0.9f,
    0.5f,
    0.5f,
    1.0f,
    0.8f,
    0.8f,
    0.8f,
    1.0f,
    0.8f,
    0.8f,
    0.8f,
    1.0f,
    0.5f,
    0.9f,
    0.5f,
    1.0f
  ]
  var index = [0.int32, 1, 2, 1, 2, 3]

  let init_error = ospInit(nil, nil)

  assert init_error == OSP_NO_ERROR

  echo "done!"
  echo "setting up camera..."

  let camera = ospNewCamera("perspective")
  ospSetFloat(camera, "aspect", imgSize_x.float32 / imgSize_y.float32)
  ospSetParam(camera, "position", OSP_VEC3F, addr cam_pos[0])
  ospSetParam(camera, "direction", OSP_VEC3F, addr cam_view[0])
  ospSetParam(camera, "up", OSP_VEC3F, addr cam_up[0])
  ospCommit(camera)

  echo "done!"
  echo "setting up scene..."

  let mesh = ospNewGeometry("mesh")
  let data = ospNewSharedData1D(addr vertex[0], OSP_VEC3F, 4)
  ospCommit(data)
  ospSetObject(mesh, "vertex.position", data)
  ospRelease(data)

  let datac = ospNewSharedData1D(addr color[0], OSP_VEC4F, 4)
  ospCommit(datac)
  ospSetObject(mesh, "vertex.color", datac)
  ospRelease(datac)

  let datai = ospNewSharedData1D(addr index[0], OSP_VEC3UI, 2)
  ospCommit(datai)
  ospSetObject(mesh, "index", datai)
  ospRelease(datai)

  ospCommit(mesh)

  let mat = ospNewMaterial("pathtracer", "obj")
  ospCommit(mat)

  # put the mesh into a model
  let model = ospNewGeometricModel(mesh)
  ospSetObject(model, "material", mat)
  ospCommit(model)
  ospRelease(mesh)
  ospRelease(mat)

  # put the model into a group 
  let group = ospNewGroup()
  ospSetObjectAsData(group, "geometry", OSPDataType.OSP_GEOMETRIC_MODEL, model)
  ospCommit(group)
  ospRelease(model)

  # put the group into an instance (give the group a world transform)
  let instance = ospNewInstance(group)
  echo "ha"
  ospCommit(instance)
  echo "shit"
  ospRelease(group)

  # Put the instance in the world.
  let world = ospNewWorld()
  ospSetObjectAsData(world, "instance", OSPDataType.OSP_INSTANCE, instance)
  ospRelease(instance)

  # Create and setup light for Ambient Occlusion
  let light = ospNewLight("ambient")
  ospCommit(light)
  ospSetObjectAsData(world, "light", OSPDataType.OSP_LIGHT, light)
  ospRelease(light)

  ospCommit(world)

  echo "done!"

  # print out world bounds
  let worldBounds = ospGetBounds(world)
  echo &"world bounds {worldBounds}"

  echo "setting up the renderer"

  let renderer = ospNewRenderer("pathtracer")

  ospSetFloat(renderer, "backgroundColor", 1.0f)
  ospCommit(renderer)

  let framebuffer = ospNewFrameBuffer(imgSize_x, imgSize_y, 
                                      OSP_FB_SRGBA, 
                                      OSP_FB_COLOR or OSP_FB_ACCUM)
  ospResetAccumulation(framebuffer)

  echo "rendering initial frame to firstFrame.ppm"

  discard ospRenderFrameBlocking(framebuffer, renderer, camera, world)

  let fb = cast[ptr uint32](ospMapFrameBuffer(framebuffer, OSP_FB_COLOR))
  writePPM("firstFrame.ppm", imgSize_x, imgSize_y, fb)
  ospUnmapFrameBuffer(fb, framebuffer)

  echo "done"
  echo "rendering 10 accumulated frames to accumulatedFrame.ppm..."

  for i in 1..10:
    discard ospRenderFrameBlocking(framebuffer, renderer, camera, world)

  let fb2 = cast[ptr uint32](ospMapFrameBuffer(framebuffer, OSP_FB_COLOR))
  writePPM("accumulatedFrame.ppm", imgSize_x, imgSize_y, fb2)
  ospUnmapFrameBuffer(fb2, framebuffer)

  # final cleanups
  ospRelease(renderer)
  ospRelease(camera)
  ospRelease(framebuffer)
  ospRelease(world)

  echo "done!"
  ospShutdown()

  #TODO really need to set up handle objects, so the ospRelease can be
  #     done at object destruction time, to get rid of all of the ospRelease
  #     noise.  And the silent aborts if you make a mistake and release something
  #     one too many times.


go()
