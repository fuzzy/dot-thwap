#!/usr/bin/env python3

import re
import os
import sys
import time
import shlex
import random
import subprocess


def show_help():
    print(f'Usage: {os.path.basename(sys.argv[0])} [-sync|-snap|-zfs]')
    sys.exit(0)


class Output(object):
    def _write(self, m):
        sys.stdout.write(m)
        sys.stdout.flush()

    def msg(self, m):
        self._write(f'\033[32m>>> \033[1;37m{m}\033[0m\n')

    def err(self, m):
        self._write(f'\033[31m!!! \033[1;37m{m}\033[0m\n')

    def fatal(self, m):
        self._write(f'\033[1;31m!!! \033[1;37m{m}\033[0m\n')
        sys.exit(1)

    def statusMsg(self, m):
        self._write(f'\033[32m>>> \033[1;37m{m}\033[0m: ')

    def statusOk(self):
        self._write('\033[1;32mOK\033[0m\n')

    def statusErr(self):
        self._write('\033[1;31mERR\033[0m\n')


class Utils(Output):

    def __init__(self):
        # sudo stuff
        if self._which('sudo'):
            self.sudo = self._which('sudo')
        else:
            self.sudo = ''

        # rdiff-backup
        if self._which('rdiff-backup'):
            self.rdiff = self._which('rdiff-backup')
        else:
            self.fatal('You must install rdiff-backup.')

            # OS specific stuff
        if os.uname().sysname == 'Linux':
            if self._which('tar'):
                self.tar = self._which('tar')
        elif os.uname().sysname == 'FreeBSD':
            if self._which('gtar'):
                self.tar = self._which('gtar')
            else:
                self.fatal('You must install GNU tar (gtar).')

    def _which(self, cmd):
        for dname in os.getenv('PATH').split(':'):
            if cmd in os.listdir(dname):
                return '/'.join((dname, cmd))
        return None

    def _exec(self, cmd, msg):
        self.statusMsg(msg)
        retv = subprocess.run(cmd.split(),
                              stdout=subprocess.PIPE,
                              stderr=subprocess.STDOUT)
        if retv.returncode == 0:
            self.statusOk()
            return True
        else:
            self.statusErr()
            logf = '/tmp/%016d.log' % random.randint(0, 1000000000000000)
            log = open(logf, 'w+')
            log.write('Message: '+msg.strip()+'\n')
            log.write('Command: '+cmd.strip()+'\n')
            log.write(retv.stdout.decode('utf-8'))
            self.err('Details: %s' % logf)
            return False

    def humanTime(self, s):
        times = eDict(sc=1,     mn=60,
                      hr=60**2, dy=((60**2)*24),
                      wk=(((60**2)*24)*7))
        retv = eDict(sc=0, mn=0, hr=0, dy=0, wk=0)
        secs = int(s)
        if secs >= times.wk:
            retv.wk = (secs / times.wk)
            secs = int(secs % times.wk)
        if secs >= times.dy:
            retv.dy = (secs / times.dy)
            secs = int(secs % times.dy)
        if secs >= times.hr:
            retv.hr = (secs / times.hr)
            secs = int(secs % times.hr)
        if secs >= times.mn:
            retv.mn = (secs / times.mn)
            secs = int(secs % times.mn)
        retv.sc = secs
        return '%dw%dd%dh%dm%ds' % (retv.wk,
                                    retv.dy,
                                    retv.hr,
                                    retv.mn,
                                    retv.sc)


class Backup(Utils):
    def backup(self):
        self.err('You forgot to override Backup.backup()')

    def cleanup(self):
        self.err('You forgot to override Backup.cleanup()')


class RdiffBackup(Backup):
    def __init__(self, cfg):
        if cfg:
            self.cfg = cfg
            Utils.__init__(self)
        else:
            self.fatal('Invalid config object passed: RdiffBackup.__init__()')

    def backup(self):
        self.msg(f'Delta backup: {os.getenv("HOME")}')
        date_l = f'\033[0mDate: \033[1;37m{time.ctime()}\033[0m'
        self._exec('%s %s %s/ %s/' % (self.rdiff,
                                      self.cfg.rdiff.arguments,
                                      os.getenv('HOME'),
                                      self.cfg.rdiff.target),
                   date_l)

    def cleanup(self):
        self._exec(
            'rdiff-backup --force --remove-older-than %s %s' % (
                cfg.rdiff.retention,
                cfg.rdiff.target
            ),
            '\033[0mPruning backups older than: \033[1;37m%s\033[0m' % (
                cfg.rdiff.retention
            )
        )


class RdiffRestore(Utils):
    pass


