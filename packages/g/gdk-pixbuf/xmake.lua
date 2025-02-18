package("gdk-pixbuf")

    set_homepage("https://docs.gtk.org/gdk-pixbuf/")
    set_description("GdkPixbuf is a library that loads image data in various formats and stores it as linear buffers in memory. The buffers can then be scaled, composited, modified, saved, or rendered.")
    set_license("LGPL-2.1")

    add_urls("https://download.gnome.org/sources/gdk-pixbuf/$(version).tar.xz", {alias = "home", version = function (version)
        return format("%d.%d/gdk-pixbuf-%s", version:major(), version:minor(), version)
    end})
    add_urls("https://gitlab.gnome.org/GNOME/gdk-pixbuf/-/archive/$(version)/gdk-pixbuf-$(version).tar.gz",
             "https://gitlab.gnome.org/GNOME/gdk-pixbuf.git")
    add_versions("home:2.42.10", "ee9b6c75d13ba096907a2e3c6b27b61bcd17f5c7ebeab5a5b439d2f2e39fe44b")
    add_versions("home:2.42.6", "c4a6b75b7ed8f58ca48da830b9fa00ed96d668d3ab4b1f723dcf902f78bde77f")

    add_patches("2.42.6", path.join(os.scriptdir(), "patches", "2.42.6", "macosx.patch"), "ad2705a5a9aa4b90fb4588bb567e95f5d82fccb6a5d463cd07462180e2e418eb")

    add_includedirs("include", "include/gdk-pixbuf-2.0")

    add_deps("meson", "ninja")
    add_deps("libpng", "libjpeg-turbo", "libtiff", "glib", "pcre2")
    if is_plat("windows") then
        add_syslinks("iphlpapi", "dnsapi")
        add_deps("pkgconf", "libintl")
    elseif is_plat("macosx") then
        add_frameworks("Foundation", "CoreFoundation", "AppKit")
        add_extsources("brew::gdk-pixbuf")
        add_syslinks("resolv")
    elseif is_plat("linux") then
        add_extsources("pacman::gdk-pixbuf2")
    end

    on_install("windows", "macosx", "linux", function (package)
        io.gsub("meson.build", "subdir%('tests'%)", "")
        io.gsub("meson.build", "subdir%('fuzzing'%)", "")
        io.gsub("meson.build", "subdir%('docs'%)", "")

        local configs = {"-Dman=false",
                         "-Ddocs=false",
                         "-Dgtk_doc=false",
                         "-Dpng=enabled",
                         "-Dtiff=enabled",
                         "-Djpeg=enabled",
                         "-Dnative_windows_loaders=false",
                         "-Dbuiltin_loaders=all",
                         "-Dgio_sniffing=false",
                         "-Drelocatable=true",
                         "-Dintrospection=disabled",
                         "-Dtests=false",
                         "-Dinstalled_tests=false"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs, {packagedeps = {"libjpeg-turbo", "libpng", "libtiff", "glib", "pcre2", "libintl"}})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gdk_pixbuf_get_type", {includes = "gdk-pixbuf/gdk-pixbuf.h"}))
    end)
