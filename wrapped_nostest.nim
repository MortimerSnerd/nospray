# A pretty straight conversion of ospTutorial.c, with with the Nim wrapped
# api.
import 
  ospray, ospray_util_raw, strformat

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

  let (init_error, remaining_args, lib) = ospray.init(["--osp:debug", "--osp:verbose"])

  echo "Got back " & $remaining_args
  assert init_error == OSP_NO_ERROR
 
  echo "done!"
  echo "setting up camera..."
 
  let camera = newCamera("perspective")
  camera.set("aspect", imgSize_x.float32 / imgSize_y.float32)
  camera.setVec3f("position",  addr cam_pos[0])
  camera.setVec3f("direction", addr cam_view[0])
  camera.setVec3f("up", addr cam_up[0])
  commit(camera)
  echo "done!"
 
  let mesh = newGeometry("mesh")
  let data = newSharedData1D(addr vertex[0], OSP_VEC3F, 4)
  commit(data)
  mesh.set("vertex.position", data)

  let datac = newSharedData1D(addr color[0], OSP_VEC4F, 4)
  commit(datac)
  mesh.set("vertex.color", datac)
  
  let datai = newSharedData1D(addr index[0], OSP_VEC3UI, 2)
  commit(datai)
  mesh.set("index", datai)

  commit(mesh)

  let mat = newMaterial("pathtracer", "obj")
  commit(mat)
 
  # put the mesh into a model
  let model = newGeometricModel(mesh)
  model.set("material", mat)
  commit(model)

  # put the model into a group
  let group = newGroup()
  group.setObjectAsData("geometry", model)
  commit(group)

  # put the group into an instance (give the group a world transform)
  let instance = newInstance(group)
  commit(instance)

  # Put the instance in the world.
  let world = newWorld()

  world.setObjectAsData("instance", instance)

  # Create and setup light for Ambient Occlusion
  let light = newLight("ambient")
  commit(light)
  world.setObjectAsData("light", light)

  commit(world)
  echo "done!"
 
  # print out world bounds
  let worldBounds = getBounds(world)
  echo &"world bounds {worldBounds}"
 
  echo "setting up the renderer"
 
  let renderer = newRenderer("pathtracer")

  renderer.set("backgroundColor", 1.0f)
  commit(renderer)

 
  let framebuffer = newFrameBuffer(imgSize_x, imgSize_y,
                                   OSP_FB_SRGBA,
                                   OSP_FB_COLOR or OSP_FB_ACCUM)
  resetAccumulation(framebuffer)
 
  echo "rendering initial frame to firstFrame.ppm"
 
  let ft = renderFrameBlocking(framebuffer, renderer, camera, world)
  echo &"variance = {ft}"
 
  let fb = mapFrameBuffer[uint32](framebuffer, OSP_FB_COLOR)
  writePPM("firstFrame.ppm", imgSize_x, imgSize_y, fb)
  unmapFrameBuffer(fb, framebuffer)
 
  echo "done"
  echo "rendering 10 accumulated frames to accumulatedFrame.ppm..."
 
  for i in 1..10:
    discard renderFrameBlocking(framebuffer, renderer, camera, world)
 
  let fb2 = mapFrameBuffer[uint32](framebuffer, OSP_FB_COLOR)
  writePPM("accumulatedFrame.ppm", imgSize_x, imgSize_y, fb2)
  unmapFrameBuffer(fb2, framebuffer)
 

go()
