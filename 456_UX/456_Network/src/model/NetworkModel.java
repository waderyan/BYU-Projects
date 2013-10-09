package model;
import static org.junit.Assert.assertTrue;

import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.io.*;
import model.NetworkConnection.Side;

/**
 * Objects of this class contain information about a network nodes and their connections.  
 */
public class NetworkModel {
	
	/** File name **/
	private String _fileName;
	/** Collection of nodes **/
	private List<NetworkNode> _nodes;
	/** Collection of connections **/
	private List<NetworkConnection> _connections;
	/** Flag showing if the file has been saved in its current state **/
	private boolean _saved;
	/** File Processor Helper **/
	private NetworkModelFileProcessor _ntkFileProcessor;

	private void init(String fileName) {
		setFileName(fileName);
		_nodes = new ArrayList<NetworkNode>();
		_connections = new ArrayList<NetworkConnection>();
		_saved = true;
		_ntkFileProcessor = new NetworkModelFileProcessor();
	}
	
	private void damage() {
		_saved = false;
	}
	
	private void unDamage() {
		_saved = true;
	}
	
	private class NetworkModelFileProcessor {
		
		public void processFile (File file) throws NetworkException {
			BufferedReader reader = null;
			
			try {
				reader = new BufferedReader(new FileReader(file));
				
				String line = "";
				while ((line = reader.readLine()) != null) {
					processLine(line);
				}
				
			} catch (IOException ex) {
				throw new NetworkException("Error reading file");
			} finally {
				if (reader != null)
					try {
						reader.close();
					} catch (IOException e) {
						throw new NetworkException("Cannot close reader");
					}
			}
			
			unDamage();
		}
		
		private String[] split(String line) {
			List<String> result = new ArrayList<String>();
			Matcher m = Pattern.compile("[^\\s\"']+|\"([^\"]*)\"|'([^']*)'").matcher(line);
			
			while (m.find()) {
				if (m.group(1) != null) {
					result.add(m.group(1));
				} else if (m.group(2) != null) {
					result.add(m.group(2));
				} else {
					result.add(m.group());
				}
			}
			
			return result.toArray(new String[result.size()]);
		}
		
		public void processLine (String line) throws NetworkException, NumberFormatException {
			final String[] parts = split(line);
			
			if (parts[0].equals("N")) {
				addNode(new NetworkNode(parts[3], Double.parseDouble(parts[1]), Double.parseDouble(parts[2])));
			} else if (parts[0].equals("C")) {
				addConnection(new NetworkConnection(parts[1], Side.get(parts[2]), parts[3], Side.get(parts[4])));
			} else {
				throw new NetworkException(String.format("Invalid file format.\nLine: %s", line));
			}
		}
		
		public void save() throws NetworkException {
			BufferedWriter writer = null;
			
			try {
				writer = new BufferedWriter(new FileWriter(_fileName));
				
				for (int i = 0; i < _nodes.size(); i++) {
					writer.write(getNode(i).toString());
					if ((i != _nodes.size()) && _connections.size() != 0) {
						writer.write("\n");
					
					}
				}
				for (int i = 0; i < _connections.size(); i++) {
					writer.write(getConnection(i).toString());
					if (i != (_connections.size())) {
						writer.write("\n");
					}
				}
				
			} catch (IOException ex) {
				throw new NetworkException("cannot close writer");
			} finally {
				if (writer != null) {
					try {
						writer.close();
					} catch (IOException e) {
						throw new NetworkException("cannot close writer");
					}
				}
			}
		}
	}
	
	/**
	 * Creates an empty network model that has a unique default file name and no contents
	 */
	public NetworkModel () {
		init(UUID.randomUUID().toString());	
	}
	
	/**
	 * Reads the specific file and creates a new NetworkModel object that contains all of the 
	 * information in the file. If there is no such file then an exception should be thrown.
	 * @param fileName the name of the file to be read.
	 */
	public NetworkModel(String fileName) throws NetworkException {
		init(fileName);
		
		try {
			_ntkFileProcessor.processFile(new File(fileName));
		} catch (Exception ex) {
			throw new NetworkException(String.format("Invalid File.\nFile Name: %s", fileName));
		}
	}
	
	/**
	 * Returns the name of the file associated with this model.
	 */
	public String getFileName() {
		return _fileName;
	}
	
