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




cQryTotais := "  "
cQryTotais += "SELECT PRINCIPAL,  "
cQryTotais += "COUNT(DISTINCT CASE WHEN MES = 'ANTERIOR' THEN CONCAT(CLIENTE,LOJA) ELSE '' END) CLIANT, "
cQryTotais += "COUNT(DISTINCT CASE WHEN MES = 'ATUAL' THEN CONCAT(CLIENTE,LOJA) ELSE '' END) CLIATUAL, "
cQryTotais += "COUNT(DISTINCT CASE WHEN MES = 'ATUAL' THEN POSITIVACAO ELSE '' END) POSITIVACAO, "
cQryTotais += "COUNT(DISTINCT CASE WHEN MES = 'ATUAL' THEN PEDIDO ELSE '' END) PEDIDOS,  "
cQryTotais += "SUM(CASE WHEN MES = 'ATUAL' THEN VALOR ELSE 0 END) RECEBIDO,  "
cQryTotais += "ROUND(AVG(CASE WHEN MES = 'ANTERIOR' THEN VALOR ELSE NULL END),2) TMANT, "
cQryTotais += "ROUND(AVG(CASE WHEN MES = 'ATUAL' THEN VALOR ELSE NULL END),2) TMATUAL,  "
cQryTotais += "COUNT(DISTINCT CASE WHEN MES = 'ATUAL' THEN NOVO ELSE '' END) NOVOS "

cQryTotais += "FROM ( "
cQryTotais += "select C5_FILIAL FILIAL, C5_EMISSAO EMISSAO, C5_VEND1 VEND1, "
cQryTotais += "SA3.A3_NOME PRINCIPAL, C5_VEND4 VEND2, NVL(SA32.A3_NOME,' ') SECUNDARIO, C5_NUM PEDIDO,A1_NOME NOME,   "
cQryTotais += "A1_COD CLIENTE, A1_LOJA LOJA,  "
cQryTotais += "SUM(C6_VALOR) TOTAL, "
cQryTotais += "SUM(CASE WHEN C5_VEND4 <> ' ' THEN C6_VALOR/2 ELSE C6_VALOR END) VALOR,   "
cQryTotais += "CASE WHEN C5_VEND4 <> ' ' THEN 'METADE' ELSE 'TOTAL' END TIPO, "
cQryTotais += "NVL(PRIVENDA,' ') PRIVENDA, "
cQryTotais += "CASE WHEN  PRIVENDA > '20250831' AND PRIVENDA <= '20250931' THEN CONCAT(A1_COD,A1_LOJA) ELSE '' END NOVO, "
cQryTotais += "CASE WHEN  ULTIMA > '20250731' AND ULTIMA <= '20250831' THEN CONCAT(A1_COD,A1_LOJA) ELSE '' END POSITIVACAO, "
cQryTotais += "NVL(ULTIMA,' ') ULTIMA, "
cQryTotais += "CASE WHEN C5_EMISSAO >= '20250801' AND C5_EMISSAO <= '20250831' THEN 'ANTERIOR' ELSE 'ATUAL' END MES "
cQryTotais += "from SC5010 SC5   "
cQryTotais += "inner join SC6010 SC6 on C6_FILIAL = C5_FILIAL AND C6_NUM = C5_NUM AND C6_CLI = C5_CLIENTE AND C6_LOJA = C5_LOJACLI AND SC6.D_E_L_E_T_ <> '*'  "
cQryTotais += "left join SA3010 SA3 on SA3.A3_COD = C5_VEND1 AND SA3.D_E_L_E_T_ <> '*'  "
cQryTotais += "left join SA3010 SA32 on SA32.A3_COD = C5_VEND4 AND SA32.D_E_L_E_T_ <> '*'  "
cQryTotais += "inner join SA1010 SA1 on A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND SA1.D_E_L_E_T_ <> '*'  "

cQryTotais += "LEFT JOIN  "
cQryTotais += "(SELECT SETOR,A1_COD CODIGO, A1_LOJA LOJA,DESCR,EMISSAO PRIVENDA FROM ( "
cQryTotais += "SELECT 'VEN' SETOR, RTRIM(A1_COD) A1_COD, A1_LOJA, A1_NOME DESCR, ( "
cQryTotais += "SELECT MIN(SD2.D2_EMISSAO) EMISSAO  FROM SD2010 SD2 "
cQryTotais += "WHERE SD2.D2_CLIENTE = SA1.A1_COD  AND SD2.D2_TIPO = 'N' --AND SUBSTR(D2_CF,2,3) IN ('101','102','107','108','401','403') "
cQryTotais += "AND SD2.D_E_L_E_T_ <> '*'  "
cQryTotais += "AND SUBSTR(D2_CF,2,3) IN ('101','102','103','104','105','106','107', "
cQryTotais += "'109','110','111','112','113','114','115','116','117','118', "
cQryTotais += "'119','120','122','123','124','125','129','401','402','403','405') "
cQryTotais += ") AS EMISSAO FROM SA1010 SA1 "
cQryTotais += "WHERE SA1.D_E_L_E_T_ <> '*'  "
cQryTotais += ")) PRI on PRI.CODIGO = C5_CLIENTE AND PRI.LOJA = C5_LOJACLI "

