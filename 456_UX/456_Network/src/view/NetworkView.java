package view;

import java.awt.*;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.geom.Ellipse2D;
import java.awt.geom.Line2D;
import java.awt.geom.Point2D;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.swing.*;

import model.*;
import model.NetworkConnection.Side;

public class NetworkView extends JPanel implements MouseListener {

	private static final long serialVersionUID = 1L;
	private final List<DrawingComp> _comps;
	private final Map<String, DrawingNode> _strToNode;
	
	/** Returns the specified NetworkNode. */
	private DrawingNode getNode(String name) throws NetworkException {
		if (!_strToNode.containsKey(name)) {
			throw new NetworkException ("node does not exist!");
		}
		return _strToNode.get(name);
	}

	public NetworkView (NetworkModel model) throws NetworkException {
		_comps = new ArrayList<DrawingComp>();
		_strToNode = new HashMap<String, DrawingNode>();
		
		// Ordering is important here. Do not add connections w/o adding nodes.
		for (int i = 0; i < model.nNodes(); i++) {
			DrawingNode newNode = new DrawingNode(model.getNode(i));
			_comps.add(newNode);
			_strToNode.put(model.getNode(i).getName(), newNode);
		}
		for (int i = 0; i < model.nConnections(); i++) {
			_comps.add(new DrawingConnection(
					model.getConnection(i),
					getNode(model.getConnection(i).getNode1Name()),
					getNode(model.getConnection(i).getNode2Name())
			));
		}
		
		enableEvents(AWTEvent.MOUSE_EVENT_MASK);
		addMouseListener(this);
	}
	
	public void paint(Graphics g) {
		Graphics2D g2 = (Graphics2D) g;
		for (DrawingComp comp : _comps) {
			comp.draw(g2);
		}
	}
	
	public GeometryDescriptor pointGeometry(Point mouseLoc) {
		// Check all nodes
			// if node check text within node
		// Check all connections
		
		return null;
	}
	
	@Override
	public void mouseReleased(MouseEvent e) {
		GeometryDescriptor desc = pointGeometry(e.getPoint());
		System.out.println("mouse released");
	}

	@Override
	public void mouseClicked(MouseEvent e) {
		//System.out.println("mouse clicked");
	}

	@Override
	public void mousePressed(MouseEvent e) {
		//System.out.println("mouse pressed");
	}

	@Override
	public void mouseEntered(MouseEvent e) {
		//System.out.println("mouse entered");
	}

	@Override
	public void mouseExited(MouseEvent e) {
		//System.out.println("mouse exited");
	}
}


abstract class DrawingComp {
	
	protected static final Font _font = new Font("Helvetica", Font.BOLD, 15);
	protected static final Color _fontColor = Color.black;
	
	public abstract void draw(Graphics2D g2);
}

class DrawingNode extends DrawingComp {
	
	private final NetworkNode _node;
	private static final Color _color = Color.blue;
	private static final int _offset = 30;
	private double _x;
	private double _y;
	private double _w;
	private double _h;
	
	public DrawingNode (NetworkNode node) {
		if (node == null) {
			throw new IllegalArgumentException();
		}
		_node = node;
	}
	
	public void draw(Graphics2D g2) {
		assert (g2 != null);
		
		g2.setFont(_font);
		FontMetrics FM = g2.getFontMetrics();
		int textWidth = FM.stringWidth(_node.getName());
		int textHeight = FM.getHeight();
		
		// I have a height problem
		_h = textWidth + _offset;
		_w = textWidth + _offset;
		_x = _node.getX() - (_w / 2);
		_y = _node.getY() - (_h / 2);
		
		int textBase = (int) (_node.getY() + (FM.getHeight() / 2));
		int textLeft = ((int) _node.getX() - (textWidth / 2));
		
		Ellipse2D.Double ellipse = new Ellipse2D.Double(_x, _y, _w, _h);
		
		g2.draw(ellipse);
		g2.setColor(_color);
		g2.fill(ellipse);
		g2.setColor(_fontColor);
		g2.drawString(_node.getName(), textLeft, textBase);
	}
	
	public Point2D.Double getLeftSidePoint() {
		return new Point2D.Double( _x,  _y + (_h / 2));
	}
	
	public Point2D.Double getRightSidePoint() {
		return new Point2D.Double( _x + _w,  _y + (_h / 2));
	}
	
	public Point2D.Double getTopSidePoint() {
		return new Point2D.Double( _x + (_w / 2),  _y);
	}
	
	public Point2D.Double getBottomSidePoint() {
		return new Point2D.Double( _x + (_w / 2),  _y + _h);
	}
	
}

class DrawingConnection extends DrawingComp {
	
	private final NetworkConnection _conn;
	private final DrawingNode _node1;
	private final DrawingNode _node2;
	private final static Color _color = Color.black;
	
	public DrawingConnection (NetworkConnection conn, DrawingNode node1, DrawingNode node2) {
		if (conn == null || node1 == null || node2 == null) {
			throw new IllegalArgumentException();
		}
		_conn = conn;
		_node1 = node1;
		_node2 = node2;
	}
	
	/** Gets the correct side point for the given node **/
	private Point2D.Double getSidePoint(Side side, DrawingNode node)  {
		assert (side != null && node != null);
		
		switch (side) {
		case Left: 
			return node.getLeftSidePoint();
		case Right:
			return node.getRightSidePoint();
		case Top:
			return node.getTopSidePoint();
		case Bottom:
			return node.getBottomSidePoint();
		default:
			assert(false);
		}
		return null;
	}
	
	public void draw(Graphics2D g2) {
		assert (g2 != null);
		
		g2.setColor(_color);
		g2.draw(new Line2D.Double(getSidePoint(_conn.getSide1(), _node1), getSidePoint(_conn.getSide2(), _node2)));
	}
}

