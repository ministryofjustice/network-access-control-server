#! /usr/bin/env python3

import os
import radiusd
from pymysql import connect, cursors
from itertools import groupby

def post_auth(p):
    connection = connect(host=os.environ.get('DB_HOST'),
                             user=os.environ.get('DB_USER'),
                             password=os.environ.get('DB_PASS'),
                             database=os.environ.get('DB_NAME'),
                             cursorclass=cursors.DictCursor)

    with connection.cursor() as cursor:
        payload_dict = dict(p)
        if payload_dict.get('EAP-Type') != "TLS":
            return

        print(payload_dict.get('Client-Shortname'), "POLICY ENGINE: Request Attributes -", payload_dict)
        policy_id = 0
        grouped_rules_by_policy(cursor, payload_dict['Client-Shortname'])

        for _policy_id, rules in groupby(cursor, lambda row: row['policy_id']):
            rules_value_match = 0
            if policy_id != 0:
                break

            for index, rule in enumerate(rules):
                if payload_dict.get(rule['request_attribute']) == None:
                    continue

                if rule['operator'] == "equals" and rule['value'] == payload_dict.get(rule['request_attribute']):
                    rules_value_match += 1
                elif rule['operator'] == "contains" and rule['value'] in payload_dict.get(rule['request_attribute']):
                    rules_value_match += 1 
                
                if rules_value_match == rule['rule_count']:
                    policy_id = rule['policy_id']
                    print(payload_dict.get('Client-Shortname'), "POLICY ENGINE: Policy Matched -", rule['policy_name'])

        reply_list = ()
        if policy_id != 0:
            reply_list = main_policy_responses(cursor, policy_id)
        else:
            reply_list = fallback_policy_responses(cursor, payload_dict['Client-Shortname'])

        print(payload_dict.get('Client-Shortname'), "POLICY ENGINE: Policy Response -", tuple(reply_list))

        reply_payload = { "reply" : (reply_list) }
        result = radiusd.RLM_MODULE_OK

        for key, value in reply_list:
            if key == "Post-Auth-Type" and value == "Reject":
                result = radiusd.RLM_MODULE_FAIL

        connection.close()
        return result, reply_payload

def grouped_rules_by_policy(cursor, _site):
    rules_sql = "SELECT `policies`.`id` policy_id, `policies`.`name` policy_name, `request_attribute`, `operator`, `value`, `policies`.`rule_count` " \
            "FROM `rules` " \
            "INNER JOIN `policies` ON `policies`.`id` = `rules`.`policy_id` " \
            "INNER JOIN site_policies sp ON sp.policy_id = policies.id " \
            "INNER JOIN sites s ON s.id = sp.site_id " \
            "WHERE `s`.`tag`=%s " \
            "ORDER BY sp.priority;"
    cursor.execute(rules_sql, (_site,))

def main_policy_responses(cursor, policy_id):
    reponses_sql = "SELECT `response_attribute`, `value` FROM `responses` WHERE `policy_id`=%s"
    cursor.execute(reponses_sql, (policy_id,))
    responses_results = cursor.fetchall()
    return group_responses(responses_results)

def fallback_policy_responses(cursor, _site):
    fallback_sql = "SELECT DISTINCT(`response_attribute`), `value` FROM `responses` " \
            "INNER JOIN `policies` ON `policies`.`id` = `responses`.`policy_id` "  \
            "INNER JOIN site_policies sp ON sp.policy_id = policies.id " \
            "INNER JOIN sites s ON s.id = sp.site_id " \
            "WHERE `s`.`tag`=%s AND `policies`.`fallback`=1"
    cursor.execute(fallback_sql, (_site,))
    responses_results = cursor.fetchall()              
    return group_responses(responses_results)

def group_responses(responses_results):
    reply_list = [(response['response_attribute'], response['value']) for response in responses_results]
    return tuple(reply_list)
