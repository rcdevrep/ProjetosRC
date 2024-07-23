#include 'Totvs.ch'
#include 'TOPConn.ch'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#Include "AP5MAIL.CH"
#Include "TBICONN.CH"					 

#DEFINE cEOL Chr(13)+Chr(10) // Fim de linha e próxima linha

//-------------------------------------------------------------------
/*/{Protheus.doc} XAG0124
Monitor de Pedidos Armazem

@author Leandro Spiller
@since 23/11/2023
/*/
//-------------------------------------------------------------------
User Function XAG0124()

    // Parametros da rotina
    Private cPerg 		:= "XAG0124"
    Private _aRotina 	:= {} 

    // Filtro conforme Parâmetros do Usuário
    Private _cFiltro 	:= ""
    Private _cDescDep 	:= ""
    Private _cAGEP		:= ""
    Private  aColumns   := {}//fBuildColumns()
    Private _cUserLib   := SuperGetMv("MV_XSEPMON", ,"001072")

    If !(__cUserID $ _cUserLib .or. FWIsAdmin(__cUserId))
        MsgInfo("MV_XSEPMON - Você não possui liberação para acessar a rotina","Sem Acesso")
        Return
    Endif 

    AtuSX1()
    If !Pergunte(cPerg,.T.)
        Return()
    EndIF

    CriaTrb()

    // Monta a tela conforme os parâmetros
    sfTela()

Return()

