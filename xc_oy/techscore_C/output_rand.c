#include<stdio.h>
#include<stdlib.h>
#include<time.h>

void output_rand(int length,char* fileName){
  FILE *fo;
  int i;
  
  if((fo=fopen(fileName,"w"))==NULL){
    printf("Can't Open Input File.\n");
    exit(1);
  }
  srand(time(NULL));
  for(i=0;i<length;i++){
    fprintf(fo,"%d\n",rand()%1000);
  }
  fclose(fo);
}

int main(int argc,char *argv[]){
  int length;
  
  if(argc!=3){
    printf("Please Enter Length and File Name\n");
    exit(1);
  }
  if(!isdigit(*argv[1])){
    printf("Length is Integer!!!\n");
    exit(1);
  }
  length=atoi(argv[1]);
  output_rand(length,argv[2]);
  return(0);
}
