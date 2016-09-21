<?php

	/*************************************************************************
	  Fonte: realiza_consulta.php                                               
	  Autor: Adriano                                                  
	  Data : Outubro/2011                       Última Alteração: 		   
	                                                                   
	  Objetivo  : Realiza consulta CADLNG.             
	                                                                 
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
	
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'A')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nriniseq"]) || !isset($_POST["cddopcao"]) || 
		!isset($_POST["consupes"]) || !isset($_POST["consucpf"]) ||
		!isset($_POST["nrregist"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','',false);
		
	}	
	
	$cddopcao = $_POST["cddopcao"];
	$nrcpfcgc = $_POST["consucpf"];
	$nmpessoa = $_POST["consupes"];
	$nrregist = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 30;
	$nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 1;	
	
	$xmlConsulta  = "";
	$xmlConsulta .= "<Root>";
	$xmlConsulta .= " <Cabecalho>";
	$xmlConsulta .= "    <Bo>b1wgen0117.p</Bo>";
	$xmlConsulta .= "    <Proc>consulta</Proc>";
	$xmlConsulta .= " </Cabecalho>";
	$xmlConsulta .= " <Dados>";
	$xmlConsulta .= "	 <cddopcao>".$cddopcao."</cddopcao>";
	$xmlConsulta .= "    <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xmlConsulta .= "    <nmpessoa>".$nmpessoa."</nmpessoa>";
	$xmlConsulta .= "	 <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlConsulta .= "	 <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlConsulta .= "	 <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlConsulta .= "	 <nrregist>".$nrregist."</nrregist>";
	$xmlConsulta .= "	 <nriniseq>".$nriniseq."</nriniseq>";
	$xmlConsulta .= "	 <flgpagin>yes</flgpagin>";
	$xmlConsulta .= " </Dados>";
	$xmlConsulta .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlConsulta);
		
	$xmlObjConsulta = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjConsulta->roottag->tags[0]->name) == "ERRO") {
		$dsdoerro = $xmlObjConsulta->roottag->tags[0]->tags[0]->tags[4]->cdata;
		echo 'showError("error","'.$dsdoerro.'","Alerta - Ayllos","");';
	}   

	$registros = $xmlObjConsulta->roottag->tags[0]->tags;
	$qtregist = $xmlObjConsulta->roottag->tags[0]->attributes["QTREGIST"];
	
			
	if ($qtregist == 0) { 			
       ?>
		showError('inform','Nenhum registro foi encontrado.','Alerta - Ayllos','$(\'#cddopcao\',\'#frmCabCadlng\').focus()');
		limpaCampos();
		<?
	} else {      
	?>
		var strHTML = '';		 
		
		strHTML = '<br />';
		strHTML += '<fieldset id="Informacoes">';
		strHTML += '<legend><? if($qtregist > 0){echo "Registro(s) encontrado(s)";}else{echo "Registro(s) encontrado(s)";} ?></legend>';
		strHTML += '<div class="divRegistros">';
		strHTML += '  <table>';
		strHTML += '    <thead>';
		strHTML += '       <tr>';
		strHTML += '          <th>Sequ&ecirc;ncia</th>';
		strHTML += '          <th>Situa&ccedil;&atilde;o</th>';
		strHTML += '          <th>Nome</th>';
		strHTML += '          <th>CPF/CNPJ</th>';
		strHTML += '       </tr>';
		strHTML += '    </thead>';
		strHTML += '    <tbody>';
		<? foreach( $registros as $result ) {     	?>
		strHTML += '     	       <tr>'; 	
		strHTML += '     	   	     <td><span><? echo getByTagName($result->tags,'nrsequen'); ?></span><? echo getByTagName($result->tags,'nrsequen'); ?> </td>';
		strHTML += '      	         <td><span><? echo getByTagName($result->tags,'cdsitreg'); ?></span><? if(getByTagName($result->tags,'cdsitreg') == 1) { $dscsitua = "INCLUIDO"; }else{ $dscsitua = "EXCLUIDO";} echo $dscsitua; ?> </td>';
		strHTML += '       	         <td><span><? echo getByTagName($result->tags,'nmpessoa'); ?></span><? echo getByTagName($result->tags,'nmpessoa'); ?> </td>';
		strHTML += '       	         <td><span><? echo getByTagName($result->tags,'nrcpfcgc'); ?></span><? $cpf = getByTagName($result->tags,'nrcpfcgc'); if($cpf.length <= 11){ echo formatar($cpf,"cpf");}else{echo formatar($cpf,"cnpj");} ?> </td>';	
		strHTML += '				 <input type="hidden" id="detseque" name="detseque" value="<? echo getByTagName($result->tags,'nrsequen') ?>" />';
		strHTML += '				 <input type="hidden" id="detsitua" name="detsitua" value="<? if(getByTagName($result->tags,'cdsitreg') == 1) { $dscsitua = "INCLUIDO"; }else{ $dscsitua = "EXCLUIDO";} echo $dscsitua; ?>" />';
		strHTML += '				 <input type="hidden" id="detnrcpf" name="detnrcpf" value="<? echo getByTagName($result->tags,'nrcpfcgc') ?>" />';
		strHTML += '				 <input type="hidden" id="detdnome" name="detdnome" value="<? echo getByTagName($result->tags,'nmpessoa') ?>" />';
		strHTML += '				 <input type="hidden" id="detsolic" name="detsolic" value="<? echo getByTagName($result->tags,'nmcoosol')." - ".getByTagName($result->tags,'nmpessol')." - ".getByTagName($result->tags,'dscarsol')  ?>" />';
		strHTML += '				 <input type="hidden" id="detdtinc" name="detdtinc" value="<? echo getByTagName($result->tags,'dtinclus')." - ".getByTagName($result->tags,'hrinclus') ?>" />';
		strHTML += '				 <input type="hidden" id="detmotin" name="detmotin" value="<? echo getByTagName($result->tags,'dsmotinc') ?>" />';
		strHTML += '				 <input type="hidden" id="detdocad" name="detdocad" value="<? echo getByTagName($result->tags,'nmcooinc')." - ".getByTagName($result->tags,'nmopeinc') ?>" />';
		strHTML += '				 <input type="hidden" id="detexclu" name="detexclu" value="<? if(getByTagName($result->tags,'nmcooexc') <> "" && getByTagName($result->tags,'nmopeexc') <> ""){ echo getByTagName($result->tags,'nmcooexc')." - ".getByTagName($result->tags,'nmopeexc');} ?>" />';
		strHTML += '				 <input type="hidden" id="detdtexc" name="detdtexc" value="<? if(getByTagName($result->tags,'dtexclus') <> "" && getByTagName($result->tags,'hrexclus') <> ""){ echo getByTagName($result->tags,'dtexclus')." - ".getByTagName($result->tags,'hrexclus');} ?>" />';
		strHTML += '				 <input type="hidden" id="detmotex" name="detmotex" value="<? echo getByTagName($result->tags,'dsmotexc') ?>" />';
		strHTML += '     	       </tr>';	
		<? } ?>
		strHTML += '     </tbody>';	
		strHTML += '  </table>';
		strHTML += '</div>';
		strHTML += '<div id="divRegistrosRodape" class="divRegistrosRodape">';
		strHTML += '	<table>';	
		strHTML += '		<tr>';
		strHTML += '			<td>';
		strHTML += '				<? if (isset($qtregist) and $qtregist == 0){ $nriniseq = 0;} ?>';
		strHTML += '				<? if ($nriniseq > 1){ ?>';
		strHTML += '				       <a class="paginacaoAnt"><<< Anterior</a>';
		strHTML += '				<? }else{ ?>';
		strHTML += '						&nbsp;';
		strHTML += '				<? } ?>';
		strHTML += '			</td>';
		strHTML += '			<td>';
		strHTML += '				<? if (isset($nriniseq)) { ?>';
		strHTML += '					   Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?>';
		strHTML += '					<? } ?>';
		strHTML += '			</td>';
		strHTML += '			<td>';
		strHTML += '				<? if($qtregist > ($nriniseq + $nrregist - 1)) { ?>';
		strHTML += '					  <a class="paginacaoProx">Pr&oacute;ximo >>></a>';
		strHTML += '				<? }else{ ?>';
		strHTML += '						&nbsp;';
		strHTML += '				<? } ?>';
		strHTML += '			</td>';
		strHTML += '        </tr>';
		strHTML += '	</table>';
		strHTML += '</div>';	
		strHTML += '</fieldset>';
					
		<?
		
		echo '$("#divDetalheConsulta").html(strHTML);';
		echo 'tabela();';
		echo '$("#divDetalheConsulta").css("display","block")';
		
		}	 
	
		
			 
?>



				

