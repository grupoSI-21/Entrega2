package agenda;

import cartago.*;
import cartago.tools.*;
import java.util.LinkedList;
import java.util.ListIterator;
import java.time.format.DateTimeFormatter;
import java.time.Duration;
import java.time.LocalDateTime;


class Event {
	private String name;
	private LocalDateTime date;
	
	public Event(String name, LocalDateTime date) {
		this.name = name;
		this.date = date;
	}
	
	public String getName() {
		return name;
	}
	
	public LocalDateTime getDate() {
		return date;
	}
}

public class Agenda extends Artifact {
	private boolean monitoring;
	private LinkedList<Event> events = new LinkedList<>();
	
	void init() {
		monitoring = true;
		execInternalOp("start");
	}
	
	// Añade un evento con nombre name que se notificará al bot en s segundos
	@OPERATION void addEventRelativeSeconds(String name, int s) {
		events.add(new Event(name, LocalDateTime.now().plus(Duration.ofSeconds(s))));
	}

	@INTERNAL_OPERATION void start() {
		// Monitorea en busca de eventos cada segundo
		while (monitoring) {
			ListIterator<Event> iter = events.listIterator();
			while(iter.hasNext()) {
				Event event = iter.next();
				if (event.getDate().isBefore(LocalDateTime.now())){
					iter.remove();
					signal("evento",event.getName());
				}
			}
			await_time(1000); // cada 1 segundo
		}
	}
	
}
