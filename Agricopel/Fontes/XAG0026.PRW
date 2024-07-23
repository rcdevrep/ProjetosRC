#Include 'Protheus.ch'
#Include 'Report.ch'

/*
Programa.: XAG0026
Autor....: Emerson - Sla
Data.....: 10/04/2018
Descricao: Relatorio especifico de Controle de Comissão Sobre a Margem
Uso......: Agricopel
*/

User Function XAG0026()
Local oReport
Private cAliasQry := GetNextAlias()
Private cAlias    := cAliasQry
Private cPerg  := "XAG0025"
pergunte(cPerg,.t.)
//-- Interface de impressao
oReport := ReportDef()
oReport:PrintDialog()  
Return


Static Function ReportDef()

Local cTitulo := "Relatório Comissão Agricopel "
Local cDescri := "Este Relatório imprime o Calculo da Comissão Agricopel."

Local oReport
Local oComissaoA
Local oComissaoS
Local oDetalhe
Local oTotal,oGeral
Local cVend  		:= ""      
Local NDIFCST :=0     
Local nAc1			:= 0
Local nAc2			:= 0
Local nAc3      	:= 0
Local nAc4      	:= 0
Local nAc5      	:= 0
Local oBreakP
Local oBreakV

oReport := TReport():New("XAG0026",cTITULO,cPerg, {|oReport| ReportPrint(oReport,cAliasQry,oComissaoA,oComissaoS,oDetalhe,oTotal,oGeral)},"Emissão Do Relatório De Comissões Agricopel.")
oReport:lParamPage := .T.   //Exibe parâmetros para impressão.
oReport:SetLandscape() 
oReport:SetTotalInLine(.T.)

