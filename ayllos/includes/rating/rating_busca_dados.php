<?php 

	//*****************************************************************************//
	//*** Fonte: rating_busca_dados.php											***//
	//*** Autor: David															***//
	//*** Data : Abril/2010                   Última Alteração: 09/08/2016		***//
	//***																		***//
	//*** Objetivo  : Carregar dados do rating do cooperado						***//	
	//***																		***//
	//*** Alterações: 22/10/2010 - Incluir novo parametro para a funcao			***//
	//***                          getDataXML (David).							***//
	//***																		***//
	//***		      06/04/2011 - Realizado alteracao na procedure				***// 
	//***						   sequencia_rating para atender a nova			***//
	//***						   tabela do rating (Adriano).					***//
	//***																		***//
	//***             13/04/2015 - Consultas automatizadas para o limite		***//
	//***                          de credito (Jonata-RKAM).					***//
	//***																		***//
	//***             25/07/2016 - Corrigi o uso de variaveis nao				***//
	//***                          declaradas. SD 479874 (Carlos R.)			***//
	//***																		***//
	//***             09/08/2016 - Alterei a forma de declaracao das variaveis	***//
	//***                          utilizadas na inclusao.SD 501912 (Carlos R.)	***//
	//***																		***//
	//*****************************************************************************//
	
	// Monta o xml de requisição
	$xmlGetRating  = "";
	$xmlGetRating .= "<Root>";
	$xmlGetRating .= "  <Cabecalho>";
	$xmlGetRating .= "    <Bo>b1wgen0043.p</Bo>";
	$xmlGetRating .= "    <Proc>busca_dados_rating</Proc>";
	$xmlGetRating .= "  </Cabecalho>";
	$xmlGetRating .= "  <Dados>";
	$xmlGetRating .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetRating .= "    <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetRating .= "    <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetRating .= "    <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetRating .= "    <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetRating .= "    <idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGetRating .= "    <nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetRating .= "    <idseqttl>1</idseqttl>";
	$xmlGetRating .= "    <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetRating .= "  </Dados>";
	$xmlGetRating .= "</Root>";	
	
	$nrinfcad = ( isset($nrinfcad) ) ? $nrinfcad : 0;
	$nrpatlvr =	( isset($nrpatlvr) ) ? $nrpatlvr : 0;
	$nrperger =	( isset($nrperger) ) ? $nrperger : 0;
	$vltotsfn =	( isset($vltotsfn) ) ? $vltotsfn : 0;
	$perfatcl =	( isset($perfatcl) ) ? $perfatcl : 0;
	$nrgarope =	( isset($nrgarope) ) ? $nrgarope : 0;
	$nrliquid =	( isset($nrliquid) ) ? $nrliquid : 0;

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetRating,false);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjRating = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjRating->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjRating->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$itens   = $xmlObjRating->roottag->tags[1]->tags;
	$qtItens = count($itens);
	
	// Se não for uma inclusão, variáveis recebem dados no script que está chamando está include
	if ($cdOperacao == "I") {		
		$nrinfcad = $xmlObjRating->roottag->tags[0]->tags[0]->tags[0]->cdata;
		$nrpatlvr = $xmlObjRating->roottag->tags[0]->tags[0]->tags[1]->cdata;
		$nrperger = $xmlObjRating->roottag->tags[0]->tags[0]->tags[2]->cdata;
		$vltotsfn = number_format(str_replace(",",".",$xmlObjRating->roottag->tags[0]->tags[0]->tags[3]->cdata),2,",",".");
		$perfatcl = number_format(str_replace(",",".",$xmlObjRating->roottag->tags[0]->tags[0]->tags[4]->cdata),2,",",".");
		$nrgarope = $xmlObjRating->roottag->tags[0]->tags[0]->tags[5]->cdata;
		$nrliquid = $xmlObjRating->roottag->tags[0]->tags[0]->tags[6]->cdata;		
	}
	
	$inpessoa = $xmlObjRating->roottag->tags[0]->tags[0]->tags[7]->cdata;
