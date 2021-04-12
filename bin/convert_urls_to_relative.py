#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Transforms all absolute links in rendered HTML files produced by jekyll into
relative links compatible to browsing rendered lessons without a HTTP server.
"""

import sys
import os
try:
    import lxml.html as html
except ImportError:
    print('Unable to import lxml.html module: please install lxml', file=sys.stderr)
    sys.exit(1)

from glob import glob


# tag: url attribute
TAGS = {
    "meta": "content",  # we only match 'content' starting with '/'
    "link": "href",
    "a": "href",
    "img": "src",
    "script": "src",
}


def iter_html(builddir):
    """Iterate all html files in the build directory"""
    for filename in glob(os.path.join(builddir, "**/*.html"), recursive=True):
        yield filename


def main(builddir="."):
    for filename in iter_html(builddir):
        et = html.parse(filename)

        for tag in et.iter():
            try:
                attrib = TAGS[tag.tag]
            except KeyError:
                continue

            # Not all tags have the attribute we are looking for
            if attrib in tag.attrib:
                path = tag.attrib[attrib]

                # Should match cases when site.baseurl = /
                if path.startswith("/"):
                    path = builddir + path

                    # When path is missing a filename, assume index.html
                    # as would be the case by a HTTP server
                    if path.endswith("/"):
                        path += "index.html"

                    # if we don't find the file something went wrong
                    # TODO: Should this be fatal?
                    if not os.path.isfile(path):
                        print(
                            "WARNING: attribute ", attrib,
                            " in tag ", tag.tag,
                            " and line number ", tag.sourceline,
                            " of file ", filename,
                            " references a missing file ", path, "",
                            sep="'")

                    new_path = os.path.relpath(path, os.path.dirname(filename))

                    tag.attrib[attrib] = new_path

        # NOTE: This overwrites the original files
        et.write(filename, pretty_print=True)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Argument missing, need path to built website")
        sys.exit(1)
    main(sys.argv[1])
