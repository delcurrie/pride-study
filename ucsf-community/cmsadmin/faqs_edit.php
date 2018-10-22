<?php
include_once('includes/application_top.php');

// We're adding if it doesn't exist
$mode = 'add';
if (!empty($_GET['id'])) {
	$faq = $db->query('select * from faqs where id = ' . (int)$_GET['id'] . ' limit 1')->fetch(PDO::FETCH_ASSOC);

	// Otherwise we're editing
	if($faq) {
		$mode = 'edit';
	}
}

// Prepare some Ajax return data format
$return_data = array(
	'errors' 	 => array(),
	'revalidate' => false
);

// If we're post-ing
if(!empty($_POST)) {

	// Keys we need
	$keys = array(
		'question',
		'answer',
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
			'question' => $_POST['question'],
			'answer' => $_POST['answer'],
			'active' => (int)$_POST['active']
		);

		// Depending on which mode; we'll use different
		// code to handle DB query.
		if($mode == 'add') {
            $db->perform("faqs", $data);
            $id = $db->lastInsertId();
            $db->query('update faqs set sort_order = '.(int)$id.' where id = '.(int)$id.' limit 1');
        } else {
            $db->perform("faqs", $data, "update", "id = ".(int)$faq['id']." limit 1");
            $id = $faq['id'];
        }

        // Redirect back to this faq
		$return_data['redirect'] = 'faqs.php';
    }

    // Return the json for the AJAX request
    echo json_encode($return_data);
    die();
}

// -------------------------------------------------------------------------- //

// Now handle the front-end
addValidation();
addAutoSize();
$required_js[] = 'pages/faqs_edit.js';

include("includes/header.php");
?>

<div class="row" id="content-wrapper">
	<div class="col-xs-12">
	<?php
		drawHeaderRow(array(
			array(
				'name' => 'Frequently Asked Questions',
				'icon' => 'icon-question',
				'url'  => 'faqs_edit.php'
			),
			array(
				'name' => ucfirst($mode) . ' Frequently Asked Questions',
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
								<?php echo ucfirst($mode); ?> Frequently Asked Questions
						</div>
					</div>
					<div class="box-content box-no-padding">
						<form class="form form-horizontal form-striped" action="#" method="get">
							<?php
								drawAutosizeTextArea('question', 'Question', $faq);
								drawAutosizeTextArea('answer', 'Answer', $faq);
								drawSelect('active', array(
								    'No', 'Yes'
								), 'Active', $faq);
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