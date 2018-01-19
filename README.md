# Ski
### A automation framework made for portability

Features:

- Interactive mode
- Multiple projects
- Multiple Pipelines
- Fail fast


Installation:

`gem install ski`

Example setup:

1. Create a `.ski/` directory in your project.

2. Add a file `your-project.yml` to `.ski/`

``` yaml
title: Bonumco
description: Hello World
pipelines:
  build:
    description: Build local docker images
    fail-fast: false
    interactive: false
    target: :local
    workdir: .
    tasks:
      show-all-local-files:
        description: Show all local files
        command: ls .
      show-space-used:
        description: Show the whole space
        command: du -sch .
      sleep-5:
        description: Ping google exactly one time
        command: sleep 5
      check-processes:
        description: Check processes running of port 3000
        command: lsof -i :3000
      check-ruby-version:
        description: Check ruby version
        command: ruby -v
    then:
      greet:
        description: Wish a happy day
        command: echo 'Hey dear, the deployment was successfull. Have a nice day! :)'
    catch:
      rollback:
        description: Rolling back actions
        command: echo 'Oooops, something went wrong!'
  deployment:
    description: Deploy things
    interactive: true
    fail-fast: true
    target: :local
    tasks:
      deploy-to-production:
        description: Deploy to production
        command: echo 'Bam bam production!'
    then:
      greet:
        description: Wish a happy day
        command: echo 'Hey dear, the deployment was successfull. Have a nice day! :)'
    catch:
      greet:
        description: Wish a happy day
        command: echo 'Hey dear, the deployment was successfull. Have a nice day! :)'
targets:
  local:
    ip: 192.168.0.1
    username: root
    password: :prompt
    ssh-key: true
```

3. Run:
`ski -P your-project -p build`

# Todo

* Add functionality for remote tasks
* Add functionality for prompts (like configurable 'are you sure' etc)
* Add functionality for variables (:prompts, :my_var etc)
* Make use of pipeline targets in code
* Add functionality for secrets and ssh keys (stored somewhere on a safe place not in your project dir)
* Improve command line (ski run bonumco/deployment or something..)