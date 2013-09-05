package model;

/**
* Objects of this class describe a single node in a network.
**/

public class NetworkNode
{
	/**
	* Creates a network node
	* @param nodeName the name that the node will be identified by. Names are exact
	*	and case sensitive.
	* @param xCenter the X coordinate of the center of the node in pixels
	* @param yCenter the Y coordinate of the center of the node in pixels
	*/
	public NetworkNode(String nodeName, double xCenter, double yCenter) {
		
	}
	
	/**
	* @return name of the node
	*/
	public String getName() {
		return null;
	}
	
	/**
	* Changes the name of the node
	* @param newName
	*/
	public void setName(String newName)
	{}
	
	/**
	* @return the X coordinate of the center of the node
	*/
	public double getX() {
		return 0;
	}
	
	/**
	* @return the Y coordinate of the center of the node
	*/
	public double getY() {
		return 0;
	}
	
	/**
	* Changes the location of the center of the node
	*/
	public void setLocation(double xCenter, double yCenter)
	{}

	/**
	* Sets a reference to the network model that this node belongs to
	* @param network
	*/
	public void setNetwork(NetworkModel network) {}
	
	/**
	* @return the network that this node belongs to
	*/
	public NetworkModel getNetwork() {
		return null;}
}
