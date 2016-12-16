#!/bin/bash

FILENAME=$1

tail -n10 $FILENAME|fold -w75|grep -v /usr/sbin/run-crons
