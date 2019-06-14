<?php
	/*!
	 * FONTE        : inclui_email.php
	 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
	 * DATA CRIAÇÃO : 27/08/2018
	 * OBJETIVO     : Rotina para incluir email
	 * --------------
	 * ALTERAÇÕES   : 
	 * -------------- 
	 */		

    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();			

	$tpproduto        = (isset($_POST['tpproduto']))        ? $_POST['tpproduto']        : 0;
	$qt_periodicidade = (isset($_POST['qt_periodicidade'])) ? $_POST['qt_periodicidade'] : 0; 
	$qt_envio         = (isset($_POST['qt_envio']))         ? $_POST['qt_envio']         : 0; 
	$ds_assunto       = (isset($_POST['ds_assunto']))       ? $_POST['ds_assunto']       : ''; 
	$ds_corpo         = (isset($_POST['ds_corpo']))         ? $_POST['ds_corpo']         : '';

	// tratar acentuação
	$ds_assunto = utf8_decode($ds_assunto);
	$ds_corpo = utf8_decode($ds_corpo);
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"I")) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
		
	// Montar o xml de Requisicao
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= " <tpproduto>".$tpproduto."</tpproduto>";
	$xml .= " <qt_periodicidade>".$qt_periodicidade."</qt_periodicidade>";
	$xml .= " <qt_envio>".$qt_envio."</qt_envio>";
	$xml .= " <ds_assunto>".$ds_assunto."</ds_assunto>";
	$xml .= " <ds_corpo>".$ds_corpo."</ds_corpo>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_TAB089", "INSERE_EMAIL_PROPOSTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"],"</Root>");
	$xmlObj = getObjectXML($xmlResult);
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
		exit();
	}

	exibirErro('inform','E-mail cadastrado com sucesso.' ,'Alerta - Ayllos','acessaAbaEmail();',false);
?>