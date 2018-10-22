<?php

/**
 * Validator wrapper around
 * the GUMP class. Provides an
 * easier interface which integrates
 * more neatly with the format
 * of AJAX responses.
 *
 */
class Validator extends GUMP {

	protected $input = array(),
			  $rules = array(),
			  $formatted_errors = array(),
			  $passed = false;

	private static $instance;

	/**
	 * Make a new validator with some input and some rules
	 * you can optionally disable input sanitization.
	 *
	 * @param  array   $input
	 * @param  array   $rules
	 * @param  boolean $sanitize
	 * @return Validator
	 */
	public static function make($input = array(), $rules = array(), $sanitize = true)
	{
		self::createCustomValidators();

		if(!self::$instance) {
			self::$instance = new Validator();
		}

		self::$instance->input = $input;
		self::$instance->rules = $rules;

		if($sanitize) {
			self::$instance->input = self::$instance->sanitize(self::$instance->input);
		}

		return self::$instance;
	}

	/**
	 * Grab the input for this validator
	 *
	 * @return Array
	 */
	public function getInput()
	{
		return $this->input;
	}

	/**
	 * Grab the rules for this validator
	 *
	 * @return Array
	 */
	public function getRules()
	{
		return $this->rules;
	}

	/**
	 * Did the validation fail?
	 *
	 * @return Boolean
	 */
	public function failed()
	{
		return $this->passed === false;
	}

	/**
	 * Process the validation
	 *
	 * @return Validator
	 */
	public function process()
	{
        $this->validation_rules($this->rules);
        $this->passed = (bool)$this->run($this->input);
		return $this;
	}

	/**
	 * Grab the errors returned after running
	 * the validator.
	 *
	 * @return Array
	 */
	public function getErrors()
	{
		$this->formatted_errors = $this->get_errors_array();
        foreach($this->formatted_errors as $key => $value) {
            unset($this->formatted_errors[$key]);
            $this->formatted_errors[str_replace(' ', '_', strtolower($key))] = ucfirst(strtolower($value));
        }
		return $this->formatted_errors;
	}

	/**
	 * This is where any custom validators are bound
	 *
	 * @return void
	 */
	private static function createCustomValidators()
	{
		self::add_validator("card_not_expired", function($field, $input, $param = NULL) {

		    $month = DateTime::createFromFormat('m', $input['month']);
            $month = $month->format('F');
            $year = DateTime::createFromFormat('y', $input['year']);
            $year = $year->format('Y');
            $date = new DateTime($month . ' ' . $year . ' next month - 1 hour');

            return $date > new DateTime();

		});
	}

}