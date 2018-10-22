<?php
include_once('includes/application_top.php');

// We're adding if it doesn't exist
$mode = 'add';
if (!empty($_GET['id'])) {
	$slide = $db->query('select * from slides where id = ' . (int)$_GET['id'] . ' limit 1')->fetch(PDO::FETCH_ASSOC);

	// Otherwise we're editing
	if($slide) {
		$mode = 'edit';
	}
}

uploadImage('image', 'SlideModel', array(
    array(
        'width' => 1000,
        'height' => 1000,
        'crop' => false,
        'folder' => 'slides'
    )
));

// Prepare some Ajax return data format
$return_data = array(
	'errors' 	 => array(),
	'revalidate' => false
);

// If we're post-ing
if(!empty($_POST)) {

	// Keys we need
	$keys = array(
		'image_file',
		'text',
		'active'
	);

	// Walk the array and check each of our
	// required fields aren't empty
	array_walk($_POST, function($item, $key) use($keys) {
		if(in_array($key, $keys)) {

			if(!isset($item) || empty($item)) {
				$return_data['revalidate'] = true;
				$return_data['errors'][$key] = 'This field must be present';
			}

		}
	});

	// If we're okay, then we can continue
	if(empty($return_data['errors']) && empty($return_data['revalidate'])) {

		// format data for update/insert
		$data = array(
			'image'  => $_POST['image_file'],
			'text'   => $_POST['text'],
			'active' => (int)$_POST['active']
		);

		// Depending on which mode; we'll use different
		// code to handle DB query.
		if($mode == 'add') {
            $db->perform("slides", $data);
            $id = $db->lastInsertId();
            $db->query('update slides set sort_order = '.(int)$id.' where id = '.(int)$id.' limit 1');
        } else {
            $db->perform("slides", $data, "update", "id = ".(int)$slide['id']." limit 1");
            $id = $slide['id'];
        }

        // Redirect back to this faq
		$return_data['redirect'] = 'sliders.php';
    }

    // Return the json for the AJAX request
    echo json_encode($return_data);
    die();
}

// -------------------------------------------------------------------------- //

// Now handle the front-end
addValidation();
addAutoSize();
addUploadify();
$required_js[] = 'pages/sliders_edit.js';

include("includes/header.php");
?>

<div class="row" id="content-wrapper">
	<div class="col-xs-12">
	<?php
		drawHeaderRow(array(
			array(
				'name' => 'Welcome Slides',
				'icon' => 'icon-pciture-o',
				'url'  => 'sliders_edit.php'
			),
			array(
				'name' => ucfirst($mode) . ' Welcome Slides',
				'icon' => 'icon-edit',
			),
		));
	?>
		<div class="row">
			<div class="col-sm-12">
				<div class="box">
					<div class="box-header dark-grey-background">
						<div class="title">
							<div class="icon-edit"></div>
								<?php echo ucfirst($mode); ?> Welcome Slides
						</div>
					</div>
					<div class="box-content box-no-padding">
						<form class="form form-horizontal form-striped" action="#" method="get">
							<?php
								drawAutosizeTextArea('text', 'Text', $slide);
								drawImageUploadField('image', 'Slide Image', $slide, SlideModel::getImageFolder('slides'));
								drawSelect('active', array(
								    'No', 'Yes'
								), 'Active', $slide);
							?>
							<div class="form-actions" style="margin-bottom: 0;">
								<div class="row">
									<div class="col-md-9 col-md-offset-3">
										<button class="btn btn-primary btn-lg" type="submit">
											<i class="icon-save"></i>
											Save
										</button>
									</div>
								</div>
							</div>
						</form>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
<?php
	include("includes/footer.php");
	include("includes/application_bottom.php");
?>