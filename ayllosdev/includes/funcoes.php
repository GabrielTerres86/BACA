<?php
/*
******************************************************************************
ATENCAO! CONVERSAO PROGRESS - ORACLE
ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!

PARA QUALQUER ALTERACAO QUE ENVOLVA PARAMETROS DE COMUNICACAO NESSE FONTE,
A PARTIR DE 10/MAI/2013, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES PESSOAS:
- GUILHERME STRUBE (CECRED)
- MARCOS MARTINI (SUPERO)
- GUILHERME BOETTCHER (SUPERO)
*******************************************************************************

 * FONTE        : funcoes.php
 * CRIAÇÃO      : David
 * DATA CRIAÇÃO : Julho/2007
 * OBJETIVO     : Biblioteca de Funções
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * XXX: [27/01/2009] Guilherme     (CECRED) : Criada as funções addDiasNaData, subDiasNaData, diffData
 * XXX: [08/10/2009] David         (CECRED) : Alteração na função validaPermissao
 * 001: [11/02/2010] Rodolpho Telmo   (DB1) : Criada função getByTabName
 * 002: [10/03/2010] Rodolpho Telmo   (DB1) : Criada função exibirErro
 * 003: [10/03/2010] Rodolpho Telmo   (DB1) : Criada função selectEstado
 * 004: [30/03/2010] Rodolpho Telmo   (DB1) : Criada função formatarCPF_CNPJ
 * 005: [07/04/2010] Rodolpho Telmo   (DB1) : Criada função preencheString
 * 006: [14/04/2010] Rodolpho Telmo   (DB1) : Criada função juntaTexto
 * 007: [15/04/2010] Rodolpho Telmo   (DB1) : Criada função utf8ToHtml
 * 008: [16/04/2010] Rodolpho Telmo   (DB1) : Criada função retiraAcentos
 * 009: [16/04/2010] Rodolpho Telmo   (DB1) : Criada função retiraSerialize
 * 010: [16/04/2010] Rodolpho Telmo   (DB1) : Alterada função exibirErro
 * 011: [16/04/2010] Rodolpho Telmo   (DB1) : Criada função exibirConfirmacao
 * 012: [20/05/2010] Rodolpho Telmo   (DB1) : Alterada função selectEstado
 * 013: [28/07/2010] David         (CECRED) : Incluir a função sendMail
 * 014: [21/09/2010] David         (CECRED) : Incluir função visualizaPDF
 * 015: [22/10/2010] David         (CECRED) : Incluir tratamento para permissão de acesso na função getDataXML
 * 016: [18/04/2011] Rogérius Militão (DB1) : Criada a função formataCep
 * 017: [19/05/2011] Rodolpho Telmo   (DB1) : Criada a função mascara
 * 018: [16/06/2011] Jorge		   (CECRED)	: Alterada funcao exibirErro() e exibirMensagens()		
 * 019: [06/07/2011] Rogérius Militão (DB1)	: Criada a função xmlFilho()		
 * 020: [02/08/2011] Rogérius Militão (DB1)	: Criada a função formataMoeda()		
 * 021: [02/08/2011] Rogérius Militão (DB1)	: Criada a função converteFloat()		
 * 022: [03/08/2011] Rogérius Militão (DB1)	: Criada a função formataTaxa()	
 * 023: [08/09/2011] David (CECRED)         : Ajuste na função redirecionaErro, utilizando o SIDLOGIN 
 * 024: [26/12/2011] David (CECRED)         : Retirar acento do estado Roraima
 * 025: [25/04/2012] Tiago         (CECRED) : Criada a função formataContaDVsimples()
 * 026: [01/06/2012] David Kistner (CECRED) : Criada função CheckNavigator() e ajuste na visualizaPDF()
 * 027: [05/05/2014] Petter Rafael (Supero) : Criar functions para trabalho com Oracle
 * 028: [17/05/2014] Petter Rafael (Supero) : Alterar mensageria para comportar validação sistemica por requisição
 * 029: [12/08/2014] Jonata (RKAM)          : Utilizar o nome da tela enviado como parametro na mensageria com o Oracle.
 * 030: [20/11/2014] Vanessa (CECRED)       : Alterada a função visualizaPDF para tratar as teds migradas.
 * 031: [17/04/2015] Petter Rafael (Supero)	: Implementar controle de encoding nas funções dbProcedure() e dbConnect().
 * 032: [09/08/2015] Lucas Lunelli         	: Criada função removeCaracteresInvalidos().
 * 033: [14/07/2015] Gabriel       (RKAM)   : Incluir estado EX para estrangeiro.
 * 034: [20/07/2015] Kelvin					: Alteração na função removeCaracteresInvalidos() para alterar os scapes da string.
 * 035: [13/08/2015] James					: Remover o caminho "/var/www/ayllos/xml/"
 * 036: [14/08/2015] Lucas Ranghetti(CECRED): Incluir função visualizaArquivo para fazer download do arquivo ou gerar pdf na mesma function.
 * 037: [30/12/2015] Jaison (CECRED)		: Criada a funcao retornaKeyArrayMultidimensional.
 * 038: [11/07/2016] Carlos Rafael Tanholi: Removi o codigo da funcao mensageria que registrava as requisicoes nos arquivo da pasta xml/(in.xml | out.xml).
 * 039: [20/07/2016] Carlos Rafael Tanholi: Correcao na funcao formataMoeda que passava um parametro do tipo STRING para number_format. SD 448397.
 * 040: [25/07/2016] Carlos Rafael Tanholi: Correcao na expressao regular da funcao formatar(). SD 479874. 
 * 031: [24/08/2016] Carlos (CECRED)        : Criada a classe XmlMensageria para auxiliar a montagem do xml usado para mensageria 
 * 042: [22/09/2016] Carlos Rafael Tanholi: Alterei a função cecredCript e cecredDecript que usava mcrypt_cbc depreciada. SD 495858.
 * 043: [18/10/2016] Kelvin (CECRED)        : Ajustes feito na funcao RemoveCaracteresInvalidos para codificar a string antes de tratar.
 * 044: [08/02/2016] Kelvin (CECRED)        : Adicionado na funcao removeCaracteresInvalidos os caracteres ("º","°","ª") para ajustar o chamado 562089.
 * 045: [08/05/2017] Andrey (MOUTS)         : Incluir funcao validar_cnpj e validar_cpf.
 * 046: [12/04/2017] Reinert				: Ajustado funcao RemoveCaracteresInvalidos para ignorar caractere "#".
 * 047:	[28/08/2017] Carlos Rafael Tanholi	: Ajuste nas rotinas xmlFilho, dataParaTimestamp, validaPermissao, mensageria. SD 743183. 	
 * 048: [28/09/2017] Jean Michel (CECRED)   : Adicionado função get_http_response_code para retornar o status code de arquivo ou domínio
 * 049:	[28/08/2017] Lombardi (CECRED)		: Criada nova rotina buscaDominios. Projeto 366 - Reestruturação dos tipos e situações de conta.
 * 050:	[26/04/2018] Lombardi (CECRED)		: Criada nova rotina buscaSituacoesConta. Projeto 366 - Reestruturação dos tipos e situações de conta.
 * 051: [10/04/2018] Luis Fernando (Gft)	: Criada nova função getClassXml que devolve um objeto modificado do xmlFile fazendo algumas alterações em métodos para facilitar a construção
 * 052: [20/08/2018] Maykon (Envolti) : P442 - Criadas funcoes para Fipe, Aditiv e Manbem
 * 053: [16/10/2018] Bruno Luiz Katzjarowski (Mout's) : Criar rotina para detectar encode da string e converter para o encode da página
 * 054: [05/09/2019] Adicionado um nó xmlInsere na mensageiria para ajudar na localização das chamadas - Luiz Otavio Olinger Momm - AMCOM
  */

// Função para requisição de dados através de XML 
// Função retorna string com XML de retorno	
// Includes necessárias: - includes/config.php
	
function getDataXML($xmlRequest,$flgPermissao=true,$flgBlank=true,$codCooper=0) {
	global $DataServer; // Nome do servidor com base de dados PROGRESS
	global $glbvars;
	global $url_webspeed_ayllosweb;
	
	// Se variável de sessão existir e parâmetro codCooper for diferente de zero
	if (isset($glbvars["cdcooper"]) && $codCooper == 0) {
		$codCooper = $glbvars["cdcooper"];
	}
	
	if ($flgPermissao) {
		if (isset($glbvars["nmdatela"]) && isset($glbvars["telpermi"]) && $glbvars["nmdatela"] == $glbvars["telpermi"] && $glbvars["nmrotina"] == $glbvars["rotpermi"]) {
			$xmlRequest = str_replace("</Root>","",$xmlRequest);
			$xmlRequest .= "  <Permissao>";
			$xmlRequest .= "    <nmdatela>".$glbvars["telpermi"]."</nmdatela>";
			$xmlRequest .= "    <nmrotina>".$glbvars["rotpermi"]."</nmrotina>";
			$xmlRequest .= "    <cddopcao>".$glbvars["opcpermi"]."</cddopcao>";
			$xmlRequest .= "    <idsistem>".$glbvars["idsistem"]."</idsistem>";	
			$xmlRequest .= "    <inproces>".$glbvars["inproces"]."</inproces>";			
			$xmlRequest .= "    <cdagecxa>".$glbvars["cdagenci"]."</cdagecxa>";
			$xmlRequest .= "    <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
			$xmlRequest .= "    <cdopecxa>".$glbvars["cdoperad"]."</cdopecxa>";
			$xmlRequest .= "    <idorigem>".$glbvars["idorigem"]."</idorigem>";
			$xmlRequest .= "  </Permissao>";
			$xmlRequest .= "</Root>";			
		}
	}	

	// Executa o shell	
	$retorno = shell_exec("echo '".$xmlRequest."' | curl -s -S -k -X POST --data-binary @- ".$url_webspeed_ayllosweb."distribuidor.p --header \"Content-Type:text/xml\"");
        
	if ($flgBlank && trim($retorno) == "") {
		die("XML error: Requisi&ccedil;&atilde;o retornou XML em branco");
	}

	// Retorna string com XML
	return $retorno;
	
	/**** Desabilitada criptografia com gnuserver em 08/04/2014 ****
	$key = "50983417512346753284723840854609576043576094576059437609";
	$iv  = "12345678";
	
	$NomeArq = microtime(1).getmypid();
	$NomeArq = preg_replace("/\s/","",$NomeArq);		
	
	// Comando para requisição de dados pelo script gnuclient
	$command = "w".$codCooper." '".$xmlRequest."'";		
			
	$encriptado = mcrypt_cbc(MCRYPT_BLOWFISH,$key,$command,MCRYPT_ENCRYPT,$iv);
	$encriptado = preg_replace("/\n/","\\{n}",$encriptado);
	
	$fp = fopen("/var/www/ayllos/xml/$NomeArq","w+");
	fwrite($fp,$encriptado);
	fclose($fp);
		
	// Executa o shell	
	$xmlResult = shell_exec('/bin/cat /var/www/ayllos/xml/'.$NomeArq.' | /usr/local/bin/gnuclient.pl --servidor="'.$DataServer.'" --porta="2502"');
	unlink("/var/www/ayllos/xml/$NomeArq");
	$decriptado = mcrypt_cbc(MCRYPT_BLOWFISH,$key,$xmlResult,MCRYPT_DECRYPT,$iv);
	$decriptado = eregi_replace('/\e\040/',"",$decriptado);
	
	if ($flgBlank && trim($decriptado) == "") {
		die("XML error: Requisi&ccedil;&atilde;o retornou XML em branco");
	}				

	// Retorna string com XML
	return $decriptado;
	****/
}

