import json
import os
import re
import requests
# imports config.py to use the API key for Godaddy
import config

# Retireve DNS records, clean up the text and push dns records update to GoDaddy
def update_dns_fn():

    # Pull Records from Hosted Zone
    hz_id = "aws route53 list-hosted-zones-by-name > hzid.json"
    os.system(hz_id)
    with open('hzid.json') as json_file:
        data = json.load(json_file)
        for p in data['HostedZones']:
            JID = re.split(r'/hostedzone/', p['Id'])

    # Pull NS records from Hosted Zone
    ns_records = "aws route53 list-resource-record-sets --hosted-zone-id " + JID[1] + " --output json > dns_records.txt"
    os.system(ns_records)
    with open('dns_records.txt') as json2:
        data2 = json.load(json2)
        p = data2['ResourceRecordSets']
        p = p[0]
        p = p['ResourceRecords']
        with open('text', 'w') as filehandle:
            filehandle.writelines("%s\n" % line for line in p)   

     # Clean up the NS records text file
    filename = 'text'
    file = open(filename, 'rt')
    text = file.read()
    file.close()
    words = re.split(r'\s+', text)
    split1 = words[1].strip('\'\}\.')
    split2 = words[3].strip('\'\}\.')
    split3 = words[5].strip('\'\}\.')
    split4 = words[7].strip('\'\}\.')

  # gdcreds creates the API string from config.py to pass into the requests module.
    gdcreds = 'sso-key '+ config.api_key + ":" + config.api_secret

 # create the API HTTP PUT request
    godaddy_url = "https://api.godaddy.com/v1/domains/" + config.domainname + "/records/NS/"
    gd_headers = {'Content-Type': 'application/json', 'accept': 'application/json', 'Authorization': gdcreds}
    payload = [{'data': str(split1), 'name': config.domainname, 'ttl': 3600}, {'data': str(split2), 'name': config.domainname, 'ttl': 3600}, {'data': str(split3), 'name': config.domainname, 'ttl': 3600}, {'data': str(split4), 'name': config.domainname, 'ttl': 3600}]
    # Make the request
    requests.put(godaddy_url, headers=gd_headers, json=payload)


update_dns_fn()