?>
<div id="divDadosRating">
	<form action="" name="frmDadosRating" id="frmDadosRating" method="post" onSubmit="return false;">
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="30" valign="top">
				<table width="100%" border="0" cellpadding="0" cellspacing="2">
					<tr>
						<td width="150">
							<table width="100%" border="0" cellpadding="0" cellspacing="0">
								<tr>
									<td height="1" style="background-color:#999999;"></td>
								</tr>
							</table>
						</td>								
						<td height="18" class="txtNormalBold" align="center" style="background-color: #E3E2DD;">RATING</td>
						<td width="150">
							<table width="100%" border="0" cellpadding="0" cellspacing="0">
								<tr>
									<td height="1" style="background-color:#999999;"></td>
								</tr>
							</table>								
						</td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td>
				<table width="100%" border="0" cellpadding="0" cellspacing="2">
					<tr>	
						<td width="170" class="txtNormalBold" align="right">Garantia:&nbsp;</td>
						<td class="txtNormal">
							<select name="nrgarope" class="campo" id="nrgarope" style="width: 280px;">								
							</select>
						</td>						
					</tr>
				</table>
			</td>
		</tr>
		<? if ($inprodut != 3) { // Se nao for limite de credito ?>
			<tr>
				<td>
					<table width="100%" border="0" cellpadding="0" cellspacing="2">
						<tr>	
							<td width="170" class="txtNormalBold" align="right">Informa&ccedil;&otilde;es Cadastrais:&nbsp;</td>
							<td class="txtNormal">
								<select name="nrinfcad" class="campo" id="nrinfcad" style="width: 280px;">								
								</select>
							</td>						
						</tr>
					</table>
				</td>
			</tr>
		<? } else { ?>
			<input type="hidden" name="nrinfcad" id="nrinfcad" value="1">
		<? } ?>
		<tr>
			<td>
				<table width="100%" border="0" cellpadding="0" cellspacing="2">
					<tr>	
						<td width="170" class="txtNormalBold" align="right">Liquidez das Garantias:&nbsp;</td>
						<td class="txtNormal">
							<select name="nrliquid" class="campo" id="nrliquid" style="width: 280px;">								
							</select>
						</td>						
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td>
				<table width="100%" border="0" cellpadding="0" cellspacing="2">
					<tr>	
						<td width="170" class="txtNormalBold" align="right">Patrim&ocirc;nio Pessoal Livre:&nbsp;</td>
						<td class="txtNormal">
							<select name="nrpatlvr" class="campo" id="nrpatlvr" style="width: 280px;">								
							</select>
						</td>						
					</tr>
				</table>
			</td>
		</tr>
		<? if ($inprodut != 3) { // Se nao for limite de credito ?>
		<tr>
			<td>
				<table width="100%" border="0" cellpadding="0" cellspacing="2">
					<tr>	
						<td width="170" class="txtNormalBold" align="right">Valor Total SFN c/ Coop:&nbsp;</td>
						<td class="txtNormal" colspan="3"><input name="vltotsfn" type="text" id="vltotsfn" style="width: 100px; text-align: right;" class="campo"/></td>
					</tr>
				</table>
			</td>
		</tr>
		<? } else { ?>
			<input type="hidden" name="vltotsfn" id="vltotsfn" value="0">
		<? } ?>
	</table>
	<div id="divRatingPJ">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td>
					<table width="100%" border="0" cellpadding="0" cellspacing="2">
						<tr>	
							<td width="170" class="txtNormalBold" align="right">% Faturamento &uacute;nico cliente:&nbsp;</td>
							<td class="txtNormal" colspan="3"><input name="perfatcl" type="text" id="perfatcl" style="width: 100px; text-align: right;" class="campo"/></td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td>
					<table width="100%" border="0" cellpadding="0" cellspacing="2">
						<tr>	
							<td width="170" class="txtNormalBold" align="right">Percep&ccedil;&atilde;o geral (Empresa):&nbsp;</td>
							<td class="txtNormal">
								<select name="nrperger" class="campo" id="nrperger" style="width: 280px;">									
								</select>
							</td>
						</tr>
					</table>
				</td>
			</tr>	
		</table>
	</div>
	</form>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="8"></td>
		</tr>
		<tr>
			<td align="center">							
				<table border="0" cellpadding="0" cellspacing="3">					
					<tr>						
						<td><input type="image" name="btnCancelaRating" id="btnCancelaRating" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="return false;"/></td>					
						<td width="8"></td>	
						<td><input type="image" name="btnValidaRating" id="btnValidaRating" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="<?php if ($cdOperacao == "C") { echo "eval(fncRatingContinue)"; } else { echo "validaDadosRating('".$glbvars["cdcooper"]."' , '".$operacao."' , '".$inprodut."')"; } ?>;return false;"/></td>											
					</tr>
				</table>
			</td>
		</tr>						
	</table>
</div>
<script type="text/javascript">
$("#vltotsfn","#frmDadosRating").setMask("DECIMAL","zzz.zzz.zz9,99","","");
$("#perfatcl","#frmDadosRating").setMask("DECIMAL","zz9,99","","");

