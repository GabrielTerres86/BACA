<?php
/*!
 * FONTE        : busca_bens.php
 * CRIAÇÃO      : Andrei (RKAM)
 * DATA CRIAÇÃO : Maio/2016 
 * OBJETIVO     : Rotina para buscar os bens
 * --------------
 * ALTERAÇÕES   : 24/08/2016 - Validar se pode ser alterado a situação do GRAVAMES. Projeto 369 (Lombardi).
 *
 *                18/12/2017 - Inclusão de tratamento(utf8_encode) na mensagem de erro da ação "BUSCABENS", Prj. 402 (Jean Michel).
 *
 */
?> 

<?php	
 
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');		
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
  
	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : 0;
	$nrctrpro = (isset($_POST["nrctrpro"])) ? $_POST["nrctrpro"] : 0;
	$nrgravam = (isset($_POST["nrgravam"])) ? $_POST["nrgravam"] : 0;
	$nrregist = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 30;
	$nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 1;
  
	validaDados();
  
	// Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= "  <Dados>";
	$xml 	   .= "     <nrdconta>".$nrdconta."</nrdconta>";
	$xml 	   .= "     <cddopcao>".$cddopcao."</cddopcao>";
	$xml 	   .= "     <nrctrpro>".$nrctrpro."</nrctrpro>";
	$xml 	   .= "     <nrgravam>".$nrgravam."</nrgravam>";
	$xml 	   .= "     <nrregist>".$nrregist."</nrregist>";	
	$xml 	   .= "     <nriniseq>".$nriniseq."</nriniseq>";
	$xml 	   .= "  </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "GRVM0001", "BUSCABENS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
		exibirErro('error',$msgErro,'Alerta - Aimaro','formataFiltro();focaCampoErro(\'nrdconta\',\'frmFiltro\');',false);		
					
	}
	
	$bens = $xmlObj->roottag->tags[0]->tags;
	$qtregist  = $xmlObj->roottag->attributes["QTREGIST"];
	$possuictr  = $xmlObj->roottag->tags[0]->attributes["POSSUICTR"]; 
  
	// Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= "  <Dados>";
	$xml 	   .= "  </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_GRAVAM", "PERMISSAOSITUACAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Aimaro','formataFiltro();focaCampoErro(\'nrdconta\',\'frmFiltro\');',false);
					
	}
	
	$permissao_situacao = $xmlObj->roottag->tags[0]->cdata;
	
	if ($qtregist == 0) { 		
		
		exibirErro('inform','Nenhum registro foi encontrado.','Alerta - Aimaro','formataFiltro();$(\'#nrdconta\',\'#frmFiltro\').focus();');		
		
	} else {      
		
		include('tab_registros.php'); 	
		
	}	

	function validaDados(){
			
		IF($GLOBALS["nrdconta"] == 0 ){ 
			exibirErro('error','Conta inv&aacute;lida.','Alerta - Aimaro','formataFiltro(); focaCampoErro(\'nrdconta\',\'frmFiltro\');',false);
		}
    
    IF($GLOBALS["nrctrpro"] == 0 ){ 
			exibirErro('error','Contrato inv&aacute;lido.','Alerta - Aimaro','formataFiltro(); focaCampoErro(\'nrctrpro\',\'frmFiltro\');',false);
		}
    
    IF($GLOBALS["nrgravam"] == ''  ){ 
			exibirErro('error','N&uacute;mero do registro inv&aacute;lido.','Alerta - Aimaro','formataFiltro(); focaCampoErro(\'nrgravam\',\'frmFiltro\');',false);
		}
				
	}	
  
 ?>
