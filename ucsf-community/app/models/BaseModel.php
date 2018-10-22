<?php
/**
 * @author    Analog Republic
 * @version   1.0
 * @copyright Copyright (c) 2014, Pride Study
 **/

class BaseModel
{

    public static function build($params, $instance = null)
    {
        if (!$instance) {
            $class = get_called_class();
            $instance = new $class;
        }

        foreach ((array) $params as $key => $value) {
            $instance->{$key} = $value;
        }
        return $instance;
    }

    public static function getImageFolder($size, $type = 'partial')
    {
        $class = get_called_class();
        eval('$folder = '.$class.'::$image_folder;');
        $folder_size = $folder.'-'.$size;
        if ($type == 'path') {
            return DIR_ROOT . FOLDER_ASSETS . DS . FOLDER_IMG . DS . $folder_size . DS;
        } elseif ($type == 's3path') {
            return FOLDER_IMG . '/' . $folder_size . '/';
        } elseif (awsEnabled === true) {
            return awsURL . FOLDER_IMG . '/' . $folder_size . '/';
        } elseif ($type == 'full') {
            return HTTP_URL_BASE . FOLDER_ASSETS . '/' . FOLDER_IMG . '/' . $folder_size . '/';
        } else {
            return URL_BASE . FOLDER_ASSETS . '/' . FOLDER_IMG . '/' . $folder_size . '/';
        }
    }

    public static function getTableName()
    {
        $class = get_called_class();
        eval('$table_name = '.$class.'::$table_name;');
        return $table_name;
    }

    public static function find($where = array(), $bound_values = array(), $extra = '')
    {
        $where = (isset($where[0])?' where '.implode(' and ', $where):'');
        $query = 'select * from '.self::getTableName(). $where.' '.$extra;
        $db = Database::getInstance();

        if (!empty($bound_values)) {
            $stmt = $db->prepare($query);
            $stmt->execute($bound_values);
        } else {
            $stmt = $db->query($query);
        }
        $objects = array();
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $objects[] = self::build($row);
        }
        return $objects;
    }

    public static function count($where = array(), $bound_values = array())
    {
        $where = (isset($where[0])?' where '.implode(' and ', $where):'');
        $query = 'select count(*) from '.self::getTableName(). $where;
        $db = Database::getInstance();
        if (!empty($bound_values)) {
            $stmt = $db->prepare($query);
            $stmt->execute($bound_values);
        } else {
            $stmt = $db->query($query);
        }
        return $stmt->fetchColumn();
    }

    /**
     * Find a customer by their ID
     *
     * @param  integer $id
     * @return CustomerModel
     */
    public static function findById($id = 0)
    {
        return current(self::find(array('id = :id'), array('id' => $id), 'limit 1'));
    }

    /**
     * Create a new version of this
     * 
     * @param  array  $data The data to add
     * @return BaseModel
     */
    public static function create($data = array())
    {
        $table = self::getTableName();
        $db = Database::getInstance();
        $db->perform($table, $data);
        return self::findById($db->lastInsertId());
    }

    /**
     * Create a new version of this
     * 
     * @param  array  $data The data to add
     * @return BaseModel
     */
    public static function delete($id, $table = false)
    {
        if (!$table) {
            $table = self::getTableName();
        }
        $db = Database::getInstance();
        $db->query('delete from ' . $table . ' where id = ' . (int)$id);
    }

    /**
     * Update this model
     * 
     * @param  array  $data The data to update
     * @return BaseModel
     */
    public static function update($id, $data = array())
    {
        $table = self::getTableName();
        $db = Database::getInstance();
        $db->perform($table, $data, 'update', 'id = ' . $id);
        return self::findById($id);
    }

    /**
     * Convert this model to an array
     * of all public fields.
     *
     * @return Array
     */
    public function toArray()
    {
        return call_user_func('get_object_vars', $this);
    }
}
