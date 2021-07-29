#! /usr/bin/env python3
#
# Python module example file
# Miguel A.L. Paraz <mparaz@mparaz.com>
#
# $Id$

import radiusd
from pymysql import connect, cursors

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
        rules_sql = "SELECT `policy`.`policy`, `request_key`, `request_operator`, `request_value` FROM `rules` INNER JOIN `policy` ON `policy`.`policy` = `rules`.`policy` WHERE `policy`.`shortname`=%s;"
        cursor.execute(rules_sql, (__site,))
        rules_results = cursor.fetchall()
        print(rules_results)

        policy_name = ""
        rules_value_match = 0
        payload_dict = dict(p)

        for result in rules_results:
            if result['request_operator'] == "==" and result['request_value'] == payload_dict[result['request_key']]:
                    rules_value_match += 1
            elif result['request_operator'] == "CONTAINS" and result['request_value'] in payload_dict[result['request_key']]:
                    rules_value_match += 1 

            if rules_value_match == len(rules_results):
                policy_name = result['policy']

        if policy_name != "":
            reponses_sql = "SELECT `response_key`, `response_value` FROM `responses` WHERE `policy`=%s"
            cursor.execute(reponses_sql, (policy_name,))
            responses_results = cursor.fetchall()

            reply_list = [(response['response_key'], response['response_value']) for response in responses_results]
            print(tuple(reply_list))

            update_dict = {
                "reply" : (
                    tuple(reply_list)
                )
            }

            return radiusd.RLM_MODULE_OK, update_dict

        print("No policy matches!")

        # Return just OK for the time being, need to figure out what happens when no rules/policy matches
        return radiusd.RLM_MODULE_OK
        