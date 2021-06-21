CREATE TABLE lookup (
  vlan varchar(64) NOT NULL default '',
  common_name varchar(64) NOT NULL default '',
  mac varchar(64) NOT NULL default '',
  remote_ip varchar(64) NOT NULL default ''
) ENGINE = INNODB;

 CREATE TABLE radcheck (
   id int(11) unsigned NOT NULL auto_increment,
   username varchar(64) NOT NULL default '',
   attribute varchar(64)  NOT NULL default '',
   op char(2) NOT NULL DEFAULT '==',
   value varchar(253) NOT NULL default '',
   PRIMARY KEY  (id),
   KEY username (username(32))
 );

 #
 # Table structure for table 'radgroupcheck'
 #

 CREATE TABLE radgroupcheck (
   id int(11) unsigned NOT NULL auto_increment,
   groupname varchar(64) NOT NULL default '',
   attribute varchar(64)  NOT NULL default '',
   op char(2) NOT NULL DEFAULT '==',
   value varchar(253)  NOT NULL default '',
   PRIMARY KEY  (id),
   KEY groupname (groupname(32))
 );

CREATE TABLE radgroupreply (
  id int(11) unsigned NOT NULL auto_increment,
  groupname varchar(64) NOT NULL default '',
  attribute varchar(64)  NOT NULL default '',
  op char(2) NOT NULL DEFAULT '=',
  value varchar(253)  NOT NULL default '',
  PRIMARY KEY  (id),
  KEY groupname (groupname(32))
);

CREATE TABLE radreply (
  id int(11) unsigned NOT NULL auto_increment,
  username varchar(64) NOT NULL default '',
  attribute varchar(64) NOT NULL default '',
  op char(2) NOT NULL DEFAULT '=',
  value varchar(253) NOT NULL default '',
  PRIMARY KEY  (id),
  KEY username (username(32))
);


CREATE TABLE radusergroup (
  id int(11) unsigned NOT NULL auto_increment,
  username varchar(64) NOT NULL default '',
  groupname varchar(64) NOT NULL default '',
  priority int(11) NOT NULL default '1',
  PRIMARY KEY  (id),
  KEY username (username(32))
);

 CREATE TABLE radpostauth (
   id int(11) NOT NULL auto_increment,
   username varchar(64) NOT NULL default '',
   pass varchar(64) NOT NULL default '',
   reply varchar(32) NOT NULL default '',
   authdate timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
   PRIMARY KEY  (id)
 ) ENGINE = INNODB;

 #
 # Table structure for table 'nas'
 #
 CREATE TABLE nas (
   id int(10) NOT NULL auto_increment,
   nasname varchar(128) NOT NULL,
   shortname varchar(32),
   type varchar(30) DEFAULT 'other',
   ports int(5),
   secret varchar(60) DEFAULT 'secret' NOT NULL,
   server varchar(64),
   community varchar(50),
   description varchar(200) DEFAULT 'RADIUS Client',
   PRIMARY KEY (id),
   KEY nasname (nasname)
 );

insert into radgroupreply (groupname, attribute, op, value) values ('VLAN#', 'Tunnel-Type', '=', '13');
insert into radgroupreply (groupname, attribute, op, value) values ('VLAN#', 'Tunnel-Medium-Type', '=', '6');
insert into radgroupreply (groupname, attribute, op, value) values ('VLAN#', 'Tunnel-Private-Group-Id', '=', 'VLAN tag #');
 
INSERT INTO radusergroup (username, groupname, priority) VALUES ('DEFAULT', 'VLAN#FORDEFAULTVLAN', '10');
insert into radgroupcheck (groupname, attribute, op, value) values ('VLAN#FORDEFAULTVLAN', 'Auth-Type', ':=', 'Accept');
 
INSERT INTO radcheck (username, attribute, op, value) VALUES('MAC', 'Cleartext-Password', ':=', 'MAC');
insert into radusergroup (username, groupname, priority) values ('MAC', 'VLAN#', 10);
