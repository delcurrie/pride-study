<?php

class HeaderModule extends BaseModule
{

    public $user = false, $preview_mode = true, $body_classes = '';

    protected $view = 'Header.php';

    public function process()
    {
        global $cart;
        $this->cart = $cart;

        if (!$this->meta) {
            $this->meta = new Meta;
        }

        $this->user = App::getLoggedInUser();
        if ($this->user) {
            $this->preview_mode = !$this->user->hasScreenName();
        }

        $this->render();
    }
}
