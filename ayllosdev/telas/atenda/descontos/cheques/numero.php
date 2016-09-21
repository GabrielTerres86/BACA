<?php
/*!
 * FONTE        : numero.php
 * CRIAÇÃO      : Lucas Lunelli
 * DATA CRIAÇÃO : 16/12/2015
 * OBJETIVO     : Tela para alteração do número da proposta de limite de desc de cheques. (Lunelli - SD 360072 [M175])
 * ALTERAÇÕES   : 
 * --------------
 * 000:
 *
 *
 */
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");	
?>

<table id="numero" cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">
			<table border="0" cellpadding="0" cellspacing="0" width="228px">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('Número da Proposta');?></td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotinaAltera();return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" onClick="return false;" class="txtNormalBold">Principal</a></td>
																																					
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div style="width: 195px; height: 85px;" id="divConteudoValor">
																		
										<form id='frmNumero' class="formulario">
											
											<label for="nrctrlim" ><? echo utf8ToHtml('Contrato atual:') ?></label>
											<input name="nrctrlim"  id="nrctrlim" type="text" value="" />
											<br />
											
											<label for="new_nrctrlim" ><? echo utf8ToHtml('Novo contrato:') ?></label>
											<input name="new_nrctrlim" id="new_nrctrlim" type="text" value="" />
											<br />
																																
										</form>
										
										<div id="divBotoes">
											<a href="#" class="botao" id="btVoltar" onClick="fechaRotinaAltera(); return false;">Voltar</a>
											<a href="#" class="botao" id="btSalvar" onClick="confirmaAlteraNrContrato(); return false;">Concluir</a>
											<br />
										</div>
										
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

<script type="text/javascript">
	
	var nrctrlim_1     = $('#nrctrlim','#frmNumero');
	var new_nrctrlim_1 = $('#new_nrctrlim','#frmNumero');
	
	highlightObjFocus($('#frmNumero'));
	
	nrctrlim_1.val( nrcontrato );

	nrctrlim_1.addClass('contrato3').css('width','105px');
	new_nrctrlim_1.addClass('inteiro').css('width','105px');
	new_nrctrlim_1.setMask('INTEGER','z.zzz.zzz','.','');
	
	nrctrlim_1.desabilitaCampo();
	new_nrctrlim_1.habilitaCampo();

	layoutPadrao();
	
	$('input','#frmNumero').trigger('blur');
	
	new_nrctrlim_1.val("");
	new_nrctrlim_1.focus();	

	new_nrctrlim_1.unbind('keypress').bind('keypress',function(e) {
		if(e.keyCode == 13){
			confirmaAlteraNrContrato();
			return false;			
		}		
	});	

</script>