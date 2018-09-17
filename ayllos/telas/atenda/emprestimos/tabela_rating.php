 <? 
/*!
 * FONTE        : tabela_rating.php
 * CRIAÇÃO      : Marcelo L. Pereira (GATI)
 * DATA CRIAÇÃO : 11/11/2011 
 * OBJETIVO     : Tabela que apresenta o rating
 *
 * ALTERACOES   : 001: [05/09/2012] Mudar para layout padrao (Gabriel)
 */	
?>

<div id="divParcelasTab">
	<div class="divRegistros">	
        <table>
            <thead>
                <tr>
                    <th>Data</th>
                    <th>Tipo</th>
                    <th>Contrato</th>
                    <th>Risco</th>
                    <th>Nota</th>
					<th><? echo utf8ToHtml('Vl. Utl. Rating');?></th>
				</tr>
            </thead>		
            <tbody id="tBodyParcelas">
			
            </tbody>
        </table>
    </div>
    <div id="divBotoes">
	<a href="#" class="botao" id="btSalvar" onClick="controlaOperacao(''); return false;">Continuar</a>
    </div>
</div>