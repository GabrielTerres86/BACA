<?php
/*!
 * FONTE        : criar_historico_novo_convenio.php
 * CRIAÇÃO      : Andrey Formigari - (Mouts)
 * DATA CRIAÇÃO : 27/10/2018 
 * OBJETIVO     : 
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

	require_once("../../includes/carrega_permissoes.php");

	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
		
	$hisconv1 = ((isset($_POST['hisconv1'])) ? $_POST['hisconv1'] : 0);
	$hisrefe1 = ((isset($_POST['hisrefe1'])) ? $_POST['hisrefe1'] : 0);
	$nmabrev1 = ((isset($_POST['nmabrev1'])) ? $_POST['nmabrev1'] : "");
	$nmexten1 = ((isset($_POST['nmexten1'])) ? $_POST['nmexten1'] : "");
	$hisconv2 = ((isset($_POST['hisconv2'])) ? $_POST['hisconv2'] : 0);
	$hisrefe2 = ((isset($_POST['hisrefe2'])) ? $_POST['hisrefe2'] : 0);
	$nmabrev2 = ((isset($_POST['nmabrev2'])) ? $_POST['nmabrev2'] : "");
	$nmexten2 = ((isset($_POST['nmexten2'])) ? $_POST['nmexten2'] : "");

	validaDados();
	
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "		<hisconv1>".$hisconv1."</hisconv1>";
	$xml .= "		<hisrefe1>".$hisrefe1."</hisrefe1>";
	$xml .= "		<nmabrev1>".$nmabrev1."</nmabrev1>";
	$xml .= "		<nmexten1>".$nmexten1."</nmexten1>";
	$xml .= "		<hisconv2>".$hisconv2."</hisconv2>";
	$xml .= "		<hisrefe2>".$hisrefe2."</hisrefe2>";
	$xml .= "		<nmabrev2>".$nmabrev2."</nmabrev2>";
	$xml .= "		<nmexten2>".$nmexten2."</nmexten2>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "TELA_HCONVE", 'PC_CRIAR_HISTORICO_WEB', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"],  "</Root>");

	$xmlObjeto = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		
		$msgErro = utf8_encode($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);				
		$nmdcampo = $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
			
		if ( !empty($nmdcampo) ) { 
			if($nmdcampo == 'cdhistor1'){				
				$nmdoform = 'fsetHistorico1';
				$nmdcampo = 'cdhistor';				
			}else if($nmdcampo == 'cdhistor2'){
				$nmdoform = 'fsetHistorico2';
				$nmdcampo = 'cdhistor';
			}else{
				$nmdoform = 'frmOpcaoH';
			}				
			
			$mtdErro = "$('input','#frmOpcaoH').removeClass('campoErro');focaCampoErro('".$nmdcampo."','".$nmdoform."');";  
			
		}else{
			
			$mtdErro = "formataformOpcaoH();$(\'#btVoltar\',\'#divBotoes\').focus();";  
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);		
		
	}else{
		
		exibirErro('inform','Hist&oacute;rico inclu&iacute;do com sucesso.','Alerta - Aimaro','controlaVoltar(\'2\');', false);	
		
	}
	
	
    function validaDados(){
		
		if (  $GLOBALS["hisconv1"] == 0 &&  $GLOBALS["hisconv2"] == 0){
			exibirErro('error','Hist&oacute;rico sugerido inv&aacute;lido.','Alerta - Aimaro','formataformOpcaoH();$(\'input, select\',\'#frmOpcaoH\').removeClass(\'campoErro\');focaCampoErro(\'cdhistsug1\',\'frmOpcaoH\');',false);
		}
					
		if (  $GLOBALS["hisconv1"] != 0 ){
			
			//Histórico sugerido
			if (  $GLOBALS["hisconv1"] == 0 ){
				exibirErro('error','Hist&oacute;rico sugerido inv&aacute;lido.','Alerta - Aimaro','formataformOpcaoH();$(\'input, select\',\'#frmOpcaoH\').removeClass(\'campoErro\');focaCampoErro(\'cdhistsug1\',\'frmOpcaoH\');',false);
			}
			
			//Histórico referência
			if (  $GLOBALS["hisrefe1"] == 0 ){
				exibirErro('error','Hist&oacute;rico refer&ecirc;ncia inv&aacute;lido.','Alerta - Aimaro','formataformOpcaoH();$(\'input, select\',\'#frmOpcaoH\').removeClass(\'campoErro\');focaCampoErro(\'cdhistor\',\'fsetHistorico1\');',false);
			}
					
			//Nome abreviado
			if (  $GLOBALS["nmabrev1"] == "" ){
				exibirErro('error','Nome abreviado inv&aacute;lido.','Alerta - Aimaro','formataformOpcaoH();$(\'input, select\',\'#frmOpcaoH\').removeClass(\'campoErro\');focaCampoErro(\'dshistor\',\'fsetHistorico1\');',false);
			}
			
			//Nome extenso
			if (  $GLOBALS["nmexten1"] == "" ){
				exibirErro('error','Nome extenso inv&aacute;lido.','Alerta - Aimaro','formataformOpcaoH();$(\'input, select\',\'#frmOpcaoH\').removeClass(\'campoErro\');focaCampoErro(\'dsexthst\',\'fsetHistorico1\');',false);
			}
			
		}
		
		if (  $GLOBALS["hisconv2"] != 0 ){
				
			//Histórico sugerido
			if (  $GLOBALS["hisconv2"] == 0 ){
				exibirErro('error','Hist&oacute;rico sugerido inv&aacute;lido.','Alerta - Aimaro','formataformOpcaoH();$(\'input, select\',\'#frmOpcaoH\').removeClass(\'campoErro\');focaCampoErro(\'cdhistsug2\',\'frmOpcaoH\');',false);
			}
			
			//Histórico referência
			if (  $GLOBALS["hisrefe2"] == 0 ){
				exibirErro('error','Hist&oacute;rico refer&ecirc;ncia inv&aacute;lido.','Alerta - Aimaro','formataformOpcaoH();$(\'input, select\',\'#frmOpcaoH\').removeClass(\'campoErro\');focaCampoErro(\'cdhistor\',\'fsetHistorico2\');',false);
			}
			
			//Nome abreviado
			if (  $GLOBALS["nmabrev2"] == "" ){
				exibirErro('error','Nome abreviado inv&aacute;lido.','Alerta - Aimaro','formataformOpcaoH();$(\'input, select\',\'#frmOpcaoH\').removeClass(\'campoErro\');focaCampoErro(\'dshistor\',\'fsetHistorico2\');',false);
			}
			
			//Nome extenso
			if (  $GLOBALS["nmexten2"] == "" ){
				exibirErro('error','Nome extenso inv&aacute;lido.','Alerta - Aimaro','formataformOpcaoH();$(\'input, select\',\'#frmOpcaoH\').removeClass(\'campoErro\');focaCampoErro(\'dsexthst\',\'fsetHistorico2\');',false);
			}
		}
	}
	
?>