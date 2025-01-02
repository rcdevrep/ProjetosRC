//Bibliotecas
#Include "TOTVS.CH"
#Include "FWMVCDef.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'RWMAKE.CH'
#include "fileio.ch"
#INCLUDE "TOPCONN.CH"

// RC CONSULTORIA
// EVANDRO BURLIN
// ROTINA RCKHR01 - RC1_CONCR MARKETPLACE 
// PROJETO - RC1_CONCR MARKETPLACE
// DATA - 09/10/2024

User Function RCKHR01()
	Local aArea        :=  FWGetArea()
	Local aCposCab     :=  {}
	Local aCposGrd1    :=  {}
	Local aCposGrd2       :=  {}
	Local aPergs       :=  {}
	Local aTitulos
	Local nX
	Local cSpace       := Space(17)
	Local lAborta      := .F.
	Private cTableCab, cTableGr1, cTableGr2
	Private oBrowse    :=  Nil
	Private aRotina    :=  MenuDef()
	Private aBrows, aGrd1, aGrd2    //Varias com estrutura de colunas para ser utilizado no browser, no fields e nos grids
	Private cAlisCab   := GetNextAlias()
	Private cAlisGr1   := GetNextAlias()
	Private cAlisGr2   := GetNextAlias()
	Private cfilqry
	Private aSelFil  :=  {}
	Private oGrd1
	Private oGrd2
	Private oCabec

	// Perguntas de parametros para Funcao
	//aAdd(aPergs, {1, "Da Conta", '           ',  "@!", ".T.", "CT1", ".T.", 80,  .T.})
	aAdd(aPergs, {1, "Registro de",   sTod('        '),  "", ".T.", "", ".T.", 80,  .T.})
	aAdd(aPergs, {1, "Registros ate",  sTod('        '),  "", ".T.", "", ".T.", 80,  .T.})
	aAdd(aPergs ,{3, "Seleciona Filiais",1,{"Sim","Nao"},50,"",.T.})
	aAdd(aPergs ,{3, "Somente Divergentes",2,{"Sim","Nao"},50,"",.T.})
	//aAdd(aPergs ,{3, "Somente Div. Sld Final",2,{"Sim","Nao"},50,"",.T.})
	//aAdd(aPergs, {1, "Do Item", cSpace,  "@!", ".T.", "CTD", ".T.", 80,  .F.})
	//aAdd(aPergs, {1, "Ate o Item", 'ZZZZZZZZZZZZZZZZZ',  "@!", ".T.", "CTD", ".T.", 80,  .F.})

	If ParamBox(aPergs, "Informe os parâmetros para definicao dos filtros da rotina")

		///----------------------------------------------------------
		//Cria tabela para browser que sera usada no filds do MVC
		//----------------------------------------------------------
        /*aAdd(aCposCab,{"ID","C",6,00})
        aAdd(aCposCab,{"ITEM_TAB","C",10,00})
        aAdd(aCposCab,{"DESC_ITEM","C",30,00})
        aAdd(aCposCab,{"FIN_SLA","N",15,2})
        aAdd(aCposCab,{"FIN_DEB","N",15,2})
        aAdd(aCposCab,{"FIN_CRE","N",15,2})
        aAdd(aCposCab,{"FIN_SLF","N",15,2})
        aAdd(aCposCab,{"CTB_SLA","N",15,2})
        aAdd(aCposCab,{"CTB_DEB","N",15,2})
        aAdd(aCposCab,{"CTB_CRE","N",15,2})
        aAdd(aCposCab,{"CTB_SLF","N",15,2})
        aAdd(aCposCab,{"DEF_TAB","C",1,0})
        aAdd(aCposCab,{"DIF_VAL","N",15,2})*/

        aAdd(aCposCab,{"ID","C",8,0})
        aAdd(aCposCab,{"RC1_TIPO","C",10,0})
        aAdd(aCposCab,{"RC1_PERIOD","D",08,0})
        aAdd(aCposCab,{"RC1_TOTAL","N",10,2})
        aAdd(aCposCab,{"RC1_CONC","N",10,2})
        aAdd(aCposCab,{"RC1_PEND","N",10,2})
        aAdd(aCposCab,{"RC1_MOVIM","N",10,2})
            
        //Array com nome dos campos para Browser
        //aTitulos := {'ID Rotina', "Codigo", "Nome", "Fin. Sl. Ant.","Fin. Debito","Fin. Credito","Fin. Sl. Fin.","Ctb. Sl. Ant." ,"Ctb. Debito","Ctb. Credito" ,"Ctb. Sl. Fin.", "Div.", "Diferença" }
        aTitulos := {'Id','Tipo', "Periodo", "Total", "Conciliado.","Pendente","Movimento Bancario" }
 
        //Funcao para gerar as colunas do Browser
        aBrows  :=  gerCpBrow(aCposCab,aTitulos)
        If oCabec <> Nil
            oCabec:Delete()
            oCabec  :=  Nil
        Endif
        oCabec := FWTemporaryTable():New(cAlisCab)
        oCabec:SetFields(aCposCab)
        oCabec:AddIndex("1", {"ID"})
        //oCabec:AddIndex("1", {"RC1_PERIOD"})
        //oCabec:AddIndex("2", {"ITEM_TAB"})
        oCabec:Create()
         
        //Obtenho o nome "verdadeiro" da tabela no BD (criada como tempor ria)
        cTableCab  :=  oCabec:GetRealName()
 
 
 
        //----------------------------------------------------------
        //Cria tabela grid 1 para ser usado  do MVC
        //----------------------------------------------------------
 
        If oGrd1 <> Nil
            oGrd1:Delete()
            oGrd1  :=  Nil
        Endif
 
        oGrd1  :=  FWTemporaryTable():New(cAlisGr1)
         
        /*aAdd(aCposGrd1,{"ID"        ,"C",06,0})
        aAdd(aCposGrd1,{"ITEM"      ,"C",03,0})
        aAdd(aCposGrd1,{"DATS"      ,"C",10,0})
        aAdd(aCposGrd1,{"DOC"       ,"C",09,0})
        aAdd(aCposGrd1,{"HIST"      ,"C",50,0})
        aAdd(aCposGrd1,{"FIN_DEB"   ,"N",18,2})
        aAdd(aCposGrd1,{"FIN_CRED"  ,"N",18,2})
        aAdd(aCposGrd1,{"SALDO"     ,"N",18,2})*/

        aAdd(aCposGrd1,{"ID","C",8,0})
        aAdd(aCposGrd1,{"RC2_FILIAL","C",2,0})
        aAdd(aCposGrd1,{"RC2_NUM","C",10,0})
        aAdd(aCposGrd1,{"RC2_TIPO","C",10,0})
        aAdd(aCposGrd1,{"RC2_VALOR","N",10,2})
        aAdd(aCposGrd1,{"RC2_TAXA","N",11,4})
        aAdd(aCposGrd1,{"RC2_EMISSA","D",08,0})
        aAdd(aCposGrd1,{"RC2_PARCEL","C",3,0})
        aAdd(aCposGrd1,{"RC2_VENC","D",08,0})
 
        //aTitulos := {'ID Rotina',  "Item","Data", "Documento", "Historico","Fin. Debito","Fin. Credito", "Saldo" }
        aTitulos := {'Id','Filial','Numero',  "Tipo","Valor","Taxa", "Emissao", "Parcela","Vencimento"}
        aGrd1 := gerCpBrow(aCposGrd1,aTitulos)
 
 
        oGrd1:SetFields(aCposGrd1)
        oGrd1:AddIndex("1", {"ID"})
        //oGrd1:AddIndex("1", {"RC2_VENC"})
        //oGrd1:AddIndex("2", {"DATS"})
        //oGrd1:AddIndex("3", {"DOC"})
        oGrd1:Create()
        //Obtenho o nome "verdadeiro" da tabela no BD (criada como tempor ria)
        cTableGr1  :=  oGrd1:GetRealName()
 
 
        //----------------------------------------------------------
        //Cria tabela grid 2 para ser usado  do MVC
        //----------------------------------------------------------
 
        If oGrd2 <> Nil
            oGrd2:Delete()
            oGrd2  :=  Nil
        Endif
 
        oGrd2  :=  FWTemporaryTable():New(cAlisGr2)
 
        /*aAdd(aCposGrd2,{"ID"        ,"C",06,0})
        aAdd(aCposGrd2,{"ITEM"      ,"C",03,0})
        aAdd(aCposGrd2,{"DATS"      ,"C",10,0})
        aAdd(aCposGrd2,{"LOTE"      ,"C",09,0})
        aAdd(aCposGrd2,{"HIST"      ,"C",50,0})
        aAdd(aCposGrd2,{"FIN_DEB"   ,"N",18,2})
        aAdd(aCposGrd2,{"FIN_CRED"  ,"N",18,2})
        aAdd(aCposGrd2,{"SALDO"     ,"N",18,2})*/

        aAdd(aCposGrd2,{"RC3_LEGEND","C",30,0})
        aAdd(aCposGrd2,{"ID","C",8,0})
        aAdd(aCposGrd2,{"RC3_FILIAL","C",2,0})
        aAdd(aCposGrd2,{"RC3_DOCTEF","C",20,0})
        aAdd(aCposGrd2,{"RC3_PREFIX","C",3,0})
        aAdd(aCposGrd2,{"RC3_NUM","C",9,0})
        aAdd(aCposGrd2,{"RC3_PARCEL","C",3,0})
        aAdd(aCposGrd2,{"RC3_TIPO","C",3,0})
        aAdd(aCposGrd2,{"RC3_STATUS","C",1,0})
        aAdd(aCposGrd2,{"RC3_RECEBI","N",10,2})
        aAdd(aCposGrd2,{"RC3_DATA","D",8,0})
        aAdd(aCposGrd2,{"RC3_IMPORT","C",20,0})

 
        //aTitulos := {'ID Rotina', "Item","Data", "Lote", "Historico","Fin. Debito","Fin. Credito", "Saldo" }
        aTitulos := {'Legenda','Id','Filial',"NSU","Prefixo", "Numero", "Parcela","Tipo","Status","Recebido","Data","Importacao"}
        aGrd2 := gerCpBrow(aCposGrd2,aTitulos)
 
 
        oGrd2:SetFields(aCposGrd2)
        oGrd2:AddIndex("1", {"ID"})
        //oGrd2:AddIndex("1", {"RC3_VENC"})
        //oGrd2:AddIndex("2", {"DATS"})
        //oGrd2:AddIndex("3", {"LOTE"})
        oGrd2:Create()
        //Obtenho o nome "verdadeiro" da tabela no BD (criada como tempor ria)
        cTableGr2  :=  oGrd2:GetRealName()
 
        //----------------------------------------------------------
        //Preenchimento dos dados nas tabelas
        //----------------------------------------------------------
        If MV_PAR03 == 1 .And. Len( aSelFil ) <= 0
            aSelFil  :=  AdmGetFil()
            If Len( aSelFil ) <= 0
                lAborta := .T.
            Else
                cfilqry  :=  "("
                For nX  :=  1 to len(aSelFil)
                    cfilqry += "'"+aSelFil[nX]+"',"
                Next
                cfilqry  :=  substr(cfilqry,1,len(cfilqry)-1) + ")"
            EndIf
        EndIf
 
        If ! lAborta
            MsgRun("Carregando dados de movimentação financeira...",,{||CursorWait(),GrvFin(),CursorArrow()})
 
             
            dbSelectArea(cAlisGr1)
            dbSelectArea(cAlisGr2)
 
            //----------------------------------------------------------
            //Montagem do browser
            //----------------------------------------------------------
            oBrowse :=  FwMBrowse():New()
            oBrowse:SetDescription("Concilicao Financeira") 
            oBrowse:SetAlias(cAlisCab) 
            oBrowse:SetWalkThru(.F.)
            oBrowse:SetAmbiente(.T.) 
            oBrowse:SetTemporary(.T.)
            oBrowse:SetFields(aBrows)

            //oBrowse:AddLegend( "RC3_STATUS == 'B'", "GREEN", "Baixado" )
            //oBrowse:AddLegend( "RC3_STATUS == 'E'", "RED",   "Não Encontrado" )

            oBrowse:Activate()
        EndIf
 
        //--------------------------------
        //Exclui tabelas temporarias
        //--------------------------------
        If oCabec <> Nil
            oCabec:Delete()
            oCabec  :=  Nil
        Endif
 
        If oGrd1 <> Nil
            oGrd1:Delete()
            oGrd1  :=  Nil
        Endif
 
        If oGrd2 <> Nil
            oGrd2:Delete()
            oGrd2  :=  Nil
        Endif
    EndIF
    FWRestArea(aArea)
