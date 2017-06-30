<?php 

	/************************************************************************
	 Fonte: cheques_bordero_verifica_assinatura.php
	 Autor: Lucas Reinert
	 Data : Novembro/2016                �ltima Altera��o: 31/05/2017
	                                                                  
	 Objetivo  : Verificar se bordero exige assinatura do cooperado para efetuar libera��o
	                                                                  	 
	 Altera��es: 31/05/2017 - Ajuste para verificar se possui cheque custodiado
                              no dia de hoje. 
                              PRJ300- Desconto de cheque. (Odirlei-AMcom)
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
		
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;	
	$nrborder = (isset($_POST['nrborder'])) ? $_POST['nrborder'] : 0;	
	
	// Montar o xml de Requisicao
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrborder>".$nrborder."</nrborder>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_ATENDA_DESCTO", "VERIFICA_ASSINATURA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	
	if(isset($xmlObj->roottag->tags[0]->name) && strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);
		exit();
    }

    // Verificar se possui cheques nao aprovados custodiados no dia de hj  
    $flcusthj = $xmlObj->roottag->tags[1]->cdata;
    if ($flcusthj == 1){
        $aux_acao = 'confirmaResgateCustodiahj(\'efetivaBordero();\',\'L\');';
        
    }else {
        $aux_acao = 'efetivaBordero();';
    }
            
    
	if(isset($xmlObj->roottag->tags[0]->name) && strtoupper($xmlObj->roottag->tags[0]->name == 'FLGASSIN')){
		$flgassin = $xmlObj->roottag->tags[0]->cdata;
		
		if ($flgassin == '1'){
			$msgErro = 'Esta opera&ccedil;&atilde;o n&atilde;o ser&aacute; liberada enquanto o cooperado n&atilde;o assinar o border&ocirc;.';
			echo 'showConfirmacao("Esta opera&ccedil;&atilde;o depende da assinatura do cooperado. Confirmar assinatura?","Confirma&ccedil;&atilde;o - Ayllos","'.$aux_acao.'","showError(\'error\',\''.$msgErro.'\',\'Alerta - Ayllos\',\'blockBackground(parseInt($(\"#divRotina\").css(\"z-index\")));\');","sim.gif","nao.gif");';
		}
	}else{
		echo aux_acao;
	}	
?>