// Função para criação do objeto responsável pelo tratamento do XML
// Includes necessárias: - includes/xmlfile.php
function getObjectXML($xmlResult) {		
	global $UrlLogin;
	global $glbvars;
	
	if (!strpos($xmlResult,"Unable") === false && !strpos($xmlResult,"distribuidor.p") === false) {
		redirecionaErro($glbvars["redirect"],$UrlLogin,"_parent","Sistema indispon&iacute;vel.");
	}
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = new XMLFile();

	// Executa leitura do XML
	$xmlObj->read_xml_string($xmlResult);
	
	// Verifica se não foi retornado XML, mas retornado HMTL com erro do WEBSPEED
	if (strtoupper($xmlObj->roottag->name) == "HTML" && !(strpos(strtoupper($xmlObj->roottag->tags[0]->tags[0]->cdata),"WEBSPEED") === false)) {
		redirecionaErro($glbvars["redirect"],$UrlLogin,"_parent","Sistema indispon&iacute;vel.");
	}			
	
	//Retorna objeto XML tratado
	return $xmlObj;
}

// Função para criação do objeto responsável pelo tratamento do XML
// Includes necessárias: - includes/xmlfile.php
function getClassXML($xmlResult){
	global $UrlLogin;
	global $glbvars;
	
	if (!class_exists('oXmlTag')){
		class oXmlTag extends XMLTag{
		    function add_subtag($name, $attributes=0)
		    {
		        $tag = new oXmlTag( $this );
		        $tag->set_name( $name );
		        if (is_array($attributes)) {
		            $tag->set_attributes( $attributes );
		        }
		        $this->tags[] = &$tag;
		        $this->curtag = &$tag;
		    }

		    function __toString(){
		        return $this->cdata;
		    }

		    function __get($name){
		        $tags = $this->find($name);
		        if($tags){
		            if(count($tags)===1){
		                $this->{$name} = $tags[0];
		                return $tags[0];
		            }
		            $this->{$name} = $tags;
		            return $tags;
		        }
		        return false;
		    }

		    function find($name){
		        return $this->find_subtags_by_name($name);
		    }

		    function findFirst($name){
		        $tags = $this->find_subtags_by_name($name);
		        if (is_array($tags)){
		            return $tags[0];
		        }
		        return false;
		    }

		    function getAttribute($name){
		        if(isset($this->attributes[$name])){
		            return $this->attributes[$name];
		        }
		        return '';
		    }
		}
		class oXmlFile extends XMLFile{
		    function create_root()
		    {
		        $null = 0;
		        $this->roottag = new oXmlTag($null);
		        $this->curtag = &$this->roottag;
		    }

		    function _tag_open( $parser, $tag, $attributes )
		    {
		        if (!is_object($this->curtag)) {
		            $null = 0;
		            $this->curtag = new oXmlTag($null);
		            $this->curtag->set_name( $tag );
		            $this->curtag->set_attributes( $attributes );
		        }
		        else {
		            $this->curtag->add_subtag( $tag, $attributes );
		            $this->curtag = &$this->curtag->curtag;
		        }
		    }
		}
	}
	if (!strpos($xmlResult,"Unable") === false && !strpos($xmlResult,"distribuidor.p") === false) {
		redirecionaErro($glbvars["redirect"],$UrlLogin,"_parent","Sistema indispon&iacute;vel.");
	}
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = new oXmlFile();

	// Executa leitura do XML
	$xmlObj->read_xml_string($xmlResult);
	
	// Verifica se não foi retornado XML, mas retornado HMTL com erro do WEBSPEED
	if (strtoupper($xmlObj->roottag->name) == "HTML" && !(strpos(strtoupper($xmlObj->roottag->tags[0]->tags[0]->cdata),"WEBSPEED") === false)) {
		redirecionaErro($glbvars["redirect"],$UrlLogin,"_parent","Sistema indispon&iacute;vel.");
	}			
	
	//Retorna objeto XML tratado
	return $xmlObj;

}


// Função para verificar o método de requisição para telas
function isPostMethod($flgIndex=false) {
	global $UrlLogin;
	global $glbvars;
	
	// Se método de requisição foi diferente de POST, redireciona ou mostra critíca
	if ($_SERVER["REQUEST_METHOD"] <> "POST") {
		if ($flgIndex) {
			redirecionaErro($glbvars["redirect"],$UrlLogin,"_parent","&Eacute; necess&aacute;rio efetuar o login.");
		} else {
			die("Para acessar a tela utilize o Menu de Servi&ccedil;os!");
		}
	}
}

// Função para setar variável na session (glbvars)
function setVarSession($name,$value) {
	global $glbvars;
	
	unsetVarSession($name);
	
	$_SESSION["glbvars"][$glbvars["sidlogin"]][$name] = $value;
	$glbvars[$name] = $value;
}

// Função para eliminar variável na session (glbvars)
function unsetVarSession($name) {
	global $glbvars;
	
	if (isset($_SESSION["glbvars"][$glbvars["sidlogin"]][$name])) {
		unset($_SESSION["glbvars"][$glbvars["sidlogin"]][$name]);
		unset($glbvars[$name]);
	}
}
// Função para validar datas - Formato dd/mm/yyyy
function validaData($data) {
	$dia = substr($data,0,2); 
	$mes = substr($data,3,2);
	$ano = substr($data,6,4);
	
	// Verifica se dados da data são númericos
	if (!is_numeric($dia) || !is_numeric($mes) || !is_numeric($ano)) {
		return false;
	}
	
	// Verifica se data informada é valida
	if (!checkdate($mes,$dia,$ano)) {
		return false;
	}	
	
	if ( $ano < 1800 ) {
		return false;
	}	
	
	return true;
}	

// Valida Número Decimal - Formato 000.000,00
function validaDecimal($numero,$decimals=2) {

	// caso nao encontre ao menos um numero, com uma virgula e x casas decimais
	if ( preg_match('/^[0-9]+,[0-9]{'.$decimals.'}$/', $numero) != 1 ) {
		return false;
	}	
	return true;
}	

// Valida Número Inteiro
function validaInteiro($numero) {

	if ( preg_match('/^[0-9]+$/', $numero) != 1 ) {
		return false;
	}	
	return true;
}

// Função para verificar se data final é maior que data inicial
function verificaPeriodo($dataInicial,$dataFinal) {
	// Verifica se são datas válidas - formato dd/mm/yyyy
	if (!valida_data($dataInicial) || !valida_data($dataFinal)) {
		return false;
	}
	
	// Converte datas para o formato yyyyddmm e depois converte para segundos
	$dataInicial = strtotime(substr($dataInicial,6,4).substr($dataInicial,3,2).substr($dataInicial,0,2));
	$dataFinal   = strtotime(substr($dataFinal,6,4).substr($dataFinal,3,2).substr($dataFinal,0,2));
	
	// Verifica diferença entre o período
	// Se diferença for menor que zero a data inicial é maior que a data final
	if (($dataFinal - $dataInicial) < 0) {
		return false;
	}

	return true;
}			

// Função para formatar número da conta com ponto de separação pro digito
function formataContaDVsimples($conta) {
	if (!is_numeric($conta)) {
		return $conta;
	}
	
	switch (strlen($conta)) {
		case 2: $contaNew = substr($conta,0,1).".".substr($conta,1,1); break;
		case 3: $contaNew = substr($conta,0,2).".".substr($conta,2,1); break;
		case 4: $contaNew = substr($conta,0,3).".".substr($conta,3,1); break;
		case 5: $contaNew = substr($conta,0,1).".".substr($conta,1,3).".".substr($conta,4,1); break;
		case 6: $contaNew = substr($conta,0,2).".".substr($conta,2,3).".".substr($conta,5,1); break;
		case 7: $contaNew = substr($conta,0,3).".".substr($conta,3,3).".".substr($conta,6,1); break;
		case 8: $contaNew = substr($conta,0,4).".".substr($conta,4,3).".".substr($conta,7,1); break;
	}

	return $contaNew;
}

// Função para formatar número da conta
function formataContaDV($conta) {
	if (!is_numeric($conta)) {
		return $conta;
	}
	
	switch (strlen($conta)) {
		case 2: $contaNew = substr($conta,0,1)."-".substr($conta,1,1); break;
		case 3: $contaNew = substr($conta,0,2)."-".substr($conta,2,1); break;
		case 4: $contaNew = substr($conta,0,3)."-".substr($conta,3,1); break;
		case 5: $contaNew = substr($conta,0,1).".".substr($conta,1,3)."-".substr($conta,4,1); break;
		case 6: $contaNew = substr($conta,0,2).".".substr($conta,2,3)."-".substr($conta,5,1); break;
		case 7: $contaNew = substr($conta,0,3).".".substr($conta,3,3)."-".substr($conta,6,1); break;
		case 8: $contaNew = substr($conta,0,4).".".substr($conta,4,3)."-".substr($conta,7,1); break;
	}

	return $contaNew;
}

