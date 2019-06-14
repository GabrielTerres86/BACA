<? 
/***************************************************************************************
 * FONTE        : simcrp.php				Última alteração: --/--/----
 * CRIAÇÃO      : Lombardi
 * DATA CRIAÇÃO : Março/2016
 * OBJETIVO     : 
 
	 Alterações   : 
  
 
 **************************************************************************************/
?>
 
<?
	session_start();
		
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../class/xmlfile.php');
	
	isPostMethod();		
	  
	// Guardo os parâmetos do POST em variáveis	
	$idcalculo_reciproci = (isset($_POST['idcalculo_reciproci'])) ? $_POST['idcalculo_reciproci'] : 0;
	$idparame_reciproci  = (isset($_POST['idparame_reciproci']))  ? $_POST['idparame_reciproci'] : 0;
	$nrdconta            = (isset($_POST['nrdconta']))            ? $_POST['nrdconta'] : 0;
	$modo                = (isset($_POST['modo']))                ? $_POST['modo'] : 'A';
    $cp_idcalculo        = (isset($_POST['cp_idcalculo']))        ? $_POST['cp_idcalculo'] : '';
    $cp_desmensagem      = (isset($_POST['cp_desmensagem']))      ? $_POST['cp_desmensagem'] : '';
    $cp_totaldesconto    = (isset($_POST['cp_totaldesconto']))    ? $_POST['cp_totaldesconto'] : '';
    $executafuncao       = (isset($_POST['executafuncao']))       ? $_POST['executafuncao'] : '';
    $divanterior         = (isset($_POST['divanterior']))         ? $_POST['divanterior'] : '';
  
    $xmlBuscaConf  = "";
	$xmlBuscaConf .= "<Root>";
	$xmlBuscaConf .= "   <Dados>";
	$xmlBuscaConf .= "	   <idcalculo_reciproci>".$idcalculo_reciproci."</idcalculo_reciproci>";	
	$xmlBuscaConf .= "	   <idparame_reciproci>".$idparame_reciproci."</idparame_reciproci>";	
	$xmlBuscaConf .= "	   <nrdconta>".$nrdconta."</nrdconta>";
	$xmlBuscaConf .= "	   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlBuscaConf .= "   </Dados>";
	$xmlBuscaConf .= "</Root>";
  
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlBuscaConf, "SIMCRP", "BUSCA_CONF_GERAL", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjBuscaConf = getObjectXML($xmlResult);
	
  $vr_qtmes_retorno_reciproci = $xmlObjBuscaConf->roottag->tags[0]->cdata;
  $vr_flgreversao_tarifa      = $xmlObjBuscaConf->roottag->tags[1]->cdata;
  $vr_flgdebito_reversao      = $xmlObjBuscaConf->roottag->tags[2]->cdata;
  $registros                  = $xmlObjBuscaConf->roottag->tags[3]->tags;
  $qtdregist                  = $xmlObjBuscaConf->roottag->tags[4]->cdata;
  
?>
<script type="text/javascript" src="../../telas/simcrp/simcrp.js"></script>

<input type="hidden" value="idparame_reciproci" value="<?$idparame_reciproci?>">

<form name="frmImprimir" id="frmImprimir" style="display:none">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
	<input name="nmarquiv" id="nmarquiv" type="hidden" value="" />
</form>

