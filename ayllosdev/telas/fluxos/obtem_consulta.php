<?php
	/*************************************************************************
	  Fonte: obtem_consulta.php                                               
	  Autor: Jaison Fernando
	  Data : Outubro/2016                         Última Alteração: --/--/----		   
	                                                                   
	  Objetivo  : Carrega os dados da tela FLUXOS.
	                                                                 
	  Alterações: 
				  
	***********************************************************************/

	session_start();
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");
	require_once("../../class/xmlfile.php");
    isPostMethod();

    $cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
    $dtmvtolt = (isset($_POST['dtmvtolt'])) ? $_POST['dtmvtolt'] : '';
    $dtlimite = (isset($_POST['dtlimite'])) ? $_POST['dtlimite'] : '';
    $tpdmovto = (isset($_POST['tpdmovto'])) ? $_POST['tpdmovto'] : '';
    $cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0;

    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

    switch ($cddopcao) {

        case 'F':
            // Montar o xml de Requisicao
            $xml  = "";
            $xml .= "<Root>";
            $xml .= " <Dados>";
            $xml .= "   <dtrefini>".$dtmvtolt."</dtrefini>";
            $xml .= "   <dtreffim>".$dtmvtolt."</dtreffim>";
            $xml .= "   <tpdmovto>".$tpdmovto."</tpdmovto>";
            $xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
            $xml .= " </Dados>";
            $xml .= "</Root>";

            // Requisicao dos dados
            $xmlResult = mensageria($xml, "TELA_FLUXOS", "FLUXOS_CONSULTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
            $xmlObject = getObjectXML($xmlResult);

            if ( strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO' ) {
                $msgErro = $xmlObject->roottag->tags[0]->cdata;
                if ($msgErro == '') {
                    $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
                }
                exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
            }

            $registros = $xmlObject->roottag->tags[0]->tags[0]->tags;
            $reg_total = $xmlObject->roottag->tags[0]->tags[1];

            $arrRegist = array();
            foreach( $registros as $r ) {
                $arrRegist[getByTagName($r->tags,'CODIGO')]['VLCHEQUE'] = getByTagName($r->tags,'VLCHEQUE');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['VLTOTDOC'] = getByTagName($r->tags,'VLTOTDOC');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['VLTOTTED'] = getByTagName($r->tags,'VLTOTTED');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['VLTOTTIT'] = getByTagName($r->tags,'VLTOTTIT');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['VLDEVOLU'] = getByTagName($r->tags,'VLDEVOLU');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['VLTRFITC'] = getByTagName($r->tags,'VLTRFITC');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['VLDEPITC'] = getByTagName($r->tags,'VLDEPITC');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['VLSATAIT'] = getByTagName($r->tags,'VLSATAIT');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['VLNUMERA'] = getByTagName($r->tags,'VLNUMERA');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['VLMVTITG'] = getByTagName($r->tags,'VLMVTITG');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['VLTTINSS'] = getByTagName($r->tags,'VLTTINSS');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['VLCARCRE'] = getByTagName($r->tags,'VLCARCRE');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['VLCONVEN'] = getByTagName($r->tags,'VLCONVEN');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['VLCARDEB'] = getByTagName($r->tags,'VLCARDEB');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['CEC_SOMA'] = getByTagName($r->tags,'CEC_SOMA');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['BB_SOMA']  = getByTagName($r->tags,'BB_SOMA');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['BCO_SOMA'] = getByTagName($r->tags,'BCO_SOMA');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['SIC_SOMA'] = getByTagName($r->tags,'SIC_SOMA');

                $arrRegist[getByTagName($r->tags,'CODIGO')]['BG_NR_CHEQUES'] = getByTagName($r->tags,'BG_NR_CHEQUES');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['BG_SR_DOC'] = getByTagName($r->tags,'BG_SR_DOC');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['BG_SR_TED'] = getByTagName($r->tags,'BG_SR_TED');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['BG_SR_TITULOS'] = getByTagName($r->tags,'BG_SR_TITULOS');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['BG_DEV_CHEQUE_REMETIDO'] = getByTagName($r->tags,'BG_DEV_CHEQUE_REMETIDO');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['BG_TRANSF_INTER'] = getByTagName($r->tags,'BG_TRANSF_INTER');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['BG_DEP_INTER'] = getByTagName($r->tags,'BG_DEP_INTER');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['BG_SAQUE_TAA_INTERC'] = getByTagName($r->tags,'BG_SAQUE_TAA_INTERC');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['BG_RECOLHIMENTO_NUMERARIO'] = getByTagName($r->tags,'BG_RECOLHIMENTO_NUMERARIO');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['BG_MVTO_CONTA_ITG'] = getByTagName($r->tags,'BG_MVTO_CONTA_ITG');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['BG_INSS'] = getByTagName($r->tags,'BG_INSS');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['BG_SR_CHEQUES'] = getByTagName($r->tags,'BG_SR_CHEQUES');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['BG_NR_DOC'] = getByTagName($r->tags,'BG_NR_DOC');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['BG_NR_TED_TEC'] = getByTagName($r->tags,'BG_NR_TED_TEC');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['BG_NR_TITULOS'] = getByTagName($r->tags,'BG_NR_TITULOS');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['BG_DEV_CHEQUE_RECEBIDO'] = getByTagName($r->tags,'BG_DEV_CHEQUE_RECEBIDO');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['BG_CARTAO_CREDITO'] = getByTagName($r->tags,'BG_CARTAO_CREDITO');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['BG_SUPRIMENTO_NUMERARIO'] = getByTagName($r->tags,'BG_SUPRIMENTO_NUMERARIO');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['BG_CONVENIOS'] = getByTagName($r->tags,'BG_CONVENIOS');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['BG_CARTAO_DEBITO'] = getByTagName($r->tags,'BG_CARTAO_DEBITO');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['BG_GPS'] = getByTagName($r->tags,'BG_GPS');

                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_RS_VLCHEQUE'] = getByTagName($r->tags,'DIF_RS_VLCHEQUE');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_PC_VLCHEQUE'] = getByTagName($r->tags,'DIF_PC_VLCHEQUE');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_RS_VLTOTDOC'] = getByTagName($r->tags,'DIF_RS_VLTOTDOC');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_PC_VLTOTDOC'] = getByTagName($r->tags,'DIF_PC_VLTOTDOC');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_RS_VLTOTTED'] = getByTagName($r->tags,'DIF_RS_VLTOTTED');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_PC_VLTOTTED'] = getByTagName($r->tags,'DIF_PC_VLTOTTED');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_RS_VLTOTTIT'] = getByTagName($r->tags,'DIF_RS_VLTOTTIT');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_PC_VLTOTTIT'] = getByTagName($r->tags,'DIF_PC_VLTOTTIT');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_RS_VLDEVOLU'] = getByTagName($r->tags,'DIF_RS_VLDEVOLU');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_PC_VLDEVOLU'] = getByTagName($r->tags,'DIF_PC_VLDEVOLU');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_RS_VLTRFITC'] = getByTagName($r->tags,'DIF_RS_VLTRFITC');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_PC_VLTRFITC'] = getByTagName($r->tags,'DIF_PC_VLTRFITC');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_RS_VLDEPITC'] = getByTagName($r->tags,'DIF_RS_VLDEPITC');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_PC_VLDEPITC'] = getByTagName($r->tags,'DIF_PC_VLDEPITC');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_RS_VLSATAIT'] = getByTagName($r->tags,'DIF_RS_VLSATAIT');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_PC_VLSATAIT'] = getByTagName($r->tags,'DIF_PC_VLSATAIT');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_RS_VLNUMERA'] = getByTagName($r->tags,'DIF_RS_VLNUMERA');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_PC_VLNUMERA'] = getByTagName($r->tags,'DIF_PC_VLNUMERA');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_RS_VLMVTITG'] = getByTagName($r->tags,'DIF_RS_VLMVTITG');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_PC_VLMVTITG'] = getByTagName($r->tags,'DIF_PC_VLMVTITG');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_RS_VLTTINSS'] = getByTagName($r->tags,'DIF_RS_VLTTINSS');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_PC_VLTTINSS'] = getByTagName($r->tags,'DIF_PC_VLTTINSS');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_RS_VLCARCRE'] = getByTagName($r->tags,'DIF_RS_VLCARCRE');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_PC_VLCARCRE'] = getByTagName($r->tags,'DIF_PC_VLCARCRE');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_RS_VLCONVEN'] = getByTagName($r->tags,'DIF_RS_VLCONVEN');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_PC_VLCONVEN'] = getByTagName($r->tags,'DIF_PC_VLCONVEN');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_RS_VLCARDEB'] = getByTagName($r->tags,'DIF_RS_VLCARDEB');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_PC_VLCARDEB'] = getByTagName($r->tags,'DIF_PC_VLCARDEB');

                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_RS_CEC_IN']     = getByTagName($r->tags,'DIF_RS_CEC_IN');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_PC_CEC_IN']     = getByTagName($r->tags,'DIF_PC_CEC_IN');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_RS_CEC_OUT']    = getByTagName($r->tags,'DIF_RS_CEC_OUT');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_PC_CEC_OUT']    = getByTagName($r->tags,'DIF_PC_CEC_OUT');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_RS_CEC_SOMA']   = getByTagName($r->tags,'DIF_RS_CEC_SOMA');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_PC_CEC_SOMA']   = getByTagName($r->tags,'DIF_PC_CEC_SOMA');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_CEC_PROJETADO'] = getByTagName($r->tags,'DIF_CEC_PROJETADO');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_CEC_REALIZADO'] = getByTagName($r->tags,'DIF_CEC_REALIZADO');

                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_RS_BB_IN']      = getByTagName($r->tags,'DIF_RS_BB_IN');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_PC_BB_IN']      = getByTagName($r->tags,'DIF_PC_BB_IN');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_RS_BB_OUT']     = getByTagName($r->tags,'DIF_RS_BB_OUT');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_PC_BB_OUT']     = getByTagName($r->tags,'DIF_PC_BB_OUT');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_RS_BB_SOMA']    = getByTagName($r->tags,'DIF_RS_BB_SOMA');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_PC_BB_SOMA']    = getByTagName($r->tags,'DIF_PC_BB_SOMA');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_BB_PROJETADO']  = getByTagName($r->tags,'DIF_BB_PROJETADO');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_BB_REALIZADO']  = getByTagName($r->tags,'DIF_BB_REALIZADO');

                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_RS_BCO_IN']     = getByTagName($r->tags,'DIF_RS_BCO_IN');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_PC_BCO_IN']     = getByTagName($r->tags,'DIF_PC_BCO_IN');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_RS_BCO_OUT']    = getByTagName($r->tags,'DIF_RS_BCO_OUT');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_PC_BCO_OUT']    = getByTagName($r->tags,'DIF_PC_BCO_OUT');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_RS_BCO_SOMA']   = getByTagName($r->tags,'DIF_RS_BCO_SOMA');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_PC_BCO_SOMA']   = getByTagName($r->tags,'DIF_PC_BCO_SOMA');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_BCO_PROJETADO'] = getByTagName($r->tags,'DIF_BCO_PROJETADO');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_BCO_REALIZADO'] = getByTagName($r->tags,'DIF_BCO_REALIZADO');

                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_RS_SIC_IN']     = getByTagName($r->tags,'DIF_RS_SIC_IN');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_PC_SIC_IN']     = getByTagName($r->tags,'DIF_PC_SIC_IN');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_RS_SIC_OUT']    = getByTagName($r->tags,'DIF_RS_SIC_OUT');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_PC_SIC_OUT']    = getByTagName($r->tags,'DIF_PC_SIC_OUT');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_RS_SIC_SOMA']   = getByTagName($r->tags,'DIF_RS_SIC_SOMA');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_PC_SIC_SOMA']   = getByTagName($r->tags,'DIF_PC_SIC_SOMA');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_SIC_PROJETADO'] = getByTagName($r->tags,'DIF_SIC_PROJETADO');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['DIF_SIC_REALIZADO'] = getByTagName($r->tags,'DIF_SIC_REALIZADO');
            }
            break;

        case 'M':
            // Montar o xml de Requisicao
            $xml  = "";
            $xml .= "<Root>";
            $xml .= " <Dados>";	
            $xml .= "   <dtrefere>".$dtmvtolt."</dtrefere>";
            $xml .= " </Dados>";
            $xml .= "</Root>";

            // Requisicao dos dados
            $xmlResult = mensageria($xml, "TELA_FLUXOS", "FLUXOS_MOVIMENTACAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
            $xmlObject = getObjectXML($xmlResult);

            if ( strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO' ) {
                $msgErro = $xmlObject->roottag->tags[0]->cdata;
                if ($msgErro == '') {
                    $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
                }
                exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
            }

            $registros = $xmlObject->roottag->tags[0]->tags;
            break;

        case 'L':
            // Montar o xml de Requisicao
            $xml  = "";
            $xml .= "<Root>";
            $xml .= " <Dados>";	
            $xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
            $xml .= "   <dtrefere>".$dtmvtolt."</dtrefere>";
            $xml .= " </Dados>";
            $xml .= "</Root>";

            // Requisicao dos dados
            $xmlResult = mensageria($xml, "TELA_FLUXOS", "FLUXOS_LIQUIDACAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
            $xmlObject = getObjectXML($xmlResult);

            if ( strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO' ) {
                $msgErro = $xmlObject->roottag->tags[0]->cdata;
                if ($msgErro == '') {
                    $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
                }
                exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
            }

            $xmlRegist = $xmlObject->roottag->tags[0];
            break;

        case 'R':
            // Montar o xml de Requisicao
            $xml  = "";
            $xml .= "<Root>";
            $xml .= " <Dados>";
            $xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
            $xml .= "   <dtrefere>".$dtmvtolt."</dtrefere>";
            $xml .= " </Dados>";
            $xml .= "</Root>";

            // Requisicao dos dados
            $xmlResult = mensageria($xml, "TELA_FLUXOS", "FLUXOS_CONSULTA_DIA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
            $xmlObject = getObjectXML($xmlResult);

            if ( strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO' ) {
                $msgErro = $xmlObject->roottag->tags[0]->cdata;
                if ($msgErro == '') {
                    $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
                }
                exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
            }

            $registros = $xmlObject->roottag->tags[0]->tags[0]->tags;
            $reginform = $xmlObject->roottag->tags[0]->tags[1];

            $arrRegist = array();
            foreach( $registros as $r ) {
                $arrRegist[getByTagName($r->tags,'CODIGO')]['VLENTRAD'] = getByTagName($r->tags,'VLENTRAD');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['VLSAIDAS'] = getByTagName($r->tags,'VLSAIDAS');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['VLOUTROS'] = getByTagName($r->tags,'VLOUTROS');
                $arrRegist[getByTagName($r->tags,'CODIGO')]['VLRESULT'] = getByTagName($r->tags,'VLRESULT');
            }
            break;

        case 'G':
            exit; // Utilizado apenas para validar a permissao da opcao
            break;

    }

	include('form_'.strtolower($cddopcao).'.php');
?>