// Função para redirecionamento com mensagem de erro
function redirecionaErro($tipo,$url,$target,$erro) { 
	global $UrlSite;	
	global $glbvars;	
	
	if ($tipo == "html") { // Se for uma página HTML padrão
		?>
		<html>
		<head>
		<script type="text/javascript" src="<?php echo $UrlSite; ?>scripts/jquery.js"></script>
		</head>
		<body>
		<form action="<?php echo $url; ?>" method="post" name="frmErro" id="frmErro" target="<?php echo $target; ?>">
		<input type="hidden" name="dsmsgerr" id="dsmsgerr" value="<?php echo $erro; ?>">
		<?php if (isset($glbvars["sidlogin"])) { ?>		
		<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
		<?php } ?>
		</form>
		<script type="text/javascript">$("#frmErro").submit();</script>
		</body>
		</html>			
		<?php
	} elseif ($tipo == "popup") { // Se for uma página aberta em popup
		?>
		<html>
		<head>
		<script type="text/javascript" src="<?php echo $UrlSite; ?>scripts/jquery.js"></script>
		</head>
		<body>
		<script type="text/javascript">
		var strHTML = "";
		strHTML += '<form action="<?php echo $url; ?>" method="post" name="frmErro" id="frmErro" target="<?php echo $target; ?>">';
		strHTML += '<input type="hidden" name="dsmsgerr" id="dsmsgerr" value="<?php echo $erro; ?>">';
		<?php if (isset($glbvars["sidlogin"])) { ?>
		strHTML += '<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">';
		<?php } ?>
		strHTML += '</form>';
					
		$(opener.document.body).append(strHTML);
		$(opener.document.frmErro).submit();
		
		window.close();
		</script>
		</body>
		</html>			
		<?php		
	} elseif ($tipo == "html_ajax") { // Se for um arquivo com conteúdo HTML padrão carregado por ajax
		?>
		<form action="<?php echo $url; ?>" method="post" name="frmErro" id="frmErro" target="<?php echo $target; ?>">
		<input type="hidden" name="dsmsgerr" id="dsmsgerr" value="<?php echo $erro; ?>">
		<?php if (isset($glbvars["sidlogin"])) { ?>
		<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
		<?php } ?>
		</form>
		<script type="text/javascript">
		$("#frmErro").submit();
		</script>			
		<?php
	} elseif ($tipo == "script_ajax") { // Se for um arquivo com conteúdo em javascript carregado por ajax
		?>
		var strHTML = "";
		strHTML += '<form action="<?php echo $url; ?>" method="post" name="frmErro" id="frmErro" target="<?php echo $target; ?>">';
		strHTML += '<input type="hidden" name="dsmsgerr" id="dsmsgerr" value="<?php echo $erro; ?>">';
		<?php if (isset($glbvars["sidlogin"])) { ?>
		strHTML += '<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">';
		<?php } ?>
		strHTML += '</form>';
		
		$("body").append(strHTML);
		$("#frmErro").submit();			
		<?php
	} 
}

// Função para formatar numeração
function formataNumericos($formato,$numero,$specialChars="") {
	$newValue = "";
	$j        = strlen($formato) - 1;

	for ($i = strlen($numero) - 1; $i >= 0; $i--) {
		if (!(strpos($specialChars,substr($formato,$j,1)) === false)) {				
			$newValue = substr($formato,$j,1).$newValue;
			$j--;
		} 					
		
		$newValue = substr($numero,$i,1).$newValue;
		$j--;
	}

	$posFim = strlen($formato) - strlen($newValue);
	$pos9   = strpos(substr($formato,0,$posFim),"9");

	if (!($pos9 === false)) {			
		for ($i = $posFim - 1; $i >= $pos9; $i--) {					
			$newValue = substr($formato,$i,1) == "9" ? "0".$newValue : substr($formato,$i,1).$newValue;					
		}	
	}		

	return $newValue;	
}

// Função para retornar array com UFs
function retornaUFs() {
	$estados[0]["SIGLA"]  = "AC";
	$estados[0]["NOME"]   = "Acre";
	$estados[1]["SIGLA"]  = "AL";	
	$estados[1]["NOME"]   = "Alagoas";
	$estados[2]["SIGLA"]  = "AP";
	$estados[2]["NOME"]   = "Amap&aacute;";
	$estados[3]["SIGLA"]  = "AM";
	$estados[3]["NOME"]   = "Amazonas";
	$estados[4]["SIGLA"]  = "BA";
	$estados[4]["NOME"]   = "Bahia";
	$estados[5]["SIGLA"]  = "CE";
	$estados[5]["NOME"]   = "Cear&aacute;";
	$estados[6]["SIGLA"]  = "DF";
	$estados[6]["NOME"]   = "Distrito Federal";
	$estados[7]["SIGLA"]  = "ES";
	$estados[7]["NOME"]   = "Esp&iacute;rito Santo";
	$estados[8]["SIGLA"]  = "GO";
	$estados[8]["NOME"]   = "Goi&aacute;s";
	$estados[9]["SIGLA"] = "MA";
	$estados[9]["NOME"]  = "Maranh&atilde;o";
	$estados[10]["SIGLA"] = "MT";
	$estados[10]["NOME"]  = "Mato Grosso";
	$estados[11]["SIGLA"] = "MS";
	$estados[11]["NOME"]  = "Mato Grosso do Sul";
	$estados[12]["SIGLA"] = "MG";
	$estados[12]["NOME"]  = "Minas Gerais";
	$estados[13]["SIGLA"] = "PA";
	$estados[13]["NOME"]  = "Par&aacute;";
	$estados[14]["SIGLA"] = "PB";
	$estados[14]["NOME"]  = "Para&iacute;ba";
	$estados[15]["SIGLA"] = "PR";
	$estados[15]["NOME"]  = "Paran&aacute;";
	$estados[16]["SIGLA"] = "PE";
	$estados[16]["NOME"]  = "Pernambuco";
	$estados[17]["SIGLA"] = "PI";
	$estados[17]["NOME"]  = "Piau&iacute;";
	$estados[18]["SIGLA"] = "RJ";
	$estados[18]["NOME"]  = "Rio de Janeiro";
	$estados[19]["SIGLA"] = "RN";
	$estados[19]["NOME"]  = "Rio Grande do Norte";
	$estados[20]["SIGLA"] = "RS";
	$estados[20]["NOME"]  = "Rio Grande do Sul";
	$estados[21]["SIGLA"] = "RO";
	$estados[21]["NOME"]  = "Rond&ocirc;nia";
	$estados[22]["SIGLA"] = "RR";
	$estados[22]["NOME"]  = "Roraima";
	$estados[23]["SIGLA"] = "SC";
	$estados[23]["NOME"]  = "Santa Catarina";  
	$estados[24]["SIGLA"] = "SP";
	$estados[24]["NOME"]  = "S&atilde;o Paulo";  
	$estados[25]["SIGLA"] = "SE";
	$estados[25]["NOME"]  = "Sergipe";  
	$estados[26]["SIGLA"] = "TO"; 
	$estados[26]["NOME"]  = "Tocantins"; 	
	$estados[27]["SIGLA"] = "EX"; 
	$estados[27]["NOME"]  = "Estrangeiro";
	
	return $estados;
}

function retornaCategorias() { //rubens - prj 438 - bug 14626
	$categorias[0]["IDENTIFICADOR"]  = "AUTOMOVEL";
	$categorias[0]["DESCRICAO"]   = "Automóvel";
	$categorias[1]["IDENTIFICADOR"]  = "CAMINHAO";
	$categorias[1]["DESCRICAO"]   = "Caminhão";
	$categorias[2]["IDENTIFICADOR"]  = "MOTO";
	$categorias[2]["DESCRICAO"]   = "Moto";	
	$categorias[3]["IDENTIFICADOR"]  = "OUTROS VEICULOS";
	$categorias[3]["DESCRICAO"]   = "Outros Veículos";
	
	return $categorias;
}
function retornaTiposVeiculo() {
	$tiposVeiculos[0]["IDENTIFICADOR"]  = "ZERO KM";
	$tiposVeiculos[0]["DESCRICAO"]   = "Zero KM";
	$tiposVeiculos[1]["IDENTIFICADOR"]  = "USADO";
	$tiposVeiculos[1]["DESCRICAO"]   = "Usado";
	
	return $tiposVeiculos;
}
function retornaTiposChassi() {
	$tiposVeiculos[0]["IDENTIFICADOR"]  = "1";
	$tiposVeiculos[0]["DESCRICAO"]   = "Remarcado";
	$tiposVeiculos[1]["IDENTIFICADOR"]  = "2";
	$tiposVeiculos[1]["DESCRICAO"]   = "Normal";
	
	return $tiposVeiculos;
}

function retornaUfsLicenciamento(){
	$ufs[0]["IDENTIFICADOR"] = "PR";
	$ufs[1]["IDENTIFICADOR"] = "SC";
	$ufs[2]["IDENTIFICADOR"] = "RS";
	
	return $ufs;
}

function validaPermissao($nmdatela,$nmrotina,$cddopcao='',$flgsecao=true) {
	global $glbvars;
	
	if ($flgsecao) {
		// Armazena dados da tela para validar a permissão no momento da requisição XML (getDataXML)
		setVarSession("telpermi",$nmdatela);
		setVarSession("rotpermi",$nmrotina);
		setVarSession("opcpermi",$cddopcao);
	} else {	
		// Monta o xml de requisição
		$xmlGetPermis  = "";
		$xmlGetPermis .= "<Root>";
		$xmlGetPermis .= "	<Cabecalho>";
		$xmlGetPermis .= "		<Bo>b1wgen0000.p</Bo>";
		$xmlGetPermis .= "		<Proc>obtem_permissao</Proc>";
		$xmlGetPermis .= "	</Cabecalho>";
		$xmlGetPermis .= "	<Dados>";
		$xmlGetPermis .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xmlGetPermis .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xmlGetPermis .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xmlGetPermis .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xmlGetPermis .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
		$xmlGetPermis .= "		<idsistem>".$glbvars["idsistem"]."</idsistem>";
		$xmlGetPermis .= "		<nmdatela>".$nmdatela."</nmdatela>";
		$xmlGetPermis .= "		<nmrotina>".$nmrotina."</nmrotina>";
		$xmlGetPermis .= "		<cddopcao>".$cddopcao."</cddopcao>";
		$xmlGetPermis .= "		<inproces>".$glbvars["inproces"]."</inproces>";
		$xmlGetPermis .= "	</Dados>";
		$xmlGetPermis .= "</Root>";
		
		// Executa script para envio do XML
		$xmlResult = getDataXML($xmlGetPermis);
		
		// Cria objeto para classe de tratamento de XML
		$xmlObjPermis = getObjectXML($xmlResult);
		
		// Se BO retornou algum erro, redireciona para home
		if (strtoupper($xmlObjPermis->roottag->tags[0]->name) == "ERRO") {
			return $xmlObjPermis->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}	
	}
	
	return "";
}

// Função para adicionar dias em uma data
// Entrada $data = dd/mm/aaaa (String)
//         $dias = Inteiro
function addDiasNaData($data,$dias) {     
	   $dataArr = explode('/',$data);
	$retorno = mktime(0,0,0,$dataArr[1],$dataArr[0] + $dias,$dataArr[2]);

	return strftime("%d/%m/%Y", $retorno);
}

// Função para subtrair dias em uma data
// Entrada $data = dd/mm/aaaa (String)
//         $dias = Inteiro
function subDiasNaData($data,$dias) {     
	   $dataArr = explode('/',$data);
	$retorno = mktime(0,0,0,$dataArr[1],$dataArr[0] - $dias,$dataArr[2]);
	
	return strftime("%d/%m/%Y", $retorno);
}

// Função para ver a diferença de dias entre duas datas
// Entrada $dataInicio = dd/mm/aaaa (String)
//         $dataFinal  = dd/mm/aaaa (String)
function diffData($dataInicio, $dataFinal) {
	$dataIniArr = explode('/',$dataInicio);
	   $dataIni = mktime(0,0,0,$dataIniArr[1],$dataIniArr[0],$dataIniArr[2]);
   
	   $dataFimArr = explode('/',$dataFinal);
	   $dataFim = mktime(0,0,0,$dataFimArr[1],$dataFimArr[0],$dataFimArr[2]);
   
	   $diffData = $dataIni-$dataFim;
   
	   return round($diffData/60/60/24);
 
}
	
