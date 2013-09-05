package model;

/**
 * Objects of this class contain information about a network nodes and their connections.  
 */
public class NetworkModel {
	/**
	 * Creates an empty network model that has a unique default file name and no contents
	 */
	public NetworkModel () {}
	
	/**
	 * Reads the specific file and creates a new NetworkModel object that contains all of the 
	 * information in the file. If there is no such file then an exception should be thrown.
	 * @param fileName the name of the file to be read.
	 */
	public NetworkModel(String fileName)
	{}
	
	/**
	 * Returns the name of the file associated with this model.
	 */
	public String getFileName() {
		return null;
	}
	
	/**
	 * Changes the file name associated with this model
	 * @param newFileName the new file name
	 */
	public void setFileName(String newFileName) {
		
	}
	
	/**
	 * Saves the contents of this model to its file.
	 */
	public void save() {
		
	}
	
	/**
	 * Returns true if there are unsaved changes.
	 */
	public boolean unsavedChanges() {
		throw new RuntimeException("Not implemented");
	}
	/**
	 * Adds the specified NetworkNode to the list of network objects
	 * @param newNode
	 */
	public void addNode(NetworkNode newNode) {
		
	}
	
	/**
	 * Returns the number of network node objects in this model.
	 */
	public int nNodes() {
		return 0;
	}
	
	/**
	 * Returns the specified NetworkNode. Indexes begin at zero.
	 * @param i index of the desired object. Must be less than nNodes()
	 */
	public NetworkNode getNode(int i) {
		return null;
	}
	/**
	 * Removes the specified object from the list of nodes.
	 * @param i the index of the object to be removed.
	 */
	public void removeNode(int i)
	{}
	/**
	 * Adds the specified NetworkConnection to the list of connections
	 * @param newConnection
	 */
	public void addConnection(NetworkConnection newConnection) {
		
	}
	/**
	 * Returns the number of network connections in this model.
	 */
	public int nConnections() {
		return -1;
	}
	
	/**
	 * Returns the specified NetworkConnection. Indexes begin at zero.
	 * @param i index of the desired object. Must be less than nConnections()
	 */
	public NetworkConnection getConnection(int i) {
		return null;
	}
	
	/**
	 * Removes the specified object from the list of connections
	 * @param i the index of the object to be removed.
	 */
	public void removeConnection(int i)
	{}
	/**
	* This method is a regression test to verify that this class is
	* implemented correctly. It should test all of the methods including
	* the exceptions. It should be completely self checking. This 
	* should write "testing NetworkModel" to System.out before it
	* starts and "NetworkModel OK" to System.out when the test
	* terminates correctly. Nothing else should appear on a correct
	* test. Other messages should report any errors discovered.
	**/
	public static void Test()
	{}
}