# Hammer

CLI tool to help building binaries using Heroku's anvil.

## Installation

Install it:

    $ gem install hammer

## Usage

This example will show you how to statically compile libyaml on heroku using hammer. First, we need to create a skeleton build script.

    $ hammer new libyaml
    Creating hammer skeleton...
    libyaml/
    libyaml/build
    
The template app should look something ilke this:

    $ cd libyaml/
    $ cat build
    #!/bin/sh
    
    workspace_dir=$1
    output_dir=$2
    
    curl -O http://example.com/foo.tgz -s -o - | tar zxf
    
    cd foo
    ./configure --prefix=$output_dir
    make
    make install

The build script is passed two arguments. The first is the workspace directory. This is where you can build your package in a clean folder. You can download the source code and build it in this directory. We'll automatically cd here, so you start in this directory. `$HOME` is also set to this directory.

The second argument is the output directory. This is the directory that anvil will package up and generate a tarball for. Make sure to only inclued things you want in the final tarball. You usually want to set the `--prefix` argument to this value or somewhere in this directory.

We can change the build script to build libyaml. We'll be using the `$VERSION` env var to allow us to pick the version.

    $ cat build
    #!/bin/sh
    
    workspace_dir=$1
    output_dir=$2
    
    curl http://pyyaml.org/download/libyaml/yaml-$VERSION.tar.gz -s -o - | tar zxf -
    
    cd yaml-$VERSION
    env CFLAGS=-fPIC ./configure --enable-static --disable-shared --prefix=$output_dir
    make
    make install

We can now build libyaml. The latest version as of this writing is 0.1.4. We can use the `--env` option to pass a list of env vars to the build script we wrote, like `--env KEY1:VALUE1 KEY2:VALUE2`. We also copy the contents of the current working directory (locally where the command is run) into `/tmp` on Heroku.

    $ hammer build --env VERSION:0.1.4
    Checking for buildpack files to sync... done, 3 files needed
    Uploading: 100.0%
    Checking for app files to sync... done, 0 files needed
    Launching build process... done
    Preparing app for compilation... done
    Fetching buildpack... done
    Detecting buildpack... done, hammer-binary
    Fetching cache... empty
    Compiling app...
    checking for a BSD-compatible install... /usr/bin/install -c
    ...
    Packaging the following files/dirs:
    include
    lib
    Writing .profile.d/buildpack.sh... done
    Putting cache... done
    Creating slug... done
    Uploading slug... done
    Success, slug is https://api.anvilworks.org/slugs/7867fa81-5967-11e2-9db4-7b154f4e3a6a.tgz
    $ ls
    build builds
    $ ls builds/
    7867fa81-5967-11e2-9db4-7b154f4e3a6a.tgz

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
