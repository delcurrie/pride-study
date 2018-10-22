<?php 

/**
 * Base event handler
 */
class EventHandler {

	private static $events = array();

    /**
     * Gets the value of events.
     *
     * @return mixed
     */
    public static function getEvents()
    {
        return self::$events;
    }

    /**
     * Sets the value of events.
     *
     * @param mixed $events the events
     */
    private static function setEvents($events)
    {
        self::$events = $events;
    }

    /**
     * Register a function handler to an event
     * 
     * @param  string $name
     * @param  string $method_name
     */
    public static function register($name, $method_name)
    {
    	self::$events[$name] = $method_name;
    }

    /**
     * Fire off an event
     * 
     * @param  string $name
     * @throws EventNotRegisteredException
     * @return mixed
     */
    public static function fire($name, $data = false) 
    {
    	if(!isset(self::$events[$name])) {
    		throw new EventNotRegisteredException('You need to register the event: ' . $name . ' before you can fire it.');
    	}

    	$method = self::$events[$name];
    	if(!method_exists(get_called_class(), $method)) {
    		throw new EventHandlerMethodNotExistsException('You must define the method: ' . $method . ' in: ' . get_called_class());
    	}

        $to_call = array(get_called_class(), $method);
        $arguments = array_slice(func_get_args(), 1);
    	return forward_static_call_array($to_call, $arguments);
    }
}

/**
 * Exception for when an event hasn't been registered
 */
class EventNotRegisteredException extends Exception {}

/**
 * Exception for handling when you try to call
 * a non existing method on an event handler.
 */
class EventHandlerMethodNotExistsException extends Exception {}