<?php 

class FAQModel extends BaseModel {

	protected $id = 0;
	protected $question = '';
	protected $answer = '';
	protected $active = false;

	protected static $table_name = 'faqs';
    
    /**
     * Gets the value of id.
     *
     * @return mixed
     */
    public function getId()
    {
        return $this->id;
    }

    /**
     * Gets the value of question.
     *
     * @return mixed
     */
    public function getQuestion()
    {
        return $this->question;
    }

    /**
     * Gets the value of answer.
     *
     * @return mixed
     */
    public function getAnswer()
    {
        return $this->answer;
    }

    /**
     * Gets the value of active.
     *
     * @return mixed
     */
    public function isActive()
    {
        return (bool)$this->active;
    }
}