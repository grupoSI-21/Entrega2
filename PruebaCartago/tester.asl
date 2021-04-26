// Agent tester in project prueba.mas2j

/* Initial beliefs and rules */

// To take the account of bot answers
numAnswer(1).
                 
/* Initial goals */

!start.

/* Plans */

+!start <-
	!setupTool(ChatterBot);
	.wait(1000);
	focus(ChatterBot);
	!talk;
	!finish.
	 
+!finish <-
	.wait(200);
	.abolish(All);
	.println("Eliminadas las creencias.");
	.wait(200);
	.drop_all_desires;
	.println("Eliminados los deseos.");
	.wait(200);
	.drop_all_events;
	.println("Eliminados los eventos.");
	.wait(200);
	.drop_all_intentions;
	.println("Eliminadas las intenciones.")	.
	
+!setupTool(C): true
  <- makeArtifact("bot0","bot.Chatter",["jcBot"],C).

+!talk <- 
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
	.println("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
	.println(Who," dice: ",What);
	gui.talking("Soledad",What);
	.println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
	.println;
	+pregunta(N,What);
	.wait(5000);
	chat(What).
+!say(Who,What) <- 
	.println("??????????????????????????????????????????????????????????????????").

+!waitAnswer <-
	.wait(recibida(_));
	.wait(600);
	.abolish(recibida(_)).


+answer(Answer) : numAnswer(N) & bot(Bot) <- 
	-answer(Answer)[source(percept)];
	gui.talking("Carlos",Answer);
	.println("==================================================================");
	.println;
	.println(Bot, " contesta: ", Answer);
	.println;
	.println("==================================================================");
	.wait(1000);
	+contesta(N,Answer); // Guarda la contestación indexada por si queremos usarla más adelante                   
	-+numAnswer(N+1);
	.wait(1000);
	.println;
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

























































































































































































                                                                                                    
