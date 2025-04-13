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
        editline = 'libedit' in readline.__doc__
        if not editline:
            readline.parse_and_bind("tab: complete")
        histfile = os.path.join(os.environ["HOME"], ".python_history")
        try:
            readline.read_history_file(histfile)
            prev_hist_len = readline.get_current_history_length()
        except FileNotFoundError:
            open(histfile, "wb").close()
            prev_hist_len = 0
        readline.set_history_length(1000)

        def save_history():
            hist_len = readline.get_current_history_length()
            pruned_cnt = 0
            for hist_index in range(hist_len, prev_hist_len, -1):
                line = readline.get_history_item(hist_index)  # one-based
                if line.startswith("hashpass("):
                    pruned_cnt += 1
                    readline.remove_history_item(hist_index - 1)  # zero-based, unlike get_history_item
            return readline.append_history_file(hist_len - prev_hist_len - pruned_cnt, histfile)
        atexit.register(save_history)

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