	/**
	 * Changes the file name associated with this model
	 * @param newFileName the new file name
	 */
	public void setFileName(String newFileName) {
		_fileName = newFileName;
	}
	
	/**
	 * Saves the contents of this model to its file.
	 */
	public void save() {
		try {
			_ntkFileProcessor.save();
		} catch (Exception e) {
			System.out.println("Error while saving");
			return;
		}
		
		unDamage();
	}
	
	/**
	 * Returns true if there are unsaved changes.
	 */
	public boolean unsavedChanges() {
		return !_saved;
	}
	/**
	 * Adds the specified NetworkNode to the list of network objects
	 * @param newNode
	 */
	public void addNode(NetworkNode newNode) {
		damage();
		_nodes.add(newNode);
	}
	
	/**
	 * Returns the number of network node objects in this model.
	 */
	public int nNodes() {
		return _nodes.size();
	}
	
	/**
	 * Returns the specified NetworkNode. Indexes begin at zero.
	 * @param i index of the desired object. Must be less than nNodes()
	 * 
	 * @pre i <= _nodes.size()
	 * 
	 * @return ith node of nodes
	 * @throws NetworkException 
	 */
	public NetworkNode getNode(int i) throws NetworkException {
		if (i >= nNodes()) {
			throw new NetworkException("node does not exist");
		}
		return _nodes.get(i);
	}
	
	/**
	 * Removes the specified object from the list of nodes.
	 * @param i the index of the object to be removed.
	 * @throws NetworkException 
	 * 
	 * @pre i < _nodes.size()
	 * @post _nodes.size()--
	 */
	public void removeNode(int i) throws NetworkException {
		if (i >= nNodes()) {
			throw new NetworkException("node does not exist - cannot be removed");
		}
		damage();
		_nodes.remove(i);
	}
	
	/**
	 * Adds the specified NetworkConnection to the list of connections
	 * @param newConnection 	Cannot equal null.
	 * 
	 * @pre newConnection != null
	 * @post _connections.size()++
	 */
	public void addConnection(NetworkConnection newConnection) {
		assert (newConnection != null);
		
		damage();
		_connections.add(newConnection);
	}
	
	/**
	 * Returns the number of network connections in this model.
	 */
	public int nConnections() {
		return _connections.size();
	}
	
	/**
	 * Returns the specified NetworkConnection. Indexes begin at zero.
	 * @param i index of the desired object. Must be less than nConnections()
	 * @throws NetworkException 
	 * 
	 * @pre i < _connections.size();
	 */
	public NetworkConnection getConnection(int i) throws NetworkException {
		if (i >= nConnections()) {
			throw new NetworkException("connection does not exist");
		}
		return _connections.get(i);
	}
	
