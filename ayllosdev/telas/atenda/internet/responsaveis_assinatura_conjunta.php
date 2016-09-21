<?php 

	/****************************************************************
	 Fonte: responsaveis_assinatura_conjunta.php
	 Autor: Jean Michel
	 Data : Novembro/2015               �ltima Altera��o: 09/09/2016
	                                                                 
	 Objetivo  : Mostrar responsaveis por assinatura conjunta.
	                                                                  
	 Altera��es: Altera��es referente a melhoria de assinatura conjunta, SD 514239 (Jean Michel).
	 ****************************************************************/	
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
			
	//Consulta de Responsaveis por Assinatura Conjunta
	// Monta o xml de requisi��o
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0058.p</Bo>";
	$xml .= "		<Proc>busca_dados</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";	
	$xml .= "		<idseqttl>0</idseqttl>";
	$xml .= '		<nrcpfcgc></nrcpfcgc>';	
	$xml .= '		<cddopcao>C</cddopcao>';	
	$xml .= '		<nrdctato>0</nrdctato>';	
	$xml .= '		<nrdrowid>?</nrdrowid>';	
	$xml .= '		<flgerlog>FALSE</flgerlog>';	
	$xml .= "	</Dados>";
	$xml .= "</Root>";	                            
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
		
	$registros = $xmlObj->roottag->tags[0]->tags;
	$qtminast =  $xmlObj->roottag->tags[0]->attributes['QTMINAST'];
	
?>

<fieldset>
	<legend> Respons&aacute;veis Assinatura Conjunta </legend>
	<label for="qtminast" ><? echo utf8ToHtml('Quantidade M&iacute;nima de Assinaturas:') ?></label>
	<input type="text" name="qtminast" id="qtminast" value="<?php echo $qtminast; ?>" class="inteiro" maxlength="4"/>
	<div class="divRegistros" id="divRegistrosResponsaveis" style="overflow-y: scroll;">
		<table>
			<thead>
				<tr>
					<th><input type="checkbox" id="chkTodosResp" name="chkTodosResp" onclick="selecionarTodos();" /></th> <!-- headerSort -->
					<th>Conta/dv</th>
					<th>Nome</th>
					<th>C.P.F.</th>
					<th>C.I.</th>
					<th>Vig&ecirc;ncia</th>
					<th>Cargo</th>
				</tr>			
			</thead>
			<tbody>
				<?foreach($registros as $responsaveis) {?>
					<tr>
						<td><input type="checkbox" id="chkRespAssConj['<? echo getByTagName($responsaveis->tags,'nrcpfcgc') ?>']" name="chkRespAssConj" <?php if(getByTagName($responsaveis->tags,'idrspleg') == 1){ echo "checked='checked'";}?> 
						value="<? echo getByTagName($responsaveis->tags,'nrcpfcgc') ?>" /></td>
						<!-- Analisar essa linha, chave primaria de procuradores(cdcooper,tpctrato,nrdconta,nrctremp,nrcpfcgc) -->
						<td style="font-size:11px;"> <? echo getByTagName($responsaveis->tags,'cddconta'); ?> <!-- Conta/dv -->
							<input type="hidden" id="nrdctato<? echo getByTagName($responsaveis->tags,'nrcpfcgc') ?>" name="nrdctato<? echo getByTagName($responsaveis->tags,'nrcpfcgc') ?>" value="<? echo getByTagName($responsaveis->tags,'nrdctato') ?>" />
							<input type="hidden" id="nrdrowid<? echo getByTagName($responsaveis->tags,'nrcpfcgc') ?>" name="nrdrowid<? echo getByTagName($responsaveis->tags,'nrcpfcgc') ?>" value="<? echo getByTagName($responsaveis->tags,'nrdrowid') ?>" />
						</td> 
						<td style="font-size:11px;"><? echo stringTabela(getByTagName($responsaveis->tags,'nmdavali'),23,'maiuscula') ?></td> <!-- Nome     -->
						<td style="font-size:11px;"><? echo getByTagName($responsaveis->tags,'cdcpfcgc') ?></td> <!-- C.P.F.   -->
						<td style="font-size:11px;"><? echo getByTagName($responsaveis->tags,'nrdocava') ?></td> <!-- C.I.     -->
						<td style="font-size:11px;"><? echo getByTagName($responsaveis->tags,'dsvalida') ?></td> <!-- Vig�ncia -->
						<td style="font-size:11px;"><? echo getByTagName($responsaveis->tags,'dsproftl') ?></td> <!-- Cargo -->
					</tr>				
				<? } ?>			
			</tbody>
		</table>
	</div>
</fieldset>
<script>
	$("#qtminast").addClass('campo').css({'width':'40px'});
	layoutPadrao();
</script>