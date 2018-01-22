<?php
	/*
	 * FONTE        : form_parametros.php
	 * CRIAÇÃO      : Jean Michel
	 * DATA CRIAÇÃO : 06/12/2017
	 * OBJETIVO     : Formulario de cadastro e manutenção de parâmetros CDC
	 * --------------
	 * ALTERAÇÕES   :
	 * --------------
	 */

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');

	$cdcooper   = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0 ;
	
  if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',true);
	}
    
	// Monta o xml de requisicao
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "  <cddopcao>C</cddopcao>";
	$xml .= "  <cdcooper_param>".$cdcooper."</cdcooper_param>";
	$xml .= "  <inintegra_cont>0</inintegra_cont>";
	$xml .= "  <nrprop_env>0</nrprop_env>";
	$xml .= "  <intempo_prop_env>0</intempo_prop_env>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	/* CONSULTA DE PARAMETROS */
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "TELA_PARCDC", "MANTER_PARAMETROS_CDC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
    
	$parametros = $xmlObjeto->roottag->tags[0]->tags[5]->tags;
		
	$cdcooper         = getByTagName($parametros, 'CDCOOPER');
	$inintegra_cont   = getByTagName($parametros, 'ININTEGRA_CONT');
	$nrprop_env       = getByTagName($parametros, 'NRPROP_ENV');
	$intempo_prop_env = getByTagName($parametros, 'INTEMPO_PROP_ENV');
	/* FIM CONSULTA DE PARAMETROS */
	
	/* CONSULTA DE SEGMENTOS */
	// Monta o xml de requisicao
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "  <cddopcao>C</cddopcao>";
	$xml .= "  <tpproduto></tpproduto>";
	$xml .= "  <cdsegmento>0</cdsegmento>";
	$xml .= "  <dssegmento></dssegmento>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "TELA_PARCDC", "MANTER_SEGMENTOS_CDC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
    
	$segmentos = $xmlObjeto->roottag->tags[2]->tags;	
	
	/* FIM CONSULTA DE SEGMENTOS */
?>

