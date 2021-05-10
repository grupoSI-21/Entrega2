package chat;

import javax.swing.*;
import javax.swing.text.AttributeSet;
import javax.swing.text.SimpleAttributeSet;
import javax.swing.text.StyleConstants;
import javax.swing.text.StyleContext;

import java.awt.event.*;
import java.awt.BorderLayout;
import java.awt.Container;
import java.awt.FlowLayout;
import java.awt.Color;
import java.awt.Insets;
//import java.awt.event.ActionListener;

//import java.awt.Container;

import cartago.*;
import cartago.tools.*;

public class ChatGUI extends GUIArtifact {

	private MyFrame frame;
	
	//private PanelCliente panel;
	
	public void setup() {
		frame = new MyFrame();
		
		//panel = new PanelCliente(frame.getContentPane());

		linkActionEventToOp(frame.boton,"send");
		linkKeyStrokeToOp(frame.textField,"ENTER","updateText");
		linkWindowClosingEventToOp(frame, "closed");
		linkMouseEventToOp(frame,"mouseDragged","mouseDraggedOp");
		
		//defineObsProperty("say","hola");
		
        //frame.pack();
        frame.setVisible(true);
        //frame.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
			
	}

	@INTERNAL_OPERATION void send(ActionEvent ev){
		String texto = frame.textField.getText();
 		//getObsProperty("say").updateValue(texto);
		signal("say",texto);
		
		frame.textField.setText("");
		
		appendToPane(frame.textArea, "Pregunta: ", Color.DARK_GRAY);
		appendToPane(frame.textArea, texto, Color.DARK_GRAY);
		String salto = System.lineSeparator();
		appendToPane(frame.textArea, salto, Color.DARK_GRAY);
		//signal("say",texto);
	}

	@INTERNAL_OPERATION void closed(WindowEvent ev){
		signal("closed");
	}
	
	@INTERNAL_OPERATION void updateText(ActionEvent ev){
		String texto = getValue();
		//getObsProperty("say").updateValue(texto);
		signal("say",texto);
				
		frame.textField.setText("");
		
		appendToPane(frame.textArea, "Pregunta: ", Color.DARK_GRAY);
		appendToPane(frame.textArea, texto, Color.DARK_GRAY);
		String salto = System.lineSeparator();
		appendToPane(frame.textArea, salto, Color.DARK_GRAY);
	}

	//@INTERNAL_OPERATION void mouseDraggedOp(MouseEvent ev){
		//signal("mouse_dragged",ev.getX(),ev.getY());
	//}
	
	@OPERATION void show(String texto){
		appendToPane(frame.textArea, "Respuesta: ", Color.RED);
		appendToPane(frame.textArea, texto, Color.RED);
		//frame.setText(texto);
		String salto = System.lineSeparator();
		//frame.setText(salto);
		appendToPane(frame.textArea, salto, Color.RED);
	}

	private String getValue(){
		return frame.getText();
	}
	
	private void appendToPane(JTextPane tp, String msg, Color c)
    {
        StyleContext sc = StyleContext.getDefaultStyleContext();
        AttributeSet aset = sc.addAttribute(SimpleAttributeSet.EMPTY, StyleConstants.Foreground, c);

        aset = sc.addAttribute(aset, StyleConstants.FontFamily, "Lucida Console");
        aset = sc.addAttribute(aset, StyleConstants.Alignment, StyleConstants.ALIGN_JUSTIFIED);

        int len = tp.getDocument().getLength();
        tp.setCaretPosition(len);
        tp.setCharacterAttributes(aset, false);
        tp.replaceSelection(msg);
    }
	
	class MyFrame extends JFrame {		
		
		/** Scroll */
		private JScrollPane scroll;

		/** Area para mostrar la conversacion */
		private JTextPane textArea;

		/** Para pedir el texto al usuario */
		private JTextField textField;

		/** Boton para enviar el texto */
		private JButton boton;

		public MyFrame(){
			setTitle("Simple Chat GUI ");
			setSize(600,400);
			
			Container contenedor = this.getContentPane();
			contenedor.setLayout(new BorderLayout());
			
			JPanel panel = new JPanel(new FlowLayout());
			//JPanel panel2 = new JPanel();
			setContentPane(contenedor);
			
			textArea = new JTextPane();
			textArea.setSize(400,200);
			textArea.setMargin(new Insets(5, 5, 5, 5));
			appendToPane(textArea, "/*  Aqui se muestra el diálogo desde el GUI con el chatBot */", Color.BLUE);
			String salto = System.lineSeparator();
			appendToPane(textArea, salto, Color.BLUE);
			appendToPane(textArea, salto, Color.BLUE);
			//textArea.append("/*  Aqui se muestra el diálogo desde el GUI con el chatBot */");
			
			scroll = new JScrollPane(textArea);

			textField = new JTextField(40);
			textField.setText("Zona de Escritura");
			textField.setEditable(true);
			
			boton = new JButton("Enviar");
			boton.setSize(100,50);
			
			//okButton = new JButton("ok");
			//okButton.setSize(80,50);
			
			//text = new JTextField(10);
			//text.setText("0");
			//text.setEditable(true);
			
			panel.add(boton);
			panel.add(textField);
			//panel.add(okButton, BorderLayout.SOUTH);
			//panel.add(text);
			//panel.add(textArea);
			//panel.add(scroll, BorderLayout.SOUTH);
			
			contenedor.add(scroll, BorderLayout.CENTER);
			contenedor.add(panel, BorderLayout.SOUTH);
			
		}
		
		public String getText(){
			return textField.getText();
		}

		public void setText(String s, Color c){
			//text.setText(s);
			//textArea.append(s);
			//appendToPane(textArea, "Respuesta: ", c);
			appendToPane(textArea, s, c);

		}
	}
}
