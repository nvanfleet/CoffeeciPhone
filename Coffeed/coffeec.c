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
	fprintf(stderr, "-a IPADDRESS -p PORT -c COMMAND\n");
	printf(
		"Coffeec Version 2.0"
		"SETTING\n------------------\n"
		"VERSION            Get the version of coffeed\n"
		"SHUTD              Shutdown the system (stops daemon)\n"
		"BMODE=<TRUE/FALSE> Set to brewmode or steam mode\n"
		"SLEEP=<TRUE/FALSE> Set to sleep or wake\n"
		"TPOINT             Get the current temperature (read only)\n"
		"BPOINT=<float>     Set Brew setpoint\n"
		"SPOINT=<float>     Set Steam setpoint\n"
		"PGAIN=<float>      Set PID p-gain\n"
		"IGAIN=<float>      Set PID i-gain\n"
		"DGAIN=<float>      Set PID d-gain\n"
		"TOFFEST=<float>    Set thermocouple accuracy offset\n"
		"OFFSET=<float>     Set boiler temp offset\n"
		);
}

int sendMessage(char *addr, int port, char *command, char *buffer, int bsize)
{
    ssize_t z;
    int com_socket;
    struct sockaddr_in server_address;
    struct timeval timeout;
	in_addr_t address = inet_addr(addr);
	
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
	
	z = snprintf(buffer, bsize, &command[0]);
//	snprintf(&buffer[z], bsize-z, "\0");
	
    // SEND
    z = send(com_socket, buffer, strlen(buffer), 0);
    if (z < 0)
        fprintf(stderr,"send failure\n");
    else
		printf("Send Succeeded\n");
    
    // READ
    z = recv(com_socket, buffer, bsize, 0);
    if (z < 0)
        fprintf(stderr,"receive failure\n");
    else
		printf("Receive Succeeded\n");
    
//	snprintf(&buffer[z], bsize-z,"\0");
	
    // Output
    printf("Received Response: %s\n", buffer);
    
    close(com_socket);
	
	return 1;
}

int main(int argc, char **argv)
{
	int buffersize = 256;
	char buffer[buffersize];
	
    int opt;
	int port;
	int abort = 0;
	char *command;
	char *addr;
	
    //Defaults
    addr = "127.0.0.1";
    port = 4949;
    
	//INCLUDED ARGUMENTS FROM CLI
	while((opt = getopt(argc, argv, "a:p:c:")) > 0) 
	{
		switch(opt)
		{
            case 'a':
				addr = (char *)optarg;
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
	
	sendMessage(addr, port, command, buffer, buffersize);
	    
    exit(1);
}

