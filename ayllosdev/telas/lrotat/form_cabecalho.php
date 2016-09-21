<?

/**
* FONTE        : form_cabecalho.php								Última alteração: 02/08/2016
* CRIAÇÃO      : Otto - RKAM
* DATA CRIAÇÃO : 06/07/2016
* OBJETIVO     : Mostrar o form com as opções da tela LROTAT
* --------------
* ALTERAÇÕES   : 12/07/2016 - Ajustes para finzaliZação da conversáo 
                              (Andrei - RKAM)

				 02/08/2016 - Ajuste para corrigir nome das opções disponíveis na tela
							 (Adriano).
* --------------
*/


session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
isPostMethod();

?>
<form id="frmCab" name="frmCab" class="formulario cabecalho" style="display:none;">

	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao">
		<option value="A">A - Alterar linha de cr&eacute;dito rotativo</option>
		<option value="B">B - Bloquear linha de cr&eacute;dito rotativo</option>
		<option value="C" selected="true">C - Consultar linha de cr&eacute;dito rotativo</option>
		<option value="L">L - Liberar linha de cr&eacute;dito rotativo</option>
		<option value="E">E - Excluir linha de cr&eacute;dito rotativo</option>
		<option value="I">I - Incluir linha de cr&eacute;dito rotativo</option>
	</select>

	<a href="#" class="botao" id="btnOK" name="btnOK" style = "text-align:right;">OK</a>
	
	<br style="clear:both" />	
    
</form>
