[![Build Status](https://travis-ci.org/leanprover/macports.svg?branch=master)](https://travis-ci.org/leanprover/macports)

Macports Repository for Lean
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

 - run `update.sh`
