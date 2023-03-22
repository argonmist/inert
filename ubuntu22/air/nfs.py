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

def genNFS(svc, sshpassYAMLPath, settings):
  with open(sshpassYAMLPath, 'a') as sshpassYAML:
    sshpassYAML.write('[' + svc + ']\n')
  with open(sshpassYAMLPath, 'a') as sshpassYAML:
    sshpassYAML.write('nfs' + '\n')

if __name__ == '__main__':
    settings = readyaml.read()
    sshpassYAMLPath= main_path + '/inventory/nfs.yaml'
    if os.path.exists(sshpassYAMLPath):
      os.remove(sshpassYAMLPath)
    genDefault(sshpassYAMLPath, settings)
    if 'nfs' in settings:
      genNFS('nfs', sshpassYAMLPath, settings)

