<?php
/**
 * @author    Analog Republic
 * @version   1.0
 * @copyright Copyright (c) 2014, Pride Study
 **/

class BaseModule {

    protected $template;
    protected $rendering = true;
    protected $always_process = false;

    protected $vars = array();

    public function __construct(Template $template = null) {
        $this->template = $template;
    }

    public function render() {
        extract($this->template->getVars()); extract($this->vars);
        $template_require = @include(DIR_APP_VIEWS . $this->getView());
        if (!$template_require) {
            throw new ModuleViewException($this->getView());
        }
    }

    public function setRendering($rendering) {
        $this->rendering = (bool)$rendering;
        return $this;
    }

    public function getAlwaysProcess() {
        return $this->always_process;
    }

    public function getView() {
        return 'modules' . DS .$this->view;
    }

    public function setView($view) {
        $this->view = $view;
    }

    public function __set($index, $value) {
        $this->vars[$index] = $value;
    }

    public function __get($index) {
        return $this->vars[$index];
    }

    public function __isset($index) {
        return isset($this->vars[$index]);
    }

    public function process() {
        $this->render();
    }

    public function loadModule() {
        $arguments = func_get_args();
        call_user_func_array(array($this->template, 'loadModule'), $arguments);
    }

    public function outputRequiredCSS() {
        foreach ($this->template->getRequiredCSS() as $rc) {
?>
        <link rel="stylesheet" href="<?php echo $rc ?>">
<?php
        }
    }

    public function outputRequiredJS() {
        foreach ($this->template->getRequiredJS() as $rj) {
?>
        <script src="<?php echo $rj; ?>"></script>
<?php
        }
    }

    public function isCacheable() {
        return false;
    }

    public function getCacheKey() {
        return $this->view;
    }

    public function getCacheTime() {
        return 3600;
    }
}
