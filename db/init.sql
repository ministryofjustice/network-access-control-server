
CREATE TABLE `responses` (
  `response_key` varchar(100) DEFAULT NULL,
  `response_value` varchar(100) DEFAULT NULL,
  `policy_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `rules` (
  `request_key` varchar(100) DEFAULT NULL,
  `request_operator` varchar(100) DEFAULT NULL,
  `request_value` varchar(100) DEFAULT NULL,
  `policy_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `policy` (
  `policy` varchar(100) DEFAULT NULL,
  `shortname` varchar(100) DEFAULT NULL,
  `policy_id` int(11) DEFAULT NULL,
  `fallback` bit DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO `policy` (policy, shortname, policy_id, fallback) 
VALUES('test-policy-name', 'test_client', 1, 0);

INSERT INTO `policy` (policy, shortname, policy_id, fallback)
VALUES('fallback-policy', 'test_client', 2, 1);

INSERT INTO radius.responses(response_key, response_value, policy_id)
VALUES('Tunnel-Type', 'VLAN', 1);
INSERT INTO radius.responses(response_key, response_value, policy_id)
VALUES('Tunnel-Medium-Type', 'IEEE-802', 1);
INSERT INTO radius.responses(response_key, response_value, policy_id)
VALUES('Reply-Message', 'The VLAN is being assigned by Python!', 1);
INSERT INTO radius.responses(response_key, response_value, policy_id)
VALUES('Tunnel-Private-Group-Id', '1234', 1);
INSERT INTO radius.responses(response_key, response_value, policy_id)
VALUES('Reply-Message', 'This is the fallback', 2);


INSERT INTO radius.rules(request_key, request_operator, request_value, policy_id)
VALUES('User-Name', '==', 'MoJ Auth Client', 1);
INSERT INTO radius.rules(request_key, request_operator, request_value, policy_id)
VALUES('Service-Type', '==', 'Framed-User', 1);