<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table cellpadding="0" cellspacing="0" border="0" width="750">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Par&acirc;metros CDC</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a id="btSair" href="#" onClick="fechaRotina($('#divRotina')); btnVoltar(); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>        
						</table>
					</td>        
				</tr>        
				<tr>
					<td class="tdConteudoTela" align="center">
						<table width="100%"  border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td>
									<table border="0" cellspacing="0" cellpadding="0">
										<tr>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" class="txtNormalBold" onClick="acessaOpcaoAba(0);return false;">Integra&ccedil;&atilde;o Ibacred</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>

											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq1"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen1"><a href="#" id="linkAba1" class="txtNormalBold" onClick="acessaOpcaoAba(1);return false;">Segmentos</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir1"></td>
											<td width="1"></td>

                    </tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divAba0" class="clsAbas">
										<form id="frmParametros" name="frmParametros" class="formulario">
										  <input type="hidden" id="hdnCdcooper" name="hdnCdcooper" value="<?php echo $cdcooper; ?>" />
											<br>
											<label for="inintegra_cont">Habilitar Conting&ecirc;ncia:</label>	
											<select id="inintegra_cont" name="inintegra_cont">
												<option value="1" <?php echo ($inintegra_cont == 1) ? " SELECTED " : ""; ?> >Sim</option>
												<option value="0" <?php echo ($inintegra_cont == 0) ? " SELECTED " : ""; ?> >N&atilde;o</option>
											</select>
											<br><br><br>
											<fieldset>
												<legend>Limite de Consultas</legend>
												<br>
												<label for="nrprop_env" style="width: 170px;" >Limite M&aacute;ximo Propostas:</label>
												<input type="text" class="Campo inteiro" name="nrprop_env" id="nrprop_env" maxlength="2" style="width: 25px;" value="<?php echo $nrprop_env; ?>" />
												<br><br>
												<label for="intempo_prop_env" style="width: 170px;">Intervalo Tempo Propostas:</label>
												<input type="text" class="Campo inteiro" name="intempo_prop_env" id="intempo_prop_env" maxlength="2" style="width: 25px;" value="<?php echo $intempo_prop_env; ?>" />
												<label for="intempo_prop_env">&nbsp;&nbsp;minutos</label>
											</fieldset>
										</form>	
									</div>
									
									<div id="divAba1" class="clsAbas">
										<form id="frmLista" name="frmLista" class="formulario">	
											<fieldset>
												<legend align="center">Lista de Segmentos</legend>
													<div class="divRegistros" id="divSegmentos">		
														<table class="tituloRegistros" id="tableSegmento" style="table-layout: fixed;">
															<thead>
																<tr>
																	<th>Produto</th>
																	<th>C&oacute;digo</th>
																	<th>Segmento</th>
																</tr>
															</thead>
															<tbody>		
																<?php
																	if(count($segmentos) > 0){
																	  foreach($segmentos as $segmento){
																?>
																			<tr  onclick="detalheSubsegmento(<?php echo getByTagName($segmento->tags, 'CDSEGMENTO'); ?>);">
																				<input type="hidden" id="cdsegmento" value="<?php echo getByTagName($segmento->tags, 'CDSEGMENTO'); ?>"/>
																				<td><?php echo getByTagName($segmento->tags, 'DSPRODUTO'); ?></td>
																				<td><?php echo getByTagName($segmento->tags, 'CDSEGMENTO'); ?></td>
																				<td><?php echo getByTagName($segmento->tags, 'DSSEGMENTO'); ?></td>
																			</tr>
																<?php
																		}
																	}else{
																?>
																		<tr>
																			<td colspan="2">
																				<b>N&atilde;o h&aacute; registros de segmentos cadastrados</b>
																			</td>
																		</tr>
																<?php
																	}
																?>
															</tbody>
														</table>
													</div>
												</fieldset>
											<div id="divBotoesSegmentos" name="divBotoesSegmentos" style="margin-left: 280px;">
												<a href="#" class="botao" id="btIncluirSegmento" name="btIncluirSegmento" onClick="rotinaSegmento('I');">Incluir</a>
												<a href="#" class="botao" id="btAlterarSegmento" name="btAlterarSegmento" onClick="rotinaSegmento('A');">Alterar</a>
												<a href="#" class="botao" id="btExcluirSegmento" name="btExcluirSegmento" onClick="rotinaSegmento('E');">Excluir</a>
											</div>
										
											<div id="divSubsegmentos" name="divSubsegmentos"></div>
											<div id="divBotoesSubsegmentos" name="divBotoesSubsegmentos" style="margin-left: 280px;">
												<a href="#" class="botao" id="btIncluirSubsegmento" name="btIncluirSubsegmento" onClick="rotinaSubsegmento('I');">Incluir</a>
												<a href="#" class="botao" id="btAlterarSubsegmento" name="btAlterarSubsegmento" onClick="rotinaSubsegmento('A');">Alterar</a>
												<a href="#" class="botao" id="btExcluirSubsegmento" name="btExcluirSubsegmento" onClick="rotinaSubsegmento('E');">Excluir</a>
											</div>
										</form>
									</div>									
								</td>
							</tr>
						</table>
						<br />
						<div id="botoesAba0" name="botoesAba0" style="display: none;">
							<a href="#" class="botao" id="btVoltarintegracao" name="btVoltarintegracao" onClick="fechaRotina($('#divRotina')); btnVoltar(); return false;">Voltar</a>
							<a href="#" class="botao" id="btAlterarIntegracao" name="btAlterarIntegracao" onClick="alterarIntegracao();">Alterar</a>
						</div>
						<div id="botoesAba1" name="botoesAba1" style="display: none;">
							<a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina')); btnVoltar(); return false;">Voltar</a>
						</div>
					</td>        
				</tr>   
			</table>				
		</td>
	</tr>
</table>
<div name="divCadastro" id="divCadastro"></div>
<script>
  acessaOpcaoAba(0);
	formataTabelaSegmento();
	controlaFoco();	
	$('#tableSegmento > tbody > tr', 'div.divRegistros').each(function() {
		if ($(this).hasClass('corSelecao')) {
			$(this).click();				
		}
	});
</script>