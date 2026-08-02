"""
dags/marketing_email.py

Daily DAG that pulls contactable users from the warehouse and sends
the weekly marketing newsletter.
"""

from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook


default_args = {
    "owner": "growth-team",
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}


def fetch_contactable_users(**context):
    hook = PostgresHook(postgres_conn_id="warehouse")
    rows = hook.get_records(
        """
        select user_id, email
        from user_contact_index
        where is_contactable = true
        """
    )
    users = [{"user_id": r[0], "email": r[1]} for r in rows]
    context["ti"].xcom_push(key="users", value=users)
    return len(users)


def send_newsletter(**context):
    users = context["ti"].xcom_pull(key="users", task_ids="fetch_contactable_users")
    for user in users:
        recipient = user["email"]
        # send_email(recipient, template="weekly_newsletter")
        print(f"Queued newsletter for {recipient}")


with DAG(
    dag_id="marketing_email",
    default_args=default_args,
    schedule_interval="@daily",
    start_date=datetime(2026, 1, 1),
    catchup=False,
) as dag:

    fetch_task = PythonOperator(
        task_id="fetch_contactable_users",
        python_callable=fetch_contactable_users,
    )

    send_task = PythonOperator(
        task_id="send_newsletter",
        python_callable=send_newsletter,
    )

    fetch_task >> send_task
