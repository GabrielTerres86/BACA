<?php
/*!
 * FONTE        : funcoes.php
 * CRIAÇÃO      : Gabriel (RKAM)
 * DATA CRIAÇÃO : 04/09/2015 
 * OBJETIVO     : Funcoes da CONSULTA A RECEITA FEDERAL
 *
 * ALTERACOES   :
 */
?>
<? 
	// define caminho absoluto e relativo para arquivo cookie
	$pasta_cookies = 'cookies_rf/';

	define('COOKIELOCAL', str_replace('\\', '/', realpath('./')).'/'.$pasta_cookies);
	define('HTTPCOOKIELOCAL', 'http://'.$_SERVER['SERVER_NAME'].str_replace(pathinfo($_SERVER['SCRIPT_FILENAME'],PATHINFO_BASENAME),'',$_SERVER['SCRIPT_NAME']).$pasta_cookies);
	 
	// inicia sessão
	@session_start();
	 
	// função para pegar o que interessa
	function extraiValorForm($inicio,$fim,$total)
	{
		$interesse = str_replace($inicio,'',str_replace(strstr(strstr($total,$inicio),$fim),'',strstr($total,$inicio)));
		return($interesse);
	}

	function getHtmlReceita($post, $urlvalida, $urlreferer)
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
			$conteudo = null;
			$file = fopen($cookieFile, 'r');
			while (!feof($file))
			{$conteudo .= fread($file, 1024);}
			fclose ($file);
	 
			$explodir = explode(chr(9),$conteudo);
			 
			$sessionName = trim($explodir[count($explodir)-2]);
			$sessionId = trim($explodir[count($explodir)-1]);
			 
			// constroe o parâmetro de sessão que será passado no próximo curl
			$cookie = $sessionName.'='.$sessionId.';flag=1';    
		}
		
		$post = http_build_query($post, NULL, '&');
		
					
		$ch = curl_init($urlvalida);
		curl_setopt($ch, CURLOPT_POST, true);
		curl_setopt($ch, CURLOPT_POSTFIELDS, $post);        // aqui estão os campos de formulário
		curl_setopt($ch, CURLOPT_COOKIEFILE, $cookieFile);  // dados do arquivo de cookie
		curl_setopt($ch, CURLOPT_COOKIEJAR, $cookieFile);   // dados do arquivo de cookie
		curl_setopt($ch, CURLOPT_USERAGENT, 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:8.0) Gecko/20100101 Firefox/8.0');
		curl_setopt($ch, CURLOPT_COOKIE, $cookie);      // dados de sessão e flag=1
		curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
		curl_setopt($ch, CURLOPT_MAXREDIRS, 3);
		curl_setopt($ch, CURLOPT_REFERER, $urlreferer);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
				
		$html = curl_exec($ch);

		curl_close($ch);
		return $html;
	}
	 
	// função para pegar a resposta html da consulta pelo CNPJ na página da receita
	function getHtmlCNPJ($cnpj, $captcha)
	{
		//Url de validação do capcha e retorno dos dados do formulário
		$urlvalida = 'http://www.receita.fazenda.gov.br/pessoajuridica/cnpj/cnpjreva/valida.asp'; 
		//Url para alterar o header REFERER na requisição, para que o site da RF ache que a origem foi o próprio site da RF
		$urlreferer = 'http://www.receita.fazenda.gov.br/pessoajuridica/cnpj/cnpjreva/Cnpjreva_Solicitacao2.asp';
		
		// dados que serão submetidos a consulta por post
		$post = array
		(
			'submit1'                       => 'Consultar',
			'origem'                        => 'comprovante',
			'cnpj'                          => $cnpj, 
			'txtTexto_captcha_serpro_gov_br'=> $captcha,
			'search_type'                   => 'cnpj'
		);
		
		return getHtmlReceita($post, $urlvalida, $urlreferer);
	}
	 
	// função para pegar a resposta html da consulta pelo CPF na página da receita
	function getHtmlCPF($cpf, $datanasc, $captcha)
	{
		//Url de validação do capcha e retorno dos dados do formulário
		$urlvalida = 'http://www.receita.fazenda.gov.br/Aplicacoes/ATCTA/CPF/ConsultaPublicaExibir.asp'; 
		//Url para alterar o header REFERER na requisição, para que o site da RF ache que a origem foi o próprio site da RF
		$urlreferer = 'http://www.receita.fazenda.gov.br/Aplicacoes/ATCTA/CPF/ConsultaPublica.asp';
		
		// dados que serão submetidos a consulta por post
		$post = array
		(
			'txtTexto_captcha_serpro_gov_br'	=> $captcha,
			'tempTxtCPF'						=> $cpf,
			'tempTxtNascimento'					=> $datanasc,
			'temptxtToken_captcha_serpro_gov_br'=> '',
			'temptxtTexto_captcha_serpro_gov_br'=> $captcha
		);
		
		return getHtmlReceita($post, $urlvalida, $urlreferer);
	}

	// Função para extrair o que interessa da HTML e colocar em array
	function parseHtmlCNPJ($html)
	{
		$html3 = $html;
		
		// respostas que interessam
		$campos = array(
		'NÚMERO DE INSCRIÇÃO',
		'DATA DE ABERTURA',
		'NOME EMPRESARIAL',
		'TÍTULO DO ESTABELECIMENTO (NOME DE FANTASIA)',
		'CÓDIGO E DESCRIÇÃO DA ATIVIDADE ECONÔMICA PRINCIPAL',
		'CÓDIGO E DESCRIÇÃO DAS ATIVIDADES ECONÔMICAS SECUNDÁRIAS',
		'CÓDIGO E DESCRIÇÃO DA NATUREZA JURÍDICA',
		'LOGRADOURO',
		'NÚMERO',
		'COMPLEMENTO',
		'CEP',
		'BAIRRO/DISTRITO',
		'MUNICÍPIO',
		'UF',
		'ENDEREÇO ELETRÔNICO',
		'TELEFONE',
		'ENTE FEDERATIVO RESPONSÁVEL (EFR)',
		'SITUAÇÃO CADASTRAL',
		'DATA DA SITUAÇÃO CADASTRAL',
		'MOTIVO DE SITUAÇÃO CADASTRAL',
		'SITUAÇÃO ESPECIAL',
		'DATA DA SITUAÇÃO ESPECIAL');
	 
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
		$html = str_replace('<br><b>','<b>',str_replace($caract_especiais,'',strip_tags($html,'<b><br>')));
		
		// faz a extração
		for($i=0;$i<count($campos);$i++)
		{       
			$html2 = strstr($html,utf8_decode($campos[$i]));
			$resultado[] = trim(extraiValorForm(utf8_decode($campos[$i]).'<b>','<br>',$html2));
			$html=$html2;
		}
	 
		$resultado[4] = substr($resultado[4],0,strrpos($resultado[4],'-') - 1);
	 
		// extrai os CNAEs secundarios , quando forem mais de um
		if(strstr($resultado[5],'<b>'))
		{
			$cnae_secundarios = explode('<b>',$resultado[5]);
			$resultado[5] = $cnae_secundarios;
			unset($cnae_secundarios);
		}
	  
		if( strpos($html3,'Erro na Consulta') === false && $resultado[0] != '') { // Se site no ar e validou corretamente
			return json_encode($resultado);  		
		}
		else if ($resultado[0] == '' &&  strpos($html3,'Erro na Consulta') === false) {  // Site fora do ar 
			return;
		}
		else { 
			return json_encode(array('erro','Imagem digitada incorretamente.')); // Erro na digitacao
		}
	
	}

	// Função para extrair o que interessa da HTML e colocar em array
	function parseHtmlCPF($html)
	{		
		$html3 = $html; 
	
		// respostas que interessam
		$campos = array(
		'No do CPF: ',
		'Nome da Pessoa Física: ',
		'Data de Nascimento: ',
		'Situação Cadastral: ',
		'Data da Inscrição: ');
	 
		// caracteres que devem ser eliminados da resposta
		$caract_especiais = array(
		chr(9),
		chr(10),
		chr(13),
		'&nbsp;',
		'  '
		 );
	 
		// prepara a resposta para extrair os dados
		$html = str_replace('<br><b>','<b>',str_replace($caract_especiais,'',strip_tags($html,'<b><br>')));
		
		$erros = $html;
	 
		// faz a extração
		for($i=0;$i<count($campos);$i++)
		{       
			$html2 = strstr($html,utf8_decode($campos[$i]));
			$resultado[] = trim(extraiValorForm(utf8_decode($campos[$i]).'<b>','</b>',$html2));
			$html=$html2;
		}
	 
	 
		if( strpos($html3,'idMensagemErro') === false && $resultado[0] != '') { // Se site no ar e validou corretamente
			return json_encode($resultado);  		
		}
		else if ($resultado[0] == '' &&  strpos($html3,'idMensagemErro') === false) {  
		
			if(strstr($erros,utf8_decode('CPF incorreto.'))){
				return json_encode(array('erro','CPF incorreto.'));
			}
			elseif(strstr($erros,utf8_decode('Data de nascimento informada')) &&
			   strstr($erros,utf8_decode('está divergente da constante na base de dados da Secretaria da Receita Federal do Brasil.'))) {
				return json_encode(array('erro','Data de nascimento incorreta.'));
			} else  // Site fora do ar  
				return;
		}
		else { 	
			return json_encode(array('erro','Imagem digitada incorretamente.'));			
		}
		 
	}
?>