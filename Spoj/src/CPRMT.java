import java.util.Arrays;
import java.util.Scanner;

public class CPRMT {

		// The crux of the problem is we are looking to find all letters
		// that are in both strings.
		public static void main(String[] args) {
			Scanner scan = new Scanner(System.in);
			
			while (scan.hasNext()) {
				char[] c1 = scan.nextLine().toCharArray();
				char[] c2 = scan.nextLine().toCharArray();
				
				// Sort each array for fast comparison between the two.
				Arrays.sort(c1);
				Arrays.sort(c2);
				
				int i = 0, j = 0;
				StringBuilder res = new StringBuilder();
				while (i < c1.length && j < c2.length) {
					if ( c1[i] == c2[j] ) {
						res.append(c1[i]);
						i++; j++;
					} else if ( c1[i] < c2[j] ) {
						i++;
					} else {
						j++;
					}
				}
				
				System.out.println(res.toString());
			}

		}
}