/*!
 * ALTERAÇÃO  : 001
 * OBJETIVO   : Função para buscar um valor de uma tag XML
 * PARÂMETROS : $xml     -> é a variável que contém as tags, onde uma delas possui o mesmo nome que é passado no segundo parâmetro
 *              $tagName -> o nome da tag que será procurada dentro das tags do primeiro parâmetro
 */
function getByTagName( $xml, $tagName ) {	
	$resultado = "";
	if ( $xml != ''){
		foreach( $xml as $tag ) {
			if ( strtoupper($tag->name) == strtoupper($tagName) ) {
				$resultado = $tag->cdata;
				break;
			} 		
		}
	}	
	return trim($resultado);	
}	

function mask($val, $mask)
{
	$maskared = '';
	$k = 0;
	for($i = 0; $i<=strlen($mask)-1; $i++)
	{
		if($mask[$i] == '#')
		{
			if(isset($val[$k]))
			$maskared .= $val[$k++];
		}
		else
		{
			if(isset($mask[$i]))
			$maskared .= $mask[$i];
		}
	}
	return $maskared;
}

function getCpfCnpj( $xml, $tagName ) {	
	$resultado = "";
	if ( $xml != ''){
		foreach( $xml as $tag ) {
			if ( strtoupper($tag->name) == strtoupper($tagName) ) {
				$resultado = $tag->cdata;
				break;
			} 		
		}
	}	
	$resultado = trim($resultado);
	//***** Aplica mascara de acordo com o tipo
	$tipo = verificaTipoPessoa($resultado);
	
	if($tipo==1)
	{
		$resultado = mascaraCpf($resultado);
	}else if(tipo==2)
	{
		$resultado = mascaraCnpj($resultado);
	}
	return $resultado;
}

function verificaTipoPessoa($doc)
	{
	$tipoPessoa=0;
	if(strlen($doc) <= 11)
	{
		$tipoPessoa = 1;
	}
	else if(strlen($doc) <= 14)
	{
		$tipoPessoa = 2;
	}
	return $tipoPessoa;
}

function mascaraCpf($doc)
		{
	$doc = str_pad($doc,11, '0', STR_PAD_LEFT);
	$doc  = mask($doc,'###.###.###-##');
	return $doc;
	}	

function mascaraCnpj($doc)
{
	$doc = str_pad($doc,14, '0', STR_PAD_LEFT);
	$doc = mask($doc,'##.###.###/####-##');
	return $doc;
}


/*!
 * ALTERAÇÃO  : 002 - Criada Função
 *              010 - Na chamada da fução "showError" do javascript, ao invés de passar os parâmetros $msgErro e $titulo 
 *                    diretamente, agora utiliza-se a função utf8ToHtml, para aceitar de forma mais simples os caracteres acentuados.
 *				
 * OBJETIVO   : Função para exibir erros na tela através de javascript, mostrando o erro em uma janela padrão de erro
 *              Utiliza-se da showError definida no arquivo funcoes.js
 * PARÂMETROS : $tipo      -> String, quando seu valor for "inform", será apresentada uma mensagem de alerta, caso contrário de erro
 *  			$msgErro   -> Mensagem de erro que será exibida na tela
 *              $titulo    -> Título que será exibido no cabeçalho da mensagem
 *              $metodo    -> Método (script) que será executado após o botão for clicado
 *              $tagScript -> Aceita valores booleanos. Indica se existirá tag <script> ou não. Quando utilizo requisição ajax com redirect 
 *                            "script_ajax" e no sucess contiver "eval(response)", utilizar este parâmetro passando "false". Caso não seja
 *                            passado nenhum valor, será atribuido "true", dessa forma inserindo a tab <script>
 *			    $largTab   -> Largura width da tabela de mensagem, se nao passar este parametro, pega a largura padrao.
 */	
function exibirErro($tipo,$msgErro,$titulo,$metodo,$tagScript = true,$largTab = "NaN") { 
	if ($tagScript) { echo '<script type="text/javascript">'; }
	echo 'hideMsgAguardo();';
	echo 'showError("'.$tipo.'","'.utf8ToHtml($msgErro).'","'.utf8ToHtml($titulo).'","'.$metodo.'","'.$largTab.'");';
	if ($tagScript) { echo '</script>'; }
	if ($tipo=='error') { exit(); }
}	

function exibirMensagens($tipo,$msgErro,$titulo,$metodo,$tagScript = true,$largTab = "NaN") { 
	if ($tagScript) { echo '<script type="text/javascript">'; }
	echo 'hideMsgAguardo();';
	echo 'showError("'.$tipo.'","'.utf8ToHtml($msgErro).'","'.utf8ToHtml($titulo).'","'.$metodo.'","'.$largTab.'");';
	if ($tagScript) { echo '</script>'; }
	if ($tipo=='error') { exit(); }
}

/*!
 * ALTERAÇÃO  : 011 - Criada Função
 * OBJETIVO   : Função para exibir mensagens de confirmação na tela através de javascript, mostrando a mensagem em uma janela padrão de confirmação.
 *              Utiliza-se da showConfirmacao definida no arquivo funcoes.js
 * PARÂMETROS : $msg       [String]  -> Mensagem de confirmação que será exibida na tela
 *              $titulo    [String]  -> Título que será exibido no cabeçalho da mensagem
 *              $metodoSim [String]  -> Método (script) que será executado após o botão SIM for clicado
 *              $metodoNao [String]  -> Método (script) que será executado após o botão NÃO for clicado
 *              $tagScript [Boolean] -> Indica se existirá tag <script> ou não. Quando utilizo requisição ajax com redirect 
 *                            			"script_ajax" e no sucess contiver "eval(response)", utilizar este parâmetro passando "false". Caso não seja
 *                                       passado nenhum valor, será atribuido "true", dessa forma inserindo a tab <script>
 */	
function exibirConfirmacao($msg,$titulo,$metodoSim,$metodoNao,$tagScript = true) {
	if ($tagScript) { echo '<script type="text/javascript">'; }
	echo 'hideMsgAguardo();';
	echo 'showConfirmacao("'.utf8ToHtml($msg).'","'.utf8ToHtml($titulo).'","'.$metodoSim.'","'.$metodoNao.'","sim.gif","nao.gif");';
	if ($tagScript) { echo '</script>'; }
}

/*!
 * ALTERAÇÃO  : 003 - Criada Função
 *              012 - Possibilita passar o parâmetro "modo" para escolher como o componenete SELECT irá montar a descrição com 3 casos possíveis: sigla OU nome completo do estado OU sigla com nome completo.
 * OBJETIVO   : Retornar um HTML de um SELECT com os todos os estados brasileiros
 * PARÂMETROS : $nomeCampo  [String]  -> Nome que o elemento <select> terá, este nome será aplicado nas propriedades "name" e "id" do select
 *              $valorCampo [String]  -> Valor do <option> que deverá estar selecionado
 *              $modo       [Integer] [Opcional] -> [1] Somente Sigla | [2] Nome Estado Completo | [3] Sigla - Nome Completo. O valor 3 é o Default
 *
 */	 
function selectEstado($nomeCampo,$valorCampo,$modo = 3) {
	// Testa os valores aceitos pelo parâmetro $modo
	if ( ($modo < 1) || ($modo > 3) ) { return false; }	
	$retorno 	  = '';
	$estados      = retornaUFs();	
	$retorno =  '<select name="'.$nomeCampo.'" id="'.$nomeCampo.'">';
	$retorno .= '<option value=""> - </option>';
	
	for ($i = 0; $i < count($estados); $i++) {
		$selected = ($valorCampo == $estados[$i]["SIGLA"]) ? "selected" : "";
		// Monto o retorno dependendo do parâmetro $modo	
		if ( $modo == 1 ) {
			$retorno .= '<option value="'.$estados[$i]["SIGLA"].'" '.$selected.'>'.$estados[$i]["SIGLA"].'</option>';
		} else if ( $modo == 2 ) {
			$retorno .= '<option value="'.$estados[$i]["SIGLA"].'" '.$selected.'>'.$estados[$i]["NOME"].'</option>';
		} else if ( $modo == 3 ) {
			$retorno .= '<option value="'.$estados[$i]["SIGLA"].'" '.$selected.'>'.$estados[$i]["SIGLA"]." - ".$estados[$i]["NOME"].'</option>';
		}				
	}
	$retorno .= '</select>';
	return $retorno;
}

function selectCategoria($nomeCampo,$valorCampo) {
	
	$retorno 	  = '';
	$categorias      = retornaCategorias();	
	$retorno =  '<select name="'.$nomeCampo.'" id="'.$nomeCampo.'">';
	$retorno .= '<option value=""> - </option>';
	
	for ($i = 0; $i < count($categorias); $i++) {
		$selected = ($valorCampo == $categorias[$i]["IDENTIFICADOR"]) ? "selected" : "";
		$retorno .= '<option value="'.$categorias[$i]["IDENTIFICADOR"].'" '.$selected.'>'.$categorias[$i]["DESCRICAO"].'</option>';					
	}
	$retorno .= '</select>';
	return $retorno;
}

function selectTipoVeiculo($nomeCampo,$valorCampo) {
	
	$retorno 	  = '';
	$tiposVeiculo      = retornaTiposVeiculo();	
	$retorno =  '<select name="'.$nomeCampo.'" id="'.$nomeCampo.'">';
	$retorno .= '<option value=""> - </option>';
	
	for ($i = 0; $i < count($tiposVeiculo); $i++) {
		$selected = ($valorCampo == $tiposVeiculo[$i]["IDENTIFICADOR"]) ? "selected" : "";
		$retorno .= '<option value="'.$tiposVeiculo[$i]["IDENTIFICADOR"].'" '.$selected.'>'.$tiposVeiculo[$i]["DESCRICAO"].'</option>';					
	}
	$retorno .= '</select>';
	return $retorno;
}
function selectTipoChassi($nomeCampo,$valorCampo) {
	
	$retorno 	  = '';
	$tiposChassi      = retornaTiposChassi();	
	$retorno =  '<select name="'.$nomeCampo.'" id="'.$nomeCampo.'">';
	$retorno .= '<option value=""> - </option>';
	
	for ($i = 0; $i < count($tiposChassi); $i++) {
		$selected = ($valorCampo == $tiposChassi[$i]["IDENTIFICADOR"]) ? "selected" : "";
		$retorno .= '<option value="'.$tiposChassi[$i]["IDENTIFICADOR"].'" '.$selected.'>'.$tiposChassi[$i]["DESCRICAO"].'</option>';					
	}
	$retorno .= '</select>';
	return $retorno;
}

