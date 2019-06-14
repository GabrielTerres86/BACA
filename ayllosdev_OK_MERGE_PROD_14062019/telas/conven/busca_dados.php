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
	
	if (!isset($_POST["cdempcon"]))  {
		exibeErro("Parâmetros incorretos.");
	}	
    
    if (!isset($_POST["cdsegmto"]))  {
		exibeErro("Parâmetros incorretos.");
	}	
    
	$cddopcao = $_POST["cddopcao"] == "" ? 0 : $_POST["cddopcao"];		
	$cdempcon = $_POST["cdempcon"] == "" ? 0 : $_POST["cdempcon"];
    $cdsegmto = $_POST["cdsegmto"] == "" ? 0 : $_POST["cdsegmto"];
   
   
    $xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <cddopcao>".$cddopcao."</cddopcao>";    
    $xml .= "   <cdempcon>".$cdempcon."</cdempcon>";    
    $xml .= "   <cdsegmto>".$cdsegmto."</cdsegmto>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_CONVEN", "BUSCAR_DADOS_CONVEN", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
        $cdempcon = getByTagName($r->tags, 'cdempcon');
        $cdsegmto = getByTagName($r->tags, 'cdsegmto');
        $dsalerta = getByTagName($r->tags, 'dsalerta'); 
        
       
        // Carregar dados apenas se for diferente de inclusao e
        // qnd nao retornou dado, pois pode ser inclusao
        // retornando dados e devemos questionar se deseja alterar.
        if ( $cdempcon != "" ){

            $nmrescon = getByTagName($r->tags, 'nmrescon');
            $nmextcon = getByTagName($r->tags, 'nmextcon');
            $cdhistor = getByTagName($r->tags, 'cdhistor');    
            $nrdolote = getByTagName($r->tags, 'nrdolote');    
            $flginter = getByTagName($r->tags, 'flginter');
            $flgcnvsi = getByTagName($r->tags, 'flgcnvsi');
            $cpfcgrcb = getByTagName($r->tags, 'cpfcgrcb');
            $cdbccrcb = getByTagName($r->tags, 'cdbccrcb');
            $cdagercb = getByTagName($r->tags, 'cdagercb');
            $nrccdrcb = getByTagName($r->tags, 'nrccdrcb');
            $cdfinrcb = getByTagName($r->tags, 'cdfinrcb');
            $tparrecd = getByTagName($r->tags, 'tparrecd');
            $flgaccec = getByTagName($r->tags, 'flgaccec');
            $flgacsic = getByTagName($r->tags, 'flgacsic');
            $flgacbcb = getByTagName($r->tags, 'flgacbcb');    
               
                
            echo '$("#nmrescon","#frmCampos").val("'.$nmrescon.'");';
            echo '$("#nmextcon","#frmCampos").val("'.$nmextcon.'");';
            echo '$("#cdhistor","#frmCampos").val("'.$cdhistor.'");';
            echo '$("#nrdolote","#frmCampos").val("'.$nrdolote.'");';      
            echo '$("#flginter","#frmCampos").val("'.$flginter.'");';      
            
            echo 'selecionarAceita("flgaccec",'.$flgaccec.');';            
            echo 'document.getElementById("flgacsic_'.$flgacsic.'").checked = true;';            
            echo 'selecionarAceita("flgacbcb",'.$flgacbcb.');';
            
            echo 'selecionarTparrecd('.$tparrecd.');';
            
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
    
	echo 'LiberaCampos("campos");';
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';	
    
    
    function exibeAlerta($msgAlert) {
        echo 'hideMsgAguardo();';
        echo 'showError("error","' . $msgAlert . '","Alerta - Ayllos","cCddopcao.val(\'C\');LiberaCampos(\'campos\');");';
        exit();
    }
		
?>
