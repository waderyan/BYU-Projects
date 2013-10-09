package model;

/**
* Objects of this class describe a single node in a network.
**/
public class NetworkNode {
	
	/** Reference back to the model **/
	private NetworkModel _model;
	/** Name of the node **/
	private String _nodeName;
	/** Center X **/
	private double _xCenter;
	/** Center Y **/
	private double _yCenter;
	
	/**
	* Creates a network node
	* @param nodeName the name that the node will be identified by. Names are exact
	*	and case sensitive.
	* @param xCenter the X coordinate of the center of the node in pixels
	* @param yCenter the Y coordinate of the center of the node in pixels
	*/
	public NetworkNode(String nodeName, double xCenter, double yCenter) {
		setName(nodeName);
		setLocation(xCenter, yCenter);
		_model = null;
	}
	
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((_model == null) ? 0 : _model.hashCode());
		result = prime * result
				+ ((_nodeName == null) ? 0 : _nodeName.hashCode());
		long temp;
		temp = Double.doubleToLongBits(_xCenter);
		result = prime * result + (int) (temp ^ (temp >>> 32));
		temp = Double.doubleToLongBits(_yCenter);
		result = prime * result + (int) (temp ^ (temp >>> 32));
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		NetworkNode other = (NetworkNode) obj;
		if (_model == null) {
			if (other._model != null)
				return false;
		} else if (!_model.equals(other._model))
			return false;
		if (_nodeName == null) {
			if (other._nodeName != null)
				return false;
		} else if (!_nodeName.equals(other._nodeName))
			return false;
		if (Double.doubleToLongBits(_xCenter) != Double
				.doubleToLongBits(other._xCenter))
			return false;
		if (Double.doubleToLongBits(_yCenter) != Double
				.doubleToLongBits(other._yCenter))
			return false;
		return true;
	}

	/**
	* @return name of the node
	*/
	public String getName() {
		return _nodeName;
	}
	
	/**
	* Changes the name of the node
	* @param newName
	*/
	public void setName(String newName) {
		_nodeName = newName;
	}
	
	/**
	* @return the X coordinate of the center of the node
	*/
	public double getX() {
		return _xCenter;
	}
	
	/**
	* @return the Y coordinate of the center of the node
	*/
	public double getY() {
		return _yCenter;
	}
	
	/**
	* Changes the location of the center of the node
	*/
	public void setLocation(double xCenter, double yCenter) {
		_xCenter = xCenter;
		_yCenter = yCenter;
	}

	/**
	* Sets a reference to the network model that this node belongs to
	* @param network
	*/
	public void setNetwork(NetworkModel network) {
		_model = network;
	}
	
	/**
	* @return the network that this node belongs to
	*/
	public NetworkModel getNetwork() {
		return _model;
	}
	
	public String toString() {
		return String.format("N %s %s \"%s\"", 
					String.valueOf(_xCenter), 
					String.valueOf(_yCenter), 
					_nodeName
				);
	}
}
