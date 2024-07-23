#Include "Rwmake.ch"
#INCLUDE "Topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGX472    ºAutor  ³Microsiga           º Data ³  07/29/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGX472()  

cPerg := "AGX472"
aRegistros := {}

AADD(aRegistros,{cPerg,"01","Produto De           ?","mv_ch1","C",15,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","SB1"})
AADD(aRegistros,{cPerg,"02","Produto Ate          ?","mv_ch2","C",15,0,0,"G","","MV_PAR02","","ZZZZZZZZZZZZZZZ","","","","","","","","","","","","","SB1"})
AADD(aRegistros,{cPerg,"03","Grupo De             ?","mv_ch3","C",04,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","SBM"})
AADD(aRegistros,{cPerg,"04","Grupo Ate            ?","mv_ch4","C",04,0,0,"G","","MV_PAR04","","ZZZZ","","","","","","","","","","","","","SBM"})
AADD(aRegistros,{cPerg,"05","Tipo De              ?","mv_ch5","C",02,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","02"})
AADD(aRegistros,{cPerg,"06","Tipo Ate             ?","mv_ch6","C",02,0,0,"G","","MV_PAR06","","ZZ","","","","","","","","","","","","","02"})
AADD(aRegistros,{cPerg,"07","Tabela De            ?","mv_ch7","C",03,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","DA0"})
AADD(aRegistros,{cPerg,"08","Tabela Ate           ?","mv_ch8","C",03,0,0,"G","","MV_PAR08","","ZZZ","","","","","","","","","","","","","DA0"})
AADD(aRegistros,{cPerg,"09","% Reajuste           ?","mv_chA","N",09,4,0,"G","","MV_PAR09","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"10","Fornecedor De        ?","mv_chF","C",06,0,0,"G","","MV_PAR10","","","","","","","","","","","","","","","SA2"})
AADD(aRegistros,{cPerg,"11","Fornecedor Ate       ?","mv_chG","C",06,0,0,"G","","MV_PAR11","","ZZZZZZ","","","","","","","","","","","","","SA2"})
AADD(aRegistros,{cPerg,"12","Loja De              ?","mv_chH","C",02,0,0,"G","","MV_PAR12","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"13","Loja Ate             ?","mv_chI","C",02,0,0,"G","","MV_PAR13","","ZZ","","","","","","","","","","","","",""})

U_CriaPer(cPerg,aRegistros)  

If Pergunte(cPerg,.T.)
   Processa({|| Atualiza()}, "Atualizando Preços,Aguarde...")	  
   
EndIF

Return()

Static Function Atualiza
cQuery := "" 
cQuery := "SELECT * "
cQuery += "FROM "+RetSqlName("DA1")+" DA1,"
cQuery += RetSqlName("SB1")+" SB1 "
cQuery += "WHERE DA1.DA1_FILIAL='"+xFilial("DA1")+"' AND "
cQuery += "DA1.DA1_CODPRO >= '"+MV_PAR01+"' AND "
cQuery += "DA1.DA1_CODPRO <= '"+MV_PAR02+"' AND "
cQuery += "DA1.DA1_CODTAB >= '"+MV_PAR07+"' AND "
cQuery += "DA1.DA1_CODTAB <= '"+MV_PAR08+"' AND "
cQuery += "DA1.D_E_L_E_T_=' ' AND "
cQuery += "SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
cQuery += "SB1.B1_COD = DA1.DA1_CODPRO AND "
cQuery += "SB1.B1_GRUPO>='"+MV_PAR03+"' AND "
cQuery += "SB1.B1_GRUPO<='"+MV_PAR04+"' AND "	
cQuery += "SB1.B1_TIPO>='"+MV_PAR05+"' AND "
cQuery += "SB1.B1_TIPO<='"+MV_PAR06+"' AND "	
cQuery += "SB1.B1_PROC>='"+MV_PAR10+"' AND "
cQuery += "SB1.B1_PROC<='"+MV_PAR11+"' AND "
cQuery += "SB1.B1_LOJPROC>='"+MV_PAR12+"' AND "
cQuery += "SB1.B1_LOJPROC<='"+MV_PAR13+"' AND "		
cQuery += "SB1.D_E_L_E_T_=' '      AND DA1_PRCVEN > 0.02  "
//cQuery += "ORDER BY "+SqlOrder(DA1->(IndexKey()))

If Select("QRY") <> 0
   dbSelectArea("QRY")
   dbCloseArea()
Endif

cQuery := ChangeQuery(cQuery)
TCQuery cQuery NEW ALIAS "QRY"

dbSelectArea("QRY")
ProcRegua(500)
dbGoTop()
While !Eof()        
    
     dbSelectArea("DA1")
     dbSetOrder(3)
     dbSeek(QRY->DA1_FILIAL+QRY->DA1_CODTAB+QRY->DA1_ITEM)

     RecLock("DA1",.F.)
        DA1->DA1_PRCVEN = DA1->DA1_PRCVEN + (DA1->DA1_PRCVEN * (MV_PAR09/100))
     MsUnLock()

     dbSelectArea("QRY")
     QRY->(dbSkip())
EndDo

Return()		