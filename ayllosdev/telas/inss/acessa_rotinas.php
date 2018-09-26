<? 
/***************************************************************************************
 * FONTE        : acessa_rotinas.php				Última alteração: 10/03/2015
 * CRIAÇÃO      : Adriano
 * DATA CRIAÇÃO : 05/06/2013
 * OBJETIVO     : Acessa as rotinas da tela INSS
 
				  10/03/2015 - Ajuste referente ao Histórico cadastral
						      (Adriano - Softdesk 261226).			  
  
 
 **************************************************************************************/
?>
 
<?
	session_start();
		
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	
	isPostMethod();		
		
	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');
			
	setVarSession("opcoesRotina",$opcoesTela);
	
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
		
	// Guardo os parâmetos do POST em variáveis	
	$nmdatela = (isset($_POST['nmdatela'])) ? $_POST['nmdatela'] : '';
	$nmrotina = (isset($_POST['nmrotina'])) ? $_POST['nmrotina'] : '';
		
	$flgAlteraCad      = (in_array('A', $glbvars['opcoesRotina']));
	$flgComprovaVida   = (in_array('C', $glbvars['opcoesRotina']));
	$flgDemonstrativo  = (in_array('D', $glbvars['opcoesRotina']));
	$flgTrocaDomicilio = (in_array('E', $glbvars['opcoesRotina']));
	$flgTrocaConta     = (in_array('T', $glbvars['opcoesRotina']));
	$session = session_id();	
		
		
	if($nmrotina == "CONSULTA"){
		
		switch($cddopcao){
			
			case 'A':
				$tituloTela = "Altera Cadastro";
				if (!in_array('A', $glbvars['opcoesRotina']))  exibirErro('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de acesso a rotina '.'\"'.$tituloTela.'\"'.'.','Alerta - Aimaro','',false);
			break;
			
			case 'C':
				$tituloTela = "Comprova Vida";
				if (!in_array('C', $glbvars['opcoesRotina'])){  exibirErro('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de acesso a rotina '.'\"'.$tituloTela.'\"'.'.','Alerta - Aimaro','',false);}
			break;
					
			case 'T':	
				$tituloTela = "Troca Conta Corrente";
				if (!in_array('T', $glbvars['opcoesRotina']))  exibirErro('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de acesso a rotina '.'\"'.$tituloTela.'\"'.'.','Alerta - Aimaro','',false);
			break;
			
		}
	
		
	}elseif($nmrotina == "RELATORIO"){
		
		switch($cddopcao){
		
			//Beneficios pagos
			case 'A':			
				$tituloTela = "Benef&iacute;cios pagos";
				if (!in_array('A', $glbvars['opcoesRotina']))  exibirErro('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de acesso a rotina '.'\"'.$tituloTela.'\"'.'.','Alerta - Aimaro','',false);		
			break;
			
			//Beneficios a pagar e bloqueados
			case 'B':				
				$tituloTela = "Benef&iacute;cios a pagar e bloqueados";
				if (!in_array('B', $glbvars['opcoesRotina']))  exibirErro('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de acesso a rotina '.'\"'.$tituloTela.'\"'.'.','Alerta - Aimaro','',false);				
			break;
			
			//Histórico cadastral
			case 'D':				
				$tituloTela = "Hist&oacute;rico cadastral";
				if (!in_array('B', $glbvars['opcoesRotina']))  exibirErro('error','Seu usu&aacute;rio n&atilde;o possui permiss&atilde;o de acesso a rotina '.'\"'.$tituloTela.'\"'.'.','Alerta - Aimaro','',false);				
			break;
									
		}
		
	}
	
