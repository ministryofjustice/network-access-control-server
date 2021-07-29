#! /usr/bin/env python3
#
# Python module example file
# Miguel A.L. Paraz <mparaz@mparaz.com>
#
# $Id$

import radiusd
from pymysql import connect, cursors
from itertools import groupby
from operator import itemgetter

def instantiate(p):
    print("*** instantiate ***")
    print(p)

def post_auth(p):
    connection = connect(host='db',
                             user='radius',
                             password='radius',
                             database='radius',
                             cursorclass=cursors.DictCursor)
    __site = 'test_client'

    with connection.cursor() as cursor:
        rules_sql = "SELECT `policy`.`policy_id`, `request_key`, `request_operator`, `request_value` FROM `rules` INNER JOIN `policy` ON `policy`.`policy_id` = `rules`.`policy_id` WHERE `policy`.`shortname`=%s ORDER BY `policy`.`policy_id`;"
        
        policy_id = 0
        rules_value_match = 0
        payload_dict = dict(p)
        cursor.execute(rules_sql, (__site,))

        for policy_id, rules in groupby(cursor, lambda row: row['policy_id']):
            for rule in rules:
                if rule['request_operator'] == "==" and rule['request_value'] == payload_dict[rule['request_key']]:
                        rules_value_match += 1
                elif rule['request_operator'] == "CONTAINS" and rule['request_value'] in payload_dict[rule['request_key']]:
                        rules_value_match += 1 
                if rules_value_match == len(list(rules)):
                    policy_id = rule['policy_id']

        if policy_id != 0:
            reponses_sql = "SELECT `response_key`, `response_value` FROM `responses` WHERE `policy_id`=%s"
            cursor.execute(reponses_sql, (policy_id,))
            responses_results = cursor.fetchall()

            reply_list = [(response['response_key'], response['response_value']) for response in responses_results]

            update_dict = {
                "reply" : (
                    tuple(reply_list)
                )
            }

            return radiusd.RLM_MODULE_OK, update_dict

        print("No policy matches!")

        # Return just OK for the time being, need to figure out what happens when no rules/policy matches
        return radiusd.RLM_MODULE_OK
        