function selectUfPa($nomeCampo, $valorCampo){
	$retorno		= '';
	$ufs = retornaUfsLicenciamento();
	$retorno = '<select name"'.$nomeCampo.'" id="'.$nomeCampo.'">';
	
	for($i = 0; $i < count($ufs); $i++){
		$selected = ($valorCampo == $ufs[$i]["IDENTIFICADOR"]) ? "selected" : "";
		$retorno .= '<option value="'.$ufs[$i]["IDENTIFICADOR"].'" '.$selected.'>'.$ufs[$i]["IDENTIFICADOR"].'</option>';
	}
	$retorno .= '</select>';
	return $retorno;
}


/*!
 * ALTERAÇÃO  : 004
 * OBJETIVO   : Formatar e ritar a formatação para CPF e CNPJ
 * PARÂMETROS : $campo     [String ] -> Valor a do CPF ou CNPJ a ser alterado
 *              $formatado [Boolean] ->  "True" indica que é para aplicar a máscara e "False" para não aplicar
 */	 
function formatar($campo,$tipo,$formatado=true) {
	// Definindo o array de valores válidos para o parâmetro $tipo
	$array_tipos = array('cpf','cnpj');	
	
	// Testa os valores aceitos pelos parâmetros
	if ( !in_array($tipo, $array_tipos)) { return false; }
	
	if ( ( $tipo == 'cpf' ) && ( strlen($campo) < 11 ) ) {
		for( $i=0; $i < 11 - strlen($campo); $i++ ) {
			$campo = '0'.$campo;
		}
	}
	
	if ( ( $tipo == 'cnpj' ) && ( strlen($campo) < 14 ) ) {
		for( $i=0; $i < 14 - strlen($campo); $i++ ) {
			$campo = '0'.$campo;
		}
	}	
	
	$codigoLimpo = preg_replace("/[' '-.]/", '', $campo);
    
    $tamanho = (strlen($codigoLimpo) -2);

    if ($tamanho != 9 && $tamanho != 12) { return $campo; }
    if ($formatado){
		$mascara = ($tamanho == 9) ? "###.###.###-##" : "##.###.###/####-##"; 
        $indice = -1;
        for ($i=0; $i < strlen($mascara); $i++) {
            if ($mascara[$i]=="#") { $mascara[$i] = $codigoLimpo[++$indice]; }
        }
        $retorno = $mascara; 
    }else{
        $retorno = $codigoLimpo;
    } 
    return $retorno;	
}

/*!
 * ALTERAÇÃO  : 005
 * OBJETIVO   : Completar uma string com determinado caracter até completar um tamanho fixo
 * PARÂMETROS : $str      [String ] -> String a ser preenchida
 *              $tamanho  [Integer] -> Indica o tamanho que a nova string terá. Este tamanho deve ser maior do que a o tamanho de $str
 *              $preenche [String ] -> Caracter que será inserido após a $str até completar (preencher) o $tamanho
 */ 
function preencheString( $str, $tamanho, $preenche=' ', $alinhamento='E') {
	$retorno = '';
	if ( strlen($str) >= $tamanho ) { 
		$retorno = substr( $str, 0, $tamanho );
	} else {
		switch( $alinhamento ) {
			case 'E': 
				$retorno = $str.str_repeat( $preenche, $tamanho - strlen($str) );
				break;
			case 'D':
				$retorno = str_repeat( $preenche, $tamanho - strlen($str) ).$str;
				break;
			case 'C':
				$metadeTotal = (int)($tamanho / 2);
				$metadeStr   = (int)(strlen($str) / 2);

				// Preenche com um caracter a menos à esquerda
				if (strlen($str) % 2 !== 0) {
					$metadeStr++; 
				}

				$retorno = preencheString( str_repeat( $preenche, $metadeTotal - $metadeStr ).$str ,  $tamanho );
				break;
			default: 
				$retorno = '';
				break;
		}    
	}	
	return $retorno;
}

/*!
 * ALTERAÇÃO  : 006
 * OBJETIVO   : Campos com mais de uma linha de edição no modo caracter, cada linha corresponde a uma variável no Banco PROGRESS. Quando estes campos são
 *              retornados via XML, com uma variável referenciando estas tags, posso juntá-los um uma única variável. Portando esta função serve para 
 *              juntar conteúdos de diversas tags em uma String que é retornada pela função
 * PARÂMETROS : $tagsDescricao  [ Tags  ] -> Variável que contém as tags que deseja-se juntar
 *              $quebraLinha    [Boolean] -> [Opcional] Indica se insiro uma quebra de linha entre as tags 
 */ 
function juntaTexto( $tagsDescricao, $quebraLinha=true ) {
	$resultado = '';
	foreach( $tagsDescricao as $linha ) {
		if ( $linha->cdata != '' ) {
			if ( $quebraLinha ) {
				$resultado .= ($resultado == '') ? $linha->cdata : chr(13).$linha->cdata;
			} else {
				$resultado .= ($resultado == '') ? $linha->cdata : $linha->cdata;
			}
		}
	}
	return $resultado;
}

/*!
 * ALTERAÇÃO  : 007
 * OBJETIVO   : Função que converte os caracteres UTF8 para os caracteres que o Browser reconhece, como exemplo as acentuações. 
 * PARÂMETROS : $utf8 [String] -> Testo no formato UTF8 que será convertido em entidades reconhecíveis pelo HTML
 */ 
function utf8ToHtml($utf8, $encodeTags=false) {
    $resultado = '';
    for ($i = 0; $i < strlen($utf8); $i++) {
        $char  = $utf8[$i];
        $ascii = ord($char);
        if ($ascii < 128) {
            // caracter de um byte 
            $resultado .= ($encodeTags) ? htmlentities($char) : $char;
        } else if ($ascii < 192) {
            // caracter não é utf8 ou não é o byte de início
        } else if ($ascii < 224) {
            // caracter com dois byte
            $resultado .= htmlentities(substr($utf8, $i, 2), ENT_QUOTES, 'UTF-8');
            $i++;
        } else if ($ascii < 240) {
            // caracter com trê byte
            $ascii1 = ord($utf8[$i+1]);
            $ascii2 = ord($utf8[$i+2]);
            $unicode = (15 & $ascii) * 4096 +
                       (63 & $ascii1) * 64 +
                       (63 & $ascii2);
            $resultado .= "&#$unicode;";
            $i += 2;
        } else if ($ascii < 248) {
            // caracter com quatro byte
            $ascii1 = ord($utf8[$i+1]);
            $ascii2 = ord($utf8[$i+2]);
            $ascii3 = ord($utf8[$i+3]);
            $unicode = (15 & $ascii) * 262144 +
                       (63 & $ascii1) * 4096 +
                       (63 & $ascii2) * 64 +
                       (63 & $ascii3);
            $resultado .= "&#$unicode;";
            $i += 3;
        }
    }
    return $resultado;
}

/*!
 * ALTERAÇÃO  : 008
 * OBJETIVO   : Função que retira os Acentos, substituindo-os por caracteres equivalentes mas sem os acentos
 * PARÂMETROS : $str  [String]  -> Testo que será retornado sem os acentos
 */ 
function retiraAcentos( $str ) {
	$array1 = array("á","à","â","ã","ä","é","è","ê","ë","í","ì","î","ï","ó","ò","ô","õ","ö","ú","ù","û","ü","ç"
	               ,"Á","À","Â","Ã","Ä","É","È","Ê","Ë","Í","Ì","Î","Ï","Ó","Ò","Ô","Õ","Ö","Ú","Ù","Û","Ü","Ç");
	$array2 = array("a","a","a","a","a","e","e","e","e","i","i","i","i","o","o","o","o","o","u","u","u","u","c"
                   ,"A","A","A","A","A","E","E","E","E","I","I","I","I","O","O","O","O","O","U","U","U","U","C");
	return str_replace( $array1, $array2, $str ); 
}

/*
 * ALTERAÇÃO  : 009
 * OBJETIVO   : Quando passamos via AJAX uma variável serializada, esta função pode ser chamada para retirar retirar a serialização.
 * OBSERVAÇÃO : Uma variável serializada, possui o formato: "nomeDaVariavel=%C20A%asd', portanto para obter somente seu valor, retiro seu nome e o sinal de igual.
 *              Além disso, depois eu efetuo um decode para voltar o testo ao normal, retiro os acentos e troco o sinal de + por espaços.
 * PARÂMETROS : $str     [String]  -> Testo que será retornado em modo normal
 *              $nomeVar [String]  -> Testo que será retornado em modo normal
 * UTILIZAÇÃO : No arquivo do caminho: telas\contas\inf_adicionais\manter_rotina.php 
 */ 
function retiraSerialize( $str, $nomeVar ) {
	// Retiro o nome da variável e o sinal de igual
	$str = str_replace($nomeVar.'=','',$str);	
	// Troco as quebras de linha por pipe
	$str = str_replace('%0A','|',$str);
	// Troco as aspas duplas por duas aspas simples
	$str = str_replace('%22','\'\'',$str);
	// Decodifico a mensagem
	$str = rawurldecode($str);
	// Retiro os acentos
	$str = retiraAcentos($str);
	// Troco o sinal de + por espacos
	$str = str_replace('+',' ',$str);
	return $str;
}

function primeiraMaiuscula($str) {	
	return ucfirst(mb_strtolower($str));
} 

function dataParaTimestamp($data) {
	$dia = intval(substr($data,0,2)); 
	$mes = intval(substr($data,3,2));
	$ano = intval(substr($data,6,4));
	return mktime(0, 0, 0, $mes, $dia, $ano);
}

function stringTabela( $str, $tam, $tipo ) {

	// Definindo o array de valores válidos para o parâmetro $tipo e testa os valores aceitos
	$array_tipos = array('primeira','palavra','maiuscula','minuscula');		
	if ( !in_array($tipo, $array_tipos)) { return 'ERRO strintTabela'; }
	
	// Trata exibição de maiúscula ou minúscula
	switch( $tipo ) {
		case 'minuscula': $str = mb_strtolower($str); break;
		case 'maiuscula': $str = mb_strtoupper($str); break;
		case 'primeira' : $str = ucfirst(mb_strtolower($str)); break;
		case 'palavra'  : $str = ucwords(mb_strtolower($str)); break;	
		default         : break;
	}
	
	$str = ( strlen($str) > $tam ) ? substr($str,0,$tam-1).'...' : $str;
	return $str;
}

function escreveLinha( $str ) {
	if( $GLOBALS['numLinha'] > $GLOBALS['totalLinha'] ) {
		
		// Quebro a página e retorno o número de linha atual
					
		$GLOBALS['numLinha'] = 2;
		$GLOBALS['numPagina']++;
		if ( $GLOBALS['tprelato'] == 'ficha_cadastral' ){

			echo "<p>".preencheString('PAG '.$GLOBALS['numPagina'],90,' ','D')."</p>";
			if ( $GLOBALS['flagRepete'] ) { 
				if ( $GLOBALS['tipo'] == 'tabela' ) {
					escreveTitulo( $GLOBALS['titulo'] );
					escreveLinha( $GLOBALS['cab'] );
				} else if ( $GLOBALS['tipo'] == 'formulario' ) {
					escreveTitulo( $GLOBALS['titulo'] );
				}
			}
		}else {
		
			echo "<p>&nbsp;</p>";
			
		}
		
		
	} else {
		$GLOBALS['numLinha']++;
	}
	echo '              '.$str.'<br>';
}

		
function pulaLinha ( $nLinha ){
	for ($i= 0; $i < $nLinha; $i++){
		escreveLinha( '' );
	}
	return false;
}


