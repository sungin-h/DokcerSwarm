#include <string>
#include <vector>
#include <iostream>
#include <cstdlib>
#include <ctime>


#define N 25

using namespace std;
int tar;
int cnt;
void dfs(vector<int> numbers, int dep){
	if(numbers.size() == dep){
		int res=0;
		for(auto it = numbers.begin(); it < numbers.end(); it++){
			res += *it;
		}
		if(res == tar)
			cnt++;
		return ;
	}
	else{
		dfs(numbers,dep+1);
		numbers[dep] *= -1;
		dfs(numbers,dep+1);
	}
}


int solution(vector<int> numbers, int target) {
	int answer = 0;
	tar = target;

	dfs(numbers,0);  

	return cnt;
}

int main(){
	vector<int> numbers;
	int target;
	int random_var;

	srand(time(nullptr));

	for(int i=0; i<N; i++){
		random_var = rand()%51;
		//random_var = 1;
		numbers.push_back(random_var);
	}
	target = rand()%1001;
	//target = 3;


	int answer = solution(numbers,target);
	cout<<"###"<<endl;

	for(auto it = numbers.begin(); it<numbers.end(); it++){
		cout<<*it<<" ";
	}
	cout<<endl;

	cout<<"N : "<<N<<endl;
	cout<<"target number : "<<target<<endl;
	cout<<answer<<endl;
}
