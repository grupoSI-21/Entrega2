package agenda;

import cartago.*;
import cartago.tools.*;
import java.util.LinkedList;
import java.util.ListIterator;
import java.time.Duration;
import java.time.LocalDateTime;


class Event {
	private String name;
	private LocalDateTime date;
	private boolean isReminder;
	
	public Event(String name, LocalDateTime date, boolean isReminder) {
		this.name = name;
		this.date = date;
		this.isReminder = isReminder;
	}
	
	public String getName() {
		return name;
	}
	
	public LocalDateTime getDate() {
		return date;
	}
	
	public boolean isReminder() {
		return isReminder;
	}
}

public class Agenda extends Artifact {
	private boolean monitoring;
	private LinkedList<Event> events = new LinkedList<>();
	
	// Tiempo que tardarán en notificarse los recordatorios, en segundos
	public final static int secondsToTriggerReminder = 15;
	
	void init() {
		monitoring = true;
		execInternalOp("start");
	}
	
	// Añade un evento con nombre name que se notificará al bot en s segundos
	@OPERATION void addEventRelativeSeconds(String name, int s) {
		events.add(new Event(name, LocalDateTime.now().plus(Duration.ofSeconds(s)), false));
	}
	
	// Añade un recordatorio
	@OPERATION void addReminder(String name) {
		events.add(new Event(name, LocalDateTime.now().plus(Duration.ofSeconds(secondsToTriggerReminder)), true));
	}

	@INTERNAL_OPERATION void start() {
		// Monitorea en busca de eventos cada segundo
		while (monitoring) {
			ListIterator<Event> iter = events.listIterator();
			while(iter.hasNext()) {
				Event event = iter.next();
				if (event.getDate().isBefore(LocalDateTime.now())){
					
					if (event.isReminder()) signal("recordatorio",event.getName());
					else signal("evento",event.getName());
					
					iter.remove();
				}
			}
			await_time(1000); // cada 1 segundo
		}
	}
	
}
