#pragma once
#include "AVL_Node.h"

template <typename T>
class BinarySearchTree
{
protected:
	AVL_Node<T>* root_node;

public:
	virtual bool insert();
	virtual bool erase();
	void rotate_left();
	void rotate_right();
	//Constructors
	/**
		Constructs an empty binary tree
	*/
	BinarySearchTree() : root(NULL) {};
	/**
		Constructs a binary tree with two subtrees
		@param T data for the root
		@param left_child
		@param right_child
	*/
	BinarySearchTree(T& data, BinarySearchTree<T>& left_child, BinarySearchTree<T>& right_child)
		: root_node(data,left_child,right_child) {};

	virtual void get_left_subtree();
	virtual void get_right_subtree();
	virtual void get_data();
	~BinarySearchTree() {}

};