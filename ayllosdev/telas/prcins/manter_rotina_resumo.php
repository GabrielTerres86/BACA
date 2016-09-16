<?php
	/*!
	 * FONTE        : manter_rotina_resumo.php
	 * CRIAÇÃO      : Douglas Quisinski
	 * DATA CRIAÇÃO : 24/09/2015
	 * OBJETIVO     : Rotina para realizar a busca do resumo de processamento
	 * --------------
	 * ALTERAÇÕES   : 16/10/2015 - Ajustes para liberação (Adriano).
	 * -------------- 
	 */		

    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();			
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"R")) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$cdcopaux = isset($_POST["cdcopaux"]) ? $_POST["cdcopaux"] : 0;
	$dtinicio = isset($_POST["dtinicio"]) ? $_POST["dtinicio"] : "";
	$dtafinal = isset($_POST["dtafinal"]) ? $_POST["dtafinal"] : "";
	
	if ( $dtinicio == "" || $dtafinal == "") {
		
		exibirErro('error','Data do resumo n&atilde;o informada.','Alerta - Ayllos','$(\'input,select\',\'#frmResumo\').habilitaCampo();focaCampoErro(\'dtinicio\',\'frmResumo\');',false);
		
	}
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcopaux>".$cdcopaux."</cdcopaux>";
	$xml .= "   <dtinicio>".$dtinicio."</dtinicio>";
	$xml .= "   <dtafinal>".$dtafinal."</dtafinal>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_PRCINS", "BUSCAR_RESUMO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "cdcopaux";
		}
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		
		exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'input,select\',\'#frmResumo\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'frmResumo\');',false);
		
	} 
		
	$qtdtotal = number_format(str_replace(',','',$xmlObj->roottag->attributes['QTDTOTAL']),0,',','.');	
	$vlrtotal = number_format(str_replace(',','',$xmlObj->roottag->attributes['VLRTOTAL']),0,',','.');	
	
	echo "strHTML  = '<div class=\"divRegistros\">';";
	echo "strHTML += '  <table>';";
	echo "strHTML += '     <thead>';";
	echo "strHTML += '       <tr>';";
	echo "strHTML += '          <th>Cooperativa</th>';";
	echo "strHTML += '		    <th>Quantidade</th>';";
	echo "strHTML += '		    <th>Valor</th>';";
	echo "strHTML += '	   </tr>';";
	echo "strHTML += '     </thead>';";
	echo "strHTML += '     <tbody>';";		
		
	foreach($xmlObj->roottag->tags as $resumo){
		
		/* Converter os campos de valores */ 			
		echo "strHTML += '<tr>';";	
		echo "strHTML += '   <td><span>".getByTagName($resumo->tags,'nmrescop')."</span>".getByTagName($resumo->tags,'nmrescop')."</td>';";
		echo "strHTML += '   <td><span>".number_format(str_replace(',','',getByTagName($resumo->tags,'qtdbenef')),0,',','.')."</span>".number_format(str_replace(',','',getByTagName($resumo->tags,'qtdbenef')),0,',','.')."</td>';";
		echo "strHTML += '   <td><span>".number_format(str_replace(',','',getByTagName($resumo->tags,'vlrbenef')),2,',','.')."</span>".number_format(str_replace(',','',getByTagName($resumo->tags,'vlrbenef')),2,',','.')."</td>';";
		echo "strHTML += '</tr>';";
		
	}
	
	echo "strHTML += '    </tbody>';";
	echo "strHTML += '  </table>';";
	echo "strHTML += '</div>';";
	echo "strHTML += '<div id=\"divRegistrosRodape\" class=\"divRegistrosRodape\">';";
	echo "strHTML += '   <table>';";	
	echo "strHTML += '     <tr>';";
	echo "strHTML += '        <td>';";
	echo "strHTML += '		  </td>';";
	echo "strHTML += '	      <td>';";
	
	if($cdcopaux == 0){
		echo "strHTML += '	         Total: ".$qtdtotal." - R$ ".$vlrtotal."';";
	}
	
	echo "strHTML += '        </td>';";
	echo "strHTML += '        <td>';";
	echo "strHTML += '        </td>';";
	echo "strHTML += '     </tr>';";
	echo "strHTML += '   </table>';";
	echo "strHTML += '</div>';";
	
	echo "$('#divResumo','#frmResumo').html(strHTML);";
	echo "formataTabelaResumo();";						
	echo "$('#divResumo','#frmResumo').css('display','block');"; 
	echo "$('#fsetResumo','#frmResumo').css('display','block');";
	echo "$('#btConcluir','#divBotoes').css({'display':'none'});";
	
?>