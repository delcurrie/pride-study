<?php 

class TopicCategoryModel extends BaseModel
{

    protected $id = 0;
    protected $name = '';
    protected $active = 0;
    protected $slug = '';
    protected $type = '';

    protected static $table_name = 'topic_categories';

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
     * Gets the value of name.
     *
     * @return mixed
     */
    public function getName()
    {
        return $this->name;
    }

    /**
     * Gets the value of active.
     *
     * @return mixed
     */
    public function getActive()
    {
        return $this->active;
    }

    /**
     * Grab the slug for this category
     * 
     * @return string
     */
    public function getSlug()
    {
        return $this->slug;
    }

    /**
     * Get the type of category
     * 
     * @return string
     */
    public function getType()
    {
        return $this->type;
    }

    /**
     * Find all topic categories grouped by their type
     * 
     * @return Array<String, Array<TopicCategoryModel>>
     */
    public static function findGroupedByType($build = true)
    {
        $db = Database::getInstance();
        $sql = 'select * from topic_categories where active = 1';
        $query = $db->query($sql)->fetchAll(PDO::FETCH_ASSOC);

        $categories = array();

        foreach ($query as $query_row) {
            if ($build) {
                $category = TopicCategoryModel::build($query_row);
            } else {
                $category = $query_row;
            }

            $categories[$query_row['type']][] = $category;
        }

        return $categories;
    }

    /**
     * Get a category by slug
     * 
     * @param  string $slug     
     * @return TopicCategoryModel
     */
    public static function findBySlug($slug = '')
    {
        return current(self::find(array('slug = :slug'), array('slug' => $slug)));
    }

    /**
     * Get the name field by slug
     * 
     * @param  String $slug
     * @return String       
     */
    public static function getNameBySlug($slug = '')
    {
        $name = '';
        $category = self::findBySlug($slug);
        if ($category) {
            $name = $category->getName();
        }

        return $name;
    }

    /**
     * Get the total number of topics for this category
     * 
     * @return int
     */
    public function getCountTopics()
    {
        $db = Database::getInstance();
        return $db->query('select count(id) as count from topics_to_topic_categories where topic_category_id = ' . $this->getId())->fetchColumn();
    }
}
