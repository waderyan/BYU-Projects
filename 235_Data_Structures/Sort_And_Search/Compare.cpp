#include <iostream>
#include "Student.h"
#include <vector>
#include <string>
#include <fstream>
#include <algorithm>
#include <set>
#include <list>


/*******************************************************************
* Author: Wade Anderson
* 
* If you are a BYU student honor code beware! In other words don't
* copy this code! Code it yourself if you really want to learn.
* 
*
* Also no gaurantee these functions work. I am in the middle of a large
* refactoring. Hope to have time to finsh it.
*
*********************************************************************/


using namespace std;

class Searcher <T> {

private:
	/**
		Returns the position of the target or -1
		@param {vector<T>} list - sorted list
		@param {int} first 
		@param {int} last
		@param {T} target
	*/
	int binary_searchRec(std::vector<T> lst, int first, int last, T target) {
		
		if(last < first) {
			return -1;
		}

		size_t middle = (first+last) / 2;
		
		if(lst[middle] == target) {
			return middle;
		} else if(lst[middle] > target) {
			return binary_search(lst, first, middle - 1, target);
		} else {
			return binary_search(lst, middle + 1, last, target);
		}
	}

public:

	/**
		Searches each element until target is found to be equal to that element in the vector
		Big O(n)
	*/
	int linear_search(std::vector<T> students, T target) {
		for(size_t i = 0; i < students.size(); i++) {
			if(students[i] == target) {
				return i;
			}
		}
		return -1;
	}
	

	/**
	* Returns the position of the target or -1 if target is not in list.
	*/
	int binary_searchIter(std::vector<T> lst, T target) {

		size_t lower = 0;
		size_t upper = students.size();

		while (lower < upper) {

			size_t mid = (upper + lower) / 2;

			if (lst[mid] < target) {
				upper = mid - 1;
			} else if (list[mid] > target) {
				lower = mid + 1;
			} else {
				return mid;
			}
		}

		return -1;
	}

	/**
		Middle man for binary search. Initialize the recursive algorithm to first at 0 and last as the size 
		of the vector minus one
	*/
	int binary_searchR(vector<T> lst, T target) {
		return binary_searchRec(lst, 0, lst.size()-1, target);
	}

	/**
		Iteratres through query file to find student locations.
		uses std set.find function
		pre: necessary to implement convert_string2student function on vector of strings
	*/
	void find_setFind(vector<T> lst, vector<string> query)
	{
		vector<T> temp = convert_string2student(query);
		set<T> items(lst.begin(), lst.end());
		set<T>::iterator it;

		if(!lst.empty()) {
			lst[0].clearCount();
		}

		for(size_t i = 0; i < temp.size(); i++){
			it = items.find(temp[i]);
		}
	}
};

class Sorter {
private:

	/**
		Finds the minimum position of an element
		Average Big O is O(n)
		@param vector of students
		@param first element to start search
		@param last element to end search
	*/
	int find_min(vector<T> students, int first, int last) {
		int min_pos = first;
		for(int i = first; i < last; i++) {
			if(students[i] < students[min_pos]) {
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
	void switch_elements(vector<Student>& students, int a, int b) {
		Student temp = students[a];
		students[a] = students[b];
		students[b] = temp;
	}

	/**
		Combines two vectors and a pivot value into one vector
	*/
	vector<Student> combine_vecs(vector<Student> left, vector<Student> right, Student pivot_val) {
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
	Student partition(vector<Student> students, vector<Student>& left, vector<Student>& right {
		int pivot_pos = students.size()/2;
		Student pivot_val = students[pivot_pos];
		bool same = false;

		for(size_t i = 0; i < students.size(); i++) {
			if(students[i] < pivot_val) {
				left.push_back(students[i]);
			} else if(students[i] == pivot_val) {
				if(same) {
					left.push_back(students[i]);
				}
				same = true;
			} else {
				right.push_back(students[i]);
			}
		}
		return pivot_val;
	}

public:

	/**
		Finds the minimum position of the vector and moves the element to the front
		Iterates through the rest of the vector repeating above step
		Big O(n^2) best, worst, and average;
	*/
	void selection_sort(vector<Student>& students) {
		int min_pos = 0;
		int last_pos = students.size() -1;
		for(size_t i = 0; i < students.size(); i++)
		{
			min_pos = find_min(students, i, last_pos);
			switch_elements(students, i, min_pos);
		}
	}

	/**
		Iterates through vector and brings the element to the proper place in the list
		Big O(n) best case; Big O(n^2) average and worst case;
		Usually thought of as one of the fastest
	*/
	void insertion_sort(vector<Student>& students) {
		for(size_t i = 1; i < students.size(); i++)
		{
			size_t j = i;
			while(j > 0 && students[j-1] > students[j])
			{
				switch_elements(students, j, (j-1));
				j--;
			}
		}
	}

	/**
		Sorts the students using quick sort algorithm
		@param students of students
	*/
	void quick_sort(vector<Student>& students) {
		if(students.size() > 1) {
			vector<Student> left;
			vector<Student> right;

			Student pivot_val = partition(students,left,right);

			quick_sort(left);
			quick_sort(right);

			students = combine_vecs(left,right,pivot_val);
		} 
	}

	/**
		Merges two vectors into sorted order (lowest to highest)
		@param left_vec - meant to be the lesser vector
		@param right_vec - meant to be the larger vector
	*/
	vector<Student> merge(vector<Student> left_vec, vector<Student> right_vec) {
		vector<Student> temp;
		size_t i = 0;
		size_t j = 0;

		while((i < left_vec.size()) && (j < right_vec.size())) {
			if(left_vec[i] < right_vec[j]) {
				temp.push_back(left_vec[i]);
				i++;
			} else if(left_vec[i] == right_vec[j]) {
				temp.push_back(left_vec[i]);
				temp.push_back(right_vec[j]);
				i++;
				j++;
			} else {
				temp.push_back(right_vec[j]);
				j++;
			}
		}
		while(j < right_vec.size()) {
			temp.push_back(right_vec[j]);
			j++;
		}
		while(i < left_vec.size()) {
			temp.push_back(left_vec[i]);
			i++;
		}
		return temp;
	}

	/**
		Returns a sorted list
		@param students will modify students to produce a sorted vector
	*/
	void merge_sort(vector<Student>& students) {
		if(students.size() > 1) {
			size_t mid_pos = students.size() / 2;

			vector<Student> left(students.begin(), students.begin()+mid_pos);
			vector<Student> right(students.begin() + mid_pos,students.end());

			merge_sort(left);
			merge_sort(right);

			students = merge(left,right);
		}
	}

	void stdSort(vector<Student>& campus) {
		sort(campus.begin(),campus.end());
	}

	void stdListSort(vector<Student>& campus) {
		list<Student> campus_list(campus.begin(),campus.end());
		if(!campus.empty()) {
			campus[0].clearCount();
		}
		campus_list.sort();
	}

	

};


class StudentFileReader {

public:
	/**
		Reads the student file
		@param ifstream& file is the student file
		@param StudentBody& campus is the list of students
	*/
	void read_student(ifstream& file, vector<Student>& campus) {
		string line, id, name, address, phone_num;

		for (size_t i = 1; getline(file, line); i++) {
			switch (i) {
				case 1: 
					id = line;
					break;
				case 2:
					name = line;
					break;
				case 3:
					address = line;
					break;
				case 4:
					phone_num = line;
					campus.push_back(Student(name, id, phone_num, address));
					i = 0;
					break;
			}
		}
	}

	/**
		Reads the query file
		@param ifstream& file is the query file
		@param vector query is the list of student ids to write out
	*/
	void read_query(ifstream& file, vector<string>& query) {
		string line = "";
		while (getline(file, line)) {
			query.push_back(line);
		}
	}
		
};

class ComparisonWriter {
public:
	/**
		Writes the comparison counter to the output file stream
		clears the comparison counter
	*/
	void write_other(vector<Student> students, ofstream& file) {
		if(!students.empty()) {
			file << "size: " << students.size() << "\tcompares: " << students[0].getCount() << endl;
			students[0].clearCount();
		}
	}

	/**
		Performs same operation as write_other but uses a query file to determine the size
	*/
	void write_search(vector<Student> students, vector<string> query, ofstream& file) {
		if(!students.empty()) {
			file << "size: " << students.size() << "\tcompares: " << (students[0].getCount() / query.size()) << endl;
			students[0].clearCount();
		}
	}
};



/**
	Modifies three lists: 1/4,1/2, and a full list based off of an original vector
	@param fourth, half, and full vectors that are modified
	@param original vector that the other three vectors are based off of
*/
void reset_list(vector<Student>& fourth, vector<Student>& half, vector<Student>& full, vector<Student> original) {
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
void set_query(vector<string>& fourth, vector<string>& half, vector<string>& full, vector<string> original) {
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
	Iterates through query vector to find positions from student vector
	using linear search
*/
vector<int> find_linear(vector<Student> students, vector<string> query)
{
	vector<int> positions;
	for(size_t i = 0; i < query.size(); i++) {
		int temp = linear_search(students,query[i]);
		positions.push_back(temp);
	}
	return positions;
}

/**
	Iterates through query vector to find positions from student vector
	using binary search
*/
vector<int> find_binary(vector<Student> students, vector<string> query) {

	vector<int> positions;
	quick_sort(students);
	if(!students.empty()) {
		students[0].clearCount();
	}
	for(size_t i = 0; i < query.size(); i++) {
		int temp = binary_search(students,query[i]);
		positions.push_back(temp);
	}
	return positions;
}

/**
	Iterates through query file to find student locations.
	uses stdFind function
*/
void find_stdFind(vector<Student> students, vector<string> query) {
	vector<Student>::iterator it;
	for(size_t i = 0; i < query.size(); i++) {
		it = find(students.begin(),students.end(),query[i]);
	}
}

/**
	Converts string vector to a student vector.
	Necessary to implement set.find function
*/
vector<Student> convert_string2student(vector<string> query {
	vector<Student> temp;

	for(size_t i = 0; i < query.size(); i++) {
		Student temp_student(query[i]);
		temp.push_back(temp_student);
	}
	return temp;
}


int main(int argc, char *argv[]) {
	
	if(argc != 4) {
		return -1;
	}

	vector<string> query;
	vector<Student> student_list;

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
	
	output_file << "Selection Sort\n";
	selection_sort(one_fourth);
	write_other(one_fourth,output_file);
	selection_sort(one_half);
	write_other(one_half,output_file);
	selection_sort(full_list);
	write_other(full_list,output_file);

	reset_list(one_fourth,one_half,full_list,student_list);

	
	output_file << "Insertion Sort\n";
	write_title(output_file,type);
	insertion_sort(one_fourth);
	write_other(one_fourth,output_file);
	insertion_sort(one_half);
	write_other(one_half,output_file);
	insertion_sort(full_list);
	write_other(full_list,output_file);

	reset_list(one_fourth,one_half,full_list,student_list);

	output_file << "Merge Sort\n";
	write_title(output_file,type);
	merge_sort(one_fourth);
	write_other(one_fourth,output_file);
	merge_sort(one_half);
	write_other(one_half,output_file);
	merge_sort(full_list);
	write_other(full_list,output_file);

	reset_list(one_fourth,one_half,full_list,student_list);

	output_file << "Quick Sort\n";
	quick_sort(one_fourth);
	write_other(one_fourth,output_file);
	quick_sort(one_half);
	write_other(one_half,output_file);
	quick_sort(full_list);
	write_other(full_list,output_file);

	reset_list(one_fourth,one_half,full_list,student_list);

	output_file << "Std Sort\n";
	stdSort(one_fourth);
	write_other(one_fourth,output_file);
	stdSort(one_half);
	write_other(one_half,output_file);
	stdSort(full_list);
	write_other(full_list,output_file);

	reset_list(one_fourth,one_half,full_list,student_list);

	output_file << "List Sort\n";
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

	output_file << "Linear Search\n";	
	positions.push_back(find_linear(one_fourth,fourth));
	write_search(one_fourth,fourth,output_file);
	positions.push_back(find_linear(one_half,half));
	write_search(one_half,half,output_file);
	positions.push_back(find_linear(full_list,full));
	write_search(full_list,full,output_file);

	output_file << "Binary Search\n";
	positions.push_back(find_binary(one_fourth,fourth));
	write_search(one_fourth,fourth,output_file);
	positions.push_back(find_binary(one_half,half));
	write_search(one_half,half,output_file);
	positions.push_back(find_binary(full_list,full));
	write_search(full_list,full,output_file);

	reset_list(one_fourth,one_half,full_list,student_list);

	output_file << "std::find\n";
	find_stdFind(one_fourth,fourth);
	write_search(one_fourth,fourth,output_file);
	find_stdFind(one_half,half);
	write_search(one_half,half,output_file);
	find_stdFind(full_list,full);
	write_search(full_list,full,output_file);

	output_file << "set::find\n";
	find_setFind(one_fourth,fourth);
	write_search(one_fourth,fourth,output_file);
	find_setFind(one_half,half);
	write_search(one_half,half,output_file);
	find_setFind(full_list,full);
	write_search(full_list,full,output_file);

	return 0;
}