Return
 
/*/{Protheus.doc} MenuDef
Menu da rotina
@type  Function
@author Fabricio Antunes
@since 22/09/2021
/*/
 
Static Function MenuDef()
    Local aRot  :=  {}
    Local aSubMenu := {}

    aAdd(aSubMenu, {"Redecard",     "U_FRECEB()", 0, 2, 0, NIL})
    aAdd(aSubMenu, {"Pagarme",     "U_FIN011()", 0, 2, 0, NIL})
         
    aAdd(aRot, {"Conciliar", "VIEWDEF.RCKHR01", 0, 4, 0, NIL})
    aAdd(aRot, {"Importar",  aSubMenu,      0, 2, 0, NIL})   
 
Return(Aclone(aRot))
 
/*/{Protheus.doc} ModelDef
Modelo de dados MVC para edicao da tabela temporaria
@type  Function
@author Fabricio Antunes
@since 22/09/2021
/*/
 
Static Function ModelDef()
    Local oModel   :=  Nil
    Local osCabec  :=  FWFormModelStruct():New()
    Local osGrd1   :=  FWFormModelStruct():New()
    Local osGrd2   :=  FWFormModelStruct():New()
    Local nX
    Local bPre     :=  {|oModel, cAction, cIDField, xValue| validPre(oModel, cAction, cIDField, xValue)}
    Local bPos     :=  {|oModel| fieldValidPos(oModel)}
    Local bLoad    :=  {|oModel, lCopy| loadField(oModel, lCopy)}
    Local bLoaGr1  :=  {|oModel, lCopy| loadGrd(oModel, lCopy,"GR1")}
    Local bLoaGr2  :=  {|oModel, lCopy| loadGrd(oModel, lCopy,"GR2")}
 
    For nX := 1 to Len(aBrows)
        aBrows[nX,6]=.F.
    Next
    osCabec:AddTable(cAlisCab, {"ID"}, "Concilicao Financeira")
 
    For nX := 1 to Len(aGrd1)
        aadd(aGrd1[nX],.F.)
    Next
 
    For nX := 1 to Len(aGrd2)
         aadd(aGrd2[nX],.F.)
    Next
 
    /*----------------------------------------------------------------------
    Estrutura do array para montagem dos campos usados na funcao MntStrut
        1 - Descricao
        2 - Nome do Campo
        3 - Tipo do campo
        4 - Tamanho do campo
        5 - Decimal
        6 - Se campo e editavel
    ------------------------------------------------------------------------*/
 
    MntStrut(@osCabec,cAlisCab,aBrows)  
    MntStrut(@osGrd1,cAlisGr1,aGrd1)  
    MntStrut(@osGrd2,cAlisGr2,aGrd2)  
 
    osCabec:AddTable(cAlisCab,, "Concilicao MKT/Cartoes"    ,{|| oCabec:GetRealName()})
    osGrd1:AddTable(cAlisGr1,, "Titulos em Aberto"    ,{|| oGrd1:GetRealName()})
    osGrd2:AddTable(cAlisGr2,, "Recebidos do dia"            ,{|| oGrd2:GetRealName()})    
 
    oModel  :=  FWFormModel():New( 'mdRCKHR01',,,{|oModel| commit()},{|oModel| cancel()})   
 
    osGrd1:AddField( " ", " ", "OK", "L", 1, 0, FwBuildFeature(STRUCT_FEATURE_VALID, "AlwaysTrue()"), FwBuildFeature(STRUCT_FEATURE_WHEN, "AlwaysTrue()"), Nil, .F., Nil, .F., .F., .T.)

    osGrd2:AddField( " ", " ", "OK", "L", 1, 0, FwBuildFeature(STRUCT_FEATURE_VALID, "AlwaysTrue()"), FwBuildFeature(STRUCT_FEATURE_WHEN, "AlwaysTrue()"), Nil, .F., Nil, .F., .F., .T.)

    // LEGENDAS JANELA 2
    //osGrd2:AddField( AllTrim('') , AllTrim('') ,'RC3_LEGEND' ,'C' ,50 , 0 , NIL ,NIL , NIL ,NIL ,{ || Iif( RC3_STATUS == 'B', "BR_VERDE","BR_VERMELHO") } , NIL , NIL ,.T. )

    oModel:AddFields( 'ID_M_FLD', , osCabec,bPre,bPos,bLoad)
    oModel:AddGrid( 'ID_M_GRD1', 'ID_M_FLD', osGrd1, /*bLinePre*/, /*{|oModelZA2| ValLinha(oModelZA2)}*/, /*bPreVal*/,/*{|oModel| ValLinha(oModel)}*/, bLoaGr1/*bLoad1*/)
    oModel:AddGrid( 'ID_M_GRD2', 'ID_M_FLD', osGrd2, /*bLinePre*/, /*{|oModelZA2| ValLinha(oModelZA2)}*/, /*bPreVal*/,/*{|oModel| ValLinha(oModel)}*/, bLoaGr2/* bLoad2*/)
 
    oModel:SetRelation( 'ID_M_GRD1', {{'ID','ID'}}, (cAlisGr1)->(IndexKey(1)))
    oModel:SetRelation( 'ID_M_GRD2', {{'ID','ID'}}, (cAlisGr2)->(IndexKey(1)))
 
    //oModel:GetModel( 'ID_M_GRD1' ):SetUniqueLine( { 'ITEM'} )
    //oModel:GetModel( 'ID_M_GRD2' ):SetUniqueLine( { 'ITEM'} )
    oModel:SetPrimaryKey({ 'ID' })
 
    oModel:AddCalc( 'TOTAL', 'ID_M_FLD', 'ID_M_GRD1',  'ID'    , '_nQtdeOcor', 'COUNT' , ,,'Qtde',/*{ |oModel| AGL300H( oModel)} */  )
    oModel:AddCalc( 'TOTAL2', 'ID_M_FLD', 'ID_M_GRD2', 'ID'    , '_nQtdeOco2', 'COUNT' , ,,'Qtde',/*{ |oModel| AGL300H( oModel)} */  )
    oModel:AddCalc( 'TOTAL', 'ID_M_FLD', 'ID_M_GRD1',  'RC2_VALOR'    , '_nVlrOcor', 'SUM' , ,,'Em aberto',/*{ |oModel| AGL300H( oModel)} */  )
    oModel:AddCalc( 'TOTAL2', 'ID_M_FLD', 'ID_M_GRD2', 'RC3_RECEBI'    , '_nVlrOco2', 'SUM' , ,,'Recebido',/*{ |oModel| AGL300H( oModel)} */  )
    
 
    oModel:SetDescription( 'Concilicao MKT/Cartoes' )
    oModel:GetModel( 'ID_M_GRD1' ):SetDescription( 'Titulos em Aberto' )
    oModel:GetModel( 'ID_M_GRD1' ):SetDescription( 'Recebidos do dia' )
     
