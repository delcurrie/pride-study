<?php 

/**
 * Represent a welcome page slide
 */
class SlideModel extends BaseModel {

	protected $id = 0;
	protected $image = '';
	protected $text = '';
	protected $sort_order = 0;
	protected $active = 0;

	protected static $table_name = 'slides';
	protected static $image_folder = 'welcome';

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
     * Gets the value of image.
     *
     * @return mixed
     */
    public function getImage($full = false)
    {
    	if(!$full) return $this->image;
        return self::getImageFolder('slides') . $this->image;
    }

    /**
     * Gets the value of text.
     *
     * @return mixed
     */
    public function getText()
    {
        return $this->text;
    }

    /**
     * Gets the value of sort_order.
     *
     * @return mixed
     */
    public function getSortOrder()
    {
        return (int)$this->sort_order;
    }

    /**
     * Gets the value of active.
     *
     * @return mixed
     */
    public function getActive()
    {
        return (bool)$this->active;
    }

    /**
     * Grab all active slides in sorted order
     * 
     * @return Array<SlideModel>
     */
    public static function findInOrder()
    {
    	return self::find(array('active = 1'), null, 'order by sort_order asc');
    }
}