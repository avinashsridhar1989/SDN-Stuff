#######################################################################
READ ME FILE FOR SDN (COMSE-6998) HOMEWORK - 2
Name: Avinash Sridhar
UNI: as4626
#######################################################################

Q1) Hub has been implemented to flood all the ports as asked in the question. 

Test Case:

sudo mn --topo single,4 --controller remote --mac
#######################################################################
Q2) We have been asked to skip this question due to NetKAT documentation issues
#######################################################################
Q3) Blocking SSH traffic coming from host 1 and going to host 3 or 4.

Test Case:

sudo mn --topo single,4 --controller remote --mac
#######################################################################
Q4) Learning switch is implemented using the code provided by TA as reference. Also, implemented a firewall policy within the learning function to block https
    traffic amongst h1 h2 h3.

Test Case:

sudo mn --topo single,4 --controller remote --mac
#######################################################################
Q5) Implemented routing policy for a tree topology. Static routing is enabled matching the IP Addresses, ethType, and ipProto.

Test Case:

sudo mn --controller remote --topo tree,2,2 --mac --arp
#######################################################################