Return oModel
 
/*/{Protheus.doc} fieldValidPos
Funcao de validacao pos carregamento dos dados
@type  Function
@author Fabricio Antunes
@since 22/09/2021
/*/
 
Static Function fieldValidPos(oModel)
    Local lRet  :=  .T.
 
    //oModel:GetModel():SetErrorMessage('mdRCKHR01', "RC1_PERIOD" , 'mdRCKHR01' , 'ID' , "ITEM")      
Return lRet
 
/*/{Protheus.doc} validPre
Funcao de validação dos dados de carregamento
@type  Function
@author Fabricio Antunes
@since 22/09/2021
/*/
 
Static Function validPre(oModel, cAction, cIDField, xValue)
    Local lRet  :=  .T.
 
    //oModel:GetModel():SetErrorMessage('mdRCKHR01', "RC1_PERIOD" , 'mdRCKHR01' , 'ID' , "ITEM")
Return lRet
 
/*/{Protheus.doc} loadField
Funcao de carregamento dos dados para o Fields
@type  Function
@author Fabricio Antunes
@since 22/09/2021
/*/
 
Static Function loadField(oModel, lCopy)
    Local aLoad  :=  {}
    Local nI as numeric
    Local aLine as array
    Local xValue as variant
 
    aLine  :=  {}
 
    For nI  :=  1 to Len(aBrows)
        If aBrows[nI][3] == "C"
            xValue  :=  (cAlisCab)->&(aBrows[nI,2])
        Elseif aBrows[nI][3] == "D"
            xValue  :=  (cAlisCab)->&(aBrows[nI,2])
        Elseif aBrows[nI][3] == "N"
            xValue  :=  (cAlisCab)->&(aBrows[nI,2])
        Else
            xValue  :=  .F.
        Endif
 
        aAdd(aLine, xValue)
    Next
     
 
    aAdd(aLoad, aLine) //dados
    aAdd(aLoad, 1) //recno
