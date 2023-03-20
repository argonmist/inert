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
    deployIP = settings['deploy']
    if deployIP:
      sshpassYAML.write(deployIP + '\n')
    cicdIP = settings['cicd']
    if cicdIP:
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
    genSSH('k8s', sshpassYAMLPath, settings)
    genSSH('haproxy', sshpassYAMLPath, settings)
    genSSH('nfs', sshpassYAMLPath, settings)

