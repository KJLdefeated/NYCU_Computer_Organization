#include<stdio.h>
#include<stdlib.h>
#include <iostream>
using namespace std;

int main()
{
	int n ;
	printf("Enter the number n = ");
    scanf("%d", &n);
    
    int temp = (n+1)/2;
    if(n%2==1) temp--;
    
    for(int i = 0; i < temp ; i++){
        for(int j = 0; j <= i; j++) printf(" ");
        for(int j = 0; j < n - i*2; j++) printf("*");
        printf("\n");
    }
    
    for(int i = (n+1)/2-1; i >= 0 ; i--){
		for(int j = 0; j <= i; j++) printf(" ");
		for(int j = 0; j < n - i*2; j++) printf("*");
		printf("\n");
    }

	system("pause");
	return 0;
}