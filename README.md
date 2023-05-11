<div align="right">
<a href="https://mysofa.audio/">
	<img alt="Symonics MySofa" width="320px" src="https://raw.githubusercontent.com/hoene/libmysofa/master/symonics-mysofa.png"/>
</a>
</div

#

# libmysofa

## Introduction
This is a simple set of C functions to read AES SOFA files, if they contain HRTFs
stored according to the AES69-2015 standard [http://www.aes.org/publications/standards/search.cfm?docID=99].

## Badges

<div align="center">
<a href="https://travis-ci.com/hoene/libmysofa">
<img alt="Travis CI Status" src="https://travis-ci.com/hoene/libmysofa.svg?branch=main"/>
</a>
<a href="https://ci.appveyor.com/project/hoene/libmysofa-s142k">
<img alt="AppVeyor Status" src="https://ci.appveyor.com/api/projects/status/mk86lx4ux2jn9tpo/branch/main?svg=true"/>
</a>
<a href="https://scan.coverity.com/projects/hoene-libmysofa">
<img alt="Coverity Scan Build Status" src="https://scan.coverity.com/projects/13030/badge.svg"/>
</a>
<a href="https://codecov.io/gh/hoene/libmysofa">
  <img src="https://codecov.io/gh/hoene/libmysofa/branch/master/graph/badge.svg" />
</a>
<a href="https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=GUN8R6NUQCS3C&source=url">
<img src="https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif" alt="Donate with PayPal button" />
</a>
</div>

## Compiling for wasm

I've found `make` to be more finnicky / less stable than using `ninja` for the actual build step. 

Getting a working wasm binary is a little bit complicated; as intermediate steps, you'll also need to download the source for and then compile to wasm `cunit` and `zlib`, and be able to point to the `math.h` header inside of `emsdk`. (You'll need `emscripten` locally on your system to do this.)

I've hardcoded filepaths to these external dependencies as I configured them on my own machine; they won't work out of the box if you clone this repo, but you can use my edits as starting points for your own custom cmake configuration. 

Once you finally have all the relevant external dependencies compiled and on hand, here's how you build mysofa to wasm using ninja: 

1. Create a directory immediately within root named `build`, or something similar. 

2. Within build, run some variation of `emcmake cmake .. -G Ninja`. For the purposes of debugging, lately I've been using: `emcmake cmake -DCMAKE_BUILD_TYPE=Debug -DVDEBUG=1 .. -G Ninja`

3. To perform the actual build, run `ninja` in the same directory

4. `cd` into the newly-created `src` directory. 

5. Run some variation of: `emcc -O0 --profiling libmysofa.a /Users/arcop/Downloads/zlib-1.2.13/build/libz.a  -o mysofa.html -sEXPORTED_FUNCTIONS=_mysofa_open,_mysofa_open_data  -sEXPORTED_RUNTIME_METHODS=ccall,cwrap`

Changing `-O0` to `-O2` will optimize the build, but in practice I've found it breaks things like being able to print error messages via `fprintf` from compiled C code to the browser console at runtime. `--profiling` is also optional; I think it has to do with debug symbols. For my own testing I've only exported the functions `mysofa_open` and `my_sofa_open_data`, but there are many more public-facing functions the `mysofa` API makes available; add them as you need them as command arguments. 

Also notice that I've needed to explicitly include a path to my self-compiled wasm version of `zlib`; final compilation to wasm will fail otherwise. 

6. To test the wasm binary locally in your browser, the easiest way is to run `python -m http.server` from the project root; navigate to `http://localhost:{port}/build/src/mysofa.html`.

7. In the browser's debug console, here's the test program I've been running: 

```
const res = await fetch('/share/dtf_nh2.sofa');

const dtfBuf = await res.arrayBuffer();
const dtfData = new Uint8Array(dtfBuf);

const filterLength = new Int32Array(Module.asm.memory.buffer, 0, 1);
const error = new Int32Array(Module.asm.memory.buffer, 4, 1);

const pDtfData = new Uint8Array(Module.asm.memory.buffer, 8, dtfData.byteLength); 
pDtfData.set(dtfData);

const pHrtf = _mysofa_open_data(pDtfData.byteOffset, pDtfData.byteLength, 48000, filterLength.byteOffset, error.byteOffset); 

console.log(error[0]); 
```

You'll see that `mysofa` runs without crashing, but always outputs an error code of `10000`, which signals that the data it's attempting to read is in an invalid format. 

This is my current blocker; the library seems to compile and run fine, but loading in data is broken. 

Once data loads properly, the next step is in C++ to write a wrapper class around `mysofa`'s HRTF C struct, so that using `EMBIND` it will be possibly to query loaded HRTFs like regular JavaScript objects.  

I've done all of this on an M1 Macbook, but theoretically it should be just as doable on Linux, and maybe in Windows. 

Finally, I've uploaded the ninja-built wasm binaries as a release in this repo. 



## Compile

On Ubuntu, to install the required components, enter

> sudo apt install zlib1g-dev libcunit1-dev libcunit1-dev

Then, to compile enter following commands

> cd build

> cmake -DCMAKE_BUILD_TYPE=Debug ..

> make all test

If you need an Debian package, call

> cd build && cpack

To check for memory leaks and crazy pointers

> export ASAN_SYMBOLIZER_PATH=/usr/bin/llvm-symbolizer

> export ASAN_OPTIONS=symbolize=1

> cmake -DCMAKE_BUILD_TYPE=Debug -DADDRESS_SANITIZE=ON -DVDEBUG=1 ..

> make all test


## Usage

Libmysofa has a few main function calls.

To read a SOFA file call

