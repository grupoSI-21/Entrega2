// Environment code for project prueba.mas2j
package bot;

import cartago.*;

import java.io.*;
import java.io.File;   
import java.io.BufferedReader;
import java.io.InputStreamReader;

import java.net.HttpURLConnection;               
import java.net.URL;
import java.net.URLEncoder;      

import java.util.*;
import java.util.Locale;
import java.util.logging.Logger; 
import java.util.Properties;                 
                       
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;              
import javax.mail.Session;
import javax.mail.Transport;              
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
                                      
import javax.speech.*;
import javax.speech.Central;
import javax.speech.recognition.*;   
import javax.speech.synthesis.*;
import javax.speech.synthesis.Voice;
import javax.speech.synthesis.Synthesizer;
import javax.speech.synthesis.SynthesizerModeDesc;   

import org.alicebot.ab.Bot;
import org.alicebot.ab.Chat;
import org.alicebot.ab.History;
import org.alicebot.ab.MagicBooleans;
import org.alicebot.ab.MagicStrings;
import org.alicebot.ab.utils.IOUtils;
 
import org.json.*;
import org.json.JSONArray;   

public class Services extends Artifact {
	
    /** Called before the MAS execution with the args informed in .mas2j */
    private Logger logger = Logger.getLogger("prueba.mas2j."+Chat.class.getName());
	private String botName;
	private String actualPath = getResourcesPath();

	private Bot bot;
	private Chat chatSession;
	private String response = "No tengo nada que decir";       
	
	private String remitente = "masterssia";
	private String clave = "ateri200";

    void init(String botName) {
        this.botName = botName;
		bot = new Bot(botName, actualPath);
		chatSession  = new Chat(bot);
		
		defineObsProperty("bot",botName);
		logger.info(" Defino la propiedad: bot("+ botName +")");
		//defineObsProperty("response",response);
		//logger.info(" Defino la propiedad: response("+ response +")");
		logger.info("Me encuentro en el directorio: "+actualPath);

		MagicBooleans.trace_mode = false;
		bot.brain.nodeStats();                                                 
    }

	@OPERATION void chat (String request) {
		//logger.info(" He recibido el request: "+ request);
		
		response = chatSession.multisentenceRespond(request);
			
		while (response.contains("&lt;")) response = response.replace("&lt;", "<");
		while (response.contains("&gt;")) response = response.replace("&gt;", ">");
				
		//logger.info(" El bot responde: "+ response);
	
		signal("answer",response);
			
		//ObsProperty prop = getObsProperty("response");
		//prop.updateValue(response);

	}
 
	@OPERATION void chatSincrono (String request, OpFeedbackParam<String> answer) {
		//logger.info(" He recibido el request: "+ request);
		
		response = chatSession.multisentenceRespond(request);
			
		while (response.contains("&lt;")) response = response.replace("&lt;", "<");
		while (response.contains("&gt;")) response = response.replace("&gt;", ">");
				
		answer.set(response);

	}
 
	@OPERATION void talk (String myVoice, String toTalk) {
		logger.info(" Voy a hablar: "+ toTalk + " con la voz de: "+ myVoice);     

		//StringTerm voiceTerm = new StringTermImpl(myVoice);
		Boolean isMac = false;
		
		try {
			/*
			Firstly identify the OS in which JASON is running
			*/
			if (System.getProperty("os.name").toLowerCase().indexOf("mac") >=0) {
				isMac = true;
				System.out.println("El sistema está ejecutándose en un sistema MacOs X");
				String command = new String("say -v ");
				command = command + myVoice + " " + toTalk;
				//System.out.println(command);
				//System.out.println(myVoice+" debe hablar: "+toTalk);
				Process p = Runtime.getRuntime().exec(command);
				//Process p2 = Runtime.getRuntime().exec("say -v Soledad "+toTalk);
				
			} else {
				System.out.println("El sistema no reconoce que se ejecute en un Mac Os X");
				System.setProperty( 
                "freetts.voices", 
                "com.sun.speech.freetts.en.us"
                    + ".cmu_us_kal.KevinVoiceDirectory"); 
  
				// Register Engine 
				Central.registerEngineCentral( 
                "com.sun.speech.freetts"
                + ".jsapi.FreeTTSEngineCentral"); 
  
				// Create a Synthesizer 
				Synthesizer synth 
                = Central.createSynthesizer( 
                    new SynthesizerModeDesc(Locale.US));
				
				synth.allocate();
				synth.resume();
				
				// Get it ready to speak

				// Speaking
				synth.speakPlainText(toTalk, null);

				// Wait till speaking is done
				synth.waitEngineState(Synthesizer.QUEUE_EMPTY);

				// Clean up
				synth.deallocate();
			};
			
			//String resourcesPath = getResourcesPath();
			//System.out.println(resourcesPath);
						
		} catch (Exception eLabel) {
			eLabel.printStackTrace();
		};
	}   
	
