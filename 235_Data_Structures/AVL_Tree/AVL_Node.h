#pragma once

template<typename T>
class AVL_Node
{
public:
	int balance; //This is the balance factor
	int height; //This is the height of the node in the tree
	T data; //Data contained in the node
	AVL_Node* left; //Pointer to the left sub tree - which is less than
	AVL_Node* right; //Pointer to the right sub tree - which is greater than
public:
	/**------------------------------------------------
		Constructs an new AVL_Node
		The data is placed in the node and the left and right sub trees are set to NULL
		Balance and height are also set to zero to begin with
	--------------------------------------------------**/
	AVL_Node(T& new_data, AVL_Node<T>* new_left = NULL, AVL_Node<T>* new_right = NULL) : 
	data(new_data), left(new_left), right(new_right), balance(0), height(0) {}
	/**--------------------------------------------------------
	set_balance - determines the balance of the node
	---------------------------------------------------------**/
	int get_balance()
	{
		if(right != NULL && left != NULL)
		{
			balance = (right->height - left->height);
		}
		else if(right != NULL && left == NULL)
		{
			balance = right->height;
		}
		else if(right == NULL && left != NULL)
		{
			balance = -(left->height);
		}
		else
		{
			balance = 0;
		}
		return balance;
	}

	//Destructor
	~AVL_Node() {}
};