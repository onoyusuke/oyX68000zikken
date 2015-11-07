#include<stdio.h>
 
int main(int argc, char *argv[]){
  char name[64];
  puts("What's your name?");
  gets(name);
  printf("Your name is %s",name);
 
  return(0);
}
