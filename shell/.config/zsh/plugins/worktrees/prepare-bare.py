"""Configure bare-clone refs and missing upstreams without moving local branches."""
import argparse
import os
from pathlib import Path
import subprocess


def prepare(bare, new_clone=False):
    def git(*args, **kwargs):
        return subprocess.run(['git', '-C', str(bare), *args], check=True,
                              capture_output=True, text=True, **kwargs).stdout

    rows = [line.split('\t') for line in git(
        'for-each-ref', '--format=%(refname)\t%(objectname)', 'refs/heads').splitlines()]
    if new_clone:
        git('config', 'remote.origin.fetch', '+refs/heads/*:refs/remotes/origin/*')
        # A bare clone has the remote's branch tips, but no remote-tracking refs.
        # Seed those from the clone snapshot; never do this on an existing clone.
        def quote(value):
            return '"' + value.replace('\\', '\\\\').replace('"', '\\"') + '"'
        commands = ''.join('create ' + quote('refs/remotes/origin/' + ref[len('refs/heads/'):])
                           + ' ' + oid + '\n' for ref, oid in rows)
        if commands:
            git('update-ref', '--stdin', input='start\n' + commands + 'prepare\ncommit\n')

    remotes = set(git('for-each-ref', '--format=%(refname)', 'refs/remotes/origin').splitlines())
    config = bare / 'config'
    lock = bare / 'config.lock'
    # Use Git's own lock convention and one atomic write, even for thousands of
    # cloned branches. Preserve custom upstreams, including currently missing refs.
    descriptor = os.open(lock, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    try:
        with os.fdopen(descriptor, 'w') as stream:
            os.fchmod(stream.fileno(), config.stat().st_mode & 0o777)
            settings = {entry.split('\n', 1)[0] for entry in git('config', '--null', '--list').split('\0') if entry}
            stream.write(config.read_text())
            for ref, _ in rows:
                branch = ref[len('refs/heads/'):]
                if 'refs/remotes/origin/' + branch not in remotes:
                    continue
                if any('branch.' + branch + '.' + key in settings for key in ('remote', 'merge')):
                    continue
                escaped = branch.replace('\\', '\\\\').replace('"', '\\"')
                stream.write('\n[branch "' + escaped + '"]\n\tremote = origin\n\tmerge = "'
                             + ref.replace('\\', '\\\\').replace('"', '\\"') + '"\n')
        git('config', '--file', str(lock), '--list')
        os.replace(lock, config)
    finally:
        lock.unlink(missing_ok=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('bare', type=Path)
    parser.add_argument('--new-clone', action='store_true')
    args = parser.parse_args()
    prepare(args.bare.resolve(), args.new_clone)
