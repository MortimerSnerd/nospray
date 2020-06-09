# nospray - Nim bindings for Intel OSPRay ray tracing library v2.1.0

Work in progress, this is not complete in any way.  The high level API
only has enough functions implemented to port `ospTutorial.c` at the 
moment.

## Jun 8, 2020
There may be a bug in how the handles are being used, in a test
project, I've had some instances where things released that 
should have been retained, which leads OSPRAY to enigmatically
crash.  It may also just be me using one of the API functions
incorrectly, as I haven't spotted anything incorrect when I 
turn on destroy and sink tracing.

## Notes
1) `ospray_raw` is module that exposes the raw C API.  The only noticable difference 
   is that the handle types are arranged so a OSPHandle can match any type
   of handle, but the rest are their own types.  So it can catch type errors
   from passing the wrong handle.  The

2) `ospray` is the skeletal wrapped API for Nim, where the objects
   are released at the end of the lifetime of the handle objects.
   Functions whose name or parameters vary based on the passed in types
   have been simplified by Nim's type overloading. (ie, instead of 
   `ospSetFloat(someObj, "paramname", 1.3f)`, you can use 
   `someObj.set("paramname", 1.3f)`.  This also goes for some functions
   where you have to pass in a data type enum.  
   (ie: `ospSetObjectAsData(world, "instance", OSPDataType.OSP_INSTANCE, instance)`
    vs. `world.setObjectAsData("instance", instance)`.

3) For `ospray`, the library initialization is scoped to the `ospray.Library`
   object which you get when you call `ospray.init()`. This object will call 
   `ospShutdown` when it is destroyed. I wasn't 
   entirely happy with this, but it prevents problems in code where 
   if you call `ospShutdown()` in a function that also has active scoped
   handles, your shutdown call will happen before the destructors are called,
   giving unpleasant problems.  I think I don't see this as much in C++, because
   you can scope a var to a code block to work around these sorts of things, 
   but with the current arc implementation in Nim, the destruction happens
   at function exit, regardless of any explicit blocks you've created.
  
## Wrapping notes.

These are wrapped so you can apply a diff to the C headers, and then just
get a correct raw wrapper from running `c2nim` on the headers. 

To generate the `ospray_raw.nim`, `OSPEnums.nim` and `ospray_util_raw.nim` files, 
take the corrosponding C header files from the OSPRay source distribution, 
and apply the ospray-2.1.0-c2nim.patch file.  And then run c2nim on each 
header.

Right now, c2nim makes the calling convention for function pointer
declarations to be the standard calling convention? You do need to make a manual 
edit to `ospray.nim` to change the function call declaration decls to be 
`{.cdecl.}` to fix this.

After that copy the results to the source, adding the `_raw` suffix to the 
module names. 
