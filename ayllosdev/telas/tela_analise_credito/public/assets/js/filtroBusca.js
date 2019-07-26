/**
 * User: Bruno Luiz Katzjarowski - Mout's
 * Date: 08/03/2019
 * Time: 09:50
 * Projeto: ailos_prj438_s8
 */

/* CONSTANTES */
var SETA_CIMA = 38;
var SETA_BAIXO = 40;
var MAX_ITENS_BUSCA = 8; //Define a quantidade de itens que aparecem por vez no campo de busca

/**
 * Funcao principal para o filtro de busca
 */
function startFiltroBusca (){
    $('#searchElements').hide();
    getFiltro();
}

/**
 * Recuperar json para montar filtro
 */
function getFiltro() {
    $.ajax({
        url: 'ajax/getFiltroBusca.php',
        dataType: 'json',
        type: "post",
        error: function(response){
            // em caso de erro
            showLoadingError(response);
        },
        success: function (response) {

            var listaFiltros = Array();

            verify = response.data.personas;

            if(verify) {
            if(response.ok){
                    // console.log(response);
                listaFiltros = montaListaFiltro(response.data.personas);
                    //console.log('listaFiltros: ', listaFiltros);
                montaFiltroBusca(listaFiltros);
            }
            } else {
                console.log(' nop');
            }
        }
    });
}

/**
 * Montar filtro de busca
 * @param {object} listaFiltros
 */
