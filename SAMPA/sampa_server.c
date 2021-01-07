#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>
#include <math.h>
#include "sampa.h"
#include "sampa_sock.h"
#include <time.h>

void report(const char* msg, int terminate) {
  perror(msg);
  if (terminate) exit(-1); /* failure */
}


void resetAZ(void);
void parseBuffer(char *timeStamp, size_t l);
void manualDisconnect(int cause);

int client_fd;
struct sockaddr_in caddr; /* client address */
int len = sizeof(caddr);  /* address length could change */
int connected = -1;
int sampaResult;
char sunA[32];
char sunZ[32];
char moonA[32];
char moonZ[32];
char floaty[16];
char sampaArgs[5][10];
char EOM[] = "$3.14\n";
time_t lastTime, thisTime;

int main() {
  sampa_data sampa;  //declare the SAMPA structure
    // Year, Month, Day, Hour, Minute updated by Client
    sampa.spa.year          = 2021;
    sampa.spa.month         = 1;
    sampa.spa.day           = 1;
    sampa.spa.hour          = 12;
    sampa.spa.minute        = 00;
    sampa.spa.second        = 0;  // could put this in the future for better aim?
    sampa.spa.timezone      = -5;
    sampa.spa.delta_ut1     = -0.2;
    sampa.spa.delta_t       = 72.15;
    sampa.spa.longitude     = -73.9529;	// negative west of Greenwich
    sampa.spa.latitude      = 40.6824;  // negative south of equator
    sampa.spa.elevation     = 0;
    sampa.spa.pressure      = 1016;
    sampa.spa.temperature   = 13;
    sampa.spa.atmos_refract = 0.5667;
    sampa.function          = SAMPA_NO_IRR;
  
  resetAZ();
    
    
  int fd = socket(AF_INET,     /* network versus AF_LOCAL */
		  SOCK_STREAM | SOCK_NONBLOCK, /* added SOCK_NONBLOCK seems to work */
		  0);          /* system picks underlying protocol */
  if (fd < 0) report("socket", 1); /* terminate */
  	
  /* bind the server's local address in memory */
  struct sockaddr_in saddr;
  memset(&saddr, 0, sizeof(saddr));          /* clear the bytes */
  saddr.sin_family = AF_INET;                /* versus AF_LOCAL */
  saddr.sin_addr.s_addr = htonl(INADDR_ANY); /* host-to-network endian */
  saddr.sin_port = htons(PortNumber);        /* for listening */
  
  if (bind(fd, (struct sockaddr *) &saddr, sizeof(saddr)) < 0)
    report("bind", 1); /* terminate */
	
  /* listen to the socket */
  if (listen(fd, MaxConnects) < 0) /* listen for clients, up to MaxConnects */
    report("listen", 1); /* terminate */

  fprintf(stderr, "Listening on port %i for clients...\n", PortNumber);
  /* this server will listen for 3 minutes before closing itslef */
  
  time(&lastTime);
  puts("starting timer"); // at %d",lastTime);
  while (1) {
    
    time(&thisTime);
    //puts("checking program timeout 1"); // %d",thisTime);ß
    if(thisTime - lastTime > ProgramTimeout){
      puts("fun's over");
      exit(0);
    }
    
    //struct sockaddr_in caddr; /* client address */
    //int len = sizeof(caddr);  /* address length could change */
    
    if(connected < 0){
      client_fd = accept(fd, (struct sockaddr*) &caddr, &len);  /* accept blocks */
      if (client_fd < 0) {
	report("accept", 0); /* don't terminate, though there's a problem */
	continue;
      } else {
	puts("connected to client...");
	printf("client %d\n",client_fd);
	connected = 1;
	time(&lastTime);
	continue;
      }
      time(&thisTime);
      puts("checking program timeout 2");
      if(thisTime - lastTime > ProgramTimeout){
	puts("fun's over");
	exit(0);
      }
    }

    if(connected > 0){
      
      time(&thisTime); // check the time
      puts("checking idle timeout 1");
      if(thisTime - lastTime > MaxIdleTime){
	manualDisconnect(IdleTimeOut);
      }
    //}
    
      /* read from client */
      char buffer[BuffSize + 1];
      memset(buffer, '\0', sizeof(buffer)); // fill buffer with terminators
      int count = read(client_fd, buffer, sizeof(buffer));
      
      if (count > 0) {
	if(strncmp(TerminateCom,buffer,strlen(TerminateCom)) == 0){
	  manualDisconnect(RemoteTermination);
	  continue;
	}
	time(&lastTime); // restart timer
	//puts(buffer);  // verbose barf
	parseBuffer(buffer,strlen(buffer)); // get the latest time
	sampa.spa.year = strtol(sampaArgs[0],NULL,10); // seed the sampa
	sampa.spa.month = strtol(sampaArgs[1],NULL,10);
	sampa.spa.day = strtol(sampaArgs[2],NULL,10);
	sampa.spa.hour = strtol(sampaArgs[3],NULL,10);
	sampa.spa.minute = strtol(sampaArgs[4],NULL,10);
	sampaResult = sampa_calculate(&sampa); // run the sampa
	resetAZ();  // prep the strings for sending
	// convert the sampa data
	sprintf(floaty,"%f",sampa.spa.azimuth);  // eastward from North
	strcat(sunA,floaty);  strcat(sunA,"\n"); // must end string! 
	sprintf(floaty,"%f",sampa.spa.zenith);   // down from vertical
	strcat(sunZ,floaty);  strcat(sunZ,"\n");
	sprintf(floaty,"%f",sampa.mpa.azimuth);  // eastward from North
	strcat(moonA,floaty);  strcat(moonA,"\n");
	sprintf(floaty,"%f",sampa.mpa.zenith);   // down from vertical
	strcat(moonZ,floaty);  strcat(moonZ,"\n");
	write(client_fd, sunA, strlen(sunA)); // write the sampa data
	write(client_fd, sunZ, strlen(sunZ));
	write(client_fd, moonA, strlen(moonA));
	write(client_fd, moonZ, strlen(moonZ));
	write(client_fd, EOM, strlen(EOM));  // completed transmission
      }/* if count */
    } /* if connected */
  }  /* while(1) */
  return 0;
}  /* main() */


void resetAZ(void){
  strcpy(sunA,"A");
  strcpy(sunZ,"Z");
  strcpy(moonA,"a");
  strcpy(moonZ,"z");
}


// sampa arguments: Year, Month , Day, Hour, Minute
void parseBuffer(char *ts, size_t l){
  printf("Parsing '%s'\n",ts);
  char delim[] = " ";
  int argCounter = 0;
  char *parser = strtok(ts,delim);
  while(parser != NULL){
    //printf("\t'%s'\n",parser);
    strcpy(sampaArgs[argCounter],parser);
    argCounter++;
    parser = strtok(NULL,delim);
  }
  
}

void manualDisconnect(int cause){
  switch(cause){
    case IdleTimeOut:
      puts("idle timeout");
      time(&lastTime);	// start timer
      break;
    case RemoteTermination:
      puts("client disconnected, shutting down\n");
      exit(0);
      break;
    default:
      break;
    }
  connected = -1;
}
