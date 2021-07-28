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

def authorize(p):
    print("*** authorize ***")
    print("")
    radiusd.radlog(radiusd.L_INFO, "*** log call in authorize ***")
    print("")
    print(p)
    print("")
    print(radiusd.config)
    print("")

    connection = connect(host='db',
                             user='radius',
                             password='radius',
                             database='radius',
                             cursorclass=cursors.DictCursor)

    with connection.cursor() as cursor:
        sql = "SELECT `request_key`, `request_operator`, `request_value` FROM `rules` WHERE `shortname`=%s"
        cursor.execute(sql, ('test_client',))
        results = cursor.fetchall()
        print(results)

        where_clauses = []

        for result in results:
            clause = f" `{result['request_key']}` {result['request_operator']} '{result['request_value']}'"

            where_clauses.append(clause)

        separator = " and "
        sql_results = separator.join(where_clauses)
        final_result = f"SELECT response_key, response_value FROM responses where {sql_results} and shortname = 'test_client'"

        print("-------")
        print(final_result)

    return radiusd.RLM_MODULE_OK