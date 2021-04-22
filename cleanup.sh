#!/usr/bin/bash

for i in master worker1 worker2; do
	multipass.exe delete $i
done

#multipass.exe delete --all
multipass.exe purge
