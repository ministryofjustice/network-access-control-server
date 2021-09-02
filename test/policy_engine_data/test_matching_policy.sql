-- SET FOREIGN_KEY_CHECKS = 0; 
-- truncate table responses;
-- truncate table rules;
-- truncate table policies;
-- truncate table clients;
-- truncate table sites;
-- truncate table policies_sites;
-- SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO `sites` (`id`, `name`, `created_at`, `updated_at`)
VALUES
	(1,'Probation Site 1','2021-09-01 15:39:04.000000','2021-09-01 15:42:49.611521');

INSERT INTO `clients` (`id`, `tag`, `shared_secret`, `ip_range`, `site_id`, `created_at`, `updated_at`)
VALUES
	(1,'test_client','test','10.5.0.6/32',1,'2021-09-01 15:43:21.146108','2021-09-01 15:43:21.146108');

INSERT INTO `policies` (`id`, `name`, `description`, `created_at`, `updated_at`, `fallback`)
VALUES
	(1,'Test Matching Policy','Test Matching Policy','2021-09-01 15:44:07.702484','2021-09-01 15:44:07.702484',0),
	(2,'Fallback','Some fallback policy','2021-09-01 15:49:12.352961','2021-09-01 15:49:12.352961',1);

INSERT INTO `policies_sites` (`policy_id`, `site_id`)
VALUES
	(1,1),
	(2,1);

INSERT INTO `responses` (`id`, `response_attribute`, `value`, `created_at`, `updated_at`, `mac_authentication_bypass_id`, `policy_id`)
VALUES
	(1,'Tunnel-Type','VLAN','2021-09-01 15:46:58.354468','2021-09-01 15:48:23.253863',NULL,1),
	(2,'Tunnel-Medium-Type','IEEE-802','2021-09-01 15:47:58.786005','2021-09-01 15:47:58.786005',NULL,1),
	(3,'Tunnel-Private-Group-Id','777','2021-09-01 15:48:12.971011','2021-09-01 15:48:12.971011',NULL,1),
	(4,'User-Name','failure','2021-09-01 15:49:26.559492','2021-09-01 15:49:26.559492',NULL,2);

INSERT INTO `rules` (`id`, `operator`, `value`, `policy_id`, `request_attribute`, `created_at`, `updated_at`)
VALUES
	(1,'equals','user@example.com',1,'User-Name','2021-09-01 15:44:24.523461','2021-09-01 15:44:24.523461'),
	(2,'equals','127.0.0.1',1,'NAS-IP-Address','2021-09-01 15:44:42.275498','2021-09-01 15:44:42.275498'),
	(5,'equals','Wireless-802.11',1,'NAS-Port-Type','2021-09-01 15:45:41.656111','2021-09-01 15:45:41.656111');
