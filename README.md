inventory-discovery
===================

This role is does not make any changes on target hosts. It only gathers information from hosts using the ansible setup module and DNS queries. This information is stored in a SQLite database, which can be used to generate a static inventory file, a `/etc/hosts` file, or a list of IP addresses and host names for `ssh-keyscan`. Scripts for generating a basic `/etc/hosts` file and a key-scan file are included in the `files` directory.

Requirements
------------

This role requires that `sqlite3` be available on localhost. In addition, before running the role, a database should be created with a command such as `sqlite3 tests/inventory.db < files/schema.sql` using the schema.sql file in the `files` directory. By default, it should be located in the playbook directory, but this can be adjusted with a role variable.

Role Variables
--------------

The variable `inventory_sqlite_db` is defined in the defaults as follows:

```
---
# defaults file for inventory-discovery

inventory_sqlite_db: "{{ playbook_dir }}/inventory.db"
```

This defines the location of the inventory database to which the role will save any data collected.

Dependencies
------------

This role is independent of other roles, but it does require `sqlite3`.

Example Playbook
----------------

```
---

- hosts: all
  strategy: free
  remote_user: root
  roles:
    - { role: inventory-discovery, inventory_sqlite_db: /tmp/inventory.db }
```

License
-------

BSD

Author Information
------------------

Chrisopher Miersma
