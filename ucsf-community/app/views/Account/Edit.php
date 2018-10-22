<?php $this->loadModule('Header'); ?>

<div class="createaccount editaccount main">
    
    <form method="post" class="edit-account-form">
        <div class="container container--no-bottom-padding">
            <a href="<?php echo $back_button_link; ?>" class="backbutton"></a>
            <h2 class="title">Edit Community Settings</h2>

            <h4 class="title title--dark">Screen Name</h4>
            <input type="text" name="screen_name" placeholder="Screen Name" class="qtiptop input__table" value="<?php echo $details->getScreenName(); ?>" id="screen_name">
            
            <h4 class="title title--dark">Community Email Notifications</h4>
        </div>

        <?php $this->loadModule('Notifications'); ?>

        <div class="container">
            <input type="submit" name="submit" class="button button--orange button--topmarg" value="Submit">
        </div>
    </form>
</div>

<?php $this->loadModule('Footer'); ?>
