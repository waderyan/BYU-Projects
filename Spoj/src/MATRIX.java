import java.util.Scanner;
import java.util.List;
import java.util.ArrayList;

public class MATRIX {

    public static void main(String[] args) {
        Scanner scan = new Scanner(System.in);
        int size = Integer.parseInt(scan.nextLine());
        
        List<ArrayList<Integer>> matrix = new ArrayList<ArrayList<Integer>>();
        
        // Read in the matrix
        for (int i = 0; i < size; i++) {
            String[] digits = scan.nextLine().split(" ");
            matrix.add(new ArrayList<Integer>());
            for (int j = 0; j < digits.length; j++) {
                matrix.get(i).add(Integer.parseInt(digits[j]));
            }
        }
        
        boolean[] rows = new boolean[size];
        boolean[] cols = new boolean[size];
        
        // Determine which cols and rows need to be zeroed out
        for (int i = 0; i < size; i++) {
            for (int j = 0; j < size; j++) {
                if (matrix.get(i).get(j) == 0) {
                    rows[i] = true;
                    cols[j] = true;
                }
            }
        }
        
        // Zero out the appropriate cells.
         for (int i = 0; i < size; i++) {
            for (int j = 0; j < size; j++) {
                if (rows[i] || cols[j]) {
                    matrix.get(i).set(j, 0);
                }
            }
        }
        
        // Print resulting matrix.
        for (int i = 0; i < size; i++) {
            for (int j = 0; j < size; j++) {
                System.out.printf(matrix.get(i).get(j) + " ");
            }
            System.out.println();
        }
    } 
}

