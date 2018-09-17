<? 
/*!
 * FONTE        : autorizar_resgate.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 07/12/2017
 * OBJETIVO     : Formulario que apresenta as formas de autorizacao
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

session_start();

// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
require_once("../../../../includes/config.php");
require_once("../../../../includes/funcoes.php");
require_once("../../../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo método POST
isPostMethod();	

// Classe para leitura do xml de retorno
require_once("../../../../class/xmlfile.php");

?>

<div id="divAutorizar">
	<form id="formImpres" ></form>
	<form name="frmAutorizar" id="frmAutorizar" class="formulario">

		<input name="flgautoriza" id="flgAutorizaSenha" type="radio" onchange="alteraOpcaoAutorizar()" class="radio" value="senha" />
		<label for="flgAutorizaSenha" class="radio">Solicitar senha do cooperado</label>

		<div id="divAutSenha">
			<label for="dssencar">Senha:</label>
			<input type="password" id="dssencar" name="dssencar" />
		</div>

		<div id="divAutIB">
			<input name="flgautoriza" id="flgAutorizaIB" type="radio" onchange="alteraOpcaoAutorizar()" class="radio" value="ib" />
			<label for="flgAutorizaIB" class="radio"><? echo utf8ToHtml('Aprovação via Internet Banking') ?></label>
		</div>

		<input name="flgautoriza" id="flgAutorizaComprovante" type="radio" onchange="alteraOpcaoAutorizar()" class="radio" value="comprovante" />
		<label for="flgAutorizaComprovante" class="radio"><? echo utf8ToHtml('Imprimir autorização') ?></label>

		<!-- <div id="divNomeDoc">
			<label for="nomeresg">Nome:</label>
			<input type="text" id="nomeresg" name="nomeresg" />
			<label for="docuresg">CPF:</label>
			<input type="text" id="docuresg" name="docuresg" />
		</div> -->

		<br />
	</form>
	<div id="divBotoes" style="padding-bottom:10px">
		<a href="#" class="botao" id="btVoltar" onclick="fechaRotina(divRotina); return false;">Voltar</a>
		<a href="#" class="botao" id="btProsseguirAutorizacao" onclick="prosseguirAutorizacao(); return false;" >Prosseguir</a>
	</div>
</div>