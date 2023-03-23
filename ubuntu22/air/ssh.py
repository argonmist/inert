import sys
import os
main_path = '/var/inert'
sys.path.insert(0, main_path)
from air import readyaml
import subprocess

def genDefault(sshpassYAMLPath, settings):
  user = settings['user']
  password = settings['pass']

  cmd = '/bin/bash ' + main_path + '/scripts/gen_default.sh ' + user + ' ' + password
  subprocess.call(cmd, shell=True)

  with open(main_path + '/inventory/default.yaml','r') as template, open(sshpassYAMLPath,'a') as sshpassYAML:
    for line in template:
      sshpassYAML.write(line)
    sshpassYAML.write('\n')

  with open(sshpassYAMLPath, 'a') as sshpassYAML:
    sshpassYAML.write('[ssh]\n')
    if 'gocd' in settings:
      gocdIP = settings['gocd']
      sshpassYAML.write(gocdIP + '\n')

def genSSH(svc, sshpassYAMLPath, settings):
  with open(sshpassYAMLPath, 'a') as sshpassYAML:
    k = 0
    for i in settings[svc]:
      for j in i:
        svcIP = settings[svc][k][j]
        if svcIP:
          sshpassYAML.write(svcIP + '\n')
      k = k + 1

def genDrbdSSH(svc, sshpassYAMLPath, settings):
  with open(sshpassYAMLPath, 'a') as sshpassYAML:
    primaryIP = settings[svc]['primary']['ip']
    sshpassYAML.write(primaryIP + '\n')
    for i in settings[svc]['secondary']['ip']:
      svcIP = i
      if svcIP:
        sshpassYAML.write(svcIP + '\n')

if __name__ == '__main__':
    settings = readyaml.read()
    sshpassYAMLPath= main_path + '/inventory/sshpass.yaml'
    if os.path.exists(sshpassYAMLPath):
      os.remove(sshpassYAMLPath)
    genDefault(sshpassYAMLPath, settings)
    if 'k8s' in settings:
      genSSH('k8s', sshpassYAMLPath, settings)
    if 'haproxy' in settings:
      genSSH('haproxy', sshpassYAMLPath, settings)
    if 'drbd' in settings:
      genDrbdSSH('drbd', sshpassYAMLPath, settings)

