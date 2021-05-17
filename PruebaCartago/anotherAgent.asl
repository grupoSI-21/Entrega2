!start.

+!start <-
	.wait(2000); // Para que de tiempo a inicializarse
	!sendQuestion("hola").

+!sendQuestion(Q) <-
	.println("> \"", Q, "\"", " -  pregunto");
	.send(botAgent, achieve, say(anotherAgent, Q));
	.wait(5000);
	!sendQuestion("hola").

+!say(Ag, Resp) <-
	.println("< \"", Resp, "\"", " -  me responde ", Ag).
	
+say(Msg) <-
	.println("Me repsonden", Msg).

