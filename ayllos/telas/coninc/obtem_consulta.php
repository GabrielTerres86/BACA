<?php
	/*************************************************************************
	  Fonte: obtem_consulta.php                                               
	  Autor: Jaison Fernando
	  Data : Novembro/2016                         Última Alteração: --/--/----		   
	                                                                   
	  Objetivo  : Carrega os dados da tela CONINC.
	                                                                 
	  Alterações: 
				  
	***********************************************************************/

	session_start();
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");
	require_once("../../class/xmlfile.php");
    isPostMethod();

    $nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 1;
    $nrregist = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 30;
    $cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
    $dtrefini = (isset($_POST['dtrefini'])) ? $_POST['dtrefini'] : '';
    $dtreffim = (isset($_POST['dtreffim'])) ? $_POST['dtreffim'] : '';
    $dsoperac = (isset($_POST['dsoperac'])) ? $_POST['dsoperac'] : '';
    $cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0;
    $iddgrupo = (isset($_POST['iddgrupo'])) ? $_POST['iddgrupo'] : 0;
    $dsincons = (isset($_POST['dsincons'])) ? $_POST['dsincons'] : '';
    $dsregist = (isset($_POST['dsregist'])) ? $_POST['dsregist'] : '';

    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

    switch ($cddopcao) {

        case 'C':
            // Montar o xml de Requisicao
            $xml  = "";
            $xml .= "<Root>";
            $xml .= " <Dados>";
            $xml .= "   <tpdsaida>XML</tpdsaida>";
            $xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
            $xml .= "   <iddgrupo>".$iddgrupo."</iddgrupo>";
            $xml .= "   <dtrefini>".$dtrefini."</dtrefini>";
            $xml .= "   <dtreffim>".$dtreffim."</dtreffim>";
            $xml .= "   <dsincons>".$dsincons."</dsincons>";
            $xml .= "   <dsregist>".$dsregist."</dsregist>";
            $xml .= "   <nriniseq>".$nriniseq."</nriniseq>";
            $xml .= "   <nrregist>".$nrregist."</nrregist>";
            $xml .= " </Dados>";
            $xml .= "</Root>";

            // Requisicao dos dados
            $xmlResult = mensageria($xml, "TELA_CONINC", "CONINC_BUSCA_INCONSIST", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
            $xmlObject = getObjectXML($xmlResult);
            $xmlRegist = $xmlObject->roottag->tags[0]->tags;
            $qtregist  = $xmlObject->roottag->tags[0]->attributes["QTREGIST"];
            $qtavisos  = $xmlObject->roottag->tags[0]->attributes["QTAVISOS"];
            $qtderros  = $xmlObject->roottag->tags[0]->attributes["QTDERROS"];

            if ( strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO' ) {
                $msgErro = $xmlObject->roottag->tags[0]->cdata;
                if ($msgErro == '') {
                    $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
                }
                exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
            }
            break;

        case 'G':
            // Quando nao for Inclusao
            if ($dsoperac != 'I') {
                // Montar o xml de Requisicao
                $xml  = "";
                $xml .= "<Root>";
                $xml .= " <Dados>";
                $xml .= "   <iddgrupo>".($dsoperac == 'A' && $iddgrupo > 0 ? $iddgrupo : 0)."</iddgrupo>";
                $xml .= "   <nriniseq>".$nriniseq."</nriniseq>";
                $xml .= "   <nrregist>".$nrregist."</nrregist>";
                $xml .= " </Dados>";
                $xml .= "</Root>";

                // Requisicao dos dados
                $xmlResult = mensageria($xml, "TELA_CONINC", "CONINC_BUSCA_GRUPO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
                $xmlObject = getObjectXML($xmlResult);
                $xmlRegist = $xmlObject->roottag->tags[0]->tags;
                $qtregist  = $xmlObject->roottag->tags[0]->attributes["QTREGIST"];

                if ( strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO' ) {
                    $msgErro = $xmlObject->roottag->tags[0]->cdata;
                    if ($msgErro == '') {
                        $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
                    }
                    exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
                }
            }
            break;

        case 'E':
            // Quando nao for Inclusao
            if ($dsoperac != 'I') {
                // Montar o xml de Requisicao
                $xml  = "";
                $xml .= "<Root>";
                $xml .= " <Dados>";
                $xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
                $xml .= "   <iddgrupo>".$iddgrupo."</iddgrupo>";
                $xml .= "   <nriniseq>".$nriniseq."</nriniseq>";
                $xml .= "   <nrregist>".$nrregist."</nrregist>";
                $xml .= " </Dados>";
                $xml .= "</Root>";

                // Requisicao dos dados
                $xmlResult = mensageria($xml, "TELA_CONINC", "CONINC_BUSCA_EMAIL", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
                $xmlObject = getObjectXML($xmlResult);
                $xmlRegist = $xmlObject->roottag->tags[0]->tags;
                $qtregist  = $xmlObject->roottag->tags[0]->attributes["QTREGIST"];

                if ( strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO' ) {
                    $msgErro = $xmlObject->roottag->tags[0]->cdata;
                    if ($msgErro == '') {
                        $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
                    }
                    exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
                }
            }
            break;

        case 'A':
            // Quando nao for Inclusao
            if ($dsoperac != 'I') {
                // Montar o xml de Requisicao
                $xml  = "";
                $xml .= "<Root>";
                $xml .= " <Dados>";
                $xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
                $xml .= "   <iddgrupo>".$iddgrupo."</iddgrupo>";
                $xml .= "   <nriniseq>".$nriniseq."</nriniseq>";
                $xml .= "   <nrregist>".$nrregist."</nrregist>";
                $xml .= " </Dados>";
                $xml .= "</Root>";

                // Requisicao dos dados
                $xmlResult = mensageria($xml, "TELA_CONINC", "CONINC_BUSCA_ACESSO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
                $xmlObject = getObjectXML($xmlResult);
                $xmlRegist = $xmlObject->roottag->tags[0]->tags;
                $qtregist  = $xmlObject->roottag->tags[0]->attributes["QTREGIST"];

                if ( strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO' ) {
                    $msgErro = $xmlObject->roottag->tags[0]->cdata;
                    if ($msgErro == '') {
                        $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
                    }
                    exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
                }
            // Se for uma Inclusao
            } else {
                // Montar o xml de Requisicao
                $xml  = "";
                $xml .= "<Root>";
                $xml .= " <Dados>";	
                $xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
                $xml .= " </Dados>";
                $xml .= "</Root>";

                // Requisicao dos dados
                $xmlResult = mensageria($xml, "TELA_CONINC", "CONINC_BUSCA_DEPTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
                $xmlObject = getObjectXML($xmlResult);

                if ( strtoupper($xmlObject->roottag->tags[0]->name) == 'ERRO' ) {
                    $msgErro = $xmlObject->roottag->tags[0]->cdata;
                    if ($msgErro == '') {
                        $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
                    }
                    exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
                }

                $xmlDeptos = $xmlObject->roottag->tags[0]->tags;
            }
            break;

    }

	include('form_'.strtolower($cddopcao).'.php');
?>