function montaFiltroBusca(listaFiltros){
    var searchBox = $('#filtroBusca');
    var searchElements = $('#searchElements');
    $(searchBox).on('keyup',function(e){
        if(e.keyCode !== 13){
            if(e.keyCode !== SETA_CIMA && e.keyCode !== SETA_BAIXO){
                $(searchBox).data('selecionado',1);
            }
            if($(this).val() === ""){
                $(searchElements).hide();
            }else{
                $(searchElements).show();
                var v = $(this).val().replace(/#/g, '').replace(/>/g, '').replace(/\s\s+/g, ' ');
                preencheFiltro(listaFiltros, v);
            }
        }else{
            var selecionado = $(searchBox).data('selecionado');
            var elem = $('a:nth-child('+selecionado+')',searchElements);
            $(searchBox).val($(elem).data('titulobusca').replace(/#/g, '>'));
            selecionaBusca(elem.data('nomebusca'),elem);
            $(searchBox).blur();
            $(searchElements).hide();
        }
        selecionaElementoFiltro(e.keyCode);
    });
    $(searchBox).off('focusin').on('focusin',function(){
        if($('#filtroBusca').val() !== ""){
            var v = $(this).val().replace(/#/g, '').replace(/>/g, '').replace(/\s\s+/g, ' ');
            $(searchElements).show();
            preencheFiltro(listaFiltros, v);
        }
    });
}

/**
 * @param {int} keyCode Tecla precionada
 */
function selecionaElementoFiltro(keyCode){

    var searchBox = $('#filtroBusca');
    var pureSearchBox = document.getElementById('filtroBusca');
    var searchElements = $('#searchElements');

    //ntd-child selecionado
    var selecionado = parseInt($(searchBox).data('selecionado'));

    var countElements = $('a',searchElements).length;


    switch (keyCode){
        case SETA_CIMA:
            var elem = null;
            pureSearchBox.setSelectionRange(pureSearchBox.value.length, pureSearchBox.value.length);
            if((selecionado-1) <= 0){
                $('a',searchElements).removeClass('selecionado');
                selecionado = 1;
                elem = $('a:nth-child('+(selecionado)+')',$(searchElements));
                elem.addClass('selecionado');
            }else{
                $('a',searchElements).removeClass('selecionado');
                elem = $('a:nth-child('+(selecionado-1)+')',$(searchElements));
                elem.addClass('selecionado');
                selecionado--;
            }
            break;
        case SETA_BAIXO:
            var elem = null;
            pureSearchBox.setSelectionRange(pureSearchBox.value.length, pureSearchBox.value.length);
            if((selecionado+1) > countElements){
                $('a',searchElements).removeClass('selecionado');
                elem = $('a:nth-child('+(countElements)+')',$(searchElements));
                elem.addClass('selecionado');
            }else{
                $('a',searchElements).removeClass('selecionado');
                elem = $('a:nth-child('+(selecionado+1)+')',$(searchElements));
                elem.addClass('selecionado');
                selecionado++;
            }
            break;
    }
    $(searchBox).data('selecionado',selecionado);
}

function attEventosFiltro(){
    var mouseInSearchElements = false;
    var searchBox = $('#filtroBusca');
    $(searchBox).attr('data-selecionado','1');
    var searchElements = $('#searchElements');
    $(searchBox).off('focusout').on('focusout',function(){
        if(!mouseInSearchElements){
            $(searchElements).hide();
        }
    });
    $(searchBox).off('focusout').on('focusout',function(){
        if(!mouseInSearchElements){
            $(searchElements).hide();
        }
    });

    $(searchElements)
        .mouseenter(function() {
            mouseInSearchElements = true;
        })
        .mouseleave(function() {
            mouseInSearchElements = false;
        });

    $('a',searchElements).off('click').on('click',function(e){
        e.preventDefault();
        var elem = $(this);
        $('#filtroBusca').val($(elem).data('titulobusca').replace(/#/g, '>'));
        selecionaBusca($(this).data('nomebusca'));
        $(searchElements).hide();
    });

}

/**
 * Remove as opções preenchidas e procura pelas novas a cada novo digito
 * @param {object} listaFiltros
 * @param {string} listaFiltros.nomeBusca
 * @param {string} listaFiltros.tituloBusca
 * @param {string} value Valor à pesquisar
 */
function preencheFiltro(listaFiltros,value){
    var mouseInSearchElements = false;
    var filtrado = listaFiltros.filter(function(elem, index, array){
        var v = elem.tituloBusca.replace(/#/g, '').replace(/\s\s+/g, ' ');
        return ((v.toUpperCase()).indexOf(value.toUpperCase()) !== -1);
    });
    filtrado = filtrado.slice(0,MAX_ITENS_BUSCA);

    var searchElements = $('#searchElements');

    $('a',searchElements).remove();
    filtrado.forEach(function(filtro){
        var a = $('<a>',{
            href: '#'
        });

        //<a class="filtro" busca_persona="proponente" busca_categoria="cadastro" tipo="busca">teste</a>
        $(a).attr('data-nomebusca',filtro.nomeBusca);
        $(a).attr('data-titulobusca',filtro.tituloBusca);

        var busca_split		= filtro.nomeBusca.split('.');
        var busca_persona   = busca_split[0];
        var busca_categoria = busca_split[1];
        $(a).attr('busca_persona',busca_persona);
        $(a).attr('busca_categoria',busca_categoria);
        $(a).attr('tipo','busca');
        $(a).addClass('filtro');

        $(a).html(filtro.tituloBusca.replace(/#/g, '<i class="fas fa-angle-right"></i>'));
        $(searchElements).append(a);
    });

    var elem = $('a:nth-child(1)',searchElements);
    elem.addClass('selecionado');
    attEventosFiltro();
}

/**
 * Bruno Luiz Katzjarowski - Mout's
 * @param {string} value Valor de busca
 */
function selecionaBusca(value, elem){

    console.log('%cValor de busca: ','color: pink',value);

    if (typeof elem !== 'undefined') {
    	$(elem).trigger('click');
    }

}

/**
 * Bruno Luiz Katzjarowski - Mout's
 * Monta a lista de filtros para criação dos links de retorna no campo de pesquisa
 * @param {object} personas
 * @returns {object}
 */
function montaListaFiltro(personas){

    var personas = makeArray(personas.persona);

    //console.log('personas: ',personas);
    var filtros = Array();
    //Foreach PERSONAS
    personas.forEach(function(persona){
        var filtro = {nomeBusca: '', tituloBusca: ''};
        //console.log('%cPersona: ','color: red;',persona);
        filtro.tituloBusca += persona.tituloTela + ' # '; //# será substituido por getElemArrowLeft() na impressão.
        filtro.nomeBusca += persona.tituloFiltro;

        filtro.tituloBusca = findRedux(filtro);

        //foreach CATEGORIAS
        var categorias = makeArray(persona.categorias.categoria, 'busca');
        categorias.forEach(function(categoria){
            //console.log('%cCategoria: ','color: blue;',categoria);
            var filtroGarantia = {
                tituloBusca: filtro.tituloBusca,
                nomeBusca: filtro.nomeBusca
            };

            filtroGarantia.tituloBusca += categoria.tituloTela + ' # ';
            filtroGarantia.nomeBusca += "."+categoria.tituloFiltro;

            //Foreach SUBCATEGORIAS
            var subcategorias = makeArray(categoria.subcategorias.subcategoria, 'busca');
            subcategorias.forEach(function(subcategoria){

                // se existe subcategoria
                if(typeof subcategoria.separador === "undefined"){

                    var filtroFinal = {
                        tituloBusca: filtroGarantia.tituloBusca,
                        nomeBusca: filtroGarantia.nomeBusca
                    };

                    // se existe campos
                    if(typeof subcategoria.campos !== "undefined"){

                    filtroFinal.tituloBusca += subcategoria.tituloTela + ' # '; //ID dos campos
                    filtroFinal.nomeBusca += "."+slugify(subcategoria.tituloTela); //Texto no campo de busca

                        var campos = makeArray(subcategoria.campos.campo, 'busca');

                        // se existe campo
                        if(typeof campos.campo !== "undefined"){

                            campos.forEach(function(campo){
                                var filtroCampo = {
                                    tituloBusca: filtroFinal.tituloBusca,
                                    nomeBusca: filtroFinal.nomeBusca
                                };
    
                            // se existe nome do campo
                                if(typeof campo.nome !== "undefined"){
                                    filtroCampo.tituloBusca += campo.nome;
                                    filtroCampo.nomeBusca += "."+slugify(campo.nome);
                                    filtros.push(filtroCampo); //Adicionar Filtro
                                }
                            });
                        }else{
                            filtros.push(filtroFinal);
                        }
                    }else{
                        filtros.push(filtroFinal);
                    }
                }

            });

        });
    });

    //console.log('Filtro: ',filtros);
    return filtros;
}

/**
 * @param {object} filtro
 * @param {object} filtro.tituloBusca  -- Titulo que aparece para o usuario
 * @param {object} filtro.nomeBusca -- ID do filtro
 * @returns {string}
 */
function findRedux(filtro){
    if(filtro.tituloBusca !== ""){
        if((filtro.nomeBusca.toLowerCase()).search('grupo_') > -1) {
            var tit = filtro.tituloBusca.replace(/GE/gm,'Grupo Econômico');
            return tit+' # ';
        }
        if((filtro.nomeBusca.toLowerCase()).search('quadro_') > -1) {
            var tit = filtro.tituloBusca.replace(/QS/gm,'Quadro Societário');
            return tit+' # ';
        }
    }
    return filtro.tituloBusca;
}
