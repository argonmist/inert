import sys
main_path = '/var/inert'
sys.path.insert(0, main_path)
from air import readyaml
import subprocess

def genDefault(sshpassYAMLPath, settings):
  user = settings['user']
  password = settings['pass']

  cmd = '/bin/bash ' + main_path + '/scripts/gen_sshpass_default.sh ' + user + ' ' + password
  subprocess.call(cmd, shell=True)

  with open(sshpassYAMLPath, 'a') as sshpassYAML:
    sshpassYAML.write('[ssh]\n')
    if 'cicd' in settings:
      cicdIP = settings['cicd']
      sshpassYAML.write(cicdIP + '\n')

def genSSH(svc, sshpassYAMLPath, settings):
  with open(sshpassYAMLPath, 'a') as sshpassYAML:
    k = 0
    for i in settings[svc]:
      for j in i:
        svcIP = settings[svc][k][j]
        if svcIP:
          sshpassYAML.write(svcIP + '\n')
      k = k + 1

if __name__ == '__main__':
    settings = readyaml.read()
    sshpassYAMLPath= main_path + '/inventory/sshpass.yaml'
    genDefault(sshpassYAMLPath, settings)
    if 'k8s' in settings:
      genSSH('k8s', sshpassYAMLPath, settings)
    if 'haproxy' in settings:
      genSSH('haproxy', sshpassYAMLPath, settings)
    if 'nfs' in settings:
      genSSH('nfs', sshpassYAMLPath, settings)

