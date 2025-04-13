#
#  Point to this file in your $PYTHONSTARTUP environment variable.
#
#  In interactive use of Python, all modules will be automatically
#  imported when you first reference them.  This is done by creating
#  instances of ModuleLoader and putting them into the __main__ scope
#  under the name of all existing modules.
#

def startup():
    #
    #  Command-line completion
    #
    try:
        import readline
        import rlcompleter  # noqa
    except ImportError:
        pass
    else:
        import sys
        import os
        import atexit
        if 'libedit' in readline.__doc__:
            readline.parse_and_bind("bind ^I rl_complete")
            readline.parse_and_bind("bind ^R em-inc-search-prev")
            readline.parse_and_bind("bind ^S em-inc-search-next")
            readline.parse_and_bind("bind ^[[A ed-search-prev-history")
            readline.parse_and_bind("bind ^[[B ed-search-next-history")
        else:
            readline.parse_and_bind("tab: complete")
            # readline.parse_and_bind("\e[A: history-search-backward")
            # readline.parse_and_bind("\e[B: history-search-forward")
        histfile = os.path.join(os.environ["HOME"], ".pyhist")
        try:
            readline.read_history_file(histfile)
        except IOError:
            pass
        readline.set_history_length(1000)

        def save_history(filename):
            history = [readline.get_history_item(i) for i in range(1, readline.get_current_history_length()+1)]
            readline.clear_history()
            for line in history:
                if line.startswith('hashpass'):
                    line = 'hashpass(...)'
                readline.add_history(line)
            return readline.write_history_file(filename)
        atexit.register(save_history, histfile)

    #
    #  Module auto-loader
    #
    try:
        import importlib.machinery
        ALL_SUFFIXES = importlib.machinery.all_suffixes()
    except ImportError:
        import imp
        ALL_SUFFIXES = [suffix for suffix, mode, typ in imp.get_suffixes()]
    import os
    import sys
    import __main__
    import builtins

    def loadmodule(self):
        import __main__
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
            super(ModuleLoader, self).__init__(name)
            d = super(ModuleLoader, self).__getattribute__('__dict__')
            d['__name__'] = name

        def __repr__(self):
            return '<module %r (auto-load)>' % self.__name__

        def __getattribute__(self, attr):
            if attr == '__name__':
                d = super(ModuleLoader, self).__getattribute__('__dict__')
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
    import os
    import __main__

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
