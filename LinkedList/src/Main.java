
public class Main {

	public static void main(String[] args) {
		test();
	}
	
	public static LinkedList<Integer> buildOneTwoThree() {
		LinkedList<Integer> lst = new LinkedList<Integer>();
		lst.add_front(1);
		lst.add_front(2);
		lst.add_front(3);
		return lst;
	}
	
	public static void Assert(boolean condition, String msg) {
		if (!condition) {
			System.out.println(msg);
		}
	}
	
	public static void test() {
		System.out.println("Starting tests");
		
		LinkedList<Integer> lst = buildOneTwoThree();
		Assert(lst.length() == 3, "length");
		lst.add_front(4);
		Assert(lst.length() == 4, "add_front");
		
		Assert(lst.getKthToLastElement(0) == 1, "getKthtolast");
		Assert(lst.getKthToLastElement(1) == 2, "getKthtolast");
		Assert(lst.getKthToLastElement(2) == 3, "getKthtolast");
		Assert(lst.getKthToLastElement(3) == 4, "getKthtolast");
		
		Assert(!lst.isPalindrome(), "isPalindrome");
		Assert(!lst.isPalindromeRev(), "isPalindromeRev");
		
		lst = new LinkedList<Integer>();
		lst.add_front(1);
		lst.add_front(2);
		lst.add_front(3);
		lst.add_front(2);
		lst.add_front(1);
		Assert(lst.isPalindrome(), "isPalindrome");
		Assert(lst.isPalindromeRev(), "isPalindromeRev");
		
		lst = new LinkedList<Integer>();
		lst.add_front(1);
		lst.add_front(2);
		lst.add_front(2);
		lst.add_front(1);
		Assert(lst.isPalindrome(), "isPalindrome");
		Assert(lst.isPalindromeRev(), "isPalindromeRev");
		
		Assert(!lst.hasCycle(), "hasCycle");
		lst = new LinkedList<Integer>();
		lst.add_front(1);
		lst.add_front(2);
		lst.add_front(3);
		lst.add_back(lst.getNth(0));
		Assert(lst.hasCycle(), "hasCycle");
		
		System.out.println("Finished tests");
	}
	
}
