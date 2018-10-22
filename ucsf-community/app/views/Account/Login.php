<?php $this->loadModule('Header'); ?>

<div class="createaccount main">

<?php $this->loadModule('Navigation'); ?>
    
    <div class="container">
        <a href="<?php echo $back_button_link; ?>" class="backbutton"></a>
        <h4 class="title">Login</h4>

        <form method="post" class="login-form">
            <input type="text" name="username" placeholder="Username" class="qtiptop">
            <input type="password" name="password" placeholder="Password" class="qtiptop">
            <input type="submit" name="submit" class="button button--orange button--topmarg" value="Login">
            <div class="signin signin--orange"><p>Need an account? <a href="<?php echo URL_BASE.'account/create'; ?>">Sign up here</a>.</p></div>
        </form>

    </div>
</div>

<?php $this->loadModule('Footer'); ?>
