/**
 * CFGDB discovery script
 * Compile on SmartOS by command:
 * gcc -o cfgdb_discovery -lsocket -lxnet cfgdb_discovery.c
 * Copyright (c) 2017, Erigones, s. r. o.
 */


#include <stdio.h> //printf
#include <string.h> //memset
#include <stdlib.h> //exit(0);
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/time.h> //timeval
#include <errno.h>
 
#define BUFLEN 100  //Max length of buffer
#define PORT 5430   //The port on which to listen for incoming data
#define DISCO_STRING "cfgdb_discovery"
#define REPLY_STRING "cfgdb_reply:"
 
void die(char *s)
{
    perror(s);
    exit(1);
}

int main(void)
{
    struct sockaddr_in si_me, si_other, broadcastAddr;
     
    int s, i, slen = sizeof(si_other) , recv_len;
    char buf[BUFLEN];
     
    //create a UDP socket
    if ((s=socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) == -1)
        die("socket");
     
    
    // zero out the structure
    memset((char *) &si_me, 0, sizeof(si_me));
     
    si_me.sin_family = AF_INET;
    si_me.sin_port = htons(PORT);
    si_me.sin_addr.s_addr = htonl(INADDR_ANY);
     
    //bind socket to port
    if( bind(s , (struct sockaddr*)&si_me, sizeof(si_me) ) == -1)
        die("bind");
     

    // SEND BROADCAST
   int broadcastPermission;         
   char *broadcastIP;                
   char *sendString;                 
   int sendStringLen;                
   broadcastIP = "255.255.255.255";  
   broadcastPermission = 1;
   sendString = DISCO_STRING;
   if (setsockopt(s, SOL_SOCKET, SO_BROADCAST, (void *) &broadcastPermission,sizeof(broadcastPermission)) < 0)
        die("setsockopt");
    
   /* Construct local address structure */
   memset(&broadcastAddr, 0, sizeof(broadcastAddr));   
   broadcastAddr.sin_family = AF_INET;                 
   broadcastAddr.sin_addr.s_addr = inet_addr(broadcastIP);
   broadcastAddr.sin_port = htons(PORT);       

   sendStringLen = strlen(DISCO_STRING);  
    /* Broadcast sendString in datagram to clients */
    if (sendto(s, sendString, sendStringLen, 0, (struct sockaddr *)&broadcastAddr, sizeof(broadcastAddr)) != sendStringLen)
        die("sendto");


    // RECEIVE REPLY
    struct timeval timeout={1,0}; //set timeout for 1 second
    setsockopt(s,SOL_SOCKET,SO_RCVTIMEO,(char*)&timeout,sizeof(struct timeval));

    // inspect at most this number of incoming packets before giving up
    int maxiterations = 6;
    //keep listening for data
    while(maxiterations--)
    {
        memset((char *) &buf, 0, sizeof(BUFLEN));
        fflush(stdout);
         
        //try to receive some data, this is a blocking call
        if ((recv_len = recvfrom(s, buf, BUFLEN, 0, (struct sockaddr *) &si_other, &slen)) == -1)
        {
            if(errno == EAGAIN) {
                // timeout reached, exitting..
				break;
            }
            else
                die("recvfrom()");
        }

        // ignore everything not starting with REPLY_STRING
        if(!strncmp(REPLY_STRING, buf, strnlen(REPLY_STRING, BUFLEN))) {
            // cfgdb found on IP:
            printf("%s\n", inet_ntoa(si_other.sin_addr));
            close(s);
            exit(0);
        }
    }
 
    // no cfgdb reply found..
    // exit with non-zero
    close(s);
    return 1;
}
