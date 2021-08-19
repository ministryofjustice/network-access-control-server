
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