Static Function CriaTrb()

    Local cAlias := "XAG0124"
    Local aStruSQL := {}
	
    dbSelectArea("SC9")
	//aStruSQL := dbStruct()

    //Cria campos no TRB
    AADD(aStruSQL,{'C9_XOKSEP',"C",4,0})
    AADD(aStruSQL,{"C9_FILIAL","C",2,0})
    AADD(aStruSQL,{"C9_PEDIDO","C",6,0})
    AADD(aStruSQL,{"C9_CLIENTE","C",6,0})
    AADD(aStruSQL,{"C9_LOJA","C",2,0})
    AADD(aStruSQL,{"C9_NFISCAL","C",9,0})
    AADD(aStruSQL,{"C9_SERIENF","C",3,0})
    AADD(aStruSQL,{"C9_XSREDI","C",3,0})
    AADD(aStruSQL,{"C9_XDTEDI","D",8,0})
    AADD(aStruSQL,{"C9_XHREDI","C",5,0})
    AADD(aStruSQL,{"C9_XDTSEP","D",8,0})
    AADD(aStruSQL,{"C9_XHRSEP","C",5,0})
    AADD(aStruSQL,{"C9_BLCRED","C",2,0})
    AADD(aStruSQL,{"C9_BLEST","C",2,0})
    AADD(aStruSQL,{"C5_EMISSAO","D",8,0})
    AADD(aStruSQL,{"C9_XCODSEP","C",6,0})  //Cod Separador
    AADD(aStruSQL,{"C9_XNOMSEP","C",30,0}) //Nome Separador
    AADD(aStruSQL,{"C9_XCODCON","C",6,0})  //Cod Conferente
    AADD(aStruSQL,{"C9_XNOMCON","C",30,0}) //Nome Conferente 
    AADD(aStruSQL,{"C9_XDTCONF","D",8,0})  //Data Conferencia
    AADD(aStruSQL,{"C9_XHRCONF","C",5,0})  //Hora Conferencia
    AADD(aStruSQL,{"C9_XSTSSEP","C",1,0}) 
    AADD(aStruSQL,{"A1_NOME"   ,"C",240,0}) 
    AADD(aStruSQL,{"A1_EST"    ,"C",2,0}) 
    AADD(aStruSQL,{"A1_COD_MUN","C",5,0})
    AADD(aStruSQL,{"A1_MUN"    ,"C",16,0})
    AADD(aStruSQL,{"A4_NOME "  ,"C",40,0})

    //Adiciona campos na Query 
    cCampos:= ""
    nX := 0
    nMax := Len(aStruSQL)
    aEval( aStruSQL,{|aCampo| nX++, cCampos += aCampo[1] +;
    IIF(nX == nMax,' ',', ')})

    //Fecha Arquivo de trabalho
    If SELECT("XAG0124")
        XAG0124->(DbClosearea())
    Endif 
    
    
    cArqTrb := CriaTrab(aStruSQL,.T.)
    dbUseArea(.T.,__LOCALDRIVER,cArqTrb,cAlias,.T.,.F.)
    
    cQuery := " SELECT "+cCampos+" FROM "+RetSqlName("SC9")+" (NOLOCK) SC9 "
    cQuery += " INNER JOIN "+RetSqlName("SC5")+" (NOLOCK) SC5 ON C5_FILIAL = C9_FILIAL  "
    cQuery += " AND C5_NUM = C9_PEDIDO AND SC5.D_E_L_E_T_ = '' "
    cQuery += " INNER JOIN "+RetSqlName("SC6")+" (NOLOCK) SC6 ON C6_FILIAL = C9_FILIAL  "
    cQuery += " AND C6_NUM = C9_PEDIDO AND C6_ITEM = C9_ITEM AND SC6.D_E_L_E_T_ = '' "
    cQuery += " LEFT JOIN "+RetSqlName("SA1")+" (NOLOCK) SA1 ON A1_FILIAL = '"+xFilial('SA1')+"'  "
    cQuery += " AND A1_COD = C5_CLIENTE  AND A1_LOJA = C5_LOJACLI AND SA1.D_E_L_E_T_ = '' " 
    cQuery += " LEFT JOIN "+RetSqlName("SA4")+" (NOLOCK) SA4 ON A4_FILIAL = '"+xFilial('SA4')+"'  "
    cQuery += " AND A4_COD = C5_TRANSP AND SA4.D_E_L_E_T_ = '' " 
    cQuery += " WHERE C9_FILIAL = '"+xFilial('SC9')+"'  "
    cQuery += " AND C9_PEDIDO BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' "
    cQuery += " AND C9_CLIENTE   BETWEEN '" + mv_par03 + "' AND '" + mv_par05 + "' "
    cQuery += " AND C9_LOJA      BETWEEN '" + mv_par04 + "' AND '" + mv_par06 + "' "
    cQuery += " AND C9_LOCAL     BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' "
    cQuery += " AND C5_EMISSAO   BETWEEN '" + DTOS(mv_par09) + "' AND '" +DTOS(mv_par10) + "' "
    cQuery += " AND C9_DATALIB   BETWEEN '" +DTOS(mv_par11) + "'  AND '" +DTOS(mv_par12)+ "' "
    cQuery += " AND C6_ENTREG    BETWEEN '" +DTOS(mv_par13) + "'  AND '" +DTOS(mv_par14)+ "' "
    If Mv_par15 == 2 //Pendente Imp. Mapa
        cQuery += " AND C9_XDTEDI = '' AND C9_XDTSEP = ''  "
    ElseIf Mv_par15 == 3//Pendente Sep.
        cQuery += "  AND C9_XDTEDI <> '' AND C9_XDTSEP = ''  "
    ElseIf Mv_par15 == 4//Pendente Conf.
        cQuery += " AND C9_XDTSEP <> '' AND  C9_XDTCONF = '' "
    ElseIf Mv_par15 == 5//Conferidos
        cQuery += " AND C9_XDTCONF <> ''  "
    Endif 
    
    If Mv_par16 == 2 //Não mostra Faturados
        cQuery += " AND  NOT( C9_BLEST = '10' AND C9_BLCRED = '10' ) "
     Endif

    cQuery += " AND C9_BLEST IN (' ', 'ZZ','10')  AND  C9_BLCRED IN (' ', 'ZZ','10') "
    cQuery += " AND (C9_PRODUTO  NOT LIKE '%801' OR C9_PRODUTO IN ('49067801','49167801') ) "
    cQuery += " AND SC9.D_E_L_E_T_ = '' "
   

    // MV_PAR15 Mapa? = com Mapa / Sem Mapa / Todos
    // MV_PAR16 Status = Separados / Conferidos / todos
    // MV_PAR17 Mostra Faturados? = Sim / Não

    //cQuery += " AND C9_PEDIDO    BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "' "
    cQuery += " GROUP BY "+cCampos+""
    
 /* aAdd( aDados, {'XAG0124','01','Pedido  de' ,'Pedido de','Pedido de',  'mv_ch1','C',6,0,0,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
    aAdd( aDados, {'XAG0124','02','Pedido  ate','Pedido ate','Pedido Ate','mv_ch2','C',6,0,0,'G','','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
    aAdd( aDados, {'XAG0124','03','Cliente  De','Cliente  De','Cliente  De','mv_ch3','C',Tamsx3("A1_COD")[1],0,0,'G','','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
    aAdd( aDados, {'XAG0124','04','Loja     De','Loja     De','Loja     De','mv_ch4','C',Tamsx3("A1_LOJA")[1],0,0,'G','','MV_PAR04','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
    aAdd( aDados, {'XAG0124','05','Cliente  ate','Cliente  ate','Cliente  ate','mv_ch5','C',Tamsx3("A1_COD")[1],0,0,'G','','MV_PAR05','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
    aAdd( aDados, {'XAG0124','06','Loja     ate','Loja     ate','Loja     ate','mv_ch6','C',Tamsx3("A1_LOJA")[1],0,0,'G','','MV_PAR06','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
    aAdd( aDados, {'XAG0124','07','Armazem  de' ,'Armazem de', 'Armazem de',  'mv_ch7','C',Tamsx3("B2_LOCAL")[1],0,0,'G','','MV_PAR07','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
    aAdd( aDados, {'XAG0124','08','Armazem  ate','Armazem ate','Armazem Ate', 'mv_ch8','C',Tamsx3("B2_LOCAL")[1],0,0,'G','','MV_PAR08','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
    aAdd( aDados, {'XAG0124','09','Emissao de','Emissao de','Emissao de','mv_ch9','D',8,0,0,'G','','MV_PAR09','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
    aAdd( aDados, {'XAG0124','10','Emissao ate','Emissao ate','Emissao ate','mv_cha','D',8,0,0,'G','','MV_PAR10','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
    aAdd( aDados, {'XAG0124','11','Liberacao de','Liberacao de','Liberacao de','mv_chb','D',8,0,0,'G','','MV_PAR11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
    aAdd( aDados, {'XAG0124','12','Liberacao ate','Liberacao ate','Liberacao ate','mv_chc','D',8,0,0,'G','','MV_PAR12','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
    aAdd( aDados, {'XAG0124','13','Data Entrega de','Entrega de','Entrega de','mv_chd','D',8,0,0,'G','','MV_PAR13','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
    aAdd( aDados, {'XAG0124','14','Data Entrega ate','Entrega ate','Entrega ate','mv_che','D',8,0,0,'G','','MV_PAR14','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
    aAdd( aDados, {'XAG0124','15','Mostrar','Mostrar  ','Mostrar ','mv_chf','C',1,0,0,'C','','MV_PAR15','Todos','','','','','Sem Mapa','','','','','Com Mapa','','','','','Nao Separados','','','','','','','','','','','','','',''} )
*/
 
    SqlToTrb(cQuery,aStruSQL,cAlias)
    
    cArqInd := CriaTrab(Nil,.F.)
    
   // cChave := "A1_FILIAL+A1_COD+A1_LOJA"
    cChave := "C9_FILIAL+C9_PEDIDO+C9_XSREDI"
    IndRegua(cAlias,cArqInd,cChave,,,"Indexando Registros...")

    dbSelectArea( cAlias )
    dbGotop()
