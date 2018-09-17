<?php
/*!
 * FONTE        : excluir_movimento.php                    Última alteração:
 * CRIAÇÃO      : Jonata (RKAM)
 * DATA CRIAÇÃO : Maio/2017
 * OBJETIVO     : Rotina para exclusão de movimentos da tela MOVRGP
 * --------------
 * ALTERAÇÕES   :  
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

        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
    }

	$idmovto_risco = (isset($_POST["idmovto_risco"])) ? $_POST["idmovto_risco"] : 0;
	
	validaDados();
  
	$xmlExcluir  = "";
	$xmlExcluir .= "<Root>";
	$xmlExcluir .= "   <Dados>";
	$xmlExcluir .= "	   <cddopcao>".$cddopcao."</cddopcao>";
	$xmlExcluir .= "	   <idmovto_risco>".$idmovto_risco."</idmovto_risco>";
	$xmlExcluir .= "   </Dados>";
	$xmlExcluir .= "</Root>";
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlExcluir, "TELA_MOVRGP", "EXCLUIRMOV", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjExcluir = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjExcluir->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjExcluir->roottag->tags[0]->tags[0]->tags[4]->cdata;
				 
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','carregaMovimentos(\'1\',\'30\');',false);		
							
	}    

	exibirErro('inform','Movimento exclu&iacute;do com sucesso.','Alerta - Ayllos','carregaMovimentos(\'1\',\'30\');',false);		
	
		
    function validaDados(){
		
		//Código do movimento
        if (  $GLOBALS["idmovto_risco"] == 0 ){
            exibirErro('error','C&oacute;digo do movimento inv&aacute;lido.','Alerta - Ayllos','carregaMovimentos(\'1\',\'30\');',false);
        }	
		
	}

 ?>
