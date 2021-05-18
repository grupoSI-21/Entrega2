!start.

+!start <-
	.wait(5000); // Para que de tiempo a inicializarse
	!sendQuestion("Traduce al ingles la frase me gusta el queso");
	.wait(8000);
	!sendQuestion("Ahora traduce al italiano la frase los carpinchos son los mejores animales del mundo");
	.wait(8000);
	!sendQuestion("Y por ultimo, me gustaria que tradujeras lo peor del verano son los mosquitos al euskera");
	.wait(8000);
	!sendQuestion("Quiero que traduzcas al rumano la frase a quien madruga dios no lo ayuda");
	.wait(8000);
	!sendQuestion("Me gustaria que tradujeras odio los dias de lluvia al suajili");
	.wait(8000);
	!sendQuestion("Por favor traduce al esperanto la frase la pizza es lo mejor");
	.wait(8000);
	!sendQuestion("Envia el mensaje: debemos tratar el tema en persona lo antes posible a: gabriel con asunto: proyecto");
	.wait(8000);
	//!sendQuestion("Envia el mensaje: hola a: valentina con asunto: prueba");
	//.wait(8000);
	!sendQuestion("Traduce al ingles la frase me gusta el queso");
	.wait(8000);
	!sendQuestion("Ahora traduce al italiano la frase los carpinchos son los mejores animales del mundo");
	.wait(8000);
	!sendQuestion("Y por ultimo, me gustaria que tradujeras lo peor del verano son los mosquitos al euskera");
	.wait(8000);
	!sendQuestion("Crea la propiedad nueva madre con valor ines, por favor");
	.wait(8000);
	!sendQuestion("Incluye el valor pakistan en el conjunto pais sin mas demora");
	.wait(8000);
	!sendQuestion("Incorpora la relacion entre pakistan y islamabad al mapa capital de inmediato");
	.wait(8000);
	!sendQuestion("Escribe tengo que rehacer el tag de relaciones en el fichero utilidades");
	.wait(8000);
	!sendQuestion("Conoces a juan carlos ?");
	.wait(8000);
	!sendQuestion("Hola. Me llamo Ivan. Como te llamas tu?");
	.wait(8000);
	!sendQuestion("Que edad tienes?");
	.wait(8000);
	!sendQuestion("De donde eres? Vives en Orense?");
	.wait(8000);
	!sendQuestion("Que es lo que haces en tu tiempo libre?");
	.wait(8000);
	!sendQuestion("A que te dedicas?");
	.wait(8000);
	!sendQuestion("Asi que estudias informatica; en que curso estas?");
	.wait(8000);
	!sendQuestion("Que tal te fue el ultimo curso? Aprobaste todas las materias?");
	.wait(8000);
	!sendQuestion("Quien te dio clase en ProgramacionI?");
	.wait(8000);
	!sendQuestion("Que puedes decirme sobre la asignatura de Sistemas Digitales?");
	.wait(8000);
	!sendQuestion("Conoces a la profesora Maria Jose Lado?");
	.wait(8000);
	!sendQuestion("Perdona, te acuerdas que contestaste hace 3 intervenciones?");
	.wait(8000);
	!sendQuestion("Sabes que la capital de Myanmar es NayPyiTaw?");
	.wait(8000);
	!sendQuestion("Por cierto, recuerda que Myanmar tambien se conoce como Burma.");
	.wait(8000);
	!sendQuestion("Puedes decirme cuantos amigos tienes con el pelo rubio?");
	.wait(8000);
	!sendQuestion("Adios.").

+!sendQuestion(Q) <-
	//.println("> \"", Q, "\"", " -  pregunto");
	.send(botAgent, achieve, say(pepe, Q)).

+!say(Ag, Resp) <-
	.println("< \"", Resp, "\"", " -  me responde ", Ag).

