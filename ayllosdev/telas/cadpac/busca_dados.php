<?php
/*!
 * FONTE        : busca_dados.php
 * CRIAÇÃO      : Jaison
 * DATA CRIAÇÃO : 05/07/2016
 * OBJETIVO     : Rotina para buscar os dados
 * --------------
 * ALTERAÇÕES   : 08/08/2017 - Adicionado busca de novo campo flgutcrm da tela. (Reinert - Projeto 339)
 * --------------
 *				  08/08/2017 - Implementacao da melhoria 438. Heitor (Mouts).
 *
 *                19/12/2017 - Incluido campos FGTS. PRJ406 -FGTS(Odirlei-AMcom)
 *
 *                03/01/2018 - M307 Solicitação de senha e limite para pagamento (Diogo / MoutS)
 */

    session_start();
    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php');	
    require_once('../../class/xmlfile.php');
    isPostMethod();

    // Guardo os parâmetos do POST em variáveis	
    $cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'C';
    $cdagenci = (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : 0;
    $dsdepart = $glbvars["dsdepart"];

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

    $xml  = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
    $xml .= "   <cdagenci>".$cdagenci."</cdagenci>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_CADPAC", "CADPAC_BUSCA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObject = getObjectXML($xmlResult);

    if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
        $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
        exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial()', false);
    }

    $registros = $xmlObject->roottag->tags[0];

    echo "$('#nmresage', '#frmCadpac').val('".getByTagName($registros->tags,'NMRESAGE')."');";
    
    if ($cddopcao == 'C' || $cddopcao == 'A') {
        echo "$('#nmextage', '#frmCadpac').val('".getByTagName($registros->tags,'NMEXTAGE')."');";
        echo "$('#insitage', '#frmCadpac').val('".getByTagName($registros->tags,'INSITAGE')."');";
        echo "$('#cdcxaage', '#frmCadpac').val('".getByTagName($registros->tags,'CDCXAAGE')."');";
        echo "$('#tpagenci', '#frmCadpac').val('".getByTagName($registros->tags,'TPAGENCI')."');";
        echo "$('#cdccuage', '#frmCadpac').val('".getByTagName($registros->tags,'CDCCUAGE')."');";
        echo "$('#cdorgpag', '#frmCadpac').val('".getByTagName($registros->tags,'CDORGPAG')."');";
        echo "$('#cdagecbn', '#frmCadpac').val('".getByTagName($registros->tags,'CDAGECBN')."');";
        echo "$('#cdcomchq', '#frmCadpac').val('".getByTagName($registros->tags,'CDCOMCHQ')."');";
        echo "$('#vercoban', '#frmCadpac').val('".getByTagName($registros->tags,'VERCOBAN')."');";
        echo "$('#cdbantit', '#frmCadpac').val('".getByTagName($registros->tags,'CDBANTIT')."');";
        echo "$('#cdagetit', '#frmCadpac').val('".getByTagName($registros->tags,'CDAGETIT')."');";
        echo "$('#cdbanchq', '#frmCadpac').val('".getByTagName($registros->tags,'CDBANCHQ')."');";
        echo "$('#cdagechq', '#frmCadpac').val('".getByTagName($registros->tags,'CDAGECHQ')."');";
        echo "$('#cdbandoc', '#frmCadpac').val('".getByTagName($registros->tags,'CDBANDOC')."');";
        echo "$('#cdagedoc', '#frmCadpac').val('".getByTagName($registros->tags,'CDAGEDOC')."');";
        echo "$('#flgdsede', '#frmCadpac').val('".getByTagName($registros->tags,'FLGDSEDE')."');";
        echo "$('#cdagepac', '#frmCadpac').val('".getByTagName($registros->tags,'CDAGEPAC')."');";
        echo "$('#flgutcrm', '#frmCadpac').val('".getByTagName($registros->tags,'FLGUTCRM')."');";
        echo "$('#cdagefgt', '#frmCadpac').val('".getByTagName($registros->tags,'CDAGEFGT')."');";
        echo "$('#dsendcop', '#frmCadpac').val('".getByTagName($registros->tags,'DSENDCOP')."');";
        echo "$('#nrendere', '#frmCadpac').val('".getByTagName($registros->tags,'NRENDERE')."');";
        echo "$('#nmbairro', '#frmCadpac').val('".getByTagName($registros->tags,'NMBAIRRO')."');";
        echo "$('#dscomple', '#frmCadpac').val('".getByTagName($registros->tags,'DSCOMPLE')."');";
        echo "$('#nrcepend', '#frmCadpac').val('".getByTagName($registros->tags,'NRCEPEND')."');";
        echo "$('#idcidade', '#frmCadpac').val('".getByTagName($registros->tags,'IDCIDADE')."');";
        echo "$('#dscidade', '#frmCadpac').val('".getByTagName($registros->tags,'NMCIDADE')."');";
        echo "$('#cdestado', '#frmCadpac').val('".getByTagName($registros->tags,'CDUFDCOP')."');";
        echo "$('#dsdemail', '#frmCadpac').val('".getByTagName($registros->tags,'DSDEMAIL')."');";
        echo "$('#dsmailbd', '#frmCadpac').val('".getByTagName($registros->tags,'DSMAILBD')."');";
        echo "$('#dsinform1', '#frmCadpac').val('".getByTagName($registros->tags,'DSINFORM1')."');";
        echo "$('#dsinform2', '#frmCadpac').val('".getByTagName($registros->tags,'DSINFORM2')."');";
        echo "$('#dsinform3', '#frmCadpac').val('".getByTagName($registros->tags,'DSINFORM3')."');";
        echo "$('#hhsicini', '#frmCadpac').val('".getByTagName($registros->tags,'HHSICINI')."');";
        echo "$('#hhsicfim', '#frmCadpac').val('".getByTagName($registros->tags,'HHSICFIM')."');";
        echo "$('#hhini_bancoob', '#frmCadpac').val('".getByTagName($registros->tags,'HHINI_BANCOOB')."');";
        echo "$('#hhfim_bancoob', '#frmCadpac').val('".getByTagName($registros->tags,'HHFIM_BANCOOB')."');";
        echo "$('#hhtitini', '#frmCadpac').val('".getByTagName($registros->tags,'HHTITINI')."');";
        echo "$('#hhtitfim', '#frmCadpac').val('".getByTagName($registros->tags,'HHTITFIM')."');";
        echo "$('#hhcompel', '#frmCadpac').val('".getByTagName($registros->tags,'HHCOMPEL')."');";
        echo "$('#hhcapini', '#frmCadpac').val('".getByTagName($registros->tags,'HHCAPINI')."');";
        echo "$('#hhcapfim', '#frmCadpac').val('".getByTagName($registros->tags,'HHCAPFIM')."');";
        echo "$('#hhdoctos', '#frmCadpac').val('".getByTagName($registros->tags,'HHDOCTOS')."');";
        echo "$('#hhtrfini', '#frmCadpac').val('".getByTagName($registros->tags,'HHTRFINI')."');";
        echo "$('#hhtrffim', '#frmCadpac').val('".getByTagName($registros->tags,'HHTRFFIM')."');";
        echo "$('#hhguigps', '#frmCadpac').val('".getByTagName($registros->tags,'HHGUIGPS')."');";
        echo "$('#hhbolini', '#frmCadpac').val('".getByTagName($registros->tags,'HHBOLINI')."');";
        echo "$('#hhbolfim', '#frmCadpac').val('".getByTagName($registros->tags,'HHBOLFIM')."');";
        echo "$('#hhenvelo', '#frmCadpac').val('".getByTagName($registros->tags,'HHENVELO')."');";
        echo "$('#hhcpaini', '#frmCadpac').val('".getByTagName($registros->tags,'HHCPAINI')."');";
        echo "$('#hhcpafim', '#frmCadpac').val('".getByTagName($registros->tags,'HHCPAFIM')."');";
        echo "$('#hhlimcan', '#frmCadpac').val('".getByTagName($registros->tags,'HHLIMCAN')."');";
        echo "$('#hhsiccan', '#frmCadpac').val('".getByTagName($registros->tags,'HHSICCAN')."');";
        echo "$('#hhcan_bancoob', '#frmCadpac').val('".getByTagName($registros->tags,'HHCAN_BANCOOB')."');";
        echo "$('#nrtelvoz', '#frmCadpac').val('".getByTagName($registros->tags,'NRTELVOZ')."');";
        echo "$('#nrtelfax', '#frmCadpac').val('".getByTagName($registros->tags,'NRTELFAX')."');";
        echo "$('#qtddaglf', '#frmCadpac').val('".getByTagName($registros->tags,'QTDDAGLF')."');";
        echo "$('#qtmesage', '#frmCadpac').val('".getByTagName($registros->tags,'QTMESAGE')."');";
        echo "$('#qtddlslf', '#frmCadpac').val('".getByTagName($registros->tags,'QTDDLSLF')."');";
        echo "$('#flsgproc', '#frmCadpac').val('".getByTagName($registros->tags,'FLSGPROC')."');";
        echo "$('#vllimapv', '#frmCadpac').val('".getByTagName($registros->tags,'VLLIMAPV')."');";
        echo "$('#qtchqprv', '#frmCadpac').val('".getByTagName($registros->tags,'QTCHQPRV')."');";
        echo "$('#flgdopgd', '#frmCadpac').val('".getByTagName($registros->tags,'FLGDOPGD')."');";
        echo "$('#cdageagr', '#frmCadpac').val('".getByTagName($registros->tags,'CDAGEAGR')."');";
        echo "$('#cddregio', '#frmCadpac').val('".getByTagName($registros->tags,'CDDREGIO')."');";
        echo "$('#dsdregio', '#frmCadpac').val('".getByTagName($registros->tags,'DSDREGIO')."');";
        echo "$('#tpageins', '#frmCadpac').val('".getByTagName($registros->tags,'TPAGEINS')."');";
        echo "$('#cdorgins', '#frmCadpac').val('".getByTagName($registros->tags,'CDORGINS')."');";
        echo "$('#vlminsgr', '#frmCadpac').val('".getByTagName($registros->tags,'VLMINSGR')."');";
        echo "$('#vlmaxsgr', '#frmCadpac').val('".getByTagName($registros->tags,'VLMAXSGR')."');";
		echo "$('#flmajora', '#frmCadpac').val('".getByTagName($registros->tags,'FLMAJORA')."');";
        echo "$('#vllimpag', '#frmCadpac').val('".getByTagName($registros->tags,'VLLIMPAG')."');";
    }

    if ($cddopcao == 'C') {
        echo "trocaBotao('','','carregaTelaCadpac()');";
    } else {
        echo "controlaPesquisas();";
        echo "trocaBotao('Gravar','confirmaAcao()','carregaTelaCadpac()');";
    }

    if ($cddopcao == 'C' || $cddopcao == 'I' || $cddopcao == 'A') {
        echo "acessaOpcaoAba(0);"; // Carrega aba inicial
        echo "$('#divTabCampos', '#frmCadpac').show();"; // Exibe os campos

        if ($cddopcao == 'C') {
            echo "$('input, select', '#frmCadpac').desabilitaCampo();";
        } else {
            echo "$('input, select', '#frmCadpac').habilitaCampo();";
            echo "$('#cdagenci, #dsdregio, #dscidade', '#frmCadpac').desabilitaCampo();";
            echo "$('#nmresage', '#frmCadpac').focus();";

            // Se NAO for COMPE e TI
            if ($dsdepart <> "COMPE" && $dsdepart <> "TI") {
                echo "$('#hhsicini, #hhsicfim, #hhsiccan', '#frmCadpac').desabilitaCampo();";
            }

            // Se NAO for INTERNET BANK e TAA
            if ($cdagenci <> 90 && $cdagenci <> 91) {
                echo "$('#hhtitini, #hhtitfim, #hhcompel', '#frmCadpac').desabilitaCampo();";
                echo "$('#hhcapini, #hhcapfim, #hhdoctos', '#frmCadpac').desabilitaCampo();";
                echo "$('#hhtrfini, #hhtrffim, #hhguigps', '#frmCadpac').desabilitaCampo();";
                echo "$('#hhbolini, #hhbolfim', '#frmCadpac').desabilitaCampo();";
                echo "$('#hhcpaini, #hhcpafim', '#frmCadpac').desabilitaCampo();";
                echo "$('#hhlimcan, #qtddaglf, #qtddlslf, #flsgproc', '#frmCadpac').desabilitaCampo();";
            }

            if ($cddopcao == 'A') {
                // Se NAO for COMPE
                if ($dsdepart <> "COMPE") {
                    echo "$('#cdagepac', '#frmCadpac').desabilitaCampo();";
                }
            }
        }
    } elseif ($cddopcao == 'B') {
         echo "$('#fieldOpcaoB', '#frmCadpac').show();"; // Exibe
         echo "$('#cdagenci', '#frmCadpac').desabilitaCampo();";
         echo "$('#nrdcaixa', '#frmCadpac').focus();";
         echo "trocaBotao('Continuar','validarCaixa()','carregaTelaCadpac()');";
    } elseif ($cddopcao == 'X') {
         echo "$('#fieldOpcaoX', '#frmCadpac').show();"; // Exibe
         echo "$('#vllimapv_x', '#frmCadpac').val('".getByTagName($registros->tags,'VLLIMAPV')."');";
         echo "$('#cdagenci', '#frmCadpac').desabilitaCampo();";
         echo "$('#vllimapv_x', '#frmCadpac').focus();";
    } elseif ($cddopcao == 'S') {
         echo "$('#fieldOpcaoS', '#frmCadpac').show();"; // Exibe
         echo "$('#nmpasite', '#frmCadpac').val('".getByTagName($registros->tags,'NMPASITE')."');";
         echo "$('#dstelsit', '#frmCadpac').val('".getByTagName($registros->tags,'DSTELSIT')."');";
         echo "$('#dsemasit', '#frmCadpac').val('".getByTagName($registros->tags,'DSEMASIT')."');";
         echo "$('#dshorsit', '#frmCadpac').val('".preg_replace('/\r\n|\r|\n/','\n',getByTagName($registros->tags,'DSHORSIT'))."');";
         echo "$('#nrlatitu', '#frmCadpac').val('".getByTagName($registros->tags,'NRLATITU')."');";
         echo "$('#nrlongit', '#frmCadpac').val('".getByTagName($registros->tags,'NRLONGIT')."');";
         echo "$('#cdagenci', '#frmCadpac').desabilitaCampo();";
         echo "$('#nmpasite', '#frmCadpac').focus();";
    }
?>