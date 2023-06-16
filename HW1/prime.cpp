#include<iostream>
using namespace std;

int prime(int n){
	if(n == 1){
		return 0;
	}

	for(int i = 2; i * i <= n; i++){
		if (n%i == 0){
			return 0;
		}
	}

	return 1;
}

int main(){
	int n = 0, flag = 0;
	printf("Enter the number n = ");
	scanf("%d", &n);
	if(prime(n)){
		printf("%d is a prime", n);
	}
	else{
		printf("%d is not a prime, the nearest prime is", n);
		for (int i = 1;; i++){
			if(prime(n - i)){
				printf(" %d", n - i);
				flag = 1;
			}
			if(prime(n + i)){
				printf(" %d", n + i);
				flag = 1;
			}
			if(flag) break;
		}
	}

	return 0;
}