Return



// Monta a tela para o Usuário
Static Function sfTela()

    Local aCoors   := FWGetDialogSize( oMainWnd )
    Local oPanelUp, oFWLayer, oPanelDown

    // Definição de fontes
    Local oFontN15   := TFont():New( "Arial",0,-20,,.T.,0,,700,.F.,.F.,,,,,, )

    Private oDlgPrinc, oBrowseSC9, oSayDep 

    aCpos := {}

    aColumns := getColunas()
    
    // Tecla de atalho para parâmetros
    SetKey(VK_F5,  { ||  MsAguarde( {|| U_XAG0124D() }, "Atualizando..." ) } )
    SetKey(VK_F12, { ||  U_XAG0124P() } )

    Define MsDialog oDlgPrinc Title 'Separacao de pedidos' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel

    //
    // Cria o conteiner onde serão colocados os browses
    //
    oFWLayer := FWLayer():New()
    oFWLayer:Init( oDlgPrinc, .F., .T. )

    //
    // Define Painel Superior
    //
    oFWLayer:AddLine( 'UP', 10, .F. )                       // Cria uma "linha" com 10% da tela
    oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )            // Na "linha" criada eu crio uma coluna com 100% da tamanho dela
    oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )         // Pego o objeto desse pedaço do container

    // Nome do Depositante
    oSayDep  := TSay():New( 012,004,{||_cDescDep},oPanelUp,,oFontN15,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,350,012)
    
    //
    // Painel Inferior
    //
    oFWLayer:AddLine( 'DOWN', 90, .F. )                     // Cria uma "linha" com 50% da tela
    oFWLayer:AddCollumn( 'ALL' ,  100, .T., 'DOWN' )        // Na "linha" criada eu crio uma coluna com 100% da tamanho dela
    oPanelDown  := oFWLayer:GetColPanel( 'ALL' , 'DOWN' )   // Pego o objeto desse pedaço do container

    //
    // FWmBrowse Superior Cabecalho Pre Pedido de Venda
    //
    oBrowseSC9:= FWMarkBrowse():New()
    oBrowseSC9:SetOwner( oPanelDown )                          // Aqui se associa o browse ao componente de tela
    oBrowseSC9:SetDescription( ' Monitor de Separação de Pedidos' )
    oBrowseSC9:SetAlias( 'XAG0124' )
    oBrowseSC9:SetFieldMark( 'C9_XOKSEP' )
    //oBrowseSC9:SetFields(aCpos) // Define os campos a serem mostrados no MarkBrowse
    
    //oBrowseSC9:SetAllMark({|| sfMarcAll() }) // Indica o Code-Block executado no clique do header da coluna de marca/desmarca
    //oBrowseSC9:SetCustomMarkRec({|| sfMarca() }) // Indica o Code-Block executado para marcação/desmarcação customizada do registro
    
    // Monta o filtro conforme os parametros
    //_cFiltro := sfMontaFiltro()
    //oBrowseSC9:SetFilterDefault( _cFiltro )      // Filtra somente os Pre Pedidos de Venda (0=Em andamento;1=Concluidos)
    oBrowseSC9:SetMenuDef( 'XAG0124' )                        // Define de onde virao os botoes deste browse


    //Sem Mapa
    oBrowseSC9:AddLegend( "Empty(C9_XDTEDI) .AND. alltrim(C9_XSTSSEP) == '' .AND. ( C9_BLEST <> '10' .AND. C9_BLCRED <> '10' )  ",  "BR_PINK"    ,  "Sem Mapa" )
    //Mapa Estornado
    oBrowseSC9:AddLegend( "alltrim(C9_XSTSSEP) == 'E' .AND. ( C9_BLEST <> '10' .AND. C9_BLCRED <> '10' )  ",  "BR_PRETO"    ,  "Mapa Estornado" )  
    //Sem Separador
    oBrowseSC9:AddLegend( "!Empty(C9_XDTEDI) .AND. alltrim(C9_XCODSEP) == '' .AND. alltrim(C9_XSTSSEP) == '' .AND. ( C9_BLEST <> '10' .AND. C9_BLCRED <> '10' )  ",  "BR_VERDE"    ,  "Nao Atribuido" )
    //Em Separacao
    oBrowseSC9:AddLegend( "!Empty(C9_XDTEDI)  .AND. alltrim(C9_XSTSSEP) == 'A' .AND. ( C9_BLEST <> '10' .AND. C9_BLCRED <> '10' )  ",  "BR_CINZA"    ,  "Em  Separacao" )
    //Sem conferente
    oBrowseSC9:AddLegend( "!Empty(C9_XDTEDI)  .AND. alltrim(C9_XSTSSEP) == 'B' .AND. ( C9_BLEST <> '10' .AND. C9_BLCRED <> '10' )  ",  "BR_AZUL"    ,  "Separado" )
    //Em Conferencia
    oBrowseSC9:AddLegend( "!Empty(C9_XDTEDI)  .AND. alltrim(C9_XSTSSEP) == 'C' .AND. ( C9_BLEST <> '10' .AND. C9_BLCRED <> '10' )  ",  "BR_AMARELO"    ,  "Em conferencia" )
    //Conferido
    oBrowseSC9:AddLegend( "!Empty(C9_XDTEDI)  .AND. alltrim(C9_XSTSSEP) == 'D' .AND. ( C9_BLEST <> '10' .AND. C9_BLCRED <> '10' )  ",  "BR_LARANJA"    ,  "Conferido" )
    //faturado
    oBrowseSC9:AddLegend( " ( C9_BLEST == '10' .AND. C9_BLCRED == '10' )  ",  "BR_VERMELHO"    ,  "Faturado" )
    //Divergencia
    oBrowseSC9:AddLegend( " !Empty(C9_XDTEDI)  .AND. alltrim(C9_XSTSSEP) $ 'G/H' .AND. ( C9_BLEST <> '10' .AND. C9_BLCRED <> '10' )  ",  "BR_BRANCO"    ,  "Com divergencia" )
   
   
    oBrowseSC9:DisableDetails()
    //oBrowseSC9:SetProfileID( '10' )
    oBrowseSC9:ForceQuitButton()
    oBrowseSC9:SetAmbiente(.F.) // Desabilita a utilização da funcionalidade Ambiente no Browse
    oBrowseSC9:SetWalkThru(.F.) // Desabilita a utilização da funcionalidade Walk-Thru no Browse
    oBrowseSC9:SetColumns(aColumns)

    // Ativa o Browse
    oBrowseSC9:Activate()

    Activate MsDialog oDlgPrinc Center

    // Limpa tecla de atalho
    Set Key VK_F5  TO
    Set Key VK_F12 TO

