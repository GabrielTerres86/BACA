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
    $tpfluxo_e = (isset($_POST['tpfluxo_e'])) ? $_POST['tpfluxo_e'] : '' ;
    $tpfluxo_s = (isset($_POST['tpfluxo_s'])) ? $_POST['tpfluxo_s'] : '' ;
    $flremdina = (isset($_POST['flremdina'])) ? $_POST['flremdina'] : '' ;
    $strReHiFl = (isset($_POST['strReHiFl'])) ? $_POST['strReHiFl'] : '' ;

    $cdcooper  = (isset($_POST['cdcooper'])) ? $_POST['cdcooper']   : 0 ;
    $dshora    = (isset($_POST['dshora']))   ? $_POST['dshora']     : '' ;
    $inallcop  = (isset($_POST['inallcop'])) ? $_POST['inallcop']   : 0 ;

    $margem_doc = (isset($_POST['margem_doc'])) ? $_POST['margem_doc'] : 0 ;
    $margem_chq = (isset($_POST['margem_chq'])) ? $_POST['margem_chq'] : 0 ;
    $margem_tit = (isset($_POST['margem_tit'])) ? $_POST['margem_tit'] : 0 ;
    $devolu_chq = (isset($_POST['devolu_chq'])) ? $_POST['devolu_chq'] : 0 ;

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
    } else if ($cddopcao == 'R') {
        // Verifica se pode salvar os dados
        if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'S',false)) <> '') {
            exibirErro('error',$msgError,'Alerta - Ayllos','',false);
        }
        $nmdeacao = 'PARFLU_GRAVA_HISTOR';
    } else if ($cddopcao == 'H') {
        $nmdeacao = 'PARFLU_GRAVA_HORARIO';
    } else if ($cddopcao == 'M') {
        $nmdeacao = 'PARFLU_GRAVA_MARGEM';
    }

    // Montar o xml de Requisicao
	$xmlCarregaDados  = "";
	$xmlCarregaDados .= "<Root>";
	$xmlCarregaDados .= " <Dados>";
	// OPCAO C
	$xmlCarregaDados .= "   <cdconta>".$cdconta."</cdconta>";
	$xmlCarregaDados .= "   <nmconta>".utf8_decode($nmconta)."</nmconta>";
	$xmlCarregaDados .= "   <dspercen>".$dspercen."</dspercen>";
	// OPCAO R
	$xmlCarregaDados .= "   <cdremessa>".$cdremessa."</cdremessa>";
	$xmlCarregaDados .= "   <nmremessa>".$nmremessa."</nmremessa>";
    $xmlCarregaDados .= "   <tpfluxo_e>".$tpfluxo_e."</tpfluxo_e>";
    $xmlCarregaDados .= "   <tpfluxo_s>".$tpfluxo_s."</tpfluxo_s>";
    $xmlCarregaDados .= "   <flremdina>".$flremdina."</flremdina>";
	$xmlCarregaDados .= "   <strrehifl>".$strReHiFl."</strrehifl>";
	// OPCAO H
	$xmlCarregaDados .= "   <cdcooper>".$cdcooper."</cdcooper>";
	$xmlCarregaDados .= "   <dshora>".$dshora."</dshora>";
	$xmlCarregaDados .= "   <inallcop>".$inallcop."</inallcop>";
	// OPCAO M
	$xmlCarregaDados .= "   <margem_doc>".$margem_doc."</margem_doc>";
	$xmlCarregaDados .= "   <margem_chq>".$margem_chq."</margem_chq>";
	$xmlCarregaDados .= "   <margem_tit>".$margem_tit."</margem_tit>";
	$xmlCarregaDados .= "   <devolu_chq>".$devolu_chq."</devolu_chq>";
	// Fecha o xml de Requisicao
	$xmlCarregaDados .= " </Dados>";
	$xmlCarregaDados .= "</Root>";

	$xmlResult = mensageria($xmlCarregaDados, "TELA_PARFLU", $nmdeacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObject = getObjectXML($xmlResult);

	echo 'hideMsgAguardo();';
    
    if (strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO') {
        $msgErro = $xmlObject->roottag->tags[0]->cdata;
        if ($msgErro == '') {
            $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
        }
        exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
    }

    echo "showError('inform','Dados gravados com sucesso!','PARFLU','fechaRotina($(\'#divRotina\'));estadoInicial();');";
?>