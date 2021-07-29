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
        for result in rules_results:
            for p_key, p_value in p:
                if p_key == result['request_key'] and p_value == result['request_value']:
                    rules_value_match += 1
                    print(f"{p_key} equals the key {result['request_key']}")
                    print(f"{p_value} equals the value {result['request_value']}")
                    if rules_value_match == len(rules_results):
                        policy_name = result['policy']

        if policy_name != "":
            reponses_sql = "SELECT `response_key`, `response_value` FROM `responses` WHERE `policy`=%s"
            cursor.execute(reponses_sql, (policy_name,))
            responses_results = cursor.fetchall()
            print(responses_results)

        print("-------")
        
    return radiusd.RLM_MODULE_OK