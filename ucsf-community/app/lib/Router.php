<?php
/**
 * @author    Analog Republic
 * @version   1.0
 * @copyright Copyright (c) 2014, Pride Study
 **/

class Router {

    private $routes_array = array();

    private $parsed_route = '';
    private $parsed_route_array = array();

    private $request_uri = '';
    private $request_uri_parts;

    private $request_method = '';

    private $controller;
    private $controller_instance;

    private $params;

    private $need_https = false;
    private $ignore_https = false;

    private $home = '/';

    private $viable_routes = array();

    public function __construct($routes_array = array()) {

        $this->request_uri = $_SERVER['REQUEST_URI'];
        $has_query_string = strpos($this->request_uri, '?');
        $this->request_uri = ($has_query_string?substr($this->request_uri, 0, $has_query_string):$this->request_uri);
        $this->request_uri = clean_url($this->request_uri, true);

        if (PATH_FROM_ROOT != '/') {
            $root_string = strpos($this->request_uri, PATH_FROM_ROOT);
            $this->request_uri = substr($this->request_uri, $root_string + strlen(PATH_FROM_ROOT) - 1);
        }
        if ($this->request_uri === false || $this->request_uri == PATH_FROM_ROOT) {
            $this->request_uri = $this->home;
        }

        if (substr($this->request_uri, -1) == "/")
            $this->request_uri = substr($this->request_uri, 0, -1);

        $this->request_method = $_SERVER['REQUEST_METHOD'];
        $this->setRoutes($routes_array);

        foreach ($routes_array as $pattern => $details) {
            if (isset($details['name'])) {
                $this->viable_routes[$details['name']] = $pattern;
            }
        }
    }

    public function getURI($partial = false) {
        if ($partial)
            return substr($this->request_uri, 1);

        return PATH_FROM_ROOT.substr($this->request_uri, 1);
    }

    public function getURIParts() {
        if (!$this->request_uri_parts) {
            $this->request_uri_parts = explode('/', trim($this->request_uri, '/'));
        }
        return $this->request_uri_parts;
    }

    public function getRequestMethod() {
        return $this->request_method;
    }

    public function setRoutes($routes_array) {
        $this->routes_array = $routes_array;
        return $this;
    }

    public function parseRoute() {
        $path_found = false;
        foreach ($this->routes_array as $pattern => $details) {
            $pattern = $this->addSustitutes($pattern);
            $pattern = $this->parsed_route . $pattern;
            $params = array();
            if ($params = $this->matchRoute($pattern)) {

                if (isset($details['redirect'])) {
                    App::redirect($details['redirect'], (isset($details['code'])?$details['code']:302));
                }

                $this->setParsedRoute($pattern);
                if (!isset($details['controller']) && !isset($details['action']) && !isset($details['template'])) {
                    if (isset($details[$this->request_method])) {
                        $details = $details[$this->request_method];
                    } elseif (isset($details['ALL'])) {
                        $details = $details['ALL'];
                    } else {
                        throw new NotFoundException($this->request_uri);
                    }
                }

                if (ENABLE_SSL) {
                    $in_https     = !empty($_SERVER['HTTPS']);
                    $need_https   = ($details['https'] === true);
                    $ignore_https = ($details['https'] === 'ignore');
                    if ($ignore_https) {
                        $this->ignore_https = true;
                        $this->need_https = false;
                    }
                    if ($need_https) {
                        $this->need_https = true;
                        $this->ignore_https = false;
                    }
                    if ($this->ignore_https === false) {
                        if ($this->need_https && !$in_https) {
                            $url = $this->getURI(true);
                            App::redirect(HTTPS_URL_BASE . $url);
                        } elseif (!$this->need_https && $in_https) {
                            $url = $this->getURI(true);
                            App::redirect(HTTP_URL_BASE . $url);
                        }
                    }
                }

                if (isset($details['template'])) {
                    $app = App::getInstance();
                    $app->template->render($details['template']);
                    $path_found = true;
                    break;
                }
                if (!$this->controller || isset($details['controller'])) {
                    $this->controller = $details['controller'].'Controller';
                    if (class_exists($this->controller)) {
                        $this->controller_instance = new $this->controller;
                    } else {
                        throw new ClassException($this->controller);
                    }
                }
                if (!isset($details['action'])) {
                    $details['action'] = 'Index';
                }
                $action = $details['action'];
                if (!method_exists($this->controller_instance, $action)) {
                    throw new ActionException($this->controller.' -> '.$action);
                }
                if (isset($details['params'])) {
                    $params = array_merge((array)$params, $details['params']);
                }
                $this->params = $params;
                $this->controller_instance->$action($params);
                $path_found = true;
                break;
            }
        }
        if (!$path_found)
            throw new NotFoundException($this->request_uri);
    }

    public function getParams() {
        return $this->params;
    }

    public function getParsedRoute() {
        return $this->parsed_route;
    }

    public function getController() {
        return $this->controller;
    }

    public function getControllerInstance() {
        return $this->controller_instance;
    }

    public function getViableRoutes() {
        return $this->viable_routes;
    }

    private function matchRoute($pattern) {
        if (strpos($pattern, '(') === false) {
            if ($pattern == $this->request_uri) {
                return true;
            } elseif ($pattern.'/' == $this->request_uri) {
                return true;
            } elseif ($pattern == $this->request_uri.$this->home) {
                return true;
            } elseif (strpos($this->request_uri, $pattern.'/') === 0) {
                return true;
            }
        } else {
            $regex = '{^'.$pattern.'(/.*)?$}';
            if (isset($details['action']))
                $regex = '{^'.$pattern.'(/)?$}';
            $matched = preg_match($regex, $this->request_uri, $params);
            if ($matched)
                return $params;
        }
    }

    private function setParsedRoute($route) {
        $this->parsed_route = $route;
        $this->parsed_route_array = explode('/', $route);
        return $this;
    }

    private function addSustitutes($pattern) {
        $valid_route_match = 'a-z0-9\-';
        if (strpos($pattern, ':') === false)
            return $pattern;
        return preg_replace('/:([a-z0-9]+)/', '(?P<$1>['.$valid_route_match.']+)', $pattern);
    }

    public static function generateURL($name, $keys = array(), $values = array(), $full = false) {
        static $viable_routes;
        if (!$viable_routes) {
            $app = App::getInstance();
            $viable_routes = $app->router->getViableRoutes();
        }
        if (isset($viable_routes[$name])) {
            $url = $viable_routes[$name];
            if (strpos($url, ":") !== false) {
                return ($full?HTTP_URL_BASE:URL_BASE) . substr(str_replace($keys, $values, $url), 1);
            } else
                return ($full?HTTP_URL_BASE:URL_BASE) . substr($url, 1);
        } else {
            return ($full?HTTP_URL_BASE:URL_BASE);
        }
    }

}
