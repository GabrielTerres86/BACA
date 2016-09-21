
<?
/*!
 * FONTE        : numero.php
 * CRIAÇÃO      : Gabriel Capoia - DB1 Informatica
 * DATA CRIAÇÃO : 12/04/2011 
 * OBJETIVO     : Tela para alteração do número da proposta de empréstimo.
 * ALTERAÇÕES   : 
 * --------------
 * 000: [20/09/2011] Correções de acentuação - Marcelo L. Pereira (GATI)
		[05/09/2012] Mudar para layout padrao (Gabriel)
   001: [19/12/2014] Máscara do campo de novo contrato alterado para aceitar dez números (Kelvin - 233714).
   002: [11/05/2015] Remocao do valor inicial de zero do novo contrato. (Jaison/Gielow - SD: 282303)
 */
?>
 
<?
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");	
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
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaNumero('');return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" onClick=<?php echo "acessaOpcaoAba(".count($opcoesTela).",0,'".$opcoesTela[0]."');"; ?> class="txtNormalBold">Principal</a></td>
																																					
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
											
											<label for="nrctremp" ><? echo utf8ToHtml('Contrato atual:') ?></label>
											<input name="nrctremp"  id="nrctremp" type="text" value="" />
											<br />
											
											<label for="new_nrctremp" ><? echo utf8ToHtml('Novo contrato:') ?></label>
											<input name="new_nrctremp" id="new_nrctremp" type="text" value="" />
											<br />
																																
										</form>
										
										<div id="divBotoes">
											<a href="#" class="botao" id="btVoltar" onClick="fechaNumero(''); return false;">Voltar</a>
											<a href="#" class="botao" id="btSalvar" onClick="controlaOperacao('F_NUMERO'); return false;">Concluir</a>
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
	
	var nrctremp_1     = $('#nrctremp','#frmNumero');
	var new_nrctremp_1 = $('#new_nrctremp','#frmNumero');
	
	var rNrctremp_1     = $('label[for="vlemprst"]','#frmNumero');
	var rNew_nrctremp_1 = $('label[for="vleprori"]','#frmNumero');
	
	highlightObjFocus($('#frmNumero'));
	
	nrctremp_1.val( nrctremp );
		
	rNrctremp_1.addClass('rotulo').css('width','85px');
	rNew_nrctremp_1.addClass('rotulo').css('width','85px');
	
	nrctremp_1.addClass('contrato3').css('width','105px');
	new_nrctremp_1.addClass('contrato3').css('width','105px');
	
	nrctremp_1.desabilitaCampo();
	new_nrctremp_1.habilitaCampo();
		
	layoutPadrao();
	
	$('input','#frmNumero').trigger('blur');
	
	new_nrctremp_1.val("");
		
</script>