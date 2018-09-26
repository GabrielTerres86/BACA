<?php 

	/************************************************************************
	 Fonte: principal_dados.php                                             
	 Autor: David                                                     
	 Data : Setembro/2009                Última Alteração: 21/07/2016
	                                                                  
	 Objetivo  : Mostrar opcao Principal da rotina de Aplicações da   
	             tela ATENDA                                          
	                                                                  	 
	 Alterações: 04/10/2010 - Adaptação para novas opções Incluir,    
	                          Alterar e Excluir (David).              
																	   
	             01/12/2010 - Alterado a chamda da BO b1wgen0004.p    
	                          para a BO b1wgen0081.p (Adriano).       
    																   
                 01/09/2012 - Inclusao do principal_imprimir.php      
	                          (Guilherme/Supero).                     
																	   
                 04/06/2013 - Incluir ajustes bloqueio judicial       
	                          (Lucas R).  

				 30/04/2014 - Ajustes referente ao projeto Captação							  
						      (Adriano).
							  
				 29/07/2014 - Inclusao de campo hidden(qtdiaapl) para
							  quantidade de dias de aplicacao (Jean Michel).

				 21/07/2016 - Removi o comando session_start pois este fonte
						      esta sendo incluido em outro fonte que ja possui
							  o comando. SD 479874 (Carlos R).

	************************************************************************/
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
?>

<div id="divDadosAplicacao">	

	<form action="" method="post" name="frmDadosAplicacao" id="frmDadosAplicacao" class="formulario" onSubmit="return false;">
	
		<fieldset>
			<legend>Tipo de Aplicação</legend>
			<label for="tpaplica">Tipo de Aplica&ccedil;&atilde;o:</label>
			<select name="tpaplica" id="tpaplica"></select>
		</fieldset>
				
	</form>
	
	<form action="" method="post" name="frmDadosAplicacaoPos" id="frmDadosAplicacaoPos" class="formulario" onSubmit="return false;" style="display:none;">
		
		<input type="hidden" id="qtdiaapl" name="qtdiaapl" value="" />
		<input type="hidden" id="qtdiapra" name="qtdiapra" value="" />
		<input type="hidden" id="cdmodali" name="cdmodali" value="" />
		
		<fieldset>
			<label for="vllanmto">Valor:</label>
			<input name="vllanmto" type="text" id="vllanmto" autocomplete="no" value="" />
			
			<br />
			
			<label for="qtdiacar">
			<div id="divSelecionaCarencia" style="position: absolute; background-color: #FFFFFF; border: 1px solid #666666; padding: 2px;"></div>
			Car&ecirc;ncia:
			</label>
			<input name="qtdiacar" type="text" id="qtdiacar" autocomplete="no" value="" />
			<a href="#" id="btnLupaCarencia" style="cursor: default;" onClick="return false;"><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0"></a>		
			<br />
			
			<label for="dtcarenc">Data Car&ecirc;ncia:</label>
			<input name="dtcarenc" type="text" id="dtcarenc" autocomplete="no" value="" />
			
			<br />
			
			<label for="flgdebci">Conta Investimento:</label>
			<select name="flgdebci" id="flgdebci" >
			<option value="no" selected>N&Atilde;O</option>
			<option value="yes">SIM</option>
			</select>			
		
			<br />
			
			<label for="txaplica">Percentual/Taxa:</label>
			<input name="txaplica" type="text" id="txaplica" value="" />
			<br />
			<label for="flgrecno">Recurso Novo:</label>
			<select name="flgrecno" id="flgrecno" >
			<option value="1">SIM</option>
			<option value="0" selected>N&Atilde;O</option>
			</select>
			
			<br />
						
			<label for="dsaplica">&nbsp;</label>
			<input name="dsaplica" type="text" id="dsaplica" autocomplete="no" value="" />
			<br />
				
			<label for="dtresgat">Vencimento:</label>
			<input name="dtresgat" type="text" id="dtresgat" autocomplete="no" value="" />
		
		</fieldset>					
		
	</form>
	
	<form action="" method="post" name="frmDadosAplicacaoPre" id="frmDadosAplicacaoPre" class="formulario" onSubmit="return false;" style="display:none;">

		<fieldset>
			<label for="qtdiaapl">Dias:</label>
			<input name="qtdiaapl" type="text" id="qtdiaapl"  autocomplete="no" value="" />

			<br />
			
			<label for="dtresgat">Vencimento:</label>
			<input name="dtresgat" type="text" id="dtresgat" autocomplete="no" value="" />
			
			<br />				
			
			<label for="qtdiacar">
				<div id="divSelecionaCarencia" style="position: absolute; visibility: hidden; background-color: #FFFFFF; border: 1px solid #666666; padding: 2px;"></div>
				Car&ecirc;ncia:
			</label>
			<input name="qtdiacar" type="text" id="qtdiacar" autocomplete="no" value="" />
			<a href="#" id="btnLupaCarencia" style="cursor: default;" onClick="return false;"><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0"></a>		
			<br />
		
			<label for="flgdebci">Conta Investimento:</label>
			<select name="flgdebci" id="flgdebci" >
				<option value="no" selected>N&Atilde;O</option>
				<option value="yes">SIM</option>
			</select>			
		
			<br />
			
			<label for="vllanmto">Valor:</label>
			<input name="vllanmto" type="text" id="vllanmto" autocomplete="no" value="" />
			
			<br />
			
			<label for="txaplica">Percentual/Taxa:</label>
			<input name="txaplica" type="text" id="txaplica" value="" />
			
			<br />
			<br />
			
			<label for="dsaplica">&nbsp;</label>
			<input name="dsaplica" type="text" id="dsaplica" autocomplete="no" value="" />
		
		</fieldset>
		
	</form>
		
	<div id="divBtnAplicacao" style="margin:9px">
		<a href="#" class="botao" id="btCancelar" onClick="showConfirmacao('Deseja cancelar a opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Aimaro','voltarDivPrincipal(); ativaCampo();',metodoBlock,'sim.gif','nao.gif');return false;">Cancelar</a>
		<a href="#" class="botao" id="btConcluir" onClick="controlarAplicacao(true,'I');return false;">Concluir</a>
	</div>
	
</div>