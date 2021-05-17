// Chatbot Agent in project prueba.mas2j

/* Initial beliefs and rules */

// NOT inEvent
~inEvent.

// Check if bot answer requires a service
/*Esto quiere decir que en el template debe ir el tipo de servicio
Aqui se chequea que esta dicho servicio*/
service(Answer, translating):- 			// Translating service
	checkTag("<translate>",Answer).
service(Answer, mailing):- 				// Mailing service
	checkTag("<mail>",Answer).
service(Answer, addingBot):- 			// Adding a bot property service
	checkTag("<botprop>",Answer).
service(Answer, creatingSet):- 			// Creating a set service
	checkTag("<addset>",Answer)&
	not checkTag("<new>",Answer).
service(Answer, addingSet):- 			// Adding a new value to a set service
	checkTag("<addset>",Answer)&
	checkTag("<new>",Answer).
service(Answer, creatingMap):- 			// Creating a map service
	checkTag("<addmap>",Answer) &
	not checkTag("<new>",Answer).
service(Answer, addingMap):- 			// Adding a new property with value to a map service
	checkTag("<addmap>",Answer) &
	checkTag("<new>",Answer).
service(Answer, addingFile):- 			// Adding content to a file service
	checkTag("<addtxt>",Answer).
service(Answer, creatingFile):- 		// Creating a new file service
	checkTag("<file>",Answer) &
	not service(Answer, addingfile).
	
// Checking a concrete service required by the bot ia as simple as find the required tag
// as a substring on the string given by the second parameter
checkTag(Service,String) :-
	.substring(Service,String). //devuelve true o false


// Gets into Val the first substring contained by a tag Tag into String
getValTag(Tag,String,Val) :- 
	.substring(Tag,String,Fst) &       // First: find the Fst Posicition of the tag string              
	.length(Tag,N) &                   // Second: calculate the length of the tag string
	.delete(0,Tag,RestTag) &     
	.concat("</",RestTag,EndTag) &     // Third: build the terminal of the tag string
	.substring(EndTag,String,End) &    // Four: find the Fst Position of the terminal tag string
	.substring(String,Val,Fst+N,End).  // Five: get the Val tagged
	
	/*
		Another way to get the value will consist to delete from String the prefix, sufix and tags
		in order to let only the required Val
	*/  


// Filter the answer to be showed when the service indicated as second arg is done
filter(Answer, translating, [To,Msg]):-
	getValTag("<to>",Answer,To) &
	getValTag("<msg>",Answer,Msg).
	
filter(Answer, mailing, [To,Sub,Msg]):-
	getValTag("<to>",Answer,To) &
	getValTag("<subject>",Answer,Sub) &
	getValTag("<msg>",Answer,Msg).
	
filter(Answer, addingBot, [ToWrite,Route]):-
	getValTag("<name>",Answer,Name) &
	getValTag("<val>",Answer,Val) &
	.concat(Name,":",Val,ToWrite) &
	bot(Bot) &
	.concat("/bots/",Bot,BotName) &
	.concat(BotName,"/config/properties.txt",Route).	

filter(Answer, addingFile, [Text,Route]) :-
	//getValTag("<file>", Answer, Route) & 	// Si se decide que la extension viene dada
	getValTag("<file>",Answer,Name) & // Si solo se da el nombre sin extension
	.concat(Name,".txt",Route) & 		// Adecuar a la requerida
	getValTag("<txt>", Answer, Text).
	
filter(Answer, addingSet, [Text,Route]):- 
	getValTag("<new>",Answer,Text) &
	.substring("</new>",Answer,Inicio) &
	.length("</new>",N) &
	.substring("</addset>",Answer,Fin) & 
	.substring(Answer,Name,Inicio+N+1,Fin-1)&
	.concat(Name,".txt",File) &
	bot(Bot) &
	.concat("/bots/",Bot,BotName) &
	.concat(BotName,"/sets/",SetsPath) &
	.concat(SetsPath,File,Route).

filter(Answer, addingMap, [Text,Route]):- 
	getValTag("<new>",Answer,Text) &
	.substring("</new>",Answer,Inicio) &
	.length("</new>",N) &
	.substring("</addmap>",Answer,Fin) & 
	.substring(Answer,Name,Inicio+N,Fin)&
	//.substring(Answer,Name,Inicio+N+1,Fin-1)&
	.concat(Name,".txt",File) &
	bot(Bot) &
	.concat("/bots/",Bot,BotName) &
	.concat(BotName,"/maps/",MapsPath) &
	.concat(MapsPath,File,Route).

