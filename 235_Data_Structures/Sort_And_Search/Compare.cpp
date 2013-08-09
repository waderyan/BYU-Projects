#include <iostream>
#include "Student.h"
#include <vector>
#include <string>
#include <fstream>
#include <algorithm>
#include <set>
#include <list>


using namespace std;

/**
	Finds the minimum position of an element
	Average Big O is O(n)
	@param vector of students
	@param first element to start search
	@param last element to end search
*/
int find_min(vector<Student> vec, int first, int last)
{
	int min_pos = first;
	for(int i = first; i < last; i++)
	{
		if(vec[i] < vec[min_pos])
		{
			min_pos = i;
		}
	}
	return min_pos;
}
/**
	Switches two elements
	@param vector of students passed by reference
	@param a is position of 1st element
	@param b is position of 2nd element
*/
void switch_elements(vector<Student>& vec, int a, int b)
{
	Student temp = vec[a];
	vec[a] = vec[b];
	vec[b] = temp;
}
/**
	Finds the minimum position of the vector and moves the element to the front
	Iterates through the rest of the vector repeating above step
	Big O(n^2) best, worst, and average;
*/
void selection_sort(vector<Student>& vec)
{
	int min_pos = 0;
	int last_pos = vec.size() -1;
	for(unsigned int i = 0; i < vec.size(); i++)
	{
		min_pos = find_min(vec, i, last_pos);
		switch_elements(vec, i, min_pos);
	}
}
/**
	Iterates through vector and brings the element to the proper place in the list
	Big O(n) best case; Big O(n^2) average and worst case;
	Usually thought of as one of the fastest
*/
void insertion_sort(vector<Student>& vec)
{
	for(unsigned int i = 1; i < vec.size(); i++)
	{
		unsigned int j = i;
		while(j > 0 && vec[j-1] > vec[j])
		{
			switch_elements(vec, j, (j-1));
			j--;
		}
	}
}
/**
	Combines two vectors and a pivot value into one vector
*/
vector<Student> combine_vecs(vector<Student> left, vector<Student> right, Student pivot_val)
{
	vector<Student> temp;
	for(size_t i = 0; i < left.size(); i++)
	{
		temp.push_back(left[i]);
	}
	temp.push_back(pivot_val);
	for(size_t i = 0; i < right.size(); i++)
	{
		temp.push_back(right[i]);
	}
	return temp;
}
/**
	Determines partition value that is the value in the middle of the vector
	Return pivot value
	Passes a left and right vectors by reference
*/
Student partition(vector<Student> vec, vector<Student>& left, vector<Student>& right)
{
	int pivot_pos = vec.size()/2;
	Student pivot_val = vec[pivot_pos];
	bool same = false;
	for(size_t i = 0; i < vec.size(); i++)
	{
		if(vec[i] < pivot_val)
		{
			left.push_back(vec[i]);
		}
		else if(vec[i] == pivot_val)
		{
			if(same)
			{
				left.push_back(vec[i]);
			}
			same = true;
		}
		else
		{
			right.push_back(vec[i]);
		}
	}
	return pivot_val;
}
/**
	Recursive algorithm 
	@param vec of students
*/
void quick_sort(vector<Student>& vec)
{
	if(vec.size() <= 1)
	{
		return;
	}
	else
	{
		vector<Student>left;
		vector<Student>right;
		Student pivot_val = partition(vec,left,right);
		quick_sort(left);
		quick_sort(right);
		vec = combine_vecs(left,right,pivot_val);
	}
}
/**
	Uses stdSort; Prints student and comparison information in file
*/
void stdSort(vector<Student>& campus)
{
	sort(campus.begin(),campus.end());
}
/**
	Uses std listsort(). Moves vector into a list, 
	performs sort, then prints to a file
*/
void stdListSort(vector<Student>& campus)
{
	list<Student> campus_list(campus.begin(),campus.end());
	if(!campus.empty())
	{
		campus[0].clearCount();
	}
	campus_list.sort();
}
/**
	Reads the student file
	@param ifstream& file is the student file
	@param StudentBody& campus is the list of students
*/
void read_student(ifstream& file, vector<Student>& campus)
{
	string line = "";
	string id; string name; string address; string phone_num;
	int i = 1;
	while (getline(file, line))
	{
		if(i == 1)
		{
			id = line;
		}
		else if(i == 2)
		{
			name = line;
		}
		else if(i == 3)
		{
			address = line;
		}
		else if(i == 4)
		{
			phone_num = line;
			campus.push_back(Student(name,id,phone_num,address));
			i = 0;
		}
		i++;
	}
}
/**
	Reads the query file
	@param ifstream& file is the query file
	@param vector query is the list of student ids to write out
*/
void read_query(ifstream& file, vector <string>& query)
{
	string line = "";
	while (getline(file, line))
	{
		query.push_back(line);
	}
}
/**
	Merges to vectors into sorted order (lowest to highest)
	@param left_vec - meant to be the lesser vector
	@param right_vec - meant to be the larger vector (value wise)
*/
vector<Student> merge(vector<Student> left_vec, vector<Student> right_vec)
{
	vector<Student> temp;
	unsigned int i = 0;
	unsigned int j = 0;
	while((i < left_vec.size()) && (j < right_vec.size()))
	{
		if(left_vec[i] < right_vec[j])
		{
			temp.push_back(left_vec[i]);
			i++;
		}
		else if(left_vec[i] == right_vec[j])
		{
			temp.push_back(left_vec[i]);
			temp.push_back(right_vec[j]);
			i++;
			j++;
		}
		else
		{
			temp.push_back(right_vec[j]);
			j++;
		}
	}
	while(j < right_vec.size())
	{
		temp.push_back(right_vec[j]);
		j++;
	}
	while(i < left_vec.size())
	{
		temp.push_back(left_vec[i]);
		i++;
	}
	return temp;
}
/**
	Recursive algorithm 
	@param vec will modify vec to produce a sorted vector
*/
void merge_sort(vector<Student>& vec)
{
	if(vec.size() <= 1)
	{
		return;
	}
	else
	{
		int mid_pos = vec.size()/2;
		vector<Student> left(vec.begin(), vec.begin()+mid_pos);
		vector<Student> right(vec.begin() + mid_pos,vec.end());
		merge_sort(left);
		merge_sort(right);
		vec = merge(left,right);
	}
}
/**
	Writes the title of the search or sort algorithm
*/
void write_title(ofstream& file, int type)
{
	if(type == 1)
	{
		file << "Selection Sort\n";
	}
	else if(type == 2)
	{
		file << "Insertion Sort\n";
	}
	else if(type == 3)
	{
		file << "Merge Sort\n";
	}
	else if(type == 4)
	{
		file << "Quick Sort\n";
	}
	else if(type == 5)
	{
		file << "std::sort\n";
	}
	else if(type == 6)
	{
		file << "std::list.sort\n";
	}
	else if(type == 7)
	{
		file << "Linear Search\n";
	}
	else if(type == 8)
	{
		file << "Binary Search\n";
	}
	else if(type == 9)
	{
		file << "std::find\n";
	}
	else if(type == 10)
	{
		file << "std::set.find\n";
	}
}
/**
	Writes the comparison counter to the output file stream
	clears the comparison counter
*/
void write_other(vector<Student> vec, ofstream& file)
{
	if(!vec.empty())
	{
		file << "size: " << vec.size() << "\tcompares: " << vec[0].getCount() << endl;
		vec[0].clearCount();
	}
}
/**
	Performs same operation as write_other but uses a query file to determine the size
*/
void write_search(vector<Student> vec, vector<string> query, ofstream& file)
{
	if(!vec.empty())
	{
		file << "size: " << vec.size() << "\tcompares: " << (vec[0].getCount()/query.size()) << endl;
		vec[0].clearCount();
	}
}
/**
	Modifies three lists: 1/4,1/2, and a full list based off of an original vector
	@param fourth, half, and full vectors that are modified
	@param original vector that the other three vectors are based off of
*/
void reset_list(vector<Student>& fourth, vector<Student>& half, vector<Student>& full, vector<Student> original)
{
	int four = original.size()/4;
	int two = original.size()/2;
	fourth.clear();
	half.clear();
	full.clear();
	vector<Student>::iterator it;
	it = half.begin();
	half.insert(it,original.begin(),original.begin()+two);
	vector<Student>::iterator ti;
	ti = fourth.begin();
	fourth.insert(ti,original.begin(),original.begin()+four);
	full = original;
}
/**
	Function makes three vectors of 1/4,1/2, and full size of the original vector
*/
void set_query(vector<string>& fourth, vector<string>& half, vector<string>& full, vector<string> original)
{
	int four = original.size()/4;
	int two = original.size()/2;
	fourth.clear();
	half.clear();
	full.clear();
	vector<string>::iterator it;
	it = half.begin();
	half.insert(it,original.begin(),original.begin()+two);
	vector<string>::iterator ti;
	ti = fourth.begin();
	fourth.insert(ti,original.begin(),original.begin()+four);
	full = original;
}
/**
	Searches each element until target is found to be equal to that element in the vector
	Big O(n)
*/
int linear_search(vector<Student> vec, string target)
{
	for(unsigned int i = 0; i < vec.size(); i++)
	{
		if(vec[i] == target)
		{
			return i;
		}
	}
	return -1;
}
/**
	Resursive function. Finds middle of vector, compares to target, resurses above
	if less than target and resurses below if greater than target
	Big O(logn)
*/
int binary_search(vector<Student> vec, int first, int last, string target)
{
	int middle = (first+last)/2;
	if(last < first)
	{
		return -1;
	}
	else if(vec[middle] == target)
	{
		return middle;
	}
	else if(vec[middle] > target)
	{
		return binary_search(vec, first, middle-1, target);
	}
	else
	{
		return binary_search(vec, middle+1, last, target);
	}
}
/**
	Middle man for binary search. Initialize the recursive algorithm to first at 0 and last as the size 
	of the vector minus one
*/
int binary_middle(vector<Student> vec, string target)
{
	return binary_search(vec,0,vec.size()-1,target);
}
/**
	Iterates through query vector to find positions from student vector
	using linear search
*/
vector<int> find_linear(vector<Student> vec, vector<string> query)
{
	vector<int> positions;
	for(unsigned int i = 0; i < query.size(); i++)
	{
		int temp = linear_search(vec,query[i]);
		positions.push_back(temp);
	}
	return positions;
}
/**
	Iterates through query vector to find positions from student vector
	using binary search
*/
vector<int> find_binary(vector<Student> vec, vector<string> query)
{
	//Sort first
	vector<int> positions;
	quick_sort(vec);
	if(!vec.empty())
	{
		vec[0].clearCount();
	}
	for(unsigned int i = 0; i < query.size(); i++)
	{
		int temp = binary_middle(vec,query[i]);
		positions.push_back(temp);
	}
	return positions;
}
/**
	Iteratres through query file to find student locations.
	uses stdFind function
*/
void find_stdFind(vector<Student> vec, vector<string> query)
{
	vector<Student>::iterator it;
	for(unsigned int i = 0; i < query.size(); i++)
	{
		it = find(vec.begin(),vec.end(),query[i]);
	}
}
/**
	Converts string vector to a student vector.
	Necessary to implement set.find function
*/
vector<Student> convert_string2student(vector<string> query)
{
	vector<Student> temp;
	for(unsigned int i = 0; i < query.size(); i++)
	{
		Student temp_student(query[i]);
		temp.push_back(temp_student);
	}
	return temp;
}
/**
	Iteratres through query file to find student locations.
	uses std set.find function
	pre: necessary to implement convert_string2student function on vector of strings
*/
void find_setFind(vector<Student> vec, vector<string> query)
{
	vector<Student> temp = convert_string2student(query);
	set<Student> items(vec.begin(),vec.end());
	set<Student>::iterator it;
	if(!vec.empty())
	{
		vec[0].clearCount();
	}
	for(unsigned int i = 0; i < temp.size(); i++)
	{
		it = items.find(temp[i]);
	}
}
int main(int argc, char *argv[])
{
	vector<string> query;
	vector<Student> student_list;
	
	if(argc == 4)
	{
		//Read text files
		ifstream student_file;
		student_file.open(argv[1]);
		ifstream query_file;
		query_file.open(argv[2]);
		ofstream output_file;
		output_file.open(argv[3]);
		read_query(query_file,query);
		read_student(student_file,student_list);
		
		//Create fourth of a list, half of a list, and a full list;
		vector<Student> one_fourth; vector<Student> one_half; vector<Student> full_list;
		reset_list(one_fourth,one_half,full_list,student_list);
		
		int type = 1; //Selection Sort;
		write_title(output_file,type);
		selection_sort(one_fourth);
		write_other(one_fourth,output_file);
		selection_sort(one_half);
		write_other(one_half,output_file);
		selection_sort(full_list);
		write_other(full_list,output_file);

		reset_list(one_fourth,one_half,full_list,student_list);

		type = 2; //Insertion Sort;
		write_title(output_file,type);
		insertion_sort(one_fourth);
		write_other(one_fourth,output_file);
		insertion_sort(one_half);
		write_other(one_half,output_file);
		insertion_sort(full_list);
		write_other(full_list,output_file);

		reset_list(one_fourth,one_half,full_list,student_list);

		type = 3; //Merge Sort;
		write_title(output_file,type);
		merge_sort(one_fourth);
		write_other(one_fourth,output_file);
		merge_sort(one_half);
		write_other(one_half,output_file);
		merge_sort(full_list);
		write_other(full_list,output_file);

		reset_list(one_fourth,one_half,full_list,student_list);

		type = 4; //Quick Sort;
		write_title(output_file,type);
		quick_sort(one_fourth);
		write_other(one_fourth,output_file);
		quick_sort(one_half);
		write_other(one_half,output_file);
		quick_sort(full_list);
		write_other(full_list,output_file);

		reset_list(one_fourth,one_half,full_list,student_list);

		type = 5; //std::sort;
		write_title(output_file,type);
		stdSort(one_fourth);
		write_other(one_fourth,output_file);
		stdSort(one_half);
		write_other(one_half,output_file);
		stdSort(full_list);
		write_other(full_list,output_file);

		reset_list(one_fourth,one_half,full_list,student_list);

		type = 6; //std::list.sort;
		write_title(output_file,type);
		stdListSort(one_fourth);
		write_other(one_fourth,output_file);
		stdListSort(one_half);
		write_other(one_half,output_file);
		stdListSort(full_list);
		write_other(full_list,output_file);

		reset_list(one_fourth,one_half,full_list,student_list);

		//Searches - give vector of students and vector of string
		vector<string> fourth; vector<string> half; vector<string> full;
		set_query(fourth,half,full,query);

		vector<vector<int> > positions;

		type = 7; //Linear Search
		write_title(output_file,type);
		positions.push_back(find_linear(one_fourth,fourth));
		write_search(one_fourth,fourth,output_file);
		positions.push_back(find_linear(one_half,half));
		write_search(one_half,half,output_file);
		positions.push_back(find_linear(full_list,full));
		write_search(full_list,full,output_file);

		type = 8; //Binary Search
		write_title(output_file,type);
		positions.push_back(find_binary(one_fourth,fourth));
		write_search(one_fourth,fourth,output_file);
		positions.push_back(find_binary(one_half,half));
		write_search(one_half,half,output_file);
		positions.push_back(find_binary(full_list,full));
		write_search(full_list,full,output_file);

		reset_list(one_fourth,one_half,full_list,student_list);

		type = 9; //std::find
		write_title(output_file,type);
		find_stdFind(one_fourth,fourth);
		write_search(one_fourth,fourth,output_file);
		find_stdFind(one_half,half);
		write_search(one_half,half,output_file);
		find_stdFind(full_list,full);
		write_search(full_list,full,output_file);

		type = 10; //std::set.find
		write_title(output_file,type);
		find_setFind(one_fourth,fourth);
		write_search(one_fourth,fourth,output_file);
		find_setFind(one_half,half);
		write_search(one_half,half,output_file);
		find_setFind(full_list,full);
		write_search(full_list,full,output_file);

	}
	return 0;
}