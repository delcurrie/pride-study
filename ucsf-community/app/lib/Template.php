<?php
/**
 * @author    Analog Republic
 * @version   1.0
 * @copyright Copyright (c) 2014, Pride Study
 **/

class Template {

    private $vars = array();
    private $module_vars = array();

    private $ignored_modules = array();

    public function __construct() {

        $this->set('required_js', array());
        $this->set('required_css', array());

        $this->set('validator_revalidate', false);
        $this->set('validator_errors', array());

        $app = App::getInstance();
        $this->set('current_url', $app->router->getURI());
        $this->set('url_parts', $app->router->getURIParts());

    }

    /**
     * Render the template
     *
     * @param string $template Template filename including file extension
     * @param Array $vars  Variables which can be passed to the view
     * @throws TemplateException If the template could not be found
     * @return void
     **/
    public function render($template, $vars = array()) {
        $this->vars = array_merge($vars, $this->vars);
        extract($this->vars);
        $template_require = @include(DIR_APP_VIEWS . $template);
        if (!$template_require) {
            throw new TemplateException($template);
        }
    }

    /**
     * Set a variable for use within the template
     *
     * @param string $index Name of the variable to be used within the template
     * @param mixed $value
     * @return Template
     **/
    public function set($index, $value) {
        $this->vars[$index] = $value;
        return $this;
    }

    /**
     * @return array Array of all the template variables
     **/
    public function getVars() {
        return $this->vars;
    }

    /**
     * Add JS file URL to the template
     *
     * @param string $path Path/URL to the JS file
     * @param string $type Type of Path/URL
     * @return Template Template object
     **/
    public function addRequiredJS($path, $type = 'relative') {
        switch ($type) {
            case 'root':
                $path = URL_BASE.$path;
                break;

            case 'full':
                $path = $path;
                break;

            case 'relative':
            default:
                $path = URL_BASE.FOLDER_ASSETS.'/js/'.$path;
                break;
        }

        $this->vars['required_js'][] = $path;
        return $this;
    }

    public function getRequiredJS() {
        return $this->vars['required_js'];
    }

    /**
     * Add CSS file URL to the template
     *
     * @param string $path Path/URL to the CSS file
     * @param string $type Type of Path/URL
     * @return Template Template object
     **/
    public function addRequiredCSS($path, $type = 'relative') {
        switch ($type) {
            case 'root':
                $path = URL_BASE.$path;
                break;

            case 'full':
                $path = $path;
                break;

            case 'relative':
            default:
                $path = URL_BASE.FOLDER_ASSETS.'/css/'.$path;
                break;
        }

        $this->vars['required_css'][] = $path;
        return $this;
    }

    public function getRequiredCSS() {
        return $this->vars['required_css'];
    }

    /**
     * Add Fancybox JS/CSS to the template
     *
     * @return Template Template object
     **/
    public function addFancybox() {
        $this->addRequiredCSS('//cdnjs.cloudflare.com/ajax/libs/fancybox/2.1.5/jquery.fancybox.css', 'full');
        $this->addRequiredJS('//cdnjs.cloudflare.com/ajax/libs/fancybox/2.1.5/jquery.fancybox.pack.js', 'full');
        $this->addRequiredJS('//cdnjs.cloudflare.com/ajax/libs/fancybox/2.1.5/helpers/jquery.fancybox-media.js', 'full');
        return $this;
    }

    /**
     * Add the slick slider basic libraries
     */
    public function addSlick() {
        $this->addRequiredCSS('slick.css');
        $this->addRequiredJS('vendor/slick.min.js');
        return $this;
    }

    /**
     * Add Validation JS/CSS to the template
     *
     * @return Template Template object
     **/
    public function addValidation() {
        $this->addRequiredCSS('//cdnjs.cloudflare.com/ajax/libs/qtip2/2.1.1/jquery.qtip.min.css', 'full');
        $this->addRequiredJS('//ajax.aspnetcdn.com/ajax/jquery.validate/1.11.1/jquery.validate.js', 'full');
        $this->addRequiredJS('//ajax.aspnetcdn.com/ajax/jquery.validate/1.11.1/additional-methods.min.js', 'full');
        $this->addRequiredJS('//cdnjs.cloudflare.com/ajax/libs/qtip2/2.1.1/jquery.qtip.min.js', 'full');
        return $this;
    }

    /**
     * Set a variable for a specific module
     *
     * @param string $module Name of the module for variable
     * @param string $index Name of the variable to be used in the module
     * @param mixed $value
     * @return Template
     **/
    public function setModuleVar($module, $index, $value) {
        if (!isset($this->module_vars[$module])) {
            $this->module_vars[$module] = array();
        }
        $this->module_vars[$module][$index] = $value;
        return $this;
    }

    /**
     * Load a module from within a Template
     *
     * @param string $module_basename Name of the module to load
     * @param mixed $varname,... Unlimited OPTIONAL number of additional variables to be passed to the template
     * @return void
     **/
    public function loadModule($module_basename) {
        $arguments = func_get_args();
        $module_name = $module_basename.'Module';
        $module_file = DIR_APP_MODULES.$module_name.'.php';
        if (class_exists($module_name)) {
            $module_require = true;
        } else {
            $module_require = include($module_file);
        }
        if ($module_require) {
            $module = new $module_name($this);
        } else {
            $module = new BaseModule($this);
            $module->setView($module_basename.'.php');
        }
        if (isset($this->module_vars[$module_basename])) {
            foreach ($this->module_vars[$module_basename] as $key => $value) {
                $module->{$key} = $value;
            }
        }

        if (ENABLE_MODULE_CACHE === true && $module->isCacheable()) {
            $cache_time = $module->getCacheTime();
            $cache_key = $module->getCacheKey($arguments);

            $cache_file = DIR_APP_CACHE . 'module.' . $cache_key . '.html';
            $cache_file_time = @filemtime($cache_file);
            if (!$cache_file_time || $_SERVER['REQUEST_TIME'] > ($cache_time + $cache_file_time)) {
                ob_start();
                $this->renderModule($module, $arguments);
                if (SITE_ENVIRONMENT == 'dev')
                    echo "<!-- ".$cache_key." :: Cached at ".date('m/d/Y H:i')." :: Expires at ".date('m/d/Y H:i', $_SERVER['REQUEST_TIME'] + $cache_time)." -->\n";
                $fp = fopen($cache_file, 'w');
                fwrite($fp, ob_get_contents());
                fclose($fp);
                ob_end_flush();
            } else {
                if ($module->getAlwaysProcess()) {
                    $module->setRendering(false);
                    $this->renderModule($module, $arguments);
                }
                include($cache_file);
            }
        } else {
            $module->setRendering(true);
            $this->renderModule($module, $arguments);
        }
        return $this;
    }

    private function renderModule($module, $arguments) {
        array_shift($arguments);
        call_user_func_array(array($module, 'process'), $arguments);
    }

}