Return NIL


//Obtem Colunas
Static Function getColunas()
     
    Local nX       := 0 
    Local aColumns := {}
    Local aStruct  := {}
     
    AADD(aStruct,{'C9_XOKSEP',"C",4,0,      'OK'})
    AADD(aStruct,{"C9_PEDIDO","C",6,0,  'Pedido'})
    AADD(aStruct,{"C9_XSREDI","C",3,0,  'Seq.Sep'})
    AADD(aStruct,{"C9_XDTEDI","D",8,0,  'Dt.Mapa'})
    AADD(aStruct,{"C9_XHREDI","C",5,0,  'Hr.Mapa'})
    AADD(aStruct,{"C9_XDTSEP","D",8,0,  'Dt.Sep'})
    AADD(aStruct,{"C9_XHRSEP","C",5,0,  'Hr Sep'})
    AADD(aStruct,{"C9_XCODSEP","C",6,0, 'Cod. Sep'})  //Cod Separador
    AADD(aStruct,{"C9_XNOMSEP","C",30,0,'Nome Sep'})  //Nome Separador
    AADD(aStruct,{"C9_XDTCONF","D",8,0, 'Dt Conf'})   //Data Conferencia
    AADD(aStruct,{"C9_XHRCONF","C",5,0, 'Hr Conf'})   //Hora Conferencia
    AADD(aStruct,{"C9_XCODCON","C",6,0, 'Cod. Conf'}) //Cod Conferente
    AADD(aStruct,{"C9_XNOMCON","C",30,0,'Nome Conf'}) //Nome Conferente 
    AADD(aStruct,{"C9_CLIENTE","C",6,0, 'Cliente'})
    AADD(aStruct,{"C9_LOJA","C",2,0,    'Loja'})
    AADD(aStruct,{"A1_NOME","C",240,0,  'Nome'})
    AADD(aStruct,{"A1_MUN","C",16,0,    'Municipio'})
    AADD(aStruct,{"A4_NOME ","C",40,0,  'Transportadora'})
    AADD(aStruct,{"C9_NFISCAL","C",9,0, 'Nota Fiscal'})
    AADD(aStruct,{"C9_SERIENF","C",3,0, 'Serie'})
    AADD(aStruct,{"C9_FILIAL","C",2,0,  'Filial'})
    AADD(aStruct,{"C9_XSTSSEP","C",1,0,'Status'})
    
             
    For nX := 2 To Len(aStruct)    
        AAdd(aColumns,FWBrwColumn():New())
        aColumns[Len(aColumns)]:SetData( &("{||"+aStruct[nX][1]+"}") )
        aColumns[Len(aColumns)]:SetTitle(aStruct[nX][5])
        aColumns[Len(aColumns)]:SetSize(aStruct[nX][3])
        aColumns[Len(aColumns)]:SetDecimal(aStruct[nX][4])              
    Next nX

Return aColumns

