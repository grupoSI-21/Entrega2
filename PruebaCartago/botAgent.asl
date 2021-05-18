/* Initial beliefs and rules */

~inEvent.
numPregunta(1).

// Check if bot answer requires a service
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
service (Answer, addingReminder) :-     // Reminder service
	checkTag("<reminder>", Answer).
	
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
	getValTag("<file>",Answer,Name) &
	.concat(Name,".txt",Route) &
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
	.substring(Answer,Name,Inicio+N,Fin) &
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

filter(Answer, addingReminder, [Reminder]) :-
	getValTag("<reminder>", Answer, Reminder).

/* Initial goals */

!checkingBot.

/* Plans */  

+!checkingBot <-
	!setupTool("gervasia",BotId);
	addEventRelativeSeconds("que mandar un mensaje", 5);
	addEventRelativeSeconds("que atender una llamada de mi profesor, es importante", 20);
	addEventRelativeSeconds("que vigilar la olla de lentejas que si no se me queman", 40);
	addEventRelativeSeconds("que tengo que ir al ba�o", 60).
	
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
	!say2(Ag, Q).

// Esta versión no imprime la pregunta por la consola, solo la respuesta
+!say2(Ag, Q) : numPregunta(N) <-
	+question(N, Ag, Q); // Guarda la pregunta del agente Ag
	+numPregunta(N+1);
	chatSincrono(Q, Resp);
	+response(N, Resp); // Guarda la respuesta (sin procesar los tags)
	!processResponse(Resp, Processed);
	+processed(N, Resp); // Guarda la respuesta (procesando los tags)
	!showAnsw(botAgent, Processed);
	.send(Ag, achieve, say(botAgent, Processed)).

+!say(Ag, Q) <- !showQuest(Ag, Q);
				+sayAgent(Ag, Q).
	
// Resp: es la respuesta sin procesar las etiquetas de servicios
// Processed: es la respuesta después de haber procesado las etiquetas
+!processResponse(Resp, Processed) : service(Resp, Service) <-
	!doService(Service, Resp, Processed).
	
+!processResponse(Resp, Resp).

+say(Q) <- !sayFromChat(Q).

+!sayFromChat(Q) : not inEvent & numPregunta(N) <-
	+question(N, human, Q);
	+numPregunta(N+1);
	chatSincrono(Q,Resp);
	+response(N, Resp);
	!processResponse(Resp, Processed);
	+processed(N, Resp);
	show(Processed).
	
+!sayFromChat(Msg) <- +sayChat(Msg).

+evento(Ev) <-
	.concat("Disculpa, tengo ", Ev, Ans);
	+inEvent;
	!showAnsw(botAgent, Ans);
	show(Ans);
	.wait(10000);
	-inEvent.

// Cuando se triggea el recordatorio
+recordatorio(Rem) : remByAgent(Rem, human) <-
	.concat("Hey, recuerda ", Rem, Ans);
	show(Ans).
	
+recordatorio(Rem) : remByAgent(Rem, Ag) <-
	.concat("Hey, recuerda ", Rem, Ans);
	!showAnsw(botAgent, Ans);
	.send(Ag, achieve, say(botAgent, Ans)).
	

//caso 1: Human y AnotherAgent le hablaron mientras estaba ocupado
-inEvent : sayChat(Msg1) & sayAgent(Ag, Msg2) <-
	-sayChat(Msg1);
	-sayAgent(Ag, Msg2);
	.concat("Ya esta, me estabas comentando que ", Msg1, Ans1);
	.concat("Ya esta, me estabas comentando que ", Msg2, Ans2);
	show(Ans1);
	!sayFromChat(Msg1);
	!showAnsw(Ag, Ans2);
	!say2(Ag, Msg2).

//caso 2: le habló AnotherAgent mientras estaba ausente
-inEvent : sayAgent(Ag, Msg) <-
	-sayAgent(Ag, Msg);
	.concat("Ya esta, me estabas comentando que ", Msg, Ans);
	show("Ya esta");
	!showAnsw(botAgent, Ans);
	!say2(Ag, Msg).

//caso 3: le habló Human mientras estaba ausente
-inEvent : sayChat(Msg) <-
	-sayChat(Msg);
	.concat("Ya esta, me estabas comentando que ", Msg, Ans);
	show(Ans);
	!sayFromChat(Msg);
	!showAnsw(botAgent, "Ya esta").

//caso 4: no le hablaron mientras estaba ausente
-inEvent <-
	!showAnsw(botAgent, "Ya esta");
	show("Ya esta").


+!showQuest(Who,Question) <-
	.println("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
	.println(Who," dice: ",Question);
	.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	.println.

+!showAnsw(Who, Answer) <-
		.println("==================================================================");
		.println;
		.println(Who, " contesta: ", Answer);
		.println;
		.println("==================================================================");
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
+!doService(addingReminder, Answer, Response) :
	question(N, Ag, _) & response(N, Answer) & // Con esto vemos qué agente pidio el recordatorio
	filter(Answer, addingReminder, [Reminder]) <-
		addReminder(Reminder);
		+remByAgent(Reminder, Ag);
		.concat("De acuerdo, te recordare ", Reminder, Response).