	/**
	 * Removes the specified object from the list of connections
	 * @param i the index of the object to be removed.
	 * @throws NetworkException 
	 */
	public void removeConnection(int i) throws NetworkException {
		if (i >= _connections.size()) {
			throw new NetworkException("connection does not exist - cannot be removed");
		}
		damage();
		_connections.remove(i);
	}
	
	
	/**
	* This method is a regression test to verify that this class is
	* implemented correctly. It should test all of the methods including
	* the exceptions. It should be completely self checking. This 
	* should write "testing NetworkModel" to System.out before it
	* starts and "NetworkModel OK" to System.out when the test
	* terminates correctly. Nothing else should appear on a correct
	* test. Other messages should report any errors discovered.
	**/
	public static void Test() {
		System.out.println("testing NetworkModel");
		
		try {
			String testFile = "test0";
			
			// Constructors
			NetworkConnection testConn = new NetworkConnection("TestConnBob", Side.Bottom, "TestConnJoe", Side.Left);
			NetworkNode testNode = new NetworkNode("TestNodeBob", 0, 0);
			NetworkModel model =  new NetworkModel("test0");
			NetworkModel emptyModel = new NetworkModel();
			assertTrue("ERROR - fileName is empty when it should be random!", !emptyModel.getFileName().equals(""));
			
			try {
				@SuppressWarnings("unused")
				NetworkModel badFileModel = new NetworkModel("testbad");
				assertTrue("ERROR - should not allow bad file", false);
			} catch (NetworkException e) {
			}
			
			// Init methods
			assertTrue("ERROR - wrong number of connections", model.nConnections() == 1);
			assertTrue("ERROR - wrong number of nodes", model.nNodes() == 2);
			assertTrue("ERROR - wrong fileName", model.getFileName().equals(testFile));
			
			// File name methods
			model.setFileName("newTestName");
			assertTrue("ERROR - changing file name", model.getFileName().equals("newTestName"));
			model.setFileName(testFile);
			
			// Connection methods
			model.addConnection(testConn);
			assertTrue("ERROR - changes have not been saved after adding connection!", model.unsavedChanges());
			assertTrue("ERROR - wrong number of connections after adding one", model.nConnections() == 2);
			assertTrue("ERROR - wrong connection!", model.getConnection(1).equals(testConn));
			model.removeConnection(1);
			assertTrue("ERROR - changes have not been saved after removing connection!", model.unsavedChanges());
			assertTrue("ERROR - wrong number of connections after removing one", model.nConnections() == 1);
			assertTrue("ERROR - changes have not been saved after adding and removing connections!", model.unsavedChanges());
			
			assertTrue("incorrect side", testConn.getSide1() == Side.Bottom);
			assertTrue("incorrect side", testConn.getSide2() == Side.Left);
			assertTrue(testConn.getNode1Name().equals("TestConnBob"));
			assertTrue(testConn.getNode2Name().equals("TestConnJoe"));
			assertTrue(testConn.equals(testConn));
			assertTrue(!testConn.equals(new NetworkConnection("bogus", Side.Right, "bogus2", Side.Left)));
			
			try {
				model.removeConnection(100);
				assertTrue("ERROR - should throw an exception when trying to access a connection that doesn't exist", false);
			} catch (NetworkException ex) {}
			
			try {
				model.getConnection(100);
				assertTrue("ERROR - should throw an exception when trying to access a connection that doesn't exist", false);
			} catch (NetworkException ex) {}
			
			model.addNode(testNode);
			assertTrue("ERROR - changes have not been saved after adding nodes!", model.unsavedChanges());
			assertTrue("ERROR - wrong number of nodes after adding one", model.nNodes() == 3);
			assertTrue("ERROR - wrong node!", model.getNode(2).equals(testNode));
			model.removeNode(2);
			assertTrue("ERROR - changes have not been saved after removing node!", model.unsavedChanges());
			assertTrue("ERROR - wrong number of nodes after removing one", model.nNodes() == 2);
			assertTrue("ERROR - changes have not been saved after adding and removing nodes!", model.unsavedChanges());
			
			assertTrue(testNode.getName().equals("TestNodeBob"));
			testNode.setName("NotTestNodeBob");
			assertTrue(testNode.getName().equals("NotTestNodeBob"));
			testNode.setName("TestNodeBob");
			assertTrue(testNode.getX() == 0 && testNode.getY() == 0);
			testNode.setLocation(200, 100);
			assertTrue(testNode.getX() == 200 && testNode.getY() == 100);
			testNode.setLocation(0, 0);
			assertTrue(testNode.getNetwork() == null);
			testNode.setNetwork(model);
			assertTrue(testNode.getNetwork() == model);
			testNode.setNetwork(null);
			
			try {
				model.removeNode(100);
				assertTrue("ERROR - should throw an exception when trying to access a node that doesn't exist", false);
			} catch (NetworkException ex) {}
			
			try {
				model.getNode(100);
				assertTrue("ERROR - should throw an exception when trying to access a node that doesn't exist", false);
			} catch (NetworkException ex) {}
			
			// Save methods
			model.addNode(testNode);
			model.addConnection(testConn);
			model.save();
			assertTrue("ERROR - changes were not saved correctly!", !model.unsavedChanges());
			assertTrue("ERROR - wrong number of connections after saving", model.nConnections() == 2);
			assertTrue("ERROR - wrong number of nodes after saving", model.nNodes() == 3);
			model.removeConnection(1);
			model.removeNode(2);
			model.save();
			
		} catch (NetworkException e) {
			e.printStackTrace();
			System.out.println("FAILED TEST CASES!");
			return;
		}
		
		System.out.println("NetworkModel OK");
	}
	
	private static void assertTrue(String msg, boolean condition) throws NetworkException {
		if (!condition) {
			System.out.println(msg);
			throw new NetworkException(String.format("Failed test case. %s", msg));
		}
	}
	
	private static void assertTrue(boolean condition) throws NetworkException {
		if (!condition) {
			System.out.println("ERROR!");
			throw new NetworkException(String.format("Failed test case."));
		}
	}
}