//-------------------------------------------------------------------
// Validação e Marcação da linha.
//-------------------------------------------------------------------
Static Function sfMarca()

    Local _cMark := oBrowseSC9:cMark // Marcação 

    // Desmarca
    If SC9->C9_XOKSEP = _cMark 
    
        // Realiza a desmarcação
        RecLock("SC9",.F.)
            SC9->C9_XOKSEP := SPACE(2)
        SC9->(MsUnlock())
        
        Return()	
    EndIF

    // Realiza a marcação

    DbSelectArea("SB1")
    dbSetOrder(1)
    dbSeek(xFilial("SB1") +  SC9->C9_PRODUTO )

    IF substr(SC9->C9_PRODUTO, len(alltrim(SC9->C9_PRODUTO))-2, 3) == "801" .AND. SB1->B1_TIPO == 'SH' 
        MsgAlert("Produto granel, verifique!", "XAG01105")
        return()
    endif

    //if ( SC9->C9_BLCRED == '10' .or. SC9->C9_BLCRED == '' )  .AND. (  SC9->C9_BLEST == '10' .AND. SC9->C9_BLEST == ' '  ) 
    if  SC9->C9_BLEST <> '01' .AND. SC9->C9_BLCRED <>'01'  .AND. SC9->C9_BLEST <> '02' .AND. SC9->C9_BLCRED <> '02'
        
        //And (trim(C9_PRODUTO) NOT LIKE '%801' AND B1_TIPO = 'SH'  ) 
    
            if !EMPTY(SC9->C9_XDTEDI)
                IF MsgYesNo('Pedido '+SC9->C9_PEDIDO+', Item '+SC9->C9_ITEM+ ' ja ENVIADO em'+DTOC(SC9->C9_XDTEDI)+' às '+SC9->C9_XHREDI+', deseja marcar mesmo assim?  ', "Sim ou Não.")
                    RecLock("SC9",.F.)
                    SC9->C9_XOKSEP := _cMark
                    SC9->(MsUnlock())
                ENDIF
            Elseif SC9->C9_BLEST == '10'
                IF MsgYesNo('Pedido '+SC9->C9_PEDIDO+', Item '+SC9->C9_ITEM+ ' ja foi FATURADO e nao ENVIADO  , deseja marcar mesmo assim?  ', "Sim ou Não.")
                    RecLock("SC9",.F.)
                    SC9->C9_XOKSEP := _cMark
                    SC9->(MsUnlock())
                ENDIF
            ELSE
                RecLock("SC9",.F.)
                SC9->C9_XOKSEP := _cMark
                SC9->(MsUnlock())
            ENDIF
    
    else    
        MsgAlert("Pedido Com Bloqueio, verifique!", "XAG0124")
    endif

Return()


