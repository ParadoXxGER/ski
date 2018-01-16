# Ski
### A automation framework made for portability

Example setup:


1. Create a `.ski/` directory in your project.

2. Add a file 'your-project.yml' to `.ski/`

```
title: Your Project
description: Hello World
pipelines:
  - pipeline:
      id: build
      description: Build local docker images
      fail-fast: true
      target: :local
      tasks:
        - task:
            name: Show all local files
            command: ls .
        - task:
            name: Space used
            command: du -sch .
        - task:
            name: Ping google exactly one time
            command: ping google.de -t 1
        - task:
            name: Check processes running of port 3000
            command: lsof -i :3000
        - task:
            name: Check ruby version
            command: ruby -v
      on-success:
        tasks:
          - task:
              name: Wish a happy day
              command: echo 'Hey dear, the deployment was successfull. Have a nice day! :)'
      on-error:
        tasks:
          - task:
              name: Build App server
              command: echo 'Hello World'
  - pipeline:
      id: deploy
      description: Build local docker images
      fail-fast: true
      target: :local
      tasks:
        - task:
            name: Deploy to prod
            command: echo 'Deploy to prod'
      on-success:
        tasks:
          - task:
              name: Build App server
              command: echo 'Hello World'
      on-error:
        tasks:
          - task:
              name: Build App server
              command: echo 'Hello World'
targets:
  - target:
      name: local
      ip: 192.168.0.1
      username: root
      password: :prompt
      ssh-key: true
```