 	@OPERATION void createFile (String ruta) {
		try {
			File archivo = new File(actualPath + File.separator + ruta);
			BufferedWriter bw;
		
			if(archivo.exists()) {
				System.out.println("El fichero de texto ya estaba creado.");
			} else {
				archivo.createNewFile();              
				System.out.println("Acabo de crear el fichero de texto");
			}
			bw = new BufferedWriter(new FileWriter(archivo,true));
			bw.close();
		}
		catch (Exception eLabel) {
			eLabel.printStackTrace();                                                                   
		};   
	}

	@OPERATION void writeOnFile (String text, String ruta) {    
		try {                
			File archivo = new File(actualPath + File.separator + ruta);
			BufferedWriter bw;
		
			if(archivo.exists()) {
				System.out.println("El fichero de texto "+ruta+" ya estaba creado.");
			} else {
				archivo.createNewFile();              
				System.out.println("Acabo de crear el fichero de texto: "+ruta);
			}
			bw = new BufferedWriter(new FileWriter(archivo,true));
			PrintWriter out = new PrintWriter(bw);
			out.println(text); // Writing the text
			out.close();       // Closing the output
			bw.close();        // CLosing the buffer
          } 
		catch (Exception eLabel) {
			eLabel.printStackTrace();
		};   
	}
    
	@OPERATION void mail (String to, String sub, String msg) {    
 		//Get properties object    
        Properties props = new Properties();    
		props.put("mail.smtp.auth", "true");
		props.put("mail.smtp.starttls.enable", "true");
		props.put("mail.smtp.host", "smtp.gmail.com");
		props.put("mail.smtp.port", "587");   
		
		props.put("from", "masterssia@gmail.com");
		props.put("username", "masterssia@gmail.com");
		props.put("password", clave);
		          
		//get Session   
        Session session = Session.getInstance(props, new javax.mail.Authenticator() {
			protected PasswordAuthentication getPasswordAuthentication() {
				return new PasswordAuthentication(props.getProperty("username"), props.getProperty("password"));
			}
		});
		
        Message message = new MimeMessage(session);
        try {
				message.setFrom(new InternetAddress(props.getProperty("from"))); 
				message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
				message.setSubject(sub);
				message.setText(msg);    
         				
				Transport.send(message);
				//System.out.println("Message sent successfully");    
          } catch (MessagingException me) {
			  me.printStackTrace();
			  throw new RuntimeException(me);
		  }    

   	}
                                            
	@OPERATION void translate (String langFrom, String langTo, String msg, OpFeedbackParam<String> result) {    
		try {                
			result.set(callUrlAndParseResult(langFrom, langTo, msg)); 
			//System.out.println(result);		
        }           
		catch (Exception eLabel) {
			eLabel.printStackTrace();
		};   
	}
                                                                         
	private String callUrlAndParseResult(String langFrom, String langTo,
                                             String word) throws Exception {
		String url = "https://translate.googleapis.com/translate_a/single?"+
					 "client=gtx&"+
					 "sl=" + langFrom + 
					 "&tl=" + langTo + 
					 "&dt=t&q=" + URLEncoder.encode(word, "UTF-8");    
  
		URL obj = new URL(url);
		HttpURLConnection con = (HttpURLConnection) obj.openConnection(); 
		con.setRequestProperty("User-Agent", "Mozilla/5.0");
 
		BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
		String inputLine;
		StringBuffer response = new StringBuffer();
 
		while ((inputLine = in.readLine()) != null) {
			response.append(inputLine);
		}
		in.close();
		con.disconnect();
 
		return parseResult(response.toString());
	}
 
 	private String parseResult(String inputJson) throws Exception {
  
		// inputJson for word 'hello' translated to language Hindi from English-
  
		JSONArray jsonArray = new JSONArray(inputJson);
		JSONArray jsonArray2 = (JSONArray) jsonArray.get(0);
		JSONArray jsonArray3 = (JSONArray) jsonArray2.get(0);
  
		return jsonArray3.get(0).toString();
	}

	private static String getResourcesPath() {
		File currDir = new File(".");
		String path = currDir.getAbsolutePath();
		path = path.substring(0, path.length() - 2);
		//System.out.println(path);
		//logger.info(path);
		String resourcesPath = path + File.separator + "src" + File.separator + "resources";
		return resourcesPath;
	}
	

}

