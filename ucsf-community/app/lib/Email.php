<?php
/**
 * @author    Chris Neal
 * @version   1.1
 * @copyright Copyright (c) 2014, Analog Republic
 **/

class Email {

    private $email_id;

    private $smtp_username = '';
    private $smtp_password = '';
    private $smtp_server = 'localhost';
    private $smtp_port = 25;

    private $method = 'sendgrid';

    private $to_name;
    private $to_email;
    private $from_name;
    private $from_email;

    private $subject;

    private $attachments = array();

    private $is_html = true;
    private $is_text = true;

    private $template_name;
    private $template_html;
    private $template_text;

    private $processed_template_html;
    private $processed_template_text;

    private $replacements = array();

    private $category = 'Uncategorized';

    private $replacement_start = '%%';
    private $replacement_end = '%%';

    public function __construct() {
        $this->replacements['URL_IMAGES'] = HTTP_URL_BASE . FOLDER_ASSETS . '/' . FOLDER_IMG . '/';
        $this->replacements['URL_BASE'] = HTTP_URL_BASE;
    }

    public function setUsername($smtp_username) {
        $this->smtp_username = $smtp_username;
        return $this;
    }

    public function setPassword($smtp_password) {
        $this->smtp_password = $smtp_password;
        return $this;
    }

    public function setServer($smtp_server) {
        $this->smtp_server = $smtp_server;
        return $this;
    }

    public function setPort($smtp_port) {
        $this->smtp_port = $smtp_port;
        return $this;
    }

    public function setToName($to_name) {
        $this->to_name = $to_name;
        $this->replacements['TO_NAME'] = $this->to_name;
        return $this;
    }

    public function setToEmail($to_email) {
        if (filter_var($to_email, FILTER_VALIDATE_EMAIL)) {
            $this->to_email = $to_email;
            $this->replacements['TO_EMAIL'] = $this->to_email;
        } else {
            throw new Exception("Invalid To email address");
        }
        return $this;
    }

    public function setFromName($from_name) {
        $this->from_name = $from_name;
        $this->replacements['FROM_NAME'] = $this->from_name;
        return $this;
    }

    public function setFromEmail($from_email) {
        if (filter_var($from_email, FILTER_VALIDATE_EMAIL)) {
            $this->from_email = $from_email;
            $this->replacements['FROM_EMAIL'] = $this->from_email;
        } else {
            throw new Exception("Invalid From email address");
        }
        return $this;
    }

    public function setTemplate($template) {
        if ($this->is_html) {
            $html_template = DIR_APP_VIEWS . 'emails/'.$template.'.html';
            if (file_exists($html_template)) {
                $this->template_html = file_get_contents($html_template);
            } else {
                throw new Exception("HTML template doesn't exists - ".$html_template);
            }
        }
        if ($this->is_text) {
            $text_template = DIR_APP_VIEWS . 'emails/'.$template.'.txt';
            if (file_exists($text_template)) {
                $this->template_text = file_get_contents($text_template);
            } else {
                throw new Exception("Text template doesn't exists - ".$text_template);
            }
        }
        $this->template_name = $template;
        return $this;
    }

    public function setCategory($category) {
        $this->category = $category;
        return $this;
    }

    public function setSubject($subject) {
        $this->subject = $subject;
        return $this;
    }

    public function setIsHTML($is_html) {
        $this->is_html = (bool)$is_html;
        return $this;
    }

    public function setIsText($is_text) {
        $this->is_text = (bool)$is_text;
        return $this;
    }

    public function setReplacements($replacements) {
        if (is_array($replacements)) {
            $this->replacements = array_merge($this->replacements, $replacements);
        } else {
            throw new Exception("Replacements must be array");
        }
        return $this;
    }

    public function setEmailId($email_id) {
        $this->email_id = $email_id;
        return $this;
    }

    public function getEmailId() {
        return $this->email_id;
    }

    public function addReplacement($key, $value) {
        $this->replacements[$key] = $value;
        return $this;
    }

    public function removeReplacement($key) {
        unset($this->replacements[$key]);
        return $this;
    }

    public function addAttachment($path, $custom_name = false) {
        $name = basename($path);
        $hash = md5($name);
        if (!isset($this->attachments[$hash])) {
            $this->attachments[$hash] = pathinfo($path);
            $this->attachments[$hash]['full_path'] = $path;
            if (!$custom_name) {
                $custom_name = $this->attachments[$hash]['filename'] . '.' . $this->attachments[$hash]['extension'];
            }
            $this->attachments[$hash]['custom_name'] = $custom_name;
        }
        return $this;
    }

    private function makeReplacements() {
        $this->processed_template_html = $this->template_html;
        $this->processed_template_text = $this->template_text;

        foreach ($this->replacements as $key => $value) {
            if ($this->is_html) {
                $this->processed_template_html = str_replace($this->replacement_start.$key.$this->replacement_end, $value, $this->processed_template_html);
            }
            if ($this->is_text) {
                $this->processed_template_text = str_replace($this->replacement_start.$key.$this->replacement_end, $value, $this->processed_template_text);
            }
        }

        $this->processed_template_html = preg_replace('/('.preg_quote($this->replacement_start).'([^'.preg_quote($this->replacement_end).']+)'.preg_quote($this->replacement_end).')/', '[Replacement for $1 not found]', $this->processed_template_html);
    }

    public function preview() {
        $this->makeReplacements();
        if ($this->is_html) {
            return $this->processed_template_html;
        } else {
            return '<pre>'.$this->processed_template_text.'</pre>';
        }
    }

