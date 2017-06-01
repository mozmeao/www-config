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
    output = check_output('DEIS_PROFILE={} {} config:list --oneline -a {}'.format(region, deis_bin, app_name),
                          shell=True)
    return parse_env_file(output.decode('utf-8').split())


def get_diff(app_name, region):
    local_vars = get_local_config(app_name)
    remote_vars = get_current_config(app_name, region)
    diff = []
    for key, value in local_vars.items():
        if key not in remote_vars or value != remote_vars[key]:
            diff.append((key, remote_vars.get(key) or '(none)', value))

    return diff


def main(app_name):
    parser = argparse.ArgumentParser(description='Show differences between repo and app configs')
    parser.add_argument('app', metavar='APP_NAME', help='Deis app name')
    parser.add_argument('-r', '--region', default='usw', choices=CLUSTERS.keys(),
                        help='Deis cluster with which to diff (default: usw)')
    args = parser.parse_args()
    diff = get_diff(args.app, args.region)
    if not diff:
        return 'configs are identical'

    for key, old_val, new_val in diff:
        print('{var_name}:\n  current value: {old_val}\n      new value: {new_val}\n'.format(
            var_name=key,
            old_val=old_val,
            new_val=new_val))

    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1]))
