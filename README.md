# Installation

1. Clone the repository with `git clone` and change the directory

```bash
git clone git@github.com:hpi-schul-cloud/infra-tsocks.git
```
or
```bash
git clone https://github.com/hpi-schul-cloud/infra-tsocks.git
```
and
```bash
cd infra-tsocks
```
2. Run ./configure, options which might be of interest (and that are 
   specific to tsocks include):
   `--enable-socksdns` This option causes tsocks to intercept
				DNS lookups and attempt to force them
				to use TCP instead of UDP and thus
				be proxied through the socks server. This
				is not a very elegant thing to do and
				should be avoided where possible.
	`--disable-debug` This configuration option tells tsocks
				to never output error messages to stderr.
				This can also be achieved at run time
				by defining the environment variable
				TSOCKS_NO_ERROR to be "yes"
	`--enable-oldmethod` This forces tsocks not to use the
				RTLD_NEXT parameter to dlsym to get the
				address of the connect() method tsocks
				overrides, instead it loads a reference
				to the libc shared library and then uses
				dlsym(). Again this is not very elegant
				and shouldn't be required.
	`--disable-hostnames` This disables DNS lookups on names
				provided as socks servers in the config
				file. This option is necessary
				if socks dns is enabled since tsocks
				can't send a socks dns request to resolve
				the location of the socks server. 
	`--with-conf=<filename>` You can specify the location of the tsocks
				configuration file using this option, it
				defaults to '/etc/tsocks.conf'
Other standard autoconf options are provided by typing `./configure
--help`
NOTE: The install path for the library is _NOT_ prefixed with --prefix,
this is because it is strongly recommended that tsocks is installed into
/lib (and not /usr/lib). This is important if tsocks is put into
/etc/ld.so.preload since /usr is not mounted on many systems at boot
time, meaning that programs running before /usr is mounted will try to
preload tsocks, fail to find it and die, making the machine unusable. If
you really wish to install the library into some other path use --libdir.

3. Compile the code by typing:
	`make`
This should result in the creation of the following:
	- libtsocks.so - the libtsocks library
	- validateconf - a utility to verify the tsocks configuration file
	- inspectsocks - a utility to determine the version of a socks server
	- saveme - a statically linked utility to remove /etc/ld.so.preload
		   if it becomes corrupt

4. Install the compiled library. You can skip this step if you only plan
to use the library for personal use. If you want all users on the machine
to be able to use it however, su to root then type
`make install`
This will install the library, the tsocks script and its man pages
(tsocks(8), tsocks(1) and tsocks.conf(5)) to the paths specified to
configure.
Note that by default the library is installed to /lib and that the
configure --prefix is IGNORED. See above for more detail. 

5. At this point you'll need to create the tsocks configuration file.
There are two samples provided in the build directory called
tsocks.conf.simple.example and tsocks.conf.complex.example.
Documentation on the configuration file format is provided in the
tsocks.conf man page ('man tsocks.conf'). 

6. Having created the tsocks.conf file you should verify it using
validateconf (some detail on validateconf can be found in the tsocks.conf
man page). Normally validateconf is run without arguments
('./validateconf'). Any errors which are displayed by validateconf need
to be rectified before tsocks will function correctly.

7. You can now choose to make the library affect all users or just those
who choose to use it. If you want users to use it themselves, they can
simply use the tsocks(1) shell script to run programs (see 'man tsocks')
or do the following in their shell before running applications that need
to be transparently proxied:

	(in Bash) `export LD_PRELOAD=<path to library>`
	(in CSH) `setenv LD_PRELOAD <path to library>`

	`<path to library> = e.g /usr/lib/libtsocks.so.1.8`
  If you want all users to pick up the library, place the full path to the
  full library in the file /etc/ld.so.preload (e.g "/usr/lib/libtsocks.so"). Be
  EXTREMELY careful if you do this, if you mistype it or in some way get it
  wrong this will make your machine UNUSABLE. Also, if you do this, make
  sure the directory you put the library in is in the root of the
  filesystem, if the library is not available at boot time, again, your
  machine will be UNUSABLE. 

