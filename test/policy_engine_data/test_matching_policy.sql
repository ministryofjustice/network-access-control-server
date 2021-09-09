SET FOREIGN_KEY_CHECKS = 0; 
truncate table rules;
truncate table responses;
truncate table site_policies;
truncate table policies;
truncate table sites;
truncate table clients;
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO `sites` (`id`, `name`, `created_at`, `updated_at`)
VALUES
	(1,'Probation Site 1',now(),now());

INSERT INTO `clients` (`id`, `tag`, `shared_secret`, `ip_range`, `site_id`, `created_at`, `updated_at`)
VALUES
	(1,'test_client','test','10.5.0.6/32',1,now(),now());

INSERT INTO `policies` (`id`, `name`, `description`, `created_at`, `updated_at`, `fallback`)
VALUES
	(1,'Test Matching Policy','Test Matching Policy',now(),now(),0),
	(2,'Fallback','Some fallback policy',now(),now(),1);

INSERT INTO `site_policies` (`policy_id`, `site_id`, `created_at`, `updated_at`)
VALUES
	(1,1, now(), now()),
	(2,1, now(), now());

INSERT INTO `responses` (`id`, `response_attribute`, `value`, `created_at`, `updated_at`, `mac_authentication_bypass_id`, `policy_id`)
VALUES
	(1,'Tunnel-Type','VLAN',now(),now(),NULL,1),
	(2,'Tunnel-Medium-Type','IEEE-802',now(),now(),NULL,1),
	(3,'Tunnel-Private-Group-Id','777',now(),now(),NULL,1),
	(4,'Reply-Message','Fallback Policy',now(),now(),NULL,2);

INSERT INTO `rules` (`id`, `operator`, `value`, `policy_id`, `request_attribute`, `created_at`, `updated_at`)
VALUES
	(1,'equals','user@example.org',1,'User-Name',now(),now()),
	(2,'equals','127.0.0.1',1,'NAS-IP-Address',now(),now()),
	(5,'equals','Wireless-802.11',1,'NAS-Port-Type',now(),now());