//-------------------------------------------------------------------
/*/{Protheus.doc} sfMarcAll

Marcação/Inversão de marcação dos dados conforme o status.

@author Júnior
@since 06/01/23
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function sfMarcAll()

    // Marcação
    Local _cMark := oBrowseSC9:cMark

    // Obs.: Neste momento os dados na tabela SF2 estão filtrados (set filter)
    // conforme os parametros do usuário, por isso pode-se utilizar o While sem condições

    // Inicio do Arquivo
    SC9->(DBGOTOP())

    While !SC9->(EOF())

        DbSelectArea("SB1")
        dbSetOrder(1)
        dbSeek(xFilial("SB1") +  SC9->C9_PRODUTO )

        IF  !(substr(SC9->C9_PRODUTO, len(alltrim(SC9->C9_PRODUTO))-2, 3) == "801" .AND. SB1->B1_TIPO == 'SH' )//!( ("801" $ ALLTRIM(SC9->C9_PRODUTO) ) .AND.  SB1->B1_TIPO = 'SH' )

        // Realiza a marcação ou inversão
            RecLock("SC9",.F.)
            If SC9->C9_XOKSEP = _cMark
                SC9->C9_XOKSEP := SPACE(2)
            Elseif   SC9->C9_BLEST <> '01' .AND. SC9->C9_BLCRED <>'01'  .AND. SC9->C9_BLEST <> '02' .AND. SC9->C9_BLCRED <> '02' // ( SC9->C9_BLCRED == '10' .or. SC9->C9_BLCRED == ' ' )  .AND. (  SC9->C9_BLEST == '10' .AND. SC9->C9_BLEST == ' '  ) 
                if  !EMPTY(SC9->C9_XDTEDI)
                    IF MsgYesNo('Pedido '+SC9->C9_PEDIDO+', Item '+SC9->C9_ITEM+ ' ja ENVIADO em'+DTOC(SC9->C9_XDTEDI)+' às '+SC9->C9_XHREDI+' deseja marcar mesmo assim? ' , "Sim ou Não.")
                        SC9->C9_XOKSEP := _cMark
                    Endif 
                Elseif SC9->C9_BLEST == '10'
                    IF MsgYesNo('Pedido '+SC9->C9_PEDIDO+', Item '+SC9->C9_ITEM+ ' ja foi FATURADO e NAO ENVIADO , deseja marcar mesmo assim?  ', "Sim ou Não.")
                        RecLock("SC9",.F.)
                            SC9->C9_XOKSEP := _cMark
                        SC9->(MsUnlock())
                    ENDIF
                Else
                    SC9->C9_XOKSEP := _cMark
                Endif 
            ELSE              
            // MsgAlert("Pedido Com Bloqueio, verifique!", "XAG01105")
            ENDIF	
            SC9->(MsUnlock())
        
        Endif
        // Próximo registro filtrado
        SC9->(DBSKIP())

EndDo

// Atualiza a tela
oBrowseSC9:Refresh(.T.)

Return 



//Parametros para novo filtro no browser
User Function XAG0124P()

    // Parametros
    If Pergunte(cPerg,.T.)
        
        CriaTrb()
        // Atualiza filtro
        //_cFiltro := sfMontaFiltro()	
        oBrowseSC9:SetFilterDefault( )
        
        // Atualiza a tela
        oSayDep:Refresh()
        oBrowseSC9:Refresh(.T.)

    EndIF

Return()


//Atualizar Tela (F5)
User Function XAG0124D()

    // Parametros
    Pergunte(cPerg,.F.)
     CriaTrb()   
    // Atualiza filtro
    //_cFiltro := sfMontaFiltro()	
    oBrowseSC9:SetFilterDefault( )

    // Atualiza a tela
    oBrowseSC9:Refresh(.T.)
	
Return


//Atualiza perguntas
Static Function AtuSX1()
    
    Local aArea    := GetArea()
    Local aAreaDic := SX1->( GetArea() )
    Local aEstrut  := {}
    Local aStruDic := SX1->( dbStruct() )
    Local aDados   := {}
    Local nI       := 0
    Local nJ       := 0
    Local nTam1    := Len( SX1->X1_GRUPO )
    Local nTam2    := Len( SX1->X1_ORDEM )

    aEstrut := { "X1_GRUPO"  , "X1_ORDEM"  , "X1_PERGUNT", "X1_PERSPA" , "X1_PERENG" , "X1_VARIAVL", "X1_TIPO"   , ;
                "X1_TAMANHO", "X1_DECIMAL", "X1_PRESEL" , "X1_GSC"    , "X1_VALID"  , "X1_VAR01"  , "X1_DEF01"  , ;
                "X1_DEFSPA1", "X1_DEFENG1", "X1_CNT01"  , "X1_VAR02"  , "X1_DEF02"  , "X1_DEFSPA2", "X1_DEFENG2", ;
                "X1_CNT02"  , "X1_VAR03"  , "X1_DEF03"  , "X1_DEFSPA3", "X1_DEFENG3", "X1_CNT03"  , "X1_VAR04"  , ;
                "X1_DEF04"  , "X1_DEFSPA4", "X1_DEFENG4", "X1_CNT04"  , "X1_VAR05"  , "X1_DEF05"  , "X1_DEFSPA5", ;
                "X1_DEFENG5", "X1_CNT05"  , "X1_F3"     , "X1_PYME"   , "X1_GRPSXG" , "X1_HELP"   , "X1_PICTURE", ;
                "X1_IDFIL"  }


    aAdd( aDados, {'XAG0124','01','Pedido  de' ,'Pedido de','Pedido de',  'mv_ch1','C',6,0,0,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
    aAdd( aDados, {'XAG0124','02','Pedido  ate','Pedido ate','Pedido Ate','mv_ch2','C',6,0,0,'G','','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
    aAdd( aDados, {'XAG0124','03','Cliente  De','Cliente  De','Cliente  De','mv_ch3','C',Tamsx3("A1_COD")[1],0,0,'G','','MV_PAR03','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
    aAdd( aDados, {'XAG0124','04','Loja     De','Loja     De','Loja     De','mv_ch4','C',Tamsx3("A1_LOJA")[1],0,0,'G','','MV_PAR04','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
    aAdd( aDados, {'XAG0124','05','Cliente  ate','Cliente  ate','Cliente  ate','mv_ch5','C',Tamsx3("A1_COD")[1],0,0,'G','','MV_PAR05','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
    aAdd( aDados, {'XAG0124','06','Loja     ate','Loja     ate','Loja     ate','mv_ch6','C',Tamsx3("A1_LOJA")[1],0,0,'G','','MV_PAR06','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
    aAdd( aDados, {'XAG0124','07','Armazem  de' ,'Armazem de', 'Armazem de',  'mv_ch7','C',Tamsx3("B2_LOCAL")[1],0,0,'G','','MV_PAR07','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
    aAdd( aDados, {'XAG0124','08','Armazem  ate','Armazem ate','Armazem Ate', 'mv_ch8','C',Tamsx3("B2_LOCAL")[1],0,0,'G','','MV_PAR08','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
    aAdd( aDados, {'XAG0124','09','Emissao de','Emissao de','Emissao de','mv_ch9','D',8,0,0,'G','','MV_PAR09','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
    aAdd( aDados, {'XAG0124','10','Emissao ate','Emissao ate','Emissao ate','mv_cha','D',8,0,0,'G','','MV_PAR10','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
    aAdd( aDados, {'XAG0124','11','Liberacao de','Liberacao de','Liberacao de','mv_chb','D',8,0,0,'G','','MV_PAR11','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
    aAdd( aDados, {'XAG0124','12','Liberacao ate','Liberacao ate','Liberacao ate','mv_chc','D',8,0,0,'G','','MV_PAR12','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
    aAdd( aDados, {'XAG0124','13','Data Entrega de','Entrega de','Entrega de','mv_chd','D',8,0,0,'G','','MV_PAR13','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
    aAdd( aDados, {'XAG0124','14','Data Entrega ate','Entrega ate','Entrega ate','mv_che','D',8,0,0,'G','','MV_PAR14','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
    aAdd( aDados, {'XAG0124','15','Status','Status  ','Status ','mv_chf','C',1,0,0,'C','','MV_PAR15','Todos','','','','','Sem Mapa','','','','','Pendente Sep.','','','','','Pendente Conf.','','','','','Conferidos','','','','','','','','',''} )
    aAdd( aDados, {'XAG0124','16','Mostra Faturados','Mostra Faturados  ','Mostra Faturados ','mv_chg','C',1,0,0,'C','','MV_PAR16','Sim','','','','','Não','','','','','','','','','','','','','','','','','','','','','','','',''} )


    dbSelectArea( "SX1" )
    SX1->( dbSetOrder( 1 ) )

    For nI := 1 To Len( aDados )
        If !SX1->( dbSeek( PadR( aDados[nI][1], nTam1 ) + PadR( aDados[nI][2], nTam2 ) ) )
            RecLock( "SX1", .T. )
            For nJ := 1 To Len( aDados[nI] )
                If aScan( aStruDic, { |aX| PadR( aX[1], 10 ) == PadR( aEstrut[nJ], 10 ) } ) > 0
                    SX1->( FieldPut( FieldPos( aEstrut[nJ] ), aDados[nI][nJ] ) )
                EndIf
            Next nJ
            MsUnLock()
        EndIf
    Next nI

    // Atualiza Helps
    //AtuSX1Hlp()

    RestArea( aAreaDic )
    RestArea( aArea )

Return NIL


// MenuDef
Static Function MenuDef()

    Local _aRotina := {}
    Local aRotAtrib := {}
    Local aRotExec := {}
    Local aRotOutros := {}

    AADD(aRotAtrib, { 'Separador' 	  	, ' msAguarde( { || U_XAG0124S("A",.T.),U_XAG0124D() }, "Abrindo Tela de separação, Aguarde...") ' , 0, 2, 0, NIL } )
    AADD(aRotAtrib, { 'Conferente' 	  	, ' msAguarde( { || U_XAG0124S("C",.T.),U_XAG0124D() }, "Abrindo Tela de conferencia, Aguarde...") ' , 0, 2, 0, NIL } )

    AADD(aRotExec, { 'Separação' 	  	, ' msAguarde( { || U_XAG0124S("B",.T.),U_XAG0124D() }, "Abrindo Tela de separação, Aguarde...") ' , 0, 2, 0, NIL } )
    AADD(aRotExec, { 'Conferencia' 	  	, ' msAguarde( { || U_XAG0124S("D",.T.),U_XAG0124D() }, "Abrindo Tela de conferencia, Aguarde...") ' , 0, 2, 0, NIL } )

    AADD(aRotOutros, { 'Separacao' 	  	  , 'msAguarde( { || U_XAG0124S("E",.T.),U_XAG0124D() }, "Abrindo Tela de separação, Aguarde...") ' , 0, 2, 0, NIL } )
    AADD(aRotOutros, { 'Conferencia' 	  , 'msAguarde( { || U_XAG0124S("F",.T.),U_XAG0124D() }, "Abrindo Tela de conferencia, Aguarde...") ' , 0, 2, 0, NIL } )
    AADD(aRotOutros, { 'Mapa de Separacao', 'msAguarde( { || U_XAG0123E(  "" ,.T.),U_XAG0124D()  }, "Estornando Mapa de Separacao...") ' , 0, 2, 0, NIL } )

    aAdd( _aRotina, { ' Atribuir'	        , aRotAtrib 		, 0, 2, 0, NIL } )
    aAdd( _aRotina, { ' Executar  '   	    , aRotExec, 0, 2, 0, NIL } )
    aAdd( _aRotina, { 'Estornar  '   	    , aRotOutros, 0, 2, 0, NIL } )
    

    aAdd( _aRotina, { 'Atualizar(F5)'		, 'msAguarde( { || U_XAG0124D() }, "Atualizando, Aguarde...") ' , 0, 2, 0, NIL } )
    aAdd( _aRotina, { 'Parametros(F12)'		, 'msAguarde( { || U_XAG0124P() }, "Parametros, Aguarde...") ' , 0, 2, 0, NIL } )
    aAdd( _aRotina, { 'Log Separacao  '		, 'msAguarde( { || U_XAG0124L() }, "Log de separação Aguarde...") ' , 0, 2, 0, NIL } )
    aAdd( _aRotina, { 'Imprimir Mapa  '		, 'msAguarde( { || U_XAG0123(  , .F. ,  ,  MV_PAR07 ,  MV_PAR08 , "" ,.T.),U_XAG0124D()  }, "Imprimindo Mapa de Separacao...") ' , 0, 2, 0, NIL } )
   
                                                    //                  (xPedidos,xAuto,xDatabase,xLocalde,xlocalate,xPrinter,Lbrw)

    //u_SMSAGR05(/*xPedidos*/,.t./*xAuto*/,dDatabase/*xDatabase*/,'01'/*xLocal*/,"Microsoft Print to PDF")