filter(Answer, creatingSet, [Route]):- 
	getValTag("<addset>", Answer, Name) &
	.concat(Name, ".txt", File) &
	bot(Bot) &
	.concat("/bots/", Bot, BotName) &
	.concat(BotName, "/sets/", SetsPath) &
	.concat(SetsPath, File, Route).

filter(Answer, creatingMap, [Route]):- 
	getValTag("<addmap>", Answer, Name) &
	.concat(Name, ".txt", File) &
	bot(Bot) &
	.concat("/bots/", Bot, BotName) &
	.concat(BotName, "/maps/", SetsPath) &
	.concat(SetsPath, File, Route).

filter(Answer, creatingFile, [Route]):- 
	getValTag("<file>", Answer, Name) & 	// Si se decide que la extension no viene dada 
	.concat(Name, ".txt", Route). 			// e.o.c. esto sobra


/* Initial goals */

!checkingBot.

/* Plans */  

+!checkingBot <-
	!setupTool("gervasia",BotId);
	addEventRelativeSeconds("que mandar un mensaje", 9);
	addEventRelativeSeconds("que vigilar la olla de lentejas que si no se me queman", 20);
	addEventRelativeSeconds("que atender una llamada de mi profesor, es importante", 31);
	addEventRelativeSeconds("que tengo que ir al banho", 40).
	
	
+!finish(Artifact) <-  
	.println("Quito el foco del artefacto: ", Artifact);
	stopFocus(Artifact);
	.println("Elimino el artefacto: ", Artifact);
	disposeArtifact(Artifact);
	.wait(200);               
	.abolish(All);
	.println("Elimino las creencias.");
	.wait(200);
	.drop_all_desires;
	.println("Elimino los deseos.");
	.wait(200);
	.drop_all_events;
	.println("Elimino los eventos.");            
	.wait(200);
	.drop_all_intentions;
	.println("Elimino las intenciones.").
	
+!setupTool(Name, Id): true
	<- 	makeArtifact("bot0","bot.Services",[Name],Id);
		.wait(1000);
		focus(Id);
		makeArtifact("guiChat","chat.ChatGUI",[],GUI);
		focus(GUI);
		.wait(1000);
		makeArtifact("agenda","agenda.Agenda",[],Agenda);
		focus(Agenda).

+!say(Ag, Q) : not inEvent <-
	!showQuest(Ag, Q);
	chatSincrono(Q, Resp);
	!processResponse(Resp, Processed);
	!showAnsw(botAgent, Processed);
	.send(Ag, achieve, say(botAgent, Processed)).

+!say(Ag, Q) <- +sayAgent(Ag, Q).
	
+!processResponse(Resp, Processed) : service(Resp, Service) <-
	!doService(Service, Resp, Processed).
	
+!processResponse(Resp, Resp).

+say(Msg) <- !sayFromChat(Msg).

+!sayFromChat(Msg) : not inEvent <-
	!showQuest(human, Msg);
	chatSincrono(Msg,Resp);
	!processResponse(Resp, Processed);
	!showAnsw(botAgent, Processed);
	show(Processed).
	
+!sayFromChat(Msg) <- +sayChat(Msg).

+evento(Ev) <-
	.concat("Disculpa, tengo ", Ev, Ans);
	+inEvent;
	!showAnsw(botAgent, Ans);
	show(Ans);
	.wait(5000);
	-inEvent.

-inEvent : sayChat(Msg1) & sayAgent(Ag, Msg2) <-
	.concat("Ya esta, me estabas comentando que ", Msg1, Ans1);
	.concat("Ya esta, me estabas comentando que ", Msg2, Ans2);
	show(Ans1);
	!showAnsw(botAgent, Ans1);
	!showAnsw(botAgent, Ans2).

-inEvent : sayAgent(Ag, Msg) <-
	.concat("Ya esta, me estabas comentando que ", Msg, Ans);
	show("Ya esta");
	!showAnsw(botAgent, "Ya esta").

