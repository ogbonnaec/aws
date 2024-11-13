import boto3

def lambda_handler(event, context):
    ec2_client = boto3.client('ec2')

    action = event['action']
    tag_key = event['tag_key']
    tag_value = event['tag_value']
 
    stop_instance = action == 'stop'
    instance_state = 'stopped' if not stop_instance else 'running'
    
    response = ec2_client.describe_instances(
        Filters=[
            {
                'Name': 'tag:' + tag_key,
                'Values': [tag_value]
            },
            {
                'Name': 'instance-state-name',
                'Values': [instance_state]
            }
        ]
    )
    
    instance_ids = []

    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            instance_ids.append(instance['InstanceId'])

    if action == 'start':
        ec2_client.start_instances(InstanceIds=instance_ids)
        print(f'Started instances: {", ".join(instance_ids)}')
    elif action == 'stop':
        ec2_client.stop_instances(InstanceIds=instance_ids)
        print(f'Stopped instances: {", ".join(instance_ids)}')
    else:
        print('Invalid action specified.')

