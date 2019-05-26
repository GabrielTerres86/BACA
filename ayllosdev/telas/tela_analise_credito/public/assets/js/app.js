/* 
*  @author Mout's - Anderson Schloegel
*  Ailos - Projeto 438 - sprint 9 - Tela Única de Análise de Crédito
*  fevereiro/março de 2019
* 
*  Scripts para gerenciar filtros de personas e categorias, 
* 
*/

/* 
*  BACKDROP de carregamento
*/

loading(true);

$(document).ready(function(){

    /*
    *  Modo de exibição lado a lado
    */

    startSideBySide();

    /* 
    *  FILTRO DE BUSCA
    */

    $('#searchElements').hide();
    setTimeout(startFiltroBusca, 1000);
    // startFiltroBusca();

    /*
    *  AFFIX submenu personas
    *
    *  faz o submenu de personaas fixar fixo quando a página é rolada
    */

    var target = $('.html_sub_filtro');
    target.after('<div class="affix" id="affix"></div>');

    var affix = $('.affix');
    // affix.append(target.clone(true));
    affix.html(target.clone(true));

    // Show affix on scroll
    var element = document.getElementById('affix');
    if (element !== null) {
        var position = target.position();
        window.addEventListener('scroll', function () {
            var height = $(window).scrollTop();
            // quando no topo da página, desativa affix
            if (height > 0) {
                target.css('visibility', 'hidden');
                affix.css('display', 'block');
            // se rolou 1px ou mais, ativa affix
            } else {
                affix.css('display', 'none');
                target.css('visibility', 'visible');
            }
        })
    }
});