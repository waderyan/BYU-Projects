import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;


public class CPRMT_2 {

	/**
	 * @param args
	 * @throws IOException 
	 */
	public static void main(String[] args) throws IOException {
		BufferedReader s = new BufferedReader(new InputStreamReader(System.in));
		
		String in1;
		String in2;
		
		while((in1 =s.readLine())!=null) {	
			int[] letters1 = new int[26];
			int[] letters2 = new int[26];
			
			in2 = s.readLine();
			
			char[] ca1 = in1.toCharArray();
			char[] ca2 = in2.toCharArray();
			
			for (int i =0;i<in1.length(); i++){
				letters1[ca1[i] -'a']++;
			}
			
			for (int i =0;i<in2.length(); i++){
				letters2[ca2[i] -'a']++;
			}
			
			for(int i = 0; i < 26; i++) {
				int temp = Math.min(letters1[i], letters2[i]);
				for(int j =0; j< temp; j++){
					System.out.print((char)(i + 'a'));				
				}
			}
			
			System.out.println();
		}
		

	}

}