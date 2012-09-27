/* ------------------------------------------------------------------------- */
/*       coffeedc -- A PID system for espresso machines                       */
/* ------------------------------------------------------------------------- */

/*	

 A PID client for monitoring and controlling the heat of a espresso machine.

*/

/* ------------------------------------------------------------------------- */

#include <stdio.h>
#include <stdarg.h>
#include <sys/time.h>
#include <sys/poll.h>
#include <netinet/tcp.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <errno.h>
#include <string.h>
#include <limits.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <stdlib.h>
#include <netinet/in.h>
#include <stdint.h>
#include <arpa/inet.h>

#pragma mark - Setup Code

static int connectWithTimeout (int sfd, struct sockaddr *addr, int addrlen, struct timeval *timeout)
{
    struct timeval sv;
    socklen_t svlen = sizeof sv;
    int ret;
    
    if (!timeout)
        return connect (sfd, addr, addrlen);
    if (getsockopt (sfd, SOL_SOCKET, SO_RCVTIMEO, (char *)&sv, &svlen) < 0)
        return -1;
    if (setsockopt (sfd, SOL_SOCKET, SO_RCVTIMEO, (char *)timeout, sizeof *timeout) < 0)
        return -1;
    ret = connect (sfd, addr, addrlen);
    setsockopt (sfd, SOL_SOCKET, SO_RCVTIMEO, (char *)&sv, sizeof sv);
    return ret;
}

void printhelp()
{
	fprintf(stderr, "-a IPADDRESS -p PORT -C COMMAND\n");
	printf("COMMANDS\n------------------\n"
		"CMD=SMODE          Steam mode activation\n"
		"CMD=BMODE          Brew mode activation\n"
		"CMD=WAKE           wake up PID\n"
		"CMD=SLEEP          put PID to sleep\n"
		"CMD=SDOWN          Shutdown entire daemon\n"
		"CMD=STATUS         Print server status\n"
		"SETTING\n------------------\n"
		"BPOINT=<float>     Set Brew setpoint\n"
		"SPOINT=<float>     Set Steam setpoint\n"
		"PGAIN=<float>      Set PID p-gain\n"
		"IGAIN=<float>      Set PID i-gain\n"
		"DGAIN=<float>      Set PID d-gain\n"
		"TOFFEST=<float>    Set thermocouple accuracy offset\n"
		"OFFSET=<float>     Set boiler temp offset\n"
		);
}

int main(int argc, char **argv)
{
    int abort = 0;
    int port;
	in_addr_t address;
    char *command;
    
    ssize_t z;
    int com_socket;
    struct sockaddr_in server_address;
    struct timeval timeout;

    int opt;
    
    //Defaults
    address = inet_addr("127.0.0.1");
    port = 4949;
    
	//INCLUDED ARGUMENTS FROM CLI
	while((opt = getopt(argc, argv, "a:p:c:")) > 0) 
	{
		switch(opt)
		{
            case 'a':
				address = inet_addr(optarg);
				break;
            case 'p':
				port = atoi(optarg);
                break;
            case 'c':
				abort = 1;
				command = (char *)optarg;
				break;   
            default:
		printhelp();
		exit(0);
        }
    }
    // Server
    memset(&server_address, 0, sizeof(server_address));
    server_address.sin_family = AF_INET;
    server_address.sin_port = htons(port);
    server_address.sin_addr.s_addr = address;

    if (server_address.sin_addr.s_addr == INADDR_NONE)
        fprintf(stderr, "Server address failed\n");

    if(!abort)
    {
        fprintf(stderr, "No Command given\n");
	printhelp();
        exit(0);
    }
    else
    {
    	printf("Address %s Port %d\n", inet_ntoa(server_address.sin_addr), port);
    }

    // Create com_socket
    com_socket = socket(PF_INET, SOCK_STREAM, 0);
    if (com_socket == -1)
         fprintf(stderr, "Socket failed\n");

    /*
    // Client
    struct sockaddr_in client_address;
    memset(&client_address,0,sizeof client_address);
    client_address.sin_family = AF_INET;
    client_address.sin_port = 0;
    client_address.sin_addr.s_addr = ntohl(INADDR_ANY);
    
    if (client_address.sin_addr.s_addr == INADDR_NONE)
        fprintf(stderr, "Client address failed\n");
    
    // Bind
    z= bind(com_socket, (struct sockaddr *)&client_address, sizeof (client_address));
    if ( z == -1 )
        fprintf(stderr,"Binding port\n");
    */
    
    timeout.tv_sec = 2; /* 2 seconds */ 
    timeout.tv_usec = 0; /* + 0 usec */

    // Connect
    //z = connectWithTimeout(com_socket, (struct sockaddr *) &server_address, len_inet, &timeout);
    z = connect(com_socket, (struct sockaddr *) &server_address, sizeof(server_address));
    if(z == -1)
    {
        if(errno == EINPROGRESS)
        {
            fprintf(stderr, "EINPROGRESS non block start\n");
        }
        
        if(errno == EALREADY)
        {
            fprintf(stderr, "EALREADY non block subsequent request\n");
        }
        
        fprintf(stderr, "Connect failed\n");
    }
    else 
	printf("Connect Success\n");

	int sSize = 256;
	char sbuf[sSize];

	z = snprintf(sbuf, sSize, command);
        snprintf(&sbuf[z], sSize-z, "\0");

    // SEND
    z = send(com_socket, sbuf, strlen(sbuf), 0);
    if (z < 0)
        fprintf(stderr,"send failure\n");
    else
	printf("Send Succeeded\n");
    
    // READ
    z = recv(com_socket, sbuf, sSize, 0);
    if (z < 0)
        fprintf(stderr,"receive failure\n");
    else
	printf("Receive Succeeded\n");
    
	snprintf(&sbuf[z], sSize-z,"\0");

    // Output
    printf("Received Response: %s\n", sbuf);
    
    close(com_socket);
    
    exit(1);
}

