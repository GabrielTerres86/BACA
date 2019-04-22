<?php
/* !
 * FONTE        : ajax_definicao.php
 * CRIAÇÃO      : Carlos Rafael 
 * DATA CRIAÇÃO : 12/08/2014
 * OBJETIVO     : Ajax de consulta para tela PCAPTA - definicoes
 * --------------
 * ALTERAÇÕES   : 08/10/2018 Inclusao da configuração das Apl. Programadas - Proj. 411.2 (CIS Corporate)
 *
 * --------------
 */
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

$glbvars["nmrotina"] = 'DEFINICAO';

$retorno = array();
$erro = 'N';
$msgErro = '';
$flgopcao = (isset($_POST["flgopcao"])) ? trim($_POST["flgopcao"]) : '';

if  ( $flgopcao == 'CM' ) { //consulta Modalidades
    // Verifica se os parametros necessarios foram informados
    $cdprodut = (isset($_POST["cdprodut"])) ? $_POST["cdprodut"] : 0;
    $cdcooper = (isset($_POST["cdcooper"])) ? $_POST["cdcooper"] : 0;
    $nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 1;
    $nrregist = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 20;
    $subopcao = (isset($_POST["subopcao"])) ? $_POST["subopcao"] : 'C';
    $idtxfixa = (isset($_POST["idtxfixa"])) ? $_POST["idtxfixa"] : 0;
    
    if ( $cdprodut > 0 && $cdcooper > 0 ) {
        
        $idsitmod = 0;
        if ( $subopcao == 'B' ) {
            $idsitmod = 1;
        } else if ( $subopcao == 'D' ) {
            $idsitmod = 2;
        }
        
        // Montar o xml de Requisicao
        $xml .= "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <cdprodut>" . $cdprodut . "</cdprodut>";
        $xml .= "   <cdcooper>" . $cdcooper . "</cdcooper>";
	    $xml .= "   <idsitmod>" . $idsitmod . "</idsitmod>";
    	$xml .= "   <nrregist>" . $nrregist . "</nrregist>";        
	    $xml .= "   <nriniseq>" . $nriniseq . "</nriniseq>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml, "PCAPTA", "CMODPRO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getObjectXML($xmlResult);

        if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {           
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
            if ($msgErro == null || $msgErro == '') {
                $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
            }
            exibirErro('error', $msgErro, 'Alerta - Ayllos', '', true);
        } else {
            $registros = $xmlObj->roottag->tags[0]->tags;
            $qtdregist = $xmlObj->roottag->tags[1]->cdata;
            
            include('tab_definicao.php');
        }   
    }   
    return false;
    
} else if  ( $flgopcao == 'CP' ) { //carrega Politicas
    // Verifica se os parametros necessarios foram informados
    $cdprodut = (isset($_POST["cdprodut"])) ? $_POST["cdprodut"] : 0;
    $cdcooper = (isset($_POST["cdcooper"])) ? $_POST["cdcooper"] : 0;
    $nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 1;
    $nrregist = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 20;
    $subopcao = (isset($_POST["subopcao"])) ? $_POST["subopcao"] : 'C';
    $idtxfixa = (isset($_POST["idtxfixa"])) ? $_POST["idtxfixa"] : 0;
    
    if ( $cdprodut > 0 && $cdcooper > 0 ) {
        // Montar o xml de Requisicao
        $xml .= "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <cdprodut>" . $cdprodut . "</cdprodut>";
        $xml .= "   <cdcooper>" . $cdcooper . "</cdcooper>";
	    $xml .= "   <nrregist>" . $nrregist . "</nrregist>";
	    $xml .= "   <nriniseq>" . $nriniseq . "</nriniseq>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml, "PCAPTA", "CPOLCOP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getObjectXML($xmlResult);

        if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {           
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
            if ($msgErro == null || $msgErro == '') {
                $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
            }
            exibirErro('error', $msgErro, 'Alerta - Ayllos', '', true);
        } else {
            $registros = $xmlObj->roottag->tags[0]->tags;
            $qtdregist = $xmlObj->roottag->tags[1]->cdata;
            include('tab_definicao.php');
        }   
    }   
    return false;
    
} else if  ( $flgopcao == 'C' ) { //consulta Taxa Fixa
    // Verifica se os parametros necessarios foram informados
    $cdprodut = (isset($_POST["cdprodut"])) ? $_POST["cdprodut"] : 0;
    $cdcooper = (isset($_POST["cdcooper"])) ? $_POST["cdcooper"] : 0;


    if ( $cdprodut >0 && $cdcooper>0) {

        // Montar o xml de Requisicao
        $xml .= "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <cdprodut>" . $cdprodut . "</cdprodut>";
        $xml .= "   <idsitpro>0</idsitpro>";        
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml, "PCAPTA", "CPRODU", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getObjectXML($xmlResult);

        if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {           
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
            if ($msgErro == null || $msgErro == '') {
                $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
            }
            exibirErro('error', $msgErro, 'Alerta - Ayllos', '', true);
        } else {
            $registros = $xmlObj->roottag->tags;
            $vidtxfixa = $registros[0]->tags[5]->cdata;  //retorna taxa fixa 
            $vnmdindex = $registros[0]->tags[7]->cdata; //nome do indexador
            $vindplano = $registros[0]->tags[8]->cdata; //apl. programada. 1 = sim, 2 = nao
        };
        if ($vindplano == '1') {//Aplicacao Programada
            $xmlAP .= "<Root>";
            $xmlAP .= " <Dados>";
            $xmlAP .= "   <cdcooper_b>" . $cdcooper . "</cdcooper_b>";
            $xmlAP .= "   <cdprodut>"   . $cdprodut . "</cdprodut>";
            $xmlAP .= " </Dados>";
            $xmlAP .= "</Root>";

            $xmlResultAP = mensageria($xmlAP, "APLI0008", "OBTEM_CONFIG_APL_PROG", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
            $xmlObjAP = getObjectXML($xmlResultAP);
            if (strtoupper($xmlObjAP->roottag->tags[0]->name == 'ERRO')) {           
                $msgErro = $xmlObjAP->roottag->tags[0]->cdata;
                if ($msgErro == null || $msgErro == '') {
                    $msgErro = $xmlObjAP->roottag->tags[0]->tags[0]->tags[4]->cdata;
                }
                if ($msgErro != 'Configuração não encontrada') { // Continuar pois "ainda" não há configuracao
                    exibirErro('error', $msgErro, 'Alerta - Aiyllos', '', true);
                } else {
                    $retorno[] = array(
                        'idtxfixa'       => $vidtxfixa, //retorna taxa fixa 
                        'nmdindex'       => $vnmdindex , //nome do indexador
                        'indplano'       => $vindplano, //apl. programada. 1 = sim, 2 = nao
                        'teimosinha'     => '0', //Teimosinha  (0 = indefinido, 1 = sim, 2 = nao)
                        'debito_parcial' => '0', //Debito Parcial (0 = indefinido, 1 = sim, 2 = nao)
                        'vlminimo'       => '', //Valor mínimo para debito parcial
                        'autoatendimento'=> '0', //Liberado no autoatendimento (0 = indefinido, 1 = sim, 2 = nao)
                        'resgate_programado'=> '0', //Resgate programado  (0 = indefinido, 1 = sim, 2 = nao)
                        'existe_config'  => '2' // Existe a configuracao ( 1 = sim, 2 = nao)
                        );
                     
                } 
            } else { // Nao encontrou erro
                $registrosAP    = $xmlObjAP->roottag->tags[0]->tags;
                $teimosinha         = $registrosAP[0]->tags[1]->cdata;  // Teimosinha  (1 = sim, 2 = nao) 
                $debito_parcial     = $registrosAP[0]->tags[2]->cdata;  // Debito Parcial (1 = sim, 2 = nao)
                $vlminimo           = $registrosAP[0]->tags[3]->cdata;  // Valor mínimo para debito parcial
                $autoatendimento    = $registrosAP[0]->tags[4]->cdata;  // Liberado no autoatendimento (1 = sim, 2 = nao)
                $resgate_programado = $registrosAP[0]->tags[5]->cdata;  // Resgate programado  (0 = indefinido, 1 = sim, 2 = nao)
                $retorno[] = array(
                    'idtxfixa'       => $vidtxfixa, 
                    'nmdindex'       => $vnmdindex , 
                    'indplano'       => $vindplano, 
                    'teimosinha'     => $teimosinha,            // Teimosinha  (0 = indefinido, 1 = sim, 2 = nao)
                    'debito_parcial' => $debito_parcial,        // Debito Parcial (0 = indefinido, 1 = sim, 2 = nao)
                    'vlminimo'       => $vlminimo,              // Valor mínimo para debito parcial
                    'autoatendimento'=> $autoatendimento,       // Liberado no autoatendimento (0 = indefinido, 1 = sim, 2 = nao)
                    'resgate_programado'=> $resgate_programado, // Resgate programado  (0 = indefinido, 1 = sim, 2 = nao)
                    'existe_config'  => '1'                     // Existe a configuraao ( 1 = sim, 2 = nao)
                    );
            }
        } else {  // Apl . nao e do tipo pgoramada
                $retorno[] = array(
                    'idtxfixa'       => $vidtxfixa,  //retorna taxa fixa 
                    'nmdindex'       => $vnmdindex , //nome do indexador
                    'indplano'       => $vindplano   //apl. programada. 1 = sim, 2 = nao
                    );

        }

    }
} else if  ( $flgopcao == 'CONCAR' ) { // consulta dias de carencia

    $cdprodut = (isset($_POST["cdprodut"])) ? $_POST["cdprodut"] : 0;

    // Montar o xml de Requisicao
    $xml .= "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <cdprodut>" . $cdprodut . "</cdprodut>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "PCAPTA", "CMODCAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);
    
    if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
        if ($msgErro == null || $msgErro == '') {
            $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        }
        exibirErro('error', $msgErro, 'Alerta - Ayllos', '', true);
    } else {
        $registros = $xmlObj->roottag->tags;

        if ( $cdprodut > 0 ) {
            foreach ($registros as $registro) {
                $retorno[] = array(
                    'qtdiacar' => $registro->tags[0]->cdata
                );
            }            
        }
    }    
    
} else if  ( $flgopcao == 'CONPRA' ) { // consulta prazo
    
    $cdprodut = (isset($_POST["cdprodut"])) ? $_POST["cdprodut"] : 0;
    $qtdiacar = (isset($_POST["qtdiacar"])) ? $_POST["qtdiacar"] : 0;

    // Montar o xml de Requisicao
    $xml .= "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <cdprodut>" . $cdprodut . "</cdprodut>";
    $xml .= "   <qtdiacar>" . $qtdiacar . "</qtdiacar>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "PCAPTA", "CMODPRA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);
    
    if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {        
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
        if ($msgErro == null || $msgErro == '') {
            $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        }
        exibirErro('error', $msgErro, 'Alerta - Ayllos', '', true);
    } else {
        $registros = $xmlObj->roottag->tags;

        if ( $cdprodut > 0 ) {
            foreach ($registros as $registro) {
                $retorno[] = array(
                    'qtdiaprz' => $registro->tags[0]->cdata
                );
            }            
        }
    }    
} else if  ( $flgopcao == 'CONFAI' ) { // consulta faixa
    
    $cdprodut = (isset($_POST["cdprodut"])) ? $_POST["cdprodut"] : 0;
    $qtdiacar = (isset($_POST["qtdiacar"])) ? $_POST["qtdiacar"] : 0;
    $qtdiaprz = (isset($_POST["qtdiaprz"])) ? $_POST["qtdiaprz"] : 0;

    // Montar o xml de Requisicao
    $xml .= "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <cdprodut>" . $cdprodut . "</cdprodut>";
    $xml .= "   <qtdiacar>" . $qtdiacar . "</qtdiacar>";
    $xml .= "   <qtdiaprz>" . $qtdiaprz . "</qtdiaprz>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "PCAPTA", "CMODVFA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);
    
    if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
        if ($msgErro == null || $msgErro == '') {
            $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        }
        exibirErro('error', $msgErro, 'Alerta - Ayllos', '', true);
    } else {
        $registros = $xmlObj->roottag->tags;

        if ( $cdprodut > 0 ) {
            foreach ($registros as $registro) {
                $retorno[] = array(
                    'vlrfaixa' => $registro->tags[0]->cdata
                );
            }            
        }
    }    
} else if  ( $flgopcao == 'CONPERTAX' ) { // consulta faixa
    
    $cdprodut = (isset($_POST["cdprodut"])) ? $_POST["cdprodut"] : 0;
    $qtdiacar = (isset($_POST["qtdiacar"])) ? $_POST["qtdiacar"] : 0;
    $qtdiaprz = (isset($_POST["qtdiaprz"])) ? $_POST["qtdiaprz"] : 0;
    $vlrfaixa = (isset($_POST["vlrfaixa"])) ? $_POST["vlrfaixa"] : 0;

    // Montar o xml de Requisicao
    $xml .= "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <cdprodut>" . $cdprodut . "</cdprodut>";
    $xml .= "   <qtdiacar>" . $qtdiacar . "</qtdiacar>";
    $xml .= "   <qtdiaprz>" . $qtdiaprz . "</qtdiaprz>";
    $xml .= "   <vlrfaixa>" . $vlrfaixa . "</vlrfaixa>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "PCAPTA", "CMODPERTAX", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);
    
    if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
        if ($msgErro == null || $msgErro == '') {
            $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        }
        exibirErro('error', $msgErro, 'Alerta - Ayllos', '', true);
    } else {
        $registros = $xmlObj->roottag->tags;

        if ( $cdprodut > 0 ) {
            foreach ($registros as $registro) {
                $retorno[] = array(
                    'cdmodali' => $registro->tags[0]->cdata,
                    'vlperren' => $registro->tags[1]->cdata,
                    'vltxfixa' => $registro->tags[2]->cdata
                );
            }            
        }
    }    
    
} else if  ( $flgopcao == 'V' ) { // validar
    
    // Verifica se os parametros necessarios foram informados
    if (!isset($_POST["cdcooper"]) || !isset($_POST["cdmodali"])) { 
        $msgErro = 'Par&acirc;metros incorretos.';
        $erro = 'S';               
    } else {
        $cdcooper = (isset($_POST["cdcooper"])) ? $_POST["cdcooper"] : 0;
        $cdmodali = (isset($_POST["cdmodali"])) ? $_POST["cdmodali"] : 0;
    }

    if ( $erro == 'N' ) {
        // Montar o xml de Requisicao
        $xml .= "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <cddopcao>V</cddopcao>";
        $xml .= "   <cdcooper>" . $cdcooper . "</cdcooper>";
        $xml .= "   <cdmodali>" . $cdmodali . "</cdmodali>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml, "PCAPTA", "MANMODCOP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getObjectXML($xmlResult);

        if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
            if ($msgErro == null || $msgErro == '') {
                $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
            }
            exibirErro('error', $msgErro, 'Alerta - Ayllos', '', true);
        } else {
            $registros = $xmlObj->roottag->tags;
            foreach ($registros as $registro) {
                $retorno[] = array(
                    'modalidade'  => $registro->tags[0]->cdata, //valida existencia da modalidade
                );
            }
        }
    }
} else if  ( $flgopcao == 'I' ) { //inserir
    
    // Verifica se os parametros necessarios foram informados
    if (!isset($_POST["cdcooper"]) || !isset($_POST["cdmodali"]) || !isset($_POST["indplano"]) || !isset($_POST["cdprodut"]) ||
        !isset($_POST["indteimo"]) || !isset($_POST["indparci"]) || !isset($_POST["valormin"]) ||
        !isset($_POST["indautoa"]) || !isset($_POST["indrgtpr"])) { 
        $msgErro = 'Par&acirc;metros incorretos.';
        $erro = 'S';               
    } else {
        $cdcooper = (isset($_POST["cdcooper"])) ? $_POST["cdcooper"] : 0;
        $cdprodut = (isset($_POST["cdprodut"])) ? $_POST["cdprodut"] : 0;
        $cdmodali = (isset($_POST["cdmodali"])) ? $_POST["cdmodali"] : 0;
        $indplano = (isset($_POST["indplano"])) ? $_POST["indplano"] : 0;
        $indteimo = (isset($_POST["indteimo"])) ? $_POST["indteimo"] : 0;  
        $indparci = (isset($_POST["indparci"])) ? $_POST["indparci"] : 0;
        $valormin = (isset($_POST["valormin"])) ? $_POST["valormin"] : 0;

	    $valormin = str_replace(',','.',str_replace('.','',$valormin)); // substituir , por .
        $indautoa = (isset($_POST["indautoa"])) ? $_POST["indautoa"] : 0;
        $indrgtpr = (isset($_POST["indrgtpr"])) ? $_POST["indrgtpr"] : 0;        
    }

    if ( $erro == 'N' ) {
        // Montar o xml de Requisicao
        $xml .= "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <cddopcao>I</cddopcao>";
        $xml .= "   <cdcooper>" . $cdcooper . "</cdcooper>";
        $xml .= "   <cdmodali>" . $cdmodali . "</cdmodali>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml, "PCAPTA", "MANMODCOP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getObjectXML($xmlResult);

        if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
            if ($msgErro == null || $msgErro == '') {
                $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
            }
            exibirErro('error', $msgErro, 'Alerta - Ayllos', '', true);
            exit();            
        } else {
            $registros = $xmlObj->roottag->tags;

            foreach ($registros as $registro) {
                if ( $registro->tags[0]->cdata == 'OK' ) {            
                    $retorno[] = array(
                        'msg' => $registro->tags[0]->cdata
                    );
                }
            }

            if ($indplano == 1) {
                // Grava configuracao se for programada
                $xmlCfg .= "<Root>";
                $xmlCfg .= " <Dados>";
                $xmlCfg .= "   <cdcooper_a>" . $cdcooper . "</cdcooper_a>";
                $xmlCfg .= "   <cdprodut>" . $cdprodut . "</cdprodut>";
                $xmlCfg .= "   <indplano>" . $indplano . "</indplano>";
                $xmlCfg .= "   <flgteimo>" . $indteimo . "</flgteimo>";
                $xmlCfg .= "   <fldbparc>" . $indparci . "</fldbparc>";
                $xmlCfg .= "   <vlminimo>" . $valormin . "</vlminimo>";
                $xmlCfg .= "   <flgautoatendimento>" . $indautoa . "</flgautoatendimento>";
                $xmlCfg .= "   <flgresgate_prog>" . $indrgtpr . "</flgresgate_prog>";
                $xmlCfg .= " </Dados>";
                $xmlCfg .= "</Root>";
                $xmlResultCfg = mensageria($xmlCfg, "APLI0008", "MANTEM_CONFIG_APL_PROG", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
                $xmlObjCfg = getObjectXML($xmlResultCfg);
                if (strtoupper($xmlObjCfg->roottag->tags[0]->name == 'ERRO')) {
                    $msgErro = $xmlObjCfg->roottag->tags[0]->cdata;
                    if ($msgErro == null || $msgErro == '') {
                        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
                    }
                    exibirErro('error', $msgErro, 'Alerta - Ayllos', '', true);
                    exit();            
                }
            }

        }
    }    
} else if  ( $flgopcao == 'A' ) { //Alterar a configuracao
    
    // Verifica se os parametros necessarios foram informados
    if (!isset($_POST["cdcooper"]) || !isset($_POST["indplano"]) || !isset($_POST["cdprodut"]) ||
        !isset($_POST["indteimo"]) || !isset($_POST["indparci"]) || !isset($_POST["valormin"]) ||
        !isset($_POST["indautoa"]) || !isset($_POST["indrgtpr"])) { 
        $msgErro = 'Par&acirc;metros incorretos.';
        $erro = 'S';               
    } else {
        $cdcooper = (isset($_POST["cdcooper"])) ? $_POST["cdcooper"] : 0;
        $cdprodut = (isset($_POST["cdprodut"])) ? $_POST["cdprodut"] : 0;
        $indplano = (isset($_POST["indplano"])) ? $_POST["indplano"] : 0;
        $indteimo = (isset($_POST["indteimo"])) ? $_POST["indteimo"] : 0;  
        $indparci = (isset($_POST["indparci"])) ? $_POST["indparci"] : 0;
        $valormin = (isset($_POST["valormin"])) ? $_POST["valormin"] : 0;

	    $valormin = str_replace(',','.',str_replace('.','',$valormin)); // substituir , por .
        $indautoa = (isset($_POST["indautoa"])) ? $_POST["indautoa"] : 0;
        $indrgtpr = (isset($_POST["indrgtpr"])) ? $_POST["indrgtpr"] : 0;
    }

    if ( $erro == 'N' ) {
        $xmlCfg .= "<Root>";
        $xmlCfg .= " <Dados>";
        $xmlCfg .= "   <cdcooper_a>" . $cdcooper . "</cdcooper_a>";
        $xmlCfg .= "   <cdprodut>" . $cdprodut . "</cdprodut>";
        $xmlCfg .= "   <indplano>" . $indplano . "</indplano>";
        $xmlCfg .= "   <flgteimo>" . $indteimo . "</flgteimo>";
        $xmlCfg .= "   <fldbparc>" . $indparci . "</fldbparc>";
        $xmlCfg .= "   <vlminimo>" . $valormin . "</vlminimo>";
        $xmlCfg .= "   <flgautoatendimento>" . $indautoa . "</flgautoatendimento>";
        $xmlCfg .= "   <flgresgate_prog>" . $indrgtpr . "</flgresgate_prog>";
        $xmlCfg .= " </Dados>";
        $xmlCfg .= "</Root>";
        $xmlResultCfg = mensageria($xmlCfg, "APLI0008", "MANTEM_CONFIG_APL_PROG", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObjCfg = getObjectXML($xmlResultCfg);
        if (strtoupper($xmlObjCfg->roottag->tags[0]->name == 'ERRO')) {
            $msgErro = $xmlObjCfg->roottag->tags[0]->cdata;
            if ($msgErro == null || $msgErro == '') {
                $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
            }
            exibirErro('error', $msgErro, 'Alerta - Ayllos', '', true);
            exit();            
        }
    }    
} else if ( $flgopcao == 'E' || $flgopcao == 'D' || $flgopcao == 'B' ) {
   
   // Verifica se os parametros necessarios foram informados
    if (!isset($_POST["cdmodali"]) || !isset($_POST["cdcooper"])) {
        $msgErro = 'Par&acirc;metros incorretos.';
        $erro = 'S';          
    } else {
        $cdmodali = (isset($_POST["cdmodali"])) ? $_POST["cdmodali"] : '';
        $cdcooper = (isset($_POST["cdcooper"])) ? $_POST["cdcooper"] : '';
    }
    
    if ( $erro == 'N' ) {
        // Montar o xml de Requisicao
        $xml .= "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <cddopcao>$flgopcao</cddopcao>";    
        $xml .= "   <cdcooper>$cdcooper</cdcooper>";    
        $xml .= "   <cdmodali>" . $cdmodali . "</cdmodali>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        $xmlResult = mensageria($xml, "PCAPTA", 'MANMODCOP', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObj = getObjectXML($xmlResult);

        if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
            if ($msgErro == null || $msgErro == '') {
                $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
            }
            exibirErro('error', $msgErro, 'Alerta - Ayllos', '', true);   
        } else {
            $registros = $xmlObj->roottag->tags[0];
            foreach ($registros as $registro) {
                if ( $registro->tags[0]->cdata == 'OK' ) {
                    $retorno[] = array(
                        'msg' => $registro->tags[0]->cdata
                    );                
                }
            }        
        }
    }
}
echo json_encode(array('rows' => count($retorno), 'records' => $retorno, 'erro' => $erro, 'msg'=> $msgErro));