    public function send() {
        switch ($this->method) {
            case 'smtp':
                $this->send_SMTP();
                break;

            case 'swift_mail':
                $this->send_SwiftMail();
                break;

            case 'sendgrid':
                $this->send_SendGrid();
                break;

            default:
                $this->send_Mail();
                break;
        }
    }

    private function send_SendGrid() {

        $this->makeReplacements();

        // loadLib('vendor' . DS . 'sendgrid-php-3.2.0' . DS . 'lib' . DS . 'SendGrid');

        // $sendgrid = new SendGrid(SENDGRID_USERNAME, SENDGRID_PASSWORD);
        // $email = new SendGrid\Email();
        // $email
        //     ->addTo($this->to_email, $this->to_name)
        //     ->setFrom($this->from_email, $this->from_name)
        //     ->setSubject($this->subject)
        //     ->setText($this->processed_template_text)
        //     ->setHtml($this->processed_template_html)
        // ;

        // if (count($this->attachments) > 0) {
        //     foreach ($this->attachments as $attachment_hash => $attachment) {
        //         $email->addAttachment($attachment['full_path'], $attachment['custom_name']);
        //     }
        // }

        // $response = $sendgrid->send($email);
        // if ($response->getCode() == 200) {
        //     return true;
        // } else {
        //     throw new Exception("Send failed");
        // }

        $params = array(
            'api_user' => SENDGRID_USERNAME,
            'api_key'  => SENDGRID_PASSWORD,
            'to'       => $this->to_email,
            'toname'   => $this->to_name,
            'from'     => $this->from_email,
            'fromname' => $this->from_name,
            'subject'  => $this->subject,
        );

        if (count($this->attachments) > 0) {
            foreach ($this->attachments as $attachment_hash => $attachment) {
                $params['files'][$attachment['custom_name']] = '@' . $attachment['full_path'];
            }
        }

        if ($this->is_html)
            $params['html'] = $this->processed_template_html;

        if ($this->is_text)
            $params['text'] = $this->processed_template_text;

        $request =  'https://api.sendgrid.com/api/mail.send.json';
        $session = curl_init($request);
        curl_setopt($session, CURLOPT_POST, true);
        curl_setopt($session, CURLOPT_POSTFIELDS, $params);
        curl_setopt($session, CURLOPT_HEADER, false);
        curl_setopt($session, CURLOPT_RETURNTRANSFER, true);
        $response = curl_exec($session);
        curl_close($session);

        $json = json_decode($response, true);

        if ($json['message'] == "success") {
            return true;
        } else {
            throw new Exception("Send failed");
        }

    }

    private function send_Mail() {
        $this->makeReplacements();
        $random_hash = md5(date('r', time()));
        $headers = "From: ".$this->from_name." <".$this->from_email.">\r\n";
        $message = '';
        if ($this->is_text && $this->is_html) {
            $headers .= "Content-Type: multipart/alternative; boundary=\"PHP-alt-".$random_hash."\"";
            $message .= '--PHP-alt-'.$random_hash."\r\n".
                        'Content-Type: text/html; charset=utf-8'."\r\n".
                        $this->processed_template_text."\r\n".
                        '--PHP-alt-'.$random_hash."\r\n".
                        'Content-Type: text/html; charset=utf-8'."\r\n".
                        $this->processed_template_html."\r\n".
                        "--PHP-alt-".$random_hash."--\n";
        } elseif ($this->is_text) {
            $headers .= 'Content-type: text/plain; charset=utf-8' . "\r\n";
            $message .= $this->processed_template_text;
        } elseif ($this->is_html) {
            $headers .= 'Content-type: text/html; charset=utf-8' . "\r\n";
            $message .= $this->processed_template_html;
        }

        $sent = @mail($this->to_name." <".$this->to_email.">", $this->subject, $message, $headers);
        if ($sent) {
            return true;
        } else {
            throw new Exception("Send failed");
        }

    }

    private function send_SwiftMail() {

        loadLib('vendor/swift/swift_required');

        $this->makeReplacements();

        $transport = Swift_MailTransport::newInstance();
        $swift = Swift_Mailer::newInstance($transport);
        $message = new Swift_Message($this->subject);

        $message->setFrom(array($this->from_email => $this->from_name));
        if ($this->is_html)
            $message->setBody($this->processed_template_html, 'text/html');

        if ($this->is_text && !$this->is_html) {
            $message->setBody($this->processed_template_text, 'text/plain');
        } elseif ($this->is_text && $this->is_html) {
            $message->addPart($this->processed_template_text, 'text/plain');
        }

        $message->setTo(array($this->to_email => $this->to_name));

        if ($recipients = $swift->send($message, $failures)) {
            return true;
        } else {
            throw new Exception("Send failed");
        }

    }

    private function send_SMTP() {

        loadLib('vendor/swift/swift_required');

        $this->makeReplacements();

        $transport = Swift_SmtpTransport::newInstance($this->smtp_server, $this->smtp_port);
        $transport ->setUsername($this->smtp_username);
        $transport ->setPassword($this->smtp_password);
        $swift = Swift_Mailer::newInstance($transport);

        $message = new Swift_Message($this->subject);

        $headers = $message->getHeaders();
        $message->setFrom(array($this->from_email => $this->from_name));
        if ($this->is_html)
            $message->setBody($this->processed_template_html, 'text/html');

        if ($this->is_text && !$this->is_html) {
            $message->setBody($this->processed_template_text, 'text/plain');
        } elseif ($this->is_text && $this->is_html) {
            $message->addPart($this->processed_template_text, 'text/plain');
        }

        $message->setTo(array($this->to_email => $this->to_name));

        if ($recipients = $swift->send($message, $failures)) {
            return true;
        } else {
            throw new Exception("Send failed");
        }

    }
}