#
# This file is the bahnappcpp recipe.
#

SUMMARY = "Simple bahnappcpp application"
SECTION = "PETALINUX/apps"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:prepend = "${THISDIR}/files:"

SRC_URI += " \
    file://CMakeLists.txt \
    file://include/handling_vbb.h \
    file://scr/main.cpp \
    file://scr/handling_vbb.cpp \
"

S = "${WORKDIR}"

inherit pkgconfig cmake

DEPENDS += "virtual/libc curl rapidjson"

###### DEBUG

DEBUG_FLAGS = "-g3 -O0"

# Specifies to build packages with debugging information
DEBUG_BUILD = "1"

# Do not remove debug symbols
INHIBIT_PACKAGE_STRIP = "1"

# OPTIONAL: Do not split debug symbols in a separate file
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"

###### DEBUG

# Konfiguration für die App
APP_NAME = "bahnappcpp-dbg"
APP_INSTALL = "1"

FILES_${APP_NAME} += "${bindir}/*"

#do_install() {
#    install -d ${D}${bindir}
#    install -m 0755 ps_cpp ${D}${bindir}
#}

# Alternativ: in cmakelists.txt: install(TARGETS ps_cpp DESTINATION bin) 

