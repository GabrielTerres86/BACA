<?php
/* !
 * FONTE        : FINALI.php
 * CRIAÇÃO      : André Santos / SUPERO
 * DATA CRIAÇÃO : 15/08/2013
 * OBJETIVO     : Exibe Dados - Tela FINALI
 * --------------
 * ALTERAÇÕES   : 05/06/2014 - Alterado format do cdlcremp de 3 para 4 
 * --------------              Softdesk 137074 (Lucas R.)
 *
 *				  10/08/2015 - Alterações e correções (Lunelli SD 102123)
 *
 */

session_start();

require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');

isPostMethod();

?>

<div id="divFinali" style="display:block" >
    <fieldset>
        <form id="frmFinali" name="frmFinali" class="formulario" onSubmit="return false;" style="display:block" >            
            <fieldset>
                <legend>Linhas de Cr&eacute;dito</legend>
                <?php				
					if ($cddopcao == "I") {
					?>
					<table width=100%>
						<tr><td>&nbsp;</td></tr>
						<tr>
							<td>
							<label for="cdlcremp">C&oacute;digo:</label>
							<input type="text" id="cdlcremp" name="cdlcremp" value="" />
							<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisaLcr();return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>	
							<input type="text" id="dslcremp" name="dslcremp" value="" />
							<a href="#" class="botao" id="btInserir" onclick="btnInserirLcr(cCdlcremp.val(), cDslcremp.val()); return false;" >Inserir</a>&nbsp;
							</td>
						</tr>
						<tr><td>&nbsp;</td></tr>
					</table>
					<?php
					}					
					include('tab_finali.php');
				?>				
            </fieldset>
            <fieldset>
                <legend>Situa&ccedil;&atilde;o</legend>
                <label for="dssitfin" >Situa&ccedil;&atilde;o:</label>
                <input id="dssitfin" name="dssitfin" value="<?php echo $dssitfin; ?>" />
            </fieldset>            
        </form>
    </fieldset>
</div>