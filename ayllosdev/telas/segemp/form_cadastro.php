<?php
	/*
	 * FONTE        : form_cadastro.php
	 * CRIAÇÃO      : Douglas Pagel
	 * DATA CRIAÇÃO : 11/02/2019
	 * OBJETIVO     : Formulario de manutenção de subsegmentos
	 * --------------
	 * ALTERAÇÕES   :
	 * --------------
	 */

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');

	$cdsegmento    = (isset($_POST['cdsegmento'])) ? $_POST['cdsegmento'] : 0;
	$cdsubsegmento = (isset($_POST['cdsubsegmento'])) ? $_POST['cdsubsegmento'] : 0;

	if (($msgError = validaPermissao($glbvars['nmdatela'],$nmrotina,$cddopcao,false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Aimaro','',true);
	}
	
	// Monta o xml de requisicao
	$xmlSeg  = "<Root>";
	$xmlSeg .= " <Dados>";
	$xmlSeg .= "  <idsegmento>".$cdsegmento."</idsegmento>";
	$xmlSeg .= "  <idsubsegmento>".$cdsubsegmento."</idsubsegmento>";
	$xmlSeg .= " </Dados>";
	$xmlSeg .= "</Root>";
	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResultSeg = mensageria($xmlSeg, "TELA_SEGEMP", "SEGEMP_CONS_SUB", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResultSeg);
	

	$subsegmento = $xmlObj->roottag->tags[0]->tags;
	
	$cdsubsegmento = getByTagName($subsegmento, 'idsubsegmento');			
	
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
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Cadastro Subsegmento</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a id="btSair" href="#" onClick="fechaRotina($('#divRotina')); bloqueiaFundo($('#divTela')); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
																				
										<div id="divAbaSubsegmento" name="divAbaSubsegmento" class="clsAbas">
											    <label for="cdsubsegmento" >C&oacute;digo:</label>
												<input type="text" class="Campo inteiro" name="cdsubsegmento" id="cdsubsegmento" maxlength="10" <?php echo" readonly "?> value="<?php echo $cdsubsegmento; ?>" />
												<br><br>
												<label for="dssubsegmento"><? echo utf8ToHtml("Descrição:"); ?></label>
												<input type="text" class="Campo" name="dssubsegmento" id="dssubsegmento" maxlength="100" value="<?php echo utf8ToHtml(getByTagName($subsegmento, 'dssubsegmento')); ?>"/>
												<br><br>
												<label for="cdfinemp"><? echo utf8ToHtml("Finalidade:"); ?></label>
												<input  type="text" id="cdfinemp" name="cdfinemp"value="<?echo getByTagName($subsegmento,'codigo_finalidade_credito'); ?>" > 
												<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa('5'); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>	
												<input  type="text" id="dsfinemp" name="dsfinemp"value="<?echo getByTagName($subsegmento,'dsfinemp'); ?>" >
												<br><br>
												<label for="cdlcremp"><? echo utf8ToHtml("Linha de Crédito:"); ?></label>
												<input  type="text" id="cdlcremp" name="cdlcremp"value="<?echo getByTagName($subsegmento,'cdlinha_credito'); ?>" > 
												<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa('2'); return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>	
												<input  type="text" id="dslcremp" name="dslcremp"value="<?echo getByTagName($subsegmento,'descricao_linha_credito'); ?>" >
												<br><br>

												<label for="garantia" >Garantia:</label>
												<select class="Campo" name="garantia" id="garantia" onClick="altGarantia();">
													<option value="1" <?php echo (getByTagName($subsegmento, 'flggarantia') == 1) ? " selected " : "" ?> >SIM</option>
													<option value="0" <?php echo (getByTagName($subsegmento, 'flggarantia') == 0) ? " selected " : "" ?>><? echo utf8ToHtml("NÃO"); ?></option>
												</select>
												<label for="tpgarantia">Tipo da Garantia:</label>
												<select class="Campo" name="tpGarantia" id="tpGarantia">
													<option value="0" <?php echo (getByTagName($subsegmento, 'tpgarantia') == 0) ? " selected " : "" ?>>NOVO</option>
													<option value="1" <?php echo (getByTagName($subsegmento, 'tpgarantia') == 1) ? " selected " : "" ?>>USADO</option>
												</select>
												<br><br>
												
												<label for="percentual_maximo_autorizado" style="width: 140px;" >% M&aacute;x. Autorizado:</label>
												<input type="text" name="percentual_maximo_autorizado" id="percentual_maximo_autorizado" value="<?php echo getByTagName($subsegmento,'pemax_autorizado'); ?>" />
												<br><br>
												<!--
												<label for="valor_maximo_proposta" style="width: 140px;" >e Vlr. M&aacute;x. Proposta:</label>
												-->
												<input hidden type="text" class="Campo moeda" name="valor_maximo_proposta" id="valor_maximo_proposta" maxlength="14" style="width: 110px;" value="<?php //echo getByTagName($subsegmento,'vlmax_proposta'); ?>" />
												
												<br><br>
												<label for="percentual_excedente" style="width: 140px;" >% Excedente:</label>
												<input type="text" name="percentual_excedente" id="percentual_excedente" value="<?php echo getByTagName($subsegmento,'peexcedente'); ?>" />
												<br><br>
											</div>
									</form>
								</td>
							</tr>
						</table>
						<br />
						<a href="#" class="botao" id="btVoltarSub" onClick="fechaRotina($('#divRotina')); bloqueiaFundo($('#divTela')); return false;">Voltar</a>
						<a href="#" class="botao" id="btConcluirSub">Concluir</a>
					</td>        
				</tr>   
			</table>				
		</td>
	</tr>
</table>
<script>
	formataFormularioSubsegmento();
	altGarantia();
</script>