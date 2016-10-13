<?php
	/*************************************************************************
	  Fonte: grava_dados.php                                               
	  Autor: Jaison Fernando
	  Data : Outubro/2016                       Última Alteração: --/--/----
	                                                                   
	  Objetivo  : Grava os dados.
	                                                                 
	  Alterações: 
	                                                                  
	***********************************************************************/

	session_start();

	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	

	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");

	$cddopcao  = (isset($_POST['cddopcao']))  ? $_POST['cddopcao']  : '' ;
                                              
    $cdconta   = (isset($_POST['cdconta']))   ? $_POST['cdconta']   : 0  ;
	$nmconta   = (isset($_POST['nmconta']))   ? $_POST['nmconta']   : '' ;

    $cdremessa = (isset($_POST['cdremessa'])) ? $_POST['cdremessa'] : 0 ;
    $nmremessa = (isset($_POST['nmremessa'])) ? $_POST['nmremessa'] : '' ;
    $strReHiFl = (isset($_POST['strReHiFl'])) ? $_POST['strReHiFl'] : '' ;

    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

    if ($cddopcao == 'C') {
        $arrPrazo = array(90, 180, 270, 360, 720, 1080, 1440, 1800, 2160, 2520, 2880, 3240, 3600, 3960, 4320, 4680, 5040, 5400, 5401);
        $dspercen = '';
        foreach ($arrPrazo as $cdprazo) {
            $perc = $_POST['perc_'.$cdprazo];
            if ($perc) {
                $dspercen .= ($dspercen ? '#' : '') . $cdprazo . '|' . $perc;
            }
        }
        $nmdeacao = 'PARFLU_GRAVA_SYSPHERA';
    } else { // cddopcao == 'H'
        $nmdeacao = 'PARFLU_GRAVA_HISTOR';
    }

    // Montar o xml de Requisicao
	$xmlCarregaDados  = "";
	$xmlCarregaDados .= "<Root>";
	$xmlCarregaDados .= " <Dados>";
	// OPCAO C
	$xmlCarregaDados .= "   <cdconta>".$cdconta."</cdconta>";
	$xmlCarregaDados .= "   <nmconta>".utf8_decode($nmconta)."</nmconta>";
	$xmlCarregaDados .= "   <dspercen>".$dspercen."</dspercen>";
	// OPCAO H
	$xmlCarregaDados .= "   <cdremessa>".$cdremessa."</cdremessa>";
	$xmlCarregaDados .= "   <nmremessa>".$nmremessa."</nmremessa>";
	$xmlCarregaDados .= "   <strrehifl>".$strReHiFl."</strrehifl>";
	// Fecha o xml de Requisicao
	$xmlCarregaDados .= " </Dados>";
	$xmlCarregaDados .= "</Root>";

	$xmlResult = mensageria($xmlCarregaDados, "TELA_PARFLU", $nmdeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObject = getObjectXML($xmlResult);

	echo 'hideMsgAguardo();';

	if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObject->roottag->tags[0]->cdata,'Alerta - Ayllos',"bloqueiaFundo($('#divRotina'));",false);
	}

    echo "showError('inform','Dados gravados com sucesso!','PARFLU','fechaRotina($(\'#divRotina\'));estadoInicial();');";
?>