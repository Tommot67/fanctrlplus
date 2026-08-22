# **FanCtrl Plus + OpenFAN**

**FanCtrl Plus + OpenFAN** is an Unraid plugin maintained by **Tommot67** that provides automatic fan control based on the temperatures of HDDs, NVMe drives, Unassigned Devices, and optionally the CPU.

It supports local Linux PWM controllers as well as OpenFAN controllers through
their HTTP APIs: OpenFAN Controller (channels 0–9) and OpenFAN Micro (one fan,
channel 0).

## Upstream attribution

This project is a fork of [FanCtrl Plus by ck9393](https://github.com/ck9393/fanctrlplus).
It retains the original local PWM/hwmon functionality and adds OpenFAN and
OpenFAN Micro support. Please report fork-specific issues to this repository.
Each fan configuration can monitor specific drives or the CPU, define a temperature range, and scale fan speed automatically using a linear control algorithm.  
Configuration is done through a user-friendly interface, with custom thresholds, intervals, and labels available per fan.

## ✨ Features

- Full-featured Web UI for configuration and monitoring
- Supports temporary fan configuration with safe validation and custom naming
- Automatically starts with the Unraid array for hands-free operation
- Set custom thresholds and intervals per fan
- Control multiple PWM fans independently
- Monitor temps from array disks, NVMe, unassigned devices, and optionally the CPU
- Uses a linear control algorithm to smoothly adjust fan speed (PWM) based on the current temperature (disk or CPU) between your defined low/high values
- Identify and label PWM controllers to match physical fans easily
- Control OpenFAN and OpenFAN Micro fans without a kernel module
- Dashboard tile and system integration
- Optional FCP Airflow Dashboard tile, similar to Unraid’s built-in Airflow tile but enhanced with support for custom fan labels
- Drag and drop fan configuration boxes to reorder them as you like. The new order is saved and reflected in both the UI and Dashboard.

---

## 🔧 Manual Installation

Install **FanCtrl Plus + OpenFAN** from this fork's plugin URL after its release package has been published.

Support / Issues
- https://github.com/Tommot67/fanctrlplus/issues
