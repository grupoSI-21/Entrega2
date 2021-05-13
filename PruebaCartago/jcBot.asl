// Chatbot Agent in project prueba.mas2j

/* Initial beliefs and rules */

// To take the account of bot answers
numAnswer(1).  

// Check if bot answer requires a service
/*Esto quiere decir que en el template debe ir el tipo de servicio
Aquí se chequea que está dicho servicio*/
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
	//getValTag("<file>", Answer, Route) & 	// Si se decide que la extensión viene dada
	getValTag("<file>",Answer,Name) & // Si solo se da el nombre sin extensión
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
	.substring(Answer,Name,Inicio+N+1,Fin-1)&
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
	getValTag("<file>", Answer, Name) & 	// Si se decide que la extensión no viene dada 
	.concat(Name, ".txt", Route). 			// e.o.c. esto sobra


/* Initial goals */

!checkingBot.

/* Plans */  

+!checkingBot <-
	!setupTool("gervasia",BotId);  
	!check; //esta regla es la que le mete el contenido al fichero utilidades en este caso pero no es del todo correcta
	!talk;
	!finish(BotId).
	
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
	.println("Elimino las intenciones."). // Just at this moment we can kill the agent if we wish.      
	
+!setupTool(Name, Id): true
	<- 	makeArtifact("bot0","bot.Services",[Name],Id);
		.wait(1000);
		focus(Id);
		makeArtifact("guiChat","chat.ChatGUI",[],GUI);
		focus(GUI).

+!talk <-
	//!say("Iván","Crea la propiedad nueva madre con valor ines, por favor");
	//!waitAnswer;
	!say("Iván","Incluye el valor pakistan en el conjunto pais sin más demora");
	!waitAnswer;
	!say("Iván","Incorpora la relacion entre pakistan y islamabad al mapa capital de inmediato");
	!waitAnswer;
	!say("Iván","Escribe tengo que rehacer el tag de relaciones en el fichero utilidades");
	!waitAnswer;
	!say("Iván","Conoces a juan carlos ?");
	!waitAnswer;
	// Comento esta línea para que no mande el correo y salte una excepción
	//!say("Iván","Envia el mensaje: debemos tratar el tema en persona lo antes posible a: gabriel con asunto: proyecto");
	//!waitAnswer;
	
	// Estas son las que trabajé, que son las del test que nos pasó en clase
	!say("Iván","Hola. Me llamo Ivan. Como te llamas tu?");
	!waitAnswer;
	!say("Iván","Que edad tienes?");
	!waitAnswer;
	!say("Iván","De donde eres? Vives en Orense?");
	!waitAnswer;
	!say("Iván","Que es lo que haces en tu tiempo libre?");
	!waitAnswer;
	!say("Iván","A que te dedicas?");
	!waitAnswer;
	!say("Iván","Así que estudias informática; en que curso estás?");
	!waitAnswer;
	!say("Iván","Qué tal te fué el último curso? Aprobaste todas las materias?");
	!waitAnswer;
	!say("Iván","Quien te dio clase en ProgramacionI?");
	!waitAnswer;
	!say("Iván","Qué puedes decirme sobre la asignatura de Sistemas Digitales?");
	!waitAnswer;
	!say("Iván","Conoces a la profesora Maria Jose Lado?");
	!waitAnswer;
	!say("Iván","Perdona, te acuerdas que contestaste hace 3 intervenciones?");
	!waitAnswer;
	!say("Iván","Sabes que la capital de Myanmar es NayPyiTaw?");
	!waitAnswer;
	!say("Iván","Por cierto, recuerda que Myanmar también se conoce como Burma.");
	!waitAnswer;
	!say("Iván","Puedes decirme cuantos amigos tienes con el pelo rubio?");
	!waitAnswer;
	!say("Iván","Adios.");
	!waitAnswer;
	.println("Y este cuento se acaboooooo").

+!say(Who,What) : numAnswer(N) <-
	!showQuest(Who,What);
	+pregunta(N,What);
	.wait(6000);                      
	chat(What).
+!say(Who,What) <- 
	.println("??????????????????????????????????????????????????????????????????").
	
+say(What) <-
	println("El Bot Master ha dicho: ", What);
	chatSincrono(What,Answer);
	println("El Bot contesta: ",Answer);
	show(Answer).

