<?php
/*!
 * FONTE        : alterar_valor_minimo_ted_capital.php                    Última alteração:
 * CRIAÇÃO      : Jonata (RKAM)
 * DATA CRIAÇÃO : Julho/2017
 * OBJETIVO     : Responsável por alterar/incluir o valor minimo referente a TED de capital
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

        exibirErro('error',$msgError,'Alerta - Ayllos','');
    }

	$vlminimo = (isset($_POST["vlminimo"])) ? $_POST["vlminimo"] : 0;
	
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "   <Dados>";
	$xml .= "	   <vlminimo>".$vlminimo."</vlminimo>";
	$xml .= "   </Dados>";
	$xml .= "</Root>";
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_SOL030", "ALTERAR_VLMINIMO_CAPITAL_TED", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjPrazo = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjPrazo->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjPrazo->roottag->tags[0]->tags[0]->tags[4]->cdata;
			 
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','estadoInicial();',false);		
							
	}
	
	exibirErro('inform','Opera&ccedil;&atilde;o efetuada com sucesso.','Alerta - Ayllos','estadoInicial();');		
		
	
?>


