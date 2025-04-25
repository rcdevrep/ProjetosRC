#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
//±±³Cliente   ³            ³                                                 ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Programa  ³ VEIR005    ³ Autor ³ RICARDO BECKERT       ³ Data ³ 09/03/16 ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
//±±³          ³                                                              ³±±
//±±³Descricao ³ RELATORIO CALCULO COMISSAO COMPETENCIA                       ³±±
//±±³          ³                                                              ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Parametros³                                                              ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
//±±³Retorno   ³                                                              ³±±
//±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
User Function RCTEP02()

Local   oReport
Local   aRegs  := {}
Private cPerg  := "RCTEP02"
//Private _oUtil := TUtil():New()


//_oUtil:registraAnaliseUso("RCTEP02")
cPerg := PADR(cPerg,10)

AADD(aRegs,{cPerg,"01","Ano         ","","","mv_ch1","C",04,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Competência ","","","mv_ch2","C",02,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})

//U_SIDCRIAPER(cPerg,aRegs)

//Atualiza parametro
fAtuParam(cPerg)
If pergunte(cPerg,.T.)
	oReport := ReportDef()
	oReport:PrintDialog()	
Endif

	
Return
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
//±±³STATIC FUNCTION ³ FATUPARAM                                            ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
//±±³                                                                       ³±±
//±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Static Function fAtuParam(cPerg)

SetMVValue(cPerg,"MV_PAR01",SubStr(DtoS(Date()),1,4) )
SetMVValue(cPerg,"MV_PAR02",SubStr(DtoS(Date()),5,2) )

/*SX1->(dbSeek(cPerg + "01"))
RecLock("SX1",.F.)
SX1->X1_CNT01 := SubStr(DtoS(Date()),1,4) 
MsUnLock("SX1")

SX1->(dbSeek(cPerg + "02"))
RecLock("SX1",.F.)
SX1->X1_CNT01 := SubStr(DtoS(Date()),5,2) 
MsUnLock("SX1")*/

Return
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
//±±³STATIC FUNCTION ³ REPORTDEF                                            ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
//±±³DEFINICAO DO LAYOUT DO RELATORIO                                       ³±±
//±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Static Function ReportDef()

Local oReport
Local oSection1
Local aOrdem := {"Código","Nome"}

oReport := TReport():New("VEIR005","Cálculo Comissão Competência","VEIR005",{|oReport| ReportPrint(oReport)},"Cálculo Comissão Competência")
oReport:SetPortrait(.T.)
oReport:SetTotalInLine(.F.)


oSection1 := TRSection():New(oReport,"Relatório Cálculo Comissão",{},aOrdem)
oSection1:SetLineBreak(.F.)

TRCell():New(oSection1,"COD",,"Código"			,"@!"				,20,.F.)
TRCell():New(oSection1,"NOM",,"Nome"			,"@!"				,50,.F.)
TRCell():New(oSection1,"FIX",,"Perc. Fixo"		,"@E 9,999,999.99"	,12,.F.,,"RIGHT")
TRCell():New(oSection1,"SAL",,"Perc. Saldo"		,"@E 9,999,999.99"	,12,.F.,,"RIGHT")
TRCell():New(oSection1,"MAR",,"Perc. Margem"	,"@E 9,999,999.99"	,12,.F.,,"RIGHT") 
TRCell():New(oSection1,"LIN",,"Perc. Linhas"	,"@E 9,999,999.99"	,12,.F.,,"RIGHT") 
TRCell():New(oSection1,"MET",,"Perc. Meta"		,"@E 9,999,999.99"	,12,.F.,,"RIGHT") 
TRCell():New(oSection1,"TOT",,"Perc. Total"		,"@E 9,999,999.99"	,12,.F.,,"RIGHT") 

	
Return oReport
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
//±±³STATIC FUNCTION ³ REPORTPRINT                                          ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
//±±³FAZ A IMPRESSAO DO RELATORIO CONFOME LAYOUT                            ³±±
//±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Static Function ReportPrint(oReport)

Local oSection1 := oReport:Section(1)
Local nOrdem 	  := oSection1:GetOrder()

Local _cAliasCom := GetNextAlias()

//Verifica Competencia se existe mais de um fechamento
_dDtFec := fVerifComp()
  
  
_cQuery := " SELECT       SA3.A3_COD AS CODIGO, SA3.A3_NOME AS NOME, ZP1.ZP1_FIXO, ZP1.ZP1_SALDO, ZP1.ZP1_MARGEM, ZP1.ZP1_LINHA, ZP1.ZP1_META "
_cQuery += " FROM         "+RetSqlName("ZP1")+" ZP1 "
_cQuery += " INNER JOIN   "+RetSqlName("SA3")+" SA3 "	
_cQuery += "         ON   SA3.A3_FILIAL   = '"+ xFilial("SA3") +"' "	
_cQuery += "        AND   SA3.D_E_L_E_T_  = ' ' "	
_cQuery += "        AND   SA3.A3_COD      = ZP1.ZP1_CODSA3 "	
_cQuery += " WHERE        ZP1.D_E_L_E_T_  = ' ' "
_cQuery += " AND          ZP1.ZP1_FILIAL  = '"+ xFilial("ZP1") +"' "
_cQuery += " AND          ZP1.ZP1_ANO     = '"+ mv_par01 +"' "
_cQuery += " AND          ZP1.ZP1_MES     = '"+ mv_par02 +"' "
If Type("_dDtFec") == "D"
	_cQuery += " AND      ZP1.ZP1_DTFEC   = '"+ DtoS(_dDtFec) +"' "	
Endif
If nOrdem == 1
	_cQuery += " ORDER BY SA3.A3_COD "
ElseIf nOrdem == 2
	_cQuery += " ORDER BY SA3.A3_NOME " 
Endif

Conout(_cQuery)
_nRegs := _oUtil:executaQuery(_cQuery,(_cAliasCom),.T.)

If _nRegs > 0
	oSection1:Init()
	
	oReport:SetMeter(_nRegs)
	
	While (_cAliasCom)->(!Eof())
		oReport:IncMeter()
		
		_nPercTot := ((_cAliasCom)->(ZP1_FIXO) + (_cAliasCom)->(ZP1_SALDO) + (_cAliasCom)->(ZP1_MARGEM) + (_cAliasCom)->(ZP1_LINHA) + (_cAliasCom)->(ZP1_META))	
		
			
		oSection1:Cell("COD"):SetValue({ || (_cAliasCom)->(CODIGO)		})
		oSection1:Cell("NOM"):SetValue({ || (_cAliasCom)->(NOME)		})
		oSection1:Cell("FIX"):SetValue({ || (_cAliasCom)->(ZP1_FIXO)	}) 
		oSection1:Cell("SAL"):SetValue({ || (_cAliasCom)->(ZP1_SALDO)	}) 
		oSection1:Cell("MAR"):SetValue({ || (_cAliasCom)->(ZP1_MARGEM)	}) 
		oSection1:Cell("LIN"):SetValue({ || (_cAliasCom)->(ZP1_LINHA)	}) 
		oSection1:Cell("MET"):SetValue({ || (_cAliasCom)->(ZP1_META)	}) 
		oSection1:Cell("TOT"):SetValue({ || _nPercTot					})  
		
		
		oSection1:PrintLine()
		
	   (_cAliasCom)->(dbSkip())      
	End
	(_cAliasCom)->(dbCloseArea())
	
	oSection1:Finish()
	
	oReport:EndPage()
Endif	

	
Return
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
//±±³STATIC FUNCTION ³ FVERIFCOMP                                           ³±±
//±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
//±±³                                                                       ³±±
//±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Static Function fVerifComp()

Local _dDtSel
Local _cAlias := GetNextAlias()

_aArrData := {}
 

_cQuery := " SELECT    ZP1.ZP1_DTFEC "
_cQuery += " FROM      "+RetSqlName("ZP1")+" ZP1 "	
_cQuery += " WHERE     ZP1.D_E_L_E_T_  = ' ' "
_cQuery += " AND       ZP1.ZP1_FILIAL  = '"+ xFilial("ZP1") +"' "
_cQuery += " AND       ZP1.ZP1_ANO     = '"+ mv_par01 +"' "
_cQuery += " AND       ZP1.ZP1_MES     = '"+ mv_par02 +"' "
_cQuery += " GROUP BY  ZP1.ZP1_DTFEC "
_cQuery += " ORDER BY  ZP1.ZP1_DTFEC "

_nRegs := _oUtil:executaQuery(_cQuery,(_cAlias),.T.)

If _nRegs > 1
	While (_cAlias)->(!Eof())
		aadd(_aArrData, StoD((_cAlias)->ZP1_DTFEC))
	
		(_cAlias)->(dbSkip())
	End
	(_cAlias)->(dbCloseArea())
	
	
	_oDlg := TDialog():New(000,000,300,400,"Data de Fechamento",,,,,CLR_BLACK,CLR_WHITE,,,.T.)
	
	_oSay1	:= TSay():New(015,004,{|| "Encontrado mais de um Fechamento para o Período escolhido, escolha a Data de Fechamento para impressão do relatório!" },_oDlg,,,,,,.T.,CLR_BLACK,CLR_WHITE,190,30)
		
	_oPanel := TPanel():New(050,005,,_oDlg,,,,,,190,080)
	_oLb := FWBrowse():New(_oPanel)
	
	_oLb:AddColumn({"Data de Fechamento",{|| _aArrData[_oLb:nAt] },"C","@!","LEFT",20,0,.F.})
	
	_oLb:nAt := 1
	_oLb:DisableReport()
	_oLb:DisableConfig()
	_oLb:SetDataArray()
	_oLb:SetArray(_aArrData)
	_oLb:bLDblClick := {|| (_dDtSel := _aArrData[_oLb:nAt], _oDlg:End()) }
	_oLb:Activate()
	
	_oBtConf := TButton():New(135,005,"Confirmar",_oDlg,{|| (_dDtSel := _aArrData[_oLb:nAt], _oDlg:End()) },60,12,,,.F.,.T.,.F.,,.F.,,,.F.) 	
		
	_oDlg:Activate(,,,.T.,{|| .T.},,{|| .T.} )

Endif

Return _dDtSel
