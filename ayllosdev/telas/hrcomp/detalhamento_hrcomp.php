<?
/*!
 * FONTE        : detalhamento_hrcomp.php
 * CRIAÇÃO      : Tiago Machado
 * DATA CRIAÇÃO : 25/02/2014
 * OBJETIVO     : Tela do formulario de detalhamento dos arquivos da comp
 * --------------
 * ALTERAÇÕES   : 21/09/2016 - Incluir tratamento para poder alterar a cooperativa cecred e 
 * --------------              escolher o programa "DEVOLUCAO DOC" - Melhoria 316 
 *                             (Lucas Ranghetti #525623)
 */	 
?>

<?
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	
?>

<table width="100%" id='telaDetalhamento' cellpadding="0" cellspacing="0" border="0" >
	<tr>
		<td align="center">		
			<table width="100%" border="0" cellpadding="0" cellspacing="0"  >
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('Detalhamento de hor&aacute;rios') ?></td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divRotina')); carregaDetalhamento(); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" class="txtNormalBold">Altera&ccedil;&atilde;o</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divConteudoOpcao" >
										<form id="frmProc" name="frmProc" class="formulario cabecalho" onSubmit="return false;" style="display:none">
											<table width="100%">
												<tr>		
													<td> 	
														<label for="processo"><b><? echo utf8ToHtml('Processo:') ?></b></label>
														<label for="nmprocex"><b><? echo utf8ToHtml('VLB') ?></b></label>
														<input type="hidden" id="nmprocex" name="nmprocex" value="" />
													</td>
												</tr>
												<tr>
													<td>
														<label for="flgativo"><? echo utf8ToHtml('Ativo:') ?></label>
														<select id="flgativo" name="flgativo" style="width: 80px;">
															<option value="N"> N&atilde;o </option>
															<option value="S"> Sim </option> 
														</select>
														
														<label for="agxinihr"><b><? echo utf8ToHtml('Horario inicial:') ?></b></label>
														<input type="text" id="agxinihr" name="agxinihr" value="00" />
														<label for="agxinimm"><b><? echo utf8ToHtml(':') ?></b></label>
														<input type="text" id="agxinimm" name="agxinimm" value="00" />

														<label for="agxfimhr"><b><? echo utf8ToHtml('Horario final:') ?></b></label>
														<input type="text" id="agxfimhr" name="agxfimhr" value="00" />
														<label for="agxfimmm"><b><? echo utf8ToHtml(':') ?></b></label>
														<input type="text" id="agxfimmm" name="agxfimmm" value="00" />
													</td>
												</tr>
											</table>
										</form>										
									</div>
									<div id="divBotoesfrmDetalhaHrcomp" style="margin-bottom: 5px; text-align:center;" >
										<a href="#" class="botao" id="btVoltar"  	onClick="<? echo 'fechaRotina($(\'#divRotina\'));'; ?> return false;">Voltar</a>
										<a href="#" class="botao" id="btSalvar"  	onClick="<? echo 'fechaRotina($(\'#divRotina\')); realizaOperacao();'; ?> return false;">Concluir</a>										
									</div>									
								</td>
							</tr>
						</table>			    
					</td> 
				</tr>
			</table>
		</td>
	</tr>
</table>