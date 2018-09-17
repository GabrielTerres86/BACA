<?
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Douglas Quisinski
 * DATA CRIAÇÃO : 08/05/2015
 * OBJETIVO     : Capturar dados para tela CUSTCH
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
		
	// Recebe o POST
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ;
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'I')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Se conta informada não for um número inteiro válido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inválida.','Alerta - Ayllos','',false);
	

	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "CUSTCH", "CUSTCH_VALIDA_CONTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO'){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
		exit();
	}
			
	$nmprimtl = "";
	if(strtoupper($xmlObj->roottag->tags[0]->name) == 'DADOS'){	
		$nmprimtl = $xmlObj->roottag->tags[0]->cdata;
		if($nmprimtl == null || $nmprimtl == ''){
			$nmprimtl = $xmlObj->roottag->tags[0]->tags[0]->cdata;
		}
	}
		
	include('form_cabecalho.php');	
	include('tab_custch.php');	
?>

<script type='text/javascript'>
	controlaLayout();

	// Alimenta as variáveis globais
	nrdconta = '<? echo $nrdconta; ?>';
	<?php
		echo '$("#nrdconta","#frmCab").val("'.$nrdconta.'").formataDado("INTEGER","zzzz.zzz-z","",false);';
		echo '$("#nmprimtl","#frmCab").val("'.$nmprimtl.'")';
	?>
</script>