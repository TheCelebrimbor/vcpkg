vcpkg_fail_port_install(ON_TARGET "uwp")

if(VCPKG_TARGET_IS_WINDOWS)
    # Building python bindings is currently broken on Windows
    if("python" IN_LIST FEATURES)
        message(FATAL_ERROR "The python feature is currently broken on Windows")
    endif()
    if(VCPKG_CRT_LINKAGE STREQUAL "static")
        set(_static_runtime ON)
    endif()
endif()

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        deprfun     deprecated-functions
        examples    build_examples
        iconv       iconv
        python      python-bindings
        test        build_tests
        tools       build_tools
)

# Note: the python feature currently requires `python3-dev` and `python3-setuptools` installed on the system
if("python" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PYTHON3)
    get_filename_component(PYTHON3_PATH ${PYTHON3} DIRECTORY)
    vcpkg_add_to_path(${PYTHON3_PATH})

    file(GLOB BOOST_PYTHON_LIB "${CURRENT_INSTALLED_DIR}/lib/*boost_python*")
    string(REGEX REPLACE ".*(python)([0-9])([0-9]+).*" "\\1\\2\\3" _boost-python-module-name "${BOOST_PYTHON_LIB}")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arvidn/libtorrent
    REF 7d317830e020230524b3ba9f84ce039919ce27b8 # v2.0.4
    SHA512 9534d775ba0b7befccc00cc279932c4f6f4eae70a6bc4caee6096ac93921c7ad38f4939289afafb5398b2ae4154a372bee0ba633939952335afceba91cce7520
    HEAD_REF RC_1_2
)

vcpkg_download_distfile(ARCHIVE1
    URLS "https://github.com/arvidn/try_signal/archive/refs/heads/master.zip"
    FILENAME "try_signal_master.zip"
    SHA512 c01d81464486f70f97a4318e6c98ad786f36f652f01c819b583b5f8e2322d1c3b41389f92f691c85e5c40561d15f0b3acb12a835ef028e533183e7596de38d6c
)
vcpkg_extract_source_archive(${ARCHIVE1} ${SOURCE_PATH}/deps)
file(REMOVE_RECURSE ${SOURCE_PATH}/deps/try_signal)
file(RENAME ${SOURCE_PATH}/deps/try_signal-master ${SOURCE_PATH}/deps/try_signal)

vcpkg_download_distfile(ARCHIVE2
    URLS "https://github.com/paullouisageneau/boost-asio-gnutls/archive/refs/heads/master.zip"
    FILENAME "asio_gnutls_master.zip"
    SHA512 49245f7958c1f1fe27433d06b02f3236c067e82e010e4a703dc56820c61c0e3792b5c3904f957e3a5790fa31805a8c6a525eaf00e3983ffc4d29b787fc33005e
)
vcpkg_extract_source_archive(${ARCHIVE2} ${SOURCE_PATH}/deps)
file(REMOVE_RECURSE ${SOURCE_PATH}/deps/asio-gnutls)
file(RENAME ${SOURCE_PATH}/deps/boost-asio-gnutls-master ${SOURCE_PATH}/deps/asio-gnutls)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -Dboost-python-module-name=${_boost-python-module-name}
        -Dstatic_runtime=${_static_runtime}
        -DPython3_USE_STATIC_LIBS=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/LibtorrentRasterbar TARGET_PATH share/LibtorrentRasterbar)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# Do not duplicate include files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share ${CURRENT_PACKAGES_DIR}/share/cmake)
