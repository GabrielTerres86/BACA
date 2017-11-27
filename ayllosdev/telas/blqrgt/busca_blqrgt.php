<?php
/*!
 * FONTE        : busca_blqrgt.php                        Última alteração: 
 * CRIAÇÃO      : Lombardi
 * DATA CRIAÇÃO : 16/11/2017
 * OBJETIVO     : Busca lista de bloqueios
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

    require_once("../../includes/carrega_permissoes.php");


	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ; 
    
    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {     
    
        exibirErro('error',$msgError,'Alerta - Ayllos','',false);
    }
    
    validaDados();

    // Monta o xml de requisição        
    $xml  = "";
    $xml .= "<Root>";
    $xml .= " <Dados>";
    $xml .= "     <cddopcao>".$cddopcao."</cddopcao>";
    $xml .= "     <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= " </Dados>";
    $xml .= "</Root>";
    
    // Executa script para envio do XML 
    $xmlResult = mensageria($xml, "TELA_BLQRGT", "BUSCA_BLQ_APL_COB", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);
    
    // Se ocorrer um erro, mostra crítica
    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'#btnVoltar\',\'#divBotoesFiltroLdesco\').click();',false);
        
    }
	
	$registros = '<Root>';
	
	foreach($xmlObj->roottag->tags[0]->tags as $registro){
		$registros .=
				'<bloq>'.
					'<dstipapl>'.getByTagName($registro->tags,'dstipapl').'</dstipapl>'.
					'<nrctrrpp>'.getByTagName($registro->tags,'nrctrrpp').'</nrctrrpp>'.
					'<vlsdrdpp>'.formataMoeda(str_replace(',','.',getByTagName($registro->tags,'vlsdrdpp'))).'</vlsdrdpp>'.
					'<tpaplica>'.getByTagName($registro->tags,'tpaplica').'</tpaplica>'.
					'<idtipapl>'.getByTagName($registro->tags,'idtipapl').'</idtipapl>'.
					'<nmprodut>'.getByTagName($registro->tags,'nmprodut').'</nmprodut>'.
				'</bloq>';
	}
	
	$bloqueiosCobertura = $xmlObj->roottag->tags[1]->tags;
	$countBloqueiosCobertura = count($xmlObj->roottag->tags[1]->tags);
	
    // Monta o xml de requisição
    $xml  = "";
    $xml .= "<Root>";
    $xml .= " <Dados>";
    $xml .= "     <nrdconta>".$nrdconta."</nrdconta>";
    $xml .= "     <idseqttl>1</idseqttl>";
    $xml .= "     <nraplica>0</nraplica>";
    $xml .= "     <cdprodut>0</cdprodut>";
    $xml .= "     <idconsul>5</idconsul>";
    $xml .= "     <idgerlog>0</idgerlog>";
    $xml .= " </Dados>";
    $xml .= "</Root>";
    
    // Executa script para envio do XML 
    $xmlResult = mensageria($xml, "ATENDA", "LISAPLI", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);
	
	foreach($xmlObj->roottag->tags as $registro){
		if ($registro->tags[12]->cdata == "BLOQUEADA") {
			$registros .= 
					'<bloq>'.
						'<dstipapl>'.$registro->tags[18]->cdata.'</dstipapl>'.
						'<nrctrrpp>'.$registro->tags[1]->cdata.'</nrctrrpp>'.
						'<vlsdrdpp>'.formataMoeda($registro->tags[9]->cdata).'</vlsdrdpp>'.
						'<tpaplica>'.(isset($registro->tags[29]->cdata) ? $registro->tags[29]->cdata : 0).'</tpaplica>'.
						'<idtipapl>'.$registro->tags[16]->cdata.'</idtipapl>'.
						'<nmprodut>'.$registro->tags[21]->cdata.'</nmprodut>'.
					'</bloq>';
		}
	}
	
	$registros .= '</Root>';
	
	$bloqueios = simplexml_load_string($registros);
	
	include('form_blqrgt.php');
	
    function validaDados(){
	/*      
        //Codigo
        if ( $GLOBALS["cdcodigo"] == 0){ 
            exibirErro('error','Código inv&aacute;lido.','Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesFiltroLdesco\').focus();',false);
        }
	*/    
    }

?> 
