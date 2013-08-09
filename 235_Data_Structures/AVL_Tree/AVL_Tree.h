#pragma once
#include <iostream>
#include <string>
#include "AVL_Node.h"
#include "Set.h"
#include "LinkedList.h"
#include "Queue.h"

using namespace std;
/**--------------------------------------------------------------------
	AVL_Tree class
	Implements a set : Inherits from an abstract set class
	Characteristics: no duplicates; no random access; very fast finding;
---------------------------------------------------------------------**/
template <typename T> 
class AVL_Tree : public Set<T>
{
	/**---------------------------------------------------------------------
		Four Kinds of critically unbalanced trees
		Left-Left (parent balance is -2, left child balance is -1): 
			Rotate right around parent
		Left-Right (parent balance is -2, left child balance is +1): 
			Rotate left around child, then rotate right around parent
		Right-Right (parent balance is +2, right child balance is +1):
			Rotate left around parent.
		Right-Left (parent balance is +2, right child balance is -1):
			Rotate right around child, then rotate left around parent
	---------------------------------------------------------------------*/
private:
	AVL_Node<T>* root_node; //int balance, T data, left*, right*
	bool increase; //Flag that tells if a node has been added or not
	bool decrease; //Flag that tells if a node has been deleted or not
	unsigned int num_items; //Count of how many items are in the tree
	//Functions AVL Specific-----------------------------------------------
	/**---------------------------------------------------------------------
		rotate_left - Changes the node on the left side with parent
		Algorithm: Remember the value of root->right,
		set root->right to the value of root->left,
		set temp->left to root; Set root to temp
		pre: root is the root of the BST
		post: root->right is the root of a BST
			  root->right->right is raised one level
			  root->right->left does not change levels
			  root->left is lowered one level
			  root is set to the new root
		@param root is the root of the AVL Tree to be rotated
	---------------------------------------------------------------------**/
	void rotate_left(AVL_Node<T>*& root)
	{
		AVL_Node<T>* temp1 = root->right;
		AVL_Node<T>* temp = temp1->left;
		temp1->left = root;
		root->right = temp;
		//AVL_Node<T>* temp = root->right; //Stores right sub tree in temp node
		//root->right = temp->left; // Assigns right sub tree to temps left sub tree the left sub tree of the right sub tree
		//temp->left = root; //Assign left sub tree to the root node
		//root = temp; //Assign the root node to the temp node (which is the right sub tree)
		set_height(root);
		set_height(temp1);
		root = temp1;
	}
	/**---------------------------------------------------------------------
		rotate_right - Changes the nodes on the right side with parent
		Algorithm: Remember the value of root->left, 
		set root->left to the value of root->right,
		set temp->right to root; Set root to temp
		pre: root is the root of the BST
		post: root->left is the root of a BST
			  root->left->left is raised one level
			  root->left->right does not change levels
			  root->right is lowered one level
			  root is set to the new root
		@param root is the root of the AVL Tree to be rotated
	---------------------------------------------------------------------**/
	void rotate_right(AVL_Node<T>*& root)
	{
		AVL_Node<T>* temp1 = root->left;
		AVL_Node<T>* temp2 = temp1->right;
		temp1->right = root;
		root->left = temp2;
		//AVL_Node<T>* temp = root->left;	
		//root->left = temp->right;
		//temp->right = root;
		//root = temp;
		set_height(root);
		set_height(temp1);
		root = temp1;
	}
	/**---------------------------------------------------------------------
		rebalance_left - rebalances a critically left heavy tree
		Algorithm: 
		if the left subtree has a postive balance (left-right case)
			if the left-right subtree has a negative balance (left-right-left case)
				set the left subtree(new left subtree) balance to 0
				set the left-right*(changed) subtree (new root) balance to 0
				set the local root (new right subtree) balance to +1
			else if the left-right subtree has a positive balance (left-right-right case)
				set the left subtree balance to -1
				set the left-left subtree balance to 0
				set the local root balance to 0
			else (left-right balance case)
				set the left subtree balance to 0
				set the left-left subtree balance to 0
				set the local root balance to 0
			rotate the left subtree left
		else left left case
			set the left subtee balance to 0
			set the local root balance to 0
		rotate the local root right
	---------------------------------------------------------------------**/
	void rebalance_left(AVL_Node<T>*& root)
	{
		if(root->left->get_balance() > 0) //left-right case
		{
			if(root->left->right->get_balance() < 0) //Left-Right-Left case 
			{
				//root->height -= 2;
				//root->left->height -= 2;
				//root->right->left->height++;
			}
			else if(root->left->right->get_balance() > 0)//Left-Right-Right case
			{
				//root->height--;
				//root->left->height--;
				//root->left->right->height--;
			}
			else //Left-Right-Balanced case
			{
				//root->height--;
				//root->left->height--;
				//root->left->right->height++;
			}
			rotate_left(root->left); //Rotate the left subtree left
		}
		else //left-left case (parent balance -2, left child balance is -1)
		{
			//root->height--;
		}
		rotate_right(root); //Rotate root right
	}
	/**---------------------------------------------------------------------
		rebalance_right - Rebalances a critically right heavy tree 
		Algorithm: 
		if the right subtree has a postive balance (right-right case)
			if the right-right subtree has a negative balance (right-right-left case)
				set the right subtree balance to 0
				set the right-right subtree balance to 0
				set the local root balance to +1
			else if the right-right subtree has a positive balance (right-right-right case)
				set the right subtree balance to -1
				set the right-right subtree balance to 0
				set the local root balance to 0
			else (right-right balance case)
				set the right subtree balance to 0
				set the right-right subtree balance to 0
				set the local root balance to 0
			rotate the right subtree right
		else right left case
			set the right subtee balance to 0
			set the local root balance to 0
		rotate the local root left
	
	---------------------------------------------------------------------*/
	void rebalance_right(AVL_Node<T>*& root)
	{
		if(root->right->get_balance() < 0) //right-left case? (balance positive)
		{
			if(root->right->left->get_balance() < 0)//right-left-left case? (balance negative)
			{
				//root->height -= 2;
				//root->right->height -= 2;
				//root->right->left->height++;
			}
			else if(root->right->left->get_balance() > 0) //right-left-right case? (balance positive)
			{
				//root->height--;
				//root->right->height--;
				//root->right->left->height--;
			}
			else //is it a right left balanced case
			{
				//root->height--;
				//root->height--;
				//root->right->height--;
				//root->right->left->height++;
				//root->right->left->height++;
			}
			rotate_right(root->right); //Rotate right subtree right
		}
		else //Right-right case
		{
			//root->height--;
			//root->right->height--;
			//root->right->right->height += 0; just a reference
		}
		rotate_left(root); //Rotate root left to take care of right heaviness
	}
	//Implemented Set Recursive Methods
	/**---------------------------------------------------------------------
	insert - places a new item in the tree
	Algorithm: (adapted from book)
	if the root is NULL
		create a new tree with the item at the root and return true
	else if the item is less than the root-> data
		recursivley insert he item in the left subtree
		if the height of the left subtree has increased 
			Decrement balance
			if balance is zero, reset increase to false
			if balance is less than -1
				reset increase to false
				perform rebalanceleft
	else if the item is greater than root->data
		symmetric algorithm to if less than. Increment balance if increase is true
	else (the item is already in the list)
		increase = false and return false
	---------------------------------------------------------------------**/
	void add(AVL_Node<T>*& root, T item)
	{
		if(root == NULL) //Tree is empty - base case
		{
			root = new AVL_Node<T>(item); //Make a new node with right and left NULL
			increase = true; //Set increase flag to true
			num_items++;
			root->height = 1;
			return;
		}
		else if(item < root->data) //Going to add to left sub tree (becasue it is less)
		{
			add(root->left, item); //Recursively add item to left subtree
			set_height(root);
			//Rebalance tree - When we add to the left sub tree balance is decreased by one
			if(increase) //if increase flag is true
			{
				if(absolute(root->get_balance()) >= 2)
				{
					rebalance_left(root); //Rotate the root to the left
				}
			}
			//root->height = find_height(root->left, root->right); //Finds the height based off of the two sub trees
			return; //Return the result
		}
		else if(item > root->data) //Going to add to right sub tree (becasue it is greater)
		{
			add(root->right, item); //Recursively add item to right subtree
			set_height(root);
			//Rebalance tree - when we add to the right sub tree balance is increased by one
			if(increase) //if increase flag is true
			{
				if(absolute(root->get_balance()) >= 2) //Looking at the roots balance
				{
					rebalance_right(root); //Rebalance it because it is critically right heavy
				}
			}
			//root->height = find_height(root->left, root->right); //Finds the height based off of the two sub trees
			return; //Return result of recursion
		}
		else //Item is already in the tree - base case
		{
			increase = false; //Set flag to false
			return;
		}
	}
	/**---------------------------------------------------------------------
		erase - removes an item from the tree
		Algorithm: 
		if the root is NULL
			there are no items in the list. return false
		else if the item is less than the root data
			recursivley search erase the left subtree
			if the height of the left subtree has decreased
				??? () switch(root->balance) //Looking at root's balance
				case 0 : //If it is zero 
					root->balance = 1; //Then increment to make right heavy
					break;
				case 1 : //If it is one
					root->balance = 0; //Then decrement to make balanced
					increase = false; //Set increase flag to false
					break;
				case -1 : //If it is left heavy then it is critically unbalanced on the left
					rebalance_left(root); //Rotate the root to the left
					increase = false; //Set increase flag to false
					break;
		else if the item is greater than the root data
			recursivley search erase the right subtree
			if the height of the right subtree has decreased
		else the item equals root->data
			AVL_Node<T>* old_root = root;
			if(root->left == NULL)
				root = root->right;
			else if root->right == NULL
				root = root->left;
			else
				replace_root(...)
			delete old_root;
			return true;
			
	---------------------------------------------------------------------**/
	void remove(AVL_Node<T>*& root, T item)
	{
		if(root == NULL)//Is this path a dead end?
		{
			decrease = false;
			return; //Item is not here
		}
		else
		{
			if(item < root->data) //Is the item less than the root data? 
			{
				remove(root->left,item);//Recursively search the left subtree
				set_height(root);
				//Rebalance the tree - When we remove from left sub tree balance of root is increased by one
				if(decrease) //Did the tree decrease in size?
				{
					
					if(absolute(root->get_balance()) >= 2) //Looking at the roots balance
					{
						rebalance_right(root); //Rebalance it because it is critically right heavy
					}
				}
				//root->height = find_height(root->left, root->right); //Finds the height based off of the two sub trees
				return;
			}
			else if(item > root->data)//Is the item greater than the root data?
			{
				remove(root->right,item);//Recursivley search the right subtree
				//Rebalance the tree - When we remove from right sub tree balance of root is decreased
				set_height(root);
				if(decrease) //Did the tree decrease in size?
				{
					if(absolute(root->get_balance()) >= 2) //Looking at the roots balance
					{
						rebalance_left(root); //Rebalance it because it is critically right heavy
					}	
				}
				//root->height = find_height(root->left, root->right); //Finds the height based off of the two sub trees
				return;
			}
			else //This is the item we are looking for
			{
				delete_node(root); //Calls a delete function
				decrease = true;
				return;
			}
			return;
		}
	}
	/**---------------------------------------------------------------------
		find - finds a specified item recursively
		@param root that we are searching
		@param item searching for
		Return: returns true if it is found, false otherwise
		Binary Search algorithm
		if the root is NULL
			The item is not in the tree return NULL
		compare the value of target, the item begin sought with, root->data
		if they are equal
			The target has been found, return the data of the root
		else if the target is less than root->data 
			Return recursing through the left subtree
		else
			return recursing through the right subtree
	---------------------------------------------------------------------*/
	bool find(AVL_Node<T>*& root, T item)
	{
		bool result = false; //Need to initially set to false because it is initially set to true by the compiler
		if(root == NULL) //TThere are no items in the list
		{
			return false;
		}
		if(item < root->data) //Is the item less than the root data?
		{
			result = find(root->left,item);//Recursively search the left subtree
		}
		else if(item > root->data)//the item is greater than the root data
		{
			result = find(root->right,item);//Recursivley search the right subtree
		}
		else//This is the item we are looking for
		{
			return true; //Return that it is found
		}
		return result;
	}
	AVL_Node<T>* finder(AVL_Node<T>*& root, T item)
	{
		//bool result = false; //Need to initially set to false because it is initially set to true by the compiler
		AVL_Node<T>* temp = NULL;
		if(root == NULL) //TThere are no items in the list
		{
			return NULL;
		}
		if(item < root->data) //Is the item less than the root data?
		{
			temp = finder(root->left,item);//Recursively search the left subtree
		}
		else if(item > root->data)//the item is greater than the root data
		{
			temp = finder(root->right,item);//Recursivley search the right subtree
		}
		else//This is the item we are looking for
		{
			return root; //Return that it is found
		}
		return temp;
	}
	/**---------------------------------------------------------------------
		clear - clears all the item in the tree
	---------------------------------------------------------------------*/
	void clear(AVL_Node<T>*& node)
	{
		while(node != NULL)
		{
			delete_node(node);
		}
	}
	//Helper Functions------------------------------------------------------
	int get_height(AVL_Node<T>* node)
	{
		if(node == NULL)
		{
			return 0;
		}
		else
		{
			return node->height;
		}
	}
	void set_height(AVL_Node<T>*& node)
	{
		node->height = max(get_height(node->left),get_height(node->right)) +1;
	}
	/**---------------------------------------------------------------------
		delete-node - removes the node and replaces the tree structure
		@param node that we are removing
		Returns a deleted node for three cases
		Returns a recursive remove for one case
		
		Algorithm
		if leaf node case
			Then delete node
		else if two children case
			replace with smallest node in right subtree
			remove smallest node in right subtree
		else if child on right case
			connect parent to child
		else child on left case
			connect parent to child
	---------------------------------------------------------------------*/
	void delete_node(AVL_Node<T>*& node)
	{
		if(node->left == NULL && node->right == NULL) //Leaf node case
		{
			delete node; //delete the node
			node = NULL; //set it to NULL
			num_items--; //reduce the number of items
			decrease = true;
			return;
		}
		else if(node->left != NULL && node->right != NULL) //Two children case
		{
			AVL_Node<T>* temp = get_min_node(node->right); //Search for the smallest node on the right sub tree
			node->data = temp->data; //Set the node data to temp data
			remove(node->right, temp->data); //Remove the lowest value on the right sub tree
			//num_items-- and decrease flag will be set with the above remove function
			return;
		}
		else if(node->left == NULL && node->right != NULL) //Child on right case
		{
			AVL_Node<T>* temp = node; //Create a temp node
			node = node->right; //Point the node to its child
			decrease = true; //Set the decrease flag
			num_items--; //Reduce the number of items
			temp->right = NULL; //Point the node we are going to delete to NULL 
			temp->left = NULL;
			delete temp; //Delete the node
			return;
		}
		else //Child on left case
		{
			AVL_Node<T>* temp = node; //Same idea as above with child on right case
			node = node->left;
			decrease = true;
			num_items--;
			temp->right = NULL;
			temp->left = NULL;
			delete temp;
			return;
		}
	}
	/**---------------------------------------------------------------------
		find_min_node - search for the minimum position in the right subtree
		Algorithm 
		if left subtree is empty 
			return the node
		else if left subtree is not emptry
			recursively search down the left subtree until it is not empty
	---------------------------------------------------------------------*/
	AVL_Node<T>* get_min_node(AVL_Node<T>* node)
	{
		if(node->left == NULL) //Is there any children on the left (that are less)
		{
			return node; //Then return that node because its data is the smallest
		}
		else
		{
			return get_min_node(node->left); //Continue searching the left side recursively
		}
	}
	/**---------------------------------------------------
		find_height- finds the sub tree with the largest
		height and adds one. 
		pre: can never pass to NULL sub trees into this funciton
		@param - AVL_Node* left sub tree
		@param - AVL_Node* right subt tree
		Returns height to be assigned to the parent node
	---------------------------------------------------**/
	int find_height(AVL_Node<T>* left_sub_tree, AVL_Node<T>* right_sub_tree)
	{
		int height = 1; //Initial assignment of height
		if(left_sub_tree != NULL && right_sub_tree != NULL) //There are two children nodes
		{
			if(left_sub_tree->height > right_sub_tree->height) //Compare left and right sub tree heights
				height = left_sub_tree->height; //If left sub tree is greater than assign to height
			else
				height = right_sub_tree->height; //If right sub tree is greater or they are equal assign to height
			return ++height; //Add one as we return to give us the parent node's height
		}
		else if(left_sub_tree != NULL && right_sub_tree == NULL) //There is one child node on the left side
		{
			return left_sub_tree->height + 1;
		}
		else if(left_sub_tree == NULL && right_sub_tree != NULL) //There is one child node on the right side
		{
			return right_sub_tree->height + 1;
		}
		else //There are no children - this is a bad use of the function
		{
			return height;
		}
		
	}
	/**--------------------------------------------------------------------
	---------------------------------------------------------------------**/
	void print_level_order(ofstream& file, AVL_Node<T>* root)
	{
		bool level_change = true;
		int level = 0; int print_count = 0;
		Queue<AVL_Node<T>*>* current = new LinkedList<AVL_Node<T>*>();
		Queue<AVL_Node<T>*>* next = new LinkedList<AVL_Node<T>*>();
		current->enqueue(root);
		while(current->size() != 0)
		{
			AVL_Node<T>* temp = current->dequeue();
			if(temp == NULL)
				continue;
			if(temp->left != NULL)
				next->enqueue(temp->left); //Put left child in next level Q
			if(temp->right != NULL)
				next->enqueue(temp->right); //Put right child in next level Q
			if(level_change)
			{
				file << "level " << level << ": ";
				level_change = false;
			}
			format_print(file,temp,level); //Print
			print_count++; //Increment print count
			if(current->size() == 0) //Check to see if current level is empty
			{
				 //If it is empty then put in the contents of next level Q
				move_contents(current,next);
				level++;
				print_count = 0;
				file << '\n';
				level_change = true;
			}
			if(print_count == 8)
			{
				print_count = 0;
				file << '\n';
			}
		}
		delete current;
		delete next;
	}
	/**--------------------------------------------------------------------
	---------------------------------------------------------------------**/
	void format_print(ofstream& file, AVL_Node<T>* node, int level)
	{
		file << node->data << "(" << node->height << ") "; //Correct format
	}
	/**--------------------------------------------------------------------
		pre: current should be empty to begin with
	---------------------------------------------------------------------**/
	void move_contents(Queue<AVL_Node<T>*>*& current, Queue<AVL_Node<T>*>*& next)
	{
		while(next->size() != 0)
		{
			AVL_Node<T>* temp = next->dequeue();
			current->enqueue(temp);
		}
	}
	/**-----------------------------------------------------------------
		split - splits the avl tree in two
		deletes half of the nodes
		@param node
	------------------------------------------------------------------**/
	void split(AVL_Node<T>*& node)
	{
		for(int to_delete = num_items/2; to_delete != 0; to_delete--)
		{
			delete_node(node);
		}
	}
	/**-----------------------------------------------------------------
		copy_tree - 
	------------------------------------------------------------------**/
	void copy(AVL_Node<T>* root, Set<T>*& other)
	{
		Queue<AVL_Node<T>*>* current = new LinkedList<AVL_Node<T>*>();
		Queue<AVL_Node<T>*>* next = new LinkedList<AVL_Node<T>*>();
		current->enqueue(root);
		while(current->size() != 0)
		{
			AVL_Node<T>* temp = current->dequeue();
			if(temp == NULL)
				continue;
			other->add(temp->data); //Add the data of temp to the new tree
			next->enqueue(temp->left); //Put left child in next level Q
			next->enqueue(temp->right); //Put right child in next level Q
			if(current->size() == 0) //Check to see if current level is empty
			{
				 //If it is empty then put in the contents of next level Q
				move_contents(current,next);
			}
		}
		//Result should be another tree (other) with the same nodes as the original tree
	}
	/**----------------------------------------------------------------
		absolute - returns absolute value
	-----------------------------------------------------------------**/
	int absolute(int number)
	{
		if(number < 0)
		{
			return -(number);
		}
		else
		{
			return number;
		}
	}
public:
	//Constructors----------------------------------------------------------
	/**---------------------------------------------------------------------
		Constructs an empty binary tree
	---------------------------------------------------------------------*/
	AVL_Tree()
	{
		root_node = NULL;
		num_items = 0;
	}
	/**---------------------------------------------------------------------
		Constructs a binary tree with two subtrees
		@param T data for the root
		@param left_child
		@param right_child
	---------------------------------------------------------------------*/
	AVL_Tree(T& data, AVL_Tree<T>& left_child, AVL_Tree<T>& right_child)
		: root_node(data,left_child,right_child) {}
	//Set inhertited methods-----------------------------------------------------
	/**---------------------------------------------------------------------
		add - middle man function that calls AVL_node insert
		@param item to add to the tree
	---------------------------------------------------------------------*/
	virtual void add(T item);
	/**---------------------------------------------------------------------
		remove - middle man function that calls AVL_node erase
		@param item to remove from tree
	---------------------------------------------------------------------*/
	virtual void remove(T item);
	/**---------------------------------------------------------------------
		clear - middle man that calls AVL clear on the root node
		Returns: an empty AVL tree
	---------------------------------------------------------------------*/
	virtual void clear();
	/**---------------------------------------------------------------------
		find - middle man algorithm that calls a recursive function
		@param item to be searched for
		Returns: result of search : true or false
	---------------------------------------------------------------------*/
	virtual bool find(T item);
	virtual void print(ofstream& file);
	/**--------------------------------------------------------------
		get_size - returns the number of items in the set
	---------------------------------------------------------------**/
	virtual unsigned int get_size() 
	{
		return num_items;
	}
	/**--------------------------------------------------------------
		get_root_data - returns the data of the root node
	---------------------------------------------------------------**/
	virtual T get_root_data()
	{
		return this->root_node->data;
	}
	/**-----------------------------------------------------------------
		split - middle man function that calls AVL_Tree split
	------------------------------------------------------------------**/
	virtual void split()
	{
		split(this->root_node);
	}
	/**-----------------------------------------------------------------
		copy - copys the parameter from the original tree
	------------------------------------------------------------------**/
	virtual void copy(Set<T>*& other)
	{
		copy(this->root_node,other);
	}
	virtual T get_left_child(T item)
	{
		AVL_Node<T>* root = finder(this->root_node, item);
		if(root == NULL)
		{
			throw out_of_range("item not here");
		}
		else
		{
			if(root->left != NULL)
			{
				return root->left->data;
			}
			else
			{
				throw out_of_range("no left child");
			}
		}
	}
	virtual T get_right_child(T item)
	{
		AVL_Node<T>* root = finder(this->root_node, item);
		if(root == NULL)
		{
			throw out_of_range("item not here");
		}
		else
		{
			if(root->right != NULL)
			{
				return root->right->data;
			}
			else
			{
				throw out_of_range("no left child");
			}
		}
	}
	virtual int get_height(T item)
	{
		AVL_Node<T>* temp = finder(this->root_node, item);
		if(temp != NULL)
		{
			return temp->height;
		}
		else
		{
			return 0;
		}
	}
	virtual int get_size(T item)
	{
		return num_items;
	}
	~AVL_Tree()
	{
		clear();
	}
};
/**---------------------------------------------------------------------
	add - middle man function that calls AVL_node insert
	@param item to add to the tree
---------------------------------------------------------------------*/
template<typename T>
void AVL_Tree<T>::add(T item)
{
	add(this->root_node,item);
}
/**---------------------------------------------------------------------
	remove - middle man function that calls AVL_node erase
	@param item to remove from tree
---------------------------------------------------------------------*/
template <typename T>
void AVL_Tree<T>::remove(T item)
{
	remove(this->root_node,item);
}
/**---------------------------------------------------------------------
	clear - middle man that calls AVL clear on the root node
	Returns: an empty AVL tree
---------------------------------------------------------------------*/
template <typename T>
void AVL_Tree<T>::clear()
{
	clear(this->root_node);
}
/**---------------------------------------------------------------------
	find - middle man algorithm that calls a recursive function
	@param item to be searched for
	Returns: result of search : true or false
---------------------------------------------------------------------*/
template <typename T>
bool AVL_Tree<T>::find(T item)
{
	return find(this->root_node,item);
}
/**---------------------------------------------------------------------
	print - 
---------------------------------------------------------------------*/
template <typename T>
void AVL_Tree<T>::print(ofstream& output)
{
	print_level_order(output,this->root_node);
}