/*!
 * ALTERAÇÃO  : 
 * OBJETIVO   : Função que monta o XML dos resgistros filhos
 * PARÂMETROS : $strCampos [String] -> Testo que contem o nome das tags que serão inseridas dentro dos registros filhos. Os campos são
										separados por "|"
 * 			    $strDados  [String] -> Testo que contem os dados dos registros filhos. Cada registro filho é separado por "|" e od dados
										são separados por ";"
 * 			    $tagPai    [String] -> Nome da tag pai
 * 			    $tagFilho  [String] -> Nome das tags filhas 
 */
function retornaXmlFilhos( $strCampos, $strDados, $tagPai, $tagFilho){
		$xml = '';
		$campos = array();
		if( $strCampos != '' ) {$campos = explode('|',$strCampos);}
		
		$aux = array();
		if( $strDados != '' ) {$aux = explode('|',$strDados);}
		
		$xml .= '<'.$tagPai.'>'; 		
		if( count($campos) != 0 ){
			foreach( $aux as $registro ){
				$dados = array();
				if( $registro != '' ) {$dados = explode(';',$registro);}
				$xml .= '<'.$tagFilho.'>'; 
				for( $i = 0; $i < count($dados); $i++ ){
					$xml .= '<'.$campos[$i].'>'.$dados[$i].'</'.$campos[$i].'>'; 		
				}		
				$xml .= '</'.$tagFilho.'>';
			}
		}
		$xml .= '</'.$tagPai.'>';
		return $xml;
	}

// Função para envio de e-mail com ou sem anexo	
function sendMail($to,$subject,$message,$from="",$reply="",$attach="") {
	/* -------------------------------------------------------------------------------------------------------- */
	/* Para anexar documentos, o parâmetro $attach deve ser um array com os seguintes dados                     */
	/* -------------------------------------------------------------------------------------------------------- */
	/* $attach[]["type"] --> String com tipo do documento     - Ex. application/pdf                             */
	/* $attach[]["name"] --> String com nome do documento     - Ex. limite_credito.pdf                          */
	/* $attach[]["file"] --> String com conteúdo do documento - Ex. $attach[]["file"] = fread($fp,strlen($fp)); */	 
	/* -------------------------------------------------------------------------------------------------------- */
	
	if (trim($to) == "" || trim($subject) == "" || trim($message) == "") {
		return false;
	}
	
	$headers = "MIME-Version: 1.0\r\n"; 
	
	// Atribui o emitente que está enviando o e-mail ao cabeçalho 
	if ($from <> "") $headers .= "From: ".$from."\r\n";
	
	// Atribui e-mail para resposta ao cabeçalho 
	if ($reply <> "") $headers .= "Reply-To: ".$reply."\r\n";
	
	// Se serão enviados anexos ao e-mail, configura cabeçalho
	if (is_array($attach)) {		
		$boundary = "XYZ-".date("dmYis")."-ZYX";
		
		$headers .= "Content-type: multipart/mixed; boundary=\"".$boundary."\"\r\n"; 
		$headers .= $boundary."\r\n";
		
		$body  = "--".$boundary."\n";
		$body .= "Content-Transfer-Encoding: 8bits\n";
		$body .= "Content-Type: text/html; charset=\"ISO-8859-1\"\n\n"; 
		$body .= $message."\n";
		
		foreach ($attach as $key => $infAttach) {
			$file = chunk_split(base64_encode($infAttach["file"]));
			
			$body .= "--".$boundary."\n";
			$body .= "Content-Type: ".$infAttach["type"]."\n"; 
			$body .= "Content-Disposition: attachment; filename=\"".$infAttach["name"]."\"\n"; 
			$body .= "Content-Transfer-Encoding: base64\n\n"; 
			$body .= $file."\n\n"; 
		}			
		
		$body .= "--".$boundary."--\r\n";
	} else {
		$headers .= "Content-type: text/html; charset=iso-8859-1\r\n";
		$body = $message;
	}

	// Envia e-mail
	return mail($to,$subject,$body,$headers);
}

function mostraTabelaAlertas($strMsg){
	echo 'var strHTML = \'<table width="445" border="0" cellpadding="1" cellspacing="2">\';';
	
	$style = "";

	for ($i = 0; $i < count($strMsg); $i++) {		
		if ($style == "") {
			$style = ' style="background-color: #FFFFFF;"';
		} else {
			$style = "";
		}	
																																	
		echo 'strHTML += \'<tr'.$style.'>\';';
		echo 'strHTML += \'<td class="txtNormal">'.$strMsg[$i].'</td>\';';
		echo 'strHTML += \'</tr>\';';															
	}

	echo 'strHTML += \'</table>\';';
			
	// Coloca conteúdo HTML no div
	echo '$("#divListaMsgsAlerta").html(strHTML);';

	// Mostra div 
	echo '$("#divMsgsAlerta").css("visibility","visible");';
	 
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';	
	
	// Bloqueia conteúdo que está átras do div de mensagens
	echo 'bloqueiaFundo($(\'#divMsgsAlerta\'));';
}

function CheckNavigator() {
	$useragent = $_SERVER['HTTP_USER_AGENT']; 
	$navegador = 'undefined';
	$versao    = '0';
	
	if (stripos($useragent,'Chrome') != false) {
		$navegador = 'chrome';
		$versao = substr($useragent,stripos($useragent,'Chrome') + 7);
		$versao = substr($versao,0,stripos($useragent,' '));		
	} elseif (stripos($useragent,'Firefox') != false) {
		$navegador = 'firefox';
		$versao = substr($useragent,stripos($useragent,'Firefox') + 8);
		$versao = substr($versao,0,stripos($useragent,' '));
	} elseif (preg_match('|MSIE ([0-9].[0-9]{1,2})|',$useragent,$matched)) {		
		$navegador = 'msie';
		
		if (stripos($useragent,'Trident') !== false) {
			$versao = substr($useragent,stripos($useragent,'Trident') + 8);
			$versao = substr($versao,0,stripos($versao,';'));
			
			switch ($versao) {
				case '4.0': $versao = '8.0'; break;
				default: $versao = '9.0';
			}
		} else {
			$versao = $matched[1];
		}
	}	
	
	$dados["navegador"] = $navegador;
	$dados["versao"]    = $versao;
	
	return $dados; 
}

function visualizaPDF($nmarquiv) {
	global $glbvars;
	
	if(trim(substr($nmarquiv,0,13)) == 'teds_migradas'){
		$dsdircop = $glbvars["dscopmig"];
	}else{
		$dsdircop = $glbvars["dsdircop"];
	}

	$nmarqpdf  = "/var/www/ayllos/documentos/".$dsdircop."/temp/".$nmarquiv;
 
	if (!file_exists($nmarqpdf)) {			
		?><script language="javascript">alert('Arquivo PDF não foi gerado.');</script><?php
		return false;
	}
	
	$fp = fopen($nmarqpdf,"r");
	$strPDF = fread($fp,filesize($nmarqpdf));
	fclose($fp);

	unlink($nmarqpdf);	
	
	$navegador = CheckNavigator();
	
	if ($navegador['navegador'] != 'chrome') {		
		header('Content-Type: application/x-download');			
		header('Content-disposition: attachment; filename="'.$nmarquiv.'"');				
	} else { 
		header('Content-Type: application/pdf');			
		header('Content-disposition: inline; filename="'.$nmarquiv.'"');
	}			
	
	header("Expires: 0"); 
	header("Cache-Control: no-cache");
	header('Cache-Control: private, max-age=0, must-revalidate');
	header("Pragma: public");
	
    echo $strPDF;
}

function visualizaCSV($nmarquiv) {
	global $glbvars;
	
	if(trim(substr($nmarquiv,0,13)) == 'teds_migradas'){
		$dsdircop = $glbvars["dscopmig"];
	}else{
		$dsdircop = $glbvars["dsdircop"];
	}

	$nmarqpdf  = "/var/www/ayllos/documentos/".$dsdircop."/temp/".$nmarquiv;
 
	if (!file_exists($nmarqpdf)) {			
		?><script language="javascript">alert('Arquivo CSV não foi gerado.');</script><?php
		return false;
	}
	
	$fp = fopen($nmarqpdf,"r");
	$strPDF = fread($fp,filesize($nmarqpdf));
	fclose($fp);

	unlink($nmarqpdf);	
	
	$navegador = CheckNavigator();
	
	//if ($navegador['navegador'] != 'chrome') {		
		header('Content-Type: application/x-download');			
		header('Content-disposition: attachment; filename="'.$nmarquiv.'"');				
	//} else { 
	//	header('Content-Type: application/pdf');			
	//	header('Content-disposition: inline; filename="'.$nmarquiv.'"');
	//}			
	
	header("Expires: 0"); 
	header("Cache-Control: no-cache");
	header('Cache-Control: private, max-age=0, must-revalidate');
	header("Pragma: public");
	
    echo $strPDF;
}

/*!
 * ALTERAÇÃO  : 016
 * OBJETIVO   : Função que formata o CEP
 * PARÂMETROS : $cep [String] -> CEP a ser formatado
 */
function formataCep($cep) {
	// pega o tamanho do cep
	//$total = count($cep);
	$cep = preencheString( $cep, 8, '0','D');
	return substr($cep,0,strlen($cep)-3)."-".substr($cep,-3);
}

/*!
 * ALTERAÇÃO  : 017
 * OBJETIVO   : Função genérica para mascarar strings
 * PARÂMETROS : $string  [String] -> Conjunto de caracteres que serão mascarados
 *              $mascara [String] -> Mascara desejada. 
 * EXEMPLOS   : Máscara pata Telefone = "(##) ####-####"
 *              Máscara para CEP      = "#####-###"
 */
function mascara($string,$mascara){
	
	$string			= str_replace(" ","",$string); // Retira os espaços em branco da string
	$contaSimbolo 	= 0; // Conta a quantidade de simbolos # já lidos da máscara
	$tamMascara		= strlen($mascara); // Tamanho da Máscara
	$tamString  	= strlen($string); // Tamanho da String	
	$novaMascara  	= ''; // Nova mascara que será gerada dependento do tamanho da $string
	
	while( ($tamMascara >= 0) && ($contaSimbolo < $tamString) ) {
		if($mascara[$tamMascara]=="#") {
			$contaSimbolo++;
		}
		$novaMascara = $mascara[$tamMascara].$novaMascara;		
		$tamMascara--;
	}	
   	for($i=0;$i<strlen($string);$i++) {
		$novaMascara[strpos($novaMascara,"#")] = $string[$i];
	}	
	return $novaMascara;
}


