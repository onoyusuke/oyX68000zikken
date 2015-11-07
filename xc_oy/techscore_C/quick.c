#include<stdio.h>
#include<stdlib.h>
#include<time.h>

int* inputData(char *fileName,int *data,int length){
  FILE *fo;
  int i;
  char str[256];

  if((fo=fopen(fileName,"r"))==NULL){//リードモードでファイルを開く
    printf("Can't Open Input File.\n");
    exit(1);
  }

  i=0;
  while(fgets(str,256,fo)!=NULL){//ファイルからデータを読み込む
    data[i]=atoi(str);
    i++;
  }
  return data;
}

//クイックソートの基準値を決定する時に使用
int median(int *num){
  int i,tmp,n;

  for(i=0;i<3;i++){
    for(n=2;n>i;n--){
      if(num[n]<num[n-1]){ //比較対象の数字が一つ前の数字より小さければ,入れ換える。
        tmp=num[n];
	num[n]=num[n-1];
	num[n-1]=tmp;
      }
    }
  }
  return num[1];//「先頭の値」「末尾の値」「配列の真中の値」のメディアンの値を返す
}

//クイックソート
void quick_sort(int *data,int first,int last,int bType){
  int i,j,x,t,num[4];
  
  if(bType==1){//先頭の値
    x=data[first];
  }
  else if(bType==2){//先頭と末尾の値の平均
    x=(data[first]+data[last])/2;
  }
  else if(bType==3){//「先頭の値」「末尾の値」「配列の真中の値」のメディアン
    num[0]=data[first];
    num[1]=data[last];
    num[2]=data[(first+last)/2];
    x=median(num);
  }
  i=first;
  j=last;
  while(1){
    while(data[i]<x) i++;
    while (x<data[j]) j--;
    if (i>=j) break;
    t=data[i];
    data[i]=data[j];
    data[j]=t;
    i++;
    j--;
  }
  if(first<i-1) quick_sort(data,first,i-1,bType);
  if(j+1<last) quick_sort(data,j+1,last,bType);
}

void outputData(int *data,int length){
  int i;

  //結果を標準出力
  printf("\n*****Result*****\n");
  for(i=0;i<length;i++){
    printf("%d ",data[i]);
  }
  printf("\n");
}

int main(int argc,char *argv[]){
  int length,i;
  int *data,bType;
  time_t startTime,endTime;

  if(argc!=4){
    printf("Please Enter File Name and Data Length and Basis Value Type\n");
    exit(1);
  }
  if(!isdigit(*argv[1])){
    printf("Length is Integer!!!\n");
    exit(1);
  }
  length=atoi(argv[1]);
  bType=atoi(argv[3]);
  
  if(bType<0 || bType>3){
    printf("Please Select Basis Type:1,2,3\n");
    exit(1);
  }

  //int型配列を用意する
  data=(int*)malloc(sizeof(int)*length);

  data=inputData(argv[2],data,length);
   
  printf("***DATA***\n");
  for(i=0;i<length;i++){
    printf("%d ",data[i]);
  }
  printf("\n");

  startTime=time(&startTime);

  quick_sort(data,0,length-1,bType);
  
  endTime=time(&endTime);
  
  outputData(data,length);
  free(data);
  printf("\nstart=%s\n",ctime(&startTime));
  printf("end=%s\n",ctime(&endTime));
  printf("Time=%fsec\n",  difftime(endTime,startTime));
  return(0);
}
