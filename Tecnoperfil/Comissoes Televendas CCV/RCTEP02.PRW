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
Private _oUtil := TUtil():New()


_oUtil:registraAnaliseUso("RCTEP02")
cPerg := PADR(cPerg,10)

AADD(aRegs,{cPerg,"01","Ano         ","","","mv_ch1","C",04,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Competência ","","","mv_ch2","C",02,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})

//U_SIDCRIAPER(cPerg,aRegs)

//Atualiza parametro
fAtuParam(cPerg)
If pergunte(cPerg,.T.)
	
	PRINTEXCEL()


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
static Function PRINTEXCEL()

oExcel := FwMsExcelXlsx():New()

lRet := oExcel:IsWorkSheet("Comissoes")
oExcel:AddworkSheet("Comissoes")


Local _cAliasCom := GetNextAlias()

  
_cQuery := " SELECT       SA3.A3_COD AS CODIGO, SA3.A3_NOME AS NOME, ZP1.ZP1_META META, ZP1_VALOR VALOR, ZP1_BONUS BONUS "
_cQuery += " FROM         "+RetSqlName("ZP1")+" ZP1 "
_cQuery += " INNER JOIN   "+RetSqlName("SA3")+" SA3 "	
_cQuery += "         ON   SA3.A3_FILIAL   = '"+ xFilial("SA3") +"' "	
_cQuery += "        AND   SA3.D_E_L_E_T_  = ' ' "	
_cQuery += "        AND   SA3.A3_COD      = ZP1.ZP1_CODSA3 "	
_cQuery += " WHERE        ZP1.D_E_L_E_T_  = ' ' "
_cQuery += " AND          ZP1.ZP1_FILIAL  = '"+ xFilial("ZP1") +"' "
_cQuery += " AND          ZP1.ZP1_ANO     = '"+ mv_par01 +"' "
_cQuery += " AND          ZP1.ZP1_MES     = '"+ mv_par02 +"' "
_cQuery += " ORDER BY SA3.A3_NOME " 

Conout(_cQuery)
_nRegs := _oUtil:executaQuery(_cQuery,(_cAliasCom),.T.)

lRet := oExcel:IsWorkSheet("Comissoes")
oExcel:AddTable ("Comissoes","Fechamento de Comissões")

oExcel:AddColumn("Comissoes","Table1","Codigo",1,1,.F., "")
oExcel:AddColumn("Comissoes","Table1","Nome",2,2,.F., "")
oExcel:AddColumn("Comissoes","Table1","Meta",3,3,.F., "")
oExcel:AddColumn("Comissoes","Table1","Valor",1,1,.T., "")
oExcel:AddColumn("Comissoes","Table1","Bonus",1,1,.T., "")

If _nRegs > 0
	While (_cAliasCom)->(!Eof())
		
		oExcel:AddRow("Comissoes","Table1",{(_cAliasCom)->(CODIGO),(_cAliasCom)->(NOME), (_cAliasCom)->(META),(_cAliasCom)->(VALOR),  (_cAliasCom)->(BONUS)})
		
	   (_cAliasCom)->(dbSkip())      
	End
	(_cAliasCom)->(dbCloseArea())
Endif	

/*oExcel:SetFont("arial")
oExcel:SetFontSize(20)
oExcel:SetItalic(.T.)
oExcel:SetBold(.T.)
oExcel:SetUnderline(.T.)*/



	cQueryTab := "  "
	cQueryTab += "select C5_FILIAL FILIAL, C5_EMISSAO EMISSAO, C5_VEND1 VEND1,SA3.A3_NOME PRINCIPAL, C5_VEND4 VEND2, NVL(SA32.A3_NOME,' ') SECUNDARIO, C5_NUM PEDIDO,A1_NOME NOME,  "
	cQueryTab += "A1_COD CLIENTE, A1_LOJA LOJA, "
	cQueryTab += "SUM(C6_VALOR) TOTAL,  "
	cQueryTab += "SUM(CASE WHEN C5_VEND4 <> ' ' THEN C6_VALOR/2 ELSE C6_VALOR END) VALOR,  "
	cQueryTab += "CASE WHEN C5_VEND4 <> ' ' THEN 'METADE' ELSE 'TOTAL' END TIPO  "
	cQueryTab += "from "+RETSQLNAME("SC5")+" SC5  "
	cQueryTab += "inner join "+RETSQLNAME("SC6")+" SC6 on C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM AND C6_CLI = C5_CLIENTE AND C6_LOJA = C5_LOJACLI AND SC6.D_E_L_E_T_ <> '*' "
	cQueryTab += "left join "+RETSQLNAME("SA3")+" SA3 on SA3.A3_COD = C5_VEND1 AND SA3.D_E_L_E_T_ <> '*' "
	cQueryTab += "left join "+RETSQLNAME("SA3")+" SA32 on SA32.A3_COD = C5_VEND4 AND SA32.D_E_L_E_T_ <> '*' "
	cQueryTab += "inner join "+RETSQLNAME("SA1")+" SA1 on A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND SA1.D_E_L_E_T_ <> '*' "
	cQueryTab += "where C5_EMISSAO > '"+DTOS(_dFecMes)+"' AND C5_EMISSAO <= '"+DTOS(_dDtFec)+"' AND SC5.D_E_L_E_T_ <> '*' "
	//cQueryTab += "AND (C5_VEND1 = '9996' OR C5_VEND4 = '9996') "
	cQueryTab += "	AND C5_VEND1 <> ' ' "
	cQueryTab += "AND C5_VEND1 NOT IN ('113396','110641', '6001') "
	cQueryTab += "AND A1_NREDUZ <> 'MRV' " 
	cQueryTab += "AND C6_TES <> '598' AND C6_TES <> '905' AND C6_TES <> '921' AND C5_NUM <> '004298' " //Exceções
	cQueryTab += "GROUP BY C5_FILIAL, C5_EMISSAO, C5_VEND1, C5_VEND4, C5_NUM,A1_NOME, A1_COD, A1_LOJA, SA3.A3_NOME, SA32.A3_NOME "
	cQueryTab += "ORDER BY C5_VEND1 "
	
	TCQuery cQueryTab New Alias 'QRY_TAB'
	cVend := ""
	dbselectarea("QRY_TAB")
	dbgotop()
	WHILE QRY_TAB->(!EOF())
		
		IF(cVend != QRY_TAB->C5_VEND1)
			oExcel:AddworkSheet(QRY_TAB->PRINCIPAL)
			oExcel:AddTable(QRY_TAB->PRINCIPAL,"Table1")
			oExcel:AddColumn(QRY_TAB->PRINCIPAL,"Table1","Filial",1, 1)
			oExcel:AddColumn(QRY_TAB->PRINCIPAL,"Table1","Emissao",2, 2)
			oExcel:AddColumn(QRY_TAB->PRINCIPAL,"Table1","Vend1",3, 3)
			oExcel:AddColumn(QRY_TAB->PRINCIPAL,"Table1","Principal",1, 4)
			oExcel:AddColumn(QRY_TAB->PRINCIPAL,"Table1","Vend2",1)
			oExcel:AddColumn(QRY_TAB->PRINCIPAL,"Table1","Secundario",1)
			oExcel:AddColumn(QRY_TAB->PRINCIPAL,"Table1","Pedido",1)
			oExcel:AddColumn(QRY_TAB->PRINCIPAL,"Table1","Nome",1)
			oExcel:AddColumn(QRY_TAB->PRINCIPAL,"Table1","Cliente",1)
			oExcel:AddColumn(QRY_TAB->PRINCIPAL,"Table1","Loja",1)
			oExcel:AddColumn(QRY_TAB->PRINCIPAL,"Table1","Vend2",1)
			oExcel:AddColumn(QRY_TAB->PRINCIPAL,"Table1","Total",1)
			oExcel:AddColumn(QRY_TAB->PRINCIPAL,"Table1","Valor",1)
			oExcel:AddColumn(QRY_TAB->PRINCIPAL,"Table1","Tipo",1)

		ELSE
			oExcel:AddRow(QRY_TAB->PRINCIPAL,"Table1",{  })
		ENDIF
				
		

		QRY_TAB->(DBSKIP())
	END

oExcel:Activate()

oExcel:GetXMLFile("C:\temp\TESTE.xlsx")

oExcel:DeActivate()
Return