?>	
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
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="$('#btVoltar','#divRotina').click();return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" onClick="acessaOpcaoAba(4,0,'@')" class="txtNormalBold">Principal</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divConteudoOpcao">
									
										<?
											
										if($nmrotina == "CONSULTA"){
										
											switch($cddopcao){
												
												//Altera Cadastro
												case 'A':
												
													include('form_alteracao_cadastral.php');
													
													?>
													<script text="text/javscript">
																								
														formataAlteracaoCadastral(); 
														alimentaCamposAltCad();
														$('#frmAlteracaoCadastral').css('display','block');
														$('#divBotoesAlteracaoCadastral').css('display','block');
																										
													</script>
													
													<?
												break;
												
												//Comprova Vida
												case 'C':
													
													include('form_comprova_vida.php');
													
													?> 
													<script text="text/javascript">
													
														$('#divComprovaVida').css('display','block');
														$('#btVoltar','#divComprovaVida').show();
														$('#btCmpBene','#divComprovaVida').show();
														
														/*Quando o beneficiário não possuir um procurador, o botão "Comprovar pelo Procurador" não será mostrado.*/
														if( $('#nmprocur','#frmConsulta').val() == '' ){
															$('#btCmpProc','#divComprovaVida').hide();
														}
																										
													</script>
													<?
													
												break;
																							
												//Troca conta
												case 'T':
												
													include('form_troca_op_conta_corrente.php');
												
													?>
													<script text="text/javscript">
																										
														formataTrocaOpContaCorrente('<?echo $cddopcao;?>'); 		
														$('#nrctaant','#frmTrocaOpContaCorrente').val($('#nrdconta','#frmConsulta').val());
														$('#orgpgant','#frmTrocaOpContaCorrente').val($('#cdorgins','#frmConsulta').val());
														$('#frmTrocaOpContaCorrente').css('display','block');
														$('#divBotoesTrocaOpContaCorrente').css('display','block');
																																																			
													</script>
													<?
												break;																			
											
											}
											
										}elseif($nmrotina == "RELATORIO"){	
										
												switch($cddopcao){
			
													//Beneficios pagos
													case 'A':	

														include('form_relatorio_beneficios_pagos.php');
															
														?>
														<script text="text/javascript">
															
															formataRelatorioBeneficiosPagos('<?echo $cddopcao;?>');
															$('#frmRelatorioBeneficiosPagos').css('display','block');
															$('#divBotoesRelatorioBeneficiosPagos').css('display','block');
															formataTabela();															
															
														</script>
														<?
																										
													break;
													
													//Beneficios a pagar e bloqueados
													case 'B':				
														
														include('form_relatorio_beneficios_pagar.php');
															
														?>
														<script text="text/javascript">
															
															formataRelatorioBeneficiosPagar('<?echo $cddopcao;?>');
															$('#frmRelatorioBeneficiosPagar').css('display','block');
															$('#divBotoesRelatorioBeneficiosPagar').css('display','block');	
															formataTabela();
															
														</script>
														<?
														
													break;			
													
													//Histórico cadastral
													case 'D':	
														
														include('form_relatorio_historico_cadastral.php');
															
														?>
														<script text="text/javascript">
															
															formataRelatorioHistoricoCadastral('<?echo $cddopcao;?>');
															$('#frmRelatorioHistoricoCadastral').css('display','block');
															$('#divBotoesRelatorioHistoricoCadastral').css('display','block');	
																														
														</script>
														<?
														
													break;			
												
												
												}
												
										}
										
										?>
									
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

<?
if($nmrotina == "CONSULTA"){

	switch($cddopcao){
	
		//Altera Cadastro
		case 'A':?> 
			<script text="text/javascript">
				exibeRotina($('#divRotina'));	
				$('#btConcluir','#divBotoesAlteracaoCadastral').focus();
			</script>
		<?	
		break;
		
		//Comprova Vida
		case 'C':?>
			<script text="text/javascript">
				exibeRotina($('#divRotina'));	
				$('#btCmpBene','#divComprovaVida').focus();
			</script>
		<?	
		break;
				
		//Troca Conta
		case 'T':?>
			<script text="text/javascript">
				exibeRotina($('#divRotina'));	
				$('#nrdconta','#frmTrocaOpContaCorrente').focus();
			</script>
		<?
		break;	

	}
	
}elseif($nmrotina == "RELATORIO"){

		switch($cddopcao){
		
			//Beneficios pagos
			case 'A':?>
				<script text="text/javascript">
					exibeRotina($('#divRotina'));
					$('#cdagenci','#frmRelatorioBeneficiosPagos').focus();
				</script>
			<?
			break;
			
			//Beneficios a pagar e bloqueados
			case 'B':?>
				<script text="text/javascript">
					exibeRotina($('#divRotina'));
					$('#cdagenci','#frmRelatorioBeneficiosPagar').focus();
				</script>
			<?				
			break;
			
			//Histórico cadastral
			case 'D':?>
				<script text="text/javascript">
					exibeRotina($('#divRotina'));
					$('#nrrecben','#frmRelatorioHistoricoCadastral').focus();
				</script>
			<?				
			break;
						
		}
		
}
		
?>


	