<?php 

	/****************************************************************
	 Fonte: responsaveis_assinatura_conjunta.php
	 Autor: Jean Michel
	 Data : Novembro/2015               Última Alteração: 09/09/2016
	                                                                 
	 Objetivo  : Mostrar responsaveis por assinatura conjunta.
	                                                                  
	 Alteraçães: Alterações referente a melhoria de assinatura conjunta, SD 514239 (Jean Michel).
	 
	             05/09/2017 - Alteração referente ao Projeto Assinatura conjunta (Proj 397)
	 ****************************************************************/	
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
			
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"H")) <> "") {
		exibeErro($msgError);		
	}
	
	/*Validacao do presposto master*/
	$strnomacao = 'BUSCA_PREPOSTOS_MASTER';

	// Montar o xml para requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "<Dados>";
	$xml .= "<cdcooper>".$glbvars['cdcooper']."</cdcooper>";
	$xml .= "<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "</Dados>";
	$xml .= "</Root>";
	
	$xmlNewResult = mensageria($xml, "ATENDA" , $strnomacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");	
	$xml_n_geral = simplexml_load_string($xmlNewResult);

	function validaMaster($xml_n_geral, $nrcpfcgc){
		foreach($xml_n_geral as $newxml){
			$nrcpfcgc = intval(preg_replace("/[^0-9]/","", $nrcpfcgc));
			if($nrcpfcgc == $newxml->nrcpf){
				return true;
				break;
			}
		}
	}
	
	//Consulta de Responsaveis por Assinatura Conjunta
	// Monta o xml de requisição
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
	
	// Se ocorrer um erro, mostra crítica
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
					<th style='width: 50px;'>Conta/dv</th>
					<th style='width: 60px;'>Nome</th>
					<th>C.P.F.</th>
					<th>C.I.</th>
					<th>Vig&ecirc;ncia</th>
					<th style='width: 70px;'>Cargo</th>
					<th>Preposto Master</th>
				</tr>			
			</thead>
			<tbody>
				<?foreach($registros as $responsaveis) {?>
					<?php $updateMaster = "validaPrepostoMaster('".$nrdconta."','".stringTabela(getByTagName($responsaveis->tags,'nmdavali'),23,'maiuscula')."', '".getByTagName($responsaveis->tags,'nrcpfcgc')."')"; ?>
					<?php $validaRespAssConj = "validaRespAssConj(".$nrdconta.",".getByTagName($responsaveis->tags,'nrcpfcgc').")"; ?>
					<tr>
						<td><input onclick="<?php echo $validaRespAssConj?>" type="checkbox" id="chkRespAssConj<? echo getByTagName($responsaveis->tags,'nrcpfcgc') ?>" name="chkRespAssConj" <?php if(getByTagName($responsaveis->tags,'idrspleg') == 1){ echo "checked='checked'";}?> 
						value="<? echo getByTagName($responsaveis->tags,'nrcpfcgc') ?>" /></td>
						<!-- Analisar essa linha, chave primaria de procuradores(cdcooper,tpctrato,nrdconta,nrctremp,nrcpfcgc) -->
						<td style="font-size:11px; width:50px"> <? echo getByTagName($responsaveis->tags,'cddconta'); ?> <!-- Conta/dv -->
							<input type="hidden" id="nrdctato<? echo getByTagName($responsaveis->tags,'nrcpfcgc') ?>" name="nrdctato<? echo getByTagName($responsaveis->tags,'nrcpfcgc') ?>" value="<? echo getByTagName($responsaveis->tags,'nrdctato') ?>" />
							<input type="hidden" id="nrdrowid<? echo getByTagName($responsaveis->tags,'nrcpfcgc') ?>" name="nrdrowid<? echo getByTagName($responsaveis->tags,'nrcpfcgc') ?>" value="<? echo getByTagName($responsaveis->tags,'nrdrowid') ?>" />
						</td> 
						<td style="font-size:11px;"><? echo stringTabela(getByTagName($responsaveis->tags,'nmdavali'),23,'maiuscula') ?></td> <!-- Nome     -->
						<td style="font-size:11px;"><? echo getByTagName($responsaveis->tags,'cdcpfcgc') ?></td> <!-- C.P.F.   -->
						<td style="font-size:11px;"><? echo getByTagName($responsaveis->tags,'nrdocava') ?></td> <!-- C.I.     -->
						<td style="font-size:11px;"><? echo getByTagName($responsaveis->tags,'dsvalida') ?></td> <!-- Vigência -->
						<td style="font-size:11px; width:50px;"><? echo getByTagName($responsaveis->tags,'dsproftl') ?></td> <!-- Cargo -->
						<td style=''><input onclick="<?php echo $updateMaster?>" type="checkbox" id="chkMasterAssConj<? echo getByTagName($responsaveis->tags,'nrcpfcgc') ?>" class="chkMasterAssConj" name="chkMasterAssConj" <?php if(validaMaster($xml_n_geral, getByTagName($responsaveis->tags,'nrcpfcgc'))){ echo "checked='checked'";}?> 
						value="1" /></td>
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