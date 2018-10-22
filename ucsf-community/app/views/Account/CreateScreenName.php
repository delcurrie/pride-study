<?php $this->loadModule('Header'); ?>

<div class="createaccount main">
    
    <div class="container">
        <a href="<?php echo URL_BASE; ?>" class="backbutton"></a>
        <h4 class="title">Create Your Community Screen Name</h4>
    
        <p>You must create a screen name to participate in the community forum. This can be any name you choose and does not need to be the name you originally shared with The PRIDE Study.</p>

        <p>If you choose to use your real name, other community members will be able to associate your posts with that name.</p>

        <form method="post" class="create-screen-name-form">
            <input type="text" name="screen_name" placeholder="Screen Name" class="qtiptop">
            <label class="label__small label__small--center">Minimum 8 characters</label>
            <input type="submit" name="submit" class="button button--orange button--topmarg" value="Submit">
        </form>

    </div>
</div>

<?php $this->loadModule('Footer'); ?>