cQryTotais += "LEFT JOIN  "
cQryTotais += "(SELECT A1_COD CODIGO, A1_LOJA LOJA, EMISSAO ULTIMA FROM ( "
cQryTotais += "SELECT 'VEN' SETOR, RTRIM(A1_COD) A1_COD, A1_LOJA, A1_NOME DESCR, ( "
cQryTotais += "SELECT MAX(SD2.D2_EMISSAO) EMISSAO  FROM SD2010 SD2 "
cQryTotais += "WHERE SD2.D2_CLIENTE = SA1.A1_COD  AND SD2.D2_TIPO = 'N' --AND SUBSTR(D2_CF,2,3) IN ('101','102','107','108','401','403') "
cQryTotais += "AND SD2.D_E_L_E_T_ <> '*' AND D2_EMISSAO <= '20250831' "
cQryTotais += "AND SUBSTR(D2_CF,2,3) IN ('101','102','103','104','105','106','107', "
cQryTotais += "'109','110','111','112','113','114','115','116','117','118', "
cQryTotais += "'119','120','122','123','124','125','129','401','402','403','405') "
cQryTotais += ") AS EMISSAO FROM SA1010 SA1 "
cQryTotais += "WHERE SA1.D_E_L_E_T_ <> '*'  "
cQryTotais += ")) ULT on ULT.CODIGO = C5_CLIENTE AND ULT.LOJA = C5_LOJACLI "

cQryTotais += "where C5_EMISSAO >= '20250801' AND C5_EMISSAO <= '20250931' AND SC5.D_E_L_E_T_ <> '*' 	 "
cQryTotais += "AND C5_VEND1 <> ' '  "
cQryTotais += "AND C5_VEND1 NOT IN ('6001')  "
cQryTotais += "AND A1_NREDUZ <> 'MRV'   "
cQryTotais += "AND C6_TES <> '598' AND C6_TES <> '905' AND C6_TES <> '921' AND C5_NUM <> '004298'  "

//--DANIELI FLAVIA.. 
//--25% do que tava no mes passado do que ele já vendia...

cQryTotais += "GROUP BY C5_FILIAL, C5_EMISSAO, C5_VEND1, C5_VEND4, C5_NUM,A1_NOME, A1_COD, A1_LOJA, SA3.A3_NOME, SA32.A3_NOME, PRIVENDA, ULTIMA "
cQryTotais += "ORDER BY C5_VEND1 "

cQryTotais += ") "

cQryTotais += "GROUP BY PRINCIPAL, VEND1 "



//PRINCIPAL
//CLIENTES_MES_ANTERIOR	
//CLIENTES_MES_ATUAL	
//POSITIVACAO	
//QTDE_PEDIDOS	
//RECEBIDO	
//TICKET_MEDIO_MES_ATUAL	
//TICKET_MEDIO_MES_ANTERIOR	
//CLIENTES_NOVOS

//PRINCIPAL
//CLIANT
//CLIATUAL
//POSITIVACAO	
//PEDIDOS	
//RECEBIDO	
//TMATUAL
//TMANTERIOR
//NOVOS

TCQuery cQryTotais New Alias 'QRY2_TAB'
	cVend := ""
	dbselectarea("QRY2_TAB")
	dbgotop()
	WHILE QRY2_TAB->(!EOF())
		
		IF(cVend != QRY2_TAB->C5_VEND1)
			oExcel:AddworkSheet("TOTAIS")
			oExcel:AddTable(QRY2_TAB->PRINCIPAL,"Table1")
			oExcel:AddColumn(QRY2_TAB->CLIANT,"Table1","Filial",1, 1)
			oExcel:AddColumn(QRY2_TAB->CLIATUAL,"Table1","Emissao",2, 2)
			oExcel:AddColumn(QRY2_TAB->POSITIVACAO,"Table1","Vend1",3, 3)
			oExcel:AddColumn(QRY2_TAB->PEDIDOS,"Table1","Principal",1, 4)
			oExcel:AddColumn(QRY2_TAB->RECEBIDO,"Table1","Vend2",1)
			oExcel:AddColumn(QRY2_TAB->TMATUAL,"Table1","Secundario",1)
			oExcel:AddColumn(QRY2_TAB->TMANTERIOR,"Table1","Pedido",1)
			oExcel:AddColumn(QRY2_TAB->NOVOS,"Table1","Nome",1)
		ELSE
			oExcel:AddRow(QRY2_TAB->PRINCIPAL,"Table1",{  })
		ENDIF
				
		

		QRY2_TAB->(DBSKIP())
	END






oExcel:Activate()

oExcel:GetXMLFile("C:\temp\TESTE.xlsx")

oExcel:DeActivate()
Return


