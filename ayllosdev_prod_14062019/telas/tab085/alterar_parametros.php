<?php
/*!
 * FONTE        : alterar_parametros.php
 * CRIAÇÃO      : Jonata (Mouts)
 * DATA CRIAÇÃO : Agosto/2018 
 * OBJETIVO     : Rotina para alterar os parametros para a tela TAB085
 * --------------
 * ALTERAÇÕES   : 
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
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	$cdcopsel = (isset($_POST["cdcopsel"])) ? $_POST["cdcopsel"] : 0;
	$flgopstr = (isset($_POST["flgopstr"])) ? $_POST["flgopstr"] : 0;
	$iniopstr = (isset($_POST["iniopstr"])) ? $_POST["iniopstr"] : 0;
	$fimopstr = (isset($_POST["fimopstr"])) ? $_POST["fimopstr"] : 0;
	$flgoppag = (isset($_POST["flgoppag"])) ? $_POST["flgoppag"] : 0;
	$inioppag = (isset($_POST["inioppag"])) ? $_POST["inioppag"] : 0;
	$fimoppag = (isset($_POST["fimoppag"])) ? $_POST["fimoppag"] : 0;
	$vlmaxpag = (isset($_POST["vlmaxpag"])) ? $_POST["vlmaxpag"] : 0;
	$flgopbol = (isset($_POST["flgopbol"])) ? $_POST["flgopbol"] : 0;
	$iniopbol = (isset($_POST["iniopbol"])) ? $_POST["iniopbol"] : 0;
	$fimopbol = (isset($_POST["fimopbol"])) ? $_POST["fimopbol"] : 0;
	$flgcrise = (isset($_POST["flgcrise"])) ? $_POST["flgcrise"] : 0;
	$hrtrpen1 = (isset($_POST["hrtrpen1"])) ? $_POST["hrtrpen1"] : 0;
	$hrtrpen2 = (isset($_POST["hrtrpen2"])) ? $_POST["hrtrpen2"] : 0;
	$hrtrpen3 = (isset($_POST["hrtrpen3"])) ? $_POST["hrtrpen3"] : 0;
	
	validaDados();
	
	// Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= " <Dados>";
	$xml 	   .= "     <cddopcao>".$cddopcao."</cddopcao>";
	$xml 	   .= "     <cdcopsel>".$cdcopsel."</cdcopsel>";		
	$xml 	   .= "     <flgopstr>".$flgopstr."</flgopstr>";		
	$xml 	   .= "     <iniopstr>".$iniopstr."</iniopstr>";		
	$xml 	   .= "     <fimopstr>".$fimopstr."</fimopstr>";		
	$xml 	   .= "     <flgoppag>".$flgoppag."</flgoppag>";		
	$xml 	   .= "     <inioppag>".$inioppag."</inioppag>";		
	$xml 	   .= "     <fimoppag>".$fimoppag."</fimoppag>";		
	$xml 	   .= "     <vlmaxpag>".$vlmaxpag."</vlmaxpag>";		
	$xml 	   .= "     <flgopbol>".$flgopbol."</flgopbol>";		
	$xml 	   .= "     <iniopbol>".$iniopbol."</iniopbol>";		
	$xml 	   .= "     <fimopbol>".$fimopbol."</fimopbol>";		
	$xml 	   .= "     <flgcrise>".$flgcrise."</flgcrise>";		
	$xml 	   .= "     <hrtrpen1>".$hrtrpen1."</hrtrpen1>";		
	$xml 	   .= "     <hrtrpen2>".$hrtrpen2."</hrtrpen2>";		
	$xml 	   .= "     <hrtrpen3>".$hrtrpen3."</hrtrpen3>";		
	$xml 	   .= " </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_TAB085", "ALTERAR_PARAMETROS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjParametros = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjParametros->roottag->tags[0]->name) == "ERRO") {
		
		$msgErro = $xmlObjParametros->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjParametros->roottag->tags[0]->attributes["NMDCAMPO"];
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "cdcooper";
		}
		
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','formataFormularioTab085();focaCampoErro(\''.$nmdcampo.'\',\'frmTab085\');',false);		
					
	}
	
	exibirErro('inform','Atualiza&ccedil;&atilde;o efetuada com sucesso.','Alerta - Ayllos','estadoInicial();', false);

		
	 
	function validaDados(){
		
		//Convenio
		if ( $GLOBALS["cdcopsel"] == 0 && $GLOBALS["cdcooper"] == 'C' ){ 
			exibirErro('error','Cooperativa n&atilde;o selecionada.','Alerta - Ayllos','$(\'#cdcooper\',\'#frmFiltro\').habilitaCampo().focus();',false);
		}
	
	}

 ?>
