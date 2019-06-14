<? 
/*!
 * FONTE        : busca_rendimentos.php
 * CRIAÇÃO      : Adriano
 * DATA CRIAÇÃO : 05/12/2011
 * OBJETIVO     : Rotina para buscar os rendimentos.
 *
 * ALTERACOES   : 20/10/2015 - Reformulacao cadastral (Gabriel-RKAM).
 */
?>
 
<?	
    session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();		
	
	
	if (!isset($_POST['nrdrowid']) ) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro','fechaRotina(divRotina)',false);	
			
	$nrdrowid = $_POST['nrdrowid'] == '' ?  0  : $_POST['nrdrowid'];	
	$nriniseq = $_POST['nriniseq'] == '' ?  0  : $_POST['nriniseq'];	
	$nrregist = $_POST['nrregist'] == '' ?  0  : $_POST['nrregist'];
	
	
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0075.p</Bo>";
	$xml .= "		<Proc>Busca_Rendimentos</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>"; 
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<nrdrowid>".$nrdrowid."</nrdrowid>";
	$xml .= "		<nriniseq>".$nriniseq."</nriniseq>";
	$xml .= "		<nrregist>".$nrregist."</nrregist>";
	$xml .= "		<flgpagin>yes</flgpagin>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	
	$registros = $xmlObjeto->roottag->tags[0]->tags;
	$qtregist = $xmlObjeto->roottag->tags[0]->attributes["QTREGIST"];			
	?>
	
	var strHTML = '';		 

	
	strHTML = '<fieldset id="Outros Rendimentos">';
	strHTML += '<legend> Outros Rendimentos </legend>';
	strHTML += '<div class="divRegistros">';
	strHTML += '  <table>';
	strHTML += '    <thead>';
	strHTML += '       <tr>';
	strHTML += '          <th>Origem</th>';
	strHTML += '          <th>Valor</th>';
	strHTML += '       </tr>';
	strHTML += '    </thead>';
	strHTML += '    <tbody>';
	<? foreach( $registros as $result ) {  $qtlinhas = $qtlinhas + 1   	?>
	strHTML += '     	       <tr>'; 	
	strHTML += '     	   	     <td><span><? echo getByTagName($result->tags,'dsorigem'); ?></span><? echo getByTagName($result->tags,'dsorigem'); ?> </td>';
	strHTML += '      	         <td><span><? echo getByTagName($result->tags,'vldrendi'); ?></span><? echo number_format(str_replace(",",".",getByTagName($result->tags,'vldrendi')),2,",","."); ?> </td>';
	strHTML += '				 <input type="hidden" id="tpdrendi" name="tpdrendi" value="<? echo getByTagName($result->tags,'tpdrendi') ?>" />';
	strHTML += '				 <input type="hidden" id="vldrendi" name="vldrendi" value="<? echo formataNumericos('zzz.zzz.zz9',getByTagName($result->tags,'vldrendi'),'.') ?>" />';
	strHTML += '				 <input type="hidden" id="dsdrendi" name="dsdrendi" value="<? echo getByTagName($result->tags,'dsdrendi') ?>" />';
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
	echo "$('#divRendimentos').html();";
	echo "$('#divRendimentos').html(strHTML);";
	echo "tabela('".$qtlinhas."');";
	echo "$('#frmDadosComercial').css('display','none');";
	echo "$('#divBotoes').css('display','none');";
	echo "$('#divRendimentos').css('display','block');";
	echo "$('#frmJustificativa').css('display','block');";
	echo "$('#divBotoesRendi').css('display','block');";
	echo "$('#divConteudoOpcao').css('height','280');";
	echo "bloqueiaFundo(divRotina)";
	
	
?>