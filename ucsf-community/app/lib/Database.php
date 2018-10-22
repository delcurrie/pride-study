<?php
/**
 * @author    Analog Republic
 * @version   1.1
 * @copyright Copyright (c) 2014, Pride Study
 **/

if (class_exists('PDO')) {
    class PDOWrapper extends PDO {}
} else {
    /*loadLib('vendor'.DS.'phppdo-1.4'.DS.'phppdo');
    if (!class_exists('PHPPDO'))
        throw new Exception("PDODO doesn't exist.");

    class PDOWrapper extends PHPPDO {}*/
    die('PDO is missing');
}

class PDOHelper extends PDOWrapper {
    public function perform($table, $data, $action = 'insert', $update_params = '1') {
        if ($action == 'insert') {
            $keys = array();
            $values = array();
            $new_data = array();
            foreach ($data as $k => $v) {
                $keys[] = $k;
                if ($v === 'now()') {
                    $values[] = 'now()';
                } elseif (strpos($v, 'GeomFromText') === 0) {
                    $values[] = $v;
                } else {
                    $values[] = ':'.$k;
                    $new_data[':'.$k] = $v;
                }
            }
            try {
                $query = 'INSERT INTO '.$table.' ('.implode(', ', $keys).') VALUES ('.implode(', ', $values).')';
                $stmt = $this->prepare($query);
                $stmt->execute($new_data);
                return $stmt;
            } catch (PDOException $e) {
                throw $e;
            }
        } elseif ($action == 'update') {
            $keys = array();
            $new_data = array();
            foreach ($data as $k => $v) {
                if ($v === 'now()') {
                    $keys[] = $k.' = now()';
                } elseif (strpos($v, 'GeomFromText') === 0) {
                    $keys[] = $k.' = GeomFromText(?)';
                    $new_data[] = substr(str_replace('GeomFromText(', '', $v), 1, -2);
                } else {
                    $keys[] = $k.' = ?';
                    $new_data[] = $v;
                }
            }
            try {
                $query = 'UPDATE '.$table.' SET '.implode(', ', $keys).' WHERE '.$update_params;
                $stmt = $this->prepare($query);
                $stmt->execute($new_data);
                return $stmt;
            } catch (PDOException $e) {
                throw $e;
            }
        }
    }
}

// http://wiki.hashphp.org/PDO_Tutorial_for_MySQL_Developers

class Database {
    static $db;
    private $dbh;

    private function __construct() {
        try {
            $dsn = DB_TYPE.":host=".DB_HOST.";port=".DB_PORT.";dbname=".DB_NAME;
            $this->dbh = new PDOHelper($dsn, DB_USERNAME, DB_PASSWORD);
            $this->dbh->setAttribute(PDO::ATTR_PERSISTENT, true);
            $this->dbh->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            $this->dbh->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
            $this->dbh->exec("SET NAMES ".DB_CHARSET);
        } catch (PDOException $e) {
            throw $e;
        }
    }

    public static function getInstance() {
        if (!isset(Database::$db)) {
            Database::$db = new Database();
        }
        return Database::$db->dbh;
    }
}
