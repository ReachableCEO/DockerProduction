# K8S at TSYS

## Introduction 

In the near future (by end of 2024) we will need to spin our on premise heavy compute facility back online to run K8S.

This file is where we will document what that looks like. Mostly it will be used by R&D for the entire SDLC. 

## Ecosystem

Probably 

- https://github.com/spinnaker/spinnaker

as the overall orchestration layer. 

Various K8S distributions have emerged. 

We are (as of 10/12) a ways out from needing to worry about this in the critical path. We can go a long way with cloudron / cosmos / coolify and off the shelf docker containers (and even making some of our own containers for the tsys line of business application web sites). 