Return _aRotina


//View de dados
Static Function ViewDef()
*************************
    Local oView
    Local oModel     := FWLoadModel( 'XAG0124' )
    Local oStruct    := FWFormStruct( 2, 'XAG0124', /*bAvalCampo*/,/*lViewUsado*/ )

    oView := FWFormView():New()
    oView:SetModel( oModel )
    oView:AddField( 'XAG0124_VIEW', oStruct, 'SC9MASTER'  )

    oView:CreateHorizontalBox( 'FORMFIELD', 100 )
    oView:SetOwnerView( 'XAG0124_VIEW', 'FORMFIELD' )
    oView:SetDescription( 'Monitor de Separacao' )

Return oView

//Modelo de dados
Static Function Modeldef()
**************************
    Local oModel     := NIL
    Local oStruct    := NIL

    oStruct := FWFormStruct( 1, 'XAG0124', /*bAvalCampo*/,/*lViewUsado*/ )

    oModel  := MPFormModel():New( 'XAG0124M',, )
    oModel:AddFields( 'SC9MASTER', NIL, oStruct,, )
    oModel:SetDescription( 'Modelo de dados Envio de arquivo' )
    oModel:GetModel( 'SC9MASTER' ):SetDescription( 'Monitor de Separacao' )

Return oModel


