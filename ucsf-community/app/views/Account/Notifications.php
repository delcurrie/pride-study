<?php $this->loadModule('Header'); ?>

<div class="createaccount main">
    
    <form method="post" class="set-email-notifications-form">
	    <div class="container">
	        <a href="<?php echo URL_BASE; ?>" class="backbutton"></a>
	        <h4 class="title">Configure Your Notification Settings</h4>

	        <p>Select instances in which you would like to receive email notifications. </p>
		</div>
        <?php $this->loadModule('Notifications'); ?>
        <div class="container">
	        <input type="submit" name="submit" class="button button--orange button--topmarg" value="Submit">
    	</div>
   	</form>
</div>

<?php $this->loadModule('Footer'); ?>
