<?php

	/*************************************************************************
	  Fonte: carrega_dados.php                                               
	  Autor: Henrique                                                  
	  Data : Setembro/2011                     Última Alteração: 14/08/2013
	                                                                   
	  Objetivo  : Carregar os dados da tela CNCART.              
	                                                                 
	  Alterações: 14/11/2011 - Criado paginação para a tabela, ordenada pelo
							   nome do titular (Adriano).
							   
				  17/12/2012 - Ajuste para layout padrao (Daniel).

				  14/08/2013 - Alteração da sigla PAC para PA (Carlos).
	                                                                  
				  30/11/2016 - P341-Automatização BACENJUD - Alterado para passar como parametro o  
                               código do departamento ao invés da descrição (Renato Darosci - Supero)
	                                                                  
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
	
	$tipopesq = $_POST["tipopesq"];
	$dscartao = $_POST["dscartao"];
	$flgpagin = $_POST["flgpagin"];
	$nrregist = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 30;
	$nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 1;
	
	
	$i = 0;
	
	$xmlCarregaDados  = "";
	$xmlCarregaDados .= "<Root>";
	$xmlCarregaDados .= " <Cabecalho>";
	$xmlCarregaDados .= "    <Bo>b1wgen0028.p</Bo>";
	$xmlCarregaDados .= "    <Proc>busca-cartao</Proc>";
	$xmlCarregaDados .= " </Cabecalho>";
	$xmlCarregaDados .= " <Dados>";
	$xmlCarregaDados .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlCarregaDados .= "	 <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlCarregaDados .= "	 <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlCarregaDados .= "	 <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlCarregaDados .= "	 <tipopesq>".$tipopesq."</tipopesq>";
	$xmlCarregaDados .= "	 <dscartao>".$dscartao."</dscartao>";
	$xmlCarregaDados .= "	 <nrregist>".$nrregist."</nrregist>";
	$xmlCarregaDados .= "	 <nriniseq>".$nriniseq."</nriniseq>";
	$xmlCarregaDados .= "	 <flgpagin>".$flgpagin."</flgpagin>";
	$xmlCarregaDados .= "	 <cddepart>".$glbvars["cddepart"]."</cddepart>";
	$xmlCarregaDados .= " </Dados>";
	$xmlCarregaDados .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlCarregaDados);
	
	$xmlCarrega = getObjectXML($xmlResult);
			
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlCarrega->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlCarrega->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$cartoes  = $xmlCarrega->roottag->tags[0]->tags;
	
	$qtregist = $xmlCarrega->roottag->tags[0]->attributes["QTREGIST"];
	
?>
	strHTML = '';	
	strHTML += '<legend>Cart&otilde;es</legend>';
	strHTML += '<div class="divRegistros">';
	strHTML += '	<table>';
	strHTML += '		<thead>';
	strHTML += '      	<tr>';
	strHTML += '			<th> Conta/dv </th>';
	strHTML += '			<th> Titular do cart&atilde;o </th>';
	strHTML += '			<th> Cooperativa </th>';
	strHTML += '			<th> ADM </th>';
	strHTML += '			<th> SIT </th>';
	strHTML += '			<th> N&uacute;mero do cart&atilde;o </th>';
	strHTML += '     	</tr>';
	strHTML += '   		</thead>';
	strHTML += '    	<tbody>';
	
	detalhe = new Array();
	detalhe[0] = ''; /* Registro 0 não será utilizado no array */
	
	<? $i=0;
	foreach( $cartoes as $cartao ) { $i++; ?>
	strHTML += '      	<tr onFocus="mostra_detalhes(<? echo $i; ?>);return false;" onClick="mostra_detalhes(<? echo $i; ?>);return false;">';
	strHTML += '      		<td><span><? echo getByTagName($cartao->tags,'nrdconta'); ?></span><? echo formataContaDV(getByTagName($cartao->tags,'nrdconta')); ?></td>';	
	strHTML += '      		<td><span><? echo getByTagName($cartao->tags,'nmtitcrd'); ?></span><? echo getByTagName($cartao->tags,'nmtitcrd'); ?></td> ';
	strHTML += '      		<td><span><? echo getByTagName($cartao->tags,'nmrescop'); ?></span><? echo getByTagName($cartao->tags,'nmrescop'); ?></td> ';
	strHTML += '      		<td><span><? echo getByTagName($cartao->tags,'cdadmcrd'); ?></span><? echo formataNumericos("zz9",getByTagName($cartao->tags,'cdadmcrd'),'.'); ?></td>';
	strHTML += '      		<td><span><? echo getByTagName($cartao->tags,'insitcrd'); ?></span><? echo strtoupper(getByTagName($cartao->tags,'insitcrd')); ?></td>';						
	strHTML += '      		<td><span><? echo getByTagName($cartao->tags,'nrcrcard'); ?></span><? echo formataNumericos("9999.9999.9999.9999",getByTagName($cartao->tags,'nrcrcard'),'.'); ?></td>';
	strHTML += '     	</tr>';	
	
	ObjDetalhe = new Object();
	ObjDetalhe.cdagenci = '<? echo getByTagName($cartao->tags,'cdagenci'); ?>';
	<? if ($tipopesq == 2) { ?>
		ObjDetalhe.nmtitcrd = '<? echo getByTagName($cartao->tags,'nmplastc'); ?>';
	<? } else {?>
		ObjDetalhe.nmtitcrd = '<? echo getByTagName($cartao->tags,'nmextttl'); ?>';
	<? } ?>	
	detalhe[<? echo $i;	?>] = ObjDetalhe; 
	<? } ?>	
	strHTML += '	    </tbody>';
	strHTML += '	</table>';
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
	strHTML += '<div id="divCampos">';
	<?	if ($tipopesq == 2) {
			$aux_label = "Nome no cart&atilde;o:";
		} else {
			$aux_label = "Titular da conta:";
		}
	?>
	strHTML += '	<label id="lnmtitcrd" for="nmtitcrd"><? echo $aux_label; ?></label><input type="text" id="nmtitcrd" name="nmtitcrd"/> ';
	strHTML += '	<label id="lcdagenci" for="cdagenci">PA:</label><input type="text" id="cdagenci" name="cdagenci"/> '; 
	strHTML += '</div>';
	$("#divTela > #tabConteudo").html(strHTML);
	formataFormulario();
	mostra_detalhes(1); 
<?	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 		
	    echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","");';
		exit();
	}
	
?>