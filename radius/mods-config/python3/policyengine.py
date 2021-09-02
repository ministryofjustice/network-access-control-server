#! /usr/bin/env python3

import radiusd
from pymysql import connect, cursors
from itertools import groupby

def post_auth(p):
    connection = connect(host='{{DB_HOST}}',
                             user='{{DB_USER}}',
                             password='{{DB_PASS}}',
                             database='{{DB_NAME}}',
                             cursorclass=cursors.DictCursor)

    with connection.cursor() as cursor:
        payload_dict = dict(p)
        policy_id = 0
        grouped_rules_by_policy(cursor, payload_dict['Client-Shortname'])

        for _policy_id, rules in groupby(cursor, lambda row: row['policy_id']):
            rules_value_match = 0
            if policy_id != 0:
                break

            for index, rule in enumerate(rules):
                if rule['operator'] == "equals" and rule['value'] == payload_dict.get(rule['request_attribute']):
                    rules_value_match += 1
                elif rule['operator'] == "contains" and rule['value'] in payload_dict.get(rule['request_attribute']):
                    rules_value_match += 1 
                
                if rules_value_match == rule['amount_of_rules']:
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

def grouped_rules_by_policy(cursor, _site):
    rules_sql = "SELECT `policies`.`id` policy_id, `request_attribute`, `operator`, `value`, `rules_count`.`amount_of_rules` " \
            "FROM `rules` " \
            "INNER JOIN `policies` ON `policies`.`id` = `rules`.`policy_id` " \
            "INNER JOIN (SELECT count(*) amount_of_rules, `policy_id` FROM `rules` GROUP BY `policy_id`) `rules_count` ON `rules_count`.`policy_id` = `policies`.`id`" \
            "INNER JOIN policies_sites ps ON ps.policy_id = policies.id " \
            "INNER JOIN sites s ON s.id = ps.site_id " \
            "INNER JOIN clients c ON c.site_id = s.id " \
            "WHERE `c`.`tag`=%s " \
            "ORDER BY `rules_count`.`amount_of_rules` DESC, `policies`.`id`;"
    cursor.execute(rules_sql, (_site,))

def main_policy_responses(cursor, policy_id):
    reponses_sql = "SELECT `response_attribute`, `value` FROM `responses` WHERE `policy_id`=%s"
    cursor.execute(reponses_sql, (policy_id,))
    responses_results = cursor.fetchall()
    return group_responses(responses_results)

def fallback_policy_responses(cursor, _site):
    fallback_sql = "SELECT `response_attribute`, `value` FROM `responses` " \
            "INNER JOIN `policies` ON `policies`.`id` = `responses`.`policy_id` "  \
            "INNER JOIN policies_sites ps ON ps.policy_id = policies.id " \
            "INNER JOIN sites s ON s.id = ps.site_id " \
            "INNER JOIN clients c ON c.site_id = s.id " \
            "WHERE `c`.`tag`=%s AND `policies`.`fallback`=1"
    cursor.execute(fallback_sql, (_site,))
    responses_results = cursor.fetchall()              
    return group_responses(responses_results)

def group_responses(responses_results):
    reply_list = [(response['response_attribute'], response['value']) for response in responses_results]
    return tuple(reply_list)
