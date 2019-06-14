<?php
	/*************************************************************************
	  Fonte: busca_dados_histor.php                                               
	  Autor: Jaison Fernando
	  Data : Outubro/2016                         Última Alteração: --/--/----		   
	                                                                   
	  Objetivo  : Carrega os dados do historico.
	                                                                 
	  Alterações: 
				  
	***********************************************************************/

	session_start();
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");
	require_once("../../class/xmlfile.php");
    isPostMethod();

    $cddopcao = 'R';
    $cdhistor = (isset($_POST['cdhistor'])) ? $_POST['cdhistor'] : 0;
    $dsaction = (isset($_POST['dsaction'])) ? $_POST['dsaction'] : 'carrega';
    $nriniseq = 1;
    $nrregist = 1;

    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Montar o xml de Requisicao
    $xml  = "";
    $xml .= "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <dshistor/>";
	$xml .= "   <cdhistor>".$cdhistor."</cdhistor>";
	$xml .= "   <nriniseq>".$nriniseq."</nriniseq>";
	$xml .= "   <nrregist>".$nrregist."</nrregist>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    // Requisicao dos dados
    $xmlResult = mensageria($xml, "TELA_PARFLU", "PARFLU_BUSCA_HISTOR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObject = getObjectXML($xmlResult);
    $qtdHistor = $xmlObject->roottag->tags[0]->attributes["QTREGIST"];
    $regHistor = $xmlObject->roottag->tags[0]->tags[0];
    
    if ($qtdHistor) {
        if ($dsaction == 'carrega') {
            echo "$('#dshistor','#frmParflu').val('".getByTagName($regHistor->tags,'DSHISTOR')."');";
            echo "$('#tphistor','#frmParflu').val('".getByTagName($regHistor->tags,'TPHISTOR')."');";
        } else {
            echo "confirmaInclusao()";
        }
    } else {
        exibirErro('error','Hist&oacute;rico inv&aacute;lido!','Alerta - Ayllos',"resetaInclusao()",false);
    }
?>