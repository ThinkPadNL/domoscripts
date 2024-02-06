#!/usr/bin/env python
# encoding: utf-8
'''
round_modus -- Honeywell Round Connected Modulation

@author:     Nicky Bulthuis

@copyright:  2015 Nicky Bulthuis. All rights reserved.

@license:    BSD

@deffield    updated: Updated
'''

import sys
from argparse import ArgumentParser
from evohomeclient2 import EvohomeClient

def main(argv=None):
    
    parser = ArgumentParser(description='Honeywell Round Connected Modulation')
    parser.add_argument("-u", "--username", dest="username", help="Username of your mytotalconnect.com account.", required=True)
    parser.add_argument("-p", "--password", dest="password", help="Password of your mytotalconnect.com account.", required=True)
    
    modus = parser.add_mutually_exclusive_group(required=True)
    modus.add_argument('--normal', dest='modus', action='store_const',
                   const='normal', help='set modus normal/auto')
    modus.add_argument('--away', dest='modus', action='store_const',
                   const='away', help='set modus away')
    modus.add_argument('--eco', dest='modus', action='store_const',
                   const='eco', help='set modus eco')
    modus.add_argument('--custom', dest='modus', action='store_const',
                   const='custom', help='set modus custom')
    modus.add_argument('--dayoff', dest='modus', action='store_const',
                   const='dayoff', help='set modus day off')
    modus.add_argument('--heatingoff', dest='modus', action='store_const',
                   const='heatingoff', help='set modus heating off')
    
    args = parser.parse_args()
    
    client = EvohomeClient(args.username, args.password, debug=False)
    
    if args.modus == 'normal':
        client.set_status_normal()
    elif args.modus == 'custom':
        client.set_status_custom()
    elif args.modus == 'eco':
        client.set_status_eco()
    elif args.modus == 'away':
        client.set_status_away()
    elif args.modus == 'dayoff':
        client.set_status_dayoff()
    elif args.modus == 'heatingoff':
        client.set_status_heatingoff()
            
if __name__ == "__main__":
    sys.exit(main())