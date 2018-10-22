<?php
/**
 * @author    Analog Republic
 * @version   1.0
 * @copyright Copyright (c) 2014, Pride Study
 **/

class BaseIterator implements Iterator {
    protected $position = 0;
    protected $array = array();

    public function __construct($array) {
        $this->array = $array;
        $this->position = 0;
    }

    function rewind() {
        $this->position = 0;
    }

    function current() {
        return $this->array[$this->position];
    }

    function key() {
        return $this->position;
    }

    function next() {
        ++$this->position;
    }

    function valid() {
        return isset($this->array[$this->position]);
    }

}