<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><?echo $tituloTela;?></td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="$('#<?echo $cp_desmensagem?>').val('NOK');fechaRotina($('#divUsoGenerico'),$('#divRotina')); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>     
					</td> 
				</tr>    
				<tr>
					<td class="tdConteudoTela" align="center">	
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td>
									<table border="0" cellspacing="0" cellpadding="0">
										<tr>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" onClick="acessaOpcaoAba(4,0,'@')" class="txtNormalBold">Simulação do Cálculo da Reciprocidade para Desconto:</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divCabecalho" style="align: center;">
										<table>
										  <thead>
											<tr>
											  <th width="320px" align="left">Indicador</th>
											  <th width="88px">Tipo</th>
											  <th width="98px">Contratado/Mês</th>
											  <th width="80px">%Desconto</th>
											  <th width="245px">Realizado/Mês (Últimos 3 meses)</th>
											<tr>
										  </thead>
										</table>
									  </div>
									  <div id="divSimcrp" style="width: 100%; height: 90px; align: center; overflow: scroll; overflow-x: hidden;">
										<table style="width: 834px">
										  <tbody>
										  <?
											$i = 0;
											foreach($registros as $registro) {
											  ?> 
											  <tr>
												<td class="campo" >
												  <input type="text" id="idindicador<?echo $i?>" style="width:30px; text-align:right;" readonly value="<? echo getByTagName($registro->tags,'idindicador')?>">
												  <input type="hidden" id="pertolera<?echo $i?>" value="<? echo getByTagName($registro->tags,'pertolera')?>">                              
												</td>
												<td class="campo" ><input type="text" id="nmindicador<?echo $i?>" readonly size="50" value="<? echo getByTagName($registro->tags,'nmindicador')?>"></td>
												<td class="campo" ><input type="text" id="tpindicador<?echo $i?>" readonly size="10" value="<? echo getByTagName($registro->tags,'tpindicador')?>"></td>												
												<?if(getByTagName($registro->tags,'tpindicador') == "Adesão") { ?>
												  <td>
													<select class="campo" id="vlcontrata<?echo $i?>" <?if ($modo == 'C' || $modo == 'c') {?>readonly disabled<?} else {?> onChange="pct_desconto_indicador('<?echo $i?>','<?echo $idcalculo_reciproci?>','<?echo $idparame_reciproci?>','<?echo $qtdregist?>');"<? } ?> style="width:100px;">
													  <option value="1" <?if(getByTagName($registro->tags,'vlcontrata') == "Sim"){?>selected<?}?>>Sim</option>
													  <option value="0" <?if(getByTagName($registro->tags,'vlcontrata') <> "Sim"){?>selected<?}?>>Não</option>
													</select>
												  </td>
												<?}else{?>
												  <td class="campo" ><input type="text" class="clsCampoVlcontrata <?if(getByTagName($registro->tags,'tpindicador') == "Moeda"){?>moeda<?}else{?>qtd<?}?>" id="vlcontrata<?echo $i?>" style="text-align: right;" size="12" <?if ($modo == 'C' || $modo == 'c') {?>readonly<?} else {?> onkeyup="pct_desconto_indicador('<?echo $i?>','<?echo $idcalculo_reciproci?>','<?echo $idparame_reciproci?>','<?echo $qtdregist?>');"<?}?> value="<? echo getByTagName($registro->tags,'vlcontrata')?>"></td>
												<?}?>
												<td class="campo" ><input type="text" id="perdesconto<?echo $i?>" style="width:70px; text-align:right" readonly value="<? echo getByTagName($registro->tags,'perdesconto')?>"></td>
												<td class="campo" ><input type="text" id="ocorrencia_1<?echo $i?>" style="width:70px; text-align:right" readonly value="<? echo getByTagName($registro->tags,'ocorrencia_1')?>"></td>
												<td class="campo" ><input type="text" id="ocorrencia_2<?echo $i?>" style="width:70px; text-align:right" readonly value="<? echo getByTagName($registro->tags,'ocorrencia_2')?>"></td>
												<td class="campo" ><input type="text" id="ocorrencia_3<?echo $i?>" style="width:70px; text-align:right" readonly value="<? echo getByTagName($registro->tags,'ocorrencia_3')?>"></td>
											  </tr>
										   <? $i++;
											}?>
										  </tbody>
										</table>
									</div>
								  <br>
								  <div style="width: 887px;">
                    <label style="margin-left: 419px;" >Total desconto:</label>
                    <input class="per campo" id="totaldesconto" type="text" style="text-align:right; width: 80px;" readonly value="<? echo $perdesmax?>">
                    <a href="#" style="width: 210px;" class="botao" id="btRelacUlt12Ocorr" onClick="emite_crrl713('<?echo $nrdconta?>','<?echo $idcalculo_reciproci?>','<?echo $idparame_reciproci?>');">Relação últimas 12 ocorrências</a>
                  </div>
								  <div style="margin-top:30px;"></div>
								  <div>
									<table style="width:100%; border:10xp">
									  <tr>
										<td style="width:50%; text-align:right; padding: 5px;">
										  <label for="retorno_reciproci"> <? echo utf8ToHtml('Retorno de Reciprocidade:') ?></label>
										</td>
										<td style="width:50%;">
										  <select class="campo" id="retorno_reciproci" style="width:70px;">
											 <option value="3">3</option>
											 <option value="6">6</option>
											 <option value="9">9</option>
											 <option value="12">12</option>
										  </select>
										</td>
									  </tr>
									  <tr>
										<td style="width:50%; text-align:right; padding: 5px;">
										  <label for="reversao_tarifa"> <? echo utf8ToHtml('Revers&atilde;o da Tarifa:') ?></label>
										</td>
										<td style="width:50%;">
										  <select class="campo" id="reversao_tarifa" style="width:70px;">
											<option value="1">Sim</option>
											<option value="0">Não</option>
										  </select>
										</td>
									  </tr>
									  <tr>
										<td style="width:50%; text-align:right; padding: 5px;">
										  <label for="debito_reajuste_reciproci"><? echo utf8ToHtml('D&eacute;bito de reajuste Reciprocidade:') ?></label>
										</td>
										<td style="width:50%;">
										  <select class="campo" id="debito_reajuste_reciproci" style="width:70px;">
											 <option value="1">Sim</option>
											 <option value="0">Não</option>
										  </select>
										</td>
									  </tr>
									</table>
								  </div>
								  <div style="margin-top:20px;"></div>
								  <div>
									<table>
									  <tr>
										<td width="70px" align="center"> <a href="#" class="botao" id="btVoltar"onClick="$('#<?echo $cp_desmensagem?>').val('NOK');fechaRotina($('#divUsoGenerico'),$('#divRotina')); return false;">Voltar</a></td>
										<?if (strtoupper($modo) != "C") {?>
										  <td width="70px" align="center"> <a href="#" class="botao" id="btConfirmar" onClick="confirmar('<?echo $qtdregist?>','<?echo $idparame_reciproci?>', '<?echo $idcalculo_reciproci?>', '<?echo $modo?>','<?echo $cp_idcalculo?>','<?echo $cp_desmensagem?>','<?echo $cp_totaldesconto?>', '<?echo $executafuncao?>', '<?echo $divanterior?>');" >Confirmar</a> </td>
										<?}?>                                                                                                                                                                                                    
									  </tr>                                                                                                                                                                                                      
									</table>
								  </div>
								  <br>
								</td>
							</tr>
						</table>			    
					</td> 
				</tr>
			</table>
		</td>
	</tr>
</table>
<script language="Javascript">
$('.per').setMask('DECIMAL','zz9,99','.','');
$('.qtd').setMask('DECIMAL','zzz.zzz.zzz.zz9',',','');

if ("<? echo strtoupper($modo)?>" == "C"){
  $('#retorno_reciproci').prop('readonly',true).prop('disabled',true);
  $('#reversao_tarifa').prop('readonly',true).prop('disabled',true);
  $('#debito_reajuste_reciproci').prop('readonly',true).prop('disabled',true);
}

calculaTotalDesconto(<?echo $qtdregist?>);

$('#retorno_reciproci').val(<?echo $vr_qtmes_retorno_reciproci?>);
$('#reversao_tarifa').val(<?echo $vr_flgreversao_tarifa?>);
$('#debito_reajuste_reciproci').val(<?echo $vr_flgdebito_reversao?>);

</script>