package model;

/**
* This class describes a connection between two network nodes
*/
public class NetworkConnection {

	public enum Side {
		Left, 
		Right, 
		Top, 
		Bottom
	}
	
	/**
	* Creates a new connection
	* @param node1 the name of the first node to be connected
	* @param side1 specifies the side of node1 to which the connection is to be attached
	* @param node2 the name of the second node to be connected
	* @param side2 specifies the side of node2 to which the connection is to be attached
	*/
	public NetworkConnection(String node1, Side side1, String node2, Side side2) {
		
	}
	
}
