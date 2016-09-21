<? 
/***************************************************************************************
 * FONTE        : CONFRP.php				Última alteração: --/--/----
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
	$idparame_reciproci    = (isset($_POST['idparame_reciproci']))    ? $_POST['idparame_reciproci']    : 0;
$dslogcfg              = (isset($_POST['dslogcfg']))              ? $_POST['dslogcfg'] : 0;
	$inpessoa              = (isset($_POST['inpessoa']))              ? $_POST['inpessoa']              : 0;
	$cdproduto             = (isset($_POST['cdproduto']))             ? $_POST['cdproduto']             : 0;
    $cp_idparame_reciproci = (isset($_POST['cp_idparame_reciproci'])) ? $_POST['cp_idparame_reciproci'] : 0;
    $cp_desmensagem        = (isset($_POST['cp_desmensagem']))        ? $_POST['cp_desmensagem']        : '';
	$cp_deslogconfrp       = (isset($_POST['cp_deslogconfrp']))       ? $_POST['cp_deslogconfrp'] : '';
    $executafuncao         = (isset($_POST['executafuncao']))         ? $_POST['executafuncao']         : '';
    $divanterior           = (isset($_POST['divanterior']))           ? $_POST['divanterior']           : '';
	$consulta              = (isset($_POST['consulta']))              ? $_POST['consulta']              : 'N';
    $tela_anterior         = (isset($_POST['tela_anterior']))         ? $_POST['tela_anterior']         : 'Cobranca';
	$senha_coordenador     = (isset($_POST['senha_coordenador']))     ? $_POST['senha_coordenador']     : 'N';
	
    $xmlBuscaConf  = "";
	$xmlBuscaConf .= "<Root>";
	$xmlBuscaConf .= "   <Dados>";
	$xmlBuscaConf .= "	   <idparame_reciproci>".$idparame_reciproci."</idparame_reciproci>";	
	$xmlBuscaConf .= "	   <inpessoa>".$inpessoa."</inpessoa>";
	$xmlBuscaConf .= "	   <cdproduto>".$cdproduto."</cdproduto>";	
	$xmlBuscaConf .= "	   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlBuscaConf .= "   </Dados>";
	$xmlBuscaConf .= "</Root>";
  
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlBuscaConf, "CONFRP", "BUSCA_CONF", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjBuscaConf = getObjectXML($xmlResult);
	
  $registros = $xmlObjBuscaConf->roottag->tags[0]->tags;
  $perdesmax = $xmlObjBuscaConf->roottag->tags[1]->cdata;
  $qtdregist = $xmlObjBuscaConf->roottag->tags[2]->cdata;
  
?>
<script type="text/javascript" src="../../telas/confrp/confrp.js"></script>

<input type="hidden" id="hd_qtdregis" value="<?echo $qtdregist;?>">
<input type="hidden" id="hd_idparame_reciproci" value="<?echo $idparame_reciproci;?>">
<input type="hidden" id="hd_cp_idparame_reciproci" value="<?echo $cp_idparame_reciproci;?>">
<input type="hidden" id="hd_cp_desmensagem" value="<?echo $cp_desmensagem;?>">
<input type="hidden" id="hd_executafuncao" value="<?echo $executafuncao;?>">
<input type="hidden" id="hd_divanterior" value="<?echo $divanterior;?>">

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
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="$('#<?echo $cp_desmensagem?>').val('NOK');fechaRotina($('#divUsoGenerico')<?if ($divanterior != ""){?>,$('#<?echo $divanterior;?>')<?}?>); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" onClick="acessaOpcaoAba(4,0,'@')" class="txtNormalBold"><?if($tela_anterior != 'pacote_tarifas') {?>Configuração do cálculo da Reciprocidade vinculada ao convênio:<?}else{?>Configuração do cálculo da Reciprocidade vinculada ao Pacote de Tarifas:<?}?></a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divCabecalho" style="width: 834px; align: center; left: 10px;">
									<table>
									  <thead>
										<tr>
										  <th align="center" width="43px">Ativo?</th>
										  <th width="43px">Indicador</th>
										  <th width="<?if($tela_anterior != 'pacote_tarifas') {?>288px<?}else{?>330px<?}?>"></th>
										  <th width="88px">Tipo</th>
										  <th width="98px">Valor Mínimo</th>
										  <th width="98px">Valor Máximo</th>
										  <th width="<?if($tela_anterior != 'pacote_tarifas') {?>53px<?}else{?>100px<?}?>"><?if($tela_anterior == 'pacote_tarifas') {echo "% Desc. Máx.";} else { echo "%Score";}?></th>
										  <?if($tela_anterior != 'pacote_tarifas') {?><th width="83px">%Tolerância</th><?}?>
										<tr>
									  </thead>
									</table>
								  </div>
								  <div id="divConfrp" style="width: 100%; height: 158px; align: center; overflow: scroll; overflow-x: hidden;">
									<table style="width: 834px">
									  <tbody>
									  <?
										$i = 0;
										foreach($registros as $registro) {
										  $tpindicador = getByTagName($registro->tags,'tpindicador');
										  ?> 
										  <tr>
											<td><table><tr><td align="center" width="50px"><input id="ativo<?echo $i?>" <?if ((getByTagName($registro->tags,'flgativo') == 1) || ($tela_anterior == 'pacote_tarifas' && strtoupper($consulta) == "N")) {?>checked<?} if($consulta == "S" || $consulta == "s") {?> disabled="disabled" <?}?> type="checkbox" size="13"></td></tr></table></td>
											<td class="campo" ><input type="text" id="idindicador<?echo $i?>" style="text-align:right;" readonly size="3" value="<? echo getByTagName($registro->tags,'idindicador')?>"></td>
											<td class="campo" ><input type="text" id="nmindicador<?echo $i?>" readonly size="50" value="<? echo getByTagName($registro->tags,'nmindicador')?>"></td>
											<td class="campo" ><input type="text" id="tpindicador<?echo $i?>" readonly size="10" value="<? echo $tpindicador?>"></td>
											<td class="campo" ><input type="text" class="<?if($tpindicador == 'Quantidade'){?>qtd<?} if($tpindicador == 'Moeda'){?>moeda<?}?>" id="vlminimo<?echo $i?>" style="text-align:right" size="12" <?if (getByTagName($registro->tags,'tpindicador') == 'Adesão' || strtoupper($consulta) == 'S') {?>readonly<?}?> value="<? echo getByTagName($registro->tags,'vlminimo')?>"></td>
											<td class="campo" ><input type="text" class="<?if($tpindicador == 'Quantidade'){?>qtd<?} if($tpindicador == 'Moeda'){?>moeda<?}?>" id="vlmaximo<?echo $i?>" style="text-align:right" size="12" <?if (getByTagName($registro->tags,'tpindicador') == 'Adesão' || strtoupper($consulta) == 'S') {?>readonly<?}?> value="<? echo getByTagName($registro->tags,'vlmaximo')?>"></td>
											<td class="campo" ><input type="text" class="per" id="perscore<?echo $i?>" style="text-align:right" size="<?if($tela_anterior != 'pacote_tarifas') {?>3<?}else{?>9<?}?>" <?if ($consulta == 'S' || $consulta == 's'){?>readonly<?}?> value="<? echo getByTagName($registro->tags,'perscore')?>"></td>
											<td <?if($tela_anterior != 'pacote_tarifas') { echo "class=\"campo\"";}?> ><input type="<?if($tela_anterior != 'pacote_tarifas') { echo "text";}else{ echo "hidden";} ?>" <?if (getByTagName($registro->tags,'tpindicador') != 'Adesão'){?>class="per"<?}?> id="pertolera<?echo $i?>" style="text-align:right" size="6" <?if (getByTagName($registro->tags,'tpindicador') == 'Adesão' || strtoupper($consulta) == 'S') {?>readonly<?}?> value="<?if ($tela_anterior == 'pacote_tarifas'){echo '0,00';} else { echo getByTagName($registro->tags,'pertolera');}?>"></td>
										  </tr>
									   <? $i++;
										}?>
									  </tbody>
									</table>
													</div>
								  <br>
								  <div>
									<table>
									  <tr>
										<td><?if ($tela_anterior != 'pacote_tarifas'){?>% Máximo de Desconto Permitido ao Cálculo:<?}?></td>
										<td <?if ($tela_anterior != 'pacote_tarifas'){?>class="campo"<?}?>><input class="per" id="perdesmax" type="<?if ($tela_anterior == 'pacote_tarifas'){?>hidden<?}else{?>text<?}?>" size="5" <?if (strtoupper($consulta) == 'S'){?>readonly<?}?> value="<?if ($tela_anterior == 'pacote_tarifas'){echo '100,00';} else { echo $perdesmax;}?>"></td>
									  </tr>
									</table>
								  </div>
								  <br>
								  <div>
									<table>
									  <tr>
										<td width="70px" align="center"> <a href="#" class="botao" id="btVoltar" onClick="$('#<?echo $cp_desmensagem?>').val('NOK');fechaRotina($('#divUsoGenerico')<?if ($divanterior != ""){?>,$('#<?echo $divanterior;?>')<?}?>); return false;">Voltar</a></td>
										<?if ($consulta != "S" && $consulta != "s") {
											if ($senha_coordenador == "S") {?>
												<td width="70px" align="center"> <a href="#" class="botao" id="btConfirmar" onClick="confirmar(<?echo $qtdregist?>,'<?echo $idparame_reciproci?>','<?echo $dslogcfg?>','<?echo $cp_idparame_reciproci?>','<?echo $cp_desmensagem?>','<?echo $cp_deslogconfrp?>','pedeSenhaCoordenador(2,\'<?echo $executafuncao?>\',\'divRotina\');','<?echo $divanterior?>', '<?echo $tela_anterior?>');" >Confirmar</a> </td>
											<?} else {?>
												<td width="70px" align="center"> <a href="#" class="botao" id="btConfirmar" onClick="confirmar(<?echo $qtdregist?>,'<?echo $idparame_reciproci?>','<?echo $dslogcfg?>','<?echo $cp_idparame_reciproci?>','<?echo $cp_desmensagem?>','<?echo $cp_deslogconfrp?>','<?echo $executafuncao?>','<?echo $divanterior?>', '<?echo $tela_anterior?>');" >Confirmar</a> </td>
											<?}?>
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
$('.per').setMask('DECIMAL','zz0,00',',','');
$('.qtd').setMask('DECIMAL','zzz.zzz.zzz.zz0',',','');
$('.moeda').setMask('DECIMAL','zzz.zzz.zzz.zz0,00',',','');
<?if($tela_anterior == 'pacote_tarifas') {?>
	$('#perdesmax').desabilitaCampo();
	for (var i = 0; i < <?echo $qtdregist;?>; i++) {
		$('#pertolera' + i).desabilitaCampo();
	}
<?}?>
</script>