import java.util.Stack;


public class LinkedList<T> {
	
	@SuppressWarnings("hiding")
	private class LinkedListNode <T> {

		private T _data;
		private LinkedListNode<T> _next;
	
		public LinkedListNode(T data, LinkedListNode<T> next) {
			setData(data);
			setNext(next);
		}

		public LinkedListNode(LinkedListNode<T> node) {
			if (node != null) {
				setData(node.getData());
				setNext(new LinkedListNode<T>(node.getNext()));
			}
		}

		public T getData() {
			return _data;
		}

		public void setData(T _data) {
			this._data = _data;
		}

		public LinkedListNode<T> getNext() {
			return _next;
		}

		public void setNext(LinkedListNode<T> _next) {
			this._next = _next;
		}
	}
	
	private LinkedListNode<T> _head;
	
	public LinkedList() {
		_head = null;
	}
	
	public LinkedList(LinkedListNode<T> newHead) {
		_head = newHead;
	}
	
	public void add_front(T newData) {
		LinkedListNode<T> newHead = new LinkedListNode<T>(newData, _head);
		_head = newHead;
	}
	
	public void add_front(LinkedListNode<T> node) {
		node.setNext(_head);
		_head = node;
	}
	
	public void add_back(LinkedListNode<T> node) {
		LinkedListNode<T> curr = _head;
		while (curr.getNext() != null) {
			curr = curr.getNext();
		}
		curr.setNext(node);
	}
	
	public int length() {
		int count = 0;
		LinkedListNode<T> curr = _head;
		while (curr != null) {
			curr = curr.getNext();
			count++;
		}
		return count;
	}
	
	public T getKthToLastElement(int k) {
		if (_head == null) return null;
		LinkedListNode<T> onestep = _head;
		LinkedListNode<T> kstep = _head;
		
		for (int i = 0; i < k; i++) {
			if (kstep == null) throw new IllegalArgumentException("k outside of bounds");
			kstep = kstep.getNext();
		}
		
		while (kstep.getNext() != null) {
			onestep = onestep.getNext();
			kstep = kstep.getNext();
		}
		
		return onestep.getData();
	}
	
	public LinkedListNode<T> getNth(int n) {
		if ( n < 0 || n > length()) {
			return null;
		}
		LinkedListNode<T> curr = _head;
		for (int i = 0; i < n; i++) {
			curr = curr.getNext();
		}
		return curr;
	}
	
	public boolean isPalindromeRev() {
		LinkedListNode<T> reversedCurr = reverse();
		LinkedListNode<T> current = _head;
		
		while (current != null) {
			if (current.getData() != reversedCurr.getData()) {
				return false;
			}
			current = current.getNext();
			reversedCurr = reversedCurr.getNext();
		}
		
		return true;
	}
	
	public LinkedListNode<T> reverse() {
		Stack<LinkedListNode<T>> nodes = new Stack<LinkedListNode<T>>();
		LinkedListNode<T> current = new LinkedListNode<T>(_head);
		
		while (current.getNext() != null) {
			nodes.push(current);
			current = current.getNext();
		}
		
		while (!nodes.isEmpty()) {
			current.setNext(nodes.pop());
			current = current.getNext();
		}
		
		return current;
	}
	
	public boolean isPalindrome() {
		LinkedListNode<T> end = _head;
		while (end.getNext() != null) {
			end = end.getNext();
		}
		return isPalindrome(_head, end, length());
	}
	
	private boolean isPalindrome(LinkedListNode<T> front, LinkedListNode<T> end, int size) {
		if (front.getData() != end.getData()) {
			return false;
		}
		size -= 2;
		if (size <= 0) {
			return true;
		}
		end = front.getNext();
		for (int i = 0; i < size - 1; i++) {
			end = end.getNext();
		}
		
		return isPalindrome(front.getNext(), end, size);
	}
	
	public boolean hasCycle() {
		if (_head == null) return false;
		LinkedListNode<T> hair = _head;
		LinkedListNode<T> tort = _head;
		
		while (hair != null && hair.getNext() != null) {
			tort = tort.getNext();
			hair = hair.getNext().getNext();
			if (tort == hair) {
				return true;
			}
		}
		
		return false;
	}
}
