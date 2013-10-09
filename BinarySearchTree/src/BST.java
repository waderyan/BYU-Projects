
public class BST <T extends Comparable<T>> {

	public BSTNode<T> _root;
	
	public BST () {
		_root = null;
	}
	
	public BST (BSTNode<T> root) {
		_root = root;
	}
	
	public BST (T data) {
		_root = new BSTNode<T>(data);
	}
	
	public BST (T[] data) {
		for (int i = 0; i < data.length; i++) {
			BSTNode<T> node = new BSTNode<T>(data[i]);
			add(node);
		}
	}
	
	public BSTNode<T> getRoot() {
		return _root;
	}
	
	public boolean contains (T data) {
		return contains(new BSTNode<T> (data));
	}
	
	public boolean contains (BSTNode<T> node) {
		return contains(node, _root);
	}
	
	private boolean contains (BSTNode<T> node, BSTNode<T> current) {
		if (current == null) {
			return false;
		} else if (node.getData().equals(current.getData())) {
			return true;
		} else if (node.getData().compareTo(current.getData()) == 1) {
			return contains (node, current.getRight());
		} else {
			return contains (node, current.getLeft());
		}
	}
	
	private void rebalanceLeft(BSTNode<T> node) {
		
	}
	
	private void rebalanceRight(BSTNode<T> node) {
		
	}
	
	public void add (T data) {
		add(new BSTNode<T>(data));
	}
	
	public void add (BSTNode<T> node) {
		add (node, _root);
	}
	
	private void add (BSTNode<T> node, BSTNode<T> current) {
		if (node.getData().compareTo(current.getData()) == 1) {
			if (current.getRight() != null) {
				add(node, current.getRight());
			}
			current.setRight(node);
		} else {
			if (current.getLeft() != null) {
				add(node, current.getLeft());
			}
			current.setLeft(node);
		}
	}
	
	public void remove (T data) {
		remove (new BSTNode<T> (data));
	}
	
	public void remove (BSTNode<T> node) {
		if (node.getData().equals(_root.getData())) {
			BSTNode<T> replace = getMax(_root.getLeft());
			if (replace == null) {
				replace = getMin(_root.getRight());
			}
			remove (replace, _root);
			_root = replace;
		} else {
			remove (node, _root);
		}
	}
	
	private BSTNode<T> getMax(BSTNode<T> current) {
		if (current == null) {
			return null;
		}
		return (current.getRight() == null) ? current : getMax(current.getRight());
	}
	
	private BSTNode<T> getMin(BSTNode<T> current) {
		if (current == null) {
			return null;
		}
		return (current.getLeft() == null) ? current : getMin(current.getLeft());
	}
	
	private void remove (BSTNode<T> node, BSTNode<T> current) {
		if (node.getData().equals(current.getRight())) {
			current.setRight(current.getRight().getRight());
		} else if (node.getData().equals(current.getLeft())){
			current.setLeft(current.getLeft().getLeft());
		} else {
			if (node.getData().compareTo(current.getData()) == 1) {
				remove (node, current.getRight());
			} else {
				remove (node, current.getLeft());
			}
		}
	}
	
	public BSTNode<T> findCommonAncestor (BSTNode<T> left, BSTNode<T> right) {
		return (_root == left || _root == right) ? null : findCommonAncestor(left, right, _root);
	}
	
	private BSTNode<T> findCommonAncestor (BSTNode<T> left, BSTNode<T> right, BSTNode<T> current) {
		if (left.getData().compareTo(current.getData()) == 1 && right.getData().compareTo(current.getData()) == -1) {
			return current;
		} else if (left.getData().compareTo(current.getData()) == 1 && right.getData().compareTo(current.getData()) == 1) {
			return findCommonAncestor(left, right, current.getRight());
		} else {
			return findCommonAncestor(left, right, current.getLeft());
		}
	}
	
	public boolean isSubtree (BST<T> subtreeCandidate) {
		return true;
	}
	
	private boolean isSubtree (BSTNode<T> subtreeNode) {
		return false;
	}
	
	public boolean isBST () {
		return isBST(_root);
	}
	
	private boolean isBST(BSTNode<T> current) {
		if (current.getLeft() == null || current.getRight() == null) {
			return true;
		}
		if (current.getLeft().getData().compareTo(current.getRight().getData()) == -1) {
			return isBST(current.getLeft()) && isBST(current.getRight());
		} else {
			return false;
		}
	}
	
	public boolean isBalanced () {
		return checkHeight (_root) != -1;
	}
	
	private int checkHeight (BSTNode<T> current) {
		if ( current == null ) {
			return 0;
		}
		
		int leftHeight = checkHeight (current.getLeft());
		if ( Math.abs(leftHeight) > 1 ) {
			return -1;
		}
		
		int rightHeight = checkHeight (current.getRight());
		if ( Math.abs(rightHeight) > 1 ) {
			return -1;
		}
		
		return Math.max(leftHeight, rightHeight) > 1 ? -1 : leftHeight + rightHeight + 1;
	}
	
	private boolean isBalanced2() {
		return false;		
	}
	
	public int size () {
		return size(_root);
	}
	
	private int size(BSTNode<T> node) {
		if (node != null) {
			return 1 + size(node.getLeft()) + size(node.getRight());
		} else {
			return 0;
		}
	}
	
	public T minValue () {
		return minValue(_root);
	}
	
	private T minValue(BSTNode<T> current) {
		if (current.getRight() == null && current.getLeft() == null) {
			return current.getData();
		} else {
			return minValue(current.getLeft());
		}
	}
	
	public String toStringInOrder() {
		return toStringInOrder("", _root);
	}
	
	private String toStringInOrder (String current, BSTNode<T> node) {
		if (node == null) {
			return current;
		}
		
		current += toStringInOrder(current, node.getLeft());
		current += toStringInOrder(current, node);
		current += toStringInOrder(current, node.getRight());
		
		return current;
	}
	
	public String toStringPreOrder () {
		return toStringPreOrder("", _root);
	}
	
	private String toStringPreOrder (String current, BSTNode<T> node) {
		if (node == null) {
			return current;
		}
		
		current += toStringInOrder(current, node);
		current += toStringInOrder(current, node.getLeft());
		current += toStringInOrder(current, node.getRight());
		
		return current;
	}
	
	public String toStringPostOrder () {
		return toStringPostOrder("", _root);
	}
	
	private String toStringPostOrder (String current, BSTNode<T> node) {
		if (node == null) {
			return current;
		}
		
		current += toStringInOrder(current, node.getLeft());
		current += toStringInOrder(current, node.getRight());
		current += toStringInOrder(current, node);
		
		return current;
	}
	
	public void toStringPaths () {
		// Paths from root to leaves
	}
	
	public boolean hasPathSum (int target) {
		return true;
	}
	
	public BST<T> mirror () {
		return null;
	}
	
	public BST<T> duplicate () {
		BSTNode<T> nodes[] = new BSTNode[this.size() + 1];
		return null;
	}
	
	public boolean equals (BST<T> other) {
		if (other.getRoot() == null) {
			return false;
		}
		return equals(_root, other.getRoot());
	}
	
	private boolean equals(BSTNode<T> node, BSTNode<T> other) {
		if (node == null && other == null) {
			return true;
		} else if ((node != null && other == null) || (node == null && other != null)){
			return false;
		}
		return node.equals(other) 
				&& equals(node.getRight(), other.getRight())
				&& equals(node.getLeft(), other.getLeft());
	}
}