Return aLoad
 
/*/{Protheus.doc} Commit
Funcao de valicao do comit da tela
@type  Function
@author Fabricio Antunes
@since 22/09/2021
/*/
 
Static Function Commit()
Return .T.
 
/*/{Protheus.doc} Cancel
Funcao de valicao do cancelamento do tela
@type  Function
@author Fabricio Antunes
@since 22/09/2021
/*/
 
Static Function Cancel()
Return .T.
 
/*/{Protheus.doc} ViewDef
Visao de dados MVC para montagem da tela da  tabela temporaria
@type  Function
@author Fabricio Antunes
@since 22/09/2021
/*/
 
Static Function ViewDef()
    Local oModel  :=  FWLoadModel("RCKHR01")
    Local osCabec  :=  FWFormViewStruct():New()
    Local osGrd1  :=  FWFormViewStruct():New()
    Local osGrd2  :=  FWFormViewStruct():New()
    Local oStruTot := FWCalcStruct(oModel:GetModel("TOTAL"))
    Local oStruTot2 := FWCalcStruct(oModel:GetModel("TOTAL2"))
    //Local oStruQtd := FWCalcStruct(oModel:GetModel("QTDE"))
    //Local oStruQtd2 := FWCalcStruct(oModel:GetModel("QTDE2"))
    Local oView  :=  Nil
    Local nX
    Local aDadCab  := {}
    Local aDadGr1  := {}
    Local aDadGr2  := {}
 
    /*----------------------------------------------------------------------
    Estrutura do array para montagem dos campos usados na funcao MntView
        1 - Nome do Campo
        2 - Ordem
        3 - Titulo do campo
        4 - Tipo do campo
        5 - Picture
        6 - Se campo e editavel
    ------------------------------------------------------------------------*/
   
    For nX := 1 to Len(aBrows)
        IF aBrows[nX,3] = "C"
            cPict := "@!"
        ElseIF aBrows[nX,3] = "N"
            cPict := "@E 9,999,999.99"
        Else
            cPict := ""
        EnDIF
        aADD(aDadCab,{aBrows[nX,2],StrZero(nX,2),aBrows[nX,1],aBrows[nX,3],cPict,.F.})
    Next
 
    For nX := 1 to Len(aGrd1)
        IF aGrd1[nX,3] = "C"
            cPict := "@!"
        ElseIF aGrd1[nX,3] = "N"
            cPict := "@E 9,999,999.99"
        Else
            cPict := ""
        EnDIF
        aADD(aDadGr1,{aGrd1[nX,2],StrZero(nX,2),aGrd1[nX,1],aGrd1[nX,3],cPict,.F.})
    Next
 
    For nX := 1 to Len(aGrd2)
         IF aGrd2[nX,3] = "C"
            IF aGrd2[nX,2] == "RC3_LEGEND"
                cPict := "@BMP"
            ELSE
             cPict := "@!"
            ENDIF
         ElseIF aGrd2[nX,3] = "N"
             cPict := "@E 9,999,999.99"
         Else
             cPict := ""
         EnDIF
        aADD(aDadGr2,{aGrd2[nX,2],StrZero(nX,2),aGrd2[nX,1],aGrd2[nX,3],cPict,.F.})
    Next
 
    MntView(@osCabec,aDadCab)
    MntView(@osGrd1,aDadGr1)
    MntView(@osGrd2,aDadGr2)
 
    oView  :=  FWFormView():New()
    oView:SetModel(oModel)
 
    oView:AddField("ID_V_FLD", osCabec, "ID_M_FLD")
    oView:AddGrid("ID_V_GRD1", osGrd1, "ID_M_GRD1")
    oView:AddGrid("ID_V_GRD2", osGrd2, "ID_M_GRD2")
    oView:AddField("VIEW_TOT", oStruTot, "TOTAL")
    oView:AddField("VIEW_TOT2", oStruTot2, "TOTAL2")
    //oView:AddField("VIEW_QTDE", oStruQtd, "QTDE")
    //oView:AddField("VIEW_QTDE2", oStruQtd2, "QTDE2")
    oView:AddOtherObject('ID_V_FLD',{|oPanel|fBtConc(oPanel)})    

    osGrd1:AddField("OK","01","Ok","Ok", Nil,"L","",Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
    osGrd2:AddField("OK","01","Ok","Ok", Nil,"L","",Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)

    //LEGENDAS JANELA 2
    //osGrd2:AddField('RC3_LEGEND', "00",AllTrim(''), AllTrim(''),, 'C','@BMP',NIL,'', .T., NIL,NIL, NIL, NIL, NIL, .T., NIL,NIL)

 
    oView:CreateHorizontalBox("SUPERIOR",20)
    oView:CreateHorizontalBox("INFERIOR",70)
    oView:CreateVerticalBox('ESQUERDA', 45 , 'INFERIOR')
    oView:CreateVerticalBox("DIREITA",  55 , 'INFERIOR')
    oView:CreateHorizontalBox("RODAPE",10)
    oView:CreateVerticalBox('ENCH_TOT', 45 , 'RODAPE')
    oView:CreateVerticalBox("ENCH_TOT2",  55 , 'RODAPE')

     
    oView:SetOwnerView( 'ID_V_FLD'   , 'SUPERIOR' )
    oView:SetOwnerView( 'ID_V_GRD1'   , 'ESQUERDA' )
    oView:SetOwnerView( 'ID_V_GRD2'   , 'DIREITA' )
    oView:SetOwnerView( 'VIEW_TOT'   , 'ENCH_TOT' )
    oView:SetOwnerView( 'VIEW_TOT2'   , 'ENCH_TOT2' )
    //oView:SetOwnerView( 'VIEW_QTDE'   , 'ENCH_TOT' )
    //oView:SetOwnerView( 'VIEW_QTDE2'   , 'ENCH_TOT2' )
    //oView:SetOwnerView( 'VIEW_RODAPE'  , 'RODAPE')


 
 
    //Colocando título do formulário
    oView:EnableTitleView('ID_V_FLD', 'Concilicao MKT/Cartoes' )  
    oView:EnableTitleView('ID_V_GRD1', 'Titulos em Aberto' )  
    oView:EnableTitleView('ID_V_GRD2', 'Recebidos do dia' )       
    oView:EnableTitleView('VIEW_TOT', 'Totalizador' )    
    oView:EnableTitleView('VIEW_TOT2', 'Totalizador2' )    
    oView:SetCloseOnOk({||.T.})
Return oView
 
/*/{Protheus.doc} gerCpBrow
Funcao para montar array com colunas para browse
@type  Function
@author Fabricio Antunes
@since 22/09/2021
/*/
 
Static Function gerCpBrow(aCampos,aTitulos)
    Local nX
    Local aBrows := {}
 
    For nX := 1 to Len(aCampos)
        aAdd(aBrows,{aTitulos[nX], aCampos[nX,1] ,aCampos[nX,2] ,aCampos[nX,3] ,aCampos[nX,4]})
    Next
Return aBrows
 
/*/{Protheus.doc} MntStrut
Funcao para montar estrutura de dados para ModelDef
@type  Function
@author Fabricio Antunes
@since 22/09/2021
/*/
 
Static Function MntStrut(oObj,cAlias, aCampos)
    Local nX
    Default aCampos := {}
 
    For nX := 1 to Len(aCampos)
        oObj:AddField(;
            aCampos[nX,1],;                                                                                  // [01]  C   Titulo do campo
            aCampos[nX,1],;                                                                                  // [02]  C   ToolTip do campo
            aCampos[nX,2],;                                                                                  // [03]  C   Id do Field
            aCampos[nX,3],;                                                                                  // [04]  C   Tipo do campo
            aCampos[nX,4],;                                                                                  // [05]  N   Tamanho do campo
            aCampos[nX,5],;                                                                                  // [06]  N   Decimal do campo
            Nil,;                                                                                            // [07]  B   Code-block de validação do campo
            Nil,;                                                                                            // [08]  B   Code-block de validação When do campo
            {},;                                                                                             // [09]  A   Lista de valores permitido do campo
            .F.,;                                                                                            // [10]  L   Indica se o campo tem preenchimento obrigatório
            FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,('"+cAlias+"')->"+aCampos[nX,2]+",'')" ),;   // [11]  B   Code-block de inicializacao do campo
            .T.,;                                                                                            // [12]  L   Indica se trata-se de um campo chave
            aCampos[nX,6],;                                                                                  // [13]  L   Indica se o campo pode receber valor em uma operação de update.
            .F.;                                                                                             // [14]  L   Indica se o campo é virtual
        )
 
        IF aCampos[nX,6]
            oObj:SetProperty(aCampos[nX,2], MODEL_FIELD_WHEN, { || .T.})
            oObj:SetProperty(aCampos[nX,2], MODEL_FIELD_NOUPD,.F.)
        EndIF
    Next
