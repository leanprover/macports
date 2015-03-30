Macports Repository for Lean [![Build Status](https://travis-ci.org/leanprover/macports.svg?branch=master)](https://travis-ci.org/leanprover/macports)
============================

How to Use
----------

1. Edit `/opt/local/etc/macports/sources.conf` (admin privilege required) and add the following line before the default source (one starting with `rsync`):

    ```
https://leanprover.github.io/macports/ports.tar
    ```

2. Sync Macports:

    ```bash
sudo port -v sync
    ```

3. Install Lean:

    ```bash
sudo port install lean
    ```

**Installation is in** `/opt/local`.


How to Maintain
---------------
 - Follow the above installation instructions. `update.sh` script assumes that there is a pre-installed macport version of Lean and tries to upgrade it to the latest version.
 - Run `update.sh`, if necessary use `-f` option to force upgrade.