```
#include <mysofa.h>

int filter_length;
int err;
struct MYSOFA_EASY *hrtf = NULL;

hrtf = mysofa_open("file.sofa", 48000, &filter_length, &err);
if(hrtf==NULL)
	return err;
```

This call will normalize your hrtf data upon opening. For non-normalized data, replace the call to mysofa_open by:

```
hrtf = mysofa_open_no_norm("file.sofa", 48000, &filter_length, &err);
```

Or for a complete control over neighbors search algorithm parameters:

```
bool norm = true; // bool, apply normalization upon import
float neighbor_angle_step = 5; // in degree, neighbor search angle step (common to azimuth and elevation)
float neighbor_radius_step = 0.01; // in meters, neighbor search radius step
hrtf = mysofa_open_advanced("file.sofa", 48000, &filter_length, &err, norm, neighbor_angle_step, neighbor_radius_step);
```

(The greater the neighbor_*_step, the faster the neighbors search. The algorithm will end up skipping true nearest neighbors if these values are set too high. To be define based on the will-be-imported sofa files grid step. Default mysofa_open method is usually fast enough for classical hrtf grids not to bother with the advanced one.)

Or, if you have loaded your HRTF file into memory already, call, for example
```
char buffer[9] = "TESTDATA";
int filter_length;
int err;
struct MYSOFA_EASY *hrtf = NULL;
hrtf = mysofa_open_data(buffer, 9, 48000, &filter_length, &err);
```

To free the HRTF structure, call:
```
mysofa_close(hrtf);
```

If you need HRTF filter for a given coordinate, just call
```
short leftIR[filter_length];
short rightIR[filter_length];
int leftDelay;          // unit is samples
int rightDelay;         // unit is samples

mysofa_getfilter_short(hrtf, x, y, z, leftIR, rightIR, &leftDelay, &rightDelay);
```
and then delay the audio signal by leftDelay and rightDelay samples and do a FIR filtering with leftIR and rightIR. Alternative, if you are using float values for the filtering, call
```
float leftIR[filter_length]; // [-1. till 1]
float rightIR[filter_length];
float leftDelay;          // unit is sec.
float rightDelay;         // unit is sec.

mysofa_getfilter_float(hrtf, x, y, z, leftIR, rightIR, &leftDelay, &rightDelay);
```

using ``mysofa_getfilter_float_nointerp`` instead of ``mysofa_getfilter_float`` (same arguments), you can bypass the linear interpolation applied by ``mysofa_getfilter_float`` (weighted sum of nearest neighbors filters coefficients), and get the exact filter stored in the sofa file nearest to the [x,y,z] position requested.

If you have spherical coordinates but you need Cartesian coordinates, call
```
void mysofa_s2c(float values[3])
```
with phi (azimuth in degree, measured counterclockwise from the X axis), theta (elevation in degree,  measured up from the X-Y plane), and r (distance between listener and source) as parameters in the float array and x,y,z as response in the same array. Similar, call
```
void mysofa_c2s(float values[3])
```
The coordinate system is defined in the SOFA specification and is the same as in the SOFA file. Typically, the X axis vector (1 0 0) is the listening direction. The Y axis (0 1 0) is the left side of the listener and Z (0 0 1) is upwards.


Sometimes, you want to use multiple SOFA filters or if you have to open a SOFA file multiple times, you may use
```
hrtf1 = mysofa_open_cached("file.sofa", 48000, &filter_length, &err);
hrtf2 = mysofa_open_cached("file.sofa", 48000, &filter_length, &err);
hrtf3 = mysofa_open_cached("file.sofa", 8000, &filter_length, &err);
hrtf3 = mysofa_open_cached("file2.sofa", 8000, &filter_length, &err);
mysofa_close_cached(hrtf1);
mysofa_close_cached(hrtf2);
mysofa_close_cached(hrtf3);
mysofa_close_cached(hrtf4);
...
mysofa_cache_release_all();
```
Then, all HRTFs having the same filename and sampling rate are stored only once in memory. If your program is using several threads, you must use appropriate synchronisation mechanisms so only a single thread can access the mysofa_open_cached and mysofa_close_cached functions at a given time.

## OS support

Libmysofa compiles for Linux operating systems, OSX and Windows. By default, each commit is compiled with Travis CI under Ubuntu 14.04 and OSX 7.3 and with AppVeyor for Windows Visual Studio 2015 on a x64 system. In addition, FFmpeg is compiling libmysofa with MinGW under Windows using their own build system.


## References

 * Christian Hoene and Piotr Majdak, "HDF5 under the SOFA – A 3D audio case in HDF5 on embedded and mobile devices", HDF Blog, https://www.hdfgroup.org/2017/04/hdf5-under-the-sofa-hdf5-on-embedded-and-mobile-devices/, April 26, 2017.
 * Christian Hoene, Isabel C. Patiño Mejía, Alexandru Cacerovschi, "MySofa: Design Your Personal HRTF", Audio Engineering Society
 Convention Paper 9764, Presented at the 142nd Convention, May 2017, Berlin, Germany, http://www.aes.org/e-lib/browse.cfm?elib=18640

## Disclaimer

The SOFA files are from https://www.sofaconventions.org/, Piotr Majdak <piotr@majdak.com>. The K-D tree algorithm is by John Tsiombikas <nuclear@member.fsf.org>. The resampler is by Jean-Marc Valin. The remaining source code is by Christian Hoene <christian.hoene@symonics.com>, <a href="https://symonics.com/">Symonics GmbH</a>, and available under BSD-3-Clause license. This work has been funded by German <a href="https://www.bmbf.de">Federal Ministry of Education and Research</a>, funding code 01IS14027A.

