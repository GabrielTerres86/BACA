<?php
/*!
 * FONTE        : fechar_digitacao.php                    Última alteração:
 * CRIAÇÃO      : Jonata (RKAM)
 * DATA CRIAÇÃO : Maio/2017
 * OBJETIVO     : Rotina para fechar o período para digitacao da tela  MOVRGP
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

	$cdcopsel = (isset($_POST["cdcopsel"])) ? $_POST["cdcopsel"] : 0;
	$dtrefere = (isset($_POST["dtrefere"])) ? $_POST["dtrefere"] : '';
	
	validaDados();
  
	$xmlFechar  = "";
	$xmlFechar .= "<Root>";
	$xmlFechar .= "   <Dados>";
	$xmlFechar .= "	   <cddopcao>".$cddopcao."</cddopcao>";
	$xmlFechar .= "	   <cdcopsel>".$cdcopsel."</cdcopsel>";
	$xmlFechar .= "	   <dtrefere>".$dtrefere."</dtrefere>";
	$xmlFechar .= "   </Dados>";
	$xmlFechar .= "</Root>";
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlFechar, "TELA_MOVRGP", "FECHADIGI", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjFechar = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjFechar->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjFechar->roottag->tags[0]->tags[0]->tags[4]->cdata;
				 
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','focaCampoErro(\'cdcopsel\',\'frmFiltroCoop\');',false);		
							
	}    

	exibirErro('inform','Fechamento efetuado com sucesso.','Alerta - Ayllos','controlaVoltar(\'2\');',false);		
	
		
    function validaDados(){
		
		//Código da cooperativa
        if (  $GLOBALS["cdcopsel"] == 0 ){
            exibirErro('error','C&oacute;digo da cooperativa inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'cdcopsel\',\'frmFiltroCoop\');',false);
        }
		
		//Data de referência
        if (  $GLOBALS["dtrefere"] == '' ){
            exibirErro('error','Data de refer&ecirc;ncia inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'dtrefere\',\'frmFiltroCoop\');',false);
        }	
		
	}

 ?>
