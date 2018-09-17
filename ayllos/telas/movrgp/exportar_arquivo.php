<?php
/*!
 * FONTE        : exportar_arquivo.php                    Última alteração:
 * CRIAÇÃO      : Jonata (RKAM)
 * DATA CRIAÇÃO : Maio/2017
 * OBJETIVO     : Rotina para exportação de arquivo da tela MOVRGP
 * --------------
 * ALTERAÇÕES   : 19/06/2017 - Ajuste para realizar a exportação de todas as cooperativas (Jonata - RKAM).
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

	$dtrefere = (isset($_POST["dtrefere"])) ? $_POST["dtrefere"] : '';
	
	validaDados();
  
	$xmlExportar  = "";
	$xmlExportar .= "<Root>";
	$xmlExportar .= "   <Dados>";
	$xmlExportar .= "	   <cddopcao>".$cddopcao."</cddopcao>";
	$xmlExportar .= "	   <dtrefere>".$dtrefere."</dtrefere>";
	$xmlExportar .= "   </Dados>";
	$xmlExportar .= "</Root>";
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlExportar, "TELA_MOVRGP", "EXPORTARARQ", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjExportar = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjExportar->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjExportar->roottag->tags[0]->tags[0]->tags[4]->cdata;
				 
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','$(\'#cdproduto\',\'#frmFiltroProduto\').focus();',false);		
							
	}    

	$nmarquivo = $xmlObjExportar->roottag->tags[0]->tags[0]->cdata;	
	
	echo 'Gera_Impressao("'.$nmarquivo.'","estadoInicial();");';
	
		
    function validaDados(){
		
		//Data de referência
        if (  $GLOBALS["dtrefere"] == '' ){
            exibirErro('error','Data de refer&ecirc;ncia inv&aacute;lida.','Alerta - Ayllos','$(\'#cdproduto\',\'#frmFiltroProduto\').focus();',false);
        }
		
	}

 ?>
