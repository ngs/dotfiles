#!/bin/sh

echo https://git.io/$(curl https://git.io/create -sd "url=$1")