/*!
 * ALTERAÇÃO  : 019
 * OBJETIVO   : Função que cria xml
 * PARÂMETROS : $array [Array] 	-> Array com o valores  
				$pai [String] 	-> tag pai da xml  
				$filho [String] -> tag filha da xml
 */
function xmlFilho($array, $pai, $filho) {
	
	$xml = "<".$pai.">";	

	if ( count($array) > 0 ) { 
	foreach ( $array as $a ) {
		
		$xml .= "<".$filho.">";	

		foreach ( $a as $c => $v ) {
			$xml .= "<".$c.">";	
			$xml .= "$v";	
			$xml .= "</".$c.">";	
		}

		$xml .= "</".$filho.">";	
	}
	}
	$xml .= "</".$pai.">";	
	
	return $xml;
}

/*!
 * ALTERAÇÃO  : 020
 * OBJETIVO   : Função que formata valor moeda que veem do Progress para o formato do Brasil
 * PARÂMETROS : $valor 	-> moeda  
 */
function formataMoeda( $valor ) {
	return number_format(floatval(str_replace(',','.',$valor)),2,',','.');
}


/*!
 * ALTERAÇÃO  : 022
 * OBJETIVO   : Função que formata valor taxa que veem do Progress 
 * PARÂMETROS : $taxa 	-> taxa  
 */
function formataTaxa( $taxa ) {
	return number_format(str_replace(',','.',$taxa),6,',','.');
}

/*!
 * ALTERAÇÃO  : 021
 * OBJETIVO   : Função que converte moeda e taxa em float
 * PARÂMETROS : $valor 	-> float  
 */
function converteFloat( $valor, $tipo="" ){
  
      if ( $valor === "" ) {
         $valor =  0;
      } else {
	  
		 if ( $tipo == 'MOEDA' ) {
			$valor = formataMoeda( $valor );
		 } else if ( $tipo == 'TAXA' ) {
			$valor = formataTaxa( $valor );
		 }
		 
		 $valor = str_replace('.','', $valor);
         $valor = str_replace(',','.',$valor);
		 $valor = (float) $valor;
	  }
      return $valor;

   }
   
/*!
 * ALTERAÇÃO  : 023
 * OBJETIVO   : Remover caracteres DIFERENTES dos listados no replace da função.
				Assim, serão removidos caracteres que invalidam o XML ou outras transações.
				Remove tudo que for diferente de Letras (A-z), numéricos (0-9), caracteres com acentos e alguns sinais de pontuação.
 * PARÂMETROS : $str  	    [String]  -> Texto que será retornado sem os caracteres.
				$encodeString [Bool]  -> Faz encode e decode da string caso for chamado de um fonte que seja necessario.
 */
function removeCaracteresInvalidos( $str, $encodeString = false ){
	//Removendo escapes da string e colocando barras com scape
	$str = str_replace('\\', '', $str );
	
	//Se passar encode como true
	if($encodeString){
		$str = preg_replace("/[\n]/", "", $str);
		$str = preg_replace("/[^A-z0-9\sÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ\!\"\@\#\$\%\*\(\)\-\_\=\+\[\]\{\}\?\;\:\.\,\/\>\<\°\º\ª]/", "", utf8_decode($str));
		$str = utf8_encode($str);
	}else{
	$str = preg_replace("/[\n]/", "", $str);
	$str = preg_replace("/[^A-z0-9\sÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ\!\"\@\#\$\%\*\(\)\-\_\=\+\[\]\{\}\?\;\:\.\,\/\>\<\°\º\ª]/", "", $str);	
	}
	return $str;
	
	
}

function removeTodosCaracteresInvalidos($str) {
	return preg_replace("/[^\w\s\.]/i", "", $str);
}

/************************************************************/
/* 															*/
/*			FUNCOES PARA UTILIZAR O BANCO ORACLE			*/
/*															*/
/************************************************************/

/**
 * Função para descriptografar os dados de login no banco de dados Oracle.
 * Retorna constantes com login e senha.
 */
function dbOracle() {
    $user = base64_decode(USERE);
    $pass = base64_decode(PASSE);

	//valida se a constante nao esta definida
	if (defined('USER') == false) {
		define('USER', $user);
}
	//valida se a constante nao esta definida
	if (defined('PASS') == false) {
		define('PASS', $pass);
	}
}

/* Funcao para criptografar o texto enviado conforme chave secreta */
function cecredCript($texto) {
	return mcrypt_encrypt(MCRYPT_BLOWFISH, KEY, $texto, MCRYPT_MODE_CBC, IV);
}

/* Funcao para descriptografar o texto enviado conforme chave secreta */
function cecredDecript($texto) {
	return mcrypt_decrypt(MCRYPT_BLOWFISH, KEY, $texto, MCRYPT_MODE_CBC, IV);
}

/* Funcao para separar a connect string OCI em User, Pwd e Senha */
function separaOCIString($connStr,&$usr,&$pwd,&$hst){
	$usr = substr($connStr,0,strpos($connStr,'/'));
	$connStr = ltrim($connStr,$usr.'/');
	$pwd = substr($connStr,0,strpos($connStr,'@'));
	$connStr = ltrim($connStr,$pwd.'@');
	$hst = substr($connStr,0,strlen($connStr));
}

/**
 * Fábrica de conexões no banco de dados Oracle.
 * @return type Retorna pool de conexão Oracle
 */
function dbConnect() {
    
	dbOracle();
	
	// Se ainda nao gravamos as credenciais na sessao 
	if(!(isset($_SESSION["OCIConnString"]))) {	
		// Gravaremos as informações de login criptografas na sessao
		$_SESSION["OCIConnString"] = cecredCript(USER.'/'.PASS.'@'.HOST);
	}
	
	// Descriptografando Connection String
	$connStr = cecredDecript($_SESSION["OCIConnString"]);
	
	// Separamos as informações
	separaOCIString($connStr,$usr,$pwd,$hst);
		
	// Criando conexão
	$dbConn = oci_connect($usr,$pwd,$hst, 'WE8MSWIN1252');
	
	// Destroi as variaveis antes de testar o problema com a conexao para evitar
	// que as mesmas fiquem com as credenciais na memoria
	unset($usr,$pwd,$hst,$connStr);
	
	// Se houve problema com a conexao
	if(!$dbConn){
		$erro = oci_error();
		exibirErro("error", htmlentities($erro['message']), "Erro de conexão ao DB", "", false);
	}
		
	return $dbConn;
	
}

/**
 * Gerenciador para instruções SELECT.
 * Implementa PDO.
 * @param type $sql Query da instrução SELECT.
 * @return type Retorna array com os dados retornados.
 */
function dbSelect($sql) {
    
	$dbConn = dbConnect();
	
    $ps = oci_parse($dbConn, $sql);
    
    if(!$ps){
        $erro = oci_error($dbConn);
        exibirErro("error", htmlentities($erro['message']), "Erro de conexão", "", false);
    }
    
    $exec = oci_execute($ps);
    oci_fetch_all($ps, $linhas);
    
    if(!$exec){
        $erro = oci_error($ps);
        exibirErro("error", htmlentities($erro['message']), "Erro de conexão", "", false);
    }

    $dbConn = null;

    return $linhas;
}

/**
 * Gerenciador para instruções DELETE, UPDATE e INSERT.
 * @param type $sql Query da instrução SQL.
 * @return type Retorna o número de linhas afetadas.
 */
function dbAcao($sql){
    
	$dbConn = dbConnect();
	
    $ps = oci_parse($dbConn, $sql);
    
    if(!$ps){
        $erro = oci_error($dbConn);
        exibirErro("error", htmlentities($erro['message']), "Erro de conexão", "", false);
    }

    $exec = oci_execute($ps);
    
    if(!$exec){
        $erro = oci_error($ps);
        exibirErro("error", htmlentities($erro['message']), "Erro de conexão", "", false);
    }
    
    $deletar = oci_num_rows($ps);

    $dbConn = null;

    return $deletar;
}

/**
 * Gerenciador para executar a chamada da procedure do Oracle que irá processar o XML.
 * Recebe o XML de retorno a partir de um CLOB.
 * @param type $xml Arquivo XML enviado
 * @return type Arquivo XML de retorno
 */
function dbProcedure($xml){
    mb_internal_encoding("WINDOWS-1252");
	$dbConn = dbConnect();
		    
    $sql = "begin gene0004.pc_xml_web(:xmlReq, :xmlRes); end;";
    $ps = oci_parse($dbConn, $sql);
    
    if(!$ps){
        $erro = oci_error($dbConn);
        exibirErro("error", htmlentities($erro['message']), "Erro de conexão", "", false);
    }

    $textoLobRes = oci_new_descriptor($dbConn, OCI_D_LOB);
	
	oci_bind_by_name($ps, ':xmlReq', $xml, -1);
    oci_bind_by_name($ps, ':xmlRes', $textoLobRes, -1, OCI_B_CLOB);
    $exec = oci_execute($ps);
    
    $xmlresultado = $textoLobRes->read($textoLobRes->size());    
    
    if(!$exec){
        $erro = oci_error($ps);
        exibirErro("error", htmlentities($erro['message']), "Erro de conexão", "", false);
    }

    $textoLobRes->free();
    oci_close($dbConn);
	
	return $xmlresultado;
}

/**
 * Função para unificar o envio/recebimento de XML para o Oracle.
 * @param string $xml String contendo o XML
 * @param type $nmprogra Nome da tela de execução
 * @param type $cdcooper Código da cooperativa
 * @param type $cdagenci Código da agencia
 * @param type $nrdcaixa Número do caixa
 * @param type $idorigem Identificador de origem
 * @param type $cdoperad Nome do usuário
 * @param type $tag TAG XML que deverá ser demarcada como ponto de insert de novas tag´s
 * @return string Retorna XML com novas TAG´s
 */
function mensageria($xml, $nmprogra, $nmeacao, $cdcooper, $cdagenci,$nrdcaixa, $idorigem, $cdoperad, $tag){

    $xml = xmlInsere($xml, $nmprogra, $nmeacao, $cdcooper, $cdagenci, $nrdcaixa, $idorigem, $cdoperad, $tag);
    $endereco = dirname(dirname(__FILE__)) . '/xml';
	
	//valida a existencia do arquivo
	if (file_exists($endereco."/in.xml")) {
	$arquivo = fopen($endereco."/in.xml","w");
	fwrite($arquivo, $xml);
	fclose($arquivo);
	}
		
	$retXML = dbProcedure($xml);

	//valida a existencia do arquivo
	if (file_exists($endereco."/out.xml")) {
	$arquivo = fopen($endereco."/out.xml", "w");
	fwrite($arquivo, $retXML);
	fclose($arquivo);
	}
	
	return $retXML;
}