oComissaoA := TRSection():New(oReport,'Comissão Agricopel',{"SE3","SA3"},{'',''},/*Campos do SX3*/,/*Campos do SIX*/)
oComissaoA:SetTotalInLine(.T.)
oComissaoA:SetHeaderBreak(.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analitico                                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRCell():New(oComissaoA,"E3_VEND" ,"SE3",/*Titulo*/,/*Picture*/                ,/*Tamanho*/         ,/*lPixel*/  ,{|| cVend })
TRCell():New(oComissaoA,"A3_NOME" ,"SA3",/*Titulo*/,/*Picture*/                ,/*Tamanho*/         ,/*lPixel*/  ,{|| SA3->A3_NOME })
TRCell():New(oComissaoA,"A3_SALBASE" ,"SA3",/*Titulo*/,/*Picture*/                ,/*Tamanho*/         ,/*lPixel*/  ,{|| SA3->A3_SALBASE})
TRCell():New(oComissaoA,"A3_COMISLT" ,"SA3",/*Titulo*/,/*Picture*/                ,/*Tamanho*/         ,/*lPixel*/  ,{|| SA3->A3_COMISLT})

oDetalhe := TRSection():New(oComissaoA,"Comissões (analítico)",{"SE3","SA3","SA1"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
oDetalhe:SetTotalInLine(.T.)
oDetalhe:SetHeaderBreak(.T.)                                                   	

TRCell():New(oDetalhe,"E3_PREFIXO" 	,cAlias,"Tipo",/*Picture*/               ,/*Tamanho*/  ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDetalhe,"E3_NUM"		,cAlias,"Nota",/*Picture*/               ,/*Tamanho*/  ,/*lPixel*/,{|| E3_NUM })
TRCell():New(oDetalhe,"E3_PARCELA" 	,cAlias,"Item",/*Picture*/               ,/*Tamanho*/  ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDetalhe,"E3_EMISSAO"	,cAlias,/*Titulo*/,/*Picture*/               ,/*Tamanho*/  ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDetalhe,"E3_CODCLI"	,cAlias,/*Titulo*/,/*Picture*/               ,/*Tamanho*/  ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDetalhe,"A1_NREDUZ"	,cAlias,/*Titulo*/,/*Picture*/               ,30			,/*lPixel*/,{|| Substr(SA1->A1_NREDUZ,1,30) })
TRCell():New(oDetalhe,"E3_XCODPRO"	,cAlias,/*Titulo*/,/*Picture*/               ,/*Tamanho*/  ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDetalhe,"B1_DESC"	,cAlias,/*Titulo*/,/*Picture*/               ,30			,/*lPixel*/,{|| Substr(SB1->B1_DESC,1,30) })
TRCell():New(oDetalhe,"E3_BASE"	    ,cAlias,"Quantidade",/*Picture*/               ,/*Tamanho*/  ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDetalhe,"E3_XVLRCOM"	    ,cAlias,"VlrBase ",/*Picture*/               ,/*Tamanho*/  ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDetalhe,"E3_COMIS"	   ,cAlias,/*Titulo*/,/*Picture*/               ,/*Tamanho*/  ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDetalhe,"E3_XVALNFS"	    ,cAlias,"Valor NFS",/*Picture*/               ,/*Tamanho*/  ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDetalhe,"E3_XCSTNFS"   ,cAlias,"Valor CST",/*Picture*/               ,/*Tamanho*/  ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDetalhe,"E3_COMISS"	   ,cAlias,"Diferença",/*Picture*/               ,/*Tamanho*/  ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDetalhe,"E3_VEND" ,"SE3",/*Titulo*/,/*Picture*/                ,/*Tamanho*/         ,/*lPixel*/  ,{|| cVend })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sintetico                                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oComissaoS := TRSection():New(oReport,cTITULO,{"SE3","SA3"},{"",""},/*Campos do SX3*/,/*Campos do SIX*/)
oComissaoS:SetTotalInLine(.F.)

TRCell():New(oComissaoS,"E3_VEND" ,"SE3",/*Titulo*/,/*Picture*/                	,/*Tamanho*/          	,/*lPixel*/	,{|| cVend })
TRCell():New(oComissaoS,"A3_NOME" ,"SA3",/*Titulo*/,/*Picture*/					,/*Tamanho*/          	,/*lPixel*/	,{|| SA3->A3_NOME })
TRCell():New(oComissaoS,"TOTQTDE","", "Qtde Litros  " ,PesqPict('SE3','E3_BASE') 	 ,20 ,/*lPixel*/	,{|| nAc1 })
TRCell():New(oComissaoS,"A3_SALBASE","SA3","Salario Fixo " ,PesqPict('SE3','E3_BASE')  ,TamSx3("E3_BASE")[1] 	,/*lPixel*/	,{||nAc5})
TRCell():New(oComissaoS,"TOTVLTS","","Valor Litros " ,PesqPict('SE3','E3_BASE') 	 ,TamSx3("E3_BASE")[1] 	,/*lPixel*/	,{|| nAc2 })
TRCell():New(oComissaoS,"TOTVMRG","","Valor Margem " ,PesqPict('SE3','E3_BASE') 	 ,TamSx3("E3_BASE")[1] 	,/*lPixel*/	,{|| nAc3 })
TRCell():New(oComissaoS,"TOTVCOM","","Total Comissão" ,PesqPict('SE3','E3_BASE') ,TamSx3("E3_BASE")[1] 	,/*lPixel*/	,{|| nAc4 })

//-- TOTAL GERAL
oTotal := TRSection():New(oReport,"",{},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
TRCell():New(oTotal,"TOTVEND",""	,"total Margem" ,PesqPict('SE3','E3_COMISS') 	,TamSx3("E3_COMISS")[1] 	,/*lPixel*/	,{|| nAc4 })

oGeral := TRSection():New(oTotal,"",{},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
TRCell():New(oGeral, "TXTTOTAL"          , "" , "TOTAL"  , , 08 ,/*lPixel*/,{ || "" } )    
TRCell():New(oGeral, "GERAL"	         , "" , "GERAL"  , PesqPict('SE3','E3_COMISS')    	, TamSX3("E3_COMISS")[1]   ,/*lPixel*/,/*CodeBlock*/)
TRCell():New(oGeral, "COMIS"		     , "" , "COMIS" , PesqPict('SE3','E3_COMISS')    	, TamSX3("E3_COMISS")[1]   ,/*lPixel*/,/*CodeBlock*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao do Cabecalho no topo da pagina                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:Section(1):SetHeaderPage()
oReport:Section(2):SetHeaderPage()
oReport:Section(1):Setedit(.T.)
oReport:Section(1):Section(1):Setedit(.T.)
//Report:Section(1):Section(1):Section(1):Setedit(.T.)
oReport:Section(2):Setedit(.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alinhamento a direita dos campos de valores                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Analitico
oDetalhe:Cell("E3_BASE"):SetHeaderAlign("RIGHT")
oDetalhe:Cell("E3_XVLRCOM"):SetHeaderAlign("RIGHT")
oDetalhe:Cell("E3_COMIS"):SetHeaderAlign("RIGHT")
oDetalhe:Cell("E3_COMISS"):SetHeaderAlign("RIGHT")
oDetalhe:Cell("E3_XVALNFS"):SetHeaderAlign("RIGHT")
oDetalhe:Cell("E3_XCSTNFS"):SetHeaderAlign("RIGHT")


//Sintetico
oComissaoS:Cell("TOTQTDE"):SetHeaderAlign("RIGHT")
oComissaoS:Cell("A3_SALBASE"):SetHeaderAlign("RIGHT")
oComissaoS:Cell("TOTVLTS"):SetHeaderAlign("RIGHT")
oComissaoS:Cell("TOTVMRG"):SetHeaderAlign("RIGHT")
oComissaoS:Cell("TOTVCOM"):SetHeaderAlign("RIGHT")
Return(oReport)
Return


Static Function ReportPrint(oReport,cAliasQry,oComissaoA,oComissaoS,oDetalhe,oTotal,oGeral)

Local cTitFun	 := ""
Local dEmissao := CTOD( "" ) 
Local nTotLiq  := 0
Local aLiquid  := {}
Local ny 
Local cWhere   := ""
Local cNomArq, cFilialSE1, cFilialSE3
Local nI       := 0
Local cOrder   := ""
Local nDecs
Local nTotPorc	:= 0
Local nTotPerVen	:= 0
Local nTotPerGer	:= 0
Local nTaxa	:= 0

Local cDocLiq   := ""            
Local cTitulo   := ""                                     
Local cAjuste   := ""
Local nTotBase	:= 0
Local nTotComis	:= 0
Local nSection	:= 0
Local nOrdem	:= 1
Local nTGerBas  := 0
Local nTGerCom  := 0
Local lVend	    := .F.
Local lFirst    := .F.
nAc1		:= 0
nAc2		:= 0
nAc3		:= 0
nAc4		:= 0
nAc5		:= 0
cVend		:= ""

PERGUNTE(cPerg,.F.)

IF MV_PAR07 == 1 //ANALATICO
   
	oReport:Section(2):Disable()
	nSection := 1   
	oReport:Section(1):Cell("E3_VEND"):SetBlock({|| cVend })	
	oReport:Section(1):Section(1):Cell("E3_VEND"):SetBlock({|| cVend })
	oReport:Section(1):section(1):Cell("E3_VEND"):Disable()
	
		cVend		:= ""
    	oBreakP := TRBreak():New(oDetalhe,oDetalhe:Cell("E3_PREFIXO"),"Total Tipo -> ") // "Total por Função" 
 //		oBreakP:OnBreak({|x,y|cTitFun}) 
//    	oBreakP:SetTotalText({||cTitFun})
	                                                             
		TRFunction():New(oDetalhe:Cell("E3_BASE"),/*cId*/,"SUM",oBreakP,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
		TRFunction():New(oDetalhe:Cell("E3_COMIS"),/*cId*/,"SUM",oBreakP,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
		TRFunction():New(oDetalhe:Cell("E3_XVALNFS"),/*cId*/,"SUM",oBreakP,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
		TRFunction():New(oDetalhe:Cell("E3_XCSTNFS"),/*cId*/,"SUM",oBreakP,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
		TRFunction():New(oDetalhe:Cell("E3_COMISS"),/*cId*/,"SUM",oBreakP,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)

		
    	oBreakV := TRBreak():New(oDetalhe,oDetalhe:Cell("E3_VEND"),"total ") // "Total por Função" 
		oBreakV:OnBreak({|x,y|cVend}) 
    	oBreakV:SetTotalText({||"Total Vendedor ->"+cVend})
	                                                             
		TRFunction():New(oDetalhe:Cell("E3_BASE"),/*cId*/,"SUM",oBreakV,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
		TRFunction():New(oDetalhe:Cell("E3_COMIS"),/*cId*/,"SUM",oBreakV,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
		TRFunction():New(oDetalhe:Cell("E3_XVALNFS"),/*cId*/,"SUM",oBreakV,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
		TRFunction():New(oDetalhe:Cell("E3_XCSTNFS"),/*cId*/,"SUM",oBreakV,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
		TRFunction():New(oDetalhe:Cell("E3_COMISS"),/*cId*/,"SUM",oBreakV,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
		
Else				// Sintetico

	TRFunction():New(oComissaoS:Cell("TOTQTDE"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oComissaoS:Cell("A3_SALBASE"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oComissaoS:Cell("TOTVLTS"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oComissaoS:Cell("TOTVMRG"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,PesqPict('SE3','E3_COMISS'),/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oComissaoS:Cell("TOTVCOM"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)
              
	oReport:Section(1):Disable()
	oReport:Section(1):Section(1):Disable()
	nSection := 2
	
	oReport:Section(2):Cell("E3_VEND"):SetBlock({|| cVend })		
	oReport:Section(2):Cell("TOTQTDE"):SetBlock({|| nAc1 })		
	oReport:Section(2):Cell("A3_SALBASE"):SetBlock({|| nAc5 })		
	oReport:Section(2):Cell("TOTVLTS"):SetBlock({|| nAc2 })		
	oReport:Section(2):Cell("TOTVMRG"):SetBlock({|| nAc3 })		
	oReport:Section(2):Cell("TOTVCOM"):SetBlock({|| nAc4 })		

	cVend		:= ""
	nAc1		:= 0
	nAc2		:= 0
	nAc3		:= 0
	nAc4		:= 0
	nAc5		:= 0
EndIf
dbSelectArea("SE3")
dbSetOrder(2)   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatório da secao 1                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Transforma parametros Range em expressao SQL                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeSqlExpr(oReport:uParam)	
oReport:Section(nSection):BeginQuery()
cWhere :=''             
cOrder := "%E3_FILIAL,E3_VEND,E3_PREFIXO,E3_NUM,E3_PARCELA%"

BEGIN REPORT QUERY oDetalhe
	BeginSql Alias cAliasQry
	SELECT  E3_XVLRCOM,A3_SALBASE,E3_XCSTNFS,E3_XCODPRO,E3_XVALNFS,E3_FILIAL,E3_BASE, E3_COMISS,E3_COMIS, E3_VEND, E3_PORC, A3_NOME, E3_PREFIXO,E3_NUM, E3_PARCELA,E3_TIPO,E3_CODCLI,E3_LOJA,E3_AJUSTE,E3_BAIEMI,E3_EMISSAO,E3_DATA, E3_PEDIDO
		FROM %table:SE3% SE3
		LEFT JOIN %table:SA3% SA3
	        ON A3_COD = E3_VEND
			WHERE A3_FILIAL = E3_FILIAL 
			AND SE3.E3_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
			AND SE3.E3_VEND BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
			AND	E3_EMISSAO >= %Exp:Dtos(mv_par03)%
			AND E3_EMISSAO <= %Exp:Dtos(mv_par04)%
			AND SA3.%NotDel%
			AND SE3.%notdel%
	ORDER BY %Exp:cOrder%
	EndSql
END REPORT QUERY oDetalhe 

//³Metodo EndQuery ( Classe TRSection )                                    ³
//³                                                                        ³
//³Prepara o relatório para executar o Embedded SQL.                       ³
//³                                                                        ³
//³ExpA1 : Array com os parametros do tipo Range                           ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:Section(nSection):EndQuery()
TRPosition():New(oReport:Section(nSection),"SA3",1,{||xFilial("SA3")+cVend })
TRPosition():New(oReport:Section(1):Section(1),"SA1",1,{|| xFilial("SA1")+(cAlias)->E3_CODCLI+(cAlias)->E3_LOJA })
TRPosition():New(oReport:Section(1):Section(1),"SB1",1,{|| xFilial("SB1")+(cAlias)->E3_XCODPRO})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio da impressao do fluxo do relatório                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTotBase	:= 0
nTotComis	:= 0

dbSelectArea(cAlias)
dbGoTop() 

nDecs     := GetMv("MV_CENT")
oReport:SetMeter(SE3->(LastRec()))
dbSelectArea(cAlias)

While !oReport:Cancel() .And. !&(cAlias)->(Eof())
	
	cVend := &(cAlias)->(E3_VEND)
	cFil := &(cAlias)->(E3_FILIAL)
	
	nAc1 := 0
	nAc2 := 0
	nAc3 := 0
	nAc4 := (cAlias)->A3_SALBASE
	nAc5 := (cAlias)->A3_SALBASE
	
	oReport:Section(nSection):Init()

	If mv_PAR07 == 1
		oReport:Section(nSection):PrintLine()
    Endif              
    
    
	While !Eof() .And. xFilial("SE3") == (cAlias)->E3_FILIAL .And. (cAlias)->E3_VEND == cVend
	
	
		dbSelectArea("SE3")
		dbSetOrder(2)
		dbSeek(xFilial("SE3")+cVend+&(cAlias)->(E3_PREFIXO)+&(cAlias)->(E3_NUM)+&(cAlias)->(E3_PARCELA))

       
		If mv_PAR07 == 1
			dbSelectArea(cAlias)
			oReport:Section(1):Section(1):Init()
 			oReport:Section(1):Section(1):PrintLine()
  			oReport:IncMeter()
       Endif
   	
   		nAc1 += SE3->E3_BASE
		nAc2 += IF(SE3->E3_PREFIXO = 'LTS',SE3->E3_COMIS,0)
		nAc3 += IF(SE3->E3_PREFIXO = 'MRG',SE3->E3_COMIS,0)
		nAc4 += SE3->E3_COMIS
//		nAc5 += (cAlias)->A3_SALBASE

		dbSelectArea(cAlias)
		dbSkip()
	EndDo

	If mv_PAR07 == 1
		nTotBase 	+= nAc1
		nTotComis 	+= nAc4
		oReport:Section(1):Section(1):SetTotalText("Total do Vendedor " + cVend)
		oReport:Section(1):Section(1):Finish()
	EndIf
	
	If mv_PAR07 == 2
		oReport:Section(nSection):Init()				
		oReport:Section(nSection):PrintLine()
	EndIf	
	oReport:Section(nSection):Finish()
	oReport:IncMeter()
	
	nTGerBas    += nAc1
    nTGerCom    += nAc4
	
EndDo
 
If mv_par07 == 1
	oGeral:SetPageBreak(.T.)
	oGeral:Cell("TXTTOTAL"):SetSize(21)
	oGeral:Cell("GERAL"   ):SetBlock  ( { || nTGerBas } ) 
	oGeral:Cell("COMIS"   ):SetBlock  ( { || nTGerCom } ) 
	oGeral:Init()
	oGeral:PrintLine()
	oGeral:Finish()
	oGeral:SetPageBreak(.T.)
EndIf 
Return
	











