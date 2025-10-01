#!/bin/bash

# Week 2
# This is a system configuration exercise

# 200626887 is the user's student number

sudo hostnamectl hostname pc200626887 

# Sets the timezone to Toronto

timedatectl set-timezone America/Toronto

# Starts the first existing network time synchronization

sudo timedatectl set-ntp true
