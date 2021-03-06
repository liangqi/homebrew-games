class Ppsspp < Formula
  homepage "http://ppsspp.org/"
  url "https://github.com/hrydgard/ppsspp.git", :tag => "v0.9.9.1"
  head "https://github.com/hrydgard/ppsspp.git"

  bottle do
    root_url "https://downloads.sf.net/project/machomebrew/Bottles/games"
    cellar :any
    sha1 "6f2e7663ce17d2e8c94e1845527bb20743cd5140" => :yosemite
    sha1 "d242a87db02e65c2bef5f0ef974e2daeeacafdf1" => :mavericks
    sha1 "bf7618abae1db1aa500d4eee524f1a8655bb24c4" => :mountain_lion
  end

  depends_on "cmake" => :build
  depends_on "sdl"
  depends_on "ffmpeg"

  # Fix audio playback with system-wide FFmpeg
  # https://github.com/hrydgard/ppsspp/issues/5772
  patch do
    url "https://abf.rosalinux.ru/import/ppsspp/raw/rosa2014.1/ppsspp-0.9.9.1-ffmpeg2.2.patch"
    sha1 "cfd3884471c5b1024a60b656f079f31100415571"
  end

  def install
    # Make sure CMake grabs version info
    ENV["GIT_DIR"] = cached_download/".git"

    # Build type will be set to "Release" by default
    args = std_cmake_args
    args.delete "-DCMAKE_BUILD_TYPE=None"

    # Use brewed FFmpeg rather than precompiled binaries in the repo
    ffmpeg = Formula["ffmpeg"]
    args << "-DFFMPEG_BUILDDIR=#{ffmpeg.opt_prefix}"
    inreplace "CMakeLists.txt" do |s|
      s.gsub! "STATIC IMPORTED", "SHARED IMPORTED"
      s.gsub! /\${FFMPEG_BUILDDIR}\/lib.*\/(lib.*)\.a/, "${FFMPEG_BUILDDIR}/lib/\\1.dylib"
    end

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      prefix.install "PPSSPPSDL.app"
      bin.write_exec_script "#{prefix}/PPSSPPSDL.app/Contents/MacOS/PPSSPPSDL"
    end
  end
end
