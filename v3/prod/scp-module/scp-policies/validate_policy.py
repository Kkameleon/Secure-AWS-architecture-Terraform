import boto3
import os

# This script check the validity of the SCP
def check_scp(scp_index):
    # Configure AWS account access
    my_session = boto3.Session(profile_name="prod")
    client = my_session.client('accessanalyzer')
    
    scp_file_name = 'scp-'+str(scp_index)+'.json'
    with open(scp_file_name, 'r') as f:
      scp_policy = f.read()
      f.close()

    response = client.validate_policy(
      policyDocument=scp_policy,
      policyType='SERVICE_CONTROL_POLICY',
    )

    findings = response['findings']
    if len(findings) == 0:
      print(scp_file_name+": VALID\n")
    else:
      print(scp_file_name+": NOT VALID")
      print(findings)
      print("") 

if __name__ == "__main__":
  for i in range (1,4):
    check_scp(i)
    
