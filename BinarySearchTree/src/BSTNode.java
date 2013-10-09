
public class BSTNode<T extends Comparable<T>> {

	private BSTNode<T> _left;
	private BSTNode<T> _right;
	private T _data;
	
	public BSTNode(T data, BSTNode<T> left, BSTNode<T> right) {
		setLeft(left);
		setRight(right);
		setData(data);
	}
	
	public BSTNode(T data) {
		setLeft(null);
		setRight(null);
		setData(data);
	}

	public BSTNode<T> getLeft() {
		return _left;
	}

	public void setLeft(BSTNode<T> _left) {
		this._left = _left;
	}

	public BSTNode<T> getRight() {
		return _right;
	}

	public void setRight(BSTNode<T> _right) {
		this._right = _right;
	}

	public T getData() {
		return _data;
	}

	public void setData(T _data) {
		this._data = _data;
	}
}