//Log de Separação 
User Function XAG0124L(lBrw)

   	Local oBrowse
    Local cPedPosic := ""
	Private oProcess  := NIL
	Private cCadastro := "LOG de Separacao"
	PRIVATE aRotina:= {{"Pesquisar","AxPesqui",0,1},;
	                   { "Visualizar","AxVisual" , 0 , 2}}/*,;
	                   { "Importar","u_XAG029J()" , 0 , 3},;
	                   { "Excluir LOGS","u_635ZEXC()", 0 , 4}}*/

    oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZC9")
	oBrowse:SetDescription(cCadastro)
   
    If MSGYESNO( 'Exibir Log apenas do pedido posicionado? ', 'Posicionado' )
        If alltrim(XAG0124->C9_XSREDI) <> ''
            oBrowse:SetFilterDefault("ZC9_FILIAL+ZC9_NUM+ZC9_SEQ $ '"+XAG0124->C9_FILIAL+ XAG0124->C9_PEDIDO+XAG0124->C9_XSREDI+"'")// .AND. DTOS(ZDB_DATA) >= DDATABASE ")
        Else
            oBrowse:SetFilterDefault("ZC9_FILIAL+ZC9_NUM $ '"+XAG0124->C9_FILIAL+ XAG0124->C9_PEDIDO+"'")
        Endif 
    Endif
    
    //oBrowse:AddFilter("Data","DTOS(ZDB_DATA) == DTOS(DDATABASE)")
	//Desliga a exibição dos detalhes
	//	oBrowse:DisableDetails()
	oBrowse:Activate()

Return 

//Executar separação
User Function XAG0124A()

    Local _lSetEnv := .F.
    Local nColor := 16767370 //Azul 

    //Se for executado via atalho Inicia o ambiente
    If type('cEmpant') <> 'C'
        _lSetEnv := .T.

    	PREPARE ENVIRONMENT Empresa '01' Filial '06' Tables "SA1","SA2","SB1","SF2","SD2","SF3","SE1","SF4","SX5","XXS","SC5","SC6"
		
	  	RPCSetType()
        If !RpcSetEnv('01','06')
            Alert('Não foi possível inciar o ambiente, tente novamente mais tarde!')
        Endif 
    Endif 
    

    Static oDlgMain
    Static oButton2
    Static oButton3
    
    DEFINE MSDIALOG oDlgMain TITLE "  Executar  " FROM 000, 000  TO 800, 800 COLORS 0, 1675038 PIXEL

        @ 042, 091 BUTTON oButton3 PROMPT "SEPARAÇÃO"   SIZE 232, 128 ACTION(U_XAG0124S('B',.F.))   OF oDlgMain PIXEL
        @ 190, 091 BUTTON oButton2 PROMPT "CONFERENCIA" SIZE 228, 128 ACTION(U_XAG0124S('D',.F.))OF oDlgMain PIXEL
       // DEFINE SBUTTON FROM 145.5,195 COLORS 0, 16711680  TYPE 1 ACTION (nOpca := 1) ENABLE OF oDlgMain

        //Grava com cor azul
        oDlgMain:NCLRPANE := nColor

    ACTIVATE MSDIALOG oDlgMain CENTERED

    If _lSetEnv
        RpcClearEnv()
        RESET ENVIRONMENT	
    Endif 
Return


//Atribuir Separador/Conferente
User Function XAG0124B()

    Static oDlgMain
    Static oButton2
    Static oButton3
    Local nColor := 12058623 //Amarelo 

    Local  _cUserLib   := SuperGetMv("MV_XSEPATR", ,"001072")

    If !(__cUserID $ _cUserLib .or. FWIsAdmin(__cUserId))
        MsgInfo("MV_XSEPATR - Você não possui liberação para acessar a rotina","Sem Acesso")
        Return
    Endif 


    DEFINE MSDIALOG oDlgMain TITLE "  Atribuir  " FROM 000, 000  TO 800, 800 COLORS 0, 1675038 PIXEL

        @ 042, 091 BUTTON oButton3 PROMPT "SEPARADOR"   SIZE 232, 128 ACTION(U_XAG0124S('A',.F.))   OF oDlgMain PIXEL
        @ 190, 091 BUTTON oButton2 PROMPT "CONFERENTE" SIZE 228, 128 ACTION(U_XAG0124S('C',.F.))OF oDlgMain PIXEL
       // DEFINE SBUTTON FROM 145.5,195 COLORS 0, 16711680  TYPE 1 ACTION (nOpca := 1) ENABLE OF oDlgMain

        //Grava com cor azul
        oDlgMain:NCLRPANE := nColor

    ACTIVATE MSDIALOG oDlgMain CENTERED

Return
