class ModsecurityAT2 < Formula
  desc "Modsecurity v2"
  homepage "https://github.com/owasp-modsecurity/ModSecurity"
  url "https://github.com/owasp-modsecurity/ModSecurity/releases/download/v2.9.13/modsecurity-v2.9.13.tar.gz"
  sha256 "7fa925289a2e0cb5415ba82626cf0495607a4ab09f78831ace5bbd8d81496cc2"
  license "Apache-2.0"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => :build
  depends_on "pcre2"
  depends_on "httpd"

  uses_from_macos "curl", since: :monterey
  uses_from_macos "libxml2"

  patch :DATA # reads from __END__ at bottom of file

  def install
    system "autoreconf", "--force", "--install", "--verbose"

    libxml2 = OS.mac? ? "#{MacOS.sdk_path_if_needed}/usr" : Formula["libxml2"].opt_prefix

    args = [
      "--disable-silent-rules",
      "--with-libxml=#{libxml2}",
      "--with-pcre2=#{Formula["pcre2"].opt_prefix}",
      "--with-apxs=#{HOMEBREW_PREFIX}/bin/apxs",
      "--with-apr=#{HOMEBREW_PREFIX}/opt/apr/bin/apr-1-config",
      "--with-apu=#{HOMEBREW_PREFIX}/opt/apr-util/bin/apu-1-config",
    ]

    system "./configure", *args, *std_configure_args

    system "make", "install"
  end

  def caveats
    <<~EOS
      To use with Apache2 httpd add:
      `LoadModule security2_module #{HOMEBREW_PREFIX}/opt/modsecurity@2/lib/mod_security2.so`
      to your httpd.conf.
    EOS
  end

  test do
    (testpath/"httpd.conf").write <<~C
        LoadModule mpm_prefork_module lib/httpd/modules/mod_mpm_prefork.so
        ErrorLog #{testpath}/error_log
        LoadModule security2_module /opt/homebrew/opt/modsecurity@2/lib/mod_security2.so
        SecAuditEngine RelevantOnly
    C

    system "#{HOMEBREW_PREFIX}/bin/httpd", "-t", "-f", "#{testpath}/httpd.conf"
  end
end

__END__
diff -ru a/apache2/Makefile.am b/apache2/Makefile.am
--- a/apache2/Makefile.am	2026-04-28 20:02:31
+++ b/apache2/Makefile.am	2026-05-13 09:18:42
@@ -181,7 +181,6 @@
 	for m in $(pkglib_LTLIBRARIES); do \
 	  base=`echo $$m | sed 's/\..*//'`; \
 	  rm -f $(DESTDIR)$(pkglibdir)/$$base.*a; \
-	  install -D -m444 $(DESTDIR)$(pkglibdir)/$$base.so $(DESTDIR)$(APXS_MODULES)/$$base.so; \
 	done
 else
 install-exec-hook: $(pkglib_LTLIBRARIES)
@@ -189,6 +188,5 @@
 	for m in $(pkglib_LTLIBRARIES); do \
 	  base=`echo $$m | sed 's/\..*//'`; \
 	  rm -f $(DESTDIR)$(pkglibdir)/$$base.*a; \
-	  cp -p $(DESTDIR)$(pkglibdir)/$$base.so $(DESTDIR)$(APXS_MODULES); \
 	done
 endif
diff -ru modsecurity-v2.9.13 a/apache2/Makefile.in modsecurity-v2.9.13 b/apache2/Makefile.in
--- a/apache2/Makefile.in	2026-04-28 20:03:03
+++ b/apache2/Makefile.in	2026-05-13 09:18:35
@@ -1323,14 +1323,12 @@
 @LINUX_TRUE@	for m in $(pkglib_LTLIBRARIES); do \
 @LINUX_TRUE@	  base=`echo $$m | sed 's/\..*//'`; \
 @LINUX_TRUE@	  rm -f $(DESTDIR)$(pkglibdir)/$$base.*a; \
-@LINUX_TRUE@	  install -D -m444 $(DESTDIR)$(pkglibdir)/$$base.so $(DESTDIR)$(APXS_MODULES)/$$base.so; \
 @LINUX_TRUE@	done
 @LINUX_FALSE@install-exec-hook: $(pkglib_LTLIBRARIES)
 @LINUX_FALSE@	@echo "Removing unused static libraries..."; \
 @LINUX_FALSE@	for m in $(pkglib_LTLIBRARIES); do \
 @LINUX_FALSE@	  base=`echo $$m | sed 's/\..*//'`; \
 @LINUX_FALSE@	  rm -f $(DESTDIR)$(pkglibdir)/$$base.*a; \
-@LINUX_FALSE@	  cp -p $(DESTDIR)$(pkglibdir)/$$base.so $(DESTDIR)$(APXS_MODULES); \
 @LINUX_FALSE@	done
 
 # Tell versions [3.59,3.63) of GNU make to not export all variables.