Return
 
/*/{Protheus.doc} MntView
Funcao para montar estrutura de dados para ViewDef
@type  Function
@author Fabricio Antunes
@since 22/09/2021
/*/
 
Static Function MntView(oObj,aCampos)
    Local nX
 
    For nX := 1 to Len(aCampos)
        //Adicionando campos da estrutura
        oObj:AddField(;
            aCampos[nX,1],;                  // [01]  C   Nome do Campo
            aCampos[nX,2],;                  // [02]  C   Ordem
            aCampos[nX,3],;                  // [03]  C   Titulo do campo
            aCampos[nX,3],;                  // [04]  C   Descricao do campo
            Nil,;                            // [05]  A   Array com Help
            aCampos[nX,4],;                  // [06]  C   Tipo do campo
            aCampos[nX,5],;                  // [07]  C   Picture
            Nil,;                            // [08]  B   Bloco de PictTre Var
            Nil,;                            // [09]  C   Consulta F3
            aCampos[nX,6],;                  // [10]  L   Indica se o campo é alteravel
            Nil,;                            // [11]  C   Pasta do campo
            Nil,;                            // [12]  C   Agrupamento do campo
            Nil,;                            // [13]  A   Lista de valores permitido do campo (Combo)
            Nil,;                            // [14]  N   Tamanho maximo da maior opção do combo
            Nil,;                            // [15]  C   Inicializador de Browse
            Nil,;                            // [16]  L   Indica se o campo é virtual
            Nil,;                            // [17]  C   Picture Variavel
            Nil;                             // [18]  L   Indica pulo de linha após o campo
        )
    Next
 
