#!/usr/bin/env python3

from json import load
from typing import List
from subprocess import run, CalledProcessError
from os.path import abspath
from os import environ


def sysprep(disk_images: List[str]):
    args = ["virt-sysprep"]
    for image in disk_images:
        args.append("-a")
        args.append(abspath(image))
    try:
        run(args,
            check=True,
            env={
                "LIBGUESTFS_MEMSIZE": "1024",
                "LIBGUESTFS_BACKEND": "direct",
            })
    except CalledProcessError:
        exit(1)


if __name__ == "__main__":
    BUILD_NAME = environ["PACKER_BUILD_NAME"]
    BUILD_TYPE = environ["PACKER_BUILDER_TYPE"]
    RUN_UUID = environ["PACKER_RUN_UUID"]

    with open(abspath('manifest.json')) as fd:
        manifest = load(fd)

    for build in [
            build for build in manifest["builds"]
            if build["packer_run_uuid"] == RUN_UUID and build["name"] == BUILD_NAME and build["builder_type"] == BUILD_TYPE
        ]:
        disk_images = [file["name"] for file in build["files"]]

        print(f"running sysprep on build: {build['name']}")
        sysprep(disk_images)