+!waitAnswer <-
	.wait(recibida(_));
	.wait(6000);
	.abolish(recibida(_)).

+!showQuest(Who,Question) <-
	.println("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
	.println(Who," dice: ",Question);
	//talk("Soledad",Question); // To listen the question    
	.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	.println.

+!showAnsw(Answer) : numAnswer(N) & bot(Bot) 
	<-	//talk("Carlos", Answer);
		.println("==================================================================");
		.println;
		.println(Bot, " contesta: ", Answer);
		.println;
		.println("==================================================================");
		.wait(3000);
		+contesta(N,Answer); // Guarda la contestación indexada por si queremos usarla más adelante   
		-+numAnswer(N+1);
		.wait(3000);
		.println.       
		
+!doService(translating, Answer, Response): 
		bot(Name) & 
		filter(Answer, translating, [To,Msg])
	<-	translate("es", To, Msg, Translation);
		.concat("La traducción que pediste es: ", Translation, Response).
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

+answer(Answer) : service(Answer, Service)	
	<- 	//-answer(Answer)[source(percept)];
		!doService(Service, Answer, Response);
		!showAnsw(Response); 
		+realizada(Answer, Response);	// Registra los Servicios realizados
		+recibida(Answer).   			// Hace la función de la creencia answer 
						 	 			// => conocimiento sin indexar con posibilidad de tener repetición 
+answer(Answer) 	
	<- 	//-answer(Answer)[source(percept)];
		!showAnsw(Answer);     
		+recibida(Answer).   // Hace la función de la creencia answer 
						 	 // => conocimiento sin indexar con posibilidad de tener repetición 

	
+recibida(Answer) : .substring("música",Answer) <- 
	//.println("==================================================================");
	//.println;
	!say("Juan Carlos","Tienes algún grupo o artista preferido?");
	!waitAnswer;
	.abolish(recibida(_)).

+recibida(Answer) : .substring("literatura",Answer) <- 
	//.println("==================================================================");
	//.println;
	!say("Juan Carlos","Cual es el último libro que has leido?");
	!waitAnswer;
	.abolish(recibida(_)).

+recibida(Answer) : .substring("deporte",Answer) <- 
	//.println("==================================================================");
	//.println;
	!say("Juan Carlos","Eres forofo o practicante?");
	!waitAnswer;
	.abolish(recibida(_)).

+recibida(Answer) : .substring("cine",Answer) <- 
	//.println("==================================================================");
	//.println;
	!say("Juan Carlos","Eres más de series o de películas?");
	!waitAnswer;
	.abolish(recibida(_)).

+recibida(Answer) : .substring("SI",Answer) <- 
	//.println("==================================================================");
	//.println;
	!say("Juan Carlos","Que asignatura te ha dado Maria Jose Lado?");
	!waitAnswer.
	
+recibida(Answer) : .substring("NO",Answer) <- 
	//.println("==================================================================");
	//.println;
	!say("Juan Carlos","Este curso imparte ProgramacionI. Quien dices que te dió clase en ProgramacionI?");
	!waitAnswer.

/*
5) YO: 	música => Tienes algún grupo o artista preferido?
		literatura => Cual es el último libro que has leido?
		deporte => Eres forofo o practicante?
		cine => Eres más de series o de películas?
*/

+!check  : 	bot(Name) & 
			.concat("bots/",Name,BotName) & 
			.concat(BotName,"/config/properties.txt",Route) 
	<-
	//.println("El bot en funcionamiento es: ", Name);
	//translate("es", "en", "Como ves lo que haces ? Lo ves bien ?", Translation);
	//.println("La traducción es: ", Translation);
	//writeOnFile("peso:120",Route);
	//.println("Añadida la propiedad peso:120 al fichero: ",Route);
	//mail("igcortegoso@gmail.com", "A ver si hay suerte", "Intento enviar mensajes");
	//.println("He enviado un correo a igcortegoso@gmail.com, con el Subject: Esto es una prueba de envio");
	//createFile("pedete.txt");   
	//.println("He creado el fichero pedete.txt");   
	writeOnFile("Tengo que rehacer el tag de relaciones","utilidades.txt");
	.println("He incluido el contenido: Tengo que rehacer el tag de relaciones en el fichero: utilidades.txt").	
























































































































































































                                                                                                    
