#!/usr/bin/env python

'''
A script suitable for use as a git pre-commit hook to ensure your
files are flake8-compliant before committing them.

Use this by copying it to a file called $ardupilot_wiki/.git/hooks/pre-commit

'''

import os
import re
import sys
import subprocess


class PreCommitFlake8(object):

    def __init__(self):
        self.retcode = 0
        self.files_to_check_flake8 = []

    @staticmethod
    def progress(message):
        print("***** %s" % (message, ))

    def check_flake8(self):
        for path in self.files_to_check_flake8:
            self.progress("Checking (%s)" % path)
        ret = subprocess.run(["flake8"] + self.files_to_check_flake8,
                             stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        if ret.returncode != 0:
            self.progress("Flake8 check failed: (%s)" % (ret.stdout))
            self.retcode = 1

    @staticmethod
    def split_git_diff_output(output):
        '''split output from git-diff into a list of (status, filepath) tuples'''
        ret = []
        if type(output) == bytes:
            output = output.decode('utf-8')
        for line in output.split("\n"):
            if len(line) == 0:
                continue
            ret.append(re.split(r"\s+", line))
        return ret

    def run(self):
        # generate a list of files which have changes not marked for commit
        output = subprocess.check_output([
            "git", "diff", "--name-status"])
        dirty_list = self.split_git_diff_output(output)
        dirty = set()
        for (status, dirty_filepath) in dirty_list:
            dirty.add(dirty_filepath)

        # check files marked for commit:
        output = subprocess.check_output([
            "git", "diff", "--cached", "--name-status"])
        output_tuples = self.split_git_diff_output(output)
        for output_tuple in output_tuples:
            if len(output_tuple) > 2:
                if output_tuple[0].startswith('R'):
                    # rename, check destination
                    (status, filepath) = (output_tuple[0], output_tuple[2])
                else:
                    raise ValueError("Unknown status %s" % str(output_tuple[0]))
            else:
                (status, filepath) = output_tuple
            if filepath in dirty:
                self.progress("WARNING: (%s) has unstaged changes" % filepath)
            if status == 'D':
                # don't check deleted files
                continue
            (base, extension) = os.path.splitext(filepath)
            if extension == ".py":
                self.files_to_check_flake8.append(filepath)
        if self.files_to_check_flake8:
            self.check_flake8()
        return self.retcode


if __name__ == '__main__':
    precommit = PreCommitFlake8()
    sys.exit(precommit.run())
