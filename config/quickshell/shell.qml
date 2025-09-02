//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

// Adjust this to make the shell smaller or larger
//@ pragma Env QT_SCALE_FACTOR=1

import Quickshell
import QtQuick
import QtQuick.Window

import "./modules/bar/"

ShellRoot {
    id: root

    // Bar
    LazyLoader {
        active: true
        component: Bar {}
    }
}