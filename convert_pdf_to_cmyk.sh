#!/bin/sh

# (c)2016 Brian Sidebotham <brian.sidebotham@gmail.com>
# Author: Brian Sidebotham <brian.sidebotham@gmail.com>

# A script to convert a PDF to CMYK colourspace so it can be used by printing companies for fliers.

scriptdir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

if [ $# -lt 1 ]; then
    echo "usage: ${0} PDF_FILE" 2>&1
    exit 1
fi

pdf=${1}

which gs > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "ERORR: Require Ghostscript to do the colourspace conversion (gs)" >&2
    exit 1
fi

# Use ghostscript to do the work.
gs -o "${pdf}.cmyk.pdf" \
    -sDEVICE=pdfwrite \
    -dseCIRColor \
    -sProcessColorModel=DeviceCMYK \
    -sColorConversionStrategy=CMYK \
    -sColorConversionStrategyForImages=CMYK \
    -dPDFSETTINGS=/prepress \
    -dDownsampleColorImages=false \
    "${pdf}"
