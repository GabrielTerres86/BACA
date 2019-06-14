<?php
/*!
 * FONTE        : salvar_historico_novo_convenio.php
 * CRIAÇÃO      : Andrey Formigari - (Mouts)
 * DATA CRIAÇÃO : 27/10/2018 
 * OBJETIVO     : 
 * --------------
	* ALTERAÇÕES   : 
 * --------------
 */ 

	if( !ini_get('safe_mode') ){
		set_time_limit(300);
	}
	session_cache_limiter("private");
	session_start();

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');		
	
	// Ler parametros passados via POST
	$cddopcao  = (isset($_POST['cddopcao']))  ? $_POST['cddopcao']  : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
	
	$file      = (isset($_FILES['userfile'])) ? $_FILES['userfile'] : '';
	
	validaDados();

	// retorno sera de eval ou html
	$eval     = (isset($_POST['redirect'])) ? true : false;
    $tempo    = time();
    // Local de Upload do arquivo -  Antes de passar pelo "upload_file.php"
	$nmupload  = "../../upload_files/" . $_FILES['userfile']['name'];
	
	// Instanciar arrays....
	$arrCrit    = array();
	$arrStrFile = array();

	// se destinatario for por upload file
	if($file["error"] > 0){
		switch($file["error"]){
			case 1:	$arrCrit[] = "ATENCAO: Tamanho do arquivo excedeu o permitido.";		break;
			case 2:	$arrCrit[] = "ATENCAO: Tamanho do arquivo deve conter menos de 8 mb.";  break;
			case 3:	$arrCrit[] = "ATENCAO: Falha ao enviar arquivo ER3.";					break;
			case 4:	$arrCrit[] = "ATENCAO: Falha ao enviar arquivo ER4.";					break;
			case 6:	$arrCrit[] = "ATENCAO: Falha ao enviar arquivo ER6.";					break;
			case 7:	$arrCrit[] = "ATENCAO: Falha ao gravar arquivo ER7.";					break;
			case 8:	$arrCrit[] = "ATENCAO: Falha ao enviar arquivo ER8.";					break;
		}
	}
	
	// Se não encontrar o arquivo...
	if($file == ""){
		$arrCrit[] = "ATENCAO: Arquivo não encontrado.";
	}
	// Verificar o tamanho do arquivo
	if($file["size"] > (8 * (1024 * 1024))){
		$arrCrit[] = "ATENCAO: Tamanho do arquivo deve ser menor que 8 mb.";
	}
	// Validar o arquivo
	if(!is_uploaded_file($file["tmp_name"])){
		$arrCrit[] = "ATENCAO: Erro ao validar arquivo. *VL1.";
	}
	if (!move_uploaded_file($file["tmp_name"], $nmupload)) {
		$arrCrit[] = "ATENCAO: Erro ao validar arquivo. *VL2.";
	}

	// gerar erros criticos
	if(count($arrCrit) > 0){
		
		exibirErro('error',$arrCrit[0],'Alerta - Aimaro','',false);
	}

	$tempo     = time();
	
	// Nome do arquivo do upload - Depois de passar pelo "upload_file.php"
	$dirArqDne = "../../upload_files/";
	$filename  = $_FILES['userfile']['name'];
    $Arq       = $nmupload;

	//encriptacao e envio do arquivo
	require("../../includes/upload_file.php");

    // Caminho que deve ser enviado ao Mensageria / para ORACLE fazer exec do CURL
    $caminhoCompleto = $_SERVER['SERVER_NAME'].'/'.str_replace('../../','',$caminho);

    // Apaga o arquivo de UPLOAD que está sem Criptografia
    unlink($Arq);

	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";	
	$xml .= "		<dsarquiv>".$NomeArq."</dsarquiv>";	 // Variável $NomeArq vem da gnuclient_upload_file.php
	$xml .= "		<dsdireto>".$caminhoCompleto."</dsdireto>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "TELA_HCONVE", 'IMPORTA_ARQ', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
 	if ($xmlObjeto->roottag->tags[0]->name == "ERRO") {

		$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',utf8_encode($msgErro),'Alerta - Aimaro','controlaVoltar(\'3\')',false);		

    }else if ($xmlObjeto->roottag->tags[0]->name == "DADOS") {

		$inconsistencias   = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
		$qtregist  = $xmlObjeto->roottag->tags[0]->attributes["QTREGIST"];

		include("tabela_registros.php"); 

	} else {

		$flgcvuni = $xmlObjeto->roottag->tags[0]->tags[0]->cdata;
	
		if ( $flgcvuni == null ) {

			exibirErro('inform','Sucesso! Convênio aguardando execução na central.','Alerta - Aimaro','formataFormOpcaoI();$(\'#btVoltar\',\'#divBotoesOpcaoI\').focus();',false);		
		
		} else if (($flgcvuni == 0) || ($flgcvuni == 1 && $glbvars["cdcooper"] == 3)) {

			$nmarquiv = $xmlObjeto->roottag->tags[0]->tags[1]->cdata;
			echo 'Gera_Impressao("'.$nmarquiv.'","controlaVoltar(\'1\');");';	

		}
		
	}
	
    function validaDados(){
		
		if (  $_FILES['userfile']['name'] == null ){
			exibirErro('error','Diretório do arquivo não foi selecionado.','Alerta - Aimaro','formataformOpcaoI();$(\'input, select\',\'#frmOpcaoI\').removeClass(\'campoErro\');focaCampoErro(\'cdhistsug1\',\'frmOpcaoI\');',false);
		}

	}
	
?>