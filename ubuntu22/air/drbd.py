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

def genDrbd(svc, sshpassYAMLPath, settings):
  with open(sshpassYAMLPath, 'a') as sshpassYAML:
    sshpassYAML.write('[' + svc + ']\n')
  with open(sshpassYAMLPath, 'a') as sshpassYAML:
    sshpassYAML.write('drbd-1' + '\n')
    for i in range(len(settings['drbd']['secondary']['hostname'])):
      j = i + 2
      sshpassYAML.write('drbd-'+ str(j) + '\n')

if __name__ == '__main__':
    settings = readyaml.read()
    sshpassYAMLPath= main_path + '/inventory/drbd.yaml'
    if os.path.exists(sshpassYAMLPath):
      os.remove(sshpassYAMLPath)
    genDefault(sshpassYAMLPath, settings)
    if 'drbd' in settings:
      genDrbd('drbd', sshpassYAMLPath, settings)
      genDrbd('lvm', sshpassYAMLPath, settings)

