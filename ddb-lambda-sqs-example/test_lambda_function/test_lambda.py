import json

import boto3
from tabulate import tabulate


def lambda_handler(event, context):
    # Determine if running in LocalStack or AWS
    
    # Initialize AWS clients
    dynamodb = boto3.resource('dynamodb', region_name="us-west-2")
    lambda_client = boto3.client('lambda', region_name="us-west-2")
    
    # Define table name
    table_name = "testing-ddb-table"
    table = dynamodb.Table(table_name)
    
    # Scan DynamoDB table
    print(f"Scanning DynamoDB table: {table_name}")
    scan_response = table.scan()
    items = scan_response.get('Items', [])
    
    # Continue scanning if we have more items (pagination)
    while 'LastEvaluatedKey' in scan_response:
        scan_response = table.scan(ExclusiveStartKey=scan_response['LastEvaluatedKey'])
        items.extend(scan_response.get('Items', []))
    
    # Print items in tabular format
    if items:
        print("\n=== DynamoDB Table Contents ===")
        headers = list(items[0].keys())
        rows = [[item.get(header, '') for header in headers] for item in items]
        print(tabulate(rows, headers=headers, tablefmt="grid"))
    else:
        print("No items found in the DynamoDB table.")
    
    # Count resources by type
    resource_counts = {}
    for item in items:
        resource_type = item.get('resource_type', 'UNKNOWN')
        if resource_type not in resource_counts:
            resource_counts[resource_type] = 0
        resource_counts[resource_type] += 1
    
    # Get all lambda functions
    lambda_functions = []
    try:
        lambda_paginator = lambda_client.get_paginator('list_functions')
        for page in lambda_paginator.paginate():
            lambda_functions.extend(page['Functions'])
    except Exception as e:
        print(f"Error listing Lambda functions: {e}")
    
    # Check for event source mappings
    event_source_mappings = []
    mappings_by_function = {}
    try:
        mapping_paginator = lambda_client.get_paginator('list_event_source_mappings')
        for page in mapping_paginator.paginate():
            event_source_mappings.extend(page['EventSourceMappings'])
            
        # Organize mappings by function name
        for mapping in event_source_mappings:
            function_name = mapping['FunctionArn'].split(':')[-1]
            if function_name not in mappings_by_function:
                mappings_by_function[function_name] = []
            mappings_by_function[function_name].append(mapping)
    except Exception as e:
        print(f"Error listing event source mappings: {e}")
    
    # Print items with event source mappings
    print("\n=== Items with Event Source Mappings ===")
    items_with_mappings = []
    for item in items:
        if item.get('resource_type') == 'AWS_LAMBDA_FUNCTION':
            function_name = item.get('resource_name', '')
            has_mapping = function_name in mappings_by_function
            if has_mapping:
                items_with_mappings.append({
                    'group_id': item.get('group_id', ''),
                    'resource_type': item.get('resource_type', ''),
                    'resource_name': function_name,
                    'mappings_count': len(mappings_by_function.get(function_name, []))
                })
    
    if items_with_mappings:
        headers = ['group_id', 'resource_type', 'resource_name', 'mappings_count']
        rows = [[item.get(header, '') for header in headers] for item in items_with_mappings]
        print(tabulate(rows, headers=headers, tablefmt="grid"))
    else:
        print("No items found with event source mappings.")
    
    # Print resource counts
    print("\n=== Resource Counts ===")
    print(f"Total DynamoDB Items: {len(items)}")
    print(f"Lambda Functions: {len(lambda_functions)}")
    for resource_type, count in resource_counts.items():
        print(f"{resource_type}: {count}")
    print(f"Event Source Mappings: {len(event_source_mappings)}")
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'itemCount': len(items),
            'resourceCounts': resource_counts,
            'eventSourceMappingsCount': len(event_source_mappings)
        })
    }

if __name__ == "__main__":
    lambda_handler({}, {})