Return
 
/*/{Protheus.doc} GrvFin
Funcao que ira criar e popular a tabela temporaria
@type  Function
@author Fabricio Antunes
@since 22/09/2021
/*/
 
Static function GrvFin()
    Local aArea := FWGetArea()

    //IF(Select(cAlisCab) > 0)
      //  (cAlisCab)->(DbCloseArea())
    //Endif

    IF(Select( "TEMPKHR1") > 0)
        TEMPKHR1->(DbCloseArea())
    Endif
   	
    cQuery1 := "SELECT RC1_TIPO, TAB.RC1_PERIOD, RC1_TOTAL, RC1_CONC, RC1_PEND, RC1_MOVIM FROM ( "
    cQuery1 += "SELECT 'REDECARD' RC1_TIPO, E1_VENCREA RC1_PERIOD, SUM(E1_VALOR) RC1_TOTAL,  SUM(E1_VALOR - E1_SALDO) RC1_CONC, SUM(E1_SALDO) RC1_PEND "
	cQuery1 += "FROM "+RetSQLName("SE1")+" SE1 " 
	cQuery1 += "WHERE SE1.D_E_L_E_T_ = ' ' " 
	cQuery1 += "AND E1_TIPO IN ('MAQ','CC','CD') " 
    cQuery1 += "AND E1_VENCREA >= '"+DTOS(MV_PAR01)+"' AND E1_VENCREA <= '"+DTOS(MV_PAR02)+"' AND E1_NOMCLI = 'REDECARD' AND E1_FILORIG IN "+cfilqry+" "
    cQuery1 += "GROUP BY E1_VENCREA) TAB " 
    cQuery1 += "INNER JOIN (SELECT 'REDECARD', E5_DATA RC1_PERIOD, SUM(E5_VALOR) RC1_MOVIM from "+RetSQLName("SE5")+" WHERE E5_HISTOR LIKE 'BX. AUTO ARQUIVO%' "
	cQuery1 += "AND E5_NATUREZ = 'CARTAO' AND E5_DATA >= '20240101' AND D_E_L_E_T_ <> '*'  AND E5_MOEDA = 'M1' "
    cQuery1 += "GROUP BY E5_DATA) TAB2 on TAB2.RC1_PERIOD = TAB.RC1_PERIOD " 
    cQuery1 += "ORDER BY TAB.RC1_PERIOD "

	TCQuery cQuery1 NEW ALIAS "TEMPKHR1"	

	WHILE !TEMPKHR1->(Eof())
		RECLOCK((cAlisCab),.T.)
        (cAlisCab)->ID := TEMPKHR1->RC1_PERIOD
		(cAlisCab)->RC1_TIPO := TEMPKHR1->RC1_TIPO
		(cAlisCab)->RC1_PERIOD := STOD(TEMPKHR1->RC1_PERIOD)
		(cAlisCab)->RC1_TOTAL := ROUND(TEMPKHR1->RC1_TOTAL,2)
		(cAlisCab)->RC1_CONC := ROUND(TEMPKHR1->RC1_CONC,2)
		(cAlisCab)->RC1_PEND := ROUND(TEMPKHR1->RC1_PEND,2)
		(cAlisCab)->RC1_MOVIM := ROUND(TEMPKHR1->RC1_MOVIM,2)
		MSUNLOCK()
		TEMPKHR1->(DbSkip())
	ENDDO



    //IF(Select(cAlisGr1) > 0)
        //(cAlisGr1)->(DbCloseArea())
    //Endif

    IF(Select( "TEMPKHR2") > 0)
        TEMPKHR2->(DbCloseArea())
    Endif

    cQuery2 := "SELECT E1_FILORIG FILIAL, E1_NUM RC2_NUM,E1_TIPO RC2_TIPO,E1_VALOR RC2_VALOR,E1_TXMOEDA RC2_TAXA, E1_EMIS1 RC2_EMISSA, E1_PARCELA RC2_PARCEL, E1_VENCREA RC2_VENC "
    cQuery2 += "FROM "+RetSQLName("SE1")+" " 
    cQuery2 += "WHERE E1_VENCREA >= '"+DTOS(MV_PAR01)+"' AND E1_VENCREA <= '"+DTOS(MV_PAR02)+"' AND E1_NOMCLI = 'REDECARD' "
    cQuery2 += "AND E1_TIPO IN ('MAQ','CC','CD') " 
    cQuery2 += "AND E1_NOMCLI = 'REDECARD' AND E1_SALDO > 0 "    
    cQuery2 += "AND D_E_L_E_T_ <> '*' AND E1_FILORIG IN "+cfilqry+ " " 
    cQuery2 += "ORDER BY E1_NUM "

    TCQuery cQuery2 NEW ALIAS "TEMPKHR2"	

    
    Dbselectarea("TEMPKHR2")

    WHILE !TEMPKHR2->(Eof())
        RECLOCK((cAlisGr1),.T.)
        (cAlisGr1)->ID := TEMPKHR2->RC2_VENC
        (cAlisGr1)->RC2_FILIAL := TEMPKHR2->FILIAL
        (cAlisGr1)->RC2_NUM := TEMPKHR2->RC2_NUM
        (cAlisGr1)->RC2_TIPO := TEMPKHR2->RC2_TIPO
        (cAlisGr1)->RC2_VALOR := TEMPKHR2->RC2_VALOR
        (cAlisGr1)->RC2_TAXA := TEMPKHR2->RC2_TAXA
        (cAlisGr1)->RC2_EMISSA := STOD(TEMPKHR2->RC2_EMISSA)
        (cAlisGr1)->RC2_PARCEL := TEMPKHR2->RC2_PARCEL
        (cAlisGr1)->RC2_VENC := STOD(TEMPKHR2->RC2_VENC)
        MSUNLOCK()
        TEMPKHR2->(DbSkip())
    ENDDO


    IF(Select( "TEMPKHR3") > 0)
        TEMPKHR3->(DbCloseArea())
    Endif


    cQuery3 := "SELECT ZR1_FILIAL FILIAL, ZR1_DOCTEF DOCTEF, ZR1_PREFIX PREFIX, ZR1_NUM NUM, ZR1_PARCEL PARCEL, ZR1_TIPO TIPO, ZR1_STATUS STATUS, ZR1_RECEBI RECEBI, ZR1_DATA DTRECEB, ZR1_IMPORT IMPORT FROM "+RetSQLName("ZR1")+" ZR1 WHERE ZR1.D_E_L_E_T_ <> '*' AND ZR1_FILIAL IN "+cfilqry+ " "

    TCQuery cQuery3 NEW ALIAS "TEMPKHR3"	

    
    Dbselectarea("TEMPKHR3")

    WHILE !TEMPKHR3->(Eof())
        RECLOCK((cAlisGr2),.T.)
        (cAlisGr2)->ID := TEMPKHR3->DTRECEB
        (cAlisGr2)->RC3_FILIAL := TEMPKHR3->FILIAL
        (cAlisGr2)->RC3_DOCTEF := TEMPKHR3->DOCTEF
        (cAlisGr2)->RC3_PREFIX := TEMPKHR3->PREFIX
        (cAlisGr2)->RC3_NUM := TEMPKHR3->NUM
        (cAlisGr2)->RC3_PARCEL := TEMPKHR3->PARCEL
        (cAlisGr2)->RC3_TIPO := TEMPKHR3->TIPO
        (cAlisGr2)->RC3_STATUS := TEMPKHR3->STATUS
        (cAlisGr2)->RC3_RECEBI := TEMPKHR3->RECEBI
        (cAlisGr2)->RC3_DATA := STOD(TEMPKHR3->DTRECEB)
        (cAlisGr2)->RC3_IMPORT := TEMPKHR3->IMPORT
        (cAlisGr2)->RC3_LEGEND := "BR_VERDE"
        MSUNLOCK()
        TEMPKHR3->(DbSkip())
    ENDDO





    /*Local aCampos  :=  {}
    Local _oFINR5501
    Private cSE5KeyAnt     :=  ""
 
    aAdd(aCampos,{"CODIGO" ,"C",aTam[1],aTam[2]})
    aAdd(aCampos,{"SALDOA"  ,"N",18,2})
    aAdd(aCampos,{"VALORD"  ,"N",18,2})
    aAdd(aCampos,{"VALORC"  ,"N",18,2})
 
    _oFINR5501  :=  FWTemporaryTable():New( "cNomeArq" )
    _oFINR5501:SetFields(aCampos)
    _oFINR5501:AddIndex("1", {"CODIGO"})
    //------------------
    //Criação da tabela temporaria
    //------------------
    _oFINR5501:Create()
 
    //------------------
    //Localiza e grava titulos a receber dentro dos parametros
    //------------------
 
    cQuery  :=  "SELECT * FROM " + RetSqlName("SE2") + " E2  WHERE"
    cQuery += " E2.D_E_L_E_T_ <> '*' AND rownum <= 100"
 
    dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TRBSE2', .F., .T.)
    dbselectarea("TRBSE2")
    While !TRBSE2->(Eof())
 


        //------------------
        //Le registros com data anterior a data inicial (para compor
        //os saldos anteriores) ate a data final.
        //------------------
 
        If TRBSE2->E2_TIPO $ MVABATIM
            dbSelectArea("TRBSE2")
            TRBSE2->(dbSkip( ))
            Loop
        Endif
 
 
        //------------------
        //Grava debito no arquivo de trabalho
        //------------------
        _dEmissao  :=  stod(TRBSE2->E2_EMIS1)
        aMOVI  :=  {10,20,30}
 
        If( cNomeArq->(dbseek(TRBSE2->E2_FORNECE)))
            Reclock( "cNomeArq", .F. )
            cNomeArq->SALDOA   += aMOVI[1]
            cNomeArq->VALORD   += aMOVI[2]
            cNomeArq->VALORC   += aMOVI[3]
            cNomeArq->( MsUnlock() )
 
        Else
            Reclock( "cNomeArq", .T. )
            cNomeArq->CODIGO   :=  TRBSE2->E2_FORNECE
            cNomeArq->SALDOA    :=  aMOVI[1]
            cNomeArq->VALORD    :=  aMOVI[2]
            cNomeArq->VALORC    :=  aMOVI[3]
            cNomeArq->( MsUnlock() )
        Endif
 
 
        dbSelectArea("TRBSE2")
        TRBSE2->(dbSkip())
 
    Enddo
 
    dbselectarea("cNomeArq")
    cNomeArq->(dbgotop())
    cCodigo         :=  ""
    nSaldoAtu     :=  0
    nTotDeb         :=  0
    nTotCrd         :=  0
 
    While cNomeArq->(!Eof())
 
        cCodigo         :=  cNomeArq->CODIGO
        cLoja  :=  ""
        nSaldoAtu     :=  0
        nTotDeb         :=  0
        nTotCrd         :=  0
        lNoSkip  :=  .f.
        nSaldoAtu    += cNomeArq->SALDOA
        nTotDeb   += ABS(cNomeArq->VALORD)
        nTotCrd   += ABS(cNomeArq->VALORC)
 
        cNomeArq->(dbSkip())
        //cAlisCab := oGrd1:GetRealName()
 
        If cNomeArq->(Eof()) .or. cNomeArq->CODIGO <> cCodigo
            //------------------
            //Grava debito no arquivo de trabalho
            //------------------
            dbSelectArea(cAlisCab)
            (cAlisCab)->(dbSetOrder(2))
            Reclock((cAlisCab),.t.)
            Replace ID          With cCodigo
            Replace ITEM_TAB      With cCodigo
            IF SA1->(dbseek(xfilial("SA1")+cCodigo))
                Replace DESC_ITEM      With SA1->A1_NOME
            ElseIf SA2->(dbseek(xfilial("SA2")+cCodigo))
                Replace DESC_ITEM      With SA2->A2_NOME
            Endif
            Replace FIN_SLA  With nSaldoAtu
            Replace FIN_DEB  With nTotDeb
            Replace FIN_CRE  With nTotCrd
            Replace FIN_SLF  With FIN_SLA + FIN_DEB - FIN_CRE
            MsUnlock()
 
////grid 1
            dbSelectArea(cAlisGr1)
            (cAlisGr1)->(dbSetOrder(2))
            Reclock((cAlisGr1),.t.)
            Replace ID          With cCodigo
            Replace ITEM      With cCodigo
            Replace FIN_DEB  With nTotDeb
            MsUnlock()
///grid 2
 
            // dbSelectArea(cAlisGr2)
            // (cAlisGr2)->(dbSetOrder(2))
            // Reclock((cAlisGr2),.t.)
            // Replace ID          With cCodigo
            // Replace ITEM     With cCodigo
            // Replace FIN_DEB  With nTotDeb
            // MsUnlock()
        Endif
    EndDo*/
     
    FWRestArea(aArea)
