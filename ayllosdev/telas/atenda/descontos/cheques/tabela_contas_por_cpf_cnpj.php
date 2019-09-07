<? 
/*!
* FONTE        : tabela_contas_por_cpf_cnpj.php
* CRIAÇÃO      : Mateus Zimmermann (Mouts)
* DATA CRIAÇÃO : 18/10/2018 
* OBJETIVO     : Tabela que apresenta as contas do CPF/CNPJ
* ALTERAÇÕES   : 
* --------------
*
*/
?>

<div id="divTabelaContasPorCpfCnpj">
    <div class="divRegistros">	
        <table>
            <thead>
                <tr>
                    <th><? echo utf8ToHtml('Conta');?></th>
                </tr>
            </thead>		
            <tbody>
                <? foreach( $contas as $conta ) {?>
                <tr>
                    <td><? echo formataContaDV(getByTagName($conta->tags,'nrdconta')) ?></td>

                    <input type="hidden" id="nrdconta" value="<? echo formataContaDV(getByTagName($conta->tags,'nrdconta')) ?>" />
                </tr>
                <? } ?>
            </tbody>
        </table>
    </div>
    <div id="divBotoes">
        <a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divUsoGenerico'), $('#divRotina')); return false;">Voltar</a>
        <a href="#" class="botao" id="btSalvar" style="margin-bottom: 5px;" onClick=<?php echo "confirmarConta('".$nomeCampoConta."','".$nomeForm."');"; ?> >Confirmar</a>
    </div>
</div>