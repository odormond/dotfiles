#
#  Point to this file in your $PYTHONSTARTUP environment variable.
#
#  In interactive use of Python, all modules will be automatically
#  imported when you first reference them.  This is done by creating
#  instances of ModuleLoader and putting them into the __main__ scope
#  under the name of all existing modules.
#

def startup():
    import os
    import sys
    import __main__
    import builtins
    #
    #  Module auto-loader
    #
    import importlib.machinery
    ALL_SUFFIXES = importlib.machinery.all_suffixes()

    def loadmodule(self):
        name = self.__name__
        m = __main__.__dict__.get(name)
        if m is self:
            del __main__.__dict__[name]
        if m is self or m is None:
            m = __import__(name, __main__.__dict__, __main__.__dict__, [])
            __main__.__dict__[name] = m
        return m

    class ModuleLoader(type(__main__)):
        __slots__ = []

        def __init__(self, name):
            super().__init__(name)
            d = super().__getattribute__('__dict__')
            d['__name__'] = name

        def __repr__(self):
            return '<module %r (auto-load)>' % self.__name__

        def __getattribute__(self, attr):
            if attr == '__name__':
                d = super().__getattribute__('__dict__')
                return d['__name__']
            return getattr(loadmodule(self), attr)

        def __setattr__(self, attr, value):
            setattr(loadmodule(self), attr, value)

        def __delattr__(self, attr):
            delattr(loadmodule(self), attr)

    modules = list(sys.builtin_module_names)
    for path in sys.path:
        if path:  # path.startswith(sys.prefix):
            try:
                dirlist = os.listdir(path)
            except OSError:
                continue
            for fn in dirlist:
                fp = os.path.join(path, fn)
                if os.path.isfile(fp):
                    for suf in ALL_SUFFIXES:
                        if fn.endswith(suf):
                            modules.append(fn[:-len(suf)])
                            break
                elif os.path.exists(os.path.join(fp, "__init__.py")):
                    modules.append(fn)
    d = __main__.__dict__
    d2 = builtins.__dict__
    for m in modules:
        if not m.startswith('__') and m not in d and m not in d2:
            d[m] = ModuleLoader(m)

    try:
        old_help = builtins.help
    except AttributeError:
        pass
    else:
        def help(*args, **kw):
            if args and isinstance(args[0], ModuleLoader):
                args = (loadmodule(args[0]),) + args[1:]
            return old_help(*args, **kw)
        builtins.help = help

    #
    #  Local .pystartup file
    #
    startup = '.pystartup'
    if os.path.isfile(startup):
        exec(compile(open(startup).read(), startup, 'exec'), __main__.__dict__)


startup()
del startup


def hashpass(site, length=10, printout=True):
    import base64
    import hashlib
    import os.path
    if not isinstance(site, bytes):
        site = site.encode('UTF-8')
    secret = open(os.path.expanduser('~/.dotfiles/python/hashpass.secret'), 'rb').read()
    pw = base64.b64encode(hashlib.md5(b':'.join((secret, site))).digest())[:length].decode('UTF-8')
    if printout:
        print(pw)
    else:
        return pw
