<?php 

/*!
     * FONTE        : busca_dados.php
     * CRIAÇÃO      : Odirlei Busana(AMcom)
     * DATA CRIAÇÃO : Dezembro/2017 
     * OBJETIVO     : Retorna dados dos do convenio
     * --------------
     * ALTERAÇÕES   :
     * --------------
     *
     */	     
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	if (!isset($_POST["cdempres"]))  {
		exibeErro("Parâmetros incorretos.");
	}	
    
    if (!isset($_POST["tparrecd"]))  {
		exibeErro("Parâmetros incorretos.");
	}	
    
	$cddopcao = $_POST["cddopcao"] == "" ? 0 : $_POST["cddopcao"];		
	$cdempres = $_POST["cdempres"] == "" ? 0 : $_POST["cdempres"];
    $tparrecd = $_POST["tparrecd"] == "" ? 0 : $_POST["tparrecd"];
    $cdempcon = $_POST["cdempcon"] == "" ? 0 : $_POST["cdempcon"];
    $cdsegmto = $_POST["cdsegmto"] == "" ? 0 : $_POST["cdsegmto"];
    
   
   
    $xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <cddopcao>".$cddopcao."</cddopcao>";    
    $xml .= "   <cdempres>".$cdempres."</cdempres>";    
    $xml .= "   <tparrecd>".$tparrecd."</tparrecd>";
    $xml .= "   <cdempcon>".$cdempcon."</cdempcon>";
    $xml .= "   <cdsegmto>".$cdsegmto."</cdsegmto>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_GT0018", "BUSCAR_DADOS_GT0018", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);

    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        if ($msgErro == "") {
            $msgErro = $xmlObj->roottag->tags[0]->cdata;
        }

        exibeErroNew($msgErro);
        exit();
    }

    $registros = $xmlObj->roottag->tags[0]->tags;

    function exibeErroNew($msgErro) {
        echo 'hideMsgAguardo();';
        echo 'showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()");';
        exit();
    }	
    
    foreach ($registros as $r) {
        
        $cdempres = getByTagName($r->tags, 'cdempres');
        
        $dsalerta = getByTagName($r->tags, 'dsalerta'); 
        
       
        // Carregar dados apenas se for diferente de inclusao e
        // qnd nao retornou dado, pois pode ser inclusao
        // retornando dados e devemos questionar se deseja alterar.
        if ( $cdempres != "" ){
            
            $nmextcon  = getByTagName($r->tags, 'nmextcon');
            $cdempcon  = getByTagName($r->tags, 'cdempcon');
            $nmrescon  = getByTagName($r->tags, 'nmrescon');
            $cdsegmto  = getByTagName($r->tags, 'cdsegmto');
            $vltarint  = getByTagName($r->tags, 'vltarint');
            $vltartaa  = getByTagName($r->tags, 'vltartaa');
            $vltarcxa  = getByTagName($r->tags, 'vltarcxa');
            $vltardeb  = getByTagName($r->tags, 'vltardeb');
            $vltarcor  = getByTagName($r->tags, 'vltarcor');
            $vltararq  = getByTagName($r->tags, 'vltararq');
            $nrrenorm  = getByTagName($r->tags, 'nrrenorm');
            $nrtolera  = getByTagName($r->tags, 'nrtolera');
            $dsdianor  = getByTagName($r->tags, 'dsdianor');
            $dtcancel  = getByTagName($r->tags, 'dtcancel');
            $nrlayout  = getByTagName($r->tags, 'nrlayout');
               
            echo '$("#nmextcon","#frmCab").val("'.$nmextcon.'");';      
            echo '$("#cdempcon","#frmCampos").val("'.$cdempcon.'");'; 
            echo '$("#nmrescon","#frmCampos").val("'.$nmrescon.'");';      
            echo '$("#cdsegmto","#frmCampos").val("'.$cdsegmto.'");';      
            echo '$("#vltarint","#frmCampos").val("'.$vltarint.'");';      
            echo '$("#vltartaa","#frmCampos").val("'.$vltartaa.'");';      
            echo '$("#vltarcxa","#frmCampos").val("'.$vltarcxa.'");';      
            echo '$("#vltardeb","#frmCampos").val("'.$vltardeb.'");';      
            echo '$("#vltarcor","#frmCampos").val("'.$vltarcor.'");';      
            echo '$("#vltararq","#frmCampos").val("'.$vltararq.'");';      
            echo '$("#nrrenorm","#frmCampos").val("'.$nrrenorm.'");';      
            echo '$("#nrtolera","#frmCampos").val("'.$nrtolera.'");';      
            echo '$("#dsdianor","#frmCampos").val("'.$dsdianor.'");';      
            echo '$("#dtcancel","#frmCampos").val("'.$dtcancel.'");';      
            echo '$("#nrlayout","#frmCampos").val("'.$nrlayout.'");';      
                        
            // Apresentar alerta e voltar para opcao consulta
            if ($dsalerta != ""){
                exibeAlerta($dsalerta);
                return false;
            }
            
            // Caso for inclusao e localizou registro, 
            // notificar e alterar para opcao de alteracao
            if ($cddopcao == 'I'){
                echo 'confirmaRegExist();';
                return false;
            }
        }else if ($dsalerta != ""){
            exibeAlerta($dsalerta);
            return false;
        }
       
    }
    
	echo 'LiberaCampos(\'frmCampos\');';
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';	
    
    
    function exibeAlerta($msgAlert) {
        echo 'hideMsgAguardo();';
        echo 'showError("error","' . $msgAlert . '","Alerta - Ayllos","cCddopcao.val(\'C\');LiberaCampos(\'frmCampos\');");';
        exit();
    }
		
?>