-inEvent : sayChat(Msg)<-
	.concat("Ya esta, me estabas comentando que ", Msg, Ans);
	!showAnsw(botAgent, "Ya esta");
	show(Ans).

-inEvent <-
	!showAnsw(botAgent, "Ya esta");
	show("Ya esta").


+!showQuest(Who,Question) <-
	.println("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
	.println(Who," dice: ",Question);
	//talk("Soledad",Question); // To listen the question    
	.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	.println.

+!showAnsw(Who, Answer) <-
		.println("==================================================================");
		.println;
		.println(Who, " contesta: ", Answer);
		.println;
		.println("==================================================================");
		+contesta(N,Answer); // Guarda la contestacion indexada por si queremos usarla mas adelante   
		-+numAnswer(N+1);
		.println.       
		
+!doService(translating, Answer, Response): 
		bot(Name) & 
		filter(Answer, translating, [To,Msg])
	<-	translate("es", To, Msg, Translation);
		.concat("La traduccion que pediste es: ", Translation, Response).
+!doService(mailing, Answer, Response):
		bot(Name) & 
		filter(Answer, mailing, [To,Subject,Msg])
	<-	mail(To, Subject, Msg);
		.concat("Ya he enviado el correo que pediste a: ", To, Response).
+!doService(addingBot, Answer, Response):
		bot(Name) & 
		filter(Answer, addingBot, [Text,Route]) 
	<-	writeOnFile(Text,Route);
		.concat("He insertado la nueva propiedad del bot: ", Text, Response).
+!doService(creatingSet, Answer, Response):
		bot(Name) & 
		filter(Answer, creatingSet, [Route]) 
	<-	writeOnFile(Text,Route);
		.concat("He creado el conjunto: ", Route, Response).
+!doService(addingSet, Answer, Response):
		bot(Name) & 
		filter(Answer, addingSet, [Text,Route]) 
	<-	writeOnFile(Text,Route);
		.concat("He insertado el valor: ", Text, ResponseA);
		.concat(" en el conjunto: ", Route, ResponseB);
		.concat(ResponseA, ResponseB, Response).
+!doService(creatingMap, Answer, Response):
		bot(Name) & 
		filter(Answer, creatingMap, [Route]) 
	<-	writeOnFile(Text,Route);
		.concat("He creado el nuevo map: ", Route, Response).
+!doService(addingMap, Answer, Response):
		bot(Name) & 
		filter(Answer, addingMap, [Text,Route]) 
	<-	writeOnFile(Text,Route);
		.concat("He insertado la nueva relacion: ", Text, Response).
+!doService(addingFile, Answer, Response):
		bot(Name) & 
		filter(Answer, addingFile, [Text,Route]) 
	<-	writeOnFile(Text,Route);
		.concat("He insertado el texto: ", Text, ResponseA);
		.concat(" en el fichero: ", Route, ResponseB);
		.concat(ResponseA, ResponseB, Response).
+!doService(creatingFile, Answer, Response):
		bot(Name) & 
		filter(Answer, creatingFile, [Route]) 
	<-	createFile(Text,Route);
		.concat("He creado el fichero: ", Route, Response).
		
+!eventWait(Event, Seconds, Time_To_Wait)
	<-	.println("Disculpa un momento, tengo ", Event);
		addEventRelativeSeconds("que mandar un mensaje", Seconds);
		.wait(Time_To_Wait * 1000);
		!retomarConversacion.
		
+!eventWait(Event, Seconds, Time_To_Wait)
	<-	.println("Disculpa un momento, tengo ", Event);
		addEventRelativeSeconds("que vigilar la olla de lentejas que si no se me queman", Seconds);
		.wait(Time_To_Wait * 1000);
		!retomarConversacion.

+!eventWait(Event, Seconds, Time_To_Wait)
	<-	.println("Disculpa un momento, tengo ", Event);
		addEventRelativeSeconds("que atender una llamada de mi profesor, es importante", Seconds);
		.wait(Time_To_Wait * 1000);
		!retomarConversacion.
		
+!eventWait(Event, Seconds, Time_To_Wait)
	<-	.println("Disculpa un momento, tengo ", Event);
		addEventRelativeSeconds("que ir al ba�o", Seconds);
		.wait(Time_To_Wait * 1000);
		!retomarConversacion.
