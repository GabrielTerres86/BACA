<?
/*!
 * FONTE        : observacao.php
 * CRIAÇÃO      : Gabriel Capoia - DB1 Informatica
 * DATA CRIAÇÃO : 19/04/2011 
 * OBJETIVO     : Tela para buscar as observações de outra proposta
 *
 * ALTERACOES   : 13/06/2012 - Tratar da liquidacao na 1a tela (Gabriel).
				  05/09/2012 - Mudar para layout padrao (Gabriel) 
				  13/03/2014 - Campo de nr. contrato inicia vazio. (Jorge).
 */	
?>
 
<?
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");	
?>

<table id="buscaObs" cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="228px">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('Busca Observação') ?></td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaBuscaObs(''); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
									<div style="width: 365px; height: 60px;" id="divConteudoValor">
																		
										<form id='frmBuscaObs' class="formulario">
											
											<label for="nrctrobs" ><? echo utf8ToHtml('Copiar observação do contrato número:') ?></label>
											<input name="nrctrobs"  id="nrctrobs" type="text" value="" />
											<br />
																																																						
										</form>
										
										<div id="divBotoes">
											<a href="#" class="botao" id="btVoltar" onClick="fechaBuscaObs('I_INICIO'); return false;">Voltar</a>
											<a href="#" class="botao" id="btSalvar" onClick="buscaObs('I'); return false;">Continuar</a>				
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
	
	var nrctrobs  = $('#nrctrobs','#frmBuscaObs');
		
	var rNrctrobs = $('label[for="nrctrobs"]','#frmBuscaObs');
				
	rNrctrobs.addClass('rotulo').css('width','225px');
		
	nrctrobs.addClass('inteiro').css('width','90px');
		
	nrctrobs.habilitaCampo();
		
	layoutPadrao();
	
	highlightObjFocus($('#frmBuscaObs'));

	// desabilita o enter
	nrctrobs.unbind('keypress').bind('keypress', function(e) {	
		if (e.keyCode == 13 ) { return false; }
	});	

	nrctrobs.val('').focus();
	
</script>