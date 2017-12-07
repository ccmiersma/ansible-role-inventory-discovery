-- Import this into an empty SQLite database with `sqlite3 inventory.db < schema.sql` --

BEGIN TRANSACTION;
CREATE TABLE "machines" (
	`machine_id`	TEXT NOT NULL,
	`ip_address`	TEXT NOT NULL,
	`hostname`	TEXT NOT NULL,
	`domain`	TEXT,
	`fqdn`	        TEXT,
	`description`   TEXT,
	`dsa_key`	TEXT NOT NULL DEFAULT 'NA',
	`rsa_key`	TEXT NOT NULL DEFAULT 'NA',
	`ecdsa_key`	TEXT NOT NULL DEFAULT 'NA',
	`ed25519_key`	TEXT NOT NULL DEFAULT 'NA',
	PRIMARY KEY(`machine_id`,`ip_address`,`hostname`)
);

CREATE TABLE "ip_addresses" (
	`ip_address`	TEXT NOT NULL,
	`fqdn`          TEXT,
	`description`   TEXT,
	`dsa_key`	TEXT NOT NULL DEFAULT 'NA',
	`rsa_key`	TEXT NOT NULL DEFAULT 'NA',
	`ecdsa_key`	TEXT NOT NULL DEFAULT 'NA',
	`ed25519_key`	TEXT NOT NULL DEFAULT 'NA',
	PRIMARY KEY(`ip_address`)
);

CREATE TABLE "host_names" (
	`fqdn`	TEXT NOT NULL,
	`description`	TEXT,
	`ip_address`    TEXT,
	`dsa_key`	TEXT NOT NULL DEFAULT 'NA',
	`rsa_key`	TEXT NOT NULL DEFAULT 'NA',
	`ecdsa_key`	TEXT NOT NULL DEFAULT 'NA',
	`ed25519_key`	TEXT NOT NULL DEFAULT 'NA',
	PRIMARY KEY(`fqdn`)
);

CREATE VIEW "machine_ip_map" AS select machines.machine_id as machine_id, ip_addresses.ip_address as ip_address
from machines, ip_addresses
where machines.dsa_key=ip_addresses.dsa_key
and machines.rsa_key=ip_addresses.rsa_key
and machines.ecdsa_key=ip_addresses.ecdsa_key
and machines.ed25519_key=ip_addresses.ed25519_key;

CREATE VIEW "machine_fqdn_map" AS select machines.machine_id as machine_id, host_names.fqdn as fqdn
from machines, host_names
where machines.dsa_key=host_names.dsa_key
and machines.rsa_key=host_names.rsa_key
and machines.ecdsa_key=host_names.ecdsa_key
and machines.ed25519_key=host_names.ed25519_key;

CREATE VIEW "fqdn_ip_address_map" AS select host_names.fqdn as fqdn, ip_addresses.ip_address as ip_address
from host_names, ip_addresses
where host_names.dsa_key=ip_addresses.dsa_key
and host_names.rsa_key=ip_addresses.rsa_key
and host_names.ecdsa_key=ip_addresses.ecdsa_key
and host_names.ed25519_key=ip_addresses.ed25519_key;

CREATE VIEW "secondary_host_names" AS select host_names.fqdn as fqdn
from host_names
left join machines
on machines.fqdn = host_names.fqdn where machine_id is NULL;

CREATE VIEW "secondary_ip_addresses" AS select ip_addresses.ip_address as ip_address
from ip_addresses
left join machines
on machines.ip_address = ip_addresses.ip_address where machine_id is NULL;

CREATE VIEW "machine_addresses" AS select machine_id,
	group_concat(ip_address) as addresses
	from machine_ip_map
	group by machine_id;
	
CREATE VIEW "machine_fqdns" AS select machine_id,
	group_concat(fqdn) as fqdns
	from machine_fqdn_map
	group by machine_id;
	
CREATE VIEW "ssh_keyscan_list" AS
select machine_addresses.machine_id as machine_id,
	machine_addresses.addresses as addresses,
	machine_fqdns.fqdns as fqdns
	from machine_addresses
	join machine_fqdns
	on machine_addresses.machine_id = machine_fqdns.machine_id;

CREATE VIEW "hosts_file" AS select machine_ip_map.ip_address as ip_address,
machines.fqdn as fqdn,
machines.hostname as hostname,
machine_fqdns.fqdns as fqdns
from machine_ip_map
join machines on machine_ip_map.machine_id = machines.machine_id
join machine_fqdns on machine_ip_map.machine_id = machine_fqdns.machine_id;

COMMIT;
