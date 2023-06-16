#include<iostream>
using namespace std;

int GCD(int a, int b){
  if(a % b == 0){
    return b;
  }
  else{
    return GCD(b, a % b);
  }
}

int main(){
  printf("Enter first number: ");
  int a, b;
  scanf("%d", &a);
  printf("Enter second number: ");
  scanf("%d", &b);

  int result = GCD(a, b);
  printf("The GCD is: %d", result);
}