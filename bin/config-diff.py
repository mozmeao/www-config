#!/usr/bin/env python

import argparse
import sys
from subprocess import check_output

from envcat import get_unique_vars, parse_env_file


CLUSTERS = {
    'usw': 'deis',
    'euw': 'deis',
    'virginia': 'deis2',
    'tokyo': 'deis2',
}


def get_local_config(app_name):
    return get_unique_vars([
        'configs/global.env',
        'configs/usw.env',
        'configs/{}.env'.format(app_name),
    ])


def get_current_config(app_name, region):
    deis_bin = CLUSTERS[region]
    try:
        output = check_output('DEIS_PROFILE={} {} config:list --oneline -a {}'.format(region, deis_bin, app_name),
                              shell=True)
    except Exception:
        raise RuntimeError('Error communicating with Deis in {}'.format(region))

    return parse_env_file(output.decode('utf-8').split())


def get_diff(app_name, region):
    local_vars = get_local_config(app_name)
    remote_vars = get_current_config(app_name, region)
    diff = []
    for key, value in local_vars.items():
        if value and (key not in remote_vars or value != remote_vars[key]):
            diff.append((key, remote_vars.get(key) or '(none)', value))

    return diff


def get_diff_delete(app_name, region):
    local_vars = get_local_config(app_name)
    remote_vars = get_current_config(app_name, region)
    diff = []
    for key, value in local_vars.items():
        if not value and key in remote_vars:
            diff.append((key, remote_vars.get(key) or '(none)'))

    return diff


def format_diff_line(values, verbose, delete):
    if verbose:
        if delete:
            return '{0}:\n  current value: {1}\n'.format(*values)
        else:
            return '{0}:\n  current value: {1}\n      new value: {2}\n'.format(*values)
    else:
        if delete:
            return values[0]
        else:
            return '{0}={2}'.format(*values)


def print_diff(diff, verbose=False, delete=False):
    if verbose:
        if delete:
            print('Variables to Delete\n')
        else:
            print('Variables to Modify\n')

    for values in diff:
        print(format_diff_line(values, verbose, delete))


def main():
    parser = argparse.ArgumentParser(description='Show differences between repo and app configs')
    parser.add_argument('app', metavar='APP_NAME', help='Deis app name')
    parser.add_argument('-r', '--region', metavar='REGION', default='usw', choices=CLUSTERS.keys(),
                        help='Deis cluster with which to diff (default: usw)')
    parser.add_argument('-d', '--delete', action='store_true', default=False,
                        help='Run in variable deletion mode')
    parser.add_argument('-v', '--verbose', action='store_true', default=False,
                        help='Run in verbose mode')
    args = parser.parse_args()
    if args.delete:
        diff_fun = get_diff_delete
    else:
        diff_fun = get_diff

    try:
        diff = diff_fun(args.app, args.region)
    except RuntimeError as e:
        print(str(e))
        return 2

    if not diff:
        print('configs are identical')
        return 1

    print_diff(diff, args.verbose, args.delete)

    return 0


if __name__ == '__main__':
    sys.exit(main())
