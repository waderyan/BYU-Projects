package model;

public class NetworkException extends Exception {

	private static final long serialVersionUID = 1L;
	
	public NetworkException() {
		super();
	}
	
	public NetworkException(String msg) {
		super(msg);
	}
}
