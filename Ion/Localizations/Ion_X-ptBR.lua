--Ion, a World of Warcraft® user interface addon.
--Copyright© 2006-2012 Connor H. Chenoweth, aka Maul - All rights reserved.

-- Brazillian Protuguese translations by:
-- http://www.curseforge.com/profiles/marcelomax/

local L = LibStub("AceLocale-3.0"):NewLocale("Ion", "ptBR", false)

if L then

L.ACTION = "Dados de Ação" -- Needs review
L.ALPHA = "Transparência" -- Needs review
L.ALPHAUP = "Tranparência Ativa" -- Needs review
L.ALPHAUP_BATTLE = "Combate" -- Needs review
L.ALPHAUP_BATTLEMOUSE = "Combate+Mouse Sobre" -- Needs review
L.ALPHAUP_MOUSEOVER = "Mouse sobre" -- Needs review
L.ALPHAUP_RETREAT = "Recuo" -- Needs review
L.ALPHAUP_RETREATMOUSE = "Retirada+Mouse Sobre" -- Needs review
L.ALPHAUP_SPEED = "A/U Velocidade" -- Needs review
L.ALT = "Alt" -- Needs review
L.ALT0 = "Alt Acima" -- Needs review
L.ALT1 = "Alt Abaixo" -- Needs review
L.APPLY = "Aplicar" -- Needs review
L.ARCLENGTH = "Comprimento do Arco" -- Needs review
L.ARCSTART = "Início do Arco" -- Needs review
L.AURAIND = "Indicador de Aura" -- Needs review
L.AURATEXT = "Texto de Visibilidade de Aura" -- Needs review
L.AUTOHIDE = "Auto Ocultar" -- Needs review
L.BAR_ALPHA = "Valor de transparência deve ser entre zero(0) e um(1)" -- Needs review
L.BAR_ARCLENGTH = "Tamanho do arco entre 0 e 359" -- Needs review
L.BAR_ARCSTART = "Início do arco deve ser entre 0 e 359" -- Needs review
L.BAR_COLUMNS = [=[Digite o número de colunas para a barra maior que zero(0)
Omitir o número desliga as colunas]=] -- Needs review
L.BARLOCK_MOD = [=[Teclas modificadoras válidas:

|cff00ff00alt|r: destrava barra quando a tecla <alt> estiver pressionada
|cff00ff00ctrl|r: destrava barra quando a tecla <ctrl> estiver pressionada
|cff00ff00shift|r: destrava barra quando a tecla <shift> estiver pressionada]=] -- Needs review
L.BAR_PADH = "Entre um número válido para o espaço horizontal entre os botões" -- Needs review
L.BAR_PADHV = "Entre um número válido para aumentar/diminuir ambos os espaços, horizontais e verticias entre os botões" -- Needs review
L.BAR_PADV = "Entre um número válido para o espaço vertial entre os botões" -- Needs review
L.BAR_SHAPE1 = "Linear" -- Needs review
L.BAR_SHAPE2 = "Circular" -- Needs review
L.BAR_SHAPE3 = "Circular+Um" -- Needs review
L.BAR_SHAPES = [=[
1=Linear
2=Circular
3=Circular+Um]=] -- Needs review
L.BAR_STATES = "Estados da Barra" -- Needs review
L.BAR_STRATAS = [=[1=FUNDO
2=REBAIXADO
3=MÉDIO
4=ELEVADO
5=DIÁLOGO]=] -- Needs review
L.BARTYPES_LINE = "Cria uma barra para %ss" -- Needs review
L.BARTYPES_TYPES = "Tipos" -- Needs review
L.BARTYPES_USAGE = [=[Uso: |cffffff00/ion criar <tipo>|r
]=] -- Needs review
L.BAR_XPOS = "Entre um número válido para posicionamento em X" -- Needs review
L.BAR_YPOS = "Entre um número válido para posicionamento em Y" -- Needs review
L.BETA_WARNING = [=[Obrigado por instalar Ion!!!

Ion está atualmente em estado de "|cffffff00beta teste|r".

Infelizmente, eu não pude lançar a versão pronta para o patch 5.0.4. A vesão de lançamento deverá estar pronta para a expansão Mists of Pandaria!

Isto significa que nem todas as funções estarão disponíveis e talvez contenham defeitos. Mas, iWhat this means is that not all features are in and there may be bugs. Mas a maior parte está em estado utilizável e estável.

Somente use Ion atualmente se você não se importa em encontrar defeitos ocasionais e não é capaz de fazer tudo que já havia feito com Macaroon! =)

-Maul]=] -- Needs review
L.BINDER_NOTICE = [=[Ion Vinculador de Teclas
|cffffffffO Sistema Original Vinculador Mouse-sobre|r
Desenvolvido por Maul]=] -- Needs review
L.BINDFRAME_BIND = "vicular" -- Needs review
L.BINDFRAME_LOCKED = "travado" -- Needs review
L.BINDFRAME_PRIORITY = "prioridade" -- Needs review
L.BINDINGS_LOCKED = [=[O atalho deste botão está travado.
Clique-esquerdo para destravar.]=] -- Needs review
L.BINDTEXT = "Texto de Atalho" -- Needs review
L.CANCEL = "Cancelar" -- Needs review
L.CDALPHA = "Transparência de Recarga" -- Needs review
L.CDTEXT = "Texto de Recarga" -- Needs review
L.COLUMNS = "Colunas" -- Needs review
L.COMBAT = "Combate" -- Needs review
L.COMBAT0 = "Sem Combate" -- Needs review
L.COMBAT1 = "Combate" -- Needs review
L.CONFIRM = "- Confirmar - " -- Needs review
L.CONFIRM_NO = "Não" -- Needs review
L.CONFIRM_YES = "Sim" -- Needs review
L.COUNT = "Contar" -- Needs review
L.COUNTTEXT = "Contar Texto" -- Needs review
L.CREATE_BAR = "Criar Nova Barra" -- Needs review
L.CTRL = "Ctrl" -- Needs review
L.CTRL0 = "Control Acima" -- Needs review
L.CTRL1 = "Control Abaixo" -- Needs review
L.CUSTOM = "Personalizado" -- Needs review
L.CUSTOM0 = "Estado Personalizado" -- Needs review
L.CUSTOM_ICON = "Ícone Personalizado" -- Needs review
L.CUSTOM_OPTION = [=[
Para estados personalizados, adicione a opção desejada (|cffffff00/ion state custom <opção>|r) onde está <opção> é uma lista de condições de estados separados por ponto e vírgula

|cff00ff00Exemplo:|r [actionbar:1];[stance:1];[stance3,stealth];[mounted]

|cff00ff00Nota:|r o primeiro estado listado será considerado "home state". Se o gerenciador de estados ficar confuso, ele será mudado para o padrão.]=] -- Needs review
L.CUSTOM_STATES = "Personalizar Ação de Estados" -- Needs review
L.DELETE_BAR = "Apagar Barra Atual" -- Needs review
L.DONE = "Concluído" -- Needs review
L.DOWNCLICKS = "Clique Pressionado" -- Needs review
L.DRUID_CASTER = "Forma de Conjurador" -- Needs review
L.DRUID_PROWL = "Prowl" -- Needs review
L.DUALSPEC = "Dupla Espec" -- Needs review
L.EDIT_BINDINGS = "Editar Atalhos" -- Needs review
L.EDITFRAME_EDIT = "editar" -- Needs review
L.EMPTY_BUTTON = "Botão Vazio" -- Needs review
L.EXTRABAR = "Barra Extra" -- Needs review
L.EXTRABAR0 = "Sem Barra Extra" -- Needs review
L.EXTRABAR1 = "Barra Extra" -- Needs review
L.FISHING = "Pesca" -- Needs review
L.FISHING0 = "Sem Vara de Pescar" -- Needs review
L.FISHING1 = "Vara de Pescar" -- Needs review
L.GENERAL = "Opções Gerais" -- Needs review
L.GROUP = "Grupo" -- Needs review
L.GROUP0 = "Sem Grupo" -- Needs review
L.GROUP1 = "Grupo: Raide" -- Needs review
L.GROUP2 = "Grupo: Partido" -- Needs review
L.HIDDEN = "Oculto" -- Needs review
L.HOMESTATE = "Estado Inicial" -- Needs review
L.HPAD = "Esp Horiz" -- Needs review
L.HVPAD = "Esp H + V" -- Needs review
L.INVALID_INDEX = "Índice Inválido" -- Needs review
L.ION = "Ion" -- Needs review
L.KEYBIND_NONE = "nenhum" -- Needs review
L.KEYBIND_TOOLTIP1 = [=[
Pressione uma tecla para vincular]=] -- Needs review
L.KEYBIND_TOOLTIP2 = [=[Clique-esquerdo para |cfff00000TRAVAR|r este %s's atalho

Clique-direito de %s's atalho uma |cff00ff00PRIORIDADE|r

Pressione |cfff00000ESC|r para limpar os atalhos atuais para este %s's]=] -- Needs review
L.KEYBIND_TOOLTIP3 = "Atalho(s) Atual(is):" -- Needs review
L.LASTSTATE = "Não deve ver!" -- Needs review
L.LOCKBAR = "Travar Ações" -- Needs review
L.LOCKBAR_ALT = "- Destravar em ALT" -- Needs review
L.LOCKBAR_CTRL = "- Destravar em CTRL" -- Needs review
L.LOCKBAR_SHIFT = "- Destravar em SHIFT" -- Needs review
L.MACRO = "Dados de Macro" -- Needs review
L.MACRO_EDITNOTE = "Clique para editar a nota de macro" -- Needs review
L.MACRO_NAME = "-nome da macro-" -- Needs review
L.MACROTEXT = "Texto de macro" -- Needs review
L.MACRO_USENOTE = "Use nota de macro como dica de botão" -- Needs review
L.MINIMAP_TOOLTIP1 = "Clique-esquerdo para Configurar Barras" -- Needs review
L.MINIMAP_TOOLTIP2 = "Clique-direito para Editar Botões" -- Needs review
L.MINIMAP_TOOLTIP3 = "Clique-Meio ou Alt-Clique para Editar Teclas de Atalho" -- Needs review
L.OBJECTS = "Editor de Objeto" -- Needs review
L.OFF = "Desligado" -- Needs review
L.OPTIONS = "Opções" -- Needs review
L.OVERRIDE = "Sobrepor" -- Needs review
L.OVERRIDE0 = "Sem Barra de Sobreposição" -- Needs review
L.OVERRIDE1 = "Barra de Sobreposição" -- Needs review
L.PAGED = "Paginado" -- Needs review
L.PAGED1 = "Página 1" -- Needs review
L.PAGED2 = "Página 2" -- Needs review
L.PAGED3 = "Página 3" -- Needs review
L.PAGED4 = "Página 4" -- Needs review
L.PAGED5 = "Página 5" -- Needs review
L.PAGED6 = "Página 6" -- Needs review
L.PATH = "caminho" -- Needs review
L.PET = "Ajudante" -- Needs review
L.PET0 = "Sem Ajudante" -- Needs review
L.PET1 = "Existe Mascote" -- Needs review
L.PETASSIST = "Assistenciar" -- Needs review
L.PETATTACK = "Atacar" -- Needs review
L.PETDEFENSIVE = "Defensivo" -- Needs review
L.PETFOLLOW = "Seguir" -- Needs review
L.PETMOVETO = "Mover para" -- Needs review
L.PETPASSIVE = "Passivo" -- Needs review
L.POINT = "Apotar" -- Needs review
L.POSSESS = "Possuir" -- Needs review
L.POSSESS0 = "Não Possuir" -- Needs review
L.POSSESS1 = "Possuir" -- Needs review
L.PRESET_STATES = "Estados de Ação pré-definidos" -- Needs review
L.PRIEST_HEALER = "Forma de Curador" -- Needs review
L.PROWL = "Prowl" -- Needs review
L.RANGEIND = "Indicador de Alcance" -- Needs review
L.REACTION = "Reação" -- Needs review
L.REACTION0 = "Amigável" -- Needs review
L.REACTION1 = "Hostil" -- Needs review
L.REMAP = "Estado Primário pra Remapear" -- Needs review
L.REMAPTO = "Remapear estado para" -- Needs review
L.ROGUE_MELEE = "Corpo-a-corpo" -- Needs review
L.SCALE = "Escala" -- Needs review
L.SEARCH = "Procurar" -- Needs review
L.SELECT_BAR = "Sem barra selecionada ou comando inválido" -- Needs review
L.SELECT_BAR_TYPE = "- Selecione o Tipo de Barra -" -- Needs review
L.SHAPE = "Forma" -- Needs review
L.SHIFT = "Shift" -- Needs review
L.SHIFT0 = "Shift Acima" -- Needs review
L.SHIFT1 = "Shift Abaixo" -- Needs review
L.SHOWGRID = "Mostrar Grade" -- Needs review
L.SLASH1 = "/ion" -- Needs review
L.SLASH_CMD1 = "Menu" -- Needs review
L.SLASH_CMD10 = "Encaixar" -- Needs review
L.SLASH_CMD10_DESC = "Alterna Encaixes para a barra atual" -- Needs review
L.SLASH_CMD11 = "Auto-ocultar" -- Needs review
L.SLASH_CMD11_DESC = "Alterna Auto-ocultar para a barra atual" -- Needs review
L.SLASH_CMD12 = "Esconder" -- Needs review
L.SLASH_CMD12_DESC = "Alterna se a barra atual é mostrada ou escondida o tempo todo." -- Needs review
L.SLASH_CMD13 = "Forma" -- Needs review
L.SLASH_CMD13_DESC = "Ainda sem tradução para Português brasileiro." -- Needs review
L.SLASH_CMD14 = "Nome" -- Needs review
L.SLASH_CMD14_DESC = "Muda o nome da barra atual" -- Needs review
L.SLASH_CMD15 = "Camadas" -- Needs review
L.SLASH_CMD15_DESC = "Muda o estado atual da camada da moldura" -- Needs review
L.SLASH_CMD16 = "Transparência" -- Needs review
L.SLASH_CMD16_DESC = "Muda a transparência da barra atual" -- Needs review
L.SLASH_CMD17 = "TransparênciaElevada" -- Needs review
L.SLASH_CMD17_DESC = "Configura a condição para \"alpha up\" da barra atual." -- Needs review
L.SLASH_CMD18 = "InícioDoArco" -- Needs review
L.SLASH_CMD18_DESC = "Configura o local de início do arco para barra atual (em graus)" -- Needs review
L.SLASH_CMD19 = "ArcTam" -- Needs review
L.SLASH_CMD19_DESC = "Configura o comprimento do arco para a barra atual (em graus)" -- Needs review
L.SLASH_CMD1_DESC = "Abrir o menu principal" -- Needs review
L.SLASH_CMD2 = "Criar" -- Needs review
L.SLASH_CMD20 = "Colunas" -- Needs review
L.SLASH_CMD20_DESC = "Configura o número de colunas para a barra atual (para forma Multi-colunas)" -- Needs review
L.SLASH_CMD21 = "EspH" -- Needs review
L.SLASH_CMD21_DESC = "Configura o espaço horizontal entre as barras" -- Needs review
L.SLASH_CMD22 = "EspV" -- Needs review
L.SLASH_CMD22_DESC = "Configura o espaço vertical entre as barras" -- Needs review
L.SLASH_CMD23 = "EspHV" -- Needs review
L.SLASH_CMD23_DESC = "Ajusta ambos espaços entre as barras, horizontal e vertical incrementalmente" -- Needs review
L.SLASH_CMD24 = "X" -- Needs review
L.SLASH_CMD24_DESC = "Muda a posição do eixo horizontal para a barra atual" -- Needs review
L.SLASH_CMD25 = "Y" -- Needs review
L.SLASH_CMD25_DESC = "Muda a posição do eixo vertical pra a barra atual" -- Needs review
L.SLASH_CMD26 = "Estado" -- Needs review
L.SLASH_CMD26_DESC = [=[Alterna um estado de ação para a barra atual (|cffffff00/ion state <estado>|r).
    Digite |cffffff00/ion statelist|r para ver os estados válidos]=] -- Needs review
L.SLASH_CMD27 = "Vis" -- Needs review
L.SLASH_CMD27_DESC = [=[Alterna estados de visibilidades para a barra atual (|cffffff00/ion vis <estado> <índice>|r)
|cffffff00<índice>|r = "show" | "hide" | <num>.
Exemplo: |cffffff00/ion vis paged hide|r alternará oculto para todos os estados paginados
Exemplo: |cffffff00/ion vis paged 1|r alternará mostrar/oculta para quando o gerenciador de estado estiver na página 1]=] -- Needs review
L.SLASH_CMD28 = "MostrarGrade" -- Needs review
L.SLASH_CMD28_DESC = "Alterna marcação MostrarGrade para a barra atual" -- Needs review
L.SLASH_CMD29 = "Travar" -- Needs review
L.SLASH_CMD29_DESC = "Alterna a trava da barra. |cffffff00/lock <tecla modif>|r para habilitar/desabilitar a probabilidade de remover habilidades enquanto <tecla modif> estiver presionada (ex: |cffffff00/lock shift|r)" -- Needs review
L.SLASH_CMD2_DESC = [=[Cria uma barra em branco para o tipo selecionado (|cffffff00/ion create <type>|r)
    Digite |cffffff00/ion bartypes|r para ver os tipos disponíveis]=] -- Needs review
L.SLASH_CMD3 = "Apgar" -- Needs review
L.SLASH_CMD30 = "Dicas" -- Needs review
L.SLASH_CMD30_DESC = "Alterna dicas para os botoes da barra atual" -- Needs review
L.SLASH_CMD31 = "BrilhoDeMagia" -- Needs review
L.SLASH_CMD31_DESC = "Alterna a ativação de animações de magias para a barra atual" -- Needs review
L.SLASH_CMD32 = "TextoVinculado" -- Needs review
L.SLASH_CMD32_DESC = "Alterna textos de atalhos na barra atual" -- Needs review
L.SLASH_CMD33 = "TextoMacro" -- Needs review
L.SLASH_CMD33_DESC = "Alterna o texto de nome da macro na barra atual" -- Needs review
L.SLASH_CMD34 = "TextoContador" -- Needs review
L.SLASH_CMD34_DESC = "Alterna contador de magia/item na barra atual" -- Needs review
L.SLASH_CMD35 = "TextoCD" -- Needs review
L.SLASH_CMD35_DESC = "Alterna contador de recarga na barra atual" -- Needs review
L.SLASH_CMD36 = "AlphaCd" -- Needs review
L.SLASH_CMD36_DESC = "Alterna a transparência do botão enquanto estiver em recarga" -- Needs review
L.SLASH_CMD37 = "TextoAura" -- Needs review
L.SLASH_CMD37_DESC = "Alterna a visibilidade dos textos de auras para a barra atual" -- Needs review
L.SLASH_CMD38 = "IndAura" -- Needs review
L.SLASH_CMD38_DESC = "Alterna o indicador de aura do botão para a barra atual" -- Needs review
L.SLASH_CMD39 = "SoltarClique" -- Needs review
L.SLASH_CMD39_DESC = "Alterna se o botão na barra atual responde aos cliques" -- Needs review
L.SLASH_CMD3_DESC = "Apaga a barra atualmente selecionada" -- Needs review
L.SLASH_CMD4 = "Configurar" -- Needs review
L.SLASH_CMD40 = "PressionarClique" -- Needs review
L.SLASH_CMD40_DESC = "Alterna se os botões da barra atual respondem aos cliques" -- Needs review
L.SLASH_CMD41 = "LimiteTempo" -- Needs review
L.SLASH_CMD41_DESC = "Configura o tempo mínimo em segundos para mostrar o texto" -- Needs review
L.SLASH_CMD42 = "ListaEstados" -- Needs review
L.SLASH_CMD42_DESC = "Mostra uma lista de estados válidos" -- Needs review
L.SLASH_CMD43 = "TipoBarras" -- Needs review
L.SLASH_CMD43_DESC = "Mostra uma lista de tipos de barras disponíveis para criar" -- Needs review
L.SLASH_CMD44 = "BarraBlizz" -- Needs review
L.SLASH_CMD44_DESC = "Alterna Barra de ações da Blizzard" -- Needs review
L.SLASH_CMD45 = "BarraVeículo" -- Needs review
L.SLASH_CMD45_DESC = "Alterna a Barra de Veículo da Blizzard" -- Needs review
L.SLASH_CMD4_DESC = "Alterna o modo de configuração para todas as barras" -- Needs review
L.SLASH_CMD5 = "Adicionar" -- Needs review
L.SLASH_CMD5_DESC = "Adiciona botões na barra atual (|cffffff00add|r ou |cffffff00add #|r)" -- Needs review
L.SLASH_CMD6 = "Remover" -- Needs review
L.SLASH_CMD6_DESC = "Remove botões da barra atual (|cffffff00remove|r ou |cffffff00remove #|r)" -- Needs review
L.SLASH_CMD7 = "Editar" -- Needs review
L.SLASH_CMD7_DESC = "Alterna para modo de edição para todos os botões" -- Needs review
L.SLASH_CMD8 = "Vincular" -- Needs review
L.SLASH_CMD8_DESC = "Alterna para modo de edição de atalhos para todos os botões" -- Needs review
L.SLASH_CMD9 = "Escala" -- Needs review
L.SLASH_CMD9_DESC = "Redimensiona a barra para o tamanho desejado" -- Needs review
L.SLASH_HINT1 = [=[
/ion |cff00ff00<comando>|r <opções>]=] -- Needs review
L.SLASH_HINT2 = [=[
Lista de Comandos -
]=] -- Needs review
L.SNAPTO = "Encaixar" -- Needs review
L.SPELLGLOW = "Alerta de Magias" -- Needs review
L.SPELLGLOW_ALT = " - Alerta Subjugado" -- Needs review
L.SPELLGLOW_DEFAULT = " - Alerta Padrão" -- Needs review
L.SPELLGLOWS = [=[Opções válidas:

|cff00ff00padrao|r: usa a animação de brilho padrão da Blizzard nas magias.
|cff00ff00alt|r: usa uma animação de brilho alternativa nas magias]=] -- Needs review
L.STANCE = "Postura" -- Needs review
L.STATE_HIDE = "ocultar" -- Needs review
L.STATE_SHOW = "mostrar" -- Needs review
L.STEALTH = "discrição" -- Needs review
L.STEALTH0 = "Sem discrição" -- Needs review
L.STEALTH1 = "Discrição" -- Needs review
L.STRATA = "Camada" -- Needs review
L.TIMERLIMIT_INVALID = "Limite de tempo inválido" -- Needs review
L.TIMERLIMIT_SET = "Limite de tempo mudado para %d segundos" -- Needs review
L.TOOLTIPS = "Habilitar Dicas" -- Needs review
L.TOOLTIPS_COMBAT = " - Esconder em Combate" -- Needs review
L.TOOLTIPS_ENH = " - Aprimorar" -- Needs review
L.UPCLICKS = "Clique Elevado" -- Needs review
L.VALIDSTATES = [=[
|cff00ff00estados Válidos:|r ]=] -- Needs review
L.VEHICLE = "Veículo" -- Needs review
L.VEHICLE0 = "Sem Veículo" -- Needs review
L.VEHICLE1 = "Veículo" -- Needs review
L.VPAD = "Esp Vert" -- Needs review
L.WARLOCK_CASTER = "Forma de Conjurador" -- Needs review
L.XPOS = "Pos X" -- Needs review
L.YPOS = "Pos Y" -- Needs review

end