<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Jaison
 * DATA CRIAÇÃO : 24/03/2017
 * OBJETIVO     : Rotina para manipulacao dos dados da tela
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

	$vlminimo_emprestado    = (isset($_POST['vlminimo_emprestado']))    ? converteFloat($_POST['vlminimo_emprestado']) : 0;
	$vlmaximo_emprestado    = (isset($_POST['vlmaximo_emprestado']))    ? converteFloat($_POST['vlmaximo_emprestado']) : 0;
    $qtdminima_parcela      = (isset($_POST['qtdminima_parcela']))      ? $_POST['qtdminima_parcela']      : 0;
    $qtdmaxima_parcela      = (isset($_POST['qtdmaxima_parcela']))      ? $_POST['qtdmaxima_parcela']      : 0;
    $strPeriodicidadeIndex  = (isset($_POST['strPeriodicidadeIndex']))  ? $_POST['strPeriodicidadeIndex']  : '';
    $strPeriodicidadeCaren  = (isset($_POST['strPeriodicidadeCaren']))  ? $_POST['strPeriodicidadeCaren']  : '';

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'A')) <> '') {
        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

    // Monta o xml de requisicao
    $xml  = "";
    $xml .= "<Root>";
    $xml .= " <Dados>";		
    $xml .= "   <vlminimo_emprestado>".$vlminimo_emprestado."</vlminimo_emprestado>";
    $xml .= "   <vlmaximo_emprestado>".$vlmaximo_emprestado."</vlmaximo_emprestado>";
    $xml .= "   <qtdminima_parcela>".$qtdminima_parcela."</qtdminima_parcela>";
    $xml .= "   <qtdmaxima_parcela>".$qtdmaxima_parcela."</qtdmaxima_parcela>";
    $xml .= "   <strPeriodicidadeIndex>".$strPeriodicidadeIndex."</strPeriodicidadeIndex>";
    $xml .= "   <strPeriodicidadeCaren>".$strPeriodicidadeCaren."</strPeriodicidadeCaren>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_PRMPOS", 'PRMPOS_GRAVA', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjeto = getObjectXML($xmlResult);

    if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO"){
        $msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
        $arrErro = explode("###", $msgErro);
        $msgErro = $arrErro[0];
        $nmCampo = $arrErro[1];
        $nmFunca = $nmCampo ? "$('#".$nmCampo."', '#frmPrmpos').focus();" : '' ;
        exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos',$nmFunca,false);
    }

    echo "hideMsgAguardo();";    
    echo 'showError("inform","Dados gravados com sucesso!","Alerta - Ayllos","carregaTelaPrmpos();");';
?>