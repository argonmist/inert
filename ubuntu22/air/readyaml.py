import yaml
import os

def read():
    basic_path = '/var/inert/settings.yaml'
    with open(basic_path, "r") as stream:
        try:
            settings = yaml.safe_load(stream)
            return settings
        except yaml.YAMLError as exc:
            print(exc)
