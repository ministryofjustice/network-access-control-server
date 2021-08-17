#! /usr/bin/env python3

import radiusd
from pymysql import connect, cursors
from itertools import groupby

def post_auth(p):
    connection = connect(host='db',
                             user='radius',
                             password='radius',
                             database='radius',
                             cursorclass=cursors.DictCursor)

    with connection.cursor() as cursor:
        payload_dict = dict(p)
        _site = payload_dict['Client-Shortname']
        
        rules_sql = "SELECT `policy`.`policy_id`, `request_key`, `request_operator`, `request_value` FROM `rules` INNER JOIN `policy` ON `policy`.`policy_id` = `rules`.`policy_id` WHERE `policy`.`shortname`=%s ORDER BY `policy`.`policy_id`;"
        
        policy_id = 0
        cursor.execute(rules_sql, (_site,))

        for _policy_id, rules in groupby(cursor, lambda row: row['policy_id']):
            rules_value_match = 0
            for rule in rules:
                if rule['request_operator'] == "==" and rule['request_value'] == payload_dict[rule['request_key']]:
                        rules_value_match += 1
                elif rule['request_operator'] == "CONTAINS" and rule['request_value'] in payload_dict[rule['request_key']]:
                        rules_value_match += 1 

                if rules_value_match == len(list(rules)):
                    policy_id = rule['policy_id']

        update_dict = {}
        reply_list = ()
        if policy_id != 0:
            reply_list = main_policy(cursor, policy_id)
        else:
            reply_list = fallback_policy(cursor, policy_id)

        update_dict = {
            "reply" : (
                tuple(reply_list)
            )
        }
            
        connection.close()
        return radiusd.RLM_MODULE_OK, update_dict

def main_policy(cursor, policy_id):
    reponses_sql = "SELECT `response_key`, `response_value` FROM `responses` WHERE `policy_id`=%s"
    cursor.execute(reponses_sql, (policy_id,))
    responses_results = cursor.fetchall()
    return group_replies(responses_results)

def fallback_policy(cursor, policy_id):
    fallback_sql = "SELECT `response_key`, `response_value` FROM `responses` INNER JOIN `policy` ON `policy`.`policy_id` = `responses`.`policy_id` WHERE `policy`.`shortname`=%s AND `policy`.`fallback`=1"
    cursor.execute(fallback_sql, (policy_id,))
    responses_results = cursor.fetchall()              
    return group_replies(responses_results)

def group_replies(responses_results):
    reply_list = [(response['response_key'], response['response_value']) for response in responses_results]
    return reply_list
