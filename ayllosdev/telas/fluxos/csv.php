<?php
	/*************************************************************************
	  Fonte: csv.php                                               
	  Autor: Jaison Fernando
	  Data : Outubro/2016                       Última Alteração: --/--/----
	                                                                   
	  Objetivo  : Exporta os dados em CSV.
	                                                                 
	  Alterações: 
	                                                                  
	***********************************************************************/

	session_start();

	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../class/xmlfile.php");

	$cdcooper = (isset($_GET['cdcooper'])) ? $_GET['cdcooper'] : '' ;
	$dtrefini = (isset($_GET['dtrefini'])) ? $_GET['dtrefini'] : '' ;
	$dtreffim = (isset($_GET['dtreffim'])) ? $_GET['dtreffim'] : '' ;

    // Montar o xml de Requisicao
    $xml  = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <dtrefini>".$dtrefini."</dtrefini>";
    $xml .= "   <dtreffim>".$dtreffim."</dtreffim>";
    $xml .= "   <tpdmovto>E</tpdmovto>"; // Entrada
    $xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_FLUXOS", "FLUXOS_CONSULTA", $_GET["glb_cdcooper"], $_GET["glb_cdagenci"], $_GET["glb_nrdcaixa"], $_GET["glb_idorigem"], $_GET["glb_cdoperad"], "</Root>");
    $xmlObject = getObjectXML($xmlResult);

    if ( strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO' ) {
        $msgErro = $xmlObject->roottag->tags[0]->cdata;
        if ($msgErro == '') {
            $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
        }
        echo "<script>
              alert('" . $msgErro . "');
              window.close();
              </script>";
        exit;
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
    }

    $str  = 'INSTITUIÇÃO;TIPO;REMESSA;PROJETADO;REALIZADO;DIFERENÇA_VALOR;DIFERENÇA_PERCENTUAL'."\r\n";

    $str .= 'CECRED;Entrada;NR CHEQUES;'.$arrRegist['0853']['VLCHEQUE'].';'.$arrRegist['0851']['VLCHEQUE'].';'.$arrRegist['0854']['DIF_RS_VLCHEQUE'].';'.$arrRegist['0854']['DIF_PC_VLCHEQUE']."\r\n";
    $str .= 'CECRED;Entrada;SR DOC;'.$arrRegist['0853']['VLTOTDOC'].';'.$arrRegist['0851']['VLTOTDOC'].';'.$arrRegist['0854']['DIF_RS_VLTOTDOC'].';'.$arrRegist['0854']['DIF_PC_VLTOTDOC']."\r\n";
    $str .= 'CECRED;Entrada;SR TED;'.$arrRegist['0853']['VLTOTTED'].';'.$arrRegist['0851']['VLTOTTED'].';'.$arrRegist['0854']['DIF_RS_VLTOTTED'].';'.$arrRegist['0854']['DIF_PC_VLTOTTED']."\r\n";
    $str .= 'CECRED;Entrada;SR TÍTULOS;'.$arrRegist['0853']['VLTOTTIT'].';'.$arrRegist['0851']['VLTOTTIT'].';'.$arrRegist['0854']['DIF_RS_VLTOTTIT'].';'.$arrRegist['0854']['DIF_PC_VLTOTTIT']."\r\n";
    $str .= 'CECRED;Entrada;DEV. CHEQUE REMETIDO;'.$arrRegist['0853']['VLDEVOLU'].';'.$arrRegist['0851']['VLDEVOLU'].';'.$arrRegist['0854']['DIF_RS_VLDEVOLU'].';'.$arrRegist['0854']['DIF_PC_VLDEVOLU']."\r\n";
    $str .= 'CECRED;Entrada;TRANSF INTER;'.$arrRegist['0853']['VLTRFITC'].';'.$arrRegist['0851']['VLTRFITC'].';'.$arrRegist['0854']['DIF_RS_VLTRFITC'].';'.$arrRegist['0854']['DIF_PC_VLTRFITC']."\r\n";
    $str .= 'CECRED;Entrada;DEP INTER;'.$arrRegist['0853']['VLDEPITC'].';'.$arrRegist['0851']['VLDEPITC'].';'.$arrRegist['0854']['DIF_RS_VLDEPITC'].';'.$arrRegist['0854']['DIF_PC_VLDEPITC']."\r\n";
    $str .= 'CECRED;Entrada;SAQUE TAA INTERC;'.$arrRegist['0853']['VLSATAIT'].';'.$arrRegist['0851']['VLSATAIT'].';'.$arrRegist['0854']['DIF_RS_VLSATAIT'].';'.$arrRegist['0854']['DIF_PC_VLSATAIT']."\r\n";
    $str .= 'CECRED;Entrada;RECOLHIMENTO NUMERÁRIO;'.$arrRegist['0853']['VLNUMERA'].';'.$arrRegist['0851']['VLNUMERA'].';'.$arrRegist['0854']['DIF_RS_VLNUMERA'].';'.$arrRegist['0854']['DIF_PC_VLNUMERA']."\r\n";

    $str .= 'BANCO DO BRASIL;Entrada;SR TÍTULOS;'.$arrRegist['0013']['VLTOTTIT'].';'.$arrRegist['0011']['VLTOTTIT'].';'.$arrRegist['0014']['DIF_RS_VLTOTTIT'].';'.$arrRegist['0014']['DIF_PC_VLTOTTIT']."\r\n";
    $str .= 'BANCO DO BRASIL;Entrada;MVTO CONTA ITG;'.$arrRegist['0013']['VLMVTITG'].';'.$arrRegist['0011']['VLMVTITG'].';'.$arrRegist['0014']['DIF_RS_VLMVTITG'].';'.$arrRegist['0014']['DIF_PC_VLMVTITG']."\r\n";

    $str .= 'BANCOOB;Entrada;INSS;'.$arrRegist['7563']['VLTTINSS'].';'.$arrRegist['7561']['VLTTINSS'].';'.$arrRegist['7564']['DIF_RS_VLTTINSS'].';'.$arrRegist['7564']['DIF_PC_VLTTINSS']."\r\n";

    $str .= 'SICREDI;Entrada;SR TED;'.$arrRegist['7483']['VLTOTTED'].';'.$arrRegist['7481']['VLTOTTED'].';'.$arrRegist['7484']['DIF_RS_VLTOTTED'].';'.$arrRegist['7484']['DIF_PC_VLTOTTED']."\r\n";
    $str .= 'SICREDI;Entrada;INSS;'.$arrRegist['7483']['VLTTINSS'].';'.$arrRegist['7481']['VLTTINSS'].';'.$arrRegist['7484']['DIF_RS_VLTTINSS'].';'.$arrRegist['7484']['DIF_PC_VLTTINSS']."\r\n";

    // Montar o xml de Requisicao
    $xml  = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <dtrefini>".$dtrefini."</dtrefini>";
    $xml .= "   <dtreffim>".$dtreffim."</dtreffim>";
    $xml .= "   <tpdmovto>S</tpdmovto>"; // Saida
    $xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_FLUXOS", "FLUXOS_CONSULTA", $_GET["glb_cdcooper"], $_GET["glb_cdagenci"], $_GET["glb_nrdcaixa"], $_GET["glb_idorigem"], $_GET["glb_cdoperad"], "</Root>");
    $xmlObject = getObjectXML($xmlResult);

    if ( strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO' ) {
        $msgErro = $xmlObject->roottag->tags[0]->cdata;
        if ($msgErro == '') {
            $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
        }
        exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
    }

    $registros = $xmlObject->roottag->tags[0]->tags[0]->tags;

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
    }

    $str .= 'CECRED;Saída;SR CHEQUES;'.$arrRegist['0854']['VLCHEQUE'].';'.$arrRegist['0852']['VLCHEQUE'].';'.$arrRegist['0854']['DIF_RS_VLCHEQUE'].';'.$arrRegist['0854']['DIF_PC_VLCHEQUE']."\r\n";
    $str .= 'CECRED;Saída;NR DOC;'.$arrRegist['0854']['VLTOTDOC'].';'.$arrRegist['0852']['VLTOTDOC'].';'.$arrRegist['0854']['DIF_RS_VLTOTDOC'].';'.$arrRegist['0854']['DIF_PC_VLTOTDOC']."\r\n";
    $str .= 'CECRED;Saída;NR TED/TEC;'.$arrRegist['0854']['VLTOTTED'].';'.$arrRegist['0852']['VLTOTTED'].';'.$arrRegist['0854']['DIF_RS_VLTOTTED'].';'.$arrRegist['0854']['DIF_PC_VLTOTTED']."\r\n";
    $str .= 'CECRED;Saída;NR TÍTULOS;'.$arrRegist['0854']['VLTOTTIT'].';'.$arrRegist['0852']['VLTOTTIT'].';'.$arrRegist['0854']['DIF_RS_VLTOTTIT'].';'.$arrRegist['0854']['DIF_PC_VLTOTTIT']."\r\n";
    $str .= 'CECRED;Saída;DEV. CHEQUE RECEBIDO;'.$arrRegist['0854']['VLDEVOLU'].';'.$arrRegist['0852']['VLDEVOLU'].';'.$arrRegist['0854']['DIF_RS_VLDEVOLU'].';'.$arrRegist['0854']['DIF_PC_VLDEVOLU']."\r\n";
    $str .= 'CECRED;Saída;TRANSF INTER;'.$arrRegist['0854']['VLTRFITC'].';'.$arrRegist['0852']['VLTRFITC'].';'.$arrRegist['0854']['DIF_RS_VLTRFITC'].';'.$arrRegist['0854']['DIF_PC_VLTRFITC']."\r\n";
    $str .= 'CECRED;Saída;DEP INTER;'.$arrRegist['0854']['VLDEPITC'].';'.$arrRegist['0852']['VLDEPITC'].';'.$arrRegist['0854']['DIF_RS_VLDEPITC'].';'.$arrRegist['0854']['DIF_PC_VLDEPITC']."\r\n";
    $str .= 'CECRED;Saída;SAQUE TAA INTERC;'.$arrRegist['0854']['VLSATAIT'].';'.$arrRegist['0852']['VLSATAIT'].';'.$arrRegist['0854']['DIF_RS_VLSATAIT'].';'.$arrRegist['0854']['DIF_PC_VLSATAIT']."\r\n";
    $str .= 'CECRED;Saída;CARTÃO DE CRÉDITO;'.$arrRegist['0854']['VLCARCRE'].';'.$arrRegist['0852']['VLCARCRE'].';'.$arrRegist['0854']['DIF_RS_VLCARCRE'].';'.$arrRegist['0854']['DIF_PC_VLCARCRE']."\r\n";
    $str .= 'CECRED;Saída;SUPRIMENTO NUMERÁRIO;'.$arrRegist['0854']['VLNUMERA'].';'.$arrRegist['0852']['VLNUMERA'].';'.$arrRegist['0854']['DIF_RS_VLNUMERA'].';'.$arrRegist['0854']['DIF_PC_VLNUMERA']."\r\n";
    $str .= 'CECRED;Saída;CONVÊNIOS;'.$arrRegist['0854']['VLCONVEN'].';'.$arrRegist['0852']['VLCONVEN'].';'.$arrRegist['0854']['DIF_RS_VLCONVEN'].';'.$arrRegist['0854']['DIF_PC_VLCONVEN']."\r\n";

    $str .= 'BANCO DO BRASIL;Saída;NR TÍTULOS;'.$arrRegist['0014']['VLTOTTIT'].';'.$arrRegist['0012']['VLTOTTIT'].';'.$arrRegist['0014']['DIF_RS_VLTOTTIT'].';'.$arrRegist['0014']['DIF_PC_VLTOTTIT']."\r\n";
    $str .= 'BANCO DO BRASIL;Saída;MVTO CONTA ITG;'.$arrRegist['0014']['VLMVTITG'].';'.$arrRegist['0012']['VLMVTITG'].';'.$arrRegist['0014']['DIF_RS_VLMVTITG'].';'.$arrRegist['0014']['DIF_PC_VLMVTITG']."\r\n";

    $str .= 'BANCOOB;Saída;CARTÃO DE CRÉDITO;'.$arrRegist['7564']['VLCARCRE'].';'.$arrRegist['7562']['VLCARCRE'].';'.$arrRegist['7564']['DIF_RS_VLCARCRE'].';'.$arrRegist['7564']['DIF_PC_VLCARCRE']."\r\n";
    $str .= 'BANCOOB;Saída;CARTÃO DE DÉBITO;'.$arrRegist['7564']['VLCARDEB'].';'.$arrRegist['7562']['VLCARDEB'].';'.$arrRegist['7564']['DIF_RS_VLCARDEB'].';'.$arrRegist['7564']['DIF_PC_VLCARDEB']."\r\n";
    $str .= 'BANCOOB;Saída;GPS;'.$arrRegist['7564']['VLTTINSS'].';'.$arrRegist['7562']['VLTTINSS'].';'.$arrRegist['7564']['DIF_RS_VLTTINSS'].';'.$arrRegist['7564']['DIF_PC_VLTTINSS']."\r\n";

    $str .= 'SICREDI;Saída;GPS;'.$arrRegist['7484']['VLTTINSS'].';'.$arrRegist['7482']['VLTTINSS'].';'.$arrRegist['7484']['DIF_RS_VLTTINSS'].';'.$arrRegist['7484']['DIF_PC_VLTTINSS']."\r\n";
    $str .= 'SICREDI;Saída;CONVÊNIOS;'.$arrRegist['7484']['VLCONVEN'].';'.$arrRegist['7482']['VLCONVEN'].';'.$arrRegist['7484']['DIF_RS_VLCONVEN'].';'.$arrRegist['7484']['DIF_PC_VLCONVEN']."\r\n";

    $nmrescop = strtolower(getByTagName($reg_total->tags,'NMRESCOP'));
    $ardatini = explode('/', $dtrefini);
    $ardatfim = explode('/', $dtreffim);
    $dtnomini = date("dmy", strtotime($ardatini[2].'-'.$ardatini[1].'-'.$ardatini[0]));
    $dtnomfim = date("dmy", strtotime($ardatfim[2].'-'.$ardatfim[1].'-'.$ardatfim[0]));
    $filename = 'fluxo_'.$nmrescop.'_'.$dtnomini.'_'.$dtnomfim.'.csv';

    header('Content-type: text/csv');
    header('Content-Disposition: attachment; filename="'.$filename.'"');

    echo $str;
?>