// Gerar options para manipulação dos selects
$("#nrgarope","#frmDadosRating").append("<option value='0' selected>-- Selecione --</option>");
$("#nrliquid","#frmDadosRating").append("<option value='0' selected>-- Selecione --</option>");
$("#nrpatlvr","#frmDadosRating").append("<option value='0' selected>-- Selecione --</option>");
$("#nrperger","#frmDadosRating").append("<option value='0' selected>-- Selecione --</option>");

<? if ($inprodut != 3) { // Se nao for limite de credito ?>
	$("#nrinfcad","#frmDadosRating").append("<option value='0' selected>-- Selecione --</option>");
<? } ?>

<?php

for ($i = 0; $i < $qtItens; $i++) {
	$nminput = "";
	
	
	if (($inpessoa == 1 && $itens[$i]->tags[0]->cdata == 2 && $itens[$i]->tags[1]->cdata == 2) ||
		($inpessoa >= 2 && $itens[$i]->tags[0]->cdata == 4 && $itens[$i]->tags[1]->cdata == 2)) {  
		$nminput = "nrgarope";
	}
	
	if ((($inpessoa == 1 && $itens[$i]->tags[0]->cdata == 1 && $itens[$i]->tags[1]->cdata == 4) ||
		($inpessoa >= 2 && $itens[$i]->tags[0]->cdata == 3 && $itens[$i]->tags[1]->cdata == 3))) {
		$nminput = "nrinfcad";
	}
	
	if (($inpessoa == 1 && $itens[$i]->tags[0]->cdata == 2 && $itens[$i]->tags[1]->cdata == 3) ||
		($inpessoa >= 2 && $itens[$i]->tags[0]->cdata == 4 && $itens[$i]->tags[1]->cdata == 3)) {
		$nminput = "nrliquid";
	}
	
	if (($inpessoa == 1 && $itens[$i]->tags[0]->cdata == 1 && $itens[$i]->tags[1]->cdata == 8) ||
		($inpessoa >= 2 && $itens[$i]->tags[0]->cdata == 3 && $itens[$i]->tags[1]->cdata == 9)) {
		$nminput = "nrpatlvr";
		
	}
	
	if ($inpessoa >= 2 && $itens[$i]->tags[0]->cdata == 3 && $itens[$i]->tags[1]->cdata == 11) {
		$nminput = "nrperger";
	}
	
	if ($nminput <> "")  {	
		if ($inprodut == 3 && $nminput == 'nrinfcad') { // Se for limite de credito e for campo Inf. Cadastrais
			if ($itens[$i]->tags[2]->cdata == $nrinfcad) {
				echo 'dsinfcad = "' . $itens[$i]->tags[3]->cdata . '";';
			}
		} else {
			echo '$("#'.$nminput.'","#frmDadosRating").append("<option value=\''.$itens[$i]->tags[2]->cdata.'\'>'.$itens[$i]->tags[2]->cdata.' - '.$itens[$i]->tags[3]->cdata.'</option>");';
		}
	}
	
}
	
// Carregas dados do rating do cooperado
echo '$("#nrgarope","#frmDadosRating").val("'.$nrgarope.'");';
echo '$("#nrliquid","#frmDadosRating").val("'.$nrliquid.'");';
echo '$("#nrpatlvr","#frmDadosRating").val("'.$nrpatlvr.'");';
echo '$("#vltotsfn","#frmDadosRating").val("'.number_format(str_replace(",",".",$vltotsfn),2,",",".").'");';
echo '$("#perfatcl","#frmDadosRating").val("'.number_format(str_replace(",",".",$perfatcl),2,",",".").'");';
echo '$("#nrperger","#frmDadosRating").val("'.$nrperger.'");';

if ($inprodut != 3) { // Se nao for limite de credito 
	echo '$("#nrinfcad","#frmDadosRating").val("'.$nrinfcad.'");';
}

if ($cdOperacao == "C") {
	echo '$("#nrgarope","#frmDadosRating").desabilitaCampo();';
	echo '$("#nrliquid","#frmDadosRating").desabilitaCampo();';
	echo '$("#nrpatlvr","#frmDadosRating").desabilitaCampo();';
	echo '$("#vltotsfn","#frmDadosRating").desabilitaCampo();';
	echo '$("#perfatcl","#frmDadosRating").desabilitaCampo();';
	echo '$("#nrperger","#frmDadosRating").desabilitaCampo();';
	
	if ($inprodut != 3) { // Se nao for limite de credito 
		echo '$("#nrinfcad","#frmDadosRating").desabilitaCampo();';
	}
}

// Configura div para pessoa jurídica
echo '$("#divRatingPJ").css("display","'.($inpessoa == 1 ? "none" : "block").'");';		
?>
$("#divDadosRating").css("display","none");
</script>
