<?php
	/*
	 * FONTE        : form_cadastro.php
	 * CRIAÇÃO      : Jean Michel
	 * DATA CRIAÇÃO : 06/12/2017
	 * OBJETIVO     : Formulario de cadastro e manutenção de segmentos e subsegmentos CDC
	 * --------------
	 * ALTERAÇÕES   :
	 * --------------
	 */

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');

	$tpcadast      = (isset($_POST['tpcadast'])) ? $_POST['tpcadast'] : 0;
	$cddopcao      = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	$cdcopper      = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0;
	$cdsegmento    = (isset($_POST['cdsegmento'])) ? $_POST['cdsegmento'] : 0;
	$cdsubsegmento = (isset($_POST['cdsubsegmento'])) ? $_POST['cdsubsegmento'] : 0;
    $nmrotina      = isset($_POST["nmrotina"]) ? $_POST["nmrotina"] : $glbvars["nmrotina"];

	if (($msgError = validaPermissao($glbvars['nmdatela'],$nmrotina,$cddopcao,false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',true);
	}
	
	if($tpcadast == 0){ //SEGMENTOS
		// PRODUTOS
		// Monta o xml de requisicao
		$xmlSeg  = "<Root>";
		$xmlSeg .= " <Dados>";
		$xmlSeg .= " </Dados>";
		$xmlSeg .= "</Root>";
		
		// Executa script para envio do XML e cria objeto para classe de tratamento de XML
		$xmlResultSeg = mensageria($xmlSeg, "TELA_PARCDC", "LISTAR_PRODUTOS_CDC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjetoSeg = getObjectXML($xmlResultSeg);
			
		$produtos = $xmlObjetoSeg->roottag->tags[2]->tags;		
		// SEGMENTOS
		// Monta o xml de requisicao
		$xml  = "<Root>";
		$xml .= " <Dados>";
		$xml .= "  <cddopcao>C</cddopcao>";
		$xml .= "  <cdsegmento>".$cdsegmento."</cdsegmento>";			
		$xml .= "  <dssegmento></dssegmento>";			
		$xml .= " </Dados>";
		$xml .= "</Root>";
	
		// Executa script para envio do XML e cria objeto para classe de tratamento de XML
		$xmlResult = mensageria($xml, "TELA_PARCDC", "MANTER_SEGMENTOS_CDC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjeto = getObjectXML($xmlResult);
		$segmento = $xmlObjeto->roottag->tags[2]->tags[0]->tags;				
	
		if($cddopcao == "A"){
			// SEGMENTOS
			// Monta o xml de requisicao
			$xml  = "<Root>";
			$xml .= " <Dados>";
			$xml .= "  <cdsegmento>".$cdsegmento."</cdsegmento>";
			$xml .= " </Dados>";
			$xml .= "</Root>";

			$xmlResult = mensageria($xml, "TELA_PARCDC", "CONSULTA_SEGMENTO_CDC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
			$xmlObjeto = getObjectXML($xmlResult);
	
			$segmento = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
			
			$cdsegmento = getByTagName($segmento, 'codsegmento');			
			$dssegmento = getByTagName($segmento, 'dessegmento');	
			$tpproduto  = getByTagName($segmento, 'tpproduto');	
		}		
		
	}elseif($tpcadast == 1){ // SUBSEGMENTOS		
		
		// Monta o xml de requisicao
		$xmlSeg  = "<Root>";
		$xmlSeg .= " <Dados>";
		$xmlSeg .= "  <cddopcao>C</cddopcao>";
		$xmlSeg .= "  <cdsegmento>0</cdsegmento>";
		$xmlSeg .= "  <dssegmento></dssegmento>";
		$xmlSeg .= " </Dados>";
		$xmlSeg .= "</Root>";
		
		// Executa script para envio do XML e cria objeto para classe de tratamento de XML
		$xmlResultSeg = mensageria($xmlSeg, "TELA_PARCDC", "MANTER_SEGMENTOS_CDC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjetoSeg = getObjectXML($xmlResultSeg);
			
		$segmentos = $xmlObjetoSeg->roottag->tags[2]->tags;
		
		if($cddopcao == "A"){
			// SUBSEGMENTOS
			// Monta o xml de requisicao
			$xml  = "<Root>";
			$xml .= " <Dados>";
			$xml .= "  <cdsubsegmento>".$cdsubsegmento."</cdsubsegmento>";
			$xml .= " </Dados>";
			$xml .= "</Root>";

			$xmlResult = mensageria($xml, "TELA_PARCDC", "CONSULTA_SUBSEGMENTO_CDC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
			$xmlObjeto = getObjectXML($xmlResult);
    
			$subsegmento = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
			
			$cdsubsegmento = getByTagName($subsegmento, 'codsubsegmento');			
			$dssubsegmento = getByTagName($subsegmento, 'dessubsegmento');	
			$codsegmento =   getByTagName($subsegmento, 'codsegmento');	
			$nrmaxparcelas = getByTagName($subsegmento, 'nrmaxparcelas');	
			$vlmaxproposta = getByTagName($subsegmento, 'vlmaxproposta');	
			$nrcarencia =    getByTagName($subsegmento, 'nrcarencia');	
		}			
	}
	
?>

<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table cellpadding="0" cellspacing="0" border="0" width="500">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Cadastro <?php echo ($tpcadast == 0) ? "Segmento" : "Subsegmento"; ?></td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a id="btSair" href="#" onClick="fechaRotina($('#divUsoGenerico')); bloqueiaFundo($('#divRotina')); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>        
						</table>
					</td>        
				</tr>        
				<tr>
					<td class="tdConteudoTela" align="center">
						<table width="100%"  border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<form id="frmCadastro" name="frmCadastro" class="formulario">
																				
										<?php if($tpcadast == "0"){ ?>
											<div id="divAbaSegmento" name="divAbaSegmento" class="clsAbas">
												<label for="tpproduto" style="width: 70px;" >Produto:</label>
												<select class="Campo" name="tpproduto" id="tpproduto" style="width: 160px;">
													<?php
														foreach($produtos as $produto){
													?>
														<option value="<?php echo getByTagName($produto->tags, 'CODPRODUTO'); ?>" <?php echo (getByTagName($produto->tags, 'CODPRODUTO') == $tpproduto) ? " selected " : "" ?> ><?php echo getByTagName($produto->tags, 'DESPRODUTO'); ?></option>
													<?php
														}
													?>													
												</select>

												<br><br>
												<label for="cdsegmento" style="width: 70px;" >C&oacute;digo:</label>
												<input type="text" class="Campo inteiro" name="cdsegmento" id="cdsegmento" maxlength="10" <?php echo($cddopcao == "A") ? " readonly " : ""?> style="width: 50px;" value="<?php echo $cdsegmento; ?>" />
												<br><br>												
												<label for="dssegmento" style="width: 70px;" >Segmento:</label>
												<input type="text" class="Campo" name="dssegmento" id="dssegmento" maxlength="100" style="width: 390px;" value="<?php echo $dssegmento; ?>"/>
												<br><br>
											</div>
											<?php if($cddopcao != "I"){ ?>
												<script>$("#dssegmento").focus();</script>
											<?php
											 }else{											
											?>											
											  <script>$("#cdsegmento").focus();</script>
											<?php
												} 
											?>
												
										<?php }elseif($tpcadast == "1"){ ?>
											<div id="divAbaSubsegmento" name="divAbaSubsegmento" class="clsAbas">
											    <label for="cdsubsegmento" style="width: 140px;" >C&oacute;digo:</label>
												<input type="text" class="Campo inteiro" name="cdsubsegmento" id="cdsubsegmento" maxlength="10" style="width: 60px;" <?php echo($cddopcao == "A") ? " readonly " : ""?> value="<?php echo $cdsubsegmento; ?>" />
												<br><br>
												<label for="dssubsegmento" style="width: 140px;" >Subsegmento:</label>
												<input type="text" class="Campo" name="dssubsegmento" id="dssubsegmento" maxlength="100" style="width: 320px;" value="<?php echo $dssubsegmento; ?>"/>
												<br><br>
												<label for="cdsegmento" style="width: 140px;" >Segmento:</label>
												<select class="Campo" name="cdsegmento" id="cdsegmento" style="width: 320px;">
												<?php
													foreach($segmentos as $segmento){
												?>
													<option value="<?php echo getByTagName($segmento->tags, 'CDSEGMENTO'); ?>" <?php echo (getByTagName($segmento->tags, 'CDSEGMENTO') == $cdsegmento) ? " selected " : "" ?> ><?php echo getByTagName($segmento->tags, 'DSSEGMENTO'); ?></option>
												<?php
													}
												?>
												</select>
												<br><br>	
												<label for="nrmax_parcela" style="width: 140px;" >Num. M&aacute;x. Parcela(s):</label>
												<input type="text" class="Campo inteiro" name="nrmax_parcela" id="nrmax_parcela" maxlength="3" style="width: 35px;" value="<?php echo $nrmaxparcelas; ?>" />
												<br><br>
												<label for="vlmax_financ" style="width: 140px;" >Vlr. M&aacute;x. Proposta:</label>
												<input type="text" class="Campo moeda" name="vlmax_financ" id="vlmax_financ" maxlength="14" style="width: 110px;" value="<?php echo $vlmaxproposta; ?>" />
												<br><br>
												<label for="nrcarencia" style="width: 140px;" >Car&ecirc;ncia:</label>
												<input type="text" class="Campo inteiro" name="nrcarencia" id="nrcarencia" maxlength="3" style="width: 35px;" value="<?php echo $nrcarencia; ?>" />
												<br><br>
											</div>
										<?php } ?>
									</form>
								</td>
							</tr>
						</table>
						<br />
						<a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divUsoGenerico')); bloqueiaFundo($('#divRotina')); return false;">Voltar</a>
						<a href="#" class="botao" id="btConcluir" onClick="salvaDados(<?php echo $tpcadast; ?>,'<?php echo $cddopcao; ?>',0,0); return false;">Concluir</a>
					</td>        
				</tr>   
			</table>				
		</td>
	</tr>
</table>
<script>
	layoutPadrao();
</script>