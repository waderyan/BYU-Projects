package model;

import java.util.HashMap;
import java.util.Map;

/**
* This class describes a connection between two network nodes
*/
public class NetworkConnection {

	public enum Side {
		Left("L"), 
		Right("R"), 
		Top("T"), 
		Bottom("B");
		
		// Could be susceptible to class loading problems.
		private static final Map<String, Side> lookup = new HashMap<String, Side>();
		static {
			for (Side s : Side.values()) {
				lookup.put(s.getAbbreviation(), s);
			}
		}
		
		private final String _abbreviation;
		
		private Side(String abbreviation) {
			_abbreviation = abbreviation;
		}
		
		public String getAbbreviation() {
			return _abbreviation;
		}
		
		public static Side get(String abbreviation) {
			assert(lookup.containsKey(abbreviation));
			return lookup.get(abbreviation);
		}
	}
	
	final private String _node1;
	final private String _node2;
	final private Side _side1;
	final private Side _side2;
	
	/**
	* Creates a new connection
	* @param node1 the name of the first node to be connected
	* @param side1 specifies the side of node1 to which the connection is to be attached
	* @param node2 the name of the second node to be connected
	* @param side2 specifies the side of node2 to which the connection is to be attached
	*/
	public NetworkConnection(String node1, Side side1, String node2, Side side2) {
		_node1 = node1;
		_node2 = node2;
		_side1 = side1;
		_side2 = side2;
	}
	
	@Override
	public String toString() {
		return String.format("C \"%s\" %s \"%s\" %s", _node1, _side1.getAbbreviation(), _node2, _side2.getAbbreviation());
	}

	public String getNode1Name() {
		return _node1;
	}

	public String getNode2Name() {
		return _node2;
	}

	public Side getSide1() {
		return _side1;
	}

	public Side getSide2() {
		return _side2;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((_node1 == null) ? 0 : _node1.hashCode());
		result = prime * result + ((_node2 == null) ? 0 : _node2.hashCode());
		result = prime * result + ((_side1 == null) ? 0 : _side1.hashCode());
		result = prime * result + ((_side2 == null) ? 0 : _side2.hashCode());
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
		NetworkConnection other = (NetworkConnection) obj;
		if (_node1 == null) {
			if (other._node1 != null)
				return false;
		} else if (!_node1.equals(other._node1))
			return false;
		if (_node2 == null) {
			if (other._node2 != null)
				return false;
		} else if (!_node2.equals(other._node2))
			return false;
		if (_side1 != other._side1)
			return false;
		if (_side2 != other._side2)
			return false;
		return true;
	}
	
}
