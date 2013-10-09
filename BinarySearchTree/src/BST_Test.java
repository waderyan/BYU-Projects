
public class BST_Test {

	public static void main(String[] args) {
		test();
	}
	
	static void test() {
		BST<Integer> tree = new BST<Integer>();
		tree.add(1);
		tree.add(2);
		tree.add(3);
		
		Assert(tree.size() == 3, "size");
	}
	
	static void Assert (boolean condition, String msg) {
		if (!condition) {
			System.out.println(msg);
		}
	}
}
