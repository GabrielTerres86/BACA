<?php
/*!
 * FONTE        : inativar_cargo_funcao.php
 * CRIAÇÃO      : Jonata (Mouts)
 * DATA CRIAÇÃO : Setembro/2018 
 * OBJETIVO     : Rotina para inativar cargo/funcao
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

	$nrcpfcgc = (isset($_POST["nrcpfcgc"])) ? $_POST["nrcpfcgc"] : 0;
	$cdfuncao = (isset($_POST["cdfuncao"])) ? $_POST["cdfuncao"] : 0;
	$nrdrowid = (isset($_POST["nrdrowid"])) ? $_POST["nrdrowid"] : 0;
	$dtinicio_vigencia = (isset($_POST["dtinicio_vigencia"])) ? $_POST["dtinicio_vigencia"] : 0;
	$dtfim_vigencia = (isset($_POST["dtfim_vigencia"])) ? $_POST["dtfim_vigencia"] : 0;
	
	
	// Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= " <Dados>";
	$xml 	   .= "     <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";		
	$xml 	   .= "     <dtinicio_vigencia>".$dtinicio_vigencia."</dtinicio_vigencia>";		
	$xml 	   .= "     <dtfim_vigencia>".$dtfim_vigencia."</dtfim_vigencia>";		
	$xml 	   .= "     <cdfuncao>".$cdfuncao."</cdfuncao>";		
	$xml 	   .= "     <nrdrowid>".$nrdrowid."</nrdrowid>";	
	$xml 	   .= " </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_PESSOA", "INATIVAR_CARGO_FUN", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjParametros = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjParametros->roottag->tags[0]->name) == "ERRO") {
		
		$msgErro = $xmlObjParametros->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjParametros->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "dtinicio_vigencia";
		}
				
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','$(\'input, select\',\'#frmCargoFuncao\').removeClass(\'campoErro\');focaCampoErro(\''.$nmdcampo.'\',\'frmCargoFuncao\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);		
					
	}
	
	exibirErro('inform','Opera&ccedil;&atilde;o efetuada com sucesso.','Alerta - Ayllos','fechaRotina($(\'#divRotina\'));buscarCooperado(\'1\',\'30\');',false);		
	

 ?>
