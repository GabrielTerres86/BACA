<?php
	/*!
	* FONTE        : buscar_nacionalidades.php
	* CRIAÇÃO      : Kelvin Souza Ott	
	* DATA CRIAÇÃO : 12/05/2016
	* OBJETIVO     : Rotina para realizar a busca das nacionalidades
	* --------------
	* ALTERAÇÕES   : 12/04/2017 - Buscar a nacionalidade com CDNACION. (Jaison/Andrino)
	* -------------- 
	*/		
 
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	$dsnacion = isset($_POST["dsnacion"]) ? $_POST["dsnacion"] : "";
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <dsnacion>".$dsnacion."</dsnacion>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "CADA0001", "BUSCAR_NACIONALIDADE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"],
	$glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObj = getObjectXML($xmlResult);		
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "dsnacion";
		}
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		
		exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'input,select\',\'#divConteudo\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'divConteudo\');',false);
	} 
		
	echo "strHTML  = '<div class=\"divRegistros\">';";
	echo "strHTML += '  <table>';";
	echo "strHTML += '     <thead>';";
	echo "strHTML += '       <tr>';";
	echo "strHTML += '          <th>Nacionalidade</th>';";	
	echo "strHTML += '	   </tr>';";
	echo "strHTML += '     </thead>';";
	echo "strHTML += '     <tbody>';";		

	foreach($xmlObj->roottag->tags[0]->tags as $nacionalidade){
		
		//Converter os campos de valores 			
		echo "strHTML += '<tr cdnacion=\'".getByTagName($nacionalidade->tags,'cdnacion')."\'>';";	
		echo "strHTML += '   <td>".getByTagName($nacionalidade->tags,'dsnacion')."</td>';";	
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
	
	echo "strHTML += '        </td>';";
	echo "strHTML += '        <td>';";
	echo "strHTML += '        </td>';";
	echo "strHTML += '     </tr>';";
	echo "strHTML += '   </table>';";
	echo "strHTML += '</div>';";
	
	echo "$('#divConteudo').html(strHTML);";
	echo "formataTabelaNacionalidade();";						
?>