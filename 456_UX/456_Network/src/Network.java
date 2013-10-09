
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;

import javax.swing.JFrame;

import view.NetworkView;
import model.NetworkException;
import model.NetworkModel;

public class Network {

	public static boolean validateArgs (String[] args) {
		return args.length == 1 && !args[0].trim().equals("");
	}
	
	private static void run (String fileName) {
		NetworkModel model = null;
		
		try {
			model = new NetworkModel(fileName);
		
			JFrame frame = new JFrame("Network");
			frame.setBounds(100, 100, 800, 800);
			frame.addWindowListener(new WindowAdapter() {
				public void windowClosing(WindowEvent evt) {
					System.exit(0);
				}
			});
			frame.getContentPane().add(new NetworkView(model));
			frame.setVisible(true);
		
		} catch (NetworkException e) {
			System.out.println("Error occurred while creating model");
			e.printStackTrace();
			return;
		}
	}
	
	public static void main (String[] args) {		
		if (!Network.validateArgs(args)) {
			System.out.println("Invalid arguments. Usage: filename");
			return;
		}
		
		run(args[0]);
	}
}
