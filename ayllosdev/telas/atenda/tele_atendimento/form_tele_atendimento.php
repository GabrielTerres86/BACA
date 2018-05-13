<?php
	//************************************************************************//
	//*** Fonte: form_tele_atendimento.php                                 ***//
	//*** Autor: Rog�rius Milit�o - DB1                                    ***//
	//*** Data : 30/06/2011               Ultima Alteracao: 28/01/2014     ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar rotina de Tele Atendimento da tela ATENDA    ***//
	//***                                                                  ***//	 
	//*** Altera��es: 30/11/2012 - Desabilitar autocomplete (David). 	   ***//
	//*** 			  08/11/2013 - Adi��o das divs "divCadastrarSenhaURA"  ***//
	//*** e "divCriaSenhaURA" para cadastro da senha (Cristian)			   ***//
	//***     		  18/11/2013 - Alterada a fun��o chamada no evento     ***//
	//***     		   OnClick nas divs de cadastro para chamar uma fun��o ***//
	//***     		   Unica (Cristian)									   ***//
	//***						   										   ***//
	//***     		  28/01/2014 - Alterado evento ao clicar em alterar e  ***//
	//***						   cadastrar senha para chamar a procedure ***//
	//***						   verifica_senha_ura. (Reinert)		   ***//
	//************************************************************************//

	
	session_start();
	
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');		
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	
	
	
?>	
	<div id="divDadosSenhaURA">

		<form action="" name="frmURA" id="frmURA" class="formulario" method="post">
		
			<br /><br />
			
			<label for="nmopeura">Operador:</label>
			<input type="text" name="nmopeura" id="nmopeura" />
		
			<br />
			
			<label for="dtaltsnh">Data de Altera&ccedil;&atilde;o:</label>
			<input type="text" name="dtaltsnh" id="dtaltsnh" />
			
			<br />

			<label for="botao1"></label>
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/alterar_senha.gif" onClick="senhaURA();return false;">
			
		</form>
		
	</div>
	
	<div id="divAlteraSenhaURA">
		
		<form action="" name="frmSenhaURA" id="frmSenhaURA" class="formulario" method="post">
			
			<div id="msgSenhaURA">
			2 Primeiras posi&ccedil;&otilde;es n&uacute;mericas deve ser <strong><?php if (strlen($glbvars["cdcooper"]) == 1) { echo "0".$glbvars["cdcooper"]; } else { echo $glbvars["cdcooper"]; } ?>
			</div>
			
			<label for="cddsenh1">Senha:</label>
			<input type="password" autocomplete="no" name="cddsenh1" id="cddsenh1" />
			
			<br />
			
			<label for="cddsenh2">Confirma Senha:</label>
			<input type="password" autocomplete="no" name="cddsenh2" id="cddsenh2" />
			
			<br />

			<label for="botao2"></label>
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="retornarOpcaoPrincipal();return false;">
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/alterar.gif" onClick="verifica_senha_ura();return false;">
		
		</form>		
			
	</div>
	
	<!-- Div dara para o usuario a op��o de cadastrar uma nova senha, caso a mesma n�o esteja cadastrada -->
	<div id="divCadastrarSenhaURA">

		<form action="" name="frmCadURA" id="frmCadURA" class="formulario" method="post">
		
			<br /><br />
			
			<label for="nmopeura">Operador:</label>
			<input type="text" name="nmopeura" id="nmopeura" />
		
			<br />
			<label for="botao3"></label>
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/cadastrar_senha.gif" onClick="mostraCriaSenhaURA();return false;">
			
		</form>
		
	</div>
	
	<!-- Div servira para o usuario cadastrar uma nova senha, caso a mesma n�o esteja cadastrada -->
	<div id="divCriaSenhaURA">
		
		<form action="" name="frmCriaSenhaURA" id="frmCriaSenhaURA" class="formulario" method="post">
			
			<div id="msgSenhaURA">
			2 Primeiras posi&ccedil;&otilde;es n&uacute;mericas deve ser <strong><?php if (strlen($glbvars["cdcooper"]) == 1) { echo "0".$glbvars["cdcooper"]; } else { echo $glbvars["cdcooper"]; } ?>
			</div>
			
			<label for="cddsenh1">Senha:</label>
			<input type="password" autocomplete="no" name="cddsenh1" id="cddsenh1" maxLength="8" />
			
			<br />
			
			<label for="cddsenh2">Confirma Senha:</label>
			<input type="password" autocomplete="no" name="cddsenh2" id="cddsenh2" maxLength="8" />
			
			<br />

			<label for="botao2"></label>
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="retornarOpcaoPrincipal();return false;">
			<input type="image" src="<?php echo $UrlImagens; ?>botoes/cadastrar.gif" onClick="verifica_senha_ura();return false;">
		
		</form>		
			
	</div>
	
	
	