Return
 
/*/{Protheus.doc} loadGrd
Função responsável pela carga dos modelos em MVC
@type  Function
@author Fabricio Antunes
@since 22/09/2021
/*/
 
Static Function loadGrd(oSub,lCopy,cIdSub)
    Local cAliasTab     :=  ""
    Local nI         :=  0
    Local nRec         := 1
    Local aFldSub     :=  {}
    Local aRet          :=  {}
    Local aAux         :=  {}
 
    aFldSub  :=  oSub:GetStruct():GetFields()
 
    If ( cIdSub == "GR1" ) 
        cAliasTab  :=  oGrd1:GetAlias()
    ElseIf ( cIdSub == "GR2" )
        cAliasTab  :=  oGrd2:GetAlias()
    EndIf
 
    (cAliasTab)->(dbSetOrder(1))
    (cAliasTab)->(dbGoTop())
    IF (cAliasTab)->(dbSeek((cAlisCab)->ID))
        While !(cAliasTab)->(Eof()) .AND. (cAliasTab)->ID = (cAlisCab)->ID
                     
            For nI  :=  1 to Len(aFldSub)
 
                If ( (cAliasTab)->(FieldPos(aFldSub[nI,3])) > 0 )
                    aAdd(aAux,(cAliasTab)->&(aFldSub[nI,3]))
                Else
                    aAdd(aAux,GTPCastType(,aFldSub[nI,4]))
                EndIf
 
            Next nI
             
            aAdd(aRet,{nRec,aClone(aAux)})
            aAux  :=  {}
            nRec++
             
            (cAliasTab)->(DbSkip())
             
        EndDo
    EndIF
Return(aRet)

STATIC FUNCTION fBtConc(oPanel)

	Local aArea := FWGetArea()
	Local nJanLarg := oPanel:nWidth
	Local nLinObj := 0
	Local nLargBtn := 100
	Local cFontPad := "Tahoma"
	Local cFontBtn := TFont():New(cFontPad, , 2)

	oBtnConc := TButton():New(007,180 , "Conciliar", oPanel, {|| U_Conciliar()},nLargBtn)
	//oBtnAb := TButton():New(001,20 , "Em Aberto", oPanel, ,nLargBtn)
	//oBtnRec := TButton():New(001,190 , "Recebidos", oPanel, ,nLargBtn)

RETURN

USER FUNCTION Conciliar()

RETURN