8. If you do happen to break your machine with /etc/ld.so.preload, the build process creates a statically linked executable called saveme in the build directory. This executable simply unlinks /etc/ld.so.preload, this may or may not save you so give it a try. If it fails, you'll need to switch off the machine and get a rescue disk (e.g tomsrtbt) mount the disk and remove the file manually.

# Usage
## tsocks(1)

- Shell wrapper to simplify the use of the tsocks(8) library to 
transparently allow an application to use a SOCKS proxy

<a name="synopsis"></a>

## Synopsis

```
tsocks [application&nbsp;[application's&nbsp;arguments]]
or tsocks [on|off]
or tsocks
```

<a name="description"></a>

## Description

**tsocks** is a wrapper between the tsocks library and the application what you
would like to run socksified.

<a name="options"></a>

## Options


* [application&nbsp;[application's&nbsp;arguments]]  
  run the application as specified with the environment (LD_PRELOAD) set
  such that tsocks(8) will transparently proxy SOCKS connections in 
  that program
* [on|off]  
  this option adds or removes tsocks(8) from the LD_PRELOAD environment
  variable. When tsocks(8) is in this variable all executed
  applications are automatically socksified. If you want to
  use this function, you HAVE to source the shell script from yours,
  like this: "source /usr/bin/tsocks" or ". /usr/bin/tsocks"  
  Example:  
  ". tsocks on" -- add the tsocks lib to LD_PRELOAD  
  ". tsocks off" -- remove the tsocks lib from LD_PRELOAD
* [show|sh]  
  show the current value of the LD_PRELOAD variable
* &lt;without&nbsp;any&nbsp;argument&gt;  
  create a new shell with LD_PRELOAD including tsocks(8). 


<a name="author"></a>

## Author

This script was created by Tamas SZERB &lt;[toma@rulez.org](mailto:toma@rulez.org)&gt; for the debian
package of tsocks. It (along with this manual page) have since been 
adapted into the main tsocks project and modified.

# tsocks(8)

- Library for intercepting outgoing network connections and
redirecting them through a SOCKS server. 


<a name="synopsis"></a>

## Synopsis


Set LD_PRELOAD to load the library then use applications as normal

The syntax to force preload of the library for different shells is specified below:
 
Bash, Ksh and Bourne shell - `export LD_PRELOAD=/lib/libtsocks.so`

C Shell - `setenv LD_PRELOAD=/lib/libtsocks.so`

This process can be automated (for Bash, Bourne and Korn shell  users) for a single command or for all commands in a shell session by using the tsocks(1) script

You can also setup tsocks in such a way that all processes  automatically use it, a very useful configuration. For more  information on this configuration see the CAVEATS section of this manual page.


<a name="description"></a>

## Description

**tsocks** is a library to allow transparent SOCKS proxying. It wraps the normal
connect() function. When a connection is attempted, it consults the
configuration file (which is defined at configure time but defaults to
~/.tsocks.conf and if that file cannot be accessed, to /etc/tsocks.conf)
and determines if the IP address specified is local. If it is not, the
library redirects the connection to a SOCKS server specified in the
configuration file. It then negotiates that connection with the SOCKS
server and passes the connection back to the calling program.

**tsocks** is designed for use in machines which are firewalled from then
internet. It avoids the need to recompile applications like lynx or
telnet so they can use SOCKS to reach the internet. It behaves much like
the SOCKSified TCP/IP stacks seen on other platforms.


<a name="arguments"></a>

### ARGUMENTS

Most arguments to **tsocks** are provided in the configuration file (the location of which is defined at configure time by the --with-conf=&lt;file&gt; argument but defaults to /etc/tsocks.conf). The structure of this file is documented in tsocks.conf(8)

Some configuration options can be specified at run time using environment
variables as follows: 

* `TSOCKS_CONF_FILE`
  This environment variable overrides the default location of the tsocks 
  configuration file. This variable is not honored if the program tsocks
  is embedded in is setuid. In addition this environment variable can
  be compiled out of tsocks with the --disable-envconf argument to 
  configure at build time
  
* `TSOCKS_DEBUG`
  This environment variable sets the level of debug output that should be
  generated by tsocks (debug output is generated in the form of output to 
  standard error). If this variable is not present by default the logging 
  level is set to 0 which indicates that only error messages should be output. 
  Setting it to higher values will cause tsocks to generate more messages 
  describing what it is doing. If set to -1 tsocks will output absolutely no 
  error or debugging messages. This is only needed if tsocks output interferes 
  with a program it is embedded in. Message output can be permanently compiled 
  out of tsocks by specifying the --disable-debug option to configure at 
  build time
  
* `TSOCKS_DEBUG_FILE`
  This option can be used to redirect the tsocks output (which would normally 
  be sent to standard error) to a file. This variable is not honored if the 
  program tsocks is embedded in is setuid. For programs where tsocks output 
  interferes with normal operation this option is generally better than 
  disabling messages (with TSOCKS_DEBUG = -1)
  
* `TSOCKS_USERNAME`
  This environment variable can be used to specify the username to be used when
  version 5 SOCKS servers request username/password authentication. This 
  overrides the default username that can be specified in the configuration
  file using 'default_user', see tsocks.conf(8) for more information. This 
  variable is ignored for version 4 SOCKS servers.
  
* `TSOCKS_PASSWORD`
  This environment variable can be used to specify the password to be used when 
  version 5 SOCKS servers request username/password authentication. This 
  overrides the default password that can be specified in the configuration 
  file using 'default_pass', see tsocks.conf(8) for more information. This 
  variable is ignored for version 4 SOCKS servers.
   

<a name="dns-issues"></a>

### DNS ISSUES

**tsocks** will normally not be able to send DNS queries through a SOCKS server since
SOCKS V4 works on TCP and DNS normally uses UDP. Version 1.5 and up do
however provide a method to force DNS lookups to use TCP, which then makes
them proxyable. This option can only enabled at compile time, please
consult the INSTALL file for more information.


<a name="errors"></a>

### ERRORS

**tsocks** will generate error messages and print them to stderr when there are
problems with the configuration file or the SOCKS negotiation with the
server if the TSOCKS_DEBUG environment variable is not set to -1 or and
--disable-debug was not specified at compile time. This output may cause
some problems with programs that redirect standard error.

<a name="caveats"></a>

### CAVEATS

**tsocks** will not in the above configuration be able to provide SOCKS proxying to
setuid applications or applications that are not run from a shell. You can
force all applications to LD_PRELOAD the library by placing the path to
libtsocks in /etc/ld.so.preload. Please make sure you correctly enter the
full path to the library in this file if you do this. If you get it wrong,
you will be UNABLE TO DO ANYTHING with the machine and will have to boot
it with a rescue disk and remove the file (or try the saveme program, see
the INSTALL file for more info).  THIS IS A ***WARNING***, please be
careful. Also be sure the library is in the root filesystem as all hell
will break loose if the directory it is in is not available at boot time.


<a name="bugs"></a>

## Bugs
**tsocks** can only proxy outgoing TCP connections

**tsocks** does NOT work correctly with asynchronous sockets (though it does work with
non blocking sockets). This bug would be very difficult to fix and there 
appears to be no demand for it (I know of no major application that uses
asynchronous sockets)

**tsocks** is NOT fully RFC compliant in its implementation of version 5 of SOCKS, it
only supports the 'username and password' or 'no authentication'
authentication methods. The RFC specifies GSSAPI must be supported by any
compliant implementation. I haven't done this, anyone want to help?

**tsocks** can force the libc resolver to use TCP for name queries, if it does this
it does it regardless of whether or not the DNS to be queried is local or
not. This introduces overhead and should only be used when needed.

**tsocks** uses ELF dynamic loader features to intercept dynamic function calls from
programs in which it is embedded.  As a result, it cannot trace the 
actions of statically linked executables, non-ELF executables, or 
executables that make system calls directly with the system call trap or 
through the syscall() routine.


<a name="files"></a>

## Files

/etc/tsocks.conf - default tsocks configuration file

<a name="see-also"></a>

## See Also

tsocks.conf(5)
tsocks(1)

<a name="author"></a>

## Author

Shaun Clowes ([delius@progsoc.uts](mailto:delius@progsoc.uts).edu.au)


<a name="copyright"></a>

## Copyright

Copyright 2000 Shaun Clowes

tsocks and its documentation may be freely copied under the terms and
conditions of version 2 of the GNU General Public License, as published
by the Free Software Foundation (Cambridge, Massachusetts, United
States of America).

# tsocks.conf(5)

**tsocks.conf** - configuration file for tsocks(8)

<a name="overview"></a>

## Overview


The configuration for tsocks can be anything from two lines to hundreds of 
lines based on the needs at any particular site. The basic idea is to define 
any networks the machine can access directly (i.e without the use of a 
SOCKS server) and define one or many SOCKS servers to be used to access
other networks (including a 'default' server). 

Local networks are declared using the 'local' keyword in the configuration 
file. When applications attempt to connect to machines in networks marked
as local tsocks will not attempt to use a SOCKS server to negotiate the 
connection.

Obviously if a connection is not to a locally accessible network it will need
to be proxied over a SOCKS server. However, many installations have several
different SOCKS servers to be used to access different internal (and external)
networks. For this reason the configuration file allows the definition of 
\'paths\' as well as a default SOCKS server.

Paths are declared as blocks in the configuration file. That is, they begin
with a 'path {' line in the configuration file and end with a '}' line. Inside
this block directives should be used to declare a SOCKS server (as documented
later in this manual page) and 'reaches' directives should be used to declare 
networks and even destination ports in those networks that this server should 
be used to reach. N.B Each path MUST define a SOCKS server and contain one or 
more 'reaches' directives.

SOCKS server declaration directives that are not contained within a 'path' 
block define the default SOCKS server. If tsocks needs to connect to a machine
via a SOCKS server (i.e it isn't a network declared as 'local') and no 'path'
has declared it can reach that network via a 'reaches' directive this server 
is used to negotiate the connection. 


<a name="configuration-syntax"></a>

## Configuration Syntax


The basic structure of all lines in the configuration file is:

&lt;directive&gt; = &lt;parameters&gt;

The exception to this is 'path' blocks which look like:

path {
&lt;directive&gt; = &lt;parameters&gt;
}

Empty lines are ignored and all input on a line after a '#' character is 
ignored.


<a name="directives-"></a>

### DIRECTIVES 

The following directives are used in the tsocks configuration file:


* _server_  
  The IP address of the SOCKS server (e.g "server = 10.1.4.253"). Only one
  server may be specified per path block, or one outside a path
  block (to define the default server). Unless --disable-hostnames was 
  specified to configure at compile time the server can be specified as 
  a hostname (e.g "server = socks.nec.com") 
  
* _server_port_  
  The port on which the SOCKS server receives requests. Only one server_port
  may be specified per path block, or one outside a path (for the default
  server). This directive is not required if the server is on the
  standard port (1080).
  
* _server_type_  
  SOCKS version used by the server. Versions 4 and 5 are supported (but both
  for only the connect operation).  The default is 4. Only one server_type
  may be specified per path block, or one outside a path (for the default
  server). 
  
  You can use the inspectsocks utility to determine the type of server, see
  the 'UTILITIES' section later in this manual page.
  
* _default_user_  
  This specifies the default username to be used for username and password
  authentication in SOCKS version 5. In order to determine the username to
  use (if the socks server requires username and password authentication)
  tsocks first looks for the environment variable TSOCKS_USERNAME, then
  looks for this configuration option, then tries to get the local username.
  This option is not valid for SOCKS version 4 servers. Only one default_user 
  may be specified per path block, or one outside a path (for the default 
  server)
  
* _default_pass_  
  This specified the default password to be used for username and password
  authentication in SOCKS version 5. In order to determine the password to
  use (if the socks server requires username and password authentication)
  tsocks first looks for the environment variable TSOCKS_PASSWORD, then
  looks for this configuration option. This option is not valid for SOCKS
  version 4 servers. Onle one default_pass may be specified per path block, 
  or one outside a path (for the default server)
  
* _local_  
  An IP/Subnet pair specifying a network which may be accessed directly without
  proxying through a SOCKS server (e.g "local = 10.0.0.0/255.0.0.0"). 
  Obviously all SOCKS server IP addresses must be in networks specified as 
  local, otherwise tsocks would need a SOCKS server to reach SOCKS servers.
  
* _reaches_  
  This directive is only valid inside a path block. Its parameter is formed
  as IP[:startport[-endport]]/Subnet  or \*[:startport[-endport]]/Subnet and 
  it specifies a network (and a range
  of ports on that network) that can be accessed by the SOCKS server specified
  in this path block. For example, in a path block "reaches =
  150.0.0.0:80-1024/255.0.0.0" indicates to tsocks that the SOCKS server 
  specified in the current path block should be used to access any IPs in the 
  range 150.0.0.0 to 150.255.255.255 when the connection request is for ports
  80-1024. For assigning a port or a port range to a specific server instead 
  of an IP, a wildcard '*' can be used. In this case the Subnet part is ignored.
  
  
* _fallback_  
  This directive allows one to fall back to direct connection if no default
  server present in the configuration and fallback = yes.
  If fallback = no or not specified and there is no default server, the 
  tsocks gives an error message and aborts.
  This parameter protects the user against accidentally establishing
  unwanted unsockified (ie. direct) connection.
  

<a name="configuration-file-search-order"></a>

### Configuration File Search Order

tsocks will search first for $HOME/.tsocks.conf then /etc/tsocks.conf


<a name="utilities"></a>

## Utilities

tsocks comes with two utilities that can be useful in creating and verifying
the tsocks configuration file. 


* inspectsocks  
  inspectsocks can be used to determine the SOCKS version that a server supports.
  Inspectsocks takes as its arguments the ip address/hostname of the SOCKS
  server and optionally the port number for socks (e.g 'inspectsocks 
  socks.nec.com 1080'). It then inspects that server to attempt to determine 
  the version that server supports. 
  
* validateconf  
  validateconf can be used to verify the configuration file. It checks the format
  of the file and also the contents for errors. Having read the file it dumps 
  the configuration to the screen in a formatted, readable manner. This can be 
  extremely useful in debugging problems.
  
  validateconf can read a configuration file from a location other than the 
  location specified at compile time with the -f &lt;filename&gt; command line 
  option.
  
  Normally validateconf simply dumps the configuration read to the screen (in
  a nicely readable format), however it also has a useful 'test' mode. When
  passed a hostname/ip on the command line like -t &lt;hostname/ip&gt;, validateconf 
  determines which of the SOCKS servers specified in the configuration file 
  would be used by tsocks to access the specified host. 
  

<a name="see-also"></a>

# See Also

tsocks(8)

# FAQ

## Q: tsocks doesn't seem to be working for SSH, why?

A:

tsocks can be used a number of ways, the most common being the LD_PRELOAD
environment variable. When set (often through the 'tsocks' script) this
requests that the system dynamic loader load tsocks into each process
before execution of the process begins. This allows tsocks to redirect
calls to standard networking functions to force them to be socksified. 

Unfortunately LD_PRELOAD simply doesn't work for setuid programs when the
user running the program is not the same as the owner of the executable.
This is because being able to load code into a privileged executable
would be a major security flaw. To fix this problem you may wish to
removed the setuid bit from SSH (this will force it not to use privileged
TCP ports, disable some forms of RSA authentication to older servers and
may have other effects). Alternatively you might wish to force tsocks to
be loaded into all processes using the /etc/ld.so.preload file, for more
information please see the tsocks man page.


## Q: tsocks doesn't seem to be working for ftp, why?

A: 

tsocks can only socksify outgoing connection requests from applications,
in ftp there are normally two channels, one is made from the client to
the server (called the control channel) and another from the server back
to the client (called the data channel). If a SOCKS server is between the
client and the server the server will incorrectly try to connect back to
the SOCKS server rather than the client. Thus the data channel connection
will be fail (not that it would likely succeed even if it did try to
connect back to the correct client, given the SOCKS server is probably
firewalling the network off). 

The simplest solution to this problem is to use passive mode ftp, in this
form of ftp all connections are made from the client to server, even the
data channel. Most ftp clients and servers support passive mode, check
your documentation (as a tip the Linux command line ftp client uses
passive mode when invoced with the -p option) 

