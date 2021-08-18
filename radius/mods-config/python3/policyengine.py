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
        policy_id = 0

        rules_sql = "SELECT `policy`.`policy_id`, `request_key`, `request_operator`, `request_value` " \
            "FROM `rules` " \
            "INNER JOIN `policy` ON `policy`.`policy_id` = `rules`.`policy_id` " \
            "INNER JOIN (SELECT count(*) amount_of_rules, `policy_id` FROM `rules` GROUP BY `policy_id`) `rules_count` ON `rules_count`.`policy_id` = `policy`.`policy_id`" \
            "WHERE `policy`.`shortname`=%s " \
            "ORDER BY `rules_count`.`amount_of_rules` DESC, `policy`.`policy_id`;"
        cursor.execute(rules_sql, (payload_dict['Client-Shortname'],))

        for _policy_id, rules in groupby(cursor, lambda row: row['policy_id']):
            rules_value_match = 0
            for rule in rules:
                if rule['request_operator'] == "==" and rule['request_value'] == payload_dict[rule['request_key']]:
                    rules_value_match += 1
                elif rule['request_operator'] == "CONTAINS" and rule['request_value'] in payload_dict[rule['request_key']]:
                    rules_value_match += 1 

                if rules_value_match == len(list(rules)):
                    policy_id = rule['policy_id']

        reply_list = ()
        if policy_id != 0:
            reply_list = main_policy_responses(cursor, policy_id)
        else:
            reply_list = fallback_policy_responses(cursor, policy_id)

        update_dict = {
            "reply" : (
                reply_list
            )
        }
            
        connection.close()
        return radiusd.RLM_MODULE_OK, update_dict

def main_policy_responses(cursor, policy_id):
    reponses_sql = "SELECT `response_key`, `response_value` FROM `responses` WHERE `policy_id`=%s"
    cursor.execute(reponses_sql, (policy_id,))
    responses_results = cursor.fetchall()
    return group_responses(responses_results)

def fallback_policy_responses(cursor, policy_id):
    fallback_sql = "SELECT `response_key`, `response_value` FROM `responses` INNER JOIN `policy` ON `policy`.`policy_id` = `responses`.`policy_id` WHERE `policy`.`shortname`=%s AND `policy`.`fallback`=1"
    cursor.execute(fallback_sql, (policy_id,))
    responses_results = cursor.fetchall()              
    return group_responses(responses_results)

def group_responses(responses_results):
    reply_list = [(response['response_key'], response['response_value']) for response in responses_results]
    return tuple(reply_list)
