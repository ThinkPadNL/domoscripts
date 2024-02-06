<?php
//This is a version that grabs snapshot from RTSP-stream. 
//It needs permissions to run 'avconv' and also needs rights to write the snapshot to the configured folder.

require_once('class.phpmailer.php');
require_once('class.smtp.php');

define('GUSER', 'YOUR@ADDRESS>COM'); // GMail username
define('GPWD', 'YOURPASSWORD'); // GMail password

function take_snapshot() {
echo shell_exec("sudo /usr/bin/avconv -rtsp_transport tcp -i 'rtsp://192.168.4.7/user=admin&password=&channel=1&stream=0.sdp' -f image2 -vframes 1 -pix_fmt yuvj420p /var/www/html/deurbel/snapshot.jpeg >/tmp/debug.log 2>&1");
}

function smtpmailer($to, $from, $from_name, $subject, $body, $attachment) { 
	global $error;
	$mail = new PHPMailer();  // create a new object
	$mail->IsSMTP(); // enable SMTP
	$mail->SMTPDebug = 0;  // debugging: 1 = errors and messages, 2 = messages only
	$mail->SMTPAuth = true;  // authentication enabled
	$mail->SMTPSecure = 'ssl'; // secure transfer enabled REQUIRED for GMail
	$mail->Host = 'smtp.gmail.com';
	$mail->Port = 465; 
	$mail->Username = GUSER;  
	$mail->Password = GPWD;           
	$mail->SetFrom($from, $from_name);
	$mail->Subject = $subject;
	$mail->Body = $body;
	$mail->AddAddress($to);
	$mail->AddCC('your@address.com', 'Your Name');
	$mail->addAttachment($attachment, '/var/www/html/deurbel/snapshot.jpeg');
	if(!$mail->Send()) {
		$error = 'Mail error: '.$mail->ErrorInfo; 
		echo $error;
	} else {
		$error = 'Message sent!';
		echo $error;
	}
} 

take_snapshot();

smtpmailer(GUSER, GUSER, 'Deurbel', 'Deurbel', 'Er is zojuist aangebeld op de galerij, zie de bijlage voor de foto.', '/var/www/html/deurbel/snapshot.jpeg');

?>
