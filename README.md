## Introduction

When brewing beer, controlling the temperature of fermentation can help control the types of flavors produced. 
I had an old chest freezer, which I had previously used with an arduino-based temperature control system. This system 
wasn't connected to the internet though. This repository uses a 
[Particle Photon](https://www.particle.io/products/hardware/photon-wifi-dev-kit) to connect the temperature control 
system to the internet.

## Hardware

Any of the particle.io microprocessors should work with this code. The firmware used to control the board is avialble under utilities/firmware.txt and can be uploaded to your microprocessor though particle's website. I used Adafruit's [tutorial](https://learn.adafruit.com/thermistor/using-a-thermistor) to setup the thermisters.

## Server Setup

