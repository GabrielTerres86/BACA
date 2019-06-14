<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

// define caminho absoluto e relativo para arquivo cookie
$pasta_cookies = 'cookies_cnpj/';
define('COOKIELOCAL', str_replace('\\', '/', realpath('./')).'/'.$pasta_cookies);
define('HTTPCOOKIELOCAL', 'http://'.$_SERVER['SERVER_NAME'].str_replace(pathinfo($_SERVER['SCRIPT_FILENAME'],PATHINFO_BASENAME),'',$_SERVER['SCRIPT_NAME']).$pasta_cookies);

// inicia sessão
@session_start();

// função para pegar o que interessa
function pega_o_que_interessa($inicio,$fim,$total)
{
	$interesse = str_replace($inicio,'',str_replace(strstr(strstr($total,$inicio),$fim),'',strstr($total,$inicio)));
	return($interesse);
}

// função para pegar a resposta html da consulta pelo CPF na página da receita
function getHtmlCPF($cnpj,$data, $captcha)
{
    $cookieFile = COOKIELOCAL.session_id();
	$cookieFile_fopen = HTTPCOOKIELOCAL.session_id();
    if(!file_exists($cookieFile))
    {
        return false;      
    }
	else
	{
		// pega os dados de sessão gerados na visualização do captcha dentro do cookie
		$conteudo = '';
		$file = fopen($cookieFile_fopen, 'r');
		while (!feof($file))
		{$conteudo .= fread($file, 1024);}
		fclose ($file);

		$explodir = explode(chr(9),$conteudo);
		
		$sessionName = trim($explodir[count($explodir)-2]);
		$sessionId = trim($explodir[count($explodir)-1]);
		
		// constroe o parâmetro de sessão que será passado no próximo curl
		$cookie = $sessionName.'='.$sessionId.';flag=1';	
	}
	
	// dados que serão submetidos a consulta por post
    $post = array
    (
		'tempTxtNascimento'						=> $data,
		'tempTxtCPF' 							=> $cnpj, 
		'txtTexto_captcha_serpro_gov_br'		=> $captcha,
		'temptxtTexto_captcha_serpro_gov_br'	=> $captcha,
		'temptxtToken_captcha_serpro_gov_br'	=> ''
		
    );

	$post = http_build_query($post, NULL, '&');

    $ch = curl_init('https://www.receita.fazenda.gov.br/Aplicacoes/SSL/ATCTA/CPF/ConsultaPublicaExibir.asp');
	//$proxy = 'proxy.cecred.coop.br:3128';
	//curl_setopt($ch, CURLOPT_PROXY, $proxy);
	//curl_setopt($ch, CURLOPT_HTTPPROXYTUNNEL, 0);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $post);		// aqui estão os campos de formulário
    curl_setopt($ch, CURLOPT_COOKIEFILE, $cookieFile);	// dados do arquivo de cookie
    curl_setopt($ch, CURLOPT_COOKIEJAR, $cookieFile);	// dados do arquivo de cookie
    curl_setopt($ch, CURLOPT_USERAGENT, 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:8.0) Gecko/20100101 Firefox/8.0');
    curl_setopt($ch, CURLOPT_COOKIE, $cookie);	    // dados de sessão e flag=1
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
    curl_setopt($ch, CURLOPT_MAXREDIRS, 3);
	curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    //curl_setopt($ch, CURLOPT_REFERER, 'http://www.receita.fazenda.gov.br/pessoajuridica/cnpj/cnpjreva/Cnpjreva_Solicitacao2.asp');
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $html = curl_exec($ch);
    curl_close($ch);
    //exclui arquivo
    unlink($cookieFile);
    return $html;
}

// Função para extrair o que interessa da HTML e colocar em array
function parseHtmlCPF($html)
{
	// respostas que interessam
	$campos = array(
		' do CPF: ',
		'Nome da Pessoa Física: ',
		'Situação Cadastral: ',
		'Data de Nascimento: ',
		'Data da Inscrição: ');

	// caracteres que devem ser eliminados da resposta
	$caract_especiais = array(
	chr(9),
	chr(10),
	chr(13),
	'&nbsp;',
	'</b>',
	'  ',
	'<b>MATRIZ<br>',
	'<b>FILIAL<br>'
	 );

	// prepara a resposta para extrair os dados
	//$html = str_replace('<br><b>','<b>',str_replace($caract_especiais,'',strip_tags($html,'<b><br>')));
	
	$html3 = $html;

	// faz a extração
	for($i=0;$i<count($campos);$i++)
	{		
		$html2 = strstr($html,utf8_decode($campos[$i]));
		$resultado[] = trim(pega_o_que_interessa(utf8_decode($campos[$i]).'<b>','</b></span>',$html2));
		$html=$html2;
	}

	// extrai os CNAEs secundarios , quando forem mais de um
	if(strstr($resultado[4],'<b>'))
	{
		$cnae_secundarios = explode('<b>',$resultado[5]);
		$resultado[5] = $cnae_secundarios;
		unset($cnae_secundarios);
	}

	// devolve STATUS da consulta correto
	if(!$resultado[0])
	{
		if(strstr($html3,utf8_decode('O número do CNPJ não é válido')))
		{$resultado['status'] = 'CNPJ incorreto ou não existe';}
		else
		{$resultado['status'] = 'Imagem digitada incorretamente';}
	}
	else
	{$resultado['status'] = 'OK';}
	
	return $resultado;
}
?>