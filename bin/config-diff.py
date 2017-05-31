#!/usr/bin/env python

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


def get_current_config(app_name):
    output = check_output('DEIS_PROFILE=usw deis config:list --oneline -a {}'.format(app_name), shell=True)
    return parse_env_file(output.decode('utf-8').split())


def main(app_name):
    local_vars = get_local_config(app_name)
    remote_vars = get_current_config(app_name)
    diff = False
    for key, value in local_vars.items():
        if key not in remote_vars or value != remote_vars[key]:
            diff = True
            print('{var_name}:\n  current value: {old_val}\n      new value: {new_val}\n'.format(
                var_name=key,
                old_val=remote_vars.get(key) or '(none)',
                new_val=value))
    if diff:
        return 0
    else:
        return 'configs are identical'

if __name__ == '__main__':
    sys.exit(main(sys.argv[1]))
