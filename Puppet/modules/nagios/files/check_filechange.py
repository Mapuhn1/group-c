#! /usr/bin/env python3

'''
Script to monitor files and directories, alerting you whenever an event occurs

Creation date: 24/02/2017
Date last updated: 19/03/2017

* 
* License: GPL
* Copyright (c) 2017 DI-FCUL
* 
* Description:
* 
* This file contains the check_defacing plugin
* 
* Use the nrpe program to check request on remote server.
* 
* 
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
* 
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
'''

import os
import sys
from optparse import OptionParser
from time import strftime
import time
import datetime

__author__ = "\nAuthor: Raimundo Henrique da Silva Chipongue\nE-mail: fc48807@alunos.fc.ul.pt, chipongue1@gmail.com\nInstitution: Faculty of Science of the University of Lisbon\n"
__version__= "1.0.0"

# define exit codes
ExitOK = 0
ExitWarning = 1
ExitCritical = 2
ExitUnknown = 3

def checklogs(opts):

    path_files = opts.files
    files = []
    files.extend([i for i in opts.files.split(",")])
    for i in range(0,len(files)):
        if not os.path.exists(files[i]):
            print("The specified file or directory does not exist: %s"%files[i])
            sys.exit(ExitUnknown)
    
    path_files = path_files.replace(",", " ")
    processesname = 'inotifywait -mrd'
    tmp = os.popen("ps -Af").read()
    proccount = tmp.count(processesname)
    if proccount > 0:
        process = True
    else:
        process = False
    if process == False:
        timefmt = "%d/%m/%y %H:%M"
        format_ = "%T %w %e %f"
        try:
            os.popen("inotifywait -mrd --timefmt '%s' --format '%s' %s -e %s -o %s"%(timefmt,format_,path_files, opts.events, opts.path))
        except:
            print("Could not execute the inotify")
            sys.exit(ExitUnknown)
            
    totalerror = int(os.popen("cat %s | wc -l"%opts.path).read())        

    if totalerror:
        print('Critical - Were found in inotify log file %s alerts, see the file "%s"'%(totalerror, opts.path))            
        sys.exit(ExitCritical)
    else:
        print('Ok - No change were found in inotify log file "%s"'%opts.path)
        sys.exit(ExitOK) 
                
def main():
    parser = OptionParser("usage: %prog [options] ARG1 ARG2 FOR EXAMPLE: -p"+ 
                          " /var/log/inotify/inotify.log -f /tmp/,/home/cgs/ -e access,modify,attrib")
    parser.add_option("-p","--path", dest="path", default="/var/log/inotify/inotify.log",
                      help="Enter the full path to the inotify logs file, i.e. -p /var/log/inotify/inotify.log")
    parser.add_option("-f","--files", dest="files", default=False, type="string",
                      help="Use this option to specify the files or directories you need to monitore,"+ 
                      " separated by comma ',', for ex. '-f /tmp/,/home/cgs/Documents/wp_version.php'")
    parser.add_option("-e","--events", dest="events", default="access,modify,attrib,open,move,create,delete", type="string",
                      help="Use this option to specify the events you need to monitore, default values is"+
                      " 'access, modify, attrib, open, move, create, delete'")
    parser.add_option("-V","--version", action="store_true", dest="version", help="This option show the current version"+
                      " number of the program and exit")
    parser.add_option("-A","--author", action="store_true", dest="author", help="This option show author information and exit")
    (opts, args) = parser.parse_args()
    
    if opts.author:
        print(__author__)
        sys.exit()
    if opts.version:
        print("check_apache404.py %s"%__version__)
        sys.exit()
    if not opts.files:
        parser.error("Please, this program requires to specify file or directory to monitore.")
        
    if opts.path:
        if not os.path.exists(opts.path):
            parser.error("Please, this program requires to specify a valid log file.")
        else:
            checklogs(opts)
    else:
        parser.error("Please, this program requires to specify a valid path file.")

if __name__ == '__main__':
    main()
