import json
import os
import re

from collections import OrderedDict
from fabric.api import local
from fabric.utils import puts
from fabric.colors import yellow, green

PROJECT_ROOT = os.path.dirname(os.path.abspath(__file__))


def version(part="+major"):
    def format_version(groups):
        return "{0}.{1}.{2}".format(*[g[1] for g in groups.items()])

    path = os.path.join(PROJECT_ROOT, 'VERSION')

    f = open(path, 'r')
    current_version = f.read()
    f.close()

    regex = re.compile(r'(\d+)\.(\d+)\.(\d+)')
    match = regex.match(current_version)

    groups = OrderedDict([
        ('major', int(match.groups()[0])),
        ('minor', int(match.groups()[1])),
        ('patch', int(match.groups()[2])),
    ])

    inc_dec = part[0]
    part_type = part[1:]

    if inc_dec is "+":
        if part_type == 'major':
            groups['major'] += 1
            groups['minor'] = 0
            groups['patch'] = 0
        elif part_type == 'minor':
            groups['minor'] += 1
            groups['patch'] = 0
        elif part_type == 'patch':
            groups['patch'] += 1
    else:
        if groups[part_type] > 0:
            groups[part_type] -= 1

    new_version = format_version(groups)

    package = json.load(open('frontend/package.json', 'r'))
    package['version'] = new_version
    json.dump(package, open('frontend/package.json', 'w'), indent=2)

    f = open(path, 'w')
    f.write(new_version)
    f.close()

    local("git tag {version}".format(version=new_version))
    puts(yellow("Version is now: ") + green(new_version))
    puts(yellow("Don't forget to run `git push --tags`"))
