add_compile_options(-DLUA_CORE)

set(luametatex_sources
    source/luametatex.c
)

add_executable(luametatex ${luametatex_sources})

target_include_directories(luametatex PRIVATE
    source/.
    source/luacore/lua54/src
)

target_link_libraries(luametatex
    tex
    lua
    mp

    luarest
    luasocket
    luaoptional

    pplib
    miniz
)

target_link_libraries(luametatex
    ${CMAKE_DL_LIBS}
)

install(TARGETS luametatex
    EXPORT luametatex
    RUNTIME
        DESTINATION ${CMAKE_INSTALL_BINDIR}
        COMPONENT luametatex_runtime
)

if (luametatex_use_mimalloc)
    target_include_directories(luametatex PRIVATE
        source/libraries/mimalloc/include
    )
    target_link_libraries(luametatex
        mimalloc
    )
    if (LUAMETATEX_MINGW)
        target_link_libraries(luametatex --static)
        target_link_libraries(luametatex
            pthread
            psapi
            bcrypt
        )
    elseif (NOT MSVC)
        target_link_libraries(luametatex
            pthread
        )
    endif()
endif()

if (NOT MSVC)
    target_link_libraries(luametatex
        m
)
endif()

if (${CMAKE_HOST_SOLARIS})
    target_link_libraries(luametatex
        rt
        socket
        nsl
        resolv
)
endif()

if (DEFINED LMT_OPTIMIZE)
    # we strip anyway
elseif (CMAKE_HOST_SOLARIS)
    # no strip
elseif (CMAKE_C_COMPILER_ID MATCHES "GNU")
    add_custom_command(TARGET luametatex POST_BUILD COMMAND $<$<CONFIG:RELEASE>:${CMAKE_STRIP}> $<TARGET_FILE:luametatex>)
endif()