class SnapBackup(Backup):
    def __init__(self, cfg):
        if cfg:
            self.cfg = cfg
            Utils.__init__(self)
        else:
            self.fatal('Invalid config object passed: SnapBackup.__init__()')

    def backup(self):
        self.msg('Snap backup: %s' % os.getenv('HOME'))
        fname = f'{self.cfg.snaps.target}/{self.cfg.snaps.template}.tar'
        date_l = f'\033[0mDate: \033[1;37m{time.ctime()}\033[0m'
        comp_t = []
        for t in (('Compression', self.cfg.snaps.compression),
                  ('Compressor',  self.cfg.snaps.compressor)):
            comp_t.append(f'\033[0m{t[0]}: \033[1;37m{t[1]}\033[0m')
        comp_l = f'{comp_t[0]} {comp_t[1]}'
        args_l = self.cfg.snaps.arguments
        home_l = os.getenv('HOME')
        if not os.path.isdir(os.path.dirname(fname)):
            os.makedirs(os.path.dirname(fname), exist_ok=True)
        self._exec(f'{self.sudo} {self.tar} -f {fname} {args_l} -c {home_l}',
                   date_l)
        if not self._which(self.cfg.snaps.compressor):
            self.fatal(f'You must install: {self.cfg.snaps.compressor}')
        if self._which(self.cfg.snaps.compressor):
            comp_c = f'{self.cfg.snaps.compressor}'
            comp_d = f'{self.cfg.snaps.compressor_arguments}'
            self._exec(f'{comp_c} {comp_d} {fname}', comp_l)
        else:
            self.fatal(f'You must install {self.cfg.snaps.compressor}')


class SnapRestore(Utils):
    pass


class ZfsBackup(Backup):
    def __init__(self, cfg):
        if cfg:
            self.cfg = cfg
            Utils.__init__(self)
        else:
            self.fatal('Invalid config object passed: ZfsBackup.__init__()')


class ZfsRestore(Utils):
    pass


class eDict(dict):
    def __init__(self, *args, **kwargs):
        dict.__init__(self, *args, **kwargs)

    def __getattr__(self, attr):
        if attr[0] == '_':
            return dict.__getattr__(self, attr)
        if attr in self.keys():
            return self.__getitem__(attr)
        return ''

    def __setattr__(self, attr, value):
        if attr[0] == '_':
            return dict.__setattr__(self, attr, value)
        return self.__setitem__(attr, value)


class Config(eDict):
    def __init__(self, fn):
        eDict.__init__(self)
        self._env = eDict()
        self._cmd = eDict()
        self._env_pattern = re.compile('\$\{[a-zA-Z_0-9]+\}')
        self._cmd_pattern = re.compile('\$\([a-zA-Z_0-9\+\%\-\ ]+\)')
        self._sct_pattern = re.compile('\$\[[a-zA-Z_0-9\:]+\]')
        if os.path.isfile(fn):
            self._fn = fn
            self._lex = shlex.shlex(instream=open(self._fn))
            self._lex.whitespace_split = True
            self._num = re.compile('^[0-9\.]+$')
            for token in list(self._lex):
                if token[0] == '[':
                    self.__setattr__(token[1:-1], eDict())
                    self._current = token[1:-1]
                elif token[-1] == ':':
                    self._token = token[:-1]
                else:
                    tkn = self.interpolate(token)
                    if tkn[0] in ("'", '"'):
                        try:
                            self[self._current][self._token] += ' '
                            self[self._current][self._token] += tkn[1:-1]
                        except KeyError:
                            self[self._current][self._token] = tkn[1:-1]
                    elif self._num.match(tkn) and tkn.find('.') == -1:
                        self[self._current][self._token] = int(tkn)
                    elif self._num.match(tkn) and tkn.find('.') != -1:
                        self[self._current][self._token] = float(tkn)
                    else:
                        self[self._current][self._token] = tkn

    def interpolate(self, st):
        tokens = []
        retv = st
        for t in self._env_pattern.findall(st):
            a = os.getenv(t[2:-1])
            tokens.append((t, a))
        for t in self._cmd_pattern.findall(st):
            reto = subprocess.run(
                t[2:-1].split(),
                capture_output=True
            ).stdout.decode('utf-8')
            tokens.append((t, reto.strip()))
        for t in self._sct_pattern.findall(st):
            if t.find(':') != -1:
                s, k = t[2:-1].split(':')
                if s in self.keys():
                    tokens.append((t, self[s][k]))
            else:
                if t[2:-1] in self[self._current].keys():
                    tokens.append((t, self[self._current][t[2:-1]]))
        for t in tokens:
            tretv = re.sub(re.escape(t[0]), t[1], retv)
            retv = tretv
        return retv


if __name__ == '__main__':
    action = 'backup'
    cfg = Config('%s/.thwap/etc/thwap-backup.cfg' % os.getenv('HOME'))
    if len(sys.argv) == 1:
        show_help()
    for arg in sys.argv[1:]:
        if arg in ('-h', '--help', '-help', '-?'):
            show_help()
        elif arg == '-sync':
            obj = RdiffBackup(cfg)
        elif arg == '-snap':
            obj = SnapBackup(cfg)
        elif arg == '-zfs':
            obj = ZfsBackup(cfg)
        else:
            show_help()
        if action == 'backup':
            st_time = time.time()
            obj.backup()
            obj.cleanup()
            ed_time = time.time()
            runtime = obj.humanTime(ed_time - st_time)
            obj.msg(f'\033[0mFinished in: \033[1;37m{runtime}\033[0m')
