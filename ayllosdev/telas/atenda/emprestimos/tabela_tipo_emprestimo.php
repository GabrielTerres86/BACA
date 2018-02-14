<?
/*!
 * FONTE        : tabela_tipo_emprestimo.php
 * CRIAÇÃO      : Alex Sandro (GFT)
 * DATA CRIAÇÃO : 25/01/2018
 * OBJETIVO     : Tabela para selecionar os tipos de emprestimos
 * --------------
 * ALTERAÇÕES   :
 * --------------

 * 000: [25/01/2018] Adicionado tela de seleção de tipos de empréstimos (Alex)
 */
?>
<?
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");	
  
?>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="500">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Empr&eacute;stimos e Financiamentos</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divUsoGenerico'),divRotina);"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>     
					</td> 
				</tr>    
				<tr>
					<td class="tdConteudoTela" align="center">	
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
																			
									<div id="divConteudoOpcao" style="height: 80px;">
									
									<div id="divBotoes" style="height:80px;">
										<a href="#" class="botao gft" id="btEmprestimosFinanciamentos" onClick="fechaRotina($('#divUsoGenerico'),divRotina);controlaOperacao('I');" style="margin: 20px 6px">Empr&eacute;stimos e Financiamentos</a>
										<a href="#" class="botao gft" id="btEmprestimosConsignado" onClick="alert('Funcionalidade ainda em desenvolvimento!');" style="margin: 20px 6px">Empr&eacute;stimo Consignado</a>
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