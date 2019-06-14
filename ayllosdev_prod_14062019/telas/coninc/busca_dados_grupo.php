<?php
	/*************************************************************************
	  Fonte: busca_dados_grupo.php                                               
	  Autor: Jaison Fernando
	  Data : Novembro/2016                         Última Alteração: --/--/----		   
	                                                                   
	  Objetivo  : Carrega os dados do grupo.
	                                                                 
	  Alterações: 
				  
	***********************************************************************/

	session_start();
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");
	require_once("../../class/xmlfile.php");
    isPostMethod();

    $cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
    $cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0;
    $iddgrupo = (isset($_POST['iddgrupo'])) ? $_POST['iddgrupo'] : 0;
    $nriniseq = 1;
    $nrregist = 1;

    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Montar o xml de Requisicao
    $xml  = "";
    $xml .= "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nmdgrupo/>";
	$xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
	$xml .= "   <iddgrupo>".$iddgrupo."</iddgrupo>";
	$xml .= "   <nriniseq>".$nriniseq."</nriniseq>";
	$xml .= "   <nrregist>".$nrregist."</nrregist>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    // Requisicao dos dados
    $xmlResult = mensageria($xml, "TELA_CONINC", "CONINC_PESQUISA_GRUPO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObject = getObjectXML($xmlResult);
    $qtdGrupos = $xmlObject->roottag->tags[0]->attributes["QTREGIST"];
    $regGrupos = $xmlObject->roottag->tags[0]->tags[0];
    
    if ($qtdGrupos) {
        echo "$('#iddgrupo','#frmCab').val('".getByTagName($regGrupos->tags,'IDDGRUPO')."');";
        echo "$('#nmdgrupo','#frmCab').val('".getByTagName($regGrupos->tags,'NMDGRUPO')."');";
        if ($cddopcao != 'C') { // Quando NAO for Consulta
            echo "controlaOperacao(1,30);";
        }
    } else {
        exibirErro('error','Grupo inv&aacute;lido!','Alerta - Ayllos',"resetaCamposGrupo()",false);
    }
?>