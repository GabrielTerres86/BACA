<?php
/*!
 * FONTE        : consulta_rfb.js
 * CRIAÇÃO      : Gabriel (RKAM)
 * DATA CRIAÇÃO : 04/09/2015 
 * OBJETIVO     : Obter imagem para o captcha
 *
 * ALTERACOES   :
 */
?>
<?	 
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../config.php");
	require_once("../funcoes.php");	

	// define caminho absoluto e relativo para arquivo cookie
	$pasta_cookies = 'cookies_rf/';
	define('COOKIELOCAL', str_replace('\\', '/', realpath('./')).'/'.$pasta_cookies);
	define('HTTPCOOKIELOCAL', 'http://'.$_SERVER['SERVER_NAME'].str_replace(pathinfo($_SERVER['SCRIPT_FILENAME'],PATHINFO_BASENAME),'',$_SERVER['SCRIPT_NAME']).$pasta_cookies);
	 
	// inicia sessão
	@session_start();
	$cookieFile_fopen = HTTPCOOKIELOCAL.session_id();        
	$cookieFile = COOKIELOCAL.session_id();

	// cria arquivo onde será salva a sessão com a receita, caso ele não exista
	if(!file_exists($cookieFile))
	{
		$file = fopen($cookieFile, 'w');
		fclose($file);
	}

	// faz a chamada para a receita que exibe o captcha
	$tipoConsulta = $_GET['tipoConsulta'];
	$url = null;
	if ($tipoConsulta == 'CPF')
		$url = 'http://www.receita.fazenda.gov.br/Aplicacoes/ATCTA/CPF/captcha/gerarCaptcha.asp';
	else
		$url = 'http://www.receita.fazenda.gov.br/pessoajuridica/cnpj/cnpjreva/captcha/gerarCaptcha.asp';

	$ch = curl_init($url);
	curl_setopt($ch, CURLOPT_COOKIEJAR, $cookieFile);   // salva os dados de sessão
	curl_setopt($ch, CURLOPT_COOKIEFILE, $cookieFile);  // atualiza os dados de sessão se estiverem desatualizados
	curl_setopt($ch, CURLOPT_USERAGENT, 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:8.0) Gecko/20100101 Firefox/8.0');
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
	$imgsource = curl_exec($ch);
	curl_close($ch);
	 
	// se tiver imagem , mostra
	if(!empty($imgsource)) {
		$img = imagecreatefromstring($imgsource);
		header('Content-type: image/jpg');
		imagejpeg($img);
	} 
	?>