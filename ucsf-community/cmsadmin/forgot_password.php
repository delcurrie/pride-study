<?php
include("includes/application_top.php");

$return_data = array(
  'errors'     => array(),
  'revalidate' => false
);

if (!empty($_POST)) {
    if (empty($_POST['email'])) {
        $return_data['revalidate'] = true;
    } elseif (!filter_var($_POST['email'], FILTER_VALIDATE_EMAIL)) {
        $return_data['revalidate'] = true;
        $_POST['email'] = '';
    }
    if (empty($return_data['revalidate']) && empty($return_data['errors'])) {
        $valid_user = false;
        $admin_user = $db->query('SELECT * FROM `admin_users` WHERE `email` LIKE ' . $db->quote($_POST['email']) . ' AND `active` LIMIT 1')->fetch(PDO::FETCH_ASSOC);

        if ($admin_user) {
          $email = $admin_user['email'];
          $name = $admin_user['name'];
          $password = substr(str_shuffle(strtolower(sha1(rand() . time() . "5DWBZqkQzhJyE23avYCcdp4Dyq8sHetB"))),0, 10);
          $db->perform("admin_users", array('password' => md5($password)), "update", "id = " . (int)$admin_user['id'] . " limit 1");

          include_once('emails' . DIRECTORY_SEPARATOR . 'password_reset.php');
          $emailData = array(
              'from'    => 'UCSF Community',
              'to'      => $name . ' <' . $email . '>',
              'subject' => 'Forgotten Password',
              'html'    => $html
          );

          sendemail($emailData['to'], $emailData['subject'], $emailData['html']);

          $redirect = 'forgot_password_next.php';
          $return_data['redirect'] = $redirect;

        } else {
            $return_data['errors']['email'] = 'Account not found.';
        }
    }
    echo json_encode($return_data);
    die();

}

addValidation();
$required_js[] = 'pages/login.js';

define('BODY_CLASS', ' login ucsf-custom');
define("IS_LOGIN", true);
include("includes/header.php");
?>

    <div class="login-block">
      <div class="login-block__icon">

      </div>
      <h1 class="login-block__title">UCSF Community - Forgotten Password</h1>
      <p>Please enter your email to reset your password.</p><br>
      <form action="#" method="get">
        <div class="form-group">
          <div class="controls with-icon-over-input">
            <input value="" placeholder="E-mail" class="form-control" data-rule-required="true" name="email" type="text" />
            <i class="icon-user text-muted"></i>
          </div>
        </div>
        <button class="btn btn-block btn-login">Send Reset Email</button>
      </form>
      <a href="login.php" class="forgot-password">Log In</a>
    </div>
<?php
include("includes/footer.php");
include("includes/application_bottom.php");
?>