/**
 * Função para adicionar TAG´s de parametrização ao XML.
 * A TAG ROOT deve ser obrigatoriamente "root".
 * @param string $xml String contendo o XML
 * @param type $nmprogra Nome da tela de execução
 * @param type $cdcooper Código da cooperativa
 * @param type $cdagenci Código da agencia
 * @param type $nrdcaixa Número do caixa
 * @param type $idorigem Identificador de origem
 * @param type $cdoperad Nome do usuário
 * @param type $tag TAG XML que deverá ser demarcada como ponto de insert de novas tag´s
 * @return string Retorna XML com novas TAG´s
 */
function xmlInsere($xml, $nmprogra, $nmeacao, $cdcooper, $cdagenci, $nrdcaixa, $idorigem, $cdoperad, $tag){
    global $glbvars;

    $novo = "<params>" .
                "<nmprogra>" . $nmprogra . "</nmprogra>" .
                "<nmeacao>"  . $nmeacao . "</nmeacao>" .
                "<cdcooper>" . $cdcooper . "</cdcooper>" .
                "<cdagenci>" . $cdagenci . "</cdagenci>" .
                "<nrdcaixa>" . $nrdcaixa . "</nrdcaixa>" .
                "<idorigem>" . $idorigem . "</idorigem>" .
                "<cdoperad>" . $cdoperad . "</cdoperad>" .
                "<filesphp>" . $_SERVER["SCRIPT_FILENAME"]  . "</filesphp>" .  // 054: [05/09/2019] AMCOM P450 - Melhorando a vida das pessoas
             "</params>";
    
    if(isset($glbvars["nmdatela"]) && isset($glbvars["telpermi"]) && $glbvars["nmdatela"] == $glbvars["telpermi"] && $glbvars["nmrotina"] == $glbvars["rotpermi"]){

        $novo .= "<Permissao>" .
                    "<nmdatela>" . $glbvars["telpermi"] . "</nmdatela>" .
                    "<nmrotina>" . $glbvars["rotpermi"] . "</nmrotina>" .
                    "<cddopcao>" . $glbvars["opcpermi"] . "</cddopcao>" .
                    "<idsistem>" . $glbvars["idsistem"] . "</idsistem>" .
                    "<inproces>" . $glbvars["inproces"] . "</inproces>" .
                    "<cdagecxa>" . $glbvars["cdagenci"] . "</cdagecxa>" .
                    "<nrdcaixa>" . $glbvars["nrdcaixa"] . "</nrdcaixa>" .
                    "<cdopecxa>" . $glbvars["cdoperad"] . "</cdopecxa>" .
                    "<idorigem>" . $glbvars["idorigem"] . "</idorigem>" .
                  "</Permissao>";
    }

    $pos = strripos($xml, $tag);
    $xml = substr($xml, 0, $pos) . $novo . substr($xml, $pos, strlen($xml));
  
    return '<?xml version="1.0" encoding="ISO-8859-1" ?>' . $xml;
}

/**
 * Função para debugar XML.
 
 * @param string $xml String contendo o XML
 * @return string Retorna XML
 */
function pr($xml){
    
    echo "<pre>";
    print_r($xml);
    echo "</pre>";
    
}

// Função para fazer somente o download dependendo do tipo ou  visualizar arquivo em pdf
function visualizaArquivo($nmarquiv,$tipo) {
	global $glbvars;
	
	$dsdircop = $glbvars["dsdircop"];
	
	$nmarqimp  = "/var/www/ayllos/documentos/".$dsdircop."/temp/".$nmarquiv;
 
	if (!file_exists($nmarqimp)) {			
		?><script language="javascript">alert('Arquivo não foi gerado.');</script><?php
		return false;
	}
	
	$fp = fopen($nmarqimp,"r");
	$strArquivo = fread($fp,filesize($nmarqimp));
	fclose($fp);

	unlink($nmarqimp);
	
	$navegador = CheckNavigator();

	// Se extensao do arquivo não for pdf, fazer download do arquivo
	if ($tipo != 'pdf') {
		header('Content-Type: application/x-download');			
		header('Content-disposition: attachment; filename="'.$nmarquiv.'"');				
	}else{ // Gerar Arquivo PDF
		if ($navegador['navegador'] != 'chrome') {		
			header('Content-Type: application/x-download');			
			header('Content-disposition: attachment; filename="'.$nmarquiv.'"');				
		} else { 
			header('Content-Type: application/pdf');			
			header('Content-disposition: inline; filename="'.$nmarquiv.'"');
		}			
	}
	header("Expires: 0"); 
	header("Cache-Control: no-cache");
	header('Cache-Control: private, max-age=0, must-revalidate');
	header("Pragma: public");
	
	echo $strArquivo;
}

function retiraCharEspecial($valor){
	$valor = str_replace("\n", ' ',$valor);
	$valor = str_replace("\r",'',$valor);
	$valor = str_replace("'","" ,$valor);
	$valor = str_replace("\\","" ,$valor);
	return $valor;
}

function retornaKeyArrayMultidimensional($array, $field, $value)
{
   foreach($array as $key => $register)
   {
      if ( $register[$field] === $value )
         return $key;
   }
   return false;
}


// Função para justificar o texto fornecido conforme a quantidade de caracteres (largura) fornecido.
// Exemplo de uso: telas/contas/ficha_cadastral/imp_fichacadastral_pf_html.php 
function justificar($text, $width) {
	$marker = "\n"; 

	// lines is an array of lines containing the word-wrapped text 
	$wrapped = wordwrap($text, $width, $marker); 
	
	$lines = explode($marker, $wrapped);

	foreach ($lines as $line_index=>$line) {
		$line = trim($line);
		$words = explode(" ", $line);
		$words = array_map("trim", $words);
		$wordcount = count($words);
		$wordlength = strlen(implode("", $words)); 

		if ($line_index > 0 && 3*$wordlength < 2*$width) { 
			// don't touch lines shorter than 2/3 * width 
			continue;
		}

		$spaces = $width - $wordlength;

		$index = 0;
		do {
			$words[$index] = $words[$index] . " ";
			$index = ($index + 1) % ($wordcount - 1);
			$spaces--;
		} while ($spaces>0);

		$lines[$line_index] = implode("", $words);
	}
	return $lines;
}

/*
Classe auxiliar para montagem de xml usado na mensageria().
Ex. de uso: telas/cbrfra/manter_rotina.php
*/
class XmlMensageria {	
	private $xml;

	function __construct() {
		$this->xml = '<Root><Dados>';
    }

	public function add($tag, $valor) {
        $this->xml .= '<' . $tag . '>' . trim($valor) . '</' . $tag . '>';
		return $this;
    }

    public function __toString() {
        return $this->xml . '</Dados></Root>';
    }
}

function validar_cnpj($cnpj){
	$cnpj = preg_replace('/[^0-9]/', '', (string) $cnpj);
	// Valida tamanho
	if (strlen($cnpj) != 14)
		return false;
	// Valida primeiro dígito verificador
	for ($i = 0, $j = 5, $soma = 0; $i < 12; $i++)
	{
		$soma += $cnpj{$i} * $j;
		$j = ($j == 2) ? 9 : $j - 1;
	}
	$resto = $soma % 11;
	if ($cnpj{12} != ($resto < 2 ? 0 : 11 - $resto))
		return false;
	// Valida segundo dígito verificador
	for ($i = 0, $j = 6, $soma = 0; $i < 13; $i++)
	{
		$soma += $cnpj{$i} * $j;
		$j = ($j == 2) ? 9 : $j - 1;
	}
	$resto = $soma % 11;
	return $cnpj{13} == ($resto < 2 ? 0 : 11 - $resto);
}

function validar_cpf($cpf = null) {
 
    // Verifica se um número foi informado
    if(empty($cpf)) {
        return false;
    }
 
    // Elimina possivel mascara
    $cpf = ereg_replace('[^0-9]', '', $cpf);
    $cpf = str_pad($cpf, 11, '0', STR_PAD_LEFT);
     
    // Verifica se o numero de digitos informados é igual a 11 
    if (strlen($cpf) != 11) {
        return false;
    }
    // Verifica se nenhuma das sequências invalidas abaixo 
    // foi digitada. Caso afirmativo, retorna falso
    else if ($cpf == '00000000000' || 
        $cpf == '11111111111' || 
        $cpf == '22222222222' || 
        $cpf == '33333333333' || 
        $cpf == '44444444444' || 
        $cpf == '55555555555' || 
        $cpf == '66666666666' || 
        $cpf == '77777777777' || 
        $cpf == '88888888888' || 
        $cpf == '99999999999') {
        return false;
     // Calcula os digitos verificadores para verificar se o
     // CPF é válido
     } else {   
        for ($t = 9; $t < 11; $t++) {
             
            for ($d = 0, $c = 0; $c < $t; $c++) {
                $d += $cpf{$c} * (($t + 1) - $c);
            }
            $d = ((10 * $d) % 11) % 10;
            if ($cpf{$c} != $d) {
                return false;
            }
        }
        return true;
    }
}

// Função para retornar o status code de arquivo ou domínio
function get_http_response_code($url) {
	$headers = get_headers($url);
	return substr($headers[0], 9, 3);
}
	  
function buscaDominios($nmmodulo, $nmdomini) {
	global $glbvars;
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "    <nmmodulo>" . $nmmodulo . "</nmmodulo>";
	$xml .= "    <nmdomini>" . $nmdomini . "</nmdomini>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "GENE0010", "RETORNA_DOMINIOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);	
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial();',false);
	}
	
	return $xmlObj->roottag->tags[0]->tags;
}

function buscaSituacoesConta() {
	global $glbvars;
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "CADA0006", "LISTA_SITUACOES_CONTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);	
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial();',false);
	}
	
	return $xmlObj->roottag->tags[0]->tags;
}

/**
 * @author Bruno Luiz K. - Mout's;
 * Descrição: Retorna uma string com encoding correto para exibição com acento
 * @param string $string
 * @param bool $desc
 *
 * @return mixed|null|string|string[]
 */
function decodeString($string, $html = false){
	if($html){
		$string = html_entity_decode($string, ENT_QUOTES);
		$string = strip_tags($string);
	}
	$codificacaoAtual = mb_detect_encoding($string, 'auto', true);
	$content = mb_convert_encoding($string, 'ISO-8859-1', $codificacaoAtual);
	$content = decodeSpecialCharsHTML($content);
	$content = str_replace(";",".",$content);
	
	return $content;
}

function decodeSpecialCharsHTML($content){
	$arrSpecial = array(
		"&quot;" => "\"",
		"&#36;" => "$",
		"&#37;" => "%",
		"&#40;" => "(",
		"&#41;" => ")",
		"&#126;" => "~",
		"&#39;" => "'",
		"&lsquo;" => "‘",
		"&rsquo;" => "’",
		"&sbquo;" => "‚",
		"&ldquo;" => "“",
		"&rdquo;" => "”",
		"&bdquo;" => "„",
		"&#64;" => "@",
		"&#45;" => "-",
	);
	foreach ($arrSpecial as $key => $value){
		$content = str_replace($key, $value, $content);
	}
	return $content;
}
?>