<?php $this->loadModule('Header'); ?>

<div class="createtopic main">

<?php $this->loadModule('Navigation'); ?>
    
    <form method="post" class="create-topic-form">
        <div class="container container--no-top-padding">
            <a href="#" class="backbutton"></a>
            <h2 class="title title--margin-bottom title--orange">Create a Topic</h2>
            
            <h3 class="title title--input">I want to know about...</h3>
            <input type="text" name="title" placeholder="ex: Cancer Screening" class="input qtiptop">
            <h3 class="title title--input">Why?</h3>
            <textarea name="description" class="input input--textarea qtiptop" placeholder="ex: What cancer screenings are appropriate for me as a member of the LGBT community?"></textarea>
	    </div>
        
        <h3 class="title title--input title--no-margin">Categories</h3>
        <h4 class="title title--input-sub">Select all that apply</h4>
        
        <?php foreach($types as $type => $categories) : ?>
            <h4 class="checkbox-grid__title"><?php echo $type; ?></h4>
            <div class="checkbox-grid">
                <div class="container container--no-vertical-padding container--no-right-padding">
        			<?php foreach($categories as $category) : ?>
                        <div class="input__checkbox input__checkbox--small checkbox-grid__input">
                            <input type="checkbox" name="topic_categories[]" id="comments_on_my_posts[<?php echo $category->getId(); ?>]" value="<?php echo $category->getId(); ?>">
                            <label class="checkbox-grid__label" for="comments_on_my_posts[<?php echo $category->getId(); ?>]"><?php echo $category->getName(); ?><span></span></label>
                        </div>
        			<?php endforeach; ?>
                </div>
            </div>
        <?php endforeach; ?>

        <div class="container">
            <input type="submit" name="submit" class="button button--orange button--topmarg" value="Create Topic">
        </div>
    </form>
</div>

<?php $this->loadModule('Footer'); ?>