# Homebrew tap to install modsecurity v2

Installs modsecurity version 2 for Apache2 httpd.

It does not install the module in httpd/modules/ so you should manually modify your httpd.conf to load the module using the full path.

## Usage

1. Install [homebrew](https://brew.sh).
2. Add this tap: `brew tap joostdekeijzer/modsecurity2`
3. Install modsecurity v2: `brew install modsecurity@2`
4. Add `LoadModule security2_module /opt/homebrew/opt/modsecurity@2/lib/mod_security2.so` to your Apache2 httpd.conf

## OS Support

This formulae is currently only tested on macOSv15 (Sequoia)

## License

The code in this project is licensed under the [MIT license](http://choosealicense.com/licenses/mit/).
Please see the [license